% Emotion recognition with DEAP dataset.
% Step 2: Windowing.
% by: Diego Caro López.
% last edited: 30-Oct-2025.
%__________________________________________________________________________
%
% This MATLAB script will take the files obtained from
% 'Step1_Preprocessing.m', which contains two preprocessed EEG windows of 
% about 60 seconds for each emotion label of interest, for each
% participant. The goal of this script is:
%   1. To create 5-seconds windows from all the data and group them by
%      their corresponding emotion label. 
%__________________________________________________________________________

clear
clc
close all
beepbeep = 'Yes';
savedata = 'Yes';

files = dir('DEAP_clean3');
files = files(~[files.isdir]);

% Yes I care about efficiency now
surprise = cell(2*60/5*size(files,1),1);
relief = cell(2*60/5*size(files,1),1);
fear = cell(2*60/5*size(files,1),1);
disgust = cell(2*60/5*size(files,1),1);
fs = 250;

%% Step 1: Load clean EEG data
fprintf('\n===== Steps 1 & 2: Load clean EEG data & Create windows =====\n\n');
for id = 1:size(files,1)

    if id < 10
        sid = ['0' num2str(id)];
    else
        sid = num2str(id);
    end
    fid = ['SData' sid];
    SData = load(['DEAP_clean/' fid '.mat'],'SData').SData;
        
    %% Step 2: Create windows     
    cell_start = 24*(id - 1) + 1; 
    cell_end = cell_start + 23;
    for i = cell_start:cell_end
        k = i - 24*(id - 1);
        try
            if k <= 12
                eeg_start = 5*fs*(k - 1) + 1;
                eeg_end = eeg_start + 5*fs - 1;
                
                surprise{i} = SData.surprise{1}(:,eeg_start:eeg_end);
                relief{i} = SData.relief{1}(:,eeg_start:eeg_end);
                fear{i} = SData.fear{1}(:,eeg_start:eeg_end);
                disgust{i} = SData.disgust{1}(:,eeg_start:eeg_end);
            else
                eeg_start = 5*fs*(k - 13) + 1;
                eeg_end = eeg_start + 5*fs - 1;
        
                surprise{i} = SData.surprise{2}(:,eeg_start:eeg_end);
                relief{i} = SData.relief{2}(:,eeg_start:eeg_end);
                fear{i} = SData.fear{2}(:,eeg_start:eeg_end);
                disgust{i} = SData.disgust{2}(:,eeg_start:eeg_end);
            end
        catch me
            switch me.message(1:41)
                case 'Index in position 2 exceeds array bounds.'
                    if k <= 12; n = 1; else; n = 2; end
                    eeg_end2 = str2double(me.message(65:end));
                    msg = getReport(me,'extended','hyperlinks','off');
                    if contains(msg,'surprise')
                        failed = 'surprise';
                        surprise{i} = SData.surprise{n}(:,eeg_start:eeg_end2);
                        relief{i} = SData.relief{n}(:,eeg_start:eeg_end);
                        fear{i} = SData.fear{n}(:,eeg_start:eeg_end);
                        disgust{i} = SData.disgust{n}(:,eeg_start:eeg_end);
                    elseif contains(msg,'fear')
                        failed = 'fear';
                        fear{i} = SData.fear{n}(:,eeg_start:eeg_end2);
                        surprise{i} = SData.surprise{n}(:,eeg_start:eeg_end);
                        relief{i} = SData.relief{n}(:,eeg_start:eeg_end);
                        disgust{i} = SData.disgust{n}(:,eeg_start:eeg_end);
                    elseif contains(msg,'relief')
                        failed = 'relief';
                        relief{i} = SData.relief{n}(:,eeg_start:eeg_end2);
                        fear{i} = SData.fear{n}(:,eeg_start:eeg_end);
                        disgust{i} = SData.disgust{n}(:,eeg_start:eeg_end);
                        surprise{i} = SData.surprise{n}(:,eeg_start:eeg_end);
                    elseif contains(msg,'disgust')
                        failed = 'disgust';
                        disgust{i} = SData.disgust{n}(:,eeg_start:eeg_end2);
                        surprise{i} = SData.surprise{n}(:,eeg_start:eeg_end);
                        relief{i} = SData.relief{n}(:,eeg_start:eeg_end);
                        fear{i} = SData.fear{n}(:,eeg_start:eeg_end);
                    end
                    warning(['Participant ' num2str(id) ' with inconsistent cell sizes. ' ...
                        'Trial ' num2str(n) ...
                        '. Cell #' num2str(i) ...
                        ' of group ' failed '.'])
                    % There was absolutely no need to add all this code,
                    % but since I'm bored and can't go further without
                    % approval, I wanted to test my error handling skills. 
                otherwise
                    error(['Unable to create 5 second windows for participant ' ...
                        num2str(id) '. Trial ' num2str(n) '. Cell #' num2str(i) '.'])
            end
        end
    end
end
fprintf('\n Done...\n\n');

%% Step 3: Save the dataaahh!
fprintf('\n===== Step 3: Save the dataaaahhh!! =====\n\n');

% Now save each emotion group
if strncmpi(savedata,'Yes',1)
    
    % First get rid of incomplete windows
    surprise = surprise(~cellfun(@(x) size(x,2)<fs*5,surprise)); 
    fear = fear(~cellfun(@(x) size(x,2)<fs*5,fear)); 
    relief = relief(~cellfun(@(x) size(x,2)<fs*5,relief)); 
    disgust = disgust(~cellfun(@(x) size(x,2)<fs*5,disgust)); 

    surprise_dir = 'DEAP_windows3/surprise.mat';
    fear_dir = 'DEAP_windows3/fear.mat';
    relief_dir = 'DEAP_windows3/relief.mat';
    disgust_dir = 'DEAP_windows3/disgust.mat';

    save(surprise_dir,'surprise')
    save(fear_dir,'fear')
    save(relief_dir,'relief')
    save(disgust_dir,'disgust')
end

fprintf('\n Done...\n\n');

%% Step 4: Beepbeep! One participant's ready!
% Stealing code again huh. 

if strncmpi(beepbeep,'Yes',1)
    fprintf('\n===== Step 4: Alert! =====\n\n');
    for i = 1:5
        pause(1.25)
        beep
        fprintf('\n Beep Beep Diego!!! \n\n');
    end
    fprintf('\n Done...!!!!!!\n\n');
else
    fprintf('\n Done...!!!!!!\n\n');
end
