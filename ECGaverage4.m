close all;
clear all;
load('QuangHuy_140416_ECG.mat');
d=data11(1:end)';
t=[0:length(d)-1]/200;


%% filter baseline%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a b]=butter(7,[0.5 40]/100);
c = filtfilt(a,b,d);
c=c/max(abs(c));
c=c-mean(c);

subplot(2,2,1)
plot(c)
title('filter baseline');

%% bandpass filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%LPF
b=[1 0 0 0 0 0 -2 0 0 0 0 0 1];
a=[1 -2 1];
h_LP=filter(b,a,[1 zeros(1,12)]);

x2 = conv (c ,h_LP);
x2 = x2 (6+[1: length(d)]); %cancle delay
x2 = x2/ max( abs(x2 ));
subplot(2,2,2)
plot(x2)
title('lowpass filter');

%HPF
b = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
a = [1 -1];

h_HP=filter(b,a,[1 zeros(1,32)]); % impulse response of HPF
 
x3 = conv (x2 ,h_HP);
x3 = x3 (16+[1: length(d)]); %cancle delay
x3 = x3/ max( abs(x3 ));

subplot(2,2,3)
plot(x3)
title('highpass filter');
        
%% Make impulse response %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = [-1 -2 0 2 1]/8;

% Apply filter
x4 = conv (x3 ,h);
x4 = x4 (2+[1: length(d)]);
x4 = x4/ max( abs(x4 ));

%% Squaring %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x5 = x4 .^2;
x5 = x5/ max( abs(x5 ));

%% Make impulse response %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = ones (1 ,31)/31;

% Apply filter
x6 = conv (x5 ,h);
x6 = x6 (15+[1: length(d)]);
x6 = x6/ max( abs(x6 ));

max_h = max(x6);
thresh = mean (x6 );
poss_reg =(x6>thresh*max_h);

left = find(diff([0 poss_reg])==1);
right = find(diff([poss_reg 0])==-1);
meanc=mean(c);
for i=1:length(left)
    %detect R peak
    [R_value(i) R_loc(i)] = max( c(left(i):right(i)) );
    R_loc(i) = R_loc(i)-1+left(i); 
    
    %detectQ peak
    [Q_value(i) Q_loc(i)] = min( c(left(i):R_loc(i)) );
    Q_loc(i) = Q_loc(i)-1+left(i); 

    %detect S peak
    [S_value(i) S_loc(i)] = min( c(left(i):right(i)) );
    S_loc(i) = S_loc(i)-1+left(i); 
    
    %detec T peak
    a=R_loc(i)+25:R_loc(i)+100;     
    m=max(c(a));
    b=find(c(a)==m);
    
    b=b(1);
    b=a(b);

    T_loc(i)=b;
    T_value(i)=m;
    
    %detect J point
    ST_segment=[S_loc(i):T_loc(i)];
    J_loc(i)=find(x6(ST_segment)==mean(x6(ST_segment)));
    J_value(i)=c(J_loc(i));
    
   end
    
%% there is no selective wave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q_loc=Q_loc(find(Q_loc~=0));
R_loc=R_loc(find(R_loc~=0));
S_loc=S_loc(find(S_loc~=0));


%for(j=1:length(R_loc))
%    a=R_loc(j)+25:R_loc(j)+100;
%    m=max(c(a));
%    b=find(c(a)==m);
%    
%    b=b(1);
%    b=a(b);
%
%    T_loc(j)=b;
%    T_value(j)=m;
%end

%% detect J point

%for i=1:length(T_loc)
%    for j=1:length(T_loc)
%        ST_segment(i,j)=[S_loc(j):T_loc(j)];
%    end
%end
%    J_loc=find(c(ST_segment)==mean(c));
    


hr=[];
for i=1:length(R_loc)-1
    hr=[hr R_loc(i+1)-R_loc(i)];
end

subplot(2,2,4)
plot(hr)
title('Heart Rate');
    
figure
plot (t(1:length(c)),c);
hold on;
plot(t(S_loc) ,S_value, 'r^', t(T_loc),T_value, 'o');



