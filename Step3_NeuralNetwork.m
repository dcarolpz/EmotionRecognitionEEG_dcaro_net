% Emotion recognition with DEAP dataset.
% Step 4: NN using DLToolbox.
% by: Diego Caro López.
% last edited: 31-Oct-2025.
%__________________________________________________________________________

clear
clc
close all
model = 1;

%% Step 1: Load EEG windows
fprintf('\n===== Step 1: Load EEG windows =====\n\n');
    
files = dir('DEAP_windowsF');
files = files(~[files.isdir]);
for i = 1:size(files,1); load(['DEAP_windowsF\' files(i).name]); end

fprintf('\n Done...\n\n');

%% Step 2: Prepare data for training
fprintf('\n===== Step 2: Preparing data for training =====\n\n');

data = [surprise(:);
        relief(:);
        fear(:); 
        disgust(:)];

labels = [ones(size(surprise,1),1);
          ones(size(relief,1),1)*2;
          ones(size(fear,1),1)*3;
          ones(size(disgust,1),1)*4];
labels = categorical(labels);

n = numel(data);
[idxTrain,idxTest,idxValid] = trainingPartitions(n,[0.8 0.1 0.1]);
XTrain = data(idxTrain);
TTrain = labels(idxTrain);

XTest = data(idxTest);
TTest = labels(idxTest);

XValid = data(idxValid);
TValid = labels(idxValid);

emotions = {'Surprise','Relief','Fear','Disgust'}';
numChannels = size(data{1},1);

fprintf('\n Done...\n\n');

%% Step 3: Define LSTM Architecture
fprintf('\n===== Step 3: Define LSTM Architecture =====\n\n');

numHiddenUnits = 16;
numClasses = 4;
layers = [
    sequenceInputLayer(numChannels,"MinLength",1250,'Normalization','zscore')
    convolution1dLayer(8,64,'Padding','causal')
    reluLayer
    layerNormalizationLayer
    transposedConv1dLayer(8,64,'NumChannels',64)
    reluLayer
    layerNormalizationLayer
    convolution1dLayer(8,128,'Padding','causal')
    globalAveragePooling1dLayer
    bilstmLayer(numHiddenUnits,OutputMode='last')
    dropoutLayer(0.25)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    MaxEpochs = 100, ...
    InitialLearnRate = 0.001, ...
    GradientThreshold = 1, ...
    Shuffle = 'every-epoch', ...
    Plots = 'training-progress', ...
    ValidationData = {XValid,TValid}, ...
    Verbose = false);

analyzeNetwork(layers)

fprintf('\n Done...\n\n');

%% Step 4: Train LSTM Neural Network
fprintf('\n===== Step 4: Train LSTM =====\n\n');

[dcaro_net,info] = trainNetwork(XTrain,TTrain,layers,options);

fprintf('\n Done...\n\n');

%% Step 5: Test the LSTM Neural Network
fprintf('\n===== Step 5: Test LSTM =====\n\n');

YTest = classify(dcaro_net,XValid);
acc = mean(YTest==TValid);


fprintf([' And your accuracy was: ' num2str(round(100*acc,2)) '%%.\n'])

figure
confusionchart(TValid,YTest)

fprintf('\n Done...\n\n');

%% Step 6: Save Neural Network
savenet = 'No';

if strncmpi(savenet,'Yes',1)
    fprintf('\n===== Step 6: Save the Neural Network!!! =====\n\n');
    t = char(datetime('now','TimeZone','local','Format','d-MMM-y'));
    
    savedir = ['Models/' num2str(model) '_' t '.mat'];
    save(savedir,'dcaro_net','info')

    fprintf('\n Done...\n\n');
end

%% Previous models
%{
Accuracy: 41.83% (Chans 1)
numHiddenUnits = 120;
numClasses = 4;
layers = [
    sequenceInputLayer(numChannels,"MinLength",1250,'Normalization','zscore')
    convolution1dLayer(6,64,'Padding','causal')
    reluLayer
    layerNormalizationLayer
    maxPooling1dLayer(6)
    transposedConv1dLayer(12,64,'NumChannels',64)
    reluLayer
    layerNormalizationLayer
    convolution1dLayer(24,64,'Padding','causal')
    globalAveragePooling1dLayer
    lstmLayer(numHiddenUnits,OutputMode='sequence')
    dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    MaxEpochs = 80, ...
    InitialLearnRate = 0.001, ...
    GradientThreshold = 1, ...
    Shuffle = 'every-epoch', ...
    Plots = 'training-progress', ...
    ValidationData = {XValid,TValid}, ...
    Verbose = false);
%} 

%{
Accuracy: 41.5% (Chans 2)
numHiddenUnits = 120;
numClasses = 4;
layers = [
    sequenceInputLayer(numChannels,"MinLength",1250,'Normalization','zscore')
    convolution1dLayer(6,64,'Padding','causal')
    reluLayer
    layerNormalizationLayer
    transposedConv1dLayer(12,64,'NumChannels',64)
    reluLayer
    layerNormalizationLayer
    convolution1dLayer(24,64,'Padding','causal')
    globalAveragePooling1dLayer
    bilstmLayer(numHiddenUnits,OutputMode='last')
    dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    MaxEpochs = 50, ...
    InitialLearnRate = 0.001, ...
    GradientThreshold = 1, ...
    Shuffle = 'every-epoch', ...
    Plots = 'training-progress', ...
    ValidationData = {XValid,TValid}, ...
    Verbose = false);
%}

%{
Accuracy: 46.41% (Chans 2)
numHiddenUnits = 150;
numClasses = 4;
layers = [
    sequenceInputLayer(numChannels,"MinLength",1250,'Normalization','zscore')
    convolution1dLayer(6,128,'Padding','causal')
    reluLayer
    layerNormalizationLayer
    transposedConv1dLayer(12,128,'NumChannels',128)
    reluLayer
    layerNormalizationLayer
    convolution1dLayer(24,128,'Padding','causal')
    globalAveragePooling1dLayer
    bilstmLayer(numHiddenUnits,OutputMode='last')
    dropoutLayer(0.3)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    MaxEpochs = 50, ...
    InitialLearnRate = 0.001, ...
    GradientThreshold = 1, ...
    Shuffle = 'every-epoch', ...
    Plots = 'training-progress', ...
    ValidationData = {XValid,TValid}, ...
    Verbose = false);
%}

%{
Accuracy ~ 43% (Chans 3)
numHiddenUnits = 120;
numClasses = 4;
layers = [
    sequenceInputLayer(numChannels,"MinLength",1250,'Normalization','zscore')
    convolution1dLayer(10,128,'Padding','causal')
    reluLayer
    layerNormalizationLayer
    transposedConv1dLayer(10,128,'NumChannels',128)
    reluLayer
    layerNormalizationLayer
    convolution1dLayer(10,128,'Padding','causal')
    globalAveragePooling1dLayer
    lstmLayer(numHiddenUnits,OutputMode='last')
    dropoutLayer(0.25)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    MaxEpochs = 50, ...
    InitialLearnRate = 0.001, ...
    GradientThreshold = 1, ...
    Shuffle = 'every-epoch', ...
    Plots = 'training-progress', ...
    ValidationData = {XValid,TValid}, ...
    Verbose = false);
%}

%{
EEGNET + LSTM Attempt
numHiddenUnits = 40;
numClasses = 4;
layers = [
    sequenceInputLayer([1 numChannels],'MinLength',1250,'Normalization','zscore')
    transposedConv1dLayer(8,8)
    batchNormalizationLayer

    convolution1dLayer(6,8,'Padding','causal')
    flattenLayer
    batchNormalizationLayer
    reluLayer
    averagePooling1dLayer(4)
    dropoutLayer(0.25)

    transposedConv1dLayer(6,8,'Cropping','same')
    batchNormalizationLayer
    reluLayer
    averagePooling1dLayer(4)
    dropoutLayer(0.25)
    flattenLayer

    bilstmLayer(numHiddenUnits,OutputMode='last')
    dropoutLayer(0.25)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    MaxEpochs = 50, ...
    InitialLearnRate = 0.001, ...
    GradientThreshold = 1, ...
    Shuffle = 'every-epoch', ...
    Plots = 'training-progress', ...
    ValidationData = {XValid,TValid}, ...
    Verbose = false);
%}

%{
Channels 2 (Relief = Basal)
Accuracy: 75%
numHiddenUnits = 150;
numClasses = 4;
layers = [
    sequenceInputLayer(numChannels,"MinLength",1250,'Normalization','zscore')
    convolution1dLayer(6,128,'Padding','causal')
    reluLayer
    layerNormalizationLayer
    transposedConv1dLayer(12,128,'NumChannels',128)
    reluLayer
    layerNormalizationLayer
    convolution1dLayer(24,128,'Padding','causal')
    globalAveragePooling1dLayer
    bilstmLayer(numHiddenUnits,OutputMode='last')
    dropoutLayer(0.3)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    MaxEpochs = 50, ...
    InitialLearnRate = 0.001, ...
    GradientThreshold = 1, ...
    Shuffle = 'every-epoch', ...
    Plots = 'training-progress', ...
    ValidationData = {XValid,TValid}, ...
    Verbose = false);
%}
