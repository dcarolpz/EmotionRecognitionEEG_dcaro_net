% Aura - Mirai testing
% by: dcaro, Mirai Innovation Research Institute;
%     Osaka, Japan, 15-Oct-2025.
clear 
clc
close all

EEG = load("EEG_raw.mat");
EEG = EEG.EEG_raw;

%__________________________________________________________________________
% 1. Raw EEG data
EEG = pop_select(EEG,'time',[30 60]);
dcaro_stacked(EEG)
title('Raw EEG')

%__________________________________________________________________________
% 2. H-infinity filter
My_ref = [EEG.data(1,:);
          EEG.data(2,:);
          ones(1,size(EEG.times,2))];

fprintf('\n Starting H-infinity filter...\n\n');
% EEG.data = AS_hinfinityEEG(EEG.data,My_ref,'parallel','on');

fprintf('\n Done...\n\n');
dcaro_stacked(EEG)
title('EEG after H-infinity filter')

%__________________________________________________________________________
% 3. Bandpass filter
lo = 0.2;                               % Highpass cutoff frequency
hi = 50;                                % Lowpass cutoff frequency
[A,B,C,D] = butter(4,[lo hi]/(EEG.srate/2));
[sos,g] = ss2sos(A,B,C,D);

fprintf('\n Applying Bandpass filter...\n\n');
EEG.data = filtfilt(sos,g,EEG.data')';
fprintf('\n Done...\n\n');

dcaro_stacked(EEG)
title('EEG after Bandpass filter')

%__________________________________________________________________________
% 4. Common Average Reference
fprintf('\n Removing Common Average Reference...\n\n');
EEG = pop_reref(EEG,[],'exclude',[1 2]);
EEG.data = double(EEG.data);
fprintf('\n Done...\n\n');

dcaro_stacked(EEG)
title('EEG after CAR')

%%
EEG = Aura2eeglab('samples.csv');
dcaro_stacked(EEG)
