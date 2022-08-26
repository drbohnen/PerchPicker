
function [predictedLabels, etimes]=ppDeepPerchDetector(v24,station,fileID,rootdir,classifier,deleteflag) 
%
% 
% input is a waveform sampled at 24kHz unfiltered  
%
%

%% filtered version of data for detection 
fs=24000; 
lL=2000; uL=3500; % filters 
v24f=bandpass(v24,[lL, uL],fs,'Steepness',0.95); 

%% run KS picker on filtered waveform
[events] = ppKSpicker(v24f,2,10); 
etimes = events/fs; 

% if any picks are within 30 ms of end, adjust them 
 events(events+0.03*fs >= length(v24))=length(v24)-0.03*fs; 

out_directory=fullfile(rootdir,[station,'_',strrep(fileID,'.','_')]) 
 if ~exist(out_directory, 'dir'); mkdir(out_directory); end

size(events)
for i=1:size(events)   % write out scalograms 
     winstart=events(i)-0.003*fs ; % grab starting 3 ms before pick
     if winstart < 1; winstart = 1; end 
     ydet=v24(winstart:winstart+0.030*fs);
     im=ppMakescalo(ydet); 


basename=strcat(station,'_',fileID, sprintf('%011.7f',etimes(i)));
basename=strrep(basename,'.wav','_');
imFileName=strcat('t_', basename,'.jpg'); 
imwrite(im,fullfile(char(out_directory),char(imFileName)));

filelist{i}=fullfile(char(out_directory),char(imFileName)); 
end

%% get activations for each image in the out_directory  
   scalos2eval = imageDatastore(out_directory); 
  net = resnet50();     % Load pretrained network
 featureLayer = 'fc1000'; % define layer for feature extraction 
  ResNet50activations = activations(net,scalos2eval, featureLayer, ...
     'MiniBatchSize', 32, 'OutputAs', 'columns');

%% predict labels using classifier and activations 

 predictedLabels = predict(classifier, ResNet50activations, 'ObservationsIn', 'columns');


%% move the images to appropriate homes 
out_directoryP=fullfile(out_directory,'perch'); 
out_directoryO=fullfile(out_directory,'other'); 


 pp=find(predictedLabels=='perch'); 
 oo=find(predictedLabels=='other'); 
 length(pp) 
 max(pp)

 length(oo) 
 max(oo)


 mkdir(out_directoryP) 
 for i=1:length(pp)
    movefile(char(filelist(pp(i))),out_directoryP)
end



 mkdir(out_directoryO) 
 for j=1:length(oo)
    movefile(char(filelist(oo(j))),out_directoryO)
end

%% delete scalogram images if requested 

switch deleteflag 
case 'all' 
rmdir(out_directory,'s')
disp('deleteing all scalograms')
case 'perch'
rmdir(out_directoryP,'s')
disp('deleteing perch scalograms')
case 'other' 
rmdir(out_directoryO,'s')
disp('deleteing other scalograms')

otherwise 
end


end

