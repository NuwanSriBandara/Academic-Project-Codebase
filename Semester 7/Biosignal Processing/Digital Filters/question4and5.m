%Nuwan Bandara - 180066F

clc; clear all; close all;

%% Designing FIR filters using windows

%% Characteristics of window functions using fdatool
% use fdatool to design and save filter coefficients 

% Alternative approach using fvtool
load('RectWindows.mat')

% Magnitude Plot
fvtool(RectWindow5,1,RectWindow50,1,RectWindow100,1)
legend('Rectangular Window: M=5','Rectangular Window: M=50','Rectangular Window: M=100')

% Impulse Response
figure,hold on
stem(RectWindow5,'filled'),stem(RectWindow50), stem(RectWindow100)
hold off
legend('Rectangular Window: M=5','Rectangular Window: M=50','Rectangular Window: M=100')
title('Impulse Response of Rectangular Windows')

% Different Windows
M = 50;
samples = linspace(0,M,M);
rectangularWindow = rectwin(M)';
hanningWindow = hann(M)';
hammingWindow = hamming(M)';
blackmanWindow = blackman(M)';

figure
plot(samples,rectangularWindow,samples,hanningWindow,samples,hammingWindow, samples,blackmanWindow)
title('Different Window Functions'), xlabel('Samples (n)'), ylabel('Amplitude')
legend('Rectangular','Hanning','Hamming','Blackman')

% Window Properties
wc= 0.4;
rectangularfilter = fir1(M,wc,rectwin(M+1));
hanningfilter = fir1(M,wc,hann(M+1));
hammingfilter = fir1(M,wc,hamming(M+1));
blackmanfilter = fir1(M,wc,blackman(M+1));
fvtool(rectangularfilter,1,hanningfilter,1,hammingfilter,1,blackmanfilter,1)
legend('Rectangular','Hanning','Hamming','Blackman')

%% FIR filter design and application using the Kaiser windpw
load ECG_with_noise.mat
fs = 500;
T = 1000/fs; %Time (in ms)
t = linspace(0,length(nECG)*T,length(nECG));
[Pxx_1,Fxx_1] = periodogram(nECG,[],length(nECG),fs);

figure;
plot(t,nECG);
title('The ECG sequence with noise');
xlabel('Time (ms)');
ylabel('Amplitude (mV)');

figure;
plot(Fxx_1,10.*log10(Pxx_1));
title('PSD of the ECG sequence with noise');
xlabel('Hz'); ylabel('dB/Hz');

%% Filter parameters

% Low Pass filter
lp_fp = 122;
lp_fs = 128;
lp_wp = (lp_fp/fs)*2*pi;
lp_ws = (lp_fs/fs)*2*pi;
lp_delta = 0.001;

% High Pass filter
hp_fp = 8;
hp_fs = 2;
hp_wp = (hp_fp/fs)*2*pi;
hp_ws = (hp_fs/fs)*2*pi;
hp_delta = 0.001;

% Comb filter
f1 = 50;
f2 = 100;
f3 = 150;

% Values for highpass filter
hp_A = -20*log10(hp_delta);
if hp_A>50
    hp_beta = 0.1102*(hp_A-8.7);
elseif ((hp_A >= 21) && (hp_A <= 50))
    hp_beta = (0.5842*(hp_A-21).^0.4)+(0.07886*(hp_A-21));
else
    hp_beta = 0;
end

hp_wdelta = abs(hp_ws-hp_wp);
hp_M = ceil((hp_A-8)/(2.285*hp_wdelta));

% Values for the lowpass filter 
lp_wdelta = abs(lp_ws-lp_wp);
lp_A = -20*log10(lp_wdelta);
if lp_A>50
    lp_beta = 0.1102*(lp_A-8.7);
elseif ((lp_A >= 21) && (lp_A <= 50))
    lp_beta = (0.5842*(lp_A-21).^0.4)+(0.07886*(lp_A-21));
else
    lp_beta = 0;
end

lp_M = ceil((lp_A-8)/(2.285*lp_wdelta));
fprintf('Filter specifications:\n');
fprintf('For the low pass filter:\nWdelta = %.5f\nBeta = %.5f\nM = %d\nDelta = %.5f\n',lp_wdelta,lp_beta,lp_M,lp_delta);
fprintf('\nFor the high pass filter:\nWdelta = %.5f\nBeta = %.5f\nM = %d\nDelta = %.5f\n',hp_wdelta,hp_beta,hp_M,hp_delta);

% Highpass filter
hp_wc = (hp_wp+hp_ws)/2;
Ib = besseli(0,hp_beta); % zero^th order (modified) Bessel function of the first kind
for n = 1:hp_M+1
% Coefficients Kaiser window
    x = hp_beta*sqrt(1-(((n-1)-hp_M/2)/(hp_M/2))^2);
    I0 = besseli(0,x);
    hp_w(n) = I0/Ib;
    
    % Coefficients of desired impulse response
    if (n==floor(hp_M/2))
        hp_hd(n) = 1 - (hp_wc/pi);
    else
        hp_hd(n) = -1.*sin(hp_wc*((n)-floor(hp_M/2)))/(pi*((n)-floor(hp_M/2)));
    end
end

% Actual impulse response coefficients
hp_h = hp_hd.*hp_w;

figure
stem(0:hp_M,hp_h);
ylabel('Coefficients');
xlabel('n')
title('Highpass filter');

% Group delay of the highpass filter
 hpdelay = floor(mean(grpdelay(hp_h)));

% Highpass filter implemetation
lp_wc = (lp_wp+lp_ws)/2;
Ib = besseli(0,lp_beta); % zero^th order (modified) Bessel function of the first kind
for n = 1:lp_M+1
    % Coefficients Kaiser window
    x = lp_beta*sqrt(1-(((n-1)-lp_M/2)/(lp_M/2))^2);
    I0 = besseli(0,x);
    lp_w(n) = I0/Ib;
    
    % Coefficients of desired impulse response 
    if (n==floor(lp_M/2))
        lp_hd(n) = lp_wc/pi;
    else
        lp_hd(n) = sin(lp_wc*((n)-floor(lp_M/2)))/(pi*((n)-floor(lp_M/2)));
    end
end

% Actual impulse response coefficients
lp_h = lp_hd.*lp_w;

figure
stem(0:lp_M,lp_h);
ylabel('Coefficients');
xlabel('n')
title('Lowpass filter');

% Group delay of the lowpass filter
lpdelay = floor(lp_M/2);

% Filters visualization
h = fvtool(lp_h,1,hp_h,1);
set(h,'Legend','on')      
legend(h,'Lowpass filter','Highpass filter');

% Lowpass filtering of nECG
nECG_LP_filtered = filter(lp_h,1,nECG);

% High pass filtering of nECG
nECG_HP_filtered = filter(hp_h,1,nECG);

% Lowpass filter delay compensation
compensated_nECG_LP_filtered = [nECG_LP_filtered zeros(1,lpdelay)];
compensated_nECG_LP_filtered = compensated_nECG_LP_filtered(1+lpdelay:length(nECG)+lpdelay);

% Highpass filter delay compensation
compensated_nECG_HP_filtered = [nECG_HP_filtered zeros(1,hpdelay)];
compensated_nECG_HP_filtered = compensated_nECG_HP_filtered(1+hpdelay:length(nECG)+hpdelay);

% Lowpass filter application
figure;
plot(t,nECG,t,nECG_LP_filtered,t,compensated_nECG_LP_filtered);
xlabel('Time(ms)');
ylabel('Amplitude(mV)');
legend('Noisy ECG signal','Filtered but not compensated','Filtered and compensated');
title('Lowpass filter application');
axis([400 1200 -0.7 1.1]);

% Highpass filter application
figure;
plot(t,nECG,t,nECG_HP_filtered,t,compensated_nECG_HP_filtered);
xlabel('Time(ms)');
ylabel('Amplitude(mV)');
legend('Noisy ECG','Filtered but not compensated','Filtered and compensated');
title('Highpass filter application');
axis([400 1200 -0.7 1.1]);

% Comb filter
f0 = [50,100,150];
w0 = (f0./fs)*2*pi;
n = 1:1:length(f0);
z = exp(1j*n.*w0);
z1 = conj(z);
comb_coefficient = conv(conv(conv([1,-1.*z(1)],[1,-1.*z1(1)]),conv([1,-1.*z(2)],[1,-1.*z1(2)])),conv([1,-1.*z(3)],[1,-1.*z1(3)]));
G = 1/abs(sum(comb_coefficient));
b_comb = ones(1,length(comb_coefficient))./G;

% Group delay of the comb filter
comb_delay = floor(mean(grpdelay(b_comb)));
fvtool(b_comb,1);

% Comb filter application
nECG_comb_filtered = filter(b_comb,1,nECG);
compensated_nECG_comb_filtered = [nECG_comb_filtered zeros(1,comb_delay)];
compensated_nECG_comb_filtered = compensated_nECG_comb_filtered(1+comb_delay:length(nECG)+comb_delay);

% Cascaded filter
figure;
plot(t,nECG,t,compensated_nECG_comb_filtered);
xlabel('Time(ms)');
ylabel('Amplitude(mV)');
legend('Noisy ECG','Comb filter output with compensation');
title('Comb filter application in time domain');

%Filter cascading
cascaded_h = conv(conv(lp_h,hp_h),b_comb);
fvtool(cascaded_h,1);
cascaded_delay = floor(length(cascaded_h)/2);

% Cascaded filter application
nECG_cascaded_filtered = filter(cascaded_h,1,nECG);
compensated_nECG_cascaded_filtered = [nECG_cascaded_filtered zeros(1,cascaded_delay)];
compensated_nECG_cascaded_filtered = compensated_nECG_cascaded_filtered(1+cascaded_delay:length(nECG)+cascaded_delay);

figure;
plot(t,nECG,t,compensated_nECG_cascaded_filtered);
xlabel('Time(ms)');
ylabel('Amplitude(mV)');
legend('Noisy ECG','Cascaded filter output with compensation');
title('Cascaded filter application in time domain');
axis([400 2200 -1.5 2]);

%PSD of the input-output of the cascade
[Pxx_1,Fxx_1] = periodogram(compensated_nECG_cascaded_filtered,[],length(compensated_nECG_cascaded_filtered),fs);
[Pxx_2,Fxx_2] = periodogram(nECG,[],length(nECG),fs);

figure;
plot(Fxx_1,10.*log10(Pxx_1)); hold on;
plot(Fxx_2,10.*log10(Pxx_2),'r'); hold on;
title('PSD of input-output of the cascaded filter');
legend('Filtered Output (through cascade)','Noisy ECG signal ','Location','NorthEast');
xlabel('Hz'); ylabel('dB/Hz');

fprintf('\nDelays from the filters:\n');
fprintf('Delay of lowpass filter= %d\nDelay of highpass filter= %d\nDelay of comb filter= %d\nDelay of cascaded filter= %d\n',lpdelay,hpdelay,comb_delay,cascaded_delay);

%% IIR filters

% IIR filters realization
[lz,lp,lk] = butter(10,lp_wc/(2*pi),'low');
ls_os = zp2sos(lz,lp,lk);
[lb,la] = butter(10,lp_wc/(2*pi),'low');
fvtool(ls_os,'Analysis','freq')

[hz,hp,hk] = butter(10,hp_wc/(2*pi),'high');
hs_os = zp2sos(hz,hp,hk);
[hb,ha] = butter(10,hp_wc/(2*pi),'high');
fvtool(hs_os,'Analysis','freq')

Q = 50; % Quality factor
bw1 = (f0(1)/fs)/Q; % Bandwidth of the notch at -3dB
[cb1,ca1] = iircomb(floor(fs/f0(1)),bw1,'notch');
bw2 = (f0(2)/fs)/Q; 
[cb2,ca2] = iircomb(floor(fs/f0(2)),bw2,'notch');
bw3 = (f0(3)/fs)/Q; 
[cb3,ca3] = iircomb(floor(fs/f0(3)),bw3,'notch');
cb = conv(conv(cb1,cb2),cb3);
ca = conv(conv(ca1,ca2),ca3);
fvtool(cb,ca);

% IIR filter cascading
iirb = conv(conv(lb,hb),cb);
iira = conv(conv(la,ha),ca);
fvtool(iirb,iira);

%% IIR filter application
ECG_forward1 = filter(lb,la,nECG);
ECG_forward2 = filter(hb,ha,ECG_forward1);
ECG_forward = filter(cb,ca,ECG_forward1);
ECG_for_backward1 = filtfilt(hb,ha,nECG);
ECG_for_backward2 = filtfilt(hb,ha,ECG_for_backward1);
ECG_for_backward = filtfilt(cb,ca,ECG_for_backward1);

figure;
plot(t,nECG,t,ECG_forward,t,ECG_for_backward);
xlabel('Time (ms)');
ylabel('Amplitude (mV)');
legend('Noisy ECG signal','Forward filter','Forward-backward filter');
title('IIR filter application in noisy ECG signal');
axis([14300 16500 -0.4 0.8])

%PSD
[Pxx_1,Fxx_1] = periodogram(nECG,[],length(nECG),fs);
[Pxx_2,Fxx_2] = periodogram(ECG_forward,[],length(ECG_forward),fs);
[Pxx_3,Fxx_3] = periodogram(ECG_for_backward,[],length(ECG_for_backward),fs);

figure;
plot(Fxx_1,10.*log10(Pxx_1)); hold on;
plot(Fxx_2,10.*log10(Pxx_2),'r'); hold on;
plot(Fxx_3,10.*log10(Pxx_2),'k'); hold on;
title('PSD of the cascade filter');
legend('Noisy ECG signal','Forward filter','Forward-backward filter','Location','NorthEast');
xlabel('Hz'); ylabel('dB/Hz');

