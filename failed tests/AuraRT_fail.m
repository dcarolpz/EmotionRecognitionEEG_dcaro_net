% Aura data pre-processing in real time
% by: Diego Caro López
% 16-Oct-2025

clear
clc
close all
fprintf('Starting LSL stream.\n')

chans = ["Fp1" "Fp2" "F3" "F4" "C3" "C4" "P3" "P4"];
fs = 250;
window_size = 20;
window = zeros(size(chans,2),8*fs*window_size);

% Initializing LSL library
lib = lsl_loadlib();

% Resolving stream
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end

% Opening inlet
inlet = lsl_inlet(result{1},[],size(window,2),0);
inlet.open_stream
inlet.set_postprocessing(15)

fprintf('\nSuccess.\nNow receiving data. -dcarolpz\n')
tic;
while true
    [chunk,stamps] = inlet.pull_chunk();
    if isempty(chunk) || size(chunk,2) > size(window,2)
        pause(0.05);
        continue
    else
        chunk2 = dcaro_aura_fix(chunk);
        break
    end
end
inlet.close_stream
inlet.delete

fprintf('\nWe have enough data.\n Stream stopped.\n')
dcaro_stacked(chunk2,'fs',fs,'labels',cellstr(chans))
