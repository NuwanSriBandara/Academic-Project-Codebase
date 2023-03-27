%Nuwan Bandara - 180066F

clc; clear all; close all;

%% Preliminaries

load ABR_rec.mat

figure;
plot(ABR_rec);
title('EEG-based ABR response');
xlabel('Time (ms)');
ylabel('Amplitude (uV)');
legend('Stimuli','ABR train');
axis([1020000 1050000 -30 200]);

% Voltage threshold determination
thresh = find(ABR_rec(:,1)>50);

% Actual stimulus extraction
j=1;
for i=1:length(thresh)-1
if thresh(i+1)-thresh(i)>1; stim_point(j,1)=thresh(i+1); j=j+1;
end
end

% ABR epochs windowing according to the extracted stimulus points when the window length is 12ms
j = 0;
for i=1:length(stim_point) j = j + 1;
epochs(:,j) = ABR_rec((stim_point(i)-80:stim_point(i)+399),2);
end

% Ensemble average of all the extracted epochs
ensemble_avg = mean(epochs(:,(1:length(stim_point))),2);

% Ensemble averaged ABR waveform
figure;
plot((-80:399)/40,ensemble_avg);
xlabel('Time (ms)');
ylabel('Voltage (uV)');
title(['Ensemble averaged ABR from ',num2str(length(epochs)),' epochs']);

%% Improvement of SNR
[N,M] = size(epochs);
MSE_array = zeros(1,M);
for k = 1:M
    y_k = mean(epochs(:,1:k),2);
    MSE_array(k) = mean((ensemble_avg - y_k).^2);
end

% MSE array
figure;
plot(linspace(1,M,M),MSE_array);
xlabel('Epoch');
ylabel('MSE');
title(['MSE from ',num2str(M),' epochs']);

%% Signal with repetitive pattern
clc;
clear all;

load ECG_rec.mat

fs = 128;
T = 1000/fs;
t = (1:length(ECG_rec)).*T;

figure;
plot(t,ECG_rec);
dcm = datacursormode;
dcm.Enable = 'on';
xlabel('Time (ms)');
ylabel('Amplitude (mV)');
title('ECG signal');

% single PQRST waveform extractio
start = 2500; %experimentally decided through trial and error
finish = 3250;
ECG_template = ECG_rec(floor(start/T):floor(finish/T));
figure;
plot(t(floor(start/T):floor(finish/T)),ECG_template);
xlabel('Time (ms)');
ylabel('Amplitude (mV)');
title('Single PQRST waveform');

% Gaussian white noise addition to ECG
snr = 5;
nECG = awgn(ECG_rec,snr,'measured');
figure;
plot(t,ECG_rec,t,nECG);
title('ECG sequence with AWGN');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('Original ECG signal','ECG signal with AWGN');

%% Segmentation of ECG into separate epochs and ensemble averaging

% Cross-correlation between nECG and ECG_template
[c,lags] = xcorr(nECG,ECG_template);
time_lags = lags .* T;

figure;
plot(time_lags,c);
title('Cross-correlation between noisy ECG signal and ECG template');
ylabel('Cross-correlation');
xlabel('Lag (ms)');

% Segment ECG pulses by defining a threshold

% Starting points determination from the cross-correlation threshold
threshds = maxk(c,ceil(length(c)*0.05)); % list of highest cross-correlation 5% vals
thresh = find(c >threshds(end));

% Actual stimulus extraction
k = 1;
i = 1;
j =2;
while i < length(thresh)
    while j <= length(thresh)
        if (thresh(j)-thresh(i)>floor((finish-start)/T))
            start_point(k) = thresh(i);
            i = i+j;
            j = i+1;
            k = k+1;
        else
            j = j+1;
        end
    end
end
start_point(k+1) = thresh(end);

% ECG epochs in respective to the extracted stimulus points
% % Window length to be (finish-start) in ms
n = 1;
m = 1;
while n <= length(start_point)
p = start_point(n)+1;
if (p == 0)
    p = 1;
elseif (p>length(nECG))
    p = p - length(nECG);
end
if (p < length(nECG)-floor((finish-start)/T))
    epochs(:,m) = nECG(p:p+floor((finish-start)/T));
    m = m+1;
end
n = n+1;
end

[N,M] = size(epochs);
ensemble_avg = mean(epochs(:,(1:M)),2);

% SNR improvement using cross-correlation coefficient method
MSE_array = zeros(1,M);
for k = 1:M
    y_k = mean(epochs(:,1:k),2);
    MSE_array(k) = mean((ensemble_avg - y_k).^2);
end

figure;
plot(linspace(1,M,M),MSE_array);
xlabel('Epoch');
ylabel('MSE');
title(['MSE from ',num2str(M),' epochs for noisy ECG using maximum cross-correlation']);

% Selected noisy ECG pulse and two arbitrary selcted ensemble averaged ECG pulses
noisy_ECG_template = nECG(floor(start/T):floor(finish/T));
p = randi([1 M],1,2);
selected_Temp1 = transpose(epochs(:,p(1)));
selected_Temp2 = transpose(epochs(:,p(2)));
t_temp = linspace(0,length(noisy_ECG_template)*T,length(noisy_ECG_template));

figure;
plot(t_temp,noisy_ECG_template,t_temp,selected_Temp1,t_temp,selected_Temp2);
title('Selected ECG sequences with noise with respect to the maximum correlation method');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('Noisy ECG Template','Arbitrary Epoch 1','Arbitrary Epoch 2');


% Segmentation of ECG pulses suing a defined threshold

% Determination of starting points from the R-val threshold
thresh_R = find(nECG >max(ECG_template)*0.95); % Setting a threshold as 5% less than max R of  ECG template
RR_Interval = 750; % Determined by experimental observation

% Actual stimulus extraction
k = 1;
i = 1;
j =2;
while i < length(thresh_R)
    while j <= length(thresh_R)
        if (thresh_R(j)-thresh_R(i)>floor(RR_Interval/T))
            start_pointR(k) = thresh_R(i);
            i = i+j;
            j = i+1;
            k = k+1;
        else
            j = j+1;
        end
    end
end
start_pointR(k+1) = thresh_R(end);

% ECG epochs in accordance to to the extracted stimulus points. Window length to be (finish-start) in ms
PR_interval = 351.56;   % Through experimental observation
n = 1;
m = 1;
while n <= length(start_pointR)
p = start_pointR(n)+1;
if (p == 0)
    p = 1;
elseif (p>length(nECG))
    p = p - length(nECG);
end
if ((p < length(nECG)+floor(PR_interval/T)-length(ECG_template)) && (p>floor(PR_interval/T)))
    epochs_R(:,m) = nECG(p-floor(PR_interval/T):p-1-floor(PR_interval/T)+length(ECG_template));
    m = m+1;
end
n = n+1;
end

[N,M] = size(epochs_R);

ensembl_avgR = mean(epochs_R(:,(1:M)),2);

% SNR Improvement with respect to R peak method
MSE_array_R = zeros(1,M);
for k = 1:M
    y_k = mean(epochs_R(:,1:k),2);
    MSE_array_R(k) = mean((ensembl_avgR - y_k).^2);
end

figure;
plot(linspace(1,M,M),MSE_array_R);
xlabel('Epoch');
ylabel('MSE');
title(['MSE from ',num2str(M),' epochs for noisy ECG signal using R thresholds']);

% Selected noisy ECG pulse and the arbitrary selected ensemble averaged ECG pulses
p = randi([1 M],1,2);
selected_Temp1 = transpose(epochs_R(:,p(1)));
selected_Temp2 = transpose(epochs_R(:,p(2)));
t_temp = linspace(0,length(noisy_ECG_template)*T,length(noisy_ECG_template));
figure;
plot(t_temp,noisy_ECG_template,t_temp,selected_Temp1,t_temp,selected_Temp2);
title('The selected ECG sequences (with noise) in the peak detection method');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('Noisy ECG Template','Arbitrary Epoch 1','Arbitrary Epoch 2');
