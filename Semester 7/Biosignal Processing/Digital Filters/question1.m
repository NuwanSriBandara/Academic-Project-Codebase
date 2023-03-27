%Nuwan Bandara - 180066F

%% Preliminaries

clc; clear all; close all;

% Loading the given data
load ECG_template.mat

% Plotting the ECG signal
figure;
fs = 500; % Sampling Frequency
T = 1000/fs; % Sampling period is obtained in ms
t= linspace(0,numel(ECG_template)*numel(ECG_template),numel(ECG_template));%The list of time points equal length to the given samples
plot(t,ECG_template);
title('The ECG template sequence');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')

% Adding white Gausssian noise to ECG
snr = 5;
nECG = awgn(ECG_template,snr,'measured');
figure;
plot(t,ECG_template,t,nECG);
title('The ECG sequence with noise');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('Sample ECG Signal (without added noise)','ECG Signal with AWGN');

% The periodogram plot for power spectral density
figure;
periodogram(nECG,[],[],fs); % For whole length of the signals

%% MA(3) filter implementation using a customized script
N = 3;
ma3ECG_1 = zeros(1,numel(nECG));
for i = N+1:numel(nECG)
    ma3ECG_1(i) = mean(nECG(i-N:i));
end

% The group delay derivation and implementation
[phi,w] = phasez(ones(1,N)); %The phase of the filter's impulse response is considered here
group_delay = floor(mean(-1.*gradient(phi,w)));

% altenative method for group delay as derived in the report
% groupDelay = (N-1)/2;

% Compensate for the group delay 
% Delay compensation through padding: The padding of the ones to the signal end to compensate for the delay  
com_ma3ECG_1 = [ma3ECG_1,zeros(1,abs(group_delay))];
com_ma3ECG_1 = com_ma3ECG_1(1+abs(group_delay):numel(t)+abs(group_delay));

figure;
plot(t,ma3ECG_1,t,nECG,t,com_ma3ECG_1);
title('Comparison of the ECG sequence with noise and filtered output through MA(3)');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('MA(3) filter output','Noisy ECG signal','Delay compensated MA(3) filter output');

% Comparison of overlapping PSDs of ma3ECG_1 and nECG
[Pxx_1,Fxx_1] = periodogram(com_ma3ECG_1,[],length(com_ma3ECG_1),fs);
[Pxx_2,Fxx_2] = periodogram(nECG,[],length(nECG),fs);

figure;
plot(Fxx_1,10.*log10(Pxx_1), 'k'); hold on;
plot(Fxx_2,10.*log10(Pxx_2),'r'); hold on;
title('Overlapping PSDs of delay compensated MA(3) filter output and noisy ECG signal');
legend('MA(3) filtered output','Noisy ECG signal','Location','NorthEast');
xlabel('Hz'); ylabel('dB/Hz');

%% MA(3) filter implementation with the MATLAB built-in function

% The filter definition 
N =3;
B = ones(1,N)./N; % Zero coefficients
A = [1]; % since of no poles

% The filter attained 
ma3ECG_2 = filter(B,A,nECG);

% Group delay derivation and compensation
grp_delay = floor(mean(grpdelay(B))); % Magnitude of the group delay for the filter window manipulated
ma3ECG_2 = [ma3ECG_2,zeros(1,grp_delay)];
ma3ECG_2 = ma3ECG_2(1+grp_delay:numel(t)+grp_delay);

figure;
plot(t,ma3ECG_2,t,nECG,t,ECG_template);
title('Comparison of the ECG sequences and MA(3) filtered output (from built-in MATLAB)');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('MA(3) filter output (with compensation)','ECG signal with noise','Original signal without noise');

% The magnitude response, phase response and the pole-zero plot for MA(3)
fvtool(B,A);

%% MA(10) filter implementation with the MATLAB built-in function
N =10;
B = ones(1,N)./N; % Zero coefficients
A = [1]; % Since of no poles

% The filter attained  
ma10ECG = filter(B,A,nECG);
fvtool(B,A);

% Group delay derivation and compensation
grp_delay = floor(mean(grpdelay(B))); % Magnitude of the group delay for the filter window manipulated
ma10ECG = [ma10ECG,zeros(1,grp_delay)];
ma10ECG = ma10ECG(1+grp_delay:numel(t)+grp_delay);

figure;
plot(t,nECG,t,ECG_template,t,ma3ECG_2,t,ma10ECG);
title('Comparison of ECG sequences and filtered output by filters (of different orders)');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('Noisy ECG signal','Original ECG signal without noise','Delay compensated filter output of order 3','Delay compensated filter output of order 10');

%% Optimum MA(N) filter order
order_list = linspace(1,50,50); % upto 50th order
MSE_list = zeros(1,50);
for i = order_list
    B = ones(1,i)./i; % Zero coefficients
    A = [1]; % Since of no poles
    maiECG = filter(B,A,nECG);
    grp_delay = floor(mean(grpdelay(B))); % Magnitude of the group delay for the filter window manipulated
    maiECG = [maiECG,zeros(1,grp_delay)];
    maiECG = maiECG(1+grp_delay:numel(t)+grp_delay);
    MSE_list(i) = mean((maiECG - ECG_template).^2);
end

% MSE vs the order
figure;
stem(order_list,MSE_list);
title('MSE variation against the filter order');
xlabel('Order of the filter');
ylabel('MSE between original signal without noise and the filtered signal');

[min_MSE,min_order1] = min(MSE_list);
fprintf('The minimum MSE of %.5f is achieved when the MA filter of order %d is implemented.\n',min_MSE,min_order1);

%% Savitzky-Golay SG(N,L) filter
N = 3;
L = 11;
b = ones(1,L);
sg310ECG = sgolayfilt(nECG,N,L);

figure;
plot(t,sg310ECG,t,nECG,t,ECG_template);
title('Comparison of the ECG sequences and filtered SG(3,11) output signal');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('SG(3,11) filter output','Input noisy ECG signal','Original ECG signal without noise');

% Optimum SG(N,L) filter parameters
order_list = 1:50; %upto 50th order
window_list = 1:50; %upto frame length = 50
[X,Y] = meshgrid(order_list,window_list);
MSE_grid = zeros(50,50);
min_MSE = 1;
for x = order_list
    for y = window_list
        if (x<y & mod(y,2))
            sgECG = sgolayfilt(nECG,x,y);
            MSE_grid(x,y) = mean((sgECG - ECG_template).^2);
            if (MSE_grid(x,y)< min_MSE)
                min_order = x;
                min_window = y;
                min_MSE = MSE_grid(x,y);
            end
        else
            MSE_grid(x,y) = 1;
        end
    end
end
figure;
surf(X,Y,MSE_grid)
colorbar;
title('Surface plot of SG filters');
fprintf('The minimum MSE of %.5f is achieved when a SG filter of order %d and frame length of %d is implemented.\n',min_MSE,min_order,min_window);

% Optimum SG filter and delay compensated MA
sg_opt_ECG = sgolayfilt(nECG,min_order,min_window);

figure;
plot(t,nECG,t,sg310ECG,t,sg_opt_ECG);
title('Comparison of the ECG sequences and filtered output by SG filters');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('Input noisy ECG signal','SG(3,11)','Optimum SG filtered');


N = min_order1;
B = ones(1,N)./N; % zero coefficients
A = [1]; % Since of no poles

% The optimum filter attained through MA
MA_opt_filt = filter(B,A,nECG);

% Group delay compensation
grp_delay = floor(mean(grpdelay(B))); % Magnitude of the group delay for the filter window manipulated
MA_opt_filt = [MA_opt_filt,zeros(1,grp_delay)];
MA_opt_filt = MA_opt_filt(1+grp_delay:numel(t)+grp_delay);

figure;
plot(t,nECG,t,MA_opt_filt,t,sg_opt_ECG,t,ECG_template);
title('Comparison of the ECG sequences and filtered output by optimum MA and SG filters');
xlabel('Time (ms)');
ylabel('Amplitude (mV)')
legend('Input noisy ECG signal','Optimum MA','Optimum SG','Original ECG signal without noise');
