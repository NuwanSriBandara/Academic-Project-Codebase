function [minf,tm,hinf,th,ninf,tn] = hhrate(v)
%
% calculate the values of the rate constants for 
% a membrane depolarisation/hyperploarisation of v mV
% v > 0 = depolarisation
% v < 0 = hyperpolarisation
%

alphan = 0.01*(10-v)/(exp((10-v)/10)-1);
betan = 0.125*exp(-v/80);

alpham = 0.1*(25-v)/(exp((25-v)/10)-1);
betam = 4*exp(-v/18);

alphah = 0.07*exp(-v/20);
betah = 1/(exp((30-v)/10)+1);

tm = 1/(alpham+betam);
minf = alpham*tm;

th = 1/(alphah+betah);
hinf = alphah*th;

tn = 1/(alphan+betan);
ninf = alphan*tn;

