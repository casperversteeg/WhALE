clear all; close all; clc;

Xt = [];
% Read csv file
for i = 0:162
    X = readmatrix(strcat('gen',num2str(i),'.csv'));
    Xt = [Xt; X];
%     dotsize = 10;
% 
%     Z = X(:,3);
%     Y = X(:,2);
%     X = X(:,1);
% 
%     figure;
%     scatter3(X, Y, Z, dotsize, Z,'filled');
%     view(2);
%     ax = gca;
%     ax.TickLabelInterpreter = 'latex';
%     xlabel("$x$",'interpreter','latex');
%     ylabel('$y$','interpreter','latex');
%     zlabel('$Q$','interpreter','latex');
%     title(strcat('Generation ', num2str(i)),'interpreter','latex');
%     xlim([-0.1,0.1]); ylim([-0.1,0.1]);
end

% Xt = readmatrix('gen161.csv');
dotsize = 10;

Zt = Xt(:,3);
Yt = Xt(:,2);
Xt = Xt(:,1);

figure;
scatter3(Xt, Yt, Zt, dotsize, Zt,'filled');
ax = gca;
ax.TickLabelInterpreter = 'latex';
xlabel("$x$",'interpreter','latex');
ylabel('$y$','interpreter','latex');
zlabel('$Q$','interpreter','latex');

% F = scatteredInterpolant(X,Y,Z);
% sizing = 1e-3;
% [x,y] = meshgrid(min(X):sizing:max(X),...
%     min(Y):sizing:max(Y));
% z = F(x,y);
% figure;
% surf(x,y,z); shading interp;
% ax = gca;
% ax.TickLabelInterpreter = 'latex';
% xlabel("$x$",'interpreter','latex');
% ylabel('$y$','interpreter','latex');
% zlabel('$Q$','interpreter','latex');
