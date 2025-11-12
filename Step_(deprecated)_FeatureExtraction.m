% Emotion recognition with DEAP dataset.
% Step 3: Feature Extraction.
% by: Diego Caro López.
% last edited: 31-Oct-2025.
%__________________________________________________________________________
%
% This MATLAB script will take the files obtained from:
% 'Step2_Windowing.m', which contains preprocessed 5-second windows of EEG 
% data grouped by emotions.The goal of this script is: 
%   1. To extract features from each window to use as input of a Machine
%      Learning model. 
%__________________________________________________________________________

clear
clc 
close all
beepbeep = 'Yes';
savedata = 'Yes';

%% Step 1: Load EEG windows
fprintf('\n===== Step 1: Load EEG windows =====\n\n');

files = dir('DEAP_windows');
files = files(~[files.isdir]);
for i = 1:size(files,1); load(['DEAP_windows/' files(i).name]); end

fprintf('\n Done...\n\n');

%% Step 2: Extract the mean of PSD in frequency ranges for each electrode
fprintf('\n===== Step 2: Feature extraction =====\n\n');

features.surprise = zeros(size(surprise,1),8*3);
features.relief = zeros(size(relief,1),8*3);
features.fear = zeros(size(fear,1),8*3);
features.disgust = zeros(size(disgust,1),8*3);

alpha = 8:0.01:12;
beta = 12:0.01:30;
gamma = 30:0.01:50;

for i = 1:size(surprise,1)
    [psd,f] = pmtm(surprise{i}',4,'Tapers','slepian',8:0.01:50,250);
    
    [alpha_loc,~] = find(f==alpha);
    [beta_loc,~] = find(f==alpha);
    [gamma_loc,~] = find(f==alpha);

    mean_alpha = mean(pow2db(psd(alpha_loc,:)));
    mean_beta = mean(pow2db(psd(beta_loc,:)));
    mean_gamma = mean(pow2db(psd(gamma_loc,:)));

    features.surprise(i,1:8) = mean_alpha;
    features.surprise(i,9:16) = mean_beta;
    features.surprise(i,17:24) = mean_gamma;
end

for i = 1:size(relief,1)
    [psd,~] = pmtm(relief{i}',4,'Tapers','slepian',8:0.01:50,250);

    mean_alpha = mean(pow2db(psd(alpha_loc,:)));
    mean_beta = mean(pow2db(psd(beta_loc,:)));
    mean_gamma = mean(pow2db(psd(gamma_loc,:)));

    features.relief(i,1:8) = mean_alpha;
    features.relief(i,9:16) = mean_beta;
    features.relief(i,17:24) = mean_gamma;
end

for i = 1:size(fear,1)
    [psd,~] = pmtm(fear{i}',4,'Tapers','slepian',8:0.01:50,250);

    mean_alpha = mean(pow2db(psd(alpha_loc,:)));
    mean_beta = mean(pow2db(psd(beta_loc,:)));
    mean_gamma = mean(pow2db(psd(gamma_loc,:)));

    features.fear(i,1:8) = mean_alpha;
    features.fear(i,9:16) = mean_beta;
    features.fear(i,17:24) = mean_gamma;
end

for i = 1:size(disgust,1)
    [psd,~] = pmtm(disgust{i}',4,'Tapers','slepian',8:0.01:50,250);

    mean_alpha = mean(pow2db(psd(alpha_loc,:)));
    mean_beta = mean(pow2db(psd(beta_loc,:)));
    mean_gamma = mean(pow2db(psd(gamma_loc,:)));

    features.disgust(i,1:8) = mean_alpha;
    features.disgust(i,9:16) = mean_beta;
    features.disgust(i,17:24) = mean_gamma;
end

fprintf('\n Done...\n\n');

%% Step 3: Stack training data in a single array
fprintf('\n===== Step 3: Stack data =====\n\n');

% Stack features and create Target Vector
stack = [features.surprise ones(size(features.surprise,1),1); 
         features.relief 2*ones(size(features.relief,1),1);
         features.fear 3*ones(size(features.fear,1),1); 
         features.disgust 4*ones(size(features.disgust,1),1)];

fprintf('\n Done...\n\n');

%% Step 4: Save the dataaahh!
fprintf('\n===== Step 4: Save the dataaaahhh!! =====\n\n');

if strncmpi(savedata,'Yes',1)
    savename = 'Features';
    savedir = ['DEAP_features/' savename];
    save(savedir,'features','stack')
end

fprintf('\n Done...\n\n');

%% Step 5: Beep beep! Done!
% At this point this code is mine now. OMG I found this new code its
% hilarious.

if strncmpi(beepbeep,'Yes',1)
    fprintf('\n===== Step 5: Alert! =====\n\n');
    Data = load('handel.mat');
    sound(Data.y, Data.Fs)
    fprintf('\n Beep Beep Diego!!! \n\n');
    fprintf('\n Done...!!!!!!\n\n');
else
    fprintf('\n Done...!!!!!!\n\n');
end
