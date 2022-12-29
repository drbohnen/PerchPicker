# PerchPicker
MATLAB software to identify silver perch calls in passive acoustic data using deep learning. 

To use the detector: 
1) sample (or 
2) 
3) 


[predictedLabels, etimes]=ppDeepPerchDetector(v24,station,fileID,rootdir,classifier,deleteflag) 
INPUT 
v24 = is a waveform sampled at 24kHz unfiltered  
station = character string with name of station or site e.g., 'CB' 
fileID = character string with ID for recording.  If feeding in 2 min files you might use the file name from which the data were extracted 
rootdir = output directrories 'perch' and 'other' live here (for classified scalogram images) 
classifier = the name of the classification object 
deleteflag = 'perch', 'other', 'all', 'none'-specify what scalograms NOT to keep for review  
fstartdatetime = datetime object with start time of recording.  Used to assign absolute time information to the detector.   

% OUTPUT 
predictedLabels = labels returned for each detection considered 
predictedScores = scores + for perch, - for other 
etimes = event times in seconds since beginning of file 
%
% Pcount = total number of Perch Detections in waveform 
%
% Ocount = total number of Other Detections in waveform 
% 
% written files include /perch and /other directories in rootdir where 
% scalogram are stored, along with a Otable.mat and Ptable.mat 
% Note that if no perch sounds are classified Ptable.mat is not written. 
%
%
% D.R.Bohnenstiehl 
% NCSU 
% v1. 8 Sept. 2022 
