clear;
% close all
%
% This is a wrapper function for the NCSU cultch reef dataset that 
% the ppDeepPerchDector.m function 
% 
load STcalibration.mat          % calibration data 
                                % loads a variable called STcalib 
load PScultch1_dir2process.mat; % directory list for Pamlico Sound Cultch 
                                % loads a variable dir2process 
load perchclassifier_v7.mat     % trained classifier 
                                % loads a classification objected 
                                % named classifier 
% this is where you want the outou 
DirOut='D:\drbohnen\PP\perchdetCB\'; 

%% wrapper works by looping through the deployments in dir2process 

for H=1:8 %:8 %:height(dir2process)   % choose which directories (i.e., site, deployments) 
DirIn= char(dir2process.DirIn(H)); % directory in
[filelist, fstart, fend] = mktableSTdir(char(DirIn)); % list of file in that directory 
a=find(fstart > datenum(dir2process.Sgate(H)) & fstart < datenum(dir2process.Egate(H))); % filter to time range specified 
filelist=filelist(a); fstart=fstart(a); fend=fend(a); % reset based on filtered time range 
site=char(dir2process.Site(H)); dep=dir2process.Deployment(H);  % define variable site and dep 

% The second deployment was 1 minutes recordings 
if dep==2 % for NC Cultch data, dep 2 was only recorded for 60s
    NSEC=60;
else
    NSEC=120;
end


%% Load File and Run perch detector on each file 
maxfiles=length(filelist); % 
Pcount=nan(maxfiles,1); Ocount=nan(maxfiles,1);  % reallocate 
for i=1:maxfiles  
    fprintf('Processing %s\n', char(filelist(i).name));
    [y,fstart_UTC, fs, metadata]=readST(char(filelist(i).name),char(DirIn),NSEC,STcalib);   % DirIn cell, char changes to character for fileread function
    y=resample(y,1,4);  
% run the perch detector 
[~, ~,~,Pcount(i),Ocount(i)]=ppDeepPerchDetector(y,char(dir2process.Site(H)),char(filelist(i).name), DirOut,classifier,'none',datetime(fstart_UTC,'ConvertFrom','datenum','Format','dd-MMM-uuuu HH:mm:ss.SSSSSSSS')); 
end


%% Make a big table wiht the time of all the perch detections 
F=dir(fullfile(DirOut,'*','Ptable*.mat')); 
 clear('Ptable*')

for f=1:length(F)
    if f==1 
    load(fullfile(F(f).folder,F(f).name))
    V=whos('Ptable*'); 
    eval([site '_' sprintf('%02.0f',dep) '_DetTable=' V.name ';']); 
    clear('Ptable*')
    elseif f>1  
    load(fullfile(F(f).folder,F(f).name))
    V=whos('Ptable*'); 
    eval([site '_' sprintf('%02.0f',dep) '_DetTable=[' site '_' sprintf('%02.0f',dep) '_DetTable;' V.name '];']); 
    clear('Ptable*')
    end
end

%% File naming and saving 
filenamesout=char(filelist(1:length(Pcount)).name); 
filetimesout=datetime(fstart(1:length(Pcount)),'ConvertFrom','datenum'); 
eval([site '_' sprintf('%02.0f',dep) '_DetTab=table(Pcount, Ocount, filenamesout, filetimesout,''VariableNames'',{''perch'',''other'',''file'',''time''})'] ); 

out1=fullfile(DirOut,[ site '_' sprintf('%02.0f',dep) '_DetTable.mat']); 
eval(['save ' out1 ' ' site '_' sprintf('%02.0f',dep) '_DetTable']); 
out2=fullfile(DirOut,[ site '_' sprintf('%02.0f',dep) '_DetTab.mat']); 
eval(['save ' out2 ' ' site '_' sprintf('%02.0f',dep) '_DetTab']); 

%
clear Ptable Pcount Ocount F 

end
 

