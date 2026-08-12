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
%   hSurf = plotAeroMesh(lattice, meshScale, displData, defoScale)
%
%   Author: Federico Fonte
%***********************************************************************************************************************

function hSurf = plotAeroMesh(lattice, meshScale, displData, defoScale)



np = size(lattice.XYZ,1);
coordsX = reshape(lattice.XYZ(:,1:4,1)'*meshScale, [4*np,1]);
coordsY = reshape(lattice.XYZ(:,1:4,2)'*meshScale, [4*np,1]);
coordsZ = reshape(lattice.XYZ(:,1:4,3)'*meshScale, [4*np,1]);
connectivity = bsxfun(@plus, 1:4, 4*(0:np-1)');

if nargin==4
	% Deformed model
	coordsX = coordsX + defoScale*displData.n_displ(:,1);
	coordsY = coordsY + defoScale*displData.n_displ(:,2);
	coordsZ = coordsZ + defoScale*displData.n_displ(:,3);
end

hSurf = trisurf(connectivity, coordsX, coordsY, coordsZ);
axis equal;
grid on
set(hSurf, 'faceColor', 'b');
set(hSurf, 'edgeColor', 'r');
set(hSurf, 'faceAlpha', 0.5);



return
