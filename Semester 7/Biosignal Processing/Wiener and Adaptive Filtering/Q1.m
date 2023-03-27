%author - Nuwan Bandara 180066F
clc;
clear all;

load('idealECG.mat');   % load the ideal ECG signal

ideal_ecg = idealECG - mean(idealECG); %mean to zero transformation
fs = 500;               % sampling frequency 500 Hz
len = length(ideal_ecg);
time  = linspace(0, len-1, len)*(1/fs);

% noise addition
n_awgn = awgn(ideal_ecg, 10, 'measured'); % Gaussian white noise addition of 10dB

n_50 = 0.2*sin(2*pi*50*time); % Sinusoidal 50Hz noise manipulation

noisy_ECG = n_awgn + n_50; % Addition of sinusoidal noise to the Gaussian noise added ECG signal

% plotting the noisy ECG signals
figure('Name','Ideal ECG signal (without noise)'),
plot(time, ideal_ecg);
title('Ideal ECG signal (without noise)'), xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name','Ideal ECG signal (without noise)'),
plot(time(3000: 4000), ideal_ecg(3000:4000));
title('Ideal ECG signal (without noise) - zoomed'), xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name','Noisy ECG signal (with Gaussian and sinusoidal noise)'),
plot(time, noisy_ECG);
title('Noisy ECG signal (with Gaussian and sinusoidal noise)'), xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name','Noisy ECG signal (with Gaussian and sinusoidal noise)'),
plot(time(3000:4000), noisy_ECG(3000:4000));
title('Noisy ECG signal (with Gaussian and sinusoidal noise) - zoomed'), xlabel('Time (s)'), ylabel('Amplitude (mV)');


%% Part 1

% The desired signal from extracting the ECG pulse from the ideal ECG signal
single_beat_t = 1.876*fs : 2.043*fs; %84 sample length
yi = ideal_ecg(single_beat_t);
n = time(single_beat_t);

% noisy signal extraction from the T wave to P wave
noise_t = 2.032*fs : 2.072*fs; %21 sample length
noisy_sig = noisy_ECG(noise_t);
noise_n = time(noise_t);
noise_estimated = [noisy_sig noisy_sig noisy_sig noisy_sig]; % Replication of 4 times to make noisy signal with same size as desired signal

% plotting the extracted desired ECG signal and the noisy ECG signal
figure('Name','Extracted ECG Single Beat and Noisy Estimate from T wave to P wave')

subplot(1,3,1)
plot(n,yi)
xlim([n(1),n(end)])
title('Extracted ECG Beat from the desired signal'), xlabel('Time (s)'), ylabel('Amplitude (mV)')

subplot(1,3,2)
plot(linspace(1,21,21),noisy_sig,'r')
title('Isoelectric ECG Segment with noise'), xlabel('Time (s)'), ylabel('Amplitude (mV)');

subplot(1,3,3)
plot(linspace(1,84,84),noise_estimated,'k')
title('Isoelectric ECG Segment with noise (with replication)'), xlabel('Time (s)'), ylabel('Amplitude (mV)');

% With an arbitary filter order
order = 18; %arbitrarily selected
noise_added = noisy_ECG - ideal_ecg;

weight_mat = weiner_weight_vector(yi, noise_estimated, order);    % Weight matrix
disp(weight_mat');

y_hat = Weiner_filter(noisy_ECG, weight_mat); % filter the signal using Wiener weight matrix

figure('Name', 'Weiner Filtering for Arbitarily selpected order = 18')
plot(time, ideal_ecg, time, noisy_ECG, time, y_hat)
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG with order = 18')
title('Weiner Filtering of a noisy ECG signal with M = 18')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name', 'Weiner Filtering for Arbitarily selpected order = 18')
plot(time(3000:4000), ideal_ecg(3000:4000), time(3000:4000), noisy_ECG(3000:4000), time(3000:4000), y_hat(3000:4000))
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG with order = 18')
title('Weiner Filtering of a noisy ECG signal with M = 18 - zoomed')
xlabel('Time (s)'), ylabel('Amplitude (mV)');


% Find Optimum filter order and the coefficients for Wiener method
order_range = 50;
MSE_mat = NaN(1,order_range);

for order = 2: order_range
    weight_mat = weiner_weight_vector(yi, noise_estimated, order);
    y_hat = Weiner_filter(noisy_ECG(single_beat_t),weight_mat); 
    MSE_mat(order) = immse(y_hat, ideal_ecg(single_beat_t));
end

figure('Name','MSE of different order Wiener filters vs Filter Order')
plot(MSE_mat)
hold on 
[min_MSE,min_ord] = min(MSE_mat);
scatter(min_ord, min_MSE)
title('MSE of different order Wiener filters vs Filter Order')
xlabel('Filter Order'), ylabel('MSE');

% Optimum Order
optimal_order = min_ord;
optimal_weight_mat = weiner_weight_vector(yi, noise_estimated, optimal_order);
disp(optimal_weight_mat);
optimal_y_hat = Weiner_filter(noisy_ECG, optimal_weight_mat);

figure('Name', 'Optimum ordered Wiener filter')
plot(time, ideal_ecg, time, noisy_ECG, time, optimal_y_hat)
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG with optimum order')
title('Weiner Filtering of noisy ECG with optimum order')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name', 'Optimum ordered Wiener filter')
plot(time(3000:4000), ideal_ecg(3000:4000), time(3000:4000), noisy_ECG(3000:4000), time(3000:4000), optimal_y_hat(3000:4000))
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG with optimum order')
title('Weiner Filtering of noisy ECG with optimum order - zoomed')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

% Filter characteristics using fvtool
fvtool(optimal_weight_mat,1)

% The spectrum analysis
[Px_noisy_signal, F1_noisy_sig] = periodogram(noisy_ECG, [], [], fs);
[Px_noise,F2_noise] = periodogram(noise_added, [], [], fs);
[Px_ideal,F3_ideal] = periodogram(ideal_ecg, [], [], fs);
[Px_y_hat,F4_y_hat] = periodogram(optimal_y_hat, [], [], fs);

figure('Name','PSD of signals')
semilogy(F1_noisy_sig, Px_noisy_signal, F2_noise, Px_noise, F3_ideal, Px_ideal, F4_y_hat, Px_y_hat);
legend('Noisy ECG signal','Noise','Desired signal','Optimum Wiener-filtered signal')
title('Power Spectral Density'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

figure('Name','PSD of signals')
semilogy(F1_noisy_sig(500:3500), Px_noisy_signal(500:3500), F2_noise(500:3500), Px_noise(500:3500), F3_ideal(500:3500), Px_ideal(500:3500), F4_y_hat(500:3500), Px_y_hat(500:3500));
legend('Noisy ECG signal','Noise','Desired signal','Optimum Wiener-filtered signal')
title('Power Spectral Density - zoomed'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

%% Part 2 

figure('Name','Extracted ECG Single Beat');
plot(linspace(1,84,84), yi)
xlim([0,84])
title('Extracted ECG Beat'), xlabel('Sample'), ylabel('Amplitude (mV)')

% Linear model of an ECG signal beat
linear_signal = zeros(1,84);
for i = 1: length(yi) %the domains and the gradients are experimentally decided
    if i > 79
        linear_signal(i) = 0;
    elseif i > 70 
        linear_signal(i) = ((0.211062+0.108938) - (0))*(i - 79)/(70 - 79) + (0);  
    elseif i > 68
        linear_signal(i) = (0.211062+0.108938);
    elseif i > 55
        linear_signal(i) = ((0.211062+0.108938) - (0))*(i - 55)/(68 - 55) + (0);  
    elseif i > 40
        linear_signal(i) = 0;
    elseif i > 37
        linear_signal(i) = (0 - (-0.548938))*(i - 37)/(40 - 37) + (-0.548938);
    elseif i > 34
        linear_signal(i) = (1.83106 - (-0.548938))*(i - 37)/(34 - 37) + (-0.548938);
    elseif i > 30 
        linear_signal(i) = (1.83106 - (-0.398938))*(i - 30)/(34 - 30) + (-0.398938);
    elseif i > 28
        linear_signal(i) = ((0) - (-0.398938))*(i - 30)/(28 - 30) + (-0.398938);
    elseif i > 16
        linear_signal(i) = 0;
    elseif i > 12
        linear_signal(i) = ((0.0110618+0.128938) - (0))*(i - 16)/(12 - 16) + (0);
    elseif i > 11
        linear_signal(i) = (0.0110618+0.128938);
    elseif i > 8 
        linear_signal(i) = ((0.0110618+0.128938) - (0))*(i - 8)/(11 - 8) + (0);
    else
        linear_signal(i) = 0;
    end
end

linear_signal = linear_signal + ones(1,84)*0.001;
figure('Name','Linear Model of an ECG single beat');
plot(linspace(1,84,84), linear_signal)
xlim([0,84])
title('Linearly modelled ECG Beat'), xlabel('Sample'), ylabel('Amplitude (mV)')

% Arbitary ordered Wiener filter
order = 18;
noise_added = noisy_ECG-ideal_ecg;
weight_mat = weiner_weight_vector(linear_signal, noise_estimated, order);   % Wiener weight matrix
disp(weight_mat');

y_hat = Weiner_filter(noisy_ECG, weight_mat); % filter the signal using Wiener weight matrix

figure('Name', 'Weiner Filtering of arbitary order = 18 for ECG signal')
plot(time, ideal_ecg, time, noisy_ECG, time, y_hat)
legend('Ideal ECG','Noisy ECG','Linear Modelled ECG signal filtered by a Weiner Filter with order = 18')
title('Weiner Filtering of arbitary order = 18 for noisy ECG signal')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name', 'Weiner Filtering of arbitary order = 18 for ECG signal')
plot(time(3000:4000), ideal_ecg(3000:4000), time(3000:4000), noisy_ECG(3000:4000), time(3000:4000), y_hat(3000:4000))
legend('Ideal ECG','Noisy ECG','Linear Modelled ECG signal filtered by a Weiner Filter with order = 18')
title('Weiner Filtering of arbitary order = 18 for noisy ECG signal - zoomed')
xlabel('Time (s)'), ylabel('Amplitude (mV)');


% Find Optimum filter order and the coefficients for Wiener method
order_range = 50;
MSE_mat = NaN(1,order_range);

for order = 2: order_range
    weight_mat = weiner_weight_vector(linear_signal, noise_estimated, order);
    y_hat = Weiner_filter(noisy_ECG(single_beat_t),weight_mat); 
    MSE_mat(order) = immse(y_hat, ideal_ecg(single_beat_t));
end

figure('Name','MSE of different order Wiener filters vs Filter Order | linear modelled ECG')
plot(MSE_mat)
hold on 
[min_MSE,min_ord] = min(MSE_mat);
scatter(min_ord, min_MSE)
title('MSE of different order Wiener filters vs Filter Order | linear modelled ECG')
xlabel('Filter Order'), ylabel('MSE');

% Optimum order
optimal_order = min_ord;
optimal_weight_mat = weiner_weight_vector(linear_signal, noise_estimated, optimal_order);
optimal_y_hat = Weiner_filter(noisy_ECG, optimal_weight_mat);

figure('Name', 'Optimum ordered Wiener filter | linear modelled ECG')
plot(time, ideal_ecg, time, noisy_ECG, time, optimal_y_hat)
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG with optimum order | linear modelled ECG')
title('Weiner Filtering of noisy ECG with optimum order | linear modelled ECG')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name', 'Optimum ordered Wiener filter | linear modelled ECG')
plot(time(3000:4000), ideal_ecg(3000:4000), time(3000:4000), noisy_ECG(3000:4000), time(3000:4000), optimal_y_hat(3000:4000))
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG with optimum order | linear modelled ECG')
title('Weiner Filtering of noisy ECG with optimum order | linear modelled ECG - zoomed')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

% Filter characteristics using fvtool
fvtool(optimal_weight_mat,1)

% Spectrum analysis
[Px_noisy_signal, F1_noisy_sig] = periodogram(noisy_ECG, [], [], fs);
[Px_noise,F2_noise] = periodogram(noise_added, [], [], fs);
[Px_ideal,F3_ideal] = periodogram(ideal_ecg, [], [], fs);
[Px_y_hat,F4_y_hat] = periodogram(optimal_y_hat, [], [], fs);

figure('Name','PSD of signals')
semilogy(F1_noisy_sig, Px_noisy_signal, F2_noise, Px_noise, F3_ideal, Px_ideal, F4_y_hat, Px_y_hat);
legend('Noisy ECG signal','Noise','Desired signal','Optimum Wiener filtered signal')
title('Power Spectral Density'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

figure('Name','PSD of signals')
semilogy(F1_noisy_sig(500:3500), Px_noisy_signal(500:3500), F2_noise(500:3500), Px_noise(500:3500), F3_ideal(500:3500), Px_ideal(500:3500), F4_y_hat(500:3500), Px_y_hat(500:3500));
legend('Noisy ECG signal','Noise','Desired signal','Optimum Wiener filtered signal')
title('Power Spectral Density - zoomed'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

%% 1.2 Freq Derivation

[y_hat_freq, W_f] = weiner_filter_frequency_domain(ideal_ecg, noise_added, noisy_ECG);
figure('Name', 'Weiner Filtering in frequency domain')
plot(time, ideal_ecg, time, noisy_ECG, time, y_hat_freq)
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG in frequency domain')
title('Weiner Filtering in frequency domain'),
xlabel('Time (s)'),ylabel('Amplitude (mV)');

figure('Name', 'Weiner Filtering in frequency domain')
plot(time(3000:4000), ideal_ecg(3000:4000), time(3000:4000), noisy_ECG(3000:4000), time(3000:4000), y_hat_freq(3000:4000))
legend('Ideal ECG','Noisy ECG','Weiner Filtered ECG in frequency domain')
title('Weiner Filtering in frequency domain - zoomed'),
xlabel('Time (s)'),ylabel('Amplitude (mV)');

% Plotting the spectrum
[Px_noisy_signal, F1_noisy_sig] = periodogram(noisy_ECG, [], [], fs);
[Px_noise,F2_noise] = periodogram(noise_added, [], [], fs);
[Px_ideal,F3_ideal] = periodogram(ideal_ecg, [], [], fs);
[Px_yhat_freq, F4_yhat_freq] = periodogram(y_hat_freq, [], [], fs);

figure('Name','PSD Weiner Filter in frequency domain')
semilogy(F1_noisy_sig, Px_noisy_signal, F2_noise, Px_noise, F3_ideal, Px_ideal, F4_yhat_freq, Px_yhat_freq);
legend('Noisy signal','Noise','Desired signal','Frequency-domain Wiener Filtered Signal')
title('Power Spectral Density'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

figure('Name','PSD Weiner Filter in frequency domain')
semilogy(F1_noisy_sig(500:3500), Px_noisy_signal(500:3500), F2_noise(500:3500), Px_noise(500:3500), F3_ideal(500:3500), Px_ideal(500:3500), F4_yhat_freq(500:3500), Px_yhat_freq(500:3500));
legend('Noisy signal','Noise','Desired signal','Frequency-domain Wiener Filtered Signal')
title('Power Spectral Density - zoomed'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

%% Comparison of frequency-domain and time-domain weiner filtering

figure('Name', 'Comparing Frequency domain and Time domain weiner filter')
plot(time, ideal_ecg, 'b', time, optimal_y_hat,'g', time, y_hat_freq, 'r')
legend('Ideal ECG','Through optimum time-domain derived Weiner filering', 'Through frequency-domain Weiner filtering')
title('Comparison of frequency-domain and time-domain weiner filters')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

figure('Name', 'Comparing Frequency domain and Time domain weiner filter')
plot(time(3000:4000), ideal_ecg(3000:4000), 'b', time(3000:4000), optimal_y_hat(3000:4000),'g', time(3000:4000), y_hat_freq(3000:4000), 'r')
legend('Ideal ECG','Through optimum time-domain derived Weiner filering', 'Through frequency-domain Weiner filtering')
title('Comparison of frequency-domain and time-domain weiner filters - zoomed')
xlabel('Time (s)'), ylabel('Amplitude (mV)');

% comparison of MSEs between two methods
mse_time = immse(optimal_y_hat, ideal_ecg);
mse_freq = immse(y_hat_freq, ideal_ecg);
disp('Time-domain MSE');
disp(mse_time);
disp('Frequency-domain MSE');
disp(mse_freq);


%% 1.3 Effect on non-stationary noise on the Wiener filtering

% For adding two sinusoidal noises to the desired signal as non-stationary
f1 = 50;
f2 = 100;

time_p1 = time(1 : floor(length(time)/2));
time_p2 = time(floor(length(time)/ 2) + 1 : end);

n50_p1 = 0.2*sin(2*pi*f1*time_p1);
n100_p1 = 0.3*sin(2*pi*f2*time_p2);

non_stationary_noise = [n50_p1 n100_p1];
non_stationary_noisy_sig = n_awgn + non_stationary_noise;

% ECG signal with non-stationary noise to be filtered by the derived frequency-domain Weiner filter

N = length(non_stationary_noisy_sig);  
S_Xf  = fft(non_stationary_noisy_sig, N*2-1);
S_Yhat = W_f.* S_Xf;                    % Estimation of the desired signal from observation and using Wiener filter
y_hat_time = ifft(S_Yhat);              % Inverse discrete Fourier to convert into time-domain
y_hat_non_stationary = y_hat_time(1 : N);

figure('Name','Comparison of the effect of Non-stationary noise vs stationary noise')
plot(time, ideal_ecg, time, y_hat_non_stationary, time, y_hat_freq)
xlim([time(1),time(end)])
legend('Ideal ECG','Non-stationary noise - Filtered by the freq. domain Wiener filter','Stationary noise - Filtered')
title('Comparison of the effect of Non-stationary noise after filtering with Frequency domain Wiener')
xlabel('Time (s)'), ylabel('Amplitude (mV)')

figure('Name','Comparison of the effect of Non-stationary noise vs stationary noise')
plot(time(3500:4500), ideal_ecg(3500:4500), time(3500:4500), y_hat_non_stationary(3500:4500), time(3500:4500), y_hat_freq(3500:4500))
%xlim([time(1),time(end)])
legend('Ideal ECG','Non-stationary noise - Filtered by the freq. domain Wiener filter','Stationary noise - Filtered')
title('Comparison of the effect of Non-stationary noise after filtering with Frequency domain Wiener - zoomed')
xlabel('Time (s)'), ylabel('Amplitude (mV)')

noise_added = non_stationary_noisy_sig - ideal_ecg;

[Px_noisy_signal, F1_noisy_sig] = periodogram(non_stationary_noisy_sig, [], [], fs);
[Px_noise,F2_noise] = periodogram(noise_added, [], [], fs);
[Px_ideal,F3_ideal] = periodogram(ideal_ecg, [], [], fs);
[Px_y_hat_freq_ns, F4_y_hat_freq_ns] = periodogram(y_hat_non_stationary, [], [], fs);

figure('Name','PSD of Weiner Filtered (frequency-domain) ECG signal with Non-stationary noise')
semilogy(F1_noisy_sig, Px_noisy_signal, F2_noise, Px_noise, F3_ideal, Px_ideal, F4_y_hat_freq_ns, Px_y_hat_freq_ns);
legend('Non-stationary noisy ECG ignal','Non-Stationary noise','Desired signal','Frequency-domain Wiener filtered ECG signal')
title('Power Spectral Density applied on the ECG signal with Non-Stationary noise'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

figure('Name','PSD of Weiner Filtered (frequency-domain) ECG signal with Non-stationary noise')
semilogy(F1_noisy_sig(500:3500), Px_noisy_signal(500:3500), F2_noise(500:3500), Px_noise(500:3500), F3_ideal(500:3500), Px_ideal(500:3500), F4_y_hat_freq_ns(500:3500), Px_y_hat_freq_ns(500:3500));
legend('Non-stationary noisy ECG ignal','Non-Stationary noise','Desired signal','Frequency-domain Wiener filtered ECG signal')
title('Power Spectral Density applied on the ECG signal with Non-Stationary noise - zoomed'),xlabel('Frequency (Hz)'),ylabel('dB/Hz');

%% functions

function W = weiner_weight_vector(y, n_est, order)
    yyT = 0; % Autocorrelation
    nnT = 0;
    
    Yy = 0; % Cross-correlation

    y_mat = zeros(order,1);
    n_mat = zeros(order,1);
    len = length(y);

    for i=1:len
        y_mat(1) = y(i); 
        n_mat(1) = n_est(i);

        yyT = yyT + toeplitz(autocorr(y_mat, order-1));
        nnT = nnT + toeplitz(autocorr(n_mat, order-1));

        Yy = Yy + y_mat*y(i);

        % shifting the delay 
        y_mat(2:order) = y_mat(1 : order-1);
        n_mat(2:order) = n_mat(1 : order-1);
    end

    yyT = yyT.*mean(y.^2);
    nnT = nnT.*mean(n_est.^2);

    autocorr_Y = yyT./ (len - order);
    autocorr_N = nnT./ (len - order);
    theta_Yy = Yy./ (len-order);
    
    autocorr_X = autocorr_Y + autocorr_N;
    W = autocorr_X\theta_Yy;
end

function y_hat = Weiner_filter(signal, weight_mat)
    order = length(weight_mat);
    y_hat = signal;
    for i = 1: length(signal) - order % convolution
        y_hat(i) = signal(i : i + order - 1) * weight_mat;
    end
end

function [y_hat, W_f] = weiner_filter_frequency_domain(template, noise, signal)

    N = length(signal);               % Since of the same size of all FFTs
    
    S_yy = abs(fft(template,N*2-1)).^2;  % Power of template
    S_NN = abs(fft(noise,N*2-1)).^2;     % Power of noise
    S_Xf  = fft(signal,N*2-1);           % Discrete FT of the signal
    
    W_f = S_yy./(S_yy + S_NN);          % Frequency-domain Wiener filter 
    S_Yhat = W_f.*S_Xf;                 % Estimation of the signal from observation and using Wiener filter
    
    y_hat_time = (ifft(S_Yhat));            % time domain using inverse discrete Fourier transform
    y_hat = y_hat_time(1: length(signal));   % To have two-sided FFT

end



