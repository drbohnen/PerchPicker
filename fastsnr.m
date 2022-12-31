function snr=fastsnr(v,win_before,win_after)
% Returns estimated signal to noise ratio (snr) 
% calcuated on the squared amplitude of v 
% 
% INPUT 
% v = is the input vector of acoustic pressure. 
% win_before = window length in points before 
% win_after  = window length in points after 
%    
% OUTPUT 
% snr = vector of signal to noise ratio 
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 24 Aug 22 


%% check if input is a colum vector, else transpose 
m=size(v,1); n=size(v,2);   
if m==1; v=v'; m=size(v,1); n=size(v,2); end 

%% check number of inputs and set some defaults 
switch nargin
    case 2
         win_after=win_before;  
         disp(['setting after win length same as before : ' num2str(win_after)]) 
    case 1
       win_before = 240; win_after=240; 
         disp('setting both window lengths to 240 points') 
    otherwise
end

%% calculate power 
v=v.^2; % square the amplitude data 

%% moving average of power 
B=filter(ones(1,win_before)/win_before,1,v);   % Ab = B
A=filter(ones(1,win_after)/win_after,1,v);     % Aa = A 

%% Shift times correctly 
A2=[A(win_after:end,:) ; zeros(win_after-1,n)];  
snr=A2./B;                            % snr 
snr = 20*log10(max(snr,1));           % values less than 1 set to 0 dB
snr(1:win_before,:)=0;                % pad the beginning 

end

