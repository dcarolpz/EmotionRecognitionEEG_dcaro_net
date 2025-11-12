% Fixing data received from Aura LSL
% This is an ECG signal from myself
% by: dcaro
% last edited: 22-0ct-2025

%% This didn't work
clear
clc
close all
load('raw_aura.mat')
fs = 250;
jumped = 0;

stamps3 = zeros(size(stamps2));

for i = 1:size(stamps2,2) - 1
    if jumped
        jumped = jumped - 1;
        continue
    end

    ii = i+1;
    current = stamps2(i);
    next = stamps2(ii);

    while round((next - current),3) < 1/fs
        try
            next = stamps2(ii + 1);
            ii = ii + 1;
            jumped = jumped + 1;
        catch
            break
        end
    end

    stamps3(i+1) = next;
end

empty = stamps3==0;
stamps3 = stamps3(~empty);
chunk2 = chunk(:,~empty);

%% 2nd attempt
clear
clc
close all

% Building target signal
ecg = Aura2eeglab('dcaro_ecg.csv');
[b,a] = butter(4,1/(250/2),'high');
ecg.data = filtfilt(b,a,ecg.data')';
[b,a] = butter(4,50/(250/2));
ecg.data = -filtfilt(b,a,ecg.data')';
[b,a] = butter(4,[59 61]/(250/2),'stop');
ecg.data = filtfilt(b,a,ecg.data')';
dcaro_stacked(ecg,'scale',2000,'win',[1 10])
title('Target signal')

% Now trying with Raw Aura from LSL
load('raw_aura.mat')
figure
hold on
pspectrum(stamps2)
pspectrum(chunk(1,:))
xline(0.25,'--r','LineWidth',2)
xline(0.5,'--r','LineWidth',2)
xline(0.75,'--r','LineWidth',2)
xline(0.125,'--b')
xline(0.375,'--b')
xline(0.625,'--b')
xline(0.875,'--b')
hold off
% Noticing a pattern huh?

% n = round(size(chunk,2)/8);
% y = fft(chunk(1,:));
% y = y(1:n);
% x = abs(ifft(y));
% [b,a] = butter(2,1/(250/2),'high');
% x = filtfilt(b,a,x);
% [b,a] = butter(2,50/(250/2));
% x = filtfilt(b,a,x);
% [b,a] = butter(2,[59 61]/(250/2),'stop');
% x = filtfilt(b,a,x);

n = round(size(chunk,2)/8);
chunk2 = zeros(1,size(chunk,2)/8);
for i = 1:size(chunk,1)
    y = fft(chunk(i,:));
    y = y(1:n);
    x = abs(ifft(y));
    [b,a] = butter(2,1/(250/2),'high');
    x = filtfilt(b,a,x);
    [b,a] = butter(2,50/(250/2));
    x = filtfilt(b,a,x);
    [b,a] = butter(2,[59 61]/(250/2),'stop');
    x = filtfilt(b,a,x);
    chunk2(i,:) = x/4;
end
dcaro_stacked(chunk2,'fs',250,'win',[1 10],'scale',2000)
title('Reconstructed signal')
