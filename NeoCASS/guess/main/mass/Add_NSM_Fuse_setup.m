%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2008 - 2011 
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
%**************************************************************************
%  SimSAC Project
%
%  NeoCASS
%  Next generation Conceptual Aero Structural Sizing  
%
%                      Sergio Ricci             <ricci@aero.polimi.it>
%                      Luca Cavagna             <cavagna@aero.polimi.it>
%                      Alessandro De Gaspari    <degaspari@aero.polimi.it>
%                      Luca Riccobene           <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%**************************************************************************
%
% Compute paint non-structural mass using wetted surface fraction with
% respect total wetted surface, spread interior, systems, pilots and crew
% as non structural densities over beam elements, while baggage and
% passengers are treated as lumped masses.
%
%   Author: <andreadr@kth.se>
%
% MODIFICATIONS:
%     DATE        VERS     PROGRAMMER       DESCRIPTION
%     080722      1.0      A. Da Ronch      Creation
%     120502      2.1.237  L. Riccobene     Modification
%
%**************************************************************************
function str = Add_NSM_Fuse_setup(outf, aircraft, geo, stick, str)

nodes = geo.fus.x_nodes;

% Volume and wetted surface interpolation over beam elements (from GUESS
% finer mesh to SmartCAD coarse mesh)
dV    = interp1(geo.fus.x_nodes_1_2_thick, geo.fus.V, geo.fus.x_nodes_1_2, 'linear','extrap');
V     = dV;
Swet  = interp1(geo.fus.x_nodes_1_2_thick, geo.fus.Swet, geo.fus.x_nodes_1_2, 'linear','extrap');
dSwet = Swet;

% Compute total aircraft wet surface
Swettot = computeTotalWetSurface(geo);

%==========================================================================
% Paint
%==========================================================================
%
domain = [0; geo.fus.bodl];

% Compute mass paint related to fuselage
massPNT = paint_weight(Swettot)*(sum(geo.fus.Swet)/Swettot);

% Paint field is initialized here
str.fus.paint = 0;

if massPNT > 0.0
    
    % Run optimization
    mass_pnt = massNSM_distr(nodes, domain, massPNT, dSwet, Swet, stick.fus.Lbeam);
    
    % Save NSM linear density
    str.fus.NSM.dstr = str.fus.NSM.dstr + mass_pnt;
    
    % Output to video total paint mass value
    paint = sum(mass_pnt.*stick.fus.Lbeam);
    fprintf(outf, '\n\t\t- paint over fuselage: %g kg.', paint);
    
    % Save in the total mass
    str.M = str.M + paint; 
    str.fus.paint = paint;
    
end

%==========================================================================
% Systems - line 17
%==========================================================================
%
domain = [0; geo.fus.bodl];

massFUR  = aircraft.weight_balance.COG(17,4,1);
CGFUR    = aircraft.weight_balance.COG(17,1,1);

if massFUR > 0.0

  % Run optimization
  mass_fur = massNSM_distr_opt(nodes, domain, massFUR, CGFUR, dV, V, stick.fus.Lbeam);
    
  fprintf(outf, '\n\t\t- systems: %g kg from %.2f m to %.2f m.', massFUR, domain(1), domain(2));
  
  % Save NSM
  str.fus.NSM.dstr = str.fus.NSM.dstr + mass_fur;   
  
  % Save in total mass
  str.M = str.M + massFUR; 
  
end

%==========================================================================
% Interior - line 21
%==========================================================================
%
domain = [0; geo.fus.bodl];

% Paint is already considered inside Interior but will be accounted for
% separately for each aircraft's component
massINT  = aircraft.weight_balance.COG(21,4,1) - paint_weight(Swettot);
CGINT    = aircraft.weight_balance.COG(21,1,1);

if massINT > 0.0

  % Run optimization
  mass_int = massNSM_distr_opt(nodes, domain, massINT, CGINT, dV, V, stick.fus.Lbeam);
    
  fprintf(outf, '\n\t\t- interior: %g kg from %.2f m to %.2f m.', massINT, domain(1), domain(2));
  
  % Save NSM linear density
  str.fus.NSM.dstr = str.fus.NSM.dstr + mass_int; 
  
  % Save in total mass
  str.M = str.M + massINT;
  
end

%==========================================================================
% Pilots - line 22
%==========================================================================
%
domain = [0; geo.fus.lengthN];

massPIL = aircraft.weight_balance.COG(22,4,1);
CGPIL   = aircraft.weight_balance.COG(22,1,1);

if CGPIL > domain(2)
  domain = [0; geo.fus.lengthN + geo.fus.lengthMID];
end

if massPIL > 0.0
    
    % Run optimization
    mass_pil = massNSM_distr_opt(nodes, domain, massPIL, CGPIL, dV, V, stick.fus.Lbeam);
    
    fprintf(outf, '\n\t\t- pilots: %g kg from %.2f m to %.2f m.', massPIL, domain(1), domain(2));
    
    % Save NSM linear density
    str.fus.NSM.dstr = str.fus.NSM.dstr + mass_pil;
    
    % Save in total mass
    str.M = str.M + massPIL; 
    
end

%==========================================================================
% Crew - line 23
%==========================================================================
%
domain = geo.fus.lengthN + [0; geo.fus.lengthMID];

massCRE = aircraft.weight_balance.COG(23, 4, 1);
CGCRE   = aircraft.weight_balance.COG(23, 1, 1);

if CGCRE < domain(1)
  domain = [0; geo.fus.lengthN + geo.fus.lengthMID];
end

if massCRE > 0.0
  
  % Run optimization
  mass_cre = massNSM_distr_opt(nodes, domain, massCRE, CGCRE, dV, V, stick.fus.Lbeam);
  fprintf(outf, '\n\t\t- crew: %g kg from %.2f m to %.2f m.', massCRE, domain(1), domain(2));
  
  % Save NSM linear density
  str.fus.NSM.dstr = str.fus.NSM.dstr + mass_cre;
  
  % Save in total mass
  str.M = str.M + massCRE; 
  
end

%==========================================================================
% Passengers - line 24 (accounted for only as concentrated mass)
%==========================================================================
%
domain = geo.fus.lengthN + [0; geo.fus.lengthMID];

massPAX = aircraft.weight_balance.COG(24, 4, 1);

if massPAX > 0.0
    
  fprintf(outf, '\n\t\t- passengers: %g kg from %.2f m to %.2f m.', massPAX, domain(1), domain(2));
  
  % Save in total mass
  str.M = str.M + massPAX; 
  
end

%==========================================================================
% Baggage - line 25 (accounted for only as concentrated mass)
%==========================================================================
%
domain = [geo.fus.bodl*aircraft.Baggage.Baggage_apex_per_fuselgt;...
    geo.fus.bodl*aircraft.Baggage.Baggage_apex_per_fuselgt + aircraft.Baggage.Baggage_combined_length]; 

massBAG = aircraft.weight_balance.COG(25, 4, 1);

if massBAG > 0.0
    
  fprintf(outf, '\n\t\t- baggage: %g kg from %.2f m to %.2f m.', massBAG, domain(1), domain(2));
  
  % Save in total mass
  str.M = str.M + massBAG; 
  
end