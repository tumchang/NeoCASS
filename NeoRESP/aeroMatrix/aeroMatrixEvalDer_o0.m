function [Q, Q_p, Q_M] = aeroMatrixEvalDer_o0(p, Mach, Qhh, kvect, Mvect)
%
% [Q, Q_p, Q_M] = aeroMatrixEvalDer_o0(p, Mach, Qhh, kvect, Mvect)
%
% Interpolate Qhh in Mach number and reduced frequaency, compute derivatives
% with respect to the non-dimensional Laplace variable p, and with respect to 
% Mach number M.
%
%-------------------------------------------------------------------------------
% 26-10-13
%

nM = length(Mvect);


if Mach<=min(Mvect) || nM == 1
   Q = real(Qhh(:,:,1,1));
   
   Q_p = (-1j)*(imag(Qhh(:,:,2,1)))/kvect(2);
   
   Q_M = zeros(size(Q));
      
elseif Mach>=max(Mvect)
   Q = real(Qhh(:,:,1,nM));
   
   Q_p = (-1j)*(imag(Qhh(:,:,2,nM)))/kvect(2);
   
   Q_M = zeros(size(Q));
   
else
   NM1 = max(find(Mvect<Mach));
   NM2 = NM1 + 1;
   
   DMach = (Mvect(NM2) - Mvect(NM1));
   Coef = (Mach - Mvect(NM1));
   
   Q1 = real(Qhh(:,:,1,NM1));
   Q2 = real(Qhh(:,:,1,NM2));
   
   Q_M = (Q2 - Q1)/DMach;
   
   Q = Q1 + Coef*Q_M;

   % Derivative w.r.t. complex variable p:
   %
   %  d(Qhh)/dp = -j*d(Qhh)/dk
   %
   Q_p2 = (-1j)*(imag(Qhh(:,:,2, NM2)))/kvect(2);
   Q_p1 = (-1j)*(imag(Qhh(:,:,2, NM1)))/kvect(2);
   
   Q_p = Q_p1 + Coef*(Q_p2 - Q_p1)/DMach;
   
end



return
