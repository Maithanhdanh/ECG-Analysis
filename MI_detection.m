warning('off','all');
clear all; close all; clc
%% ============================ Add path ==================================
data_path = 'E:\MY_THESIS\database\euro\';

%% ====================== Calling arrhythmia records ======================
recordings =    [104];%[103 104 105 106 112 113 118 121 129 133 136 139 154 161 162 163 170 105 108 112 115 123 129 133 147 154 104 112 118 122 154 161 612 801 808];
leads =         [002];%[001 002 001 002 002 002 001 001 002 002 002 002 002 002 002 002 001 001 001 002 002 002 002 002 002 002 001 002 002 002 001 002 002 002 002];

% recordings =    [300];%[300 301 302 304 305 306 307 308 310 311 312 315 316 317 318 319 320 321 322 323 324 325 326 327];
% leads =         [001];%[001 001 001 002 001 001 002 001 002 001 002 001 001 001 002 002 002 002 002 002 002 001 002 002];

% recordings =    [16272];%[16272 16420 16483 16539 16773 16786 16795 17052 17453 18177 18184 19088 19090 19093 19140 19830];
% leads =         [001];%[001];
%% =========================== New parameters =============================
mean_HRV_all = [];
std_HRV_all = [];

% counter1 = 0;
% counter2 = 0;
% counter3 = 0;

%% ============================= Processing ===============================
for record = 1:length(recordings)
    full_data = [];
    left_all = []; R_loc_all = [];   % value and location of R peak
    T_value_all = [0]; T_loc_all = [];   % value and location of T peak
    S_value_all = []; S_loc_all = [];   % value and location of S peak
    J_value_all = [0]; J_loc_all = [];   % value and location of J peak

    ST_segment_all = [];
    mean_STS_all = [];
    std_STS_all = [];
    
    PR_segment_all = [];
    mean_PRS_all = [];
    std_PRS_all = [];

    diagnosis = [];
    STD_all = [];
    k = [];
        
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
        
        ST_segment = [];
        PR_segment = [];
        ST_deviation =[];
        

        
        % ====== feature extraction ======
        [c,R_value, R_loc, Q_value, Q_loc, S_value, S_loc, J_value, J_loc, T_value, T_loc, P_value, P_loc, K_loc, K_value, RR, PR, QT, HRV, tqrs, trr, tpr, tqt,ST] = ecg_extraction(data,fs);
        m = m + 1;
        
        counter1 = 0;
        counter2 = 0;
        counter3 = 0;
%         figure
%         plot(t(1:length(c)),c)
%         hold on
%         plot(t(K_loc),K_value,'o',t(P_loc),P_value,'x');
        % ====== PR segments ======
        for j = 2:length(K_loc)
            PK_loc = P_loc(j-1) : K_loc(j);
            PK_value = c(P_loc(j-1) : K_loc(j));
            PR_segment(end + 1) = mean(PK_value) /mean(PK_loc)*1000;
        end
        PR_segment_all = [PR_segment_all PR_segment];
        mean_PRS = mean(PR_segment);
        mean_PRS_all = [mean_PRS_all mean_PRS];
        
        std_PRS = std(PR_segment);
        std_PRS_all = [std_PRS_all std_PRS];
        
        % ====== ST segments ======
        for j = 1:length(T_loc)
            JT_loc = J_loc(j) : T_loc(j);
            JT_value = c(J_loc(j) : T_loc(j));
            ST_segment(end + 1) = mean(JT_value) /mean(JT_loc)*1000;
        end
        ST_segment_all = [ST_segment_all ST_segment];
        mean_STS = mean(ST_segment);
        mean_STS_all = [mean_STS_all mean_STS];
        
        std_STS = std(ST_segment);
        std_STS_all = [std_STS_all std_STS];

        
        % ====== ST-deviation ======
        for j = 1:length(ST_segment)
            ST_deviation(end + 1) = abs(ST_segment(j) - PR_segment(j));
        end
        STD_all = [STD_all mean(ST_deviation)];
        a = find(STD_all >= 1);
%         if mean(ST_deviation) >= 1
%             figure
%             plot(t(1:length(c)),c)
%             hold on
%             plot(t(K_loc),K_value,'o',t(P_loc),P_value,'x');
%             
%             if k == 40
%                 a = 1;
%             else k = k+1;
%             end
%     end
        % ====== detect MI ======
        a = length (PR_segment);
        b = length (ST_segment);

        for j = 1:a
        counter1=counter1+1;
            if PR_segment(j) <= (ST_segment(j) + 0.17) && ...
                    PR_segment(j) >= (ST_segment(j) - 0.17)
               counter2=counter2+1;
            else
               counter3=counter3+1;

            end
        end

        fprintf (1,'\nK> total number of signals evaluated is %d\n',counter1)
        fprintf (1,'\nK> total number of signals without MI is %d\n',counter2)
        fprintf (1,'\nK> total number of signals with MI is %d\n',counter3)
        if counter3/counter1>=0.95
            fprintf(1,'\nK>WARNING: MI\n');
            figure
            plot(t(1:length(c)),c);
            pause(5)
           k = [k m];
        else
            fprintf(1,'\nK>No MI\n');
%             pause(0.5)
        end 

        clc
        close all
    end 
end;