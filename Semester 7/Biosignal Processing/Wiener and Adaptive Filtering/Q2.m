%author - Nuwan Bandara 180066F

clc;
clear all;

% initial signal manipulation and data construction
fs = 500;
N = 5000;                                                   % Number of samples
time = linspace(0, 5, N);                                   % Time vector

sawtooth_signal = sawtooth(2*pi*2*time(1 : N), 0.5);        % Sawtooth signal
n50 = 0.2*sin(2*pi*50*time(1 : N/2));                       % Sinusoidal noise with 50 Hz
n100 = 0.3*sin(2* pi*100*time(N/2 + 1 : N));                % Sinusoidal noise with 100 Hz
nwg = sawtooth_signal - awgn(sawtooth_signal, 10, 'measured');    % 10 dB additive Gaussian white noise

noisy_signal = sawtooth_signal + nwg + [n50 n100];             % ECG signal with noise (AWGN+sinusoidal) 

figure('Name', 'ECG signals for input to Adaptive Filtering')
subplot(2,1,1)
plot(time, sawtooth_signal)
title('Ideal sawtooth wave')
subplot(2,1,2)
plot(time, noisy_signal)
title('Noise added signal')
linkaxes()

% r(n) 
% arbitary constants
a = 1.61; 
phi_1 = pi*(1/6); 
phi_2 = pi*(1/2);

n50_r = 0.2*sin(2*pi*50*time(1 : N/2) + phi_1); %sinusoidal noise of 50Hz
n100_r = 0.3*sin(2* pi*100*time(N/2 + 1 : N) + phi_2); %sinusoidal noise of 100Hz

r_n_signal = a*(nwg + [n50_r n100_r]);

%% LMS method
%% 2.1 a

mu_1 = 0.006112;
M = 12;
[err, ~, ~] = LMS_algo(noisy_signal, r_n_signal, mu_1, M);
figure;
subplot(4,1,1)
plot(time,sawtooth_signal)
title('Desired sawtooth signal(n)')
subplot(4,1,2)
plot(time,noisy_signal)
title('Noisy signal')
subplot(4,1,3)
plot(time,err)
title(['Filtered signal using LMS method with M=10 and u=0.006161'])
subplot(4,1,4)
plot(time,abs(err-sawtooth_signal))
title('Absolute Error')

e_LMS = err;    % error in LMS method

M_Range = 15; % order range
mse = NaN(M_Range, 100);

lambda_max = 20*M_Range*((noisy_signal*noisy_signal')/ length(noisy_signal));
mu = linspace(0.001, 2/ lambda_max, 100);

for M = 1:M_Range
    for i = 1:100
        [err, ~, ~] = LMS_algo(noisy_signal, r_n_signal, mu(i), M);
        mse(M,i) = immse(err,sawtooth_signal);
    end
end

M = 1:M_Range;
figure;
surf(mu, M, mse)
title('MSE Variation with LMS-based adaptive filtering') 
colorbar
xlabel('mu'), ylabel('M - Order'),zlabel('MSE');
colormap('jet')

% LMS with minimum MSE
[ms, ls] = min(mse,[],2);
[mse_min, m_min] = min(ms);
lambda_min = ls(m_min)*(2/ lambda_max - 0.001)/100 + 0.001;
disp(['Minimum Error in LMS = ' num2str(mse_min) ' at M = ' num2str(m_min) ' and mu = ' num2str(lambda_min)])

[err, ~, ~] = LMS_algo(noisy_signal, r_n_signal, lambda_min, m_min);
figure;
subplot(4,1,1)
plot(time,sawtooth_signal)
title('Desired sawtooth signal(n)')
subplot(4,1,2)
plot(time,noisy_signal)
title('Noisy signal')
subplot(4,1,3)
plot(time,err)
title(['Filtered signal using LMS method with least MSE'])
subplot(4,1,4)
plot(time,abs(err-sawtooth_signal))
title('Absolute Error')

%%  2.2 RLS Algorithm

% set constants
lamda = 0.996;          % since lamda in (0,1]
M = 15;
[err_2, ~, ~] = RLS_algo(noisy_signal, r_n_signal, lamda, M);

figure;
subplot(4,1,1)
plot(time, sawtooth_signal)
title('Desired sawtooth signal')
subplot(4,1,2)
plot(time, noisy_signal)
title('Noisy signal')
subplot(4,1,3)
plot(time, err_2);
title('Filtered Signal using RLS backed adaptive filter with M=15 and lambda = 0.996');
subplot(4,1,4)
plot(time, abs(err_2 - sawtooth_signal'))

e_RLS = err_2; %error in RLS
 
M_Range = 15;   % order range
mse = NaN(M_Range,100);
lambda = linspace(0.9,1,100);

for M=1:M_Range
    for i = 1:100
        err = RLS_algo(noisy_signal, r_n_signal, lambda(i), M);
        mse(M,i) = immse(err', sawtooth_signal);
    end
end

figure;
surf(lambda,(1:M_Range), mse)
colorbar
title('MSE Variation with respect to adaptive filtering using RLS')
xlabel('lambda'), ylabel('M - Order'), zlabel('MSE');
colormap('jet')

% Find RLS with minimum MSE
[ms,ls] = min(mse,[],2);
[mse_min,m_min] = min(ms);
lambda_min = ls(m_min)*(0.01)/100 + 0.9;
disp(['Minimum Error in RLS = ' num2str(mse_min) ' at M = ' num2str(m_min) ' and lambda = ' num2str(lambda_min)])

[err_2, ~, ~] = RLS_algo(noisy_signal, r_n_signal, lambda_min, m_min);

figure;
subplot(4,1,1)
plot(time, sawtooth_signal)
title('Desired sawtooth signal')
subplot(4,1,2)
plot(time, noisy_signal)
title('Noisy signal')
subplot(4,1,3)
plot(time, err_2);
title('Filtered Signal using RLS backed adaptive filter with least MSE');
subplot(4,1,4)
plot(time, abs(err_2 - sawtooth_signal'))
title('Absolute Error')

%% Comparing LMS algorithm and RLS algorithm

figure
subplot(2,1,1)
plot(time, abs(e_LMS - sawtooth_signal));
title(['Convergence of error using the LMS algorithm \mu = ' num2str(mu_1) ' M = 15' ]);
xlabel('Time(sawtooth signal)');
ylabel('Amplitude (mV)');
grid on
subplot(2,1,2)
plot(time, abs(e_RLS' - sawtooth_signal))
title(['Convergence of error using the RLS algorithm (ANC) \lambda = ' num2str(lamda) ' M = 15']),
xlabel('Time (sawtooth signal)');
ylabel('Amplitude (mV)');
grid on


%% c. Adaptive filtering ECG signal
load('idealECG.mat')
ECG_sig = idealECG - mean(idealECG);

fs = 500;
N = length(ECG_sig); 
time = linspace(0,N/fs,N);                  

signal = ECG_sig;                                 
n50 = 0.2*sin(2*pi*50*time(1 : N/2)); %adding non-stationary noise                    
n100 = 0.3*sin(2* pi*100*time(N/2+1 : N));                
nwg = signal - awgn(signal, 10,'measured');  % Gaussian white noise of 10dB
noisy_signal = signal + nwg + [n50 n100];    % noisy ECG signal


%% Generating r(n)
a = 1.61; 
phi_1 = pi*(1/6); 
phi_2 = pi*(1/2);

n50_r = 0.2*sin(2*pi*50*time(1 : N/2) + phi_1); 
n100_r = 0.3*sin(2*pi*100*time(N/2 + 1 : N) + phi_2); 

r_n_signal = a*(nwg + [n50_r n100_r]);

%% LMS in ECG filtering
mu = 0.006112;
M = 12;
[err, ~, ~] = LMS_algo(noisy_signal, r_n_signal, mu, M);

%% RLS in ECG filtering
lamda = 0.996; % lamda in (0,1]
M = 12;
[err_2, y2, w2] = RLS_algo(noisy_signal, r_n_signal, lamda, M);

figure;
subplot(6,1,1)
plot(time, signal)
title('Desired sawtooth signal(n)')
subplot(6,1,2)
plot(time, noisy_signal)
title('Noisy signal')
subplot(6,1,3)
plot(time, err)
title(['Filtered ECG signal using LMS algorithm with M=12 and u=0.006112'])
subplot(6,1,4)
plot(time, abs(err - signal))
title('Absolute Error | LMS')
subplot(6,1,5)
plot(time,err_2);
title(['Filtered ECG signal using RLS algorithm with M=12 and lambda = 0.996']);
subplot(6,1,6)
plot(time,abs(err_2 - signal'))
title('Absolute Error in RLS')
linkaxes()

%% functions 

function [err_vect, new_sig, weight_mat] = LMS_algo(noisy_sig, signal_R, mu, M)
    % Active noise canceller based on LMS algorithm
    
    % Inputs:
    % noisy_sig  = input signal sample vector of size N
    % Rr  = desired signal sample vector of size N
    % mu = rate of convergence
    % M = order of the FIR filter
    %
    % Outputs:
    % err_vect = output residual error vector of size N
    % new_sig = output coefficients of noise estimation
    % weight_mat = FIR filter parameters

    N_r = length(signal_R);
    N_x = length(noisy_sig);
    
    % Initialization
    Rr = zeros(M,1);                % delay matrix
    weight_vect = zeros(M,1);       % adaptive weights vector
    weight_mat = zeros(N_x,M);      % adaptive weights matrix
    new_sig = zeros(1, N_x);
    err_vect = zeros(1, N_x);       % Error vector

    if (N_r <= M)  
        disp('error: signal length must be higher than the filter order');
        return; 
    end
    if (N_r ~= N_x)  
        disp('error: Input signal and reference signal must in same length');
        return; 
    end

    lambda_max = 20*M*((noisy_sig*noisy_sig')/length(noisy_sig));
    
    if (mu > 2/lambda_max) 
        disp(['mu is too large to converge' num2str(mu) ' /' num2str(lambda_max)]);
        return
    end


    for k = 1:N_x
        Rr(1) = signal_R(k);  % r(n)
        new_sig(k) = weight_vect'*Rr;  % new_sig(n) = weight_mat(n)'.sig_R(n)
        err_vect(k) = noisy_sig(k) - new_sig(k);  % err_vect(n) = noisy_sig(n) - weight_mat(n)'.sig_R(n) = noisy_sig(n) - new_sig(n)
        weight_vect = weight_vect + 2*mu*err_vect(k)*Rr; % weight_vect(n+1) = weight_vect(n) + 2*mu*err_vect(n)*sig_R(n) : from Widrow-Hoff LMS algorithm
        weight_mat(k,:) = weight_vect;  % Store the weights vector in the weights matrix
        Rr(2:M) = Rr(1:M-1); % Delay back the ref signal window by one sample
    end

end

function [err, new_sig, weight_mat] = RLS_algo(noisy_sig, R, lamda, L)

    % Active noise canceller based on RLS algorithm 
    
    % Inputs:
    % noisy_sig  = vector of input signal samples of size N
    % R  = vector of desired signal samples of size N
    % lamda = weight parameter,
    % M = order of the FIR filter
    %
    % Outputs:
    % err = output residual error vector of size N
    % new_sig = output coefficients of noise estimation
    % weight_mat = FIR filter parameters

    N_sig = length(noisy_sig);
    N_r = length(R);

    % Initialization
    I = eye(L);
    alpha = 0.01;
    p = alpha * I;
    xx = zeros(L,1);                % delay matrix
    weight_vect = zeros(L,1);       % adaptive weights vector
    weight_mat = zeros(L,N_sig);    % adaptive weights matrix
    new_sig = zeros(N_sig,1);
    err = zeros(N_sig,1);           % Error vector


    if (N_r <= L)  
        print('error: signal length must be higher than the filter order');
        return; 
    end
    if (N_r ~= N_sig)  
        print('error: Input signal and reference signal must in same length');
        return; 
    end

    for n = 1:N_sig
        xx(1) = R(n); % r(n)
        k = (p * xx) ./ (lamda + xx' * p * xx); % Kalman gain vector
        new_sig(n) = xx'*weight_vect; % new_sig(n) = weight_mat(n)'.R(n)
        err(n) = noisy_sig(n) - new_sig(n); % e(n) = noisy_sig(n) - weight_mat(n)'.R(n) = noisy_sig(n) - new_sig(n)
        weight_vect = weight_vect + k * err(n); % weight_vect(n+1) = weight_vect(n) + k**e(n)
        p = (p - k * xx' * p) ./ lamda;
        weight_mat(:,n) = weight_vect; % Store the weights vector in the weights matrix
        xx(2:L) = xx(1:L-1); % Delay back the ref signal window by one sample
    end

end
