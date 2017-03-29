function [diagnosis] = detectmi(data,fs)
% Input
% data: ECG signal
% fs:   sampling frequency
% Output:
% counter1: counte number of peak in window
% counter2: counte number of peak without MI in window
% counter3: counte number of peak with MI in window

ST_segment = [];
PR_segment = [];
% ====== feature extraction ======
[c,R_value, R_loc, Q_value, Q_loc, S_value, S_loc, J_value, J_loc, T_value, T_loc, P_value, P_loc, K_loc, K_value] = ecg_extraction(data,fs);
% ====== PR segments ======
for j = 2:length(K_loc)
    PK_loc = P_loc(j-1) : K_loc(j);
    PK_value = c(P_loc(j-1) : K_loc(j));
    PR_segment(end + 1) = mean(PK_value) /mean(PK_loc)*1000;
end
% ====== ST segments ======
for j = 1:length(T_loc)
    JT_loc = J_loc(j) : T_loc(j);
    JT_value = c(J_loc(j) : T_loc(j));
    ST_segment(end + 1) = mean(JT_value) /mean(JT_loc)*1000;
end
% ====== detect MI ======
counter1 = 0;
counter2 = 0;
counter3 = 0;
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

if counter3/counter1>=0.95
    diagnosis = 'WARNING: MI';
else
    diagnosis = 'No MI';
end 