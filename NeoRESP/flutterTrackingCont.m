function mat = flutterTrackingCont(Vvect, rho, aref, l_a, Esys, Asys, selTracked, selj)
%
%
% Flutter tracking using continuation method. Spline interpolation of Qhh, 
% second order approximation of Qhh(p). Mach variation with flight speed 
% considered.
% 
%
%
%--------------------------------------------------------------------------
% 30-06-2016
%


% Structural modes used
nj = Esys.nj;
ne = Esys.ne;

if nargin >= 8 && ~isempty(selj)
	selj = selj(selj<=nj);
	selh = [reshape(selj, [1,length(selj)]), nj+(1:ne)];

	nj = length(selj);
	nh = length(selh);

	% Set matrices 
	Esys.Mhh = Esys.Mhh(selh,selh);
	Esys.Chh = Esys.Chh(selh,selh);
	Esys.Khh = Esys.Khh(selh,selh);
	Esys.nj = nj;
	Esys.ne = ne;

	Asys.Qhh = Asys.Qhh(selh,selh,:,:);
else

	nh = nj + ne;
end

if nargin < 7 || isempty(selTracked)
	selTracked = 1:nj;
end


nk = length(Asys.kvect);
nM = length(Asys.Mvect);
nV = length(Vvect);



% Get coefficients for spline interpolation of Qhh matrix (over reduced frequencies)
MR = zeros(nh, nh, nk, nM);
MI = zeros(nh, nh, nk, nM);

for iM = 1:nM
	[DR(:,:,:,iM), DI(:,:,:,iM)] = aeroMatrixSpline_get(Asys.Qhh(:,:,:,iM), Asys.kvect, 1);
end

Asys.DR = DR;
Asys.DI = DI;


%==========================================================================
% Flutter computation
%==========================================================================

% Extremes of speed interval to be studied
V_init = Vvect(1);
V_fin  = Vvect(nV);


% Computing starting point with PK method 
V = V_init;


% [s, Q] = PKcomputation_o2(V, rho, n, sys);
[s, Q] = flutterPK_o0(V, rho, aref, l_a, Esys, Asys);


if Esys.ne>0
	% Empirical division between structural modes and modes associated to EPOINTs
	pick = abs(sum(Q(nj+1:nh,:),1))<1e-5;
else
	pick = ones(1,nh); 
end

% Starting flutter tracking

mat = zeros(nV, length(selTracked));

odefun = @(v,X)        odefunFL(v, X, rho, aref, l_a, Esys, Asys);
NRfun  = @(v,X) NewtonFunctions(v, X, rho, aref, l_a, Esys, Asys);


% Loop over eigenvalues
jMode = 0;

% Select modes to track among the used modes
[selTracked, indexTrackedLocal] = intersect(selj, selTracked);

nTracked = length(selTracked);

fprintf('Running flutter computation for %d modes ...\n', nTracked);

for jMode = 1:nTracked

	iMode = indexTrackedLocal(jMode);

	% Mode location expressed in original set
	fprintf(' - mode %2d (%2d/%2d)\r', selTracked(jMode), jMode, nTracked);

	if pick(iMode)

		% Mode is normalized in order to have 0.5*q'*q = 1
		X0 = [s(iMode); sqrt(2)*Q(:,iMode)/norm(Q(:,iMode))];   

		X = rkSolverCont(odefun, NRfun, Vvect, X0);
		mat(:,jMode) = conj(X(1,:))';

	else

		if abs(imag(s(iMode))) < 1e-5
			s(iMode) = real(s(iMode));
		end

		mat(:,jMode) = s(iMode);
	end
end
fprintf('\n');



return
%===============================================================================




%*******************************************************************************

function X_v = odefunFL(v, X, rho, aref, l_a, Esys, Asys)
%
% l_a  = reference length
% aref = reference sound speed
%
%
%-------------------------------------------------------------------
% 22-08-13
%

nh = length(X)-1;

s = X(1);
q = X(2:nh+1);

ta = l_a/v;

Mach = v/aref;

p = s*ta;
k = imag(p);
g = real(p);

qinf = 0.5*rho*v^2;

% Aerodynamic matrices
if k<min(Asys.kvect)
	[Ham, Ham_p, Ham_M] = aeroMatrixEvalDer_o0(p, Mach, Asys.Qhh, Asys.kvect, Asys.Mvect);
else
	[Ham, Ham_p, Ham_M] = aeroMatrixSpline_interp(Asys.Qhh, Asys.kvect, Asys.Mvect, p, Mach, Asys.DR, Asys.DI);
end


F1 = s^2*Esys.Mhh + Esys.Chh*s + Esys.Khh - qinf*Ham;

F1_s = 2*s*Esys.Mhh + Esys.Chh - qinf*ta* Ham_p;

F1_v = -rho*v*Ham + qinf*s*ta/v* Ham_p - qinf/aref*Ham_M;

A = [F1_s*q, F1;  0, q'];

B = [-F1_v*q; 0];

X_v = A\B;


return
%*******************************************************************************


%*******************************************************************************
function [F, Jac] = NewtonFunctions(v, X, rho, aref, l_a, Esys, Asys)
%
%
%
%-------------------------------------------------------------------
% 16-09-13
%

nh = length(X)-1;


s = X(1);
q = X(2:nh+1);

ta = l_a/v;

Mach = v/aref;

p = s*ta;
k = imag(p);
g = real(p);

qinf = 0.5*rho*v^2;

% Aerodynamic matrices
if k<min(Asys.kvect)
	[Ham, Ham_p, Ham_M] = aeroMatrixEvalDer_o0(p, Mach, Asys.Qhh, Asys.kvect, Asys.Mvect);
else
	[Ham, Ham_p, Ham_M] = aeroMatrixSpline_interp(Asys.Qhh, Asys.kvect, Asys.Mvect, p, Mach, Asys.DR, Asys.DI);
end


F1 = s^2*Esys.Mhh + Esys.Chh*s + Esys.Khh - qinf*Ham;

F1_s = 2*s*Esys.Mhh + Esys.Chh - qinf*ta* Ham_p;

Jac = [F1_s*q, F1;  0, q'];

F = [F1*q; 0.5*q'*q-1];

return
%*******************************************************************************
