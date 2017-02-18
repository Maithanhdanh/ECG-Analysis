% ecg_comp V2
% Created: 04-19-2016
% By: Cu Gia Huy
% Feature: Add xcorr on window

close all;
% clear all;
% load('QuangHuy_140416_ECG.mat');
% load('QuangHuy_140416_alice5.mat');
load('QuangHuy_140416.mat');
ws = 200; % 
data_len = 6000;
Fs = 200;
data24_scale = (4.8*data24(1:data_len)/8388608-2.4)/3.5*1000000;
r2_val =[];
SampleDiff_val = [];

[data24_f] = bandpass(data24_scale,Fs);
[A_data24_f] = bandpass(A_data24(1:data_len),Fs);

% Plot
% ax(1) = subplot(2,1,1);plot(data24_f);
% ax(2) = subplot(2,1,2);plot(A_data24_f);
% linkaxes(ax,'x');

% Pan-Tompkins
[qrs_amp_raw,qrs_i_raw]=pan_tompkin(data24_f,Fs,0);
[A_qrs_amp_raw,A_qrs_i_raw]=pan_tompkin(A_data24_f,Fs,0);
close all;

T1 = A_data24_f;
T2 = data24_f;

  
% Cross-Correlation
% -----------------
[C1a,lag1a] = xcorr(T1,T2);
[~,I] = max(abs(C1a((data_len-200):(data_len+200)))); % find maximum correlation
abs(max(C1a));
SampleDiff_main = lag1a(data_len+I); % find delay
timeDiff = SampleDiff_main/Fs;

% figure
% % subplot(4,4,[1,2,5,6]);
% % plot(lag1/Fs,C1/max(abs(C1)),'k');
% area(lag1a,C1a);
% ylabel('Amplitude');
% xlabel('Lag');
% grid on
% title('Cross-correlation between 2 signals');

delay = finddelay(T1,T2);

if (SampleDiff_main ~= 0)
    T1 = T1(abs(SampleDiff_main):end);
end

if (length(T1)>=length(T2))
    T1 = T1(1:length(T2));
else
    T2 = T2(1:length(T1));
end

% [qrs_amp_raw,qrs_i_raw]=pan_tompkin(T2,Fs,0);
% [A_qrs_amp_raw,A_qrs_i_raw]=pan_tompkin(T1,Fs,0);

for i=0:(length(T1)/ws)-1
X1 = T1((i*ws+1):((i+1)*ws));
X2 = T2((i*ws+1):((i+1)*ws));  
% figure
% % subplot(2,1,1)
% plot(T1)
% title('s_1, aligned')
% hold all

% % subplot(2,1,2)
% plot(T2)
% title('s_2')
% xlabel('Time (s)')

% close all;

% Cross-Correlation
% -----------------
[C1,lag1] = xcorr(X1,X2);
[~,I] = max(abs(C1)); % find maximum correlation
abs(max(C1));
SampleDiff = lag1(I); % find delay
timeDiff = SampleDiff/Fs;
SampleDiff_val = [SampleDiff_val; SampleDiff];
delay = finddelay(X1,X2);

if (SampleDiff ~= 0)
    X1 = X1(abs(SampleDiff):end);
end

if (length(X1)>=length(X2))
    X1 = X1(1:length(X2));
else
    X2 = X2(1:length(X1));
end

% if (i == 1)
figure
    ax(1) = subplot(2,1,1);plot(X1);
    ax(2) = subplot(2,1,2);plot(X2);
    linkaxes(ax,'x');
% end

% Comparing frequency

[P1,f1] = periodogram(X1,hamming(length(X1)),length(X1),Fs,'power');
[P2,f2] = periodogram(X2,hamming(length(X2)),length(X2),Fs,'power');

% figure
t1 = (0:numel(X1)-1)/Fs;
t1 = t1';
t2 = (0:numel(X2)-1)/Fs;
t2 = t2';
% sig(1) = subplot(4,4,[1 2]);
% % plot(t1(1:7*Fs),T1(1:7*Fs),'k');
% plot(t1(1:end),T1(1:end));
% axis();
% ylabel('Alice 5(mV)');
% grid on
% title('Time Series')
% sig(2) = subplot(4,4,[5 6]);
% % plot(t2(1:7*Fs),T2(1:7*Fs));
% plot(t2(1:end),T2(1:end));
% ylabel('ECG device(mV)');
% grid on
% xlabel('Time (secs)')
% linkaxes(sig,'xy');
% % axis(sig1,[0 7 -0.5 1.5]);
% % axis(sig2,[0 7 -0.5 1.5]);
% subplot(4,4,[3 4]);
% plot(f1,10*log10(P1),'k');
% ylabel('P1');
% grid on;
% axis tight
% title('Power Spectrum')
% subplot(4,4,[7 8]);
% plot(f2,10*log10(P2));
% ylabel('P2');
% grid on;
% axis tight
% xlabel('Frequency (Hz)')

% Spectral coherence 

[Cxy,f] = mscohere(X1,X2,[],[],[],Fs);
Pxy     = cpsd(X1,X2,[],[],[],Fs);
phase   = -angle(Pxy)/pi*180;
[pks,locs] = findpeaks(Cxy,'MinPeakHeight',0.75);


% subplot(4,4,[9,10,11,12,13,14,15,16]);
% axis([0 100 0 1]);
% plot(f,Cxy);
% title('Frequency Coherence Estimate');
% grid on;
% hgca = gca;
% % hgca.XTick = f(locs);
% % hgca.YTick = .75;
% % axis([0 200 0 1]);
% % subplot(4,4,[13,14,15,16]);
% % plot(f,phase);
% % title('Cross-spectrum Phase (deg)');
% % grid on;
% hgca = gca;
% % hgca.XTick = f(locs);
% % hgca.YTick = round(phase(locs));
% xlabel('Frequency (Hz)');
% % axis([0 200 -180 180]);
% %

%----------- Linear regression -----------------
% X1 = A_data24_f((i*ws+1):((i+1)*ws-1));
% X2 = data24_f((i*ws+1):((i+1)*ws-1));

p= polyfit(X1,X2,1);
f= polyval(p,X1);
%----------- Call R-square function ------------
r2=Rsquare(X2,f);
r2_val = [r2_val; r2];
end

%  Plot signal
% plot(r2_val);
r2_val;
% close all;
mean(r2_val)
% i = 22;
% ax(1) = subplot(2,1,1);plot(T1((i*ws+1):((i+1)*ws-1)));
% ax(2) = subplot(2,1,2);plot(T2((i*ws+1):((i+1)*ws-1)));
% linkaxes(ax,'x');
% close all;