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
%   plotAeroMesh(beam_model, folderName, filename_base)
%
%
%   Author: Federico Fonte
%***********************************************************************************************************************

function plotAeroModel(beam_model, figHandle)

if ~isempty(beam_model.Aero.lattice_vlm)
	lattice = beam_model.Aero.lattice_vlm;
	latticeCase = 1;
	scale = 1;
elseif ~isempty(beam_model.Aero.lattice_dlm)
	lattice = beam_model.Aero.lattice_dlm;
	latticeCase = 2;
	scale = beam_model.Aero.ref.C_mgc;
end
 

np = size(lattice.N,1);
coordsXundefo = reshape(lattice.XYZ(:,1:4,1)'*scale, [4*np,1]);
coordsYundefo = reshape(lattice.XYZ(:,1:4,2)'*scale, [4*np,1]);
coordsZundefo = reshape(lattice.XYZ(:,1:4,3)'*scale, [4*np,1]);
connectivity = bsxfun(@plus, 1:4, 4*(0:np-1)');

if isempty(figHandle)
	figHandle = figure();
else
	figHandle = figure(figHandle);
end


hold on;
hSurf = trisurf(connectivity, coordsXundefo, coordsYundefo, coordsZundefo);
axis equal;
grid on
set(hSurf, 'faceColor', 'b');
set(hSurf, 'edgeColor', 'r');
set(hSurf, 'faceAlpha', 0.5);



return
