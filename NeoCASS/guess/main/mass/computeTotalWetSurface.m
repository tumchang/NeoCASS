function Swettot = computeTotalWetSurface(geo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2008 - 2017 
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
% respect total wetted surface. Do a similar procedure for fuel using
% internal volume fractions.
%
% function        Swettot = computeTotalWetSurface(geo)
%
%
%   DESCRIPTION:  Compute total wet surface for the whole aircraft
%
%
%         INPUT: NAME           TYPE       DESCRIPTION
%             
%                geo            struct     stores aircraft geometrical info
%                                       
%        OUTPUT: NAME           TYPE       DESCRIPTION
%                
%                Swettot        double     total aircraft wetted area [m^2]
%
% MODIFICATIONS:
%
%     DATE        VERS      PROGRAMMER       DESCRIPTION
%     171023      2.2.793   L.Riccobene      Creation
%
%**************************************************************************

% Retrieve aircraft component name
componentName = fieldnames(geo);
Swettot = 0;

% Cycle through aircraft components and add up surfaces
for k = 1:numel(componentName)
    
    if ~isempty(geo.(componentName{k}))
        
        switch componentName{k}
            
            case {'fus', 'vtail'}
                Swettot = Swettot + sum(geo.(componentName{k}).Swet);
            
            % For these components wet surface must be doubled (symmetry)
            case {'wing', 'wing2', 'htail', 'canard', 'tbooms'}
                Swettot = Swettot + 2*sum(geo.(componentName{k}).Swet);
                
            case 'vtail2'
                Swettot = Swettot + sum(geo.vtail.Swet);
        end
        
    end
    
end