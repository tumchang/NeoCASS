function mat = flutterTrackingPK(Vvect, rho, aref, l_a, Esys, Asys, selTracked, axesUsed, flightCond)
%
%
% Flutter tracking using continuation method. Spline interpolation of Qhh, 
% second order approximation of Qhh(p). Mach variation with flight speed 
% considered.
% 
%
%
%--------------------------------------------------------------------------
% 30-06-2016
%



%==========================================================================
% Flutter computation
%==========================================================================

nV = length(Vvect);

nTracked = length(selTracked);

mat = zeros(nV, nTracked);

fprintf('Running flutter computation for %d modes ...\n', nTracked);

switch axesUsed
case 'inertial'
	% Get base system
	[E, A, fdAero, flightCond] = aematrixFD_set(Vvect(1), l_a, Esys, Asys, axesUsed, flightCond, 'EA');

	invE = inv(E);

	for iV = 1:nV
		fprintf(' - Vinf = %5.1f m/s (%3d/%3d)\r', Vvect(iV), iV, nV);
		[svect, Q] = flutterCalcPKiner(Vvect(iV), rho, aref, l_a, invE, A, fdAero);
		mat(iV,:) = svect(selTracked);
	end


case {'body', 'bodyAngles'}
	for iV = 1:nV
		fprintf(' - Vinf = %5.1f m/s (%3d/%3d)\r', Vvect(iV), iV, nV);
		[svect, Q] = flutterCalcPKbody(Vvect(iV), rho, aref, l_a, Esys, Asys, axesUsed, flightCond);
		mat(iV,:) = svect(selTracked);
	end
end
fprintf('\n');
fprintf('\n');



return
