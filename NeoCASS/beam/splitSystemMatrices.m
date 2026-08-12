function [Mzz, Kzz, Tgf, Tfz, nd, nt] = splitSystemMatrices(DOFtable, Kbb, Mbb, Gm, MPCtable)
%
% [Mzz, Kzz, Tgf, Tfz] = splitSystemMatrices(DOFtable, Kgg, Mgg, Gm, MPCtable)
%
% Tgf: transformation matrix from g-set (total structural DOFs) to f-set 
%      (free DOFs) 
%
% Tfz: transformation matrix from f-set to z-set (f-set recombined to 
%      separate deformable from rigid movements)
%
% Mzz, Kzz : Mass and stiffness matrix referred to z-set
%
%
% uz = [ud, ut]
% 
% ud : deformation movements
% ut : rigid movements
% 
%
%-------------------------------------------------------------------------------
% 30-08-13
%

indexLO = 0;
indexSUPORT = 1;
indexSPC = 3;
indexMPC = 4;
indexRBE0 = 5;
indexAutoSPC = 6;

% Reading DOFtable -------------------------------------------------------------
pickm = (DOFtable == indexMPC) | (DOFtable==indexRBE0);    % MPC constrained
pickl = (DOFtable == indexLO);     % Left-over
pickr = (DOFtable == indexSUPORT); % SUPORT
picks = (DOFtable == indexSPC);    % SPC constrained

pickn = ~pickm;

ng = length(DOFtable);
nn = sum(pickn);
nm = sum(pickm);
ns = sum(picks);
nl = sum(pickl);
nr = sum(pickr);

nf = nl + nr;

% Transformation from ug to un -------------------------------------------------
%
% ug = Tgn * un = Sgnm*[un;um] = Sgnm * [I; Gm] * un
%
% Sgnm : reorder ug to separate un from um
%

Sgnm = sparse(eye(ng,ng));
Sgnm = [Sgnm(:, pickn), Sgnm(:, pickm)]; 

Tgn = sparse(Sgnm*[eye(nn, nn); Gm]);

Knn = Kgg(pickn, pickn) + Kgg(pickn, pickm)*Gm ...
    + Gm'*Kgg(pickm, pickn) + Gm'*Kgg(pickm, pickm)*Gm;
    
Mnn = Mgg(pickn, pickn) + Mgg(pickn, pickm)*Gm ...
    + Gm'*Mgg(pickm, pickn) + Gm'*Mgg(pickm, pickm)*Gm; 
    

% Transformation from un to uf -------------------------------------------------
%
% us = 0
%
% un = Snfs * [uf; us] = Snfs * [I; 0] * uf
%
% un = Tnf * uf 
%
% Snfs : reorder un to separate uf from us
%

doftablen = DOFtable(pickn);
pickn2s = (doftablen == indexSPC);
pickn2f = (doftablen == indexSUPORT) | (doftablen == indexLO);

Snfs = sparse(eye(nn,nn));
Snfs = [Snfs(:, pickn2f), Snfs(:, pickn2s)];

Tnf = sparse(Snfs(:, 1:nf));

Kff = Knn(pickn2f, pickn2f);
Mff = Mnn(pickn2f, pickn2f);


% Division of uf in ul and ur --------------------------------------------------
%
% uf = Sflr * [ul; ur]
%
% Sflr : reorder uf to separate ul from ur
%

usetf = usetn(pickn2f);
pickf2l = (usetf == 2);
pickf2r = (usetf == 8);

Sflr = sparse(eye(nf,nf));
Sflr = [Sflr(:, pickf2l), Sflr(:, pickf2r)];

Kll = Kff(pickf2l, pickf2l);
Klr = Kff(pickf2l, pickf2r);
Krr = Kff(pickf2r, pickf2r);

Mll = Mff(pickf2l, pickf2l);
Mlr = Mff(pickf2l, pickf2r);
Mrr = Mff(pickf2r, pickf2r);


% Coordinate transformation to separate rigid movements ------------------------
% (decoupling with respect to elastic energy (matrix K))
%
% uf = Sflr*[ul; ur] = Tfz * [ud; ut] = Tfz * uz
%

Dm = - Kll\Klr;

Tfz = sparse(Sflr * [eye(nl,nl), Dm; zeros(nr, nl), eye(nr, nr)]);

Kzz = Tfz'*Kff*Tfz;
Mzz = Tfz'*Mff*Tfz;

% Total transformation ---------------------------------------------------------
%
% ug = Tgz * uz
%
% ug = Tgf * uf
%

Tgz = Tgn*Tnf*Tfz;
Tgf = Tgn*Tnf;



return
