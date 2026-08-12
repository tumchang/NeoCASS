function varargout = aemodelFD_eval(k, Mach, qinf, fdAEmodel_base);
%
%
%
%

Asys = fdAEmodel_base.fdAero;

p = 1j*k;

% Aerodynamic matrices
if k<min(Asys.kvect)
	[Ham] = aeroMatrixEvalDer_o0(p, Mach, Asys.Ham, Asys.kvect, Asys.Mvect);
else
	[Ham] = aeroMatrixSpline_interp(Asys.Ham, Asys.kvect, Asys.Mvect, p, Mach, Asys.DR, Asys.DI);
end


selCols = fdAEmodel_base.Acols;
selRows = fdAEmodel_base.Arows;

A = fdAEmodel_base.fdAero.As;
A(selRows, selCols) = fdAEmodel_base.As(selRows, selCols) + qinf*Ham;


varargout{1} = E;
varargout{2} = A;

%fdAEmodel.E = E;
%fdAEmodel.A = A;

return
