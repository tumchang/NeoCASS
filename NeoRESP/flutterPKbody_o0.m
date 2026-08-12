function [svect, Q] = flutterPKbody_o0(V, rho, aref, l_a, Esys, Asys, selj, ...
                                       e0, v0OverVinf, edot0, angleCoord)
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


% Get parameters dependent on the flight condition

% TODO : check on rigid coordinates
selectRigid = 1:6;
selectDefo  = 7:nh;

v0 = v0OverVinf*V;


HamBody = getHamBodyCoord_v10(Asys.Qhh, Asys.kvect, selectRigid, ta, e0, v0, edot0, angleCoord);

%Qhf = QhhFlMecc(Asys.Qhh, Asys.kvect, l_a*2, [3,5]);



[T1hat, T2hat, T3hat] = iner2body(e0, v0, edot0, angleCoord);

T1 = eye(2*nh,2*nh);
T2 = eye(2*nh,2*nh);
T3 = zeros(2*nh,2*nh);

posRigid = [selectRigid, nh+selectRigid];

T1(posRigid,posRigid) = T1hat;
T2(posRigid,posRigid) = T2hat;
T3(posRigid,posRigid) = T3hat;


% Start the root finding procedure +++++++++++++++++++++++++++++++++++++++++++++
tol = 1e-4;
nmax = 100;

svect = zeros(1, nh);
Q = zeros(nh, nh);


% Check for real roots
k = 0;
[RHam, IHamk] = aeroMatrixEval_o0(k, Mach, HamBody, Asys.kvect, Asys.Mvect, 2);

Ei = [  eye(nh,nh), zeros(nh,nh);
      zeros(nh,nh),     Esys.Mhh];


Ai_elas = [ zeros(nh,nh), eye(nh,nh);
              -Esys.Khh,  -Esys.Chh];

Eb = Ei*T2;
Ab_elas = Ai_elas*T1 - Ei*T3;

Ab = Ab_elas;
Ab(nh+(1:nh), [selectDefo, nh + selectRigid]) = Ab(nh+(1:nh), [selectDefo, nh + selectRigid]) + qinf*RHam(:,[selectDefo, selectRigid]);


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
      
		Ham = aeroMatrixEval_o0(k, Mach, HamBody, Asys.kvect, Asys.Mvect, 1);

		Ab = Ab_elas;
		Ab(nh+(1:nh), [selectDefo, nh + selectRigid]) = Ab(nh+(1:nh), [selectDefo, nh + selectRigid]) + qinf*Ham(:,[selectDefo, selectRigid]);

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
