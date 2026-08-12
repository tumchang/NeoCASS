%
% acb_geom.m
%
% Author: Martin Lahuta, (c) 2008,2009 VZLU (www.vzlu.cz)
% Developed within SimSAC project, www.simsacdesign.org
% Any usage without an explicit authorization may be persecuted.
%
% Modifications:
%	DATE		VERS	PROGRAMMER	DESCRIPTION
%	08.12.09	1.0	M. Lahuta	last update
% 
% calls geometry module from AcBuilder when user selects 'Geometry (output)'
% from 'Geometry' menu or any following module (except 'Technology').
%
function acb_geom

global ac
global sinp_geo sout_geo

op=pwd;
mp=mfilename('fullpath');
gp=strrep(mp,[ 'acb_geom' ], 'Geo');

try

disp('acbuilder: Calling Geo module ...');

ac.check.geo = 0;
rel = version('-java');
rel = str2double(rel(8));
if rel >=8 || ~isfield(ac.check,'wb')
    ac.check.wb = 0;
end
acb_prepac;
acb_postac;

cd(gp);

sinp_geo=ac;

geo_xml;

ac=sout_geo;


cd(op);

ac.check.geo = 1;

return

catch ME

cd(op);
disp('acb_geom: error occured');
rethrow(ME)
% lasterr
return

end
