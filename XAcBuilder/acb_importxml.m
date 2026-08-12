%
% acb_importxml.m
%
% Author: Martin Lahuta, (c) 2008,2009 VZLU (www.vzlu.cz)
% Developed within SimSAC project, www.simsacdesign.org
% Any usage without an explicit authorization may be persecuted.
%
%
% Modifications:
%	DATE		VERS	PROGRAMMER	DESCRIPTION
%	26.11.09	1.0	M. Lahuta	last update
% 
% 
% load aircraft's data from xml file into 'ac' structure
% called when user selects 'Import XML' from 'Project' menu
%
function acb_importxml(name)

global ac defac

try

if nargin==0
   disp('AcBuilder::acb_importxml: missing parameter');
   return
end
disp(['AcBuilder: Loading data from file: ' name]);
ac=struct([]);

%
% ac=xml_load(name);

%
ac = neocass_xmlwrapper(name);

ac = add_missing_fields(ac);

acb_prepac;	% check for missing fields

% ********** Inserisce nuovi campi ***********

      % *********** AGGIUNTO ****************
    
       ac.weight_balance.Struct.NewMLG_x_cg     	      = 0.;
       ac.weight_balance.Struct.NewMLG_y_cg            = 0.;
       ac.weight_balance.Struct.NewMLG_z_cg            = 0.;

       ac.weight_balance.Struct.Aux_Landing_Gear_x_cg  = 0.;
       ac.weight_balance.Struct.Aux_Landing_Gear_y_cg  = 0.;
       ac.weight_balance.Struct.Aux_Landing_Gear_z_cg  = 0.;

       ac.weight_balance.Struct.Wings2                 = 0; % Test ok
       
       % FlagForVersion
       ac.CheckVersion                         = 1.1; % Versione 1.0 Build 27.08.14 modificata
       
       % *************************************
% ****************************************************


return

catch

disp('AcBuilder::acb_importxml: xml toolbox must be in search path');

end
