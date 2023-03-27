%Nuwan Bandara - 180066F

clc; clear all; close all;

%% FIR derivative filters

fs = 128;% Sampling frequency
T = 1/fs;

% First-order derivative filters
B1 = [1,-1].*(1/T);
A1 = [1];
fvtool(B1,A1);

B2 = [1,0,-1].*(1/(2*T));
A2 = [1];
fvtool(B2,A2);

%% FIR derivative filter application
load ECG_rec.mat

snr = 10;
nECG = awgn(ECG_rec,snr,'measured');
t = linspace(0,length(ECG_rec)*T,length(ECG_rec));
emg = 2*sin(0.5*pi.*t) + 3*sin(pi.*t + (pi/4).*ones(size(t)));
nECG = nECG + emg;

figure;
plot(t,nECG,t,ECG_rec,t,emg);
title('The ECG signal with and without (EMG) noise');
xlabel('Time (ms)');
ylabel('Magnitude (mV)');
legend('Noisy ECG signal','Without noise ECG signal','EMG signal');
axis([6 18 -6 6]);

% First order derivative filter
first_order_ECG = filter(B1.*(T/2),A1,nECG);

% Three point central difference FIR filter
ECG_3_central = filter(B2.*(T),A2,nECG);

% Group delay compensation
grp_delay = floor(mean(grpdelay(B2))); % Magnitude of the group delay for the filter window manipulated
ECG_3_central = [ECG_3_central,zeros(1,grp_delay)];
ECG_3_central = ECG_3_central(1+grp_delay:numel(t)+grp_delay);

figure;
plot(t,first_order_ECG,t,ECG_3_central,t,nECG);
title('Comparison of the ECG sequence and filtered output through derivative FIR filters');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('First-order filter output','Three-point central difference filter output','Input noisy ECG signal');

% overlapping PSDs of noisy ECG and the derivative filtered outputs
[Pxx_1,Fxx_1] = periodogram(first_order_ECG,[],length(first_order_ECG),fs);
[Pxx_2,Fxx_2] = periodogram(nECG,[],length(nECG),fs);
[Pxx_3,Fxx_3] = periodogram(ECG_3_central,[],length(ECG_3_central),fs);

figure;
plot(Fxx_1,10.*log10(Pxx_1),'b'); hold on;
plot(Fxx_2,10.*log10(Pxx_2),'r'); hold on;
plot(Fxx_3,10.*log10(Pxx_3),'y'); hold on;
title('Single-Sided Frequency Response in PSD');
legend('First-order filter','Noisy ECG','Three-point central difference filter','Location','NorthEast');
xlabel('Hz'); ylabel('dB/Hz');


