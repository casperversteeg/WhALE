clear all; close all; clc;

rho     = 2500;                                 % density [kg/m3]
E       = 70e9;                                 % Young's modulus [Pa]
nu      = 0.2;                                  % Poisson's ratio [-]
mu      = E/(2*(1+nu));                         % Shear modulus [Pa]
lambda  = E*nu/(1+nu)/(1-2*nu);                 % Lame's second param [Pa]
Cs      = sqrt(mu/rho);                         % Shear wave speed [m/s]
KID     = 0.81e6;                               % Mode-I SIF [Pa.sqrt(m)]
KIID    = 0.00e6;                               % Mode-II SIF [Pa.sqrt(m)]
sigmac  = 70e6;                                 % Critical strength [Pa]

a       = 8e-3;                                 % Initial crack length [m]

v       = 1400;                                 % Crack velocity [m/s]

beta2   = mu/rho;
alpha2  = (lambda + 2*mu)/rho;
eta     = beta2/alpha2;
zeta    = @(x) x.^2/beta2;
f       = @(x) zeta(x).^3 - 8*zeta(x).^2 + 8*zeta(x)*(3-2*eta)-16*(1-eta);

CR      = fzero(f, 3000);

sigma   = KID/sqrt(pi*a)/(1-v/CR);