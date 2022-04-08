% define neccessary constants for H-H equations

% define variables of global scope

global g_na_max g_k_max g_l e_vr e_na e_k e_l CM yo;
global delay1 delay2 sramp tempc width1 amp1 width2 amp2;
global co_na co_k ci_na ci_k kt vclamp;
global minfr hinfr ninfr
global g_na_vr g_k_vr ic;
global cmap numover odesolver;
global odeopt;

% some basic variables

tempc = 6.3;

% stimulus parameters

delay1 = 0;
delay2 = 0;
width1 = 40;
width2 = 0;
amp1 = 5; % microamps/cm^2
amp2 = 0;
sramp = 0; % microamps/(cm^2 ms)
vclamp = 0; % mV
ic = 0;

% membrane capacitance Cm microfarads/cm^2

CM = 1;

% default concentrations for squid axon in sea water - mmol/l

co_na = 491;
co_k = 20.11;
ci_na = 50;
ci_k = 400;

% set maximum channel conductances in mS/cm^2

g_na_max = 120;
g_k_max = 36;
g_l = 0.3;

% unchanging leakage reversal potential

e_l =  -49;

% basic text colour map

numover = 0;
cmap = [	'y'	% yellow
		'b'	% blue
		'r'	% red
		'g'	% green
		'c'	% cyan
		'm'	% magenta
	];
  
    
% determine ode solver and define error tolerances

mver = version;

if str2num(mver(1)) >= 5
    odesolver = 'ode15s(fh,ts,yo,odeopt)';
    odeopt = odeset('RelTol',1e-6,'AbsTol',1e-9,'Refine',4);
else
    odesolver = 'ode45(fh,ts(1),ts(2),yo)';
end