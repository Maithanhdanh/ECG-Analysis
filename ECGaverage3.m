clear all;
close all;
load('QuangHuy_140416_ECG.mat');
d=data21(1:end)';
t=[0:length(d)-1]/200;

%% filter baseline%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a b]=butter(7,[0.5 40]/100);
c = filtfilt(a,b,d);
c=c/max(abs(c));
c=c-mean(c);
%subplot(3,1,1)
%plot(c)
%title('filter baseline');

%% bandpass filter form 8 to 20 Hz%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[b a]=butter(3,[8 20]/100);
bp=filter(b,a,c);
bp=bp/max(abs(bp));
bp=bp-mean(bp);
%subplot(3,1,2)
%plot(c);
%title('bandpass filter');
        
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
    [R_value(i) R_loc(i)] = max( c(left(i):right(i)) );
    R_loc(i) = R_loc(i)-1+left(i); % add offset

    [Q_value(i) Q_loc(i)] = min( c(left(i):R_loc(i)) );
    Q_loc(i) = Q_loc(i)-1+left(i); % add offset

    [S_value(i) S_loc(i)] = min( c(left(i):right(i)) );
    S_loc(i) = S_loc(i)-1+left(i); % add offset

end
    
%% there is no selective wave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q_loc=Q_loc(find(Q_loc~=0));
R_loc=R_loc(find(R_loc~=0));
S_loc=S_loc(find(S_loc~=0));

%% Heart Rate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hr=[];
for i=1:length(R_loc)-1
    hr=[hr 60*sr*2/(R_loc(i+1)-R_loc(i))];
end

%subplot(3,1,3)
%plot(hr)
%title('Heart Rate');
    
figure
plot (t(1:length(c)),c);
hold on;
plot(t(R_loc) ,R_value , 'r^', t(S_loc) ,S_value, 'g',t(Q_loc) , Q_value, 'o');

