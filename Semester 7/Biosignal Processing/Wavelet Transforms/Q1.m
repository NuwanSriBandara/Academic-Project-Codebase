% author : Nuwan Bandara (180066F)

clearvars; close all; clc;

fs = 250;               % Sample frequency
N = 3000;               % Data length
time = (-N:N)/fs;       % Time scale
scale = 0.01:0.1:2;     % Values of scaling factor

wavlt = zeros(length(time), length(scale)); % Daughter wavelets
wavlt_mean = zeros(1,length(scale));
wavlt_energy = zeros(1,length(scale));

syms x; %symbolic; to assign to the variable x
syms y;

figure('Name','Daughter Wavelets of Mexican hat wavelet for a set of scaling factors'); % Maxican hat wavelet

for k = 1:length(scale)
    wavlt(:, k) = (2/(sqrt(3*scale(k))*pi^(1/4)))*(1-(time/scale(k)).^2).*exp(-(time/scale(k)).^2 /2); % normalized wavelet as derived in the report
    subplot(5,4,k);
    plot(time, wavlt(:, k));
    axis([-5 5 -1.5 3]);
    title(['Scale = ', num2str(scale(k))]);
    xlabel('Time (s)'), ylabel('Amplitude');
    
    wavlt_mean(k) = int((2/((sqrt(3*scale(k)))*(pi^(1/4))))*(1-((x/scale(k)).^2)).*exp((-1/2)*(x/scale(k)).^2), 'x', -inf, inf); % definite integral wrt x 
    wavlt_energy(k) =  int(((2/((sqrt(3*scale(k)))*(pi^(1/4))))*(1-((y/scale(k)).^2)).*exp((-1/2)*(y/scale(k)).^2))^2, 'y', -inf, inf); % definite integral wrt y
end
ax = subplot(5,4,1);    % scaling the coefficient 1
axis([-1 1 -3.5 5]);

figure('Name','Mean and energy of daughter wavelets');   % plot mean and energy
scatter(scale, wavlt_mean);
hold on;
scatter(scale, wavlt_energy);
hold off;
axis([0 2 -0.5 1.5]);
title('Mean and energy of daughter wavelets');
legend('Mean', 'Energy'), xlabel('Scale factor'), ylabel('Amplitude');

figure('Name', 'Spectra of daughter wavelets'); % spectra of wavelets
for i = 1:length(scale)
    Fwavelt = fft(wavlt(:, i))/length(wavlt(:, i));
    hz = linspace(0,fs/2,floor(length(wavlt(:, i))/2)+1);
    ax = subplot(5,4,i);
    plot(hz,2*abs(Fwavelt(1:length(hz))))
    if (i == 1) 
        axis([0 60 0 0.05]);   % For better visualization: due to higher centre frequency
    else
        axis([0 10 0 0.2]);
    end
    title(['Scale = ', num2str(scale(i))]), xlabel('Frequency (Hz)'), ylabel('Amplitude')
end