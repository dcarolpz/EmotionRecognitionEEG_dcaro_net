% Emotion recognition with DEAP dataset.
% Step 1: Preprocessing.
% by: Diego Caro López.
% last edited: 29-Oct-2025.
%__________________________________________________________________________
%
% This MATLAB script will automatically preprocess all the data that will
% be used to train a NN capable of decoding emotions from EEG signals. The
% training dataset will be the DEAP dataset. 
% 
% Notice: After loading each EEG file, the whole signal is preprocessed.
% Then, labels are added to  events according to the label of the video
% presented during the experiment. After that, the EEG signal is trimmed to
% only keep the portions of the signal where stimuli, in other words,
% videos are present. 
% _________________________________________________________________________

clear
clc 
close all
beepbeep = 'Yes';
savedata = 'Yes';

loc = 'C:\data_original';
addpath(loc);
files = dir(loc);
files = files(~[files.isdir]);

for id = 1:size(files,1)
%% Step 1: Load EEG data
fprintf('\n===== Step 1: Load EEG data =====\n\n');

if id > 22
    geneva = 1;
else
    geneva = 0;
end

if id < 10
    sid = ['0' num2str(id)];
else
    sid = num2str(id);
end
fid = ['s' sid '.bdf'];
EEG = pop_biosig(fid);

% Selecting only Aura channels
% channels = {'Fp1','Fp2','C3','C4','P3','P4','O1','O2'};
% channels = {'Fp1','F7','FC5','T7','P7','FC6','T8','O2'};
channels = {'Fp2','F7','F8','T7','T8','P7','P3','P8'};

chan_ids = find(ismember({EEG.chanlocs.labels},channels));
EEG = pop_select(EEG,'channel',chan_ids, ...
    'time',[0 EEG.event(end).latency/EEG.srate]);

% Reordering channels
[~,order] = ismember(channels,{EEG.chanlocs.labels});
EEG.chanlocs = EEG.chanlocs(order);
EEG.data = EEG.data(order,:);

% Resampling data
EEG = pop_resample(EEG,250);

fprintf('\n Done...\n\n');

%% Step 2: Bandpass filter @ 1-50 Hz
fprintf('\n===== Step 2: Bandpass filter @ 1-50 Hz =====\n\n');

EEG = pop_eegfiltnew(EEG,'locutoff',1,'hicutoff',50);

fprintf('\n Done...\n\n');

%% Step 3: Common Average Reference
fprintf('\n===== Step 3: Run CAR =====\n\n');

EEG = pop_reref(EEG,[]);

fprintf('\n Done...\n\n');

%% Step 4: CleanLine for 50 Hz line noise removal
fprintf('\n===== Step 4: Cleanline =====\n\n');

EEG = pop_cleanline(EEG, ...
    'ChanCompIndices',1:EEG.nbchan, ...
    'SignalType','Channels', ...
    'ComputeSpectralPower',true, ...
    'Bandwidth',1, ...
    'SlidingWinStep',0.5, ...
    'SlidingWinLength',4, ...
    'LineFrequencies',[12 24 35 48 50]);
    
    [b,a] = butter(2,[49 51]/(250/2),'stop');
    EEG.data = filtfilt(b,a,EEG.data')';

fprintf('\n Done...\n\n');

%% Step 5: Wavelet Assisted Adaptative Filter for EOG artifact removal
fprintf('\n===== Step 5: Run WAAF =====\n\n');

EEG.data = dcaro_WAAF(EEG.data);

fprintf('\n Done...\n\n');

%% Step 6: Add event labels & select data
fprintf('\n===== Step 6: Add labels =====\n\n');

% Fix missing status channel in Geneva participants
if geneva && id~=23
    % File 23 ruined my consistency
    EEG.event(cellfun(@(x) strcmp(x,'65280'),{EEG.event.type})) = [];
    [EEG.event(:).edftype] = deal(0);
    
    types = str2double({EEG.event.type});
    [EEG.event(types == 65283).edftype] = deal(3);
    [EEG.event(types == 65284).edftype] = deal(4);
    [EEG.event(types == 65285).edftype] = deal(5);
end

% Ok so at this point, we have the EEG data preprocessed. Now we're only
% missing the labels. We have 4 labels and at least two trials for each
% label in every participant. The problem is that the order in which the
% videos were shown was random. But guess what! Lucky for us, we have file
% 'participant_rating.csv' inside 'metadata'. And so conviniently, this
% mysterious file named 'ids_dcaro.csv' already has the label of each
% video, it appeared out of nowhere! Now we can assign the Experiment_id of
% each emotion:
surprise.experiment_id = [2 32];
% relief.experiment_id = [18 19];
fear.experiment_id = [31 34];
disgust.experiment_id = [37 38];

% Now we need to find the trial number of each emotion for each participant
% and match it to the EEG.event.edftype. This field consists of:
%   1. Start of a rating screen. 
%   3. Fixation screen before beginning of a trial. 
%   4. Start of video playing. 
%   5. Fixation screen after video playback. 

rates = readmatrix('metadata/participant_ratings.csv'); % Damn efficiency lol.
% Inside rates:
% Participant_id | Trial | Experiment_id ... (we don't care about the rest)
%
% And we can get rid of more data, since we're processing only one
% participant each iteration. Let's do it:
id_start = 40*(id-1) + 1;
id_end = id_start + 39;
rates = rates(id_start:id_end,1:3);

[surprise.trials,~] = find(rates(:,3)==surprise.experiment_id);
% [relief.trials,~] = find(rates(:,3)==relief.experiment_id);
[fear.trials,~] = find(rates(:,3)==fear.experiment_id);
[disgust.trials,~] = find(rates(:,3)==disgust.experiment_id);

% Now we have the indexes of each trial of interest for each participant. 
% Then match these indexes to the events EEG.event.edftype with values 4 & 5.
trial_starts = find([EEG.event.edftype]==4);
trial_ends = find([EEG.event.edftype]==5);
if geneva
    trial_ends(1:2) = [];
end

% Select data for Surprise
surprise.start = sort([EEG.event(trial_starts(surprise.trials)).latency])/EEG.srate;
surprise.end = sort([EEG.event(trial_ends(surprise.trials)).latency])/EEG.srate;
surprise.data1 = pop_select(EEG,'time',[surprise.start(1) surprise.end(1)]).data;
surprise.data2 = pop_select(EEG,'time',[surprise.start(2) surprise.end(2)]).data;

% Select data for Relief
% relief.start = sort([EEG.event(trial_starts(relief.trials)).latency])/EEG.srate;
% relief.end = sort([EEG.event(trial_ends(relief.trials)).latency])/EEG.srate;
if ~geneva 
    relief.start = [EEG.event(2).latency EEG.event(2).latency + 60*EEG.srate]/EEG.srate;
    relief.end = [EEG.event(2).latency + 60*EEG.srate EEG.event(2).latency + 120*EEG.srate]/EEG.srate;
else
    relief.start = [EEG.event(9).latency EEG.event(9).latency + 60*EEG.srate]/EEG.srate;
    relief.end = [EEG.event(9).latency + 60*EEG.srate EEG.event(9).latency + 120*EEG.srate]/EEG.srate;
end
relief.data1 = pop_select(EEG,'time',[relief.start(1) relief.end(1)]).data;
relief.data2 = pop_select(EEG,'time',[relief.start(2) relief.end(2)]).data;

% Select data for Fear
fear.start = sort([EEG.event(trial_starts(fear.trials)).latency])/EEG.srate;
fear.end = sort([EEG.event(trial_ends(fear.trials)).latency])/EEG.srate;
fear.data1 = pop_select(EEG,'time',[fear.start(1) fear.end(1)]).data;
fear.data2 = pop_select(EEG,'time',[fear.start(2) fear.end(2)]).data;

% Select data for Disgust
disgust.start = sort([EEG.event(trial_starts(disgust.trials)).latency])/EEG.srate;
disgust.end = sort([EEG.event(trial_ends(disgust.trials)).latency])/EEG.srate;
disgust.data1 = pop_select(EEG,'time',[disgust.start(1) disgust.end(1)]).data;
disgust.data2 = pop_select(EEG,'time',[disgust.start(2) disgust.end(2)]).data;

fprintf('\n Done...\n\n');

%% Step 7: Save all this hard work
fprintf('\n===== Step 7: Saving datahhh =====\n\n');

% Put everything inside SData
SData.filename = fid;

% Don't judge me, I like vertical arrays for cells.
SData.surprise{1,1} = surprise.data1; 
SData.surprise{2,1} = surprise.data2;

SData.relief{1,1} = relief.data1; 
SData.relief{2,1} = relief.data2;

SData.fear{1,1} = fear.data1; 
SData.fear{2,1} = fear.data2;

SData.disgust{1,1} = disgust.data1; 
SData.disgust{2,1} = disgust.data2;

% Now save SData
if strncmpi(savedata,'Yes',1)
    savename = ['SData' sid];
    savedir = ['DEAP_cleanCatyWong/' savename '.mat'];
    save(savedir,'SData')
end

fprintf('\n Done...\n\n');

%% Step 8: Beepbeep! One participant's ready!
% Hah What you gonna do now Alex, come here to Japan and get me? Good 
% luck with that. Your codes are mine now (mwahahah -dcarolpz).

if strncmpi(beepbeep,'Yes',1)
    fprintf('\n===== Step 8: Alert! =====\n\n');
    for i = 1:5
        pause(1.25)
        beep
        fprintf('\n Beep Beep Diego!!! \n\n');
    end
    fprintf('\n Done...!!!!!!\n\n');
else
    fprintf('\n Done...!!!!!!\n\n');
end
end
