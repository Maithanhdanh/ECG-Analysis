fs = 250
all_data = [];
windowl = 5*fs;
t = [0:length(data)-1]/fs;
for i = 1:windowl:length(data)-windowl
    data2 = data(i+1:i+windowl);   

    ST_segment = [];
    PR_segment = [];
    ST_deviation =[];

    % ====== feature extraction ======
    [c,R_value, R_loc, Q_value, Q_loc, S_value, S_loc, J_value, J_loc, T_value, T_loc, P_value, P_loc, K_loc, K_value] = ecg_extraction(data2,fs);
    all_data = [all_data c];

%         figure
%         plot(t(1:length(all_data)),all_data)

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


    % ====== ST segments ======
    for j = 1:length(T_loc)
        JT_loc = J_loc(j) : T_loc(j);
        JT_value = c(J_loc(j) : T_loc(j));
        ST_segment(end + 1) = mean(JT_value) /mean(JT_loc)*1000;
    end

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
        pause(2)
    else
        fprintf(1,'\nK>No MI\n');
            pause(0.5)
    end 

    clc
    close all
end 