% Script will calculate layer activations and generate TSNE ordination
% of labeled data for visualizing class seperation  
%
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 24 Aug 22 

imds = imageDatastore('newtraining', 'LabelSource', 'foldernames', 'IncludeSubfolders',true);

net = resnet50();
% get training features 
featureLayer = 'fc1000';
trainingFeatures = activations(net,imds, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');


% Get training labels from the trainingSet
trainingLabels = imds.Labels;

Y = tsne(trainingFeatures'); figure; gscatter(Y(:,1),Y(:,2),trainingLabels)