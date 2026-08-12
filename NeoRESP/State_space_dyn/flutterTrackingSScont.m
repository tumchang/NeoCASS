function [mat, unstableEig] = flutterTrackingSScont(Vvect, rho, aref, l_a, Esys, Asys, ...
                                     startingEig, selTracked, selj)
%
% Flutter computation for a system with a state space representation of 
% aerodynamic forces.
%
%--------------------------------------------------------------------------
% 30-06-2016
% 20-07-2016 Starting point selection modified
%

if length(Asys.mach)>1
	error('Mach number variation not available for SS computation');
end

% Structural modes used
nj = Esys.nj;
ne = Esys.ne;

if nargin >= 9 && ~isempty(selj)
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

	Asys.inputGroup.j = Asys.inputGroup.j(selj);
	Asys.outputGroup.j = Asys.outputGroup.j(selj);
else
	nh = nj + ne;
end

if ~exist('selTracked', 'var') || isempty(selTracked)
	selTracked = selj;
	indexTrackedLocal = 1:nj;
else
	[selTracked, indexTrackedLocal] = intersect(selj, selTracked);
end




%==========================================================================
% Calcolo di flutter 
%==========================================================================

% Extremes of speed interval to be studied
nV = length(Vvect);
V_init = Vvect(1);
V_fin  = Vvect(nV);


% Starting point ---------------------------------------------------------------
qinf = 0.5*rho*V_init^2;
ta = l_a/V_init;

% Create aeroservoelastic system
[E, A] = assemblySSAEmodel(rho, V_init, l_a, Esys, Asys, 'EA');

% Compute eigenvalues
[Q, lambda] = eig(A, E);
lambda = diag(lambda);




% Select only eigenvalues with non-negative imaginary part
pick = imag(lambda)>=0;
lambda = lambda(pick);
Q = Q(:,pick);

% Scaling eigenvectors (0.5*q'*q = 1)
alpha = sqrt(sum(Q.*Q, 1));
Q = sqrt(2)*Q*diag(1./alpha);


% Discard eigenvalues with negative imag part and duplicated eigenvalues
selImag = find(imag(lambda)>0);
[~, sorting] = sort(lambda(selImag));
selImag = selImag(sorting);

posReal = (imag(lambda) == 0);

nr = sum(posReal);

if nr > 0

	nrDesired = ceil(nr/2);

	lreal = lambda(posReal);

	posQ = find(posReal);

	% Discard repeated eigenvalues
	[lr, ilr] = unique(lreal);
	nrUsed = length(lr);


	% If unique eigenvalues are not enough use all the eigenvalues
	if nrUsed < nrDesired
		[lr, ilr] = sort(lreal);
		nrUsed = length(lr);
	end
	posQ = posQ(ilr);

	% Use the most positive eigenvalues
	realEigUsed = lr(nrUsed - nrDesired + 1 : nrUsed);
	posQ = posQ(nrUsed - nrDesired + 1 : nrUsed);

	reducedEig = [realEigUsed; lambda(selImag)];
	reducedQ = [Q(:,posQ), Q(:,selImag)];
end

lambda = reducedEig;
Q = reducedQ;

if ~exist('startingEig', 'var') || isempty(startingEig);
	% No initial guess provided, use all the eigenvalues with
	% frequency greater than zero and the most unstable real eigenvalues
	startingEig = lambda;
else
	startingEig = startingEig(selj);
end

% Flutter tracking -------------------------------------------------------------

mat = zeros(nV, length(selTracked));

odefun = @(v,X)          odefunFLSS(v, X, rho, aref, l_a, Esys, Asys);
NRfun  = @(v,X) NewtonFunctionsFLSS(v, X, rho, aref, l_a, Esys, Asys);

% Loop over eigenvalues
jMode = 0;

nTracked = length(selTracked);
fprintf('Running flutter computation for %d modes ...\n', nTracked);

selectLam = 1:length(lambda);

for jMode = 1:nTracked
	iMode = indexTrackedLocal(jMode);

	fprintf(' - mode %2d (%2d/%2d)\r', selTracked(iMode), jMode, nTracked);
   
	% Find the eigenvalue closest to that in startingEig
	distance = real(lambda(selectLam) - startingEig(iMode)).^2 + imag(lambda(selectLam) - startingEig(iMode)).^2;
	[~, lam_pos] = min(distance);
	X0 = [lambda(selectLam(lam_pos)); Q(:,selectLam(lam_pos))];
	selectLam = selectLam([1:lam_pos-1, lam_pos+1:end]);

	selection = zeros(length(lambda),1);
	selection(selectLam) = 1;

	% Avoid tracking eigenvalues associated to DOFs in e-set
	is_structural = abs(sum(Q(nj+1:nh,lam_pos)))<1e-8;
	is_zero = abs(X0(1))<1e-6;

	if is_structural && ~is_zero
		X = rkSolverCont(odefun, NRfun, Vvect, X0);
		mat(:,jMode) = conj(X(1,:))';
	else
		mat(:,jMode) = X0(1); 
	end
end
fprintf('\n');

% Check the most unstable mode at each velocity
unstableEig = zeros(nV,1);
for iV = 1:nV
	ta = l_a/Vvect(iV);

	% Create aeroservoelastic system
	[E, A] = assemblySSAEmodel(Vvect(iV), rho, l_a, Esys, Asys, 'EA');

	% Compute eigenvalues
	[Q, lambda] = eig(A, E);
	lambda = diag(lambda);
	pick = imag(lambda)>=0;

	% Find most unstable eigenvalue
	[mostUnstable, position] = max(real(lambda));

	unstableEig(iV) = lambda(position);

end


return
%===============================================================================




%*******************************************************************************

function X_v = odefunFLSS(v, X, rho, aref, l_a, Esys, Asys)
%
%
%
%-------------------------------------------------------------------
% 10-11-13
%


nX = length(X);

s = X(1);
x = X(2:nX);

ta = l_a/v;

Mach = v/aref;


qinf = 0.5*rho*v^2;


[E, A, E_v, A_v] = assemblySSAEmodel(v, rho, l_a, Esys, Asys, 'DV');


Jac = [E*x, E*s-A;  0, x'];

RHT = [-(E_v*s - A_v)*x; 0];

X_v = Jac\RHT;



return
%*******************************************************************************


%*******************************************************************************
function [F, Jac] = NewtonFunctionsFLSS(v, X, rho, aref, l_a, Esys, Asys)
%
%
%
%-------------------------------------------------------------------
% 10-11-13
%

nX = length(X);

s = X(1);
x = X(2:nX);

Mach = v/aref;

ta = l_a/v;


[E, A] = assemblySSAEmodel(v, rho, l_a, Esys, Asys, 'EA');


Jac = [E*x, E*s-A;  0, x'];

F = [(E*s-A)*x; 0.5*x'*x-1];

return
%*******************************************************************************




