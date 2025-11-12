% DWT & ANC to remove OA from EEG
% by: dcaro
% OG paper: https://doi.org/10.1109/JBHI.2013.2253614
% last edited: 20-Oct-2025

clear
clc
close all

% EEG = load('EEG_raw.mat');
% EEG = EEG.EEG_raw;
% EEG = pop_select(EEG,'time',[30 35]);

EEG = Aura2eeglab('samples.csv');
[c,l] = wavedec(EEG.data(1,:),7,'db4');
D = detcoef(c,l,1:7);
A7 = appcoef(c,l,'db4',7);

T = zeros(1,7);
D2 = D;
for i = 1:7
    sj = median(abs(D{i}-median(D{i})))/0.6745; 
    % T(i) = sqrt(2*log(length(D{i}))) * median(abs(D{i})) / 0.6745;
    T(i) = sj*sqrt(2*log(length(c)));
    if i < 4 
        D2{i} = wthresh(D{i},'s',T(i));
    else
        continue
    end
end

c2 = [A7 flip(cell2mat(cellfun(@flip,D2,'UniformOutput',false)))];
ref = waverec(c2,l,'db4');

figure
plot(EEG.data(1,:))
hold on
plot(ref)

%% 
clear
clc
close all
load('Cal_581.mat')

fs = 250;
lo = 0.1;                               % Highpass cutoff frequency
hi = 50;                                % Lowpass cutoff frequency
[A,B,C,D] = butter(2,[lo hi]/(fs/2));
[sos,g] = ss2sos(A,B,C,D);
x = filtfilt(sos,g,my_window')';
clearvars -except x fs

% Start DWT to obtain Reference Signal
[c,l] = wavedec(x(1,:),7,'db4');
D = detcoef(c,l,1:7);
A7 = appcoef(c,l,'db4',7);

T = zeros(1,7);
D2 = D;
for i = 1:7
    sj = median(abs(D{i}-median(D{i})))/0.6745; 
    T(i) = sj*sqrt(2*log(length(c)));
    if i < 4 
        D2{i} = wthresh(D{i},'s',T(i));
    else
        continue
    end
end

c2 = [A7 flip(cell2mat(cellfun(@flip,D2,'UniformOutput',false)))];
ref = waverec(c2,l,'db4');

figure
plot(x(1,:))
hold on
plot(ref)
plot(x(1,:)-ref)

%% ANC part (RLS)

d = x(1,:);
e = zeros(size(d));
Pi = zeros(1,size(ref,2));
P = 1e4;
lambda = 0.98;
w = 1;
for k = 1:size(ref,2)
    Pi(k) = ref(k)*P;
    
    g = Pi(k)/(lambda + Pi(k).*P);
    y = w*ref(k);
    
    e(k) = d(k) - y;
    
    w = w + g*e(k);
    P = (P - g*Pi(k))/lambda;
end

figure
hold on
plot(x(1,:))
plot(ref)
plot(e)
legend('Original EEG','Reference Signal','Denoised EEG')
