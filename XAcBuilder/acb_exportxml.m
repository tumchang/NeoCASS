%
% acb_exportxml.m
%
% Author: Martin Lahuta, (c) 2008,2009 VZLU (www.vzlu.cz)
% Developed within SimSAC project, www.simsacdesign.org
% Any usage without an explicit authorization may be persecuted.
%
% Modifications:
%	DATE		VERS	PROGRAMMER	DESCRIPTION
%	26.11.09	1.0	M. Lahuta	last update
% 
% 
% exports data from ac structure into name.xml file
% called when user selects 'Export XML' from 'Project' menu
%
function acb_exportxml(name)
global ac

msg = 'You haven''t run Weight&Balance module. GUESS sizing won''t work with this .xml file';
if isfield(ac,'check')
    if ac.check.wb ~= 1
        warning(msg)
    end
end
% try

if nargin==0
   disp('AcBuilder::acb_exportxml: missing parameter');
   return
end
disp(['AcBuilder: Saving data to file: ' name]);

acb_postac;

% xml_save(name,ac);

ac_red = reduce_structure (ac);

neocass_xmlunwrapper(name, ac_red);

return
% catch
% 
% disp('AcBuilder::acb_exportxml: xml toolbox must be in search path');
% 
% end
