clear all; close all

data_path = 'E:\MY_THESIS\database\euro\';
recordings =    [106];
leads =         [002];
filename = ['e0' num2str(recordings)];
%filename = ['rec_' num2str(record)];
full_path = [data_path filename '.hea'];
% ECGw = ECGwrapper( 'recording_name', full_path);

% ====== READ SIGANL AND ANNOTATION ======
ann = ECGw.ECG_annotations;
hea = ECGw.ECG_header;
sig = ECGw.read_signal(1,hea.nsamp);
sig1_raw = sig(:,leads);
sig1_raw = sig1_raw(1:end);
% ====== NORMALIZATION CODES ======
sig1_raw = sig1_raw - mean(sig1_raw);
L = length(sig1_raw);
Ex = 1/L * sum(abs(sig1_raw).^2);
sig1_raw = sig1_raw / Ex;
% ====== BASELINE REMOVE USING Wavelet_decompose ======
[approx, detail] = wavelet_decompose(sig1_raw, 8, 'db4');
sig1 = sig1_raw - approx(:,8);
%sig1 = sig1_raw;
sig_backup = sig1;
% ====== NORMALIZA THE SIGNAL FROM 0 TO 1 ======
sig1 = sig1 + abs(min(sig1));
sig1 = sig1 / max(sig1);

% ====== GENERAL PARAMETERS ======
fs = hea.freq;
ts = 1/fs;

d=sig1;
Fs = fs;
t=[0:length(d)-1]/Fs;

if isrow(d) == 0
    d = d';
end

%% filter baseline%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a b]=butter(5,[0.5 40]/(Fs/2));
c = filtfilt(a,b,d);
c = c + abs(min(c));
c = c / max(c);
    
%% bandpass filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%LPF
b=[1 0 0 0 0 0 -2 0 0 0 0 0 1];
a=[1 -2 1];
h_LP=filter(b,a,[1 zeros(1,12)]);

x2 = conv (c ,h_LP);
x2 = x2 (6+[1: length(d)]); %cancle delay
x2 = x2/ max( abs(x2 ));

%HPF
b = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
a = [1 -1];

h_HP=filter(b,a,[1 zeros(1,32)]); % impulse response of HPF
 
x3 = conv (x2 ,h_HP);
x3 = x3 (16+[1: length(d)]); %cancle delay
x3 = x3/ max( abs(x3 ));

%% Make impulse response %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = [-1 -2 0 2 1]/8;

% Apply filter
x4 = conv (c ,h);
x4 = x4 (2+[1: length(d)]);
x4 = x4/ max( abs(x4 ));

%% Squaring %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x5 = x4 .^2;
x5 = x5/ max( abs(x5 ));

%% Make impulse response %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = ones (1 ,31)/31;
Delay = 15; % Delay in samples

% Apply filter
x6 = conv (x5 ,h);
x6 = x6 (15+[1: length(d)]);
x6 = x6/ max( abs(x6 ));

max_h = max(x6);
thresh = mean (x6 );
poss_reg =(x6>thresh*max_h);

left = find(diff([0 poss_reg])==1);
right = find(diff([poss_reg 0])==-1);

for i=1:length(left)
    %R peak
    [R_value(i) R_loc(i)] = max(c(left(i):right(i)) );
    R_loc(i) = R_loc(i) - 1 + left(i); % add offset

    %Q peak
    [Q_value(i) Q_loc(i)] = min(c(left(i):R_loc(i)) );
    Q_loc(i) = Q_loc(i) - 1 + left(i); % add offset

    %S peak
    [S_value(i) S_loc(i)] = min(c(R_loc(i):right(i)) );
    S_loc(i) = S_loc(i) + R_loc(i); % add offset
    
    %J point
    J_loc(i) = right(i);
    J_value(i) = c(J_loc(i));
    
    %QRS duration
    tqrs(i) = (right(i)-left(i))/Fs;
    
    if i ~= 1
        %RR interval
        RR(i-1) = R_loc(i)-R_loc(i-1);
        trr(i-1) = RR(i-1)/Fs;
        
        %BPM (vent rate)
        BPM(i-1) = Fs*60/trr(i-1);

        %T peak
        [T_value(i-1) T_loc(i-1)] = max(c(floor(R_loc(i-1)+(0.15*RR(i-1))):floor(R_loc(i-1)+(0.55*RR(i-1)))));
        T_loc(i-1) = T_loc(i-1)+ R_loc(i-1) + floor(0.15*RR(i-1)); % add offset

        %P peak
        [P_value(i-1) P_loc(i-1)] = max(c(floor(left(i) - 0.1*RR(i-1)):Q_loc(i)));
        P_loc(i-1) = P_loc(i-1) + floor(left(i) - 0.1*RR(i-1)); % add offset
        
        %PR interval
        PR(i-1) = R_loc(i) - P_loc(i-1);
        tpr(i-1) = PR(i-1)/Fs;
        
        %QT interval
        QT(i-1) = (T_loc(i-1)+(trr(i-1)*0.13)-(Q_loc(i-1)-0.005*Fs));
        tqt(i-1) = QT(i-1)/Fs;
        tqt(i-1) = tqt(i-1)/(Fs*sqrt(trr(i-1)));
    end   
end

%% =============================== Entropy ================================
windowl = 60*fs;
entropy = [];
% for i = 1: windowl : length(c) - windowl
%     curr_entropy = nonlinearHRV(c)
%     entropy = [entropy;curr_entropy.sampen];
% end
 plot(t(1:length(c)),c)
 hold on
 plot(t(R_loc), R_value, '^r',t(P_loc), P_value, 'o')