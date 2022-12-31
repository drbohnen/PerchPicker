
function [predictedLabels,predictedScores, etimes, Pcount, Ocount]=ppDeepPerchDetector(v24,station,fileID,rootdir,classifier,deleteflag,fstartdatetime) 
% This is the main function called for PerchPicker 
% 
% USE: 
% [predictedLabels,predictedScores, etimes, Pcount, Ocount]=...
% ppDeepPerchDetector(v24,station,fileID,rootdir,classifier,deleteflag) 
%
% INPUT 
% v24 =      waveform sampled at 24kHz unfiltered  
% station =  character string with name of station or site e.g., 'CB' 
% fileID  =  character string with ID for recording. e.g., If feeding 2-min 
%            files use the file name from which the data were extracted 
% rootdir =  output directrories perch and other live here (for classified 
%            scalogram images) 
% classifier =  the name of the classification object 
% deleteflag = 'perch', 'other', 'all', 'none'-specify what scalograms NOT 
%               to keep for review  
% fstartdatetime = datetime object with start time of recording.  Used to 
%                  assign absolute time information to the detector.   
% 
% OUTPUT 
% predictedLabels =  labels returned for each detection considered 
% predictedScores =  scores + for perch
% etimes  =  event times in seconds since beginning of file 
% Pcount  =  total number of Perch Detections in waveform 
% Ocount  =  total number of Other Detections in waveform 
% 
% written files include /perch and /other directories in rootdir where 
% scalogram are stored, along with a Otable.mat and Ptable.mat 
% Note that if no perch sounds are classified Ptable.mat is not written. 
%
%
% D.R.Bohnenstiehl 
% NCSU 
% PerchPicker 
% v1. 8 Sept. 2022 

%% filtered version of data for detection 
fs=24000; 
lL=2000; uL=3500; % filters 
v24f=bandpass_del(v24,2000,3500,fs,4); 


%% run KS picker on filtered waveform
[potevents] = ppKSpicker(v24f,2,10); 
etimes = potevents/fs; 


%% if any picks are within 30 ms of end, adjust them 
 potevents(potevents+0.03*fs >= length(v24))=length(v24)-0.03*fs; 

 %% make a datetime object with absolute time  
 etimes2=fstartdatetime+seconds(etimes); 
 etimes2.Format='yyyy-MM-dd HH:mm:ss.SSSSSS'; 

 %% make directories to hold the image files and outputs 
out_directory=fullfile(rootdir,[station,'_',strrep(fileID,'.','_')]); 
 if ~exist(out_directory, 'dir'); mkdir(out_directory); end
out_directoryP=fullfile(out_directory,'perch');  mkdir(out_directoryP) 
out_directoryO=fullfile(out_directory,'other');  mkdir(out_directoryO) 

disp('writing images'); tic

if ~isempty(etimes)
%% write out image scalogram files 
parfor i=1:size(potevents,1)   % write out scalograms 
     winstart=potevents(i)-0.003*fs ; % grab starting 3 ms before pick
     if winstart < 1; winstart = 1; end 
     ydet=v24(winstart:winstart+0.030*fs);
     im=ppMakescalo(ydet); 

basename=strcat(station,'_',fileID, sprintf('%011.7f',etimes(i)));
basename=strrep(basename,'.wav','_');
imFileName=strcat('t_', basename,'.jpg'); 
imwrite(im,fullfile(out_directoryO,char(imFileName)));
filelist{i}=fullfile(char(out_directoryO),char(imFileName));  % write all to the other directory first 
end

toc 

disp('deep learning'); tic

%% get activations for each image in the out_directory  
scalos2eval = imageDatastore(out_directoryO); 
  net = resnet50();     % Load pretrained network
  featureLayer = 'fc1000'; % define layer for feature extraction 
  ResNet50activations = activations(net,scalos2eval, featureLayer, ...
     'MiniBatchSize', 128, 'OutputAs', 'columns');

%% predict labels using classifier and activations 
   [predictedLabels, predictedScores] = predict(classifier, ResNet50activations, 'ObservationsIn', 'columns');
toc 

%% get indices for each class 
 pp=find(predictedLabels=='perch'); Pcount=length(pp); 
 oo=find(predictedLabels=='other'); Ocount=length(oo); 

%% write tables with detections 
 ptablename=['Ptable_',station,'_',strrep(fileID,'.','_')]; 
 otablename=['Otable_',station,'_',strrep(fileID,'.','_')]; 

 if ~isempty(pp)
 eval([ptablename '=table(repmat({station},length(pp),1),predictedLabels(pp),predictedScores(pp,2),etimes(pp),etimes2(pp),repmat({fileID},length(pp),1), ''VariableNames'',{''Site'',''CallID'',''score'',''rel_time'',''abs_time'',''FileID''});']); 
 eval(['save ' fullfile(out_directory, 'Ptable.mat') ' ' ptablename]) 
 end
  if ~isempty(oo)
 eval([otablename '=table(repmat({station},length(oo),1),predictedLabels(oo),predictedScores(oo,2),etimes(oo),etimes2(oo),repmat({fileID},length(oo),1), ''VariableNames'',{''Site'',''CallID'',''score'',''rel_time'',''abs_time'',''FileID''});']); 
 eval(['save ' fullfile(out_directory, 'Otable.mat') ' ' otablename]) 
  end


%% move the perch files to the perch directory 
 parfor i=1:length(pp)
    movefile(char(filelist(pp(i))),out_directoryP)
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
else 
predictedLabels='none';
predictedScores=nan; 
etimes=nan; Pcount=nan;  Ocount=nan; 

end


end

