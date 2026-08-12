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
%   Author: Luca Cavagna, Andrea Da Ronch, DIAPM
%***********************************************************************************************************************

function figList = plot_dlm_deformed(lattice, dlm, deformSet, scale, nfig, plotUndeformed)

if (nargin == 4)
	nfig = 1;
end

cref = dlm.aero.cref;
np = lattice.np;

if nargin < 6
	plotUndeformed = true;
end

coordsXundefo = reshape(lattice.XYZ(:,1:4,1)', [4*np,1])*cref;
coordsYundefo = reshape(lattice.XYZ(:,1:4,2)', [4*np,1])*cref;
coordsZundefo = reshape(lattice.XYZ(:,1:4,3)', [4*np,1])*cref;
connectivity = bsxfun(@plus, 1:4, 4*(0:np-1)');

figList = zeros(length(deformSet),1);

for iSet = 1:length(deformSet)
	nfig = nfig + 1;

	figList(iSet) = figure; hold on; grid on

	if plotUndeformed
		% Undeformed model
		h_mesh = trisurf(connectivity, coordsXundefo, coordsYundefo, coordsZundefo);
		set(h_mesh, 'facecolor', 'none');
		set(h_mesh, 'edgecolor', [0.5, 0.5, 0.5]);
	end

	% Deformed model
	coordsX = coordsXundefo + scale*dlm.data.n_displ(:,1,deformSet(iSet));
	coordsY = coordsYundefo + scale*dlm.data.n_displ(:,2,deformSet(iSet));
	coordsZ = coordsZundefo + scale*dlm.data.n_displ(:,3,deformSet(iSet));

	h_mesh = trisurf(connectivity, coordsX, coordsY, coordsZ);
	set(h_mesh, 'facecolor', 'b');
	set(h_mesh, 'facealpha', 0.2);
	set(h_mesh, 'edgecolor', 'r');

	axis equal;
	view(2);

	title(['DLM grid - deformation set ', num2str(deformSet(iSet))]);
end

nver = ver();
isoctave = strcmp(nver(1).Name, 'Octave');

if ~isoctave
	% Display node ID when selecting with mouse
	figfcn = @(obj,event_obj) displayNodeID_fun(obj,event_obj, beam_model.Node.ID, beam_model.Node.Coord);
	dataobj = datacursormode(gcf);
	set(dataobj, 'UpdateFcn', figfcn);

	% Modify behaviour of 3d zoom as in pre-2016 versions
	nameModules = {nver.Name};
	position = strcmp(nameModules, 'MATLAB');
	if str2num(nver(position).Version)>=9
		setAxes3DPanAndZoomStyle(zoom,gca,'camera');
	end
end


return
