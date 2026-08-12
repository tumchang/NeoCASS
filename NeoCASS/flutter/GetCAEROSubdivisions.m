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
%***********************************************************************************************************************
%  SimSAC Project
%
%  SMARTCAD
%  Simplified Models for Aeroelasticity in Conceptual Aircraft Design  
%
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Alessandro Degaspari <degaspari@aero.polimi.it>
%                      Luca Riccobene       <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%***********************************************************************************************************************
%	
%   Author: Nicola Fonzi, DAER
%***********************************************************************************************************************

function Divisions = GetCAEROSubdivisions(geo,lattice)

counter = 0;
Divisions = zeros(geo.nwing,2);

for n = 1:geo.nwing
    
    nytot = geo.ny(n,:);
	nxtot = geo.nx(n,:) + geo.fnx(n,:);
	np = sum(nxtot .* nytot); % get patch number of panels
    
    % Obtain the first points in the lattice structure that have same
    % position --> the are all along the same spanwise position
    [ ~ , indexFarPoints, ~ ] = unique(squeeze(lattice.VORTEX(counter+1:counter+np,1,:)),'rows');
    
    % Index far points will contain the indices of the first panel in a new
    % spanwise position
    numberChordPos = indexFarPoints(2)-indexFarPoints(1);
    numberSpanPos = length(indexFarPoints);
    
    Divisions(n,:) = [numberChordPos numberSpanPos]; 
    
    counter = counter+np;
end