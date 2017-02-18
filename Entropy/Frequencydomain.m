function [ lfhf]= Frequencydomain (PSD, F, VLF, LF, HF)
% Find the indexes correponding to the VLF, LF and HF bands
iVLF= (F>=VLF(1)) & (F<=VLF(2));
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
end