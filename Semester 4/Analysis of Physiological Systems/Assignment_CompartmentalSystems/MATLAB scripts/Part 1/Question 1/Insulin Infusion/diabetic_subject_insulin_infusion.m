function y4 = diabetic_subject_insulin_infusion(t,y);
y4 = [-0.8 0.02;-5 -2]*y + [0.1 1]';%Insulin Infusion = 0.1 U/kg/h