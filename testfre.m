%% this algorithm found not enough peak


clear all;
close all;
load('QuangHuy_140416.mat');
d=data13_ECG';
t=[0:length(d)-1]/200;

  [a b]=butter(2,[0.67 40]/80);               
  e = filtfilt(a,b,d);
  e = e / max(abs(e));
  e = e - mean(e);
  
  c = diff(e);
  
  plot(e)

