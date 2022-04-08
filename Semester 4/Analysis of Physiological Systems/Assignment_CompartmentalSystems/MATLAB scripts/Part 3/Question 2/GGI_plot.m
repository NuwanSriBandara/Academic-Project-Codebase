clc;
clear all;
close all;

[t,y] = ode23('GGI',[0 4],[0 0 0]);
plot(t,y);
axis tight;
title('Glucose Glucagon Insulin model - Step Input');
legend('Glucose','Glucagon','Insulin');
xlabel('Time (h)');
ylabel('Glucagon (g/kg) & Insulin (g/kg) & Glucose (g/kg)');
