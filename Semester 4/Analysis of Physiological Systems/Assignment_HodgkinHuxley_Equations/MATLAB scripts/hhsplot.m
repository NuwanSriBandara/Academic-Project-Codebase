function [qna,qk,ql]=hhsplot(to,tf)
%
% Numerical solution of the Hodgkin Huxley equations
% for parameters as set from file hhconst
%
% Plots include V,m,h,n,j_na,j_k, j_cl and  stimulus
%

global yo e_vr minfr hinfr ninfr;
global g_na_max g_k_max g_l;
global e_na e_k e_l e_vr;
global g_na_vr g_k_vr;
global delay1 amp1 width1;
global width2 amp2 delay2 ic vclamp;

% update all neccessary precalculated parameters

hhparams;

[ti,yi] = hode('hh',[to,to+delay1],yo);  % do not really need to integrate here but it makes the code more readable
yo = yi';
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

gna = g_na_max*(y(:,2).^3).*y(:,3);
gk = g_k_max*(y(:,4).^4);

jna = gna.*(e_na-y(:,1));
jk = gk.*(e_k-y(:,1));
jcl = g_l*(e_l-y(:,1));

jnar = g_na_vr*(e_na-e_vr);
jkr = g_k_vr*(e_k-e_vr);
jclr = g_l*(e_l-e_vr);

% calculate total charge transferred per ion over the interval [to,tf]

qna=-trapz(t,jna);
qk=-trapz(t,jk);
ql=-trapz(t,jcl);
 
% extend the time axis a bit to indicate when the stimulus was applied

t=[-0.1*(tf-to);to;t];

ics=[-0.1*(tf-to) 0;delay1 0;delay1 amp1;delay1+width1 amp1;delay1+width1 0;delay1+width1+delay2 0;delay1+width1+delay2 amp2;delay1+width1+delay2+width2 amp2;delay1+width1+delay2+width2 0;tf 0];
y=[e_vr minfr hinfr ninfr;e_vr minfr hinfr ninfr;y];
gi = [g_na_vr g_k_vr;g_na_vr g_k_vr;gna gk];
jm=[jnar jkr jclr;jnar jkr jclr;jna jk jcl];
to=-0.1*(tf-to);


figure(2);
set(2,'Position',[200 150 620 600],'Color','k');

subplot(2,2,1),plot(ics(:,1),ics(:,2),'y-');
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('Ic (microamp/cm^2)','Color','w'),axis([to tf 1.1*min([0 amp1 amp2]) 1.1*max([amp1 amp2])]);
title('Stimulus current','Color','w');
subplot(2,2,2),plot(t,y(:,1),'y-');
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('V_m (mV)','Color','w'),axis([to tf -100 50]);
title('Membrane potential','Color','w');
subplot(2,2,3),plot(t,gi(:,1),'r-',t,gi(:,2),'b-');
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('G (mS/cm^2)','Color','w'),axis([to tf -5 40]);
title('Ionic conductances','Color','w'),legend('Gna','Gk');
subplot(2,2,4),plot(t,-0.001*jm(:,1),'r-',t,-0.001*jm(:,2),'b-',t,-0.001*jm(:,3),'g-');
set(gca,'Color','k','XColor','w','YColor','w');
xlabel('time (ms)','Color','w'),ylabel('J (mA/cm^2)','Color','w'),axis([to tf -1 1]);
title('Ionic currents','Color','w'),legend('Jna','Jk','Jcl');
