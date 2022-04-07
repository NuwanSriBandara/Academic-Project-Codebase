clc;
clear all;
close all;

%Problem1
p1 = [1 (4/3)+(2.49444*1i)];
p2 = [1 (4/3)-(2.49444*1i)];
den = conv(p1, p2)

omegan = sqrt(den(3)/den(1))
zeta = (den(2)/den(1))/(2*omegan)
Ts = 4/(zeta*omegan)
Tp = pi/(omegan*sqrt(1-zeta^2))
pos = 100*exp(-zeta*pi/sqrt(1-zeta^2))

num1 = 10;
den1 = [3 8 24];
func1 = tf(num1, den1);
stepplot(func1);

%Problem2
num2 = 400;
den2 = [1 8 400];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 100;
den2 = [1 8 100];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 44.444;
den2 = [1 8 44.444];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 25;
den2 = [1 8 25];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 16;
den2 = [1 8 16];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 11.111;
den2 = [1 8 11.111];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 8.1633;
den2 = [1 8 8.1633];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 6.25;
den2 = [1 8 6.25];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 4.9383;
den2 = [1 8 4.9383];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 4;
den2 = [1 8 4];
func2 = tf(num2, den2);
stepplot(func2)
hold off
legend('\xi = 0.2','\xi = 0.4','\xi = 0.6','\xi = 0.8','\xi = 1.0','\xi = 1.2','\xi = 1.4','\xi = 1.6','\xi = 1.8','\xi = 2.0','Location','SouthEast')

%Problem3
num2 = 16;
den2 = [1 8 16];
func2 = tf(num2, den2);
stepplot(func2);
hold on
num2 = 100;
den2 = [1 8 100];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 25;
den2 = [1 8 25];
func2 = tf(num2, den2);
stepplot(func2)
hold on
num2 = 16;
den2 = [1 0 16];
func2 = tf(num2, den2);
stepplot(func2);
hold off
legend('\xi = 0','\xi = 0.4','\xi = 0.8','\xi = 1','Location','SouthEast');


