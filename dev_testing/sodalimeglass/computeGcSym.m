clear all; close all; clc;

syms rho E v nu KID sigmac;
assume([rho E v nu KID sigmac], {'positive','real'});
assumeAlso(0 < nu < 0.5);

mu = E/(2*(1+nu));
Cs = sqrt(mu/rho);
KIID = 0;

aL      = sqrt(1 - rho*(1-nu)/2/mu * v.^2);     % Parameter [-]
aS      = sqrt(1 - rho/mu * v.^2);              % Parameter [-]
D       = 4 * aL .* aS - (1 + aS.^2).^2;        % Parameter [-]

AI      = v.^2 .* aL / (1-nu) / (Cs^2) ./ D;    % Parameter [-]
AII     = v.^2 .* aS / (1-nu) / (Cs^2) ./ D;    % Parameter [-]

Gc      = 1/E * (AI * (KID^2) + AII * (KIID^2));% Energy release rate [J/m2]
l       = 27/256 * E * Gc / sigmac^2;