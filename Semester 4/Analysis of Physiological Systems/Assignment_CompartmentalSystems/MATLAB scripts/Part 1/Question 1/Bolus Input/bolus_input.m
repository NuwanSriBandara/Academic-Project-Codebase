function y2 = bolus_input(t,y);
y2 = [-0.8 0.2;-5 -2]*y + [0 1-sign(t)]';