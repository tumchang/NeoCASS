function [Qp, Qp_p, Qp_M] = aeroMatrixSpline_interp(Qhh, kvect, Mvect, p, Mach, DR, DI)
%
%
% [Qp, Qp_p, Qp_M] = aeroMatrixSpline_interp(Qhh, kvect, Mvect, p, Mach, DR, DI)
%
% Compute Qhh(p) and d(Qhh(p))/dp using spline interpolation over reduced 
% frequencies and a second order approximation to extrapolate to complex plane
%
%--------------------------------------------------------------------------
% 31-08-2015
%


k = imag(p);
g = real(p);

nM = length(Mvect);

% Never extrapolate !!!!

if Mach<=min(Mvect) || nM == 1
	% Get Qhh(k, M), d(Qhh(k, M))/dk, d2(Qhh(k, M))/(dk)^2
	[Q, Q_k, Q_kk] = aeroMatrixSpline_eval(k, kvect, Qhh(:,:,:,1), DR(:,:,:,1), DI(:,:,:,1), 1, 2);


	% Second order extrapolation of Q(p, M)
	Qp = Q - 1j*Q_k*g - 0.5*Q_kk*g^2;

	% Linear extrapolation of dQ(p,M)/dp
	Qp_p = -1j*Q_k - g*Q_kk;
   
	Qp_M = zeros(size(Qp));
   
elseif Mach>=max(Mvect)
	% Get Qhh(k, M), d(Qhh(k, M))/dk, d2(Qhh(k, M))/(dk)^2
	[Q, Q_k, Q_kk] = aeroMatrixSpline_eval(k, kvect, Qhh(:,:,:,nM), DR(:,:,:,nM), DI(:,:,:,nM), 1, 2);

	% Second order extrapolation of Q(p, M)
	Qp = Q - 1j*Q_k*g - 0.5*Q_kk*g^2;

	% Linear extrapolation of dQ(p,M)/dp
	Qp_p = -1j*Q_k - g*Q_kk;

	Qp_M = zeros(size(Qp));

else
	NM1 = max(find(Mvect<Mach));
	NM2 = NM1 + 1;

	DMach = Mvect(NM2) - Mvect(NM1);
	Coef = Mach - Mvect(NM1);
   
	% Get Qhh(k, M1), d(Qhh(k, M1))/dk, d2(Qhh(k, M1))/(dk)^2
	[Q, Q_k, Q_kk] = aeroMatrixSpline_eval(k, kvect, Qhh(:,:,:,NM1), DR(:,:,:,NM1), DI(:,:,:,NM1), 1, 2);

	% Second order extrapolation of Q(p, M1)
	Qp1 = Q - 1j*Q_k*g - 0.5*Q_kk*g^2;

	% Linear extrapolation of dQ(p,M1)/dp
	Qp_p1 = -1j*Q_k - g*Q_kk;
   
   
	% Get Qhh(k, M2), d(Qhh(k, M2))/dk, d2(Qhh(k, M2))/(dk)^2
	[Q, Q_k, Q_kk] = aeroMatrixSpline_eval(k, kvect, Qhh(:,:,:,NM2), DR(:,:,:,NM2), DI(:,:,:,NM2), 1, 2);

	% Second order extrapolation of Q(p, M2)
	Qp2 = Q - 1j*Q_k*g - 0.5*Q_kk*g^2;

	% Linear extrapolation of dQ(p,M2)/dp
	Qp_p2 = -1j*Q_k - g*Q_kk;


	Qp_M = (Qp2-Qp1)/DMach;
   
	Qp = Qp1 + Coef*Qp_M;

	Qp_p = Qp_p1 + Coef*(Qp_p2-Qp_p1)/DMach;
end
   
   

return
