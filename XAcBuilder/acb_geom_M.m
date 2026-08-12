function testb = acb_geom_M(myXML)
struttura = neocass_xmlwrapper(myXML);%'h:\FileAircraftTest.xml'
%test = acb_geom(struttura)

global ac
global sinp_geo sout_geo


%save('h:\vel_acbgeom.mat','ac')
op=pwd;
mp=mfilename('fullpath');
gp=strrep(mp,[ 'acb_geom_M' ], 'Geo');

try

disp('acbuilder: Calling Geo module ...');
ac=struttura; % TEST
acb_prepac;

acb_postac;

cd(gp);

sinp_geo=ac;



geo_xml;

ac=sout_geo;

cd(op);
testb = ac;
return

catch

cd(op);
disp('acb_geom: error occured');
lasterr
return
end