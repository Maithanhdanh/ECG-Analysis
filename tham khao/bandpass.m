function [data_f,a,b] = bandpass(data,fs) 
f1=0.5; %cuttoff low frequency to get rid of baseline wander
f2=40; %cuttoff frequency to discard high frequency noise
Wn=[f1 f2]*2/fs; % cutt off based on fs
N = 7; % order of 3 less processing
[a,b] = butter(N,Wn); %bandpass filtering
data_f = filtfilt(a,b,data);
fig = figure; 
% set(fig,'Units','normalized','Position', [0,0,1,1]);
set(fig,'WindowStyle','docked');
% plot(data_f);hold on; 
% plot(data);
