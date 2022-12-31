function ppLabeler(v24,station, filename, starttime, rootdir) 
% Function will let you assign labels to detected calls 
% and save labeled scalograms in subfolders 'perch', 'other', noisy' 
% 
% ppLabel(v24, station, filename, starttime, rootdirectory) 
%
% INPUTS
%   v24 = 24kHz sampled waveform; pressure corrected, unfiltered 
%           (e.g., 2 min record) 
%   station = e.g.,'C2'
%   fname = file name, e.g., '1074286637.190619031500.wav' used in file name
%   starttime = start time of vector, e.g., [yyyy,mm,dd,hh,MM,ss] 
%   rootdir = where to store the labeled folders 
%
% HOW TO USE 
%   y=audioread('1074286637.190619040000.wav');
%   y=resample(y,1,2);  % assume original 48kHz 
%   gain = 169; % typical for ST instrument 
%   y=(y-mean(y))*(10^(gain/20));  % for soundtrap instrument
%   ppLabeler(y,'S1','1074286637.190619040000.wav',[2019,06,19,04,00,00],'/Volumes/G6/d_CultchTimeSeries/PP')
%
% To generate detection for review, the function calls
% >> ppKSpicker(v24f,2,10), where v24f is a 2000-35000 Hz bandpass 
%    dKthres= 2 and SNRthres - 10 dB. 
%
%
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 24 Aug 22 


close all
fs=24000; 

%% plot the data 
  np2=12; W=2^np2; 
  lL=2000; uL=3500; % filters 
      v24f=bandpass_del(v24,lL,uL,fs,4); 

     [~,F,T,Pxx]=spectrogram(v24,W,floor(W*.85),2^np2,fs); 
     PxxMod=10*log10(Pxx); 
     t=(0:1:length(v24)-1)*(1/fs);

     figure(1); AX(1)=subplot(2,1,1); 
     imagesc(T,F,PxxMod); colormap('jet'); caxis([35,85])
     title([station ' start: ' datestr(starttime) ])
     ylabel('Hz');
     axis xy 

     AX(2)=subplot(2,1,2);
     plot(t,v24f); 
     title(['Plot of BP : ' num2str(lL) ' - ' num2str(uL) ' Hz']); xlabel('seconds'); ylabel('uPa'); 
     linkaxes(AX,'x')
     xlim([0,10])

 %% run the detector 
  [events] = ppKSpicker(v24f,2,10); 

  events(events+0.03*fs >= length(v24))=length(v24)-0.03*fs;  % make sure window does go past end of the file 

  etimes = events/fs; 
  fprintf('The number of picks found in this file is %1.0f\n', length(events)) 
 
 input('return to move forward') 

%% for each detection 
for i=1:size(events,1)

   % reset the main window 
     figure(1); xlim([etimes(i,1)-0.25,etimes(i,1)+0.25 ])
     hold on; subplot(2,1,2);  xline(etimes(i),'-r','LineWidth',2);
     
   % get the data in a 30 ms winow and generate scalogram 
     winstart=events(i)-0.003*fs;  % grab starting 3 ms before pick
     ydet=v24(winstart:winstart+0.030*fs); 
     ydetf=v24f(winstart:winstart+0.030*fs); 
     subplot(2,1,2); ylim([-max(abs(ydetf)),max(abs(ydetf)) ])
     im=ppMakescalo(ydet); 
     figure(2); imshow(im)

CLS=input('classify the call: p = Perch; o = Not Perch; n = Noisy Perch; return = Skip this one:   ','s');


basename=[station,'_',filename, sprintf('%011.7f',etimes(i)) ];
basename=strrep(basename,'.wav','_');


clear imgLoc 
switch CLS

    case 'p' 
    disp('perch')
    imgLoc=fullfile(rootdir,'perch'); 
    imFileName=['p_', basename,'.jpg'];

    if ~exist(imgLoc, 'dir'); mkdir(imgLoc); end
    imwrite(im,fullfile(imgLoc,imFileName));


     case 'o' 
     disp('other')
     imgLoc=fullfile(rootdir,'other'); 
     imFileName=['o_', basename,'.jpg'];

    if ~exist(imgLoc, 'dir'); mkdir(imgLoc); end
    imwrite(im,fullfile(imgLoc,imFileName));


    case 'n' 
     disp('noisy perch')
     imgLoc=fullfile(rootdir,'noisy'); 
     imFileName=['n_', basename,'.jpg'];

    if ~exist('imgLoc', 'dir'); mkdir(imgLoc); end
    imwrite(im,fullfile(imgLoc,imFileName));

    otherwise 
end  % end switch 

end

   
 end