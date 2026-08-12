function [svect, Q] = flutterPK_o0(V, rho, aref, l_a, Esys, Asys, selj)
%
%
% Compute eigenvectors Q and eigenvalues s of aeroelastic system at speed V
%
%
%-----------------------------------------------------------------------------
% 30-06-2016
%

% Structural modes used
nj = Esys.nj;
ne = Esys.ne;

if nargin >= 7 && ~isempty(selj)
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


% Reference time
ta = l_a/V;

Mach = V/aref;

% Dynamic pressure
qinf = 0.5*rho*V^2;



tol = 1e-4;
nmax = 100;

svect = zeros(1, nh);
Q = zeros(nh, nh);


% Check for real roots
k = 0;
[RHam, IHamk] = aeroMatrixEval_o0(k, Mach, Asys.Qhh, Asys.kvect, Asys.Mvect, 2);

% A = [        zeros(nh,nh),               eye(nh,nh);
%      -Mhh\(Khh-qinf*RHam), -Mhh\(Chh-qinf*ta*IHamk)];
A = [                  zeros(nh,nh),           eye(nh,nh);
     -Esys.Mhh\(Esys.Khh-qinf*RHam),   -Esys.Mhh\Esys.Chh];


[X, lambda] = eig(A);
lambda = diag(lambda);
posReal = (imag(lambda) == 0);


nr = sum(posReal);

if nr > 0
	lreal = lambda(posReal);
	Xreal = X(:, posReal);

	% Discard repeated eigenvalues
	[lr, ilr] = unique(lreal);
	nrUsed = length(lr);

	% If unique eigenvalues are not enough use all the eigenvalues
	if nrUsed < nr/2
		[lr, ilr] = sort(lreal);
		nrUsed = length(lr);
	end

	% Use the most positive eigenvalues
	realEigUsed = lr(nrUsed - nr/2 + 1 : nrUsed);
	XrealUsed = Xreal(:,ilr(nrUsed - nr/2 + 1 : nrUsed));

	vect(1:nr/2) = realEigUsed;
	Q(:, 1:nr/2) = XrealUsed(1:nh,:);
end


% Complex eigenvalues
ni = nh - nr/2;

lambda = [ones(nr/2,1); lambda(imag(lambda)>0)];
[knew, ilc] = sort(imag(lambda)*ta);
lambda = lambda(ilc);


% Loop over eigenvalues with non-zero frequency
for iMode = (nr/2 + 1) : nh

	err = 1;
	iter = 0;

	% Primo tentativo: soluzione trovata cercando l'autovalore precedente
	k = knew(iMode);

	while err > tol && iter < nmax
      
		[RHam, IHamk] = aeroMatrixEval_o0(k, Mach, Asys.Qhh, Asys.kvect, Asys.Mvect, 2);
      
		A = [                    zeros(nh,nh),          eye(nh,nh);
		      -Esys.Mhh\(Esys.Khh - qinf*RHam),  -Esys.Mhh\(Esys.Chh - qinf*IHamk*ta)];


		[X, lambda] = eig(A);
		lambda = diag(lambda);
      
		[knew, ik] = sort(imag(lambda)*ta);

		knew = knew(nh + 1 : 2*nh);
		ik = ik(nh + 1 : 2*nh);

		err = abs(knew(iMode) - k);
		k = knew(iMode);

		iter = iter + 1;
	end


	% Update eigenvalues
	svect(iMode) = lambda(ik(iMode));
	Q(:,iMode) = X(1:nh, ik(iMode));
end


return
