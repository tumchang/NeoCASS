function [E, A] = aematrixFD_get(k, Vref, qinf, Minf, E, A, fdAero);
%
%
%
%
%
%

p = 1j*k;

% Aerodynamic matrices
if k<min(fdAero.kvect)
	[Ham] = aeroMatrixEvalDer_o0(p, Minf, fdAero.Ham, fdAero.kvect, fdAero.Mvect);
else
	[Ham] = aeroMatrixSpline_interp(fdAero.Ham, fdAero.kvect, fdAero.Mvect, p, Minf, fdAero.HamR, fdAero.HamI);
end

Ham(:,fdAero.HamVscale) = Ham(:,fdAero.HamVscale)*Vref;

selCols = fdAero.Acols;
selRows = fdAero.Arows;

A(selRows, selCols) = A(selRows, selCols) + qinf*Ham;



return
