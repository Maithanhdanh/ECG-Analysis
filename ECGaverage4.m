close all;
clear all;
load('QuangHuy_140416_ECG.mat');
d=data11';
t=[0:length(d)-1]/200;

%% filter baseline%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a b]=butter(7,[0.5 40]/100);
c = filtfilt(a,b,d);
c=c/max(abs(c));
c=c-mean(c);

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
baseline=thresh*max_h;
poss_reg =(x6>baseline);

left = find(diff([0 poss_reg])==1);
right = find(diff([poss_reg 0])==-1);

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
    
    %detect T peak
    if i>1
        [T_value(i-1) T_loc(i-1)] = max(c(S_loc(i-1):Q_loc(i)));
        T_loc(i-1)=T_loc(i-1)+19+left(i-1);
    end 
    
    %detect J point
    J_loc(i)=right(i);          %J point is the end of QRS offset
    J_value(i)=c(J_loc(i));
end
    
%% there is no selective wave %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Q_loc=Q_loc(find(Q_loc~=0));
R_loc=R_loc(find(R_loc~=0));
S_loc=S_loc(find(S_loc~=0));

%% plot figure
figure
plot (t(1:length(c)),c);
hold on;
plot(t(T_loc),T_value, 'o',t(J_loc),J_value, 'r^');

%% clear some veriable
clear -regexp data x
clear a b baseline d h h_HP h_LP max_h t thresh 

