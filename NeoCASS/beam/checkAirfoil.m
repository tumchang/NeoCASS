function foil = checkAirfoil(foil, mainDir)
%
%
% 15-12-2017
%


if exist([foil, '.dat'], 'file')
	foil = [foil, '.dat'];

elseif exist([mainDir, '/', foil, '.dat'], 'file')
	foil = [mainDir, '/', foil, '.dat'];

elseif (exist(strcat(foil, '.DAT'), 'file'))
	foil = strcat(foil, '.DAT');

elseif exist([mainDir, '/', foil, '.DAT'], 'file')
	foil = [mainDir, '/', foil, '.DAT'];

else
	msg = ['Unable to find airfoil ', foil];
	error(msg);
end




return
