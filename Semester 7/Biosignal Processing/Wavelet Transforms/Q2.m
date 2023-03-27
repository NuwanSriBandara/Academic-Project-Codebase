% author : Nuwan Bandara (180066F)

clearvars; close all; clc;

fs = 512;   % sampling frequency

%% x1 waveform construction
n1 = 0:1:512;
n2 = 513:1:1023;
x1_1 = 2*sin(20*pi*n1/fs) + sin(80*pi*n1/fs);
x1_2 = 0.5*sin(40*pi*n2/fs) + sin(60*pi*n2/fs);
x1 = [x1_1 x1_2];

figure('Name', 'x1[n] signal for DWT');
plot([n1 n2], x1);
xlim([0 1024]);
title('x1 waveform'), xlabel('Time (s)'), ylabel('Amplitude');

%%  x2 waveform construction
x2 = zeros(1, 1024);
for j = 1:1024
    i = j -1;
    if i >= 960
        x2(j) = 0;
    elseif i >= 704
        x2(j) = 1;
    elseif i >= 512
        x2(j) = 3;
    elseif i >= 256
        x2(j) = -1;
    elseif i >= 192
        x2(j) = 2;
    elseif i >= 64
        x2(j) = 0;
    elseif i >= 0
        x2(j) = 1;
    end
end

figure('Name', 'x2[n] signal for DWT');
plot(x2);
axis([0 1024 -1.5 3.5]);
title('x2 waveform'), xlabel('Time (s)'), ylabel('Amplitude');

y1 = awgn(x1, 10,'measured');   % Addition of white gaussian noise
y2 = awgn(x2, 10,'measured');

figure('Name', 'x1 waveforms with (y1) or without noise (x1)');
plot([n1 n2], x1, [n1 n2], y1);
xlim([0 1024]);
legend('x1 waveform without noise', 'y1 noisy waveform'),
title('x1 waveforms with (y1) or without noise (x1)'), xlabel('Time (s)'), ylabel('Amplitude');

n2 = 0:1:1023;
figure('Name', 'x2 waveforms with (y2) or without noise (x2)');
plot(n2, x2, n2, y2);
axis([0 1024 -3.5 4.5]);
legend('x2 waveform without noise', 'y2 noisy waveform'),
title('x2 waveforms with (y2) or without noise (x2)'), xlabel('Time (s)'), ylabel('Amplitude');

%% Morphology observation of Haar and Daubechies tap 9 (db9) using wavefun()

wavlt = 'haar'; % Harr wavelet
[phi_haar, psi_haar, xval_haar] = wavefun(wavlt, 10); 
figure ('Name','Haar Wavelet')
subplot(1,2,1);
plot(xval_haar, psi_haar, 'blue');
title('Wavelet function of Haar wavelet');
subplot(1,2,2);
plot(xval_haar, phi_haar, 'red');
title('Scaling function of Haar wavelet');

wavlt = 'db9'; % Daubechies tap 9 (db9) wavelet
[phi_deb,psi_deb, xval_deb] = wavefun(wavlt, 10); 
figure  ('Name','Daubechies tap-9 Wavelet')
subplot(1,2,1);
plot(xval_deb, psi_deb,'blue');
title('Wavelet function of Daubechies tap 9 wavelet');
subplot(1,2,2);
plot(xval_deb, phi_deb, 'red');
title('Scaling function of Daubechies tap 9 wavelet');

%% 10-level dyadic wavelet decomposition

% y1 with Haar wavelet
[c_haar_1, l_haar_1] = wavedec(y1, 10, 'haar');
approx_haar_1 = appcoef(c_haar_1, l_haar_1, 'haar');
[hd1,hd2,hd3,hd4,hd5,hd6,hd7,hd8,hd9,hd10] = detcoef(c_haar_1, l_haar_1, [1 2 3 4 5 6 7 8 9 10]);

figure('Name', 'y1[n] decomposition using Haar wavelet');
for i= 1:10
    haar_decom = detcoef(c_haar_1, l_haar_1, i);
    subplot(11,1,i);
    stem(haar_decom,'Marker','.');
    title(['Level ' num2str(i) ' dyadic decomposition of y1[n] using Haar wavelet']);
end
subplot(11,1,11);
stem(approx_haar_1);
title(['Level ' num2str(10) ' dyadic approximation coefficients']);

% y1 with db9 wavelet
[c_db_1, l_db_1] = wavedec(y1, 10, 'db9');
approx_db_1 = appcoef(c_db_1, l_db_1, 'db9');
[dbd1,dbd2,dbd3,dbd4,dbd5,dbd6,dbd7,dbd8,dbd9,dbd10] = detcoef(c_db_1, l_db_1, [1 2 3 4 5 6 7 8 9 10]);

figure('Name', 'y1[n] decomposition using db9 wavelet');
for i= 1:10
    db_decom = detcoef(c_db_1, l_db_1, i);
    subplot(11,1,i);
    stem(db_decom,'Marker','.');
    title(['Level ' num2str(i) ' dyadic decomposition of y1[n] using db9 wavelet']);
end
subplot(11,1,11);
stem(approx_db_1);
title(['Level ' num2str(10) ' dyadic approximation coefficients']);

% y2 with Haar wavelet
[c_haar_2, l_haar_2] = wavedec(y2, 10, 'haar');
approx_haar_2 = appcoef(c_haar_2, l_haar_2, 'haar');
[hd1_2,hd2_2,hd3_2,hd4_2,hd5_2,hd6_2,hd7_2,hd8_2,hd9_2,hd10_2] = detcoef(c_haar_2, l_haar_2, [1 2 3 4 5 6 7 8 9 10]);

figure('Name', 'y2[n] decomposition using Haar wavelet');
for i= 1:10
    haar_decom = detcoef(c_haar_2, l_haar_2, i);
    subplot(11,1,i);
    stem(haar_decom,'Marker','.');
    title(['Level ' num2str(i) ' dyadic decomposition of y2[n] using Haar wavelet']);
end
subplot(11,1,11);
stem(approx_haar_2);
title(['Level ' num2str(10) ' dyadic approximation coefficients']);

% y2 with db9 wavelet
[c_db_2, l_db_2] = wavedec(y2, 10, 'db9');
approx_db2 = appcoef(c_db_2, l_db_2, 'db9');
[dbd1_2,dbd2_2,dbd3_2,dbd4_2,dbd5_2,dbd6_2,dbd7_2,dbd8_2,dbd9_2,dbd10_2] = detcoef(c_db_2, l_db_2, [1 2 3 4 5 6 7 8 9 10]);

figure('Name', 'y2[n] decomposition using db9 wavelet');
for i= 1:10
    db_decom = detcoef(c_db_2, l_db_2, i);
    subplot(11,1,i);
    stem(db_decom,'Marker','.');
    title(['Level ' num2str(i) ' dyadic decomposition of y2[n] using db9 wavelet']);
end
subplot(11,1,11);
stem(approx_db_1);
title(['Level ' num2str(10) ' dyadic approximation coefficients']);

%% Discrete waveform resconstruction

% y1 in Haar wavelet
y1_reconstructed_haar = discrete_wave_reconstruction(approx_haar_1,hd1,hd2,hd3,hd4,hd5,hd6,hd7,hd8,hd9,hd10,'haar');
figure('Name', 'Noisy x1[n] (y1) - reconstructed using Haar wavelet')
plot(n2, y1_reconstructed_haar);
title('Noisy x1[n] (y1) - reconstructed using Haar wavelet'), xlabel('Samples (n)'), ylabel('Amplitude');
xlim([0,1024]);

% y1 in db9 wavelet
y1_reconstruction_db9 = discrete_wave_reconstruction(approx_db_1,dbd1,dbd2,dbd3,dbd4,dbd5,dbd6,dbd7,dbd8,dbd9,dbd10,'db9');
figure('Name', 'Noisy x1[n] (y1) - reconstructed using db9 wavelet')
plot(n2, y1_reconstruction_db9);
title('Noisy x1[n] (y1) - reconstructed using db9 wavelet'), xlabel('Samples (n)'), ylabel('Amplitude');
xlim([0,1024])

% y2 in haar wavelet
y2_reconstructed_haar = discrete_wave_reconstruction(approx_haar_2,hd1_2,hd2_2,hd3_2,hd4_2,hd5_2,hd6_2,hd7_2,hd8_2,hd9_2,hd10_2,'haar');
figure('Name', 'Noisy x2[n] (y2) - reconstructed using Haar wavelet')
plot(n2, y2_reconstructed_haar);
title('Noisy x2[n] (y2) - reconstructed using Haar wavelet'), xlabel('Samples (n)'), ylabel('Amplitude');
xlim([0,1024])

% y2 in db9 wavelet
y2_reconstructed_db9 = discrete_wave_reconstruction(approx_db2,dbd1_2,dbd2_2,dbd3_2,dbd4_2,dbd5_2,dbd6_2,dbd7_2,dbd8_2,dbd9_2,dbd10_2,'db9');
figure('Name', 'Noisy x2[n] (y2) - reconstructed using db9 wavelet')
plot(n2, y2_reconstructed_db9);
title('Noisy x2[n] (y2) - reconstructed using db9 wavelet'), xlabel('Samples (n)'), ylabel('Amplitude');
xlim([0,1024])

%% Energy calculation betweeen original and reconstructed signals

E_y1 = sum(abs(y1).^2);
E_y1_haar_reconst = sum(abs(y1_reconstructed_haar).^2);
E_y1_db9_reconst = sum(abs(y1_reconstruction_db9).^2);
E_y2 = sum(abs(y2).^2);
E_y2_haar_reconst = sum(abs(y2_reconstructed_haar).^2);
E_y2_db9_reconst = sum(abs(y2_reconstructed_db9).^2);

disp('y1 energy calculation');
disp(['Energy of original (noisy) x1 is ', num2str(E_y1, 13)]);
disp(['Energy of reconstructed (noisy) x1 using haar wavelet is ', num2str(E_y1_haar_reconst, 13)]);
disp(['Energy of reconstructed (noisy) x1 using db9 wavelet is ', num2str(E_y1_db9_reconst, 13)]);
disp('y2 energy calculation');
disp(['Energy of original (noisy) x2 = ', num2str(E_y2, 13)]);
disp(['Energy of reconstructed (noisy) x2 using haar wavelet is ', num2str(E_y2_haar_reconst, 13)]);
disp(['Energy of reconstructed (noisy) x2 using db9 wavelet is ', num2str(E_y2_db9_reconst, 13)]);

%% Signal Denoising

signal_denoising(x1, y1, 10, 'haar' , 1, 'x1');      %% x1 with haar; Threshold = 1
signal_denoising(x1, y1, 10, 'db9', 1, 'x1');        %% x1 with db9; Threshold = 1
signal_denoising(x2, y2, 10, 'haar' , 2, 'x2');      %% x2 with haar; Threshold = 2
signal_denoising(x2, y2, 10, 'db9', 2, 'x2');        %% x2 with db9; Threshold = 2

%% Signal Compression

load('ECGsig.mat');                     % Load the given ideal ECG signal 
signal_length = length(aVR);
fs_ecg = 257;                           % sampling freqency of ecg
n  = 0:1:(signal_length-1);             % samples

figure('Name', 'aV_R lead of ECG signal with fs = 257 Hz');
plot(n, aVR);
title('aV_R lead of ECG signal with fs = 257 Hz'), xlabel('Samples (n)'), ylabel('Voltage (mV)');
xlim([0 length(aVR)]);

[c_haar_avr, l_haar_avr] = wavedec(aVR, 10, 'haar'); % Obtain wavelet coefficients of aVR in Haar wavelet
approx_haar_avr = appcoef(c_haar_avr, l_haar_avr, 'haar');
figure('Name', 'Dyadic decomposition of aV_R signal with Haar wavelet');
for i= 1:10
    haar_d_avr = detcoef(c_haar_avr, l_haar_avr, i);
    subplot(11,1,i);
    stem(haar_d_avr,'Marker','.');
    title(['Level ' num2str(i) ' dyadic decomposition of aV_R signal with Haar wavelet']);
end
subplot(11,1,11);
stem(approx_haar_avr);
title(['Level' num2str(10) ' approximation wavelet coefficients']);

[c_db_avr, l_db_avr] = wavedec(aVR, 10, 'db9'); % Obtain wavelet coefficients of aVR in db9 wavelet
approx_db_avr = appcoef(c_db_avr, l_db_avr, 'db9');
figure('Name', 'Dyadic decomposition of aV_R signal with db9 wavelet');
for i= 1:10
    db_d_avr = detcoef(c_db_avr, l_db_avr, i);
    subplot(11,1,i);
    stem(db_d_avr,'Marker','.');
    title(['Level ' num2str(i) ' dyadic decomposition of aV_R signal with db9 wavelet']);
end
subplot(11,1,11);
stem(approx_db_avr);
title(['Level ' num2str(10) ' approximation coefficients']);

level_sig = ceil(log2(signal_length));
percentage = 99;
signal_compression(aVR, level_sig, signal_length, 'haar', percentage, 'aVR signal'); % aVR with haar; Threshold 0 for compression
signal_compression(aVR, level_sig, signal_length, 'db9' , percentage, 'aVR signal'); % aVR with db9; overload denoise function for plots

%% functions

function signal_compression(x, levels, signal_length, wavelet, threshold_percentage, signal_name)

[coeff, book_keeping_l] = wavedec(x, levels, wavelet);
coeff_sorted = sort(abs(coeff(:)),'descend'); % sort the wavelet coefficients in decending order
figure('Name',['Sorted ' wavelet ' wavelet coefficients of ' signal_name ' - in descending order'])
stem(coeff_sorted);
xlim([0, length(coeff_sorted)])
title(['Sorted ' wavelet ' wavelet coefficients of ' signal_name ' - in descending order']);

cumulative_energy = 0;
no_of_selected_coeff = 0;
total_energy = sum((coeff_sorted).^2);

for i=1:length(coeff_sorted)
    cumulative_energy = cumulative_energy + (coeff_sorted(i)).^2;
    if (round(cumulative_energy/total_energy, 2) == threshold_percentage/100)
        no_of_selected_coeff = i;
        break;
    end
end
disp(['Number of coefficients needed to represent 99% of the energy of the signal is ' num2str(no_of_selected_coeff) ' in ' wavelet]);

compression_ratio = signal_length/no_of_selected_coeff;
disp(['Compression ratio is ' num2str(compression_ratio) ' in ' wavelet]);

threshold_to_be = coeff_sorted(no_of_selected_coeff);
coeff_selected = coeff;
for k = 1:length(coeff_selected)    % thresholding the coefficents (to remove considered as noise)
    if (abs(coeff_selected(k)) < threshold_to_be)
        coeff_selected(k) = 0;
    end
end

x_reconstructed = waverec(coeff_selected, book_keeping_l, wavelet); % reconstruction of the waveform with the remaining (suppressed) coefficients

len_y = length(x);
N = 1:1:len_y;
figure ('Name', [signal_name ' reconstructed with ' wavelet]);
plot(N, x_reconstructed);
xlim([0 len_y]);
title([signal_name ' reconstructed with ' wavelet]), xlabel('Samples (n)'), ylabel('Amplitude');

error = x - x_reconstructed;
rmse = sqrt(sum(abs(error).^2)/length(error));  % Calculation of RMSE between the original and the reconstructed signal   
disp(['RMSE between original ' signal_name ' and reconstructed waveform with ' wavelet ' wavelet is ' num2str(rmse)]);

figure('Name',['Comparison between original and reconstructed ' signal_name ' with ' wavelet ])
plot(N, x, 'g', N, x_reconstructed, 'b')
xlim([0 len_y]);
title(['Comparison between original and reconstructed ' signal_name ' with ' wavelet ]), xlabel('Samples (n)'), ylabel('Amplitude');
legend(signal_name, ['Reconstructed ' signal_name])
end

function signal_denoising(x, y, levels, wavelet, Threshold, signal_name)

[coeff, book_keeping_l] = wavedec(y, levels, wavelet);
coeff_sorted = sort(abs(coeff(:)),'descend');   % sort the wavelet coefficients in decending order

figure('Name',['Sorted ' wavelet ' wavelet coefficients of ' signal_name ' - in descending order'])
stem(coeff_sorted);
xlim([0, length(coeff_sorted)])
title(['Sorted ' wavelet ' wavelet coefficients of ' signal_name ' - in descending order']);

coeff_selected = coeff;
for j = 1:length(coeff_selected)    % thresholding the coefficents (to remove considered as noise)
    if (abs(coeff_selected(j)) < Threshold)
        coeff_selected(j) = 0;
    end
end

x_reconstructed = waverec(coeff_selected, book_keeping_l, wavelet); % reconstruction of the waveform with the remaining (suppressed) coefficients

len_y = length(y);
N = 1:1:len_y;
figure ('Name', [signal_name ' reconstructed with ' wavelet]);
plot(N, x_reconstructed);
xlim([0 len_y]);
title([signal_name ' reconstructed with ' wavelet]), xlabel('Samples (n)'), ylabel('Amplitude');

error = x - x_reconstructed;     
rmse = sqrt(sum(abs(error).^2)/length(error));  % Calculation of RMSE between the original and the reconstructed signal 
disp(['RMSE between original ' signal_name ' and its reconstructed waveform using ' wavelet ' wavelet is ' num2str(rmse)]);

figure('Name',['Comparison between original and reconstructed ' signal_name ' with ' wavelet ])
plot(N, x, 'g', N, x_reconstructed, 'b')
xlim([0 len_y]);
title(['Comparison between original and reconstructed ' signal_name ' with ' wavelet ]), xlabel('Samples (n)'), ylabel('Amplitude');
legend(signal_name, ['Reconstructed ' signal_name])
end

function reconstructed_waveform = discrete_wave_reconstruction(A10,D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,wavelet)
    A9 = idwt(A10,D10,wavelet);
    A8 = idwt(A9,D9,wavelet);
    A7 = idwt(A8,D8,wavelet);
    A6 = idwt(A7,D7,wavelet);
    A5 = idwt(A6,D6,wavelet);
    A4 = idwt(A5,D5,wavelet);
    if wavelet == "haar"
       A3 = idwt(A4,D4,wavelet); 
    else
       A3 = idwt(A4(1:79),D4,wavelet); 
    end
    A2 = idwt(A3,D3,wavelet);
    A1 = idwt(A2,D2,wavelet);
    reconstructed_waveform = idwt(A1,D1,wavelet);
end
