function varargout = aeroMatrixInterp_o0(Qhh, kvect, k, tipo)
% aeroMatrixInterp: funzione per l'interpolazione della matrice Qhh
%
% QhhI = aeroMatrixInterp_o0(Qhh, kvect, k, 1)
%
% [RQhhI, IQhhIk] = aeroMatrixInterp_o0(Qhh, kvect, k, 2)
%
% QhhI  : Matrice Qhh valutata in corrispondenza della frequenza ridotta k
% 
% Qhh   : Array contenente le matrici Qhh valutate nelle frequenze ridotte
%         contenute in kvect
% kvect : Vettore delle frequenze ridotte
% k     : frequenza ridotta a cui valutare Qhh
%
%--------------------------------------------------------------------------
%  05-03-13
%

if ~exist('tipo', 'var') || isempty(tipo)
   tipo = 1;
end

[kvect, Ikvect] = sort(kvect);

nk = length(kvect);

if size(Qhh, 3) == nk
	
	Qhh = Qhh(:,:,Ikvect);
	
else
	error('Number of Qhh matrices different from that of reduced frequencies')
end


if k <= kvect(1)
	j = 1;

elseif k < kvect(nk)
   j = sum(kvect<k);
   
else
	j = nk - 1;
					
end


Rk = (k - kvect(j))/(kvect(j+1) - kvect(j));

switch tipo

case 1
   QhhI = Qhh(:,:,j) + (Qhh(:,:,j+1) - Qhh(:,:,j)) * Rk;
   
   varargout{1} = QhhI;
   
case 2
   RQhh = real(Qhh);
   IQhh = imag(Qhh);

   % Parte reale
   RQhhI = RQhh(:,:,j) + (RQhh(:,:,j+1) - RQhh(:,:,j)) * Rk;


   if kvect(j) == 0
      IQhhIk = IQhh(:,:,j+1)/kvect(j+1);
   else
      % Parte immaginaria (divisa per k)
      IQhhIk = IQhh(:,:,j)/kvect(j) + (IQhh(:,:,j+1)/kvect(j+1) - IQhh(:,:,j)/kvect(j)) * Rk;
   end
   
   varargout{1} = RQhhI;
   varargout{2} = IQhhIk;
end



return
