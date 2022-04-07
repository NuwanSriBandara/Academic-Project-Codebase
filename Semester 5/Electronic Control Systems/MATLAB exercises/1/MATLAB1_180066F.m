clc;
close all;

num_1 = [2 5 3 6];
den_1 = [1 6 11 6];

[r1,p1,k1] = residue(num_1,den_1)

num_2 = [0 1 2 3];
den_2 = [1 3 3 1];

[r2,p2,k2] = residue(num_2,den_2)

syms a b t;
f = (t^2)*sin(a*t);
laplace(f)

