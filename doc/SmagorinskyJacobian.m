clear all; close all; clc;

syms x y z u v w N(x,y,z) Nx Ny Nz ui vi wi;

u = N*ui;
v = N*vi;
w = N*wi;
% Nx = diff(N,x);
% Ny = diff(N,y);
% Nz = diff(N,z);

% Gu = [dudx; dudy; dudz]; Gv = [dvdx; dvdy; dvdz]; Gw = [dwdx; dwdy; dwdz];
Gu = ui * [Nx; Ny; Nz]; 
Gv = vi * [Nx; Ny; Nz]; 
Gw = wi * [Nx; Ny; Nz];

Sij = 1/2 * ([Gu Gv Gw] + transpose([Gu Gv Gw]));

% s = 0;

% for i = 1:3
%     for j = 1:3
%         s = s + Sij(i,j)*Sij(i,j);
%     end
% end

s = sum(sum(Sij.*Sij));
s_sqrt = sqrt(2*s);

s_sqrt = simplify(s_sqrt,100);
pretty(s_sqrt);

dsdu = diff(s_sqrt, ui); simplify(dsdu, 100); pretty(dsdu);
dsdv = diff(s_sqrt, vi); simplify(dsdv, 100); pretty(dsdv);
dsdw = diff(s_sqrt, wi); simplify(dsdw, 100); pretty(dsdw);