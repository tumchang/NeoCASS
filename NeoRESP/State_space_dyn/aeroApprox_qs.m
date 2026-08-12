function [Meq, Ceq, Keq] = aeroApprox_qs(Q, kvect, kmin, kmax)
%
% [Meq, Ceq, Keq] = aeroApprox_qs(Q, kvect, kmin, kmax)
%
% Compute quasi-steady approximation for aerodynamic matrix Q using a least 
% square interpolation.
%
% Q(p) = Keq + Ceq*p + Meq*p^2 + ...
%
% where p = s*(l_a/2/V) = s*ta is the non-dimensionalized Laplace variable
%
% In reduced frequency:
%
% Q(k) = Keq + Ceq*jk - Meq*k^2 - ...
%
%-------------------------------------------------------------------------------
% 10-09-2013
%

Nrow = size(Q, 1);
Ncol = size(Q, 2);

% frequenze ridotte utilizzate nell'approssimazione
Nka = (kmin<=kvect) & (kvect<=kmax);
kavect = kvect(Nka);
nka = length(kavect);
kavect = reshape(kavect, nka,1);

if nka <= 1
   error('Too few reduced frequencies in the interval [%1.3f, %1.3f]\n', kmin, kmax)
end



kavect2 = kavect.^2;
Sumk2 = kavect'*kavect;
Sumk4 = kavect2'*kavect2;

if kmin == 0
   % Minimi quadrati con approssimazione della forma
   %   imag(Qhh) =   C * kavect          % Parte immaginaria antisimmetrica in k
   %   real(Qhh) = - M * kavect.^2 + K   % Parte reale simmetrica in k
   %
   % Matrice di massa equivalente sarebbe Ma = -1/2 * dd(Re(Qhh(0)))/dk^2
   %
   
   % Rigidezza equivalente: parte reale
   Keq = real(Q(:,:,1));

   % Ogni elemento di Qhh è moltiplicato per il k^2, k è la frequenza ridotta 
   % corrispondente all'elemento di Qhh
   Meq = real(Q(:,:,1:nka)) .* repmat(reshape(kavect2, 1, 1, nka), [Nrow, Ncol, 1]);
   Meq = - ( sum(Meq, 3) - Sumk2*Keq )/Sumk4;

   % Ogni elemento di Qhh è moltiplicato per il k, k è la frequenza ridotta 
   % corrispondente all'elemento di Qhh
   Ceq = imag(Q(:,:,1:nka)) .* repmat(reshape(kavect, 1, 1, nka), [Nrow, Ncol, 1]);
   Ceq = (sum(Ceq, 3))/Sumk2;
   
else
   
   warning('FIXME: not correct estimation of K, M will be provided');
   
   % Ogni elemento di Qhh è moltiplicato per il k, k è la frequenza ridotta 
   % corrispondente all'elemento di Qhh
   Ceq = imag(Q(:,:,Nka)) .* repmat(reshape(kavect, 1, 1, nka), [Nrow, Ncol, 1]);
   Ceq = (sum(Ceq, 3))/Sumk2;
   
   
   den = Sumk4*nka - Sumk2^2;
   
   numa = (nka*kavect2 - Sumk2*ones(nka,1))';
   numc = (Sumk4*ones(nka,1) - Sumk2*kavect2)';
   
   % Ogni elemento di Qhh è moltiplicato per il k^2, k è la frequenza ridotta 
   % corrispondente all'elemento di Qhh
   Keq = real(Q(:,:,Nka)) .* repmat(reshape(numc, 1, 1, nka), [Nrow, Ncol, 1]);
   Keq = sum(Keq,3)/den;
   
   % Ogni elemento di Qhh è moltiplicato per il k^2, k è la frequenza ridotta 
   % corrispondente all'elemento di Qhh
   Meq = real(Q(:,:,Nka)) .* repmat(reshape(numa, 1, 1, nka), [Nrow, Ncol, 1]);
   Meq = - sum(Meq, 3)/den;
   
end


return
