close all;
clear all;
clc;

t = 0:0.001:10;
g_t = (-(4/13).*cos((0.8).*t) + (37/52).*sin((0.8).*t)).*exp((-1.4).*t) + 4/13;
i_t = (-(1/13).*cos((0.8).*t) - (7/52).*sin((0.8).*t)).*exp((-1.4).*t) + 1/13;
f_t = [i_t;g_t ];
figure;
plot(t,f_t)
axis tight;
axis([0 10 0 0.4]);
title('Stability Curves of Glucose and Insulin');
legend('i(t) - Insulin ','g(t) - Glucose');
xlabel('t');
ylabel('i(t)/g(t)');