function varargout = aeroMatrixEval_o0(k, Mach, Qhh, kvect, Mvect, tipo)
%
%
% QhhI = aeroMatrixEval_o0(k, Mach, Qhh, kvect, Mvect, 1)
%
% [RQhhI, IQhhIk] = aeroMatrixEval_o0(k, Mach, Qhh, kvect, Mvect, 2)
%
% Interpolation both in Mach number and in reduced frequency of the aerodynamic
% matrix Qhh.
%
%
%-------------------------------------------------------------------------------
% 26-10-13
%

if ~exist('tipo', 'var') || isempty(tipo)
   tipo = 1;
end

nM = length(Mvect);


if Mach<=min(Mvect) || nM == 1
   if tipo == 2
      [RQ, IQk] = aeroMatrixInterp_o0(Qhh(:,:,:,1), kvect, k, 2);
      
      varargout{1} = RQ;
      varargout{2} = IQk;
      
   elseif tipo == 1
      Q = aeroMatrixInterp_o0(Qhh(:,:,:,1), kvect, k, 1);
      
      varargout{1} = Q;
      
   end
   
elseif Mach>=max(Mvect)
   if tipo == 2
      [RQ, IQk] = aeroMatrixInterp_o0(Qhh(:,:,:,nM), kvect, k, 2);
      
      varargout{1} = RQ;
      varargout{2} = IQk;
      
   elseif tipo == 1
      Q = aeroMatrixInterp_o0(Qhh(:,:,:,nM), kvect, k, 1);
      
      varargout{1} = Q;
      
   end
   
else
   NM1 = max(find(Mvect<Mach));
   NM2 = NM1 + 1;

   DMach = (Mvect(NM2) - Mvect(NM1));
   Coef = (Mach - Mvect(NM1));

   if tipo == 2
      [RQ1, IQk1] = aeroMatrixInterp_o0(Qhh(:,:,:,NM1), kvect, k, 2);
      
      [RQ2, IQk2] = aeroMatrixInterp_o0(Qhh(:,:,:,NM2), kvect, k, 2);
      
      
      RQ = RQ1 + Coef*(RQ2-RQ1)/DMach;
      
      IQk = IQk1 + Coef*(IQk2-IQk1)/DMach;
      
      varargout{1} = RQ;
      varargout{2} = IQk;
      
   elseif tipo == 1
      Q1 = aeroMatrixInterp_o0(Qhh(:,:,:,NM1), kvect, k, 1);
      Q2 = aeroMatrixInterp_o0(Qhh(:,:,:,NM2), kvect, k, 1);
      
      Q = Q1 + Coef*(Q2-Q1)/DMach;
      
      varargout{1} = Q;
   end
end



return
