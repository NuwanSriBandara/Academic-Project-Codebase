clc;
clear all;
close all;

[t,y] = ode23('hypothyroidism',[0 10],[81.2 6821 682.1]); %I(0) = 81.2 ; G(0) = 6821 ; H(0) = 682.1
plot(t,y);
axis tight;
title('Riggs Model - Hypothyroidism - Low Iodine Intake - 10 Days');
legend('Plasma Iodine','Gland Iodine','Hormonal Iodine');
xlabel('Time (days)');
ylabel('Iodine (ug)');
axis([0 10 -100 7000])