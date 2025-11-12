
% Emotion recognition with DEAP dataset.
% Step 2: Overlapping windows
% by: Diego Caro López.
% last edited: 04-Nov-2025.
%__________________________________________________________________________
%
% This MATLAB script will take the files obtained from
% 'Step1_Preprocessing.m', which contains two preprocessed EEG windows of 
% about 60 seconds for each emotion label of interest, for each
% participant. The goal of this script is:
%   1. To create 5-second overlapping-windows from all the data and group 
%      them by their corresponding emotion label.
%__________________________________________________________________________

clear
clc
close all
beepbeep = 'No';
savedata = 'Yes';

files = dir('DEAP_cleanF');
files = files(~[files.isdir]);

overlap = 0.5;
n = 2*60/5/overlap - 2;
f = size(files,1);

surprise = cell(n*f,1);
relief = cell(n*f,1);
fear = cell(n*f,1);
disgust = cell(n*f,1);

fs = 250;
len = 5*fs;
stride = floor(overlap*len);

%% Step 1: Load clean EEG data
fprintf('\n===== Steps 1 & 2: Load clean EEG data & Create windows =====\n\n');
for id = 1:f
    
    if id < 10
        sid = ['0' num2str(id)];
    else
        sid = num2str(id);
    end
    fid = ['SData' sid];
    SData = load(['DEAP_cleanF/' fid '.mat'],'SData').SData;

    %% Step 2: Create windows
    cell_start = n*(id - 1) + 1; 
    cell_end = cell_start + n - 1;
    eeg_start = -stride + 1;

    for i = cell_start:cell_end
        k = i - n*(id - 1);
        eeg_start = eeg_start + stride;
        if k < n/2
            trial = 1;
        elseif k == (n/2) + 1
            trial = 2;
            eeg_start = 1;
        end
        eeg_end = eeg_start + len - 1;

        try
            surprise{i} = SData.surprise{trial}(:,eeg_start:eeg_end);
            relief{i} = SData.relief{trial}(:,eeg_start:eeg_end);
            fear{i} = SData.fear{trial}(:,eeg_start:eeg_end);
            disgust{i} = SData.disgust{trial}(:,eeg_start:eeg_end);
        catch me
            switch me.message(1:41)
                case 'Index in position 2 exceeds array bounds.'
                    eeg_end2 = str2double(me.message(65:end));
                    msg = getReport(me,'extended','hyperlinks','off');
                    if contains(msg,'surprise')
                        failed = 'surprise';
                        surprise{i} = SData.surprise{trial}(:,eeg_start:eeg_end2);
                        relief{i} = SData.relief{trial}(:,eeg_start:eeg_end);
                        fear{i} = SData.fear{trial}(:,eeg_start:eeg_end);
                        disgust{i} = SData.disgust{trial}(:,eeg_start:eeg_end);
                    elseif contains(msg,'relief')
                        failed = 'relief';
                        surprise{i} = SData.surprise{trial}(:,eeg_start:eeg_end);
                        relief{i} = SData.relief{trial}(:,eeg_start:eeg_end2);
                        fear{i} = SData.fear{trial}(:,eeg_start:eeg_end);
                        disgust{i} = SData.disgust{trial}(:,eeg_start:eeg_end);
                    elseif contains(msg,'fear')
                        failed = 'fear';
                        surprise{i} = SData.surprise{trial}(:,eeg_start:eeg_end);
                        relief{i} = SData.relief{trial}(:,eeg_start:eeg_end);
                        fear{i} = SData.fear{trial}(:,eeg_start:eeg_end2);
                        disgust{i} = SData.disgust{trial}(:,eeg_start:eeg_end);
                    elseif contains(msg,'disgust')
                        failed = 'disgust';
                        surprise{i} = SData.surprise{trial}(:,eeg_start:eeg_end);
                        relief{i} = SData.relief{trial}(:,eeg_start:eeg_end);
                        fear{i} = SData.fear{trial}(:,eeg_start:eeg_end);
                        disgust{i} = SData.disgust{trial}(:,eeg_start:eeg_end2);
                    end
                    warning(['Participant ' num2str(id) ' with inconsistent cell sizes. ' ...
                        'Trial ' num2str(trial) ...
                        '. Cell #' num2str(i) ...
                        ' of group ' failed '.'])
                otherwise
                    error(['Unable to create 5 second windows for participant ' ...
                        num2str(id) '. Trial ' num2str(n) '. Cell #' num2str(i) '.'])
            end
        end
    end
end
fprintf('\n Done...\n\n');

%% Step 3: Save the dataaahh!
% Now save each emotion group
if strncmpi(savedata,'Yes',1)
  
    fprintf('\n===== Step 3: Save the dataaaahhh!! =====\n\n');
  
    % First get rid of incomplete windows
    surprise = surprise(~cellfun(@(x) size(x,2)<fs*5,surprise)); 
    fear = fear(~cellfun(@(x) size(x,2)<fs*5,fear)); 
    relief = relief(~cellfun(@(x) size(x,2)<fs*5,relief)); 
    disgust = disgust(~cellfun(@(x) size(x,2)<fs*5,disgust)); 

    surprise_dir = 'DEAP_windowsF/surprise.mat';
    fear_dir = 'DEAP_windowsF/fear.mat';
    relief_dir = 'DEAP_windowsF/relief.mat';
    disgust_dir = 'DEAP_windowsF/disgust.mat';

    save(surprise_dir,'surprise')
    save(fear_dir,'fear')
    save(relief_dir,'relief')
    save(disgust_dir,'disgust')

    fprintf('\n Done...\n\n');
end

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

%% Compare windows

compare_wins = 'Yes';
if strncmpi(compare_wins,'Yes',1)
    n = 800;
    
    files = dir('DEAP_windowsF');
    files = files(~[files.isdir]);
    for i = 1:size(files,1); load(['DEAP_windowsF\' files(i).name]); end

    f = tiledlayout(2,2,'TileSpacing','tight');
    fig = f.Parent;
    fig.WindowState = 'maximized';

    dcaro_stacked(surprise{n},'fs',250,'scale',100,'tile',1,'scalecol','none','color','k')
    title(['Surprise window #' num2str(n)])
    dcaro_stacked(relief{n},'fs',250,'scale',100,'tile',2,'color','k')
    title(['Relief window #' num2str(n)])
    dcaro_stacked(fear{n},'fs',250,'scale',100,'tile',3,'scalecol','none','color','k')
    title(['Fear window #' num2str(n)])
    dcaro_stacked(disgust{n},'fs',250,'scale',100,'tile',4,'scalecol','none','color','k')
    title(['Disgust window #' num2str(n)])

end