for i=1:7
[ecg, IndexStr, H]=ptbopenfile(i);
x=ecg(:,1);
SNR=snr(x);
%Wn: 0:1 the cutoff frequency, with 1 corresponding to half the sample
%rate. If WWn is a two element vector, butter returns an order 2N bandpass
%filter with passband W1<W<W2
figure (10)
plot (x)
title ('Noisy signal')
xlabel ('Samples')
ylabel ('Amplitude')
% Plot magnitude spectrum of the signal
X_mags=abs(fft(x))
figure (1)
plot (X_mags)
xlabel ('DFT')
ylabel('Magnitude')
% Plot first half of DFT (normalised frequency)
num=length (X_mags);
plot([0:1/(num/2-1):1], X_mags(1:num/2))
xlabel('Normalised frequency (\pi rads/sample)')
ylabel ('Magnitude')
% Design a second order filter using a butterworth design technique
[b,a]=butter(2,0.3,'low')
%plot the freqency respone (normalised frequency
H=freqz(b,a,floor(num/2));
hold on
plot ([0:1/(num/2-1):1],abs(H),'r')
% Filter the signal using the b and a coefficients obtained from the butter
% filter design function
x_filtered=filter(b,a,x);
% Plot the fitered signal
figure (2)
plot (x_filtered,'r')
title('Filtered Signal-Using Second Order Butterworth')
xlabel ('Samples');
ylabel('Amplitude')
% Redesign the filter using a higher order filter
[b2, a2]=butter (20, 0.3, 'low')
% Plot the magnitude spectrum and compare with lower order filter
H2=freqz(b2, a2, floor(num/2))'
figure (1)
hold on
plot([0:1/(num/2-1):1], abs(H2),'g');
% Filter the noisy signal anf plot the result
x_filtered2=filter(b2,a2,x)
figure (3)
plot(x_filtered2,'g')
title('Filtered Signal-Using 20th Order Butterworth')
xlabel('Samples')
ylabel('Amplitude')
% Frequency Domain for HRV analysis
[PSD F]=pwelch(x_filtered2,hamming(128),[50],1000);
VLF=[0.0033 0.04];
LF=[0.04 0.15];
HF=[0.15 0.4];
% Find the indexes correponding to the VLF, LF and HF bands
iVLF= (F>=VLF(1)) & (F<=VLF(2));
figure(7)
plot(iVLF)
iLF = (F>=LF(1)) & (F<=LF(2));
iHF = (F>=HF(1)) & (F<=HF(2));
% Caculate areas, within the freq band (ms^2)
aVLF=trapz(F(iVLF),PSD(iVLF));

aLF=trapz(F(iLF),PSD(iLF));

aHF=trapz(F(iHF),PSD(iHF));

aTotal=aVLF+aLF+aHF;

% Caculate areas relative to the total area (%)
% pVLF=(aVLF/aTotal)*100;
% pLF=(aLF/aTotal)*100;
% pHF=(aHF/aTotal)*100;
% Caculate LF/HF ratio

lfhf =aLF/aHF;

%plot area under PSD curve
area(F(:),PSD(:),'FaceColor',[.6 .6 .6]);        
grid on;
% DFA
data=x_filtered2;
output = DFA (data,4,300,13)
end 



