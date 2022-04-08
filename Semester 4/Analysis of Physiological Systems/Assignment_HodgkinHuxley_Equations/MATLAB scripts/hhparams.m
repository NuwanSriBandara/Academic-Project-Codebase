function hhparams
% calculate neccessary model parameters

global g_na_max g_k_max g_l e_vr e_na e_k e_l; 
global tempc co_na ci_na co_k ci_k yo kt vclamp amp1 sramp; 
global minfr hinfr ninfr;
global g_na_vr g_k_vr;

rg = 8314.3;
fc = 96487;

rtf = rg*(tempc+273)/fc;

% calculate temperature scaling of rate constants

kt = 3^((tempc-6.3)/10);
 
% calculate resting conductances in mS/cm^2

[minfr tmr hinfr thr ninfr tnr] = hhrate(0);
g_na_vr = g_na_max*(minfr^3)*hinfr;
g_k_vr = g_k_max*(ninfr^4);

% set the equilibrium potentials - all in mV
 
e_na = rtf*log(co_na/ci_na);
e_k = rtf*log(co_k/ci_k);
e_vr = (g_na_vr*e_na + g_k_vr*e_k + g_l*e_l)/(g_na_vr + g_k_vr + g_l);

% determine if current clamp or voltage clamp

if (amp1~=0 | sramp~=0) & vclamp~=0;
	error('ambiguous combination of vclamp and amp1/sramp');
elseif amp1~=0 & sramp~=0;
	error('ambiguous combination of amp1 and sramp');
end;
 
% initial values as a column vector

yo = [e_vr; minfr; hinfr; ninfr];

