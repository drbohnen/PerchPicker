function k=fastkurt(v,win)
%
% Function computes kurtosis of time series in window of points
%
% USEAGE 
%  k=fastkurt(v,win)
%  k=fastkurt(waveformdata,240)
%
% INPUT
%  v ia an input waveform; pressure corrected. 
% 'win' number of sample in the sliding window   
% 
% OUTPUT 
% k is timeseries of kurtosis 
%
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 24 Aug 22 

%% check number of inputs and set some defaults 
switch nargin
    case 1
       win = 240; 
         disp('setting window length to 240 points') 
    otherwise
end


if win==1 
    win=2; disp('setting window length = 2, cannot be 1')
end


%% check if input is a colum vector, else transpose 
m=size(v,1);  
if m==1; v=v'; end 


%% fast moving window kurtosis calculation 
% from Ballard et al. 2013, Bull. Seis. Soc. Am.  
m_2=filter(ones(win,1)/win,1,v.^2);
m_4=filter(ones(win,1)/win,1,v.^4);

k=m_4./(m_2.^2);

end

