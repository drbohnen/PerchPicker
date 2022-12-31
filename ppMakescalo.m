function im=ppMakescalo(v24)
%
% Function takes a vector of acoustic data 30 ms long sampled at 24 kHz 
% and returns a scalogram image of the data resample to 224 x 224 x 3 
% suitable for RESNET50. 
% 
% Parameters are hardwaired for PerchPicker 
%   voices per octave = 16 
%   time band width = 120 
%   frequency limits Hz for scalogram = [1000, 12000]
%
% EXAMPLE: 
% im=ppMakescalo(v24)
%
% INPUT im=ppMakescalo(v24)
% v24 is a acoustic data segment sampled at 24 kHz. If longer than 
% 30 ms (720 points @ 24 kHz) it will be trimmed 
%
% OUTPUT 
% im is a 224 x 224 x 3 image matrix 
%
%
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 24 Aug 22 


%% initial set up 
fs=24000;              % sample rate 
data=v24(1:0.030*fs);  % trim the data to 30 ms 
[m,n] = size(v24);     % get length of data 

if m > n
data=data';  % transform to make a row vector 
end
L=length(data); 

%% scalogram parameters 
VPO = 16;  % voices per octave 
TBW = 120; % time band width 
FL = [1000 12000]; % frequency limits Hz for scalogram 

%% make filter bank 
fb = cwtfilterbank('SignalLength',L,'SamplingFrequency',fs,'VoicesPerOctave',VPO,'timeBandWidth',TBW,'FrequencyLimits',FL);

%% continuous wavelet transform 
    [WT,F] = cwt(data,FilterBank=fb); 
    cfs = abs(WT); 

%% image prep and return     
    a=F>2000 & F <3500;                   % band used to threshold the data
    cut=cfs(a,1:floor(length(cfs)*2/3));  % base thresold on amplitude in first 2/3 of window 
    im = ind2rgb(im2uint8(rescale(cfs,0,1,'InputMin',quantile(cut(:),0.01),'InputMax',quantile(cut(:),0.985))),parula);
    im=imresize(im,[224 224]);

end




