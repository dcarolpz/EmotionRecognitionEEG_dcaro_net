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
window = zeros(size(chans,2),fs*window_size);
times = zeros(1,fs*window_size);
start = 1;

% Initializing LSL library
lib = lsl_loadlib();

% Resolving stream
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end

% Opening inlet
inlet = lsl_inlet(result{1},5000,1,0);
inlet.open_stream
inlet.set_postprocessing(15)

fprintf('\nSuccess.\nNow receiving data. -dcarolpz\n')
tic;
while true
    [chunk,stamps] = inlet.pull_chunk();
    if isempty(chunk) || size(chunk,2) > size(window,2)
        continue
    end
    
    disp(size(chunk))
    if start + size(chunk,2)-1 > size(window,2)
        xtoc = toc;
        chunk = chunk(:,1:size(window,2)-start);
        stamps = stamps(1:size(window,2)-start);

        window(:,start:start+size(chunk,2)-1) = chunk;
        times(:,start:start+size(stamps,2)-1) = stamps;
        
        window2 = fix_ass_aura(window,xtoc); tic;
        fine_window(:,fine_start:fine_start+size(window2,2)-1) = window2;
        fine_start = fine_start + size(window2,2);

        if fine_start + size(window2) > size(fine_window,2)
            break
        end
    end

    window(:,start:start+size(chunk,2)-1) = chunk;
    times(start:start+size(stamps,2)-1) = stamps;
    start = start + size(chunk,2);

    pause(0.05);
end
inlet.close_stream
inlet.delete

fprintf('\nWe have enough data.\n Stream stopped.\n')
dcaro_stacked(fine_window,'fs',fs,'labels',cellstr(chans))

% window2 = fix_ass_aura(window,xtoc);
