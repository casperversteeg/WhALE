clear all; close all; clc;

rho     = 2500;                                 % density [kg/m3]
E       = 70e9;                                 % Young's modulus [Pa]
nu      = 0.2;                                  % Poisson's ratio [-]
mu      = E/(2*(1+nu));                         % Shear modulus [Pa]
Cs      = sqrt(mu/rho);                         % Shear wave speed [m/s]
KID     = 0.75e6;                               % Mode-I SIF [Pa.sqrt(m)]
KIID    = 0.00e6;                               % Mode-II SIF [Pa.sqrt(m)]
sigmac  = 248e6;                                % Critical strength [Pa]

v       = 1:1500;                               % Crack velocity [m/s]

aL      = sqrt(1 - rho*(1-nu)/2/mu * v.^2);     % Parameter [-]
aS      = sqrt(1 - rho/mu * v.^2);              % Parameter [-]
D       = 4 * aL .* aS - (1 + aS.^2).^2;        % Parameter [-]

AI      = v.^2 .* aL / (1-nu) / (Cs^2) ./ D;    % Parameter [-]
AII     = v.^2 .* aS / (1-nu) / (Cs^2) ./ D;    % Parameter [-]

Gc      = 1/E * (AI * (KID^2) + AII * (KIID^2));% Energy release rate [J/m2]
l       = 27/256 * E * Gc / sigmac^2;


subplot(1,2,1);
plot(v, Gc); grid on;
xlabel('$v$ ($\mathrm{m\cdot s^{-1}}$)','interpreter','latex');
ylabel('$\mathcal{G}_c$ ($\mathrm{J\cdot m^{-2}}$)','interpreter','latex');
ax = gca; ax.TickLabelInterpreter = 'latex';
subplot(1,2,2);
plot(v, l); grid on;
xlabel('$v$ ($\mathrm{m\cdot s^{-1}}$)','interpreter','latex');
ylabel('$\ell$ ($\mathrm{m}$)','interpreter','latex');
ax = gca; ax.TickLabelInterpreter = 'latex';
