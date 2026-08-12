function varargout = aeroMatrixSpline_eval(k_eval, kvect, Qhh, DR, DI, type, derivatives, splineToZero)
%
%
% Qhh           = aeroMatrixSpline_eval(k, kvect, Qhh, DR, DI, 1, derivatives, splineToZero)
% [RQhh, IQhhk] = aeroMatrixSpline_eval(k, kvect, Qhh, DR, DI, 2, [], splineToZero)
%
% Evaluate matrix Qhh at reduced frequency k, using the coefficient of spline
% interpolation contained in DR, DI (computed using function aeroMatrixSpline_get).
%
% If k lies outside the boundaries defined by [min(kvect), max(kvect)] a linear
% extrapolation is used.
% 
% type:  1 => DI interpolates imag(Qhh), the output is the complex matrix
%             real(Qhh) + j*imag(Qhh)
%        2 => DI interpolates imag(Qhh)/k, the outputs are real(Qhh) and
%             imag(Qhh)/k. With this choice derivatives are not computed.
%
%
% The computation of derivatives is performed only if type==1;
% derivatives:  0 (default) => Evaluate Qhh in point k
%               1           => Evaluate first derivative of Qhh wtr k in point k
%               2           => Evaluate first and second derivative
%
% Qhh                  = aeroMatrixSpline_eval(k, kvect, Qhh, DR, DI, 1,   0 )
% [Qhh, Qhh_k]         = aeroMatrixSpline_eval(k, kvect, Qhh, DR, DI, 1,   1 ) 
% [Qhh, Qhh_k, Qhh_kk] = aeroMatrixSpline_eval(k, kvect, Qhh, DR, DI, 1,   2 )
%
%
% splineToZero [default=true] if true the spline interpolation is extended to zero
%              reduced frequency. If false a linear extrapolation of Imag(Qhh) and
%              a quadratic extrapolation of Real(Qhh) will be used.
%
% Inputs:
% k      (1)           real
% kvect  (nk, 1)       real
% Qhh    (nr, nc, nk)  complex
% DR     (nr, nc, nk)  real
% DI     (nr, nc, nk)  real
%
% Outputs:
% type=1
%  Qhh    (nr, nc, nk)  complex
% type=2
%  RQhh   (nr, nc, nk)  real
%  IQhhk  (nr, nc, nk)  real
%
%
%------------------------------------------------------------------------------
% 28-07-2015 v1.0
% 17-09-2015 v1.1 Interpolation near zero changed
%

if ~exist('type', 'var') || isempty(type)
	type = 1;
end

if ~exist('derivatives', 'var') || isempty(derivatives) || type==2
	derivatives = 0;
end

if ~exist('splineToZero', 'var') || isempty(splineToZero)
	splineToZero = true;
end

kvect = sort(kvect);

nk = length(kvect);
nr = size(DR,1);
nc = size(DR,2);

% Looking for j such that:  kvect(j) <= k < kvect(j+1)
if k_eval < kvect(1)
	j_eval = 1;
	if splineToZero
		interpolate = 'middle';
	else
		interpolate = 'lower';
	end

elseif k_eval < kvect(nk)
	j_eval = sum(kvect<=k_eval);
	interpolate = 'middle';

else
	j_eval = nk;
	interpolate = 'upper';
end

RQhh = real(Qhh);

switch type
case 1 % type==1 ==> Interpolation of imag(Qhh)
	IQhh = imag(Qhh);
case 2 % type==2 ==> Interpolation of imag(Qhh)/k
	IQhh = imag(Qhh)./repmat(reshape(kvect, [1, 1, nk]), [nr, nc, 1]);
end


% Interpolation
switch interpolate
case 'middle'
	h_eval = kvect(j_eval+1) - kvect(j_eval);
	r_eval = (k_eval - kvect(j_eval))/h_eval;

	A1 = 1. -3*r_eval^2 + 2*r_eval^3;
	A3 =     3*r_eval^2 - 2*r_eval^3;
	A2 = (r_eval - 2*r_eval^2 + r_eval^3)*h_eval;
	A4 = (          -r_eval^2 + r_eval^3)*h_eval;


	RQhh_eval = DR(:,:,j_eval)*A2 + DR(:,:,j_eval+1)*A4 + RQhh(:,:,j_eval)*A1 + RQhh(:,:,j_eval+1)*A3;
	IQhh_eval = DI(:,:,j_eval)*A2 + DI(:,:,j_eval+1)*A4 + IQhh(:,:,j_eval)*A1 + IQhh(:,:,j_eval+1)*A3;


	if derivatives >= 1

		D1 = 6*(r_eval^2 - r_eval)/h_eval;
		D2 = 1-4*r_eval + 3*r_eval^2;
		D4 =  -2*r_eval + 3*r_eval^2;

		RQhh_k_eval = DR(:,:,j_eval)*D2 + DR(:,:,j_eval+1)*D4 + RQhh(:,:,j_eval)*D1 - RQhh(:,:,j_eval+1)*D1;
		IQhh_k_eval = DI(:,:,j_eval)*D2 + DI(:,:,j_eval+1)*D4 + IQhh(:,:,j_eval)*D1 - IQhh(:,:,j_eval+1)*D1;

		if derivatives >= 2
			K1 = 6*(2*r_eval - 1)/h_eval^2;
			K2 = (-4 + 6*r_eval)/h_eval;
			K4 = (-2 + 6*r_eval)/h_eval;

			RQhh_kk_eval = DR(:,:,j_eval)*K2 + DR(:,:,j_eval+1)*K4 + RQhh(:,:,j_eval)*K1 - RQhh(:,:,j_eval+1)*K1;
			IQhh_kk_eval = DI(:,:,j_eval)*K2 + DI(:,:,j_eval+1)*K4 + IQhh(:,:,j_eval)*K1 - IQhh(:,:,j_eval+1)*K1;

		end
	end


case 'upper' % Linear extrapolation of Qhh
	Dk = k_eval - kvect(j_eval);

	RQhh_eval = RQhh(:,:,j_eval) + Dk*DR(:,:,j_eval);
	IQhh_eval = IQhh(:,:,j_eval) + Dk*DI(:,:,j_eval);

	if derivatives >= 1

		RQhh_k_eval = DR(:,:,j_eval);
		IQhh_k_eval = DI(:,:,j_eval);

		if derivatives >= 2
			RQhh_kk_eval = zeros(nr,nc);
			IQhh_kk_eval = zeros(nr,nc);
		end
	end

case 'lower' % Linear extrapolation of Im(Qhh), quadratic extrapolation of Re(Qhh)

	% The first derivative of Im(Qhh) and the second derivative of Re(Qhh)
	% are computed using the spline values


	h_1 = kvect(2)-kvect(1);
	K1 = -6/h_1^2;
	K2 = -4/h_1;
	K4 = -2/h_1;

	RQhh_kk_1 = DR(:,:,1)*K2 + DR(:,:,2)*K4 + RQhh(:,:,1)*K1 - RQhh(:,:,2)*K1;

	RQhh_eval = RQhh(:,:,1) + RQhh_kk_1/2 * (k_eval^2 - kvect(1)^2);


	Dk = k_eval - kvect(j_eval);
	IQhh_eval = IQhh(:,:,j_eval) + Dk*DI(:,:,j_eval);


	if derivatives >= 1
		RQhh_k_eval = zeros(nr,nc);
		IQhh_k_eval = DI(:,:,j_eval);

		if derivatives >= 2
			RQhh_kk_eval = RQhh_kk_1;
			IQhh_kk_eval = zeros(nr,nc);
		end
	end
end

% Definition of the output -----------------------------------------------------

switch type
case 1
   
	varargout{1} = RQhh_eval + 1j*IQhh_eval;
   
	if derivatives >= 1
      
		varargout{2} = RQhh_k_eval + 1j*IQhh_k_eval;
      
		if derivatives == 2
			varargout{3} = RQhh_kk_eval + 1j*IQhh_kk_eval;
		end
	end
   
case 2

	varargout{1} = RQhh;
	varargout{2} = IQhh;

end
   


return
