function [DIH, SPN, CHD, CX, CY, CZ, TPR, SWP] = CAERO_nas2neo(P1, P2, c1, c2)
%
%  [DIH, SPN, CHD, CX, CY, CZ, TPR, SWP] = nas2neo_CAERO(P1, P2, c1, c2)
%
% DIH : angolo tra il piano x-y (piano orizzontale) e il piano della superficie
%       aerodinamica ( piano contenente l'asse x e passante per i punti P1 e P2)
%       angolo misurato in gradi
%
% SPN : apertura misurata nel piano della superficie aerodinamica
%
% TPR : rapporto corda di estremità - corda di radice
%
% SWP : angolo di freccia al 25% della corda, misurato nel piano della 
%       superficie aerodinamica (angolo misurato in gradi)

CHD = c1;

CX = P1(1);
CY = P1(2);
CZ = P1(3);

DY = P2(2) - P1(2);
DZ = P2(3) - P1(3);

DIH = atan(DZ/DY) * 180/pi;

%SPN = sqrt(DY^2 + DZ)^2)*sign(DY)*sign(DZ);
SPN = cos(DIH*pi/180)*DY  +  sin(DIH*pi/180)*DZ;

TPR = c2/c1;

SWP = atan((P2(1)-P1(1) + 0.25*(c2-c1))/SPN) * 180/pi;

return
