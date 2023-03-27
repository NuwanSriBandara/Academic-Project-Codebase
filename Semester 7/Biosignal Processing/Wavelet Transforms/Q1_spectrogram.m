% author : Nuwan Bandara (180066F)

clearvars; close all; clc;

fs = 250;               % Sample frequency
N = 3000;               % Data length
time = (-N:N)/fs;       % Time scale
scale = 0.01:0.01:2;    % Values of scaling factor       

%% waveform construction
n1 = 1:1:3*N/2 -1;
n2 = 3*N/2:1:3*N;
sig1 = sin(0.5*pi*n1/fs);
sig2 = sin(1.5*pi*n2/fs);
constructed_signal = [sig1 sig2];

n = 1:1:3*N;

figure('Name','Constructed signal x[n]')
plot(n, constructed_signal, 'k');
title('Constructed signal x[n]'),xlabel('n'),ylabel('Amplitude');

%% Continuous Wavelet Decomposition
scale2 = 0.01:0.01:2;
n = 1:1:3*N;
cwt_coefs = zeros(length(scale2), length(n)); 

for i = 1:length(scale2)
    wavelt = (2/(sqrt(3*scale2(i))*pi^(1/4)))*(1-(time/scale2(i)).^2).*exp(-(time/scale2(i)).^2 /2);
    conv_signal = conv(constructed_signal, wavelt, 'same');
    cwt_coefs(i,:) = conv_signal;
end

% Plot the spectrogram
figure('Name','Spectrogram');
h = pcolor(n, scale2, cwt_coefs);
set(h, 'EdgeColor', 'none');
colormap jet
xlabel('Time (s)')
ylabel('Scale')
title('Spectrogram')