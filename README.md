# PerchPicker
MATLAB software to identify silver perch calls in passive acoustic data using deep learning. 

To use the detector: 

install ResNET50 module for MATLAB 

>> [v,fs]=audioread('filename.wav'); % load your audio data 
>> 
>> v=v*cal % apply your calibration 
>> 
>> v24=resample(v,1,N) % resample to 24kHz (if fs = 96000, then N would = 4) 
>> 
>> load classifier_v7.mat % load the classification model 
>> 
>> [predictedLabels, etimes]=ppDeepPerchDetector(v24,station,fileID,rootdir,classifier,deleteflag) 
>> 

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

