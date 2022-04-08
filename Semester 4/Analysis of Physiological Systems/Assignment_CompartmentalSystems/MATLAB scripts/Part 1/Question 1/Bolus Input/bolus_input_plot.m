clc;
clear all;
close all;

[t,y] = ode23('bolus_input',[0 4],[0 0]); % Time period = 4h ; Initial Values : i(0) = g(0) = 0 
plot(t,y);
axis tight;
title('Simple Plasma Glucose/Insulin Model - Bolus Input');
legend('Insulin','Glucose');
xlabel('Time (hours)');
ylabel('Insulin (U/kg) , Glucose (g/kg)');