clc;
clear all;
close all;

%indexNo = 180066F; By comparing with 180ABC. -> A=0, B=6, C=6, .=F
A = 0;
B = 6;
C = 6;

A_p = 0.03+(0.01*A); % dB %%max passband ripple
A_a = 45+B; %dB %%min stopband attenuation
Op1 = (C*100)+300; %rad/s %%lower passband edge
Op2 = (C*100)+700; %rad/s %%upper passband edge
Oa1 = (C*100)+150; %rad/s %%lower stopband edge
Oa2 = (C*100)+800; %rad/s %%upper stopband edge
Os = 2*(C*100+1200); %rad/s %%sampling freqency

Bt1 = Op1-Oa1; %rad/s %%lower transition width
Bt2 = Oa2-Op2; %rad/s %%upper transisiton width
Bt = min(Bt1,Bt2); %rad/s %%critical transition width
Oc1 = Op1-Bt/2; %rad/s %%lower cutoff frequency
Oc2 = Op2+Bt/2; %rad/s %%upper cutoff frequency
T = 2*pi/Os; %s %%sampling period

%Calculating delta
d_P = (10^(0.05*A_p) - 1)/ (10^(0.05*A_p) + 1);
d_A = 10^(-0.05*A_a);
delta = min(d_P,d_A);
Aa = -20*log10(delta); % Actual stopband attenuation
Ap = 20*log10(1+delta/1-delta); % Actual passband ripple

%Calculating alpha
if Aa<=21
    alpha = 0;
elseif Aa>21 && Aa<= 50
    alpha = 0.5842*(Aa-21)^0.4 + 0.07886*(Aa-21);
else
    alpha = 0.1102*(Aa-8.7);
end
alpha
%Claculating D
if Aa <= 21
    D = 0.9222;
else
    D = (Aa-7.95)/14.36;
end
D
% Calculating order of the filter N
N = ceil(Os*D/Bt +1);
if mod(N,2) == 0
    N = N+1;
end
N
% Length of the filter
n = -(N-1)/2:1:(N-1)/2;

% Calculating beta
beta = alpha*sqrt(1-(2*n/(N-1)).^2);

bessellimit = 100;
Io_alpha = 1;
for k = 1:bessellimit
    val_k = (1/factorial(k)*(alpha/2).^k).^2;
    Io_alpha = Io_alpha + val_k;
end
Io_alpha
Io_beta = 1;
for m = 1:bessellimit
    val_m = (1/factorial(m)*(beta/2).^m).^2;
    Io_beta = Io_beta + val_m;
end

wk_nT = Io_beta/Io_alpha;
figure
stem(n,wk_nT)
xlabel('n')
ylabel('Amplitude')
title('Kaiser Window - Time Domain');

n_L= -(N-1)/2:1:-1;
hnt_L = 1./(n_L*pi).*(sin(Oc2*n_L*T)-sin(Oc1*n_L*T));
n_R = 1:1:(N-1)/2;
hnt_R = 1./(n_R*pi).*(sin(Oc2*n_R*T)-sin(Oc1*n_R*T));
hnt_0 = (2/Os)*(Oc2-Oc1);
n = [n_L,0,n_R];
h_nT = [hnt_L,hnt_0,hnt_R];

Hw_nT = h_nT.*wk_nT;

n_shifted = [0:1:N-1];
figure
fvtool(Hw_nT);
stem(n_shifted,Hw_nT); axis tight;
xlabel('n')
ylabel('Amplitude')
title(strcat(['Filter Causal Impulse Response - Kaiser Window - Time Domain']));

figure
[Hw,f] = freqz(Hw_nT);
w_1 = f*Os/(2*pi);
log_Hw = 20*log10(abs(Hw));
plot(w_1,log_Hw)
xlabel('Frequency (rad/s)')
ylabel('Magnitude (dB)')
title(strcat(['Filter Magnitude Response - Kaiser Window - Frequency Domain']));

figure
finish = round((length(w_1)/(Os/2)*Oc1));
wpass_l = w_1(1:finish);
hpass_l = log_Hw(1:finish);
plot(wpass_l,hpass_l)
axis([-inf, inf, -inf, inf]);
xlabel('Frequency (rad/s)')
ylabel('Magnitude (dB)')
title('Filter Lower Stopband - Frequency Domain');

figure
start = round(length(w_1)/(Os/2)*Oc2);
wpass_h = w_1(start:length(w_1));
hpass_h = log_Hw(start:length(w_1));
plot(wpass_h,hpass_h)
axis([-inf, inf, -inf, inf]);
xlabel('Frequency (rad/s)')
ylabel('Magnitude (dB)')
title('Filter Upper Stopband - Frequency Domain');

figure
start = round(length(w_1)/(Os/2)*Oc1);
finish = round(length(w_1)/(Os/2)*Oc2);
wpass_h = w_1(start:finish);
hpass_h = log_Hw(start:finish);
plot(wpass_h,hpass_h)
axis([-inf, inf, -0.1, 0.1]);
xlabel('Frequency (rad/s)')
ylabel('Magnitude (dB)')
title('Filter Passband - Frequency Domain');

figure
stem(n_shifted,h_nT); axis tight;
xlabel('n')
ylabel('Amplitude')
title(strcat(['Filter Response - Rectangular window - Time Domain']));

figure
[hw,f] = freqz(h_nT);
w_2 = f*Os/(2*pi);
log_H = 20*log10(hw);
plot(w_2,log_H)
xlabel('Frequency (rad/s)')
ylabel('Magnitude (dB)')
title(strcat(['Filter Response - Rectangular Window - Frequency Domain']));

%Component frequencies of the input
O1 = Oc1/2
O2 = Oc1 + (Oc2-Oc1)/2
O3 = Oc2 + (Os/2-Oc2)/2

%Generate discrete signal and evelope
samples = 500;
n1 = 0:1:samples;
n2 = 0:0.1:samples;
X_nT = sin(O1.*n1.*T)+sin(O2.*n1.*T)+sin(O3.*n1.*T);
X_env = sin(O1.*n2.*T)+sin(O2.*n2.*T)+sin(O3.*n2.*T);

%Filtering using frequency domain multiplication
len_fft = length(X_nT)+length(Hw_nT)-1; %length for fft in x dimension
x_fft = fft(X_nT,len_fft);
Hw_nT_fft = fft(Hw_nT,len_fft);
out_fft = Hw_nT_fft.*x_fft; %a shift in time is added here
out = ifft(out_fft,len_fft);
rec_out = out(floor(N/2)+1:length(out)-floor(N/2)); %account for shifting delay

%Ideal Output Signal
ideal_out = sin(O2.*n2.*T);

figure
subplot(2,1,1)
len_fft = 2^nextpow2(numel(n1))-1;
x_fft = fft(X_nT,len_fft);
x_fft_plot = [abs([x_fft(len_fft/2+1:len_fft)]),abs(x_fft(1)),abs(x_fft(2:len_fft/2+1))];
f = Os*linspace(0,1,len_fft)-Os/2;
plot(f,x_fft_plot); 
xlabel('Frequency rad/s')
ylabel('Magnitude')
title(strcat(['Input signal',' ','- Frequency Domain']));

%Time domain representation of input signal before filtering
subplot(2,1,2)
stem(n1,X_nT)
axis([0, 50, -inf, inf]);
xlabel('n')
ylabel('Amplitude')
title(strcat(['Input signal',' ','- Time Domain']));
hold on
plot(n2,X_env)
legend('Input signal','Envelope of the Input signal');

%Frequency domain representation of output signal after filtering
figure
subplot(2,1,1)
len_fft = 2^nextpow2(numel(n1))-1;
xfft_out = fft(rec_out,len_fft);
x_fft_out_plot = [abs([xfft_out(len_fft/2+1:len_fft)]),abs(xfft_out(1)),abs(xfft_out(2:len_fft/2+1))];
f = Os*linspace(0,1,len_fft)-Os/2;
plot(f,x_fft_out_plot); axis tight;
xlabel('Frequency rad/s')
ylabel('Magnitude')
title(strcat(['Output signal',' ','- Frequency Domain']));

% Time domain representation of output signal after filtering
subplot(2,1,2)
stem(n1,rec_out)
axis([0, 50, -inf, inf]);
xlabel('n')
ylabel('Amplitude')
title(strcat(['Output signal',' ','- Time Domain']));
hold on
plot(n2,ideal_out)
legend('Output signal','Envelope of the ideal output signal');