clear all; close all; clc; 

syms y U0; h = 4.1; 
U(y) = U0*(((y+h/2)*(y-h/2))/(-h/2));

Ubar(y) = 1/h * int(U,y, -h/2, h/2);

U0 = solve(Ubar == 1, U0);

U(y) = eval(U);
fplot(U, [-h/2, h/2])

