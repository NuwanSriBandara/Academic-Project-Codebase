clc;
close all;

%Problem1
num = [20];
den = [3 8 20];
F= tf(num, den)

stepplot(F); %plot step response of the transfer function

%Problem2
num = [1 4 6 8];
den = [1 3 5 1];

F = tf(num, den)
[numf, denf,kf] = tf2zp(num, den) %obtain the factored form of the transfer function

