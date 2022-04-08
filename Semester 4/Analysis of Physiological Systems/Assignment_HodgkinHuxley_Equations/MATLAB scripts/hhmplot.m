function hhmplot(to,tf,ol)
%
% Numerical solution of the Hodgkin Huxley equations
% for parameters as set from file hhconst
%
% Plots include V,m,h,n
%
% ol = 1 -> overlay ol = 0 -> replace

global yo e_vr minfr hinfr ninfr;
global amp1 amp2 width1 width2 delay1 delay2 ic vclamp;
global cmap numover;

% update all neccessary precalculated parameters

hhparams;

[ti,yi] = hode('hh',[to,to+delay1],yo);  % do not really need to integrate here but it makes the code more readable
len = length(yi(:,1));
yo = yi(len,:)';
if vclamp~=0;
		yo = [vclamp; yo(2:4)];
		[t1,y1] = hode('hh',[to+delay1,to+delay1+width1],yo);
		len = length(t1);
		yo = [e_vr; y1(len,2:4)'];
		[t2,y2] = hode('hh',[to+delay1+width1,tf],yo);
		t = [ti;t1;t2];
		y = [yi;y1;y2];
elseif amp1~=0;
		ic = amp1;
		[t1,y1] = hode('hh',[to+delay1,to+delay1+width1],yo);
		len = length(t1);
		yo = y1(len,1:4)';
		ic = 0;
		[t2,y2] = hode('hh',[to+delay1+width1,to+delay1+width1+delay2],yo);
		len = length(t2);
		yo = y2(len,1:4)';
		ic = amp2;
		[t3,y3] = hode('hh',[to+delay1+width1+delay2,to+delay1+width1+delay2+width2],yo);
		len = length(t3);
		yo = y3(len,1:4)';
		ic = 0;
		[t4,y4] = hode('hh',[to+delay1+width1+delay2+width2,tf],yo);
		t = [ti;t1;t2;t3;t4];
		y = [yi;y1;y2;y3;y4];
end
		
% extend the time axis a bit to indicate when the stimulus was applied

t=[-0.1*(tf-to);to;t];
y=[e_vr minfr hinfr ninfr;e_vr minfr hinfr ninfr;y];
to=-0.1*(tf-to);

cline = 'y';
figure(1);
set(1,'Position',[200 150 620 600],'Color','k');
if ol;
	cindx = rem(numover,6);
	cline = cmap(cindx+1);
	subplot(2,2,1);,hold on,subplot(2,2,2);,hold on,subplot(2,2,3);,hold on,subplot(2,2,4);hold on;
	numover = numover + 1;
else
	numover = 1;
	subplot(2,2,1);,hold off,subplot(2,2,2);,hold off,subplot(2,2,3);,hold off,subplot(2,2,4);hold off;
end;

subplot(2,2,1);,plot(t,y(:,1),cline);
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('V_m (mV)','Color','w'),axis([to tf -100 50]);
title('Membrane potential','Color','w');
subplot(2,2,2);,plot(t,y(:,2),cline);
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('m(t) (dimensionless)','Color','w'),axis([to tf 0 1]);
title('Sodium activation gate','Color','w');
subplot(2,2,3);,plot(t,y(:,3),cline);
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('h(t) (dimensionless)','Color','w'),axis([to tf 0 1]);
title('Sodium inactivation gate','Color','w');
subplot(2,2,4);,plot(t,y(:,4),cline);
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('n(t) (dimensionless)','Color','w'),axis([to tf 0 1]);
title('Potassium gate','Color','w');
