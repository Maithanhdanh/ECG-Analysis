function ker = bandpasskernel(order, lowfreq, highfreq)
%% this function creates a coefficient array of bandpass filter

ker = zeros(1, order + 1);
% neworder = order + 1;
window = blackmanwindow(order + 1);

%% create a band reject filter using the highpass and lowpass frequency
lowpass = lowpasskernel(order, lowfreq, window);

%% create a highpass for high frequency by inverting a lowpass filter 
highpass = lowpasskernel(order, highfreq, window);
for i = 1:length(highpass)
    highpass(i) = -highpass(i);
end
   highpass(length(highpass)/2) =  highpass(length(highpass)/2) + 1;
   
%% combine lowpass and highpass to create bandpass filter
for i= 1:length(ker)
    ker(i) = -(lowpass(i) + highpass(i));
end
ker(length(ker)/2) = ker(length(ker)/2) + 1;

end