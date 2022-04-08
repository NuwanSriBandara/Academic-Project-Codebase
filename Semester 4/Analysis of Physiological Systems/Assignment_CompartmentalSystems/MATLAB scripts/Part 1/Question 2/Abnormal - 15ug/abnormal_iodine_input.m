function y2 = abnormal_iodine_input(t,y);
y2 = [-2.52 0 .08;.84 -.01 0;0 .01 -.1]*y + [15 0 0]'; % Abnormal/Reduced Iodine Input = 15ug/d