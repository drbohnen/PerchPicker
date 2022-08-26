function ppLabeler_NCSUcultch(station, starttime, rootdir) 
% 
% Special version of ppLabeler for use with NCSU cultch reef data
% This version uses the 
% 
%
% Function will let you assign labels to detected calls 
% and save labeled scalograms in subfolders 'perch', 'other', noisy' 
% 
% ppLabel(v24, station, filename, starttime, rootdirectory) 
%
% INPUTS
%   station = e.g.,   'BB'
%   starttime = start time of vector, e.g., [yyyy,mm,dd,hh,MM,ss] 
%   rootdir = output directory where to store the labeled folders 
%
% HOW TO USE 
%
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 24 Aug 22 


[v,delay_rel_rq,start_time,file]=get_PSwaveform_utc(station, starttime, 0);
v24=resample(v,1,4); 

close all
fs=24000; 

%% plot the data 
  np2=12; W=2^np2; 
  lL=2000; uL=3500; % filters 

   v24f=bandpass(v24,[lL, uL],fs,'Steepness',0.95); 

     [~,F,T,Pxx]=spectrogram(v24,W,floor(W*.95),2^np2,fs); 
     PxxMod=10*log10(Pxx); 
     t=(0:1:length(v24)-1)*(1/fs);

     figure(1); AX(1)=subplot(2,1,1); 
     imagesc(T,F,PxxMod); colormap('jet'); caxis([35,85])
     title([station ' start: ' datestr(starttime) ])
     ylabel('Hz');
     axis xy 
     ylim([0,7000])

     AX(2)=subplot(2,1,2);
     %plot(t,bandpass(v24,[2000,3500],fs,'Steepness',0.95)); 
    
     plot(t,v24f)
     title(['Plot of BP : ' num2str(lL) ' - ' num2str(uL) ' Hz']); xlabel('seconds'); ylabel('uPa'); 
     linkaxes(AX,'x')
     %xlim([0,10])

 %% run the detector 
  [events] = ppKSpicker(v24f,2,10); 
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
     if winstart < 1; winstart = 1; end 
     if winstart+0.003*fs >= length(v24); winstart=length(v24)-0.003*fs; end 
     ydet=v24(winstart:winstart+0.030*fs); 
     ydetf=v24f(winstart:winstart+0.030*fs); 
     subplot(2,1,2); ylim([-max(abs(ydetf)),max(abs(ydetf)) ])
     im=ppMakescalo(ydet); 
     figure(2); imshow(im)

CLS=input('classify the call: p = Perch; o = Not Perch; n = Noisy Perch; return = Skip this one:   ','s');


basename=[station,'_',char(file), sprintf('%011.7f',etimes(i)) ];
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

    if ~exist(imgLoc, 'dir'); mkdir(imgLoc); end
    imwrite(im,fullfile(imgLoc,imFileName));

    otherwise 
end  % end switch 

end

   
 end