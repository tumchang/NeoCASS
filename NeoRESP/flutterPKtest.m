function [svect, Q] = flutterPKtest(V, rho, aref, l_a, fdAEmodel_base)
%
%
% Compute eigenvectors Q and eigenvalues s of aeroelastic system at speed V
%
%
%-----------------------------------------------------------------------------
% 30-06-2016
%


nh = fdAEmodel_base.dim.nh;
ne = fdAEmodel_base.dim.ne;

% Reference time
ta = l_a/V;

Mach = V/aref;

% Dynamic pressure
qinf = 0.5*rho*V^2;

% Start the root finding procedure +++++++++++++++++++++++++++++++++++++++++++++
tol = 1e-4;
nmax = 100;

svect = zeros(1, nh);
Q = zeros(nh, nh);


% Check for real roots
k = 0;
[Eb, Ab] = aemodelFD_get(k, Mach, qinf, fdAEmodel_base);


[X, lambda] = eig(Ab,Eb);
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
      
		[Eb, Ab] = aemodelFD_get(k, Mach, qinf, fdAEmodel_base);

		[X, lambda] = eig(Ab, Eb);
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
