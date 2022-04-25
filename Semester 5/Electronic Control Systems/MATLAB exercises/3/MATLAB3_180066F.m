clc;
close all;
%Problem1
num = [5];
den = [1 5];
F_1= tf(num, den)
stepplot(F_1); %plot step response of the transfer function

num = [20];
den = [1 20];
F_2= tf(num, den)
stepplot(F_2); %plot step response of the transfer function

%Problem2
num = [1];
den = [1.422 1];
F_3= tf(num, den)
stepplot(F_3); %plot step response of the transfer function

%Problem3
%When M=1
num = [1];
den = [1 6];
F_4= tf(num, den)
stepplot(F_4); %plot step response of the transfer function

%When M=2
num = [1];
den = [2 6];
F_5= tf(num, den)
stepplot(F_5); %plot step response of the transfer function







