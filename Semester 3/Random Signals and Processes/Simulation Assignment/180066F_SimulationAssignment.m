clc;
clear all;

L = 1000; %L = 100000 for question 5

%generate a equiprobable binary sequence
D = zeros(1,L); %generate a sequence of L zeros
p = randperm(L,L/2); %choose L/2 numbers randomly between 1 and 1000 without replacement
D(p) = ones(1,L/2); %replace the zeros in D with ones in the randomly chosen places
A = 1;

%generate a sequence of pulses
S = zeros(1,L); %generate a sequence of L zeros
for i = 1:L
    if D(i) == 0 %assign -A if D = 0
        S(i) = -1*A;
    else
        S(i) = A; %assign A if D = 1
    end
end

%generate AWGN with mean = 0 and variance = 1
m = 0;
sigma = 1;
N = m + sigma*randn(1,L);

%generate the received signal and plot it
R = S + N;
figure;
stairs([1:L],R);
title("Received Signal when \sigma^2 = 1 and L=1000");

%generate Y sequence
tau = 0;
Y = zeros(1,L);
for j = 1:L
    if R(j) > tau
        Y(j) = A;
    else
        Y(j) = -1*A;
    end
end

%plot transmitted signal and Y sequence, and compare
figure;
subplot(2,1,1);
stairs([1:L],S);
title("Transmitted Signal");
xlim([0 L]); %xlim([0 L/1000]) is taken when L = 100000
ylim([-1*A-1 A+1]);
subplot(2,1,2);
stairs([1:L],Y);
title("Decoded Signal");
xlim([0 L]); %xlim([0 L/1000]) is taken when L = 100000
ylim([-1*A-1 A+1]);

%generate the bins sequence
bin_n = 10; %bin_n=100 for question 5(a)
R_max = max(R);
R_min = min(R);
width = (R_max-R_min)/(bin_n-1);
bins = [R_min-width/2:width:R_max];

%count y values for each bin
y_values = zeros(1,bin_n);
for k = 1:L
    for a = 1:bin_n
        if (R(k) >= bins(a)-width/2) && (R(k) < bins(a)+width/2)
            y_values(a) = y_values(a) + 1;
        end
    end
end
new = y_values/width;

%plot the histogram
figure;
bar(bins,new);
title("Histogram of R (Without using the built-in function)");

%use the buit-in function hist()
figure;
hist(R,bin_n);
title("Histogram of R (Using built-in hist() function)");

%plot the pdf of f_R|S(r|S=A)
list_R1 = []; %create a list containing R values when S = A
ind = 1;
for b = 1:L
    if S(b) == A
        list_R1(ind) = R(b);
        ind = ind + 1;
    end
end

bin_1 = 100;
R_max1 = max(list_R1);
R_min1 = min(list_R1);
width_1 = (R_max1-R_min1)/(bin_1-1); %set bin width
bins_1 = [R_min1-width_1/2:width_1:R_max1]; %create the bins list
[y_val1,x_val1] = hist(list_R1,bins_1); %plot the histogram
y_val1 = y_val1/((ind-1)*width_1);
figure;
bar(x_val1,y_val1);
hold on;
plot(x_val1,y_val1,'r'); %plot the pdf
title("PDF of f_{R|S}(r|S=A) when A=1");

%plot the pdf of f_R|S(r|S=-A)
list_R0 = []; %create a list containing R values when S = -A
ind1 = 1;
for c = 1:L
    if S(c) == -1*A
        list_R0(ind1) = R(c);
        ind1 = ind1 + 1;
    end
end
bin_2 = 100;
R_max2 = max(list_R0);
R_min2 = min(list_R0);
width_2 = (R_max2-R_min2)/(bin_2-1); %set bin width
bins_2 = [R_min2-width_2/2:width_2:R_max2]; %create the bins list
[y_val2,x_val2] = hist(list_R0,bins_2); %plot the histogram
y_val2 = y_val2/((ind1-1)*width_2);
figure;
bar(x_val2,y_val2);
hold on;
plot(x_val2,y_val2,'r'); %plot the pdf
title("PDF of f_{R|S}(r|S=-A) when A=1");

%calculate E[R|S=A]
ER_SA = 0;
for i1 = 1:bin_1
    ER_SA = ER_SA + (x_val1(i1)*y_val1(i1)*width_1);
end
ER_SA

%calculate E[R|S=-A]
ER_SMA = 0;
for i2 = 1:bin_2
    ER_SMA = ER_SMA + (x_val2(i2)*y_val2(i2)*width_2);
end
ER_SMA
%calculate E[R]
[y_val,x_val] = hist(R,bins);
y_val = y_val/(L*width);
E_R = 0;
for i3 = 1:bin_n
    E_R = E_R + (x_val(i3)*y_val(i3)*width);
end
E_R
%plot the pdf of f_R(r)
figure;
bar(x_val,y_val);
hold on;
plot(x_val,y_val,'r');
title("PDF of f_R(r)");

%generate interference
m_i = 0;
sigma_i = 1;
I = m_i + sigma_i*randn(1,L);
%generate the recieved signal
R = S + N + I;

%scaling factor
alpha = 3;
%generate the recieved signal and plot it
R = alpha*S + N;

list_R1 = []; %create a list containing R values when S = A
ind = 1;
for b = 1:L
    if S(b) == A
        list_R1(ind) = R(b);
        ind = ind + 1;
    end
end
bin_1 = 100;
R_max1 = max(list_R1);
R_min1 = min(list_R1);
width_1 = (R_max1-R_min1)/(bin_1-1); %set bin width
bins_1 = [R_min1-width_1/2:width_1:R_max1]; %create the bins list
[y_val1,x_val1] = hist(list_R1,bins_1); %plot the histogram
y_val1 = y_val1/((ind-1)*width_1);
figure;
bar(x_val1,y_val1);
hold on;
plot(x_val1,y_val1,'r'); %plot the pdf
title("PDF of f_{R|S}(r|S=A) when A=1");

%plot the pdf of f_R|S(r|S=-A)
list_R0 = []; %create a list containing R values when S = -A
ind1 = 1;
for c = 1:L
    if S(c) == -1*A
        list_R0(ind1) = R(c);
        ind1 = ind1 + 1;
    end
end
bin_2 = 100;
R_max2 = max(list_R0);
R_min2 = min(list_R0);
width_2 = (R_max2-R_min2)/(bin_2-1); %set bin width
bins_2 = [R_min2-width_2/2:width_2:R_max2]; %create the bins list
[y_val2,x_val2] = hist(list_R0,bins_2); %plot the histogram
y_val2 = y_val2/((ind1-1)*width_2);
figure;
bar(x_val2,y_val2);
hold on;
plot(x_val2,y_val2,'r'); %plot the pdf
title("PDF of f_{R|S}(r|S=-A) when A=1");

%calculate E[R|S=A]
ER_SA = 0;
for i1 = 1:bin_1
    ER_SA = ER_SA + (x_val1(i1)*y_val1(i1)*width_1);
end
ER_SA

%calculate E[R|S=-A]
ER_SMA = 0;
for i2 = 1:bin_2
    ER_SMA = ER_SMA + (x_val2(i2)*y_val2(i2)*width_2);
end
ER_SMA
%calculate E[R]
[y_val,x_val] = hist(R,bins);
y_val = y_val/(L*width);
E_R = 0;
for i3 = 1:bin_n
    E_R = E_R + (x_val(i3)*y_val(i3)*width);
end
E_R
%plot the pdf of f_R(r)
figure;
bar(x_val,y_val);
hold on;
plot(x_val,y_val,'r');
title("PDF of f_R(r)");