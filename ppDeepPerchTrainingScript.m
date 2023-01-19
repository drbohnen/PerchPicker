% This script used to train a new classifier 
% AUTHORS: 
% D. Bohnenstiehl (NCSU) 
% perch picker v.1 
% 25 Aug 22 

clear

%% Load the scalogram images as a datastore, folder name  = labels 
labeled_input_folder='newtrainingv8'; 
imds = imageDatastore(labeled_input_folder, 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
imds=shuffle(imds);  % mix them up 
tbl = countEachLabel(imds)

% where labeled_input_folder is a directory with subdirecotries 'perch' and 'other'
% containing scalogram images labeled into these two classes. 

%% generate a sheet of examples 
perch = find(imds.Labels == 'perch');other = find(imds.Labels == 'other');
nP=table2array(tbl(2,2));
nO=table2array(tbl(1,2));
figure
for i=1:16 
subplot(4,4,i); imshow(readimage(imds,perch(randi(nP,1)))); title('perch example')
end

figure
for i=1:16 
subplot(4,4,i); imshow(readimage(imds,other(randi(nO,1)))); title('other example')
end


%% Use splitEachLabel method to trim to a balanced dataset 
minSetCount = min(tbl{:,2});
imds = splitEachLabel(imds, minSetCount, 'randomize');

%% Load pretrained network
net = resnet50();
% resNet50 must be installed first: 
% https://www.mathworks.com/help/deeplearning/ref/resnet50.html

%% Prepare Training and Test
% 70% training, 30% testing 
[trainingSet, testSet] = splitEachLabel(imds, 0.7, 'randomize'); 


%% Get Training Features 
featureLayer = 'fc1000';
trainingFeatures = activations(net,trainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');


%% Get training labels from the trainingSet
trainingLabels = trainingSet.Labels;


%% Train Model 
classifier1 = fitcsvm(...
    trainingFeatures', ...
    trainingLabels, ...
    'KernelFunction', 'polynomial', ...
    'PolynomialOrder', 3, ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true, ...
    'Cost',[0 1;1 0],...
    'ClassNames', categorical({'other'; 'perch'})); 

%  'Cost', [ 0 1; 1 0] gives same weight to both classes (default) 


%% Posterior Probability 
classifier = fitSVMPosterior(classifier1);  % estimate posterior probability from scores 

%%  apply to training data 
[predictedLabels,TrainingScores] = predict(classifier, trainingFeatures, 'ObservationsIn', 'columns');

% Get the known labels
trainingLabels = trainingSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(trainingLabels, predictedLabels);

disp('results for training data')
% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))

%% calculate k-folds cross model 
disp('K-fold Cross Validation Class Loss')
CVSVMModel = crossval(classifier1);
classLoss = kfoldLoss(CVSVMModel)

classifier2 = fitcsvm(...
    trainingFeatures', ...
    trainingLabels, ...
    'KernelFunction', 'polynomial', ...
    'PolynomialOrder', 3, ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true, ...
    'KFold',10,...
    'ClassNames', categorical({'other'; 'perch'})); 

predictionkfold = kfoldPredict(classifier2);
confMat = confusionmat(trainingLabels, predictionkfold);
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))



%%  apply to test data set 
% Extract test features using the CNN
testFeatures = activations(net, testSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

% Pass CNN image features to trained classifier
[predictedLabels,predictedScores]= predict(classifier, testFeatures, 'ObservationsIn', 'columns');

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

disp('results for test data')
% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))

figure; 
cm=confusionchart(testLabels, predictedLabels);
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
cm.Title = 'Test Data Confusion Matrix';

time = datestr(now, 'yyyy_mm_dd');
filename = sprintf('classifier_pp_%s.mat',time);
save(filename,'classifier','labeled_input_folder') 




