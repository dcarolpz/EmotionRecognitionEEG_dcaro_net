% Clean full signal recorded with Aura software
% by: dcaro
% last edited: 29-Oct-2025

clear
clc
close all
file = 'dcaro_motion/eeg.csv';

%% 1. Load EEG
fprintf('\n===== Step 1: Load EEG data =====\n\n');

EEG = Aura2eeglab(file);

fprintf('\n Done...\n\n');

%% 2. Bandpass filter (1-50 Hz)
fprintf('\n===== Step 2: Bandpass filter @ 1-50 Hz =====\n\n');

EEG = pop_eegfiltnew(EEG,'locutoff',1,'hicutoff',50);

fprintf('\n Done...\n\n');

%% 3. Common Average Reference
fprintf('\n===== Step 3: Run CAR =====\n\n');

EEG = pop_reref(EEG,[]);
EEG2 = EEG;

fprintf('\n Done...\n\n');

%% 4. Cleanline @ 60 Hz
fprintf('\n===== Step 4: Cleanline =====\n\n');

EEG = pop_cleanline(EEG, ...
    'ChanCompIndices',1:EEG.nbchan, ...
    'SignalType','Channels', ...
    'ComputeSpectralPower',true, ...
    'Bandwidth',1, ...
    'SlidingWinStep',0.5, ...
    'SlidingWinLength',4, ...
    'LineFrequencies',60);

    [b,a] = butter(2,[59 61]/(250/2),'stop');
    EEG.data = filtfilt(b,a,EEG.data')';

    fprintf('\n Done...\n\n');
%% 5. WAAF 
fprintf('\n===== Step 5: Run WAAF =====\n\n');

EEG.data = dcaro_WAAF(EEG.data);

fprintf('\n Done...\n\n');

%% Finished!!!
% Visualize data: CAR vs Clean
fprintf('\n===== Step 6: Visualize results =====\n\n');

figure
hold on
pspectrum(EEG2.data(1,:),EEG2.srate)
pspectrum(EEG.data(1,:),EEG.srate)
xlim([0 80])
legend('EEG after CAR','EEG after WAAF')

figure
dcaro_stacked(EEG2,'color','k','scalecol','r','tile',1,'scale',80,'win',[67 70])
dcaro_stacked(EEG,'color','r','scalecol','b','tile',1,'scale',80,'win',[67 70])

fprintf('\n Done...\n\n');

%% Additional: Run Inverse Source Localization and IClabel
fprintf('\n===== Extra step: Run ICA + DIPFIT =====\n\n');

EEG = pop_chanedit(EEG,'lookup',['C:\Program Files\MATLAB\R2023a' ...
    '\toolbox\eeglab2021.1\plugins\dipfit5.4\standard_BEM\elec' ...
    '\standard_1005.elc']);
EEG = pop_runica(EEG,'icatype','runica','extended',1,'interrupt','off');
dipfit_obj = class_DIPFIT('input',EEG);
process(dipfit_obj);
EEG = dipfit_obj.postEEG;
EEG = iclabel(EEG,'default');
pop_viewprops(EEG,0);

fprintf('\n Done...\n\n');
