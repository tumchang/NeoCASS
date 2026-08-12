function updateXML (inputXML, outputXML)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2008 - 2018
% 
% Sergio Ricci (sergio.ricci@polimi.it)
%
% Politecnico di Milano, Dipartimento di Ingegneria Aerospaziale
% Via La Masa 34, 20156 Milano - ITALY
% 
% This file is part of NeoCASS Software (www.neocass.org)
%
% NeoCASS is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation;
% either version 2, or (at your option) any later version.
%
% NeoCASS is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public
% License along with NeoCASS; see the file GNU GENERAL 
% PUBLIC LICENSE.TXT.  If not, write to the Free Software 
% Foundation, 59 Temple Place -Suite 330, Boston, MA
% 02111-1307, USA.
%
%
%***********************************************************************************************************************
%
%  SMARTCAD
%  Simplified Models for Aeroelasticity in Conceptual Aircraft Design  
%
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Alessandro Degaspari <degaspari@aero.polimi.it>
%                      Luca Riccobene       <riccobene@aero.polimi.it>
%                      Federico Fonte       <federico.fonte@polimi.it>
%                      Francesco Toffol     <francesco.toffol@polimi.it>
%                      Luca Marchetti       <luca.marchetti@polimi.it>
%
%***********************************************************************************************************************
%
%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     05-10-2018  0.0     Luca Marchetti   Creation
%
%*******************************************************************************

%This function allow the batch mode updating of the xml description of the aircraft in
%order to have it compatible with GUESS module. Geometry and Weight&Balance
%modules are executed. If launched with no input, the user is asked to find the xml file
%to update and to choose where to save the updated xml. These two paths can be given by the 
%user as funcion inputs.

global ac sinp_geo sout_geo

switch nargin
    
    case 0
        
        inputXML = uigetfile('*.xml');
        outputXML = uiputfile('*.xml');
    
    case 1
        
        outputXML = inputXML;       

end

if nargin > 2
    error('Too many inputs.')
end

%------ from xml to structure ---------------------------------------------

ac = neocass_xmlwrapper(inputXML);

%------ structure check and initialization --------------------------------

ac = add_missing_fields(ac);

acb_prepac;

acb_postac;

sinp_geo = ac;

%------ geometry module ---------------------------------------------------

geo_xml;
sout_geo.check.geo = 1;

%------ weight & balance module -------------------------------------------

ac = weight_xml(sout_geo);
ac.check.wb = 1;

%------ from structure to xml ---------------------------------------------

ac = reduce_structure(ac);

neocass_xmlunwrapper(outputXML, ac);