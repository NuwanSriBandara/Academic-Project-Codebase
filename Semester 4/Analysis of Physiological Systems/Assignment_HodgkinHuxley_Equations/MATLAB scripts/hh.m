function yprime=hh(t,y)
% H-H equations
%
% ic is a constant stimulating current in uA/cm^2
% suggested ranges are 5 to 200
%
% yprime(1) = g_na_max*y(2)^3*y(3)*(e_na-y(1)) + g_k_max*y(4)^4*(e_k-y(1)) + g_l*(e_l-y(1)) + jei(t)
% yprime(2) = (minf-y(2))/tm
% yprime(3) = (hinf-y(3))/th
% yprime(4) = (ninf-y(4))/tn

% declare global variables to be used

global g_na_max g_k_max g_l e_vr e_na e_k e_l CM;
global amp1 vclamp ic sramp kt;

[minf tm hinf th ninf tn] = hhrate(y(1)-e_vr);

if amp1~=0 | sramp~=0;  % ambiguity of options has already been checked in hhparams
	jm = (g_na_max*(y(2)^3)*y(3)*(e_na-y(1)) + g_k_max*(y(4)^4)*(e_k-y(1)) + g_l*(e_l -y(1)))/CM;
	if sramp~=0;
		yp = sramp*t + jm;
	else
		yp = ic + jm;
	end;
elseif vclamp~=0;
	yp = 0;
end;

% calculate differentials

yprime = [yp; 
          kt*(minf - y(2))/tm;
          kt*(hinf - y(3))/th;
          kt*(ninf - y(4))/tn;];
