# PerchPicker
MATLAB software to identify American silver perch calls in passive acoustic data using deep learning. 

Bohnenstiehl, D.R., in prep 2023, Automated cataloging of American silver perch (Bairdiella chrysoura) calls using machine learning

perch_classifier_v7.mat = classifier from above paper, trained on 12,000 labeled signals from data in western Pamlico Sound, NC.  This is the recommended classifier 


Instructions and a brief tutorial are provided on the PerchPicker Wiki! 
https://github.com/drbohnen/PerchPicker/wiki


**Overview:** he American silver perch (Bairdiella chrysoura) is a numerically dominant and ecologically important species found throughout coastal habitats along the eastern United States and the Gulf of Mexico.  During spawning in the spring and summer, male silver perch produce distinctive knocking sounds to attract females.  These sounds are readily identifiable through aural and visual analysis of underwater acoustic recordings, providing a means to track their distribution and spawning activity.  However, as the volume of passive acoustic datasets grows, there is an essential need to automate this process. The approach presented here utilizes a (1) detection stage, where candidate calls are identified based on the properties of signal kurtosis and signal-to-noise ratio, (2) a feature extraction stage where layer activations are returned from the pre-trained ResNet-50 convolutional neural network operating on a wavelet scalogram of the candidate signals, and (3) a one-vs-all supported-vector-machine classifier.  The labeled dataset used for training and testing consists of 6,000 perch calls and 6,000 other signals, which sample diverse acoustic conditions across eight sites within Pamlico Sound, NC USA.  The classifier accuracy is 98.9% when evaluated against the test data. Accompanying MATLAB codes provide a robust and efficient tool that can be used to monitor the vocalizations of American silver perch in passive acoustic datasets. 
