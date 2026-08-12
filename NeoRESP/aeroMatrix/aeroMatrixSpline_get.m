function [DR, DI] = aeroMatrixSpline_get(Qhh, kvect, type)
% aeroMatrixSpline_get: compute coefficients for a spline interpolation of Qhh 
%                       matrix along k axis.
%
% Inputs:
% 
% Qhh   (nr, nc, nk), complex : Array containing Qhh matrix for each reduced 
%                               frequency
% kvect (nk),         real    : Reduced frequencies vector
%
% type  (1),          integer : - type=1 => interpolation of imag(Qhh)
%                               - type=2 => interpolation of imag(Qhh)/k
%
% Outputs:
%
% DR (nr, nc, nk), real : Array containing interpolation coefficients for 
%                         real(Qhh) (MR(i,j,:) refer to real(Qhh(i,j,:)))
%
% DI (nr, nc, nk), real : Array containing interpolation coefficients for 
%                         imag(Qhh) if type=1, or imag(Qhh)/k if type=2
%                         (MI(i,j,:) refer to Qhh(i,j,:))
%
%--------------------------------------------------------------------------
%  28-07-2015
%

if nargin==2
	type = 1;
end

[kvect, Ikvect] = sort(kvect);

nk = length(kvect);

kvect = reshape(kvect, [nk,1]);

if size(Qhh, 3) == nk
	Qhh = Qhh(:,:,Ikvect);
else
	error('Number of Qhh matrices different from that of reduced frequencies')
end

% Spline coefficients
nr = size(Qhh,1);
nc = size(Qhh,2);

RQhh = real(Qhh);
IQhh = imag(Qhh);

hvect = kvect(2:nk) - kvect(1:nk-1);

% Generation of coefficient matrices ===========================================

% Diagonal
avect = 4./hvect;
avect = [0; avect] + [avect; 0];

bvect = 2./hvect;

% Cholewsky factorization of the coefficient matrix ============================
alphavect = zeros(nk,1);
betavect = zeros(nk-1,1);

alphavect(1) = sqrt(avect(1));
for ik = 2:nk;
	betavect(ik-1) = bvect(ik-1)/alphavect(ik-1);
	alphavect(ik) = sqrt(avect(ik) - (betavect(ik-1))^2);
end

% Computation of the RHS =======================================================
harray = repmat(reshape(1./hvect.^2, [1, 1, nk-1]), [nr, nc, 1]);


% Real Part --------------------------------------------------------------------

DR = zeros(nr, nc, nk);

% Generate RHS vector (the solution will be overwritten to this vector)
f = 6*harray.*(RQhh(:,:,2:nk) - RQhh(:,:,1:nk-1));
DR(:,:,1:nk-1) = f;
DR(:,:,2:nk)   = DR(:,:,2:nk) + f;



% Imaginary Part ---------------------------------------------------------------

DI = zeros(nr, nc, nk);

% Generate RHS vector (the solution will be overwritten to this vector)

% type==1 ==> Interpolation of imag(Qhh)
% type==2 ==> Interpolation of imag(Qhh)/k
if type==2 
	IQhh = IQhh./repmat(reshape(kvect, [1, 1, nk]), [nr, nc, 1]);
end

f = 6*harray.*(IQhh(:,:,2:nk) - IQhh(:,:,1:nk-1));

DI(:,:,1:nk-1) = f;
DI(:,:,2:nk)   = DI(:,:,2:nk) + f;   
 

% Computation of the coefficients ==============================================

% Forward substitution: y = inv(U')*F
DR(:,:,1) = DR(:,:,1)/alphavect(1);
DI(:,:,1) = DI(:,:,1)/alphavect(1);

for ik = 2:nk
	DR(:,:,ik) = (DR(:,:,ik) - DR(:,:,ik-1)*betavect(ik-1)) / alphavect(ik);
	DI(:,:,ik) = (DI(:,:,ik) - DI(:,:,ik-1)*betavect(ik-1)) / alphavect(ik);
end


% Backward substitution: d = inv(U)*y
DR(:,:,nk) = DR(:,:,nk)/alphavect(nk);
DI(:,:,nk) = DI(:,:,nk)/alphavect(nk);

for jk = nk-1:-1:1
	DR(:,:,jk) = (DR(:,:,jk) - DR(:,:,jk+1)*betavect(jk)) / alphavect(jk);
	DI(:,:,jk) = (DI(:,:,jk) - DI(:,:,jk+1)*betavect(jk)) / alphavect(jk);
end





return
