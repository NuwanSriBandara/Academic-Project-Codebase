function [t,y] = hode(fh,ts,yo)

% [t,y] = hode(fh,ts,yo)
% a simple wrapper for ode45 which handles the case of
% ts(1) == ts(2)

global odesolver odeopt;

if ts(1) ~= ts(2)
    [t,y] = eval(odesolver);
else
    t = ts(1);
    y = yo';
end