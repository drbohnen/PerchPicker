function [dpkts, dt, dSNR, dDK,K,DK,SNR] = ppKSpicker(v24,DKcut,SNRcut)
% 
% Function ppKSpicker returns call detection using kurtosis and SNR
% 
% dpkts = ppKSpicker(v24,DKcut,SNRcut)
% dpkts = ppKSpicker(waveformdata,2,15)
% 
% INPUT
%  v24 ia an input waveform sampled at 24kHz; pressure corrected. 
%  For perch picker this would be filter 2000-3500 
%
%  DKcut is threshold for dervative of kurtosis (default = 2) 
%
%  SNRcut is the threshold for SNR in decibles (default = 15) 
%
% OUTPUT 
% dpkts = detection in points 
% dt = detection in seconds (time),i.e, dpkts/24000;  
% dSNR = snr associated with detection in decibles
% dDK = devirvative of kurtosis associated with detection 
% K, DK, SNR are time series of kurtosis, derivative of kurtosis and snr. 
%
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 24 Aug 22 


switch nargin
    case 2
        SNRcut=15; 
         disp('appying default SNR Cutoff of 15 dB') 
    case 1
       SNRcut=15; 
       DKcut=2; 
        disp('appying default SNR cutoff of 15 dB') 
         disp('appying default derivative kurtosis cutoff of 15 dB') 
    otherwise
end


%% kurtosis and its derivative 
    K=fastkurt(v24,240); % call fast kurtosis function 
                         % use 240 point (10 ms windows) 

    % kutosis is fairly smooth function 
    % option to filter generally? not necessary 
    % flen = 3 % filter length 
    % K=filter(ones(flen,1)/flen,1,K); 

    DK=diff(K); % find derivative of K 
    DK(DK<0)=0; % and set values <0 to 0. 
    DK=[DK; 0]; % add a zero to end to preserve length

%% find peaks in derivative of kurtosis 
    % minimum peak height =2; min peak distance = 240 points 10 ms. 
    [dDK,dpkts]=findpeaks(DK,'MinPeakHeight',DKcut,'MinPeakDistance',240); 
    dpkts=max(1,dpkts-48); % move detection times back 48 points from peak  


% calculate SNR in 240 point (10 ms windows) 
SNR=fastsnr(v24,240,240); 

%% filter results for SNR 
    dpkts(SNR(dpkts) <= SNRcut)=[]; 

%% report out parameters  
    dt=dpkts/24000; 
    dSNR=SNR(dpkts); 
end


