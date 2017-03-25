warning('off','all');
clear all; close all; clc
%% ============================ Add path ==================================
data_path = 'E:\MY_THESIS\database\euro\';

%% ====================== Calling arrhythmia records ======================
recordings =    [103];%[103 104 105 106 112 113 118 121 129 133 136 139 154 161 162 163 170 105 108 112 115 123 129 133 147 154 104 112 118 122 154 161 612 801 808];
leads =         [001];%[001 002 001 002 002 002 001 001 002 002 002 002 002 002 002 002 001 001 001 002 002 002 002 002 002 002 001 002 002 002 001 002 002 002 002];
% 201(225.6) 202(149.4)
%% =========================== New parameters =============================
mean_HRV_all = [];
std_HRV_all = [];

%% ============================= Processing ===============================
for record = 1:length(recordings)
    full_data = [];
    left_all = []; R_loc_all = [];   % value and location of R peak
    T_value_all = [0]; T_loc_all = [];   % value and location of T peak
    S_value_all = []; S_loc_all = [];   % value and location of S peak
    J_value_all = [0]; J_loc_all = [];   % value and location of J peak
    JTslope1 = [];
    JTslope2 = [];
    
    J_mean_all = [];
    J_std_all = [];
    
    S_mean_all = [];
    S_std_all = [];
    STslope = [];
    mean_STS = [];
    mean_JTslope1 = [];
    mean_JTslope2 = [];
    JTslope_all1 = [];
    JTslope_all2 = [];
    
    T_mean_all = [];
    T_std_all = [];

    diagnosis = [];
    
    std_JTS1 = [];
    std_JTslope1 = [];
    std_JTS2 = [];
    std_JTslope2 = [];
        
    filename = ['e0' num2str(recordings(record))];

    disp(filename);
    full_path = [data_path filename '.hea'];
    ECGw = ECGwrapper( 'recording_name', full_path);

    % ====== READ SIGANL AND ANNOTATION ======
    ann = ECGw.ECG_annotations;
    hea = ECGw.ECG_header;
    sig = ECGw.read_signal(1,hea.nsamp);
    sig1 = sig(:,leads(record));

    % ====== GENERAL PARAMETERS ======
    fs = hea.freq;
    ts = 1/fs;
    t = [0:length(sig1)-1]/fs;
    
    %------ LOAD ATTRIBUTES DATA ----------------------------------------------
    full_path = [data_path filename '.atr'];      % attribute file with annotation data
    fid3=fopen(full_path,'r');
    A= fread(fid3, [2, length(sig1)], 'uint8')';
    fclose(fid3);
    ATRTIME=[];
    ANNOT=[];
    sa=size(A);
    saa=sa(1);
    i=1;
    while i<=saa
        annoth=bitshift(A(i,2),-2);
        if annoth==59
            ANNOT=[ANNOT;bitshift(A(i+3,2),-2)];
            ATRTIME=[ATRTIME;A(i+2,1)+bitshift(A(i+2,2),8)+...
                    bitshift(A(i+1,1),16)+bitshift(A(i+1,2),24)];
            i=i+3;
        elseif annoth==60
            % nothing to do!
        elseif annoth==61
            % nothing to do!
        elseif annoth==62
            % nothing to do!
        elseif annoth==63
            hilfe=bitshift(bitand(A(i,2),3),8)+A(i,1);
            hilfe=hilfe+mod(hilfe,2);
            i=i+hilfe/2;
        else
            ATRTIME=[ATRTIME;bitshift(bitand(A(i,2),3),8)+A(i,1)];
            ANNOT=[ANNOT;bitshift(A(i,2),-2)];
       end;
       i=i+1;
    end;
    ANNOT(length(ANNOT))=[];       % last line = EOF (=0)
    ATRTIME(length(ATRTIME))=[];   % last line = EOF
    clear A;
    ATRTIME= cumsum(ATRTIME)/360;
    ind= find(ATRTIME <= t(end));
    ATRTIMED= ATRTIME(ind);
    ANNOT=round(ANNOT);
    ANNOTD= ANNOT(ind);
    
    MI_peak = find((ANNOT == 18) | (ANNOT == 19))';
    m = 0;
    windowl = 5*fs;
    for i = 1:windowl:length(sig1)-windowl
        data = sig1(i+1:i+windowl);
%         
        STslope = [];
        JTslope1 = [];
        JTslope2 = [];
        
        % ====== feature extraction ======
        [c,R_value, R_loc, Q_value, Q_loc, S_value, S_loc, J_value, J_loc, T_value, T_loc, P_value, P_loc, RR, PR, QT, HRV, tqrs, trr, tpr, tqt,ST] = ecg_extraction(data,fs);
        m = m + 1;
        
        for j = 1:length(T_loc)
            JT_loc = J_loc(j) : T_loc(j);
            JT_value = c(J_loc(j) : T_loc(j));
            JTslope1(end + 1) = mean(JT_value) /mean(JT_loc)*1000;
        end
        JTslope_all1 = [JTslope_all1 JTslope1];
        mean_JTS1 = mean(JTslope1);
        mean_JTslope1 = [mean_JTslope1 mean_JTS1];
        
        std_JTS1 = std(JTslope1);
        std_JTslope1 = [std_JTslope1 std_JTS1];
%         if length(mean_JTslope1) >= 140 && length(mean_JTslope1) <= 160
%            figure
%            plot(c)
%         end
        
        
        for j = 1:length(T_loc)
            JT_loc = J_loc(j) : T_loc(j);
            JT_value = c(JT_loc);
            JTslope2(end + 1) = mean(JT_value) /length(JT_loc)*1000;
        end
        JTslope_all2 = [JTslope_all2 JTslope2];
        mean_JTS2 = mean(JTslope2);
        mean_JTslope2 = [mean_JTslope2 mean_JTS2];
        
        std_JTS2 = std(JTslope2);
        std_JTslope2 = [std_JTslope2 std_JTS2];
        
        sign = zeros(1,length(JTslope1));
        if mean_JTS1 > 4
            sign = ones(1,length(JTslope1));
            sign(find(JTslope1 < 1)) = 0;
            
            diagnosis = [diagnosis 1];
        else
            diagnosis = [diagnosis 0];
        end
%         diagnosis = [diagnosis sign];

%         ST_peak1 = find(mean_JTslope > 11 | mean_JTslope < -4);
   
%         if JT_value_mean < 10
%             figure
%             plot(t(1:length(c)),c);
%             hold on
%             plot(t(J_loc),J_value,'o',t(T_loc),T_value,'^');
%         end
    end
    a = find(diagnosis == 1);
end;