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
%
%   Function: exportToVTK
%
%      Exports the deformed aerodynamic model to a VTK file.
%
%   Usage:
%
%      For deformed mesh:
%         exportToVTK(lattice, ref, folderName, filename_base, dlm, deformSet, scale)
%
%      For undeformed mesh:
%         exportToVTK(lattice, ref, folderName, filename_base)
%
%   Author: Federico Fonte
%
%***********************************************************************************************************************

function exportToVTK(lattice, ref, folderName, filename_base, dlm, deformSet, scale)

if (nargin == 2) || isempty(folderName)
	folderName = './';
end

if nargin<=3 || isempty(filename_base)
	filename_base = 'exportedAeroModel';
end

if nargin>4 && isempty(dlm) && max(deformSet)>0
	error('the dlm struct must be provided as input in order to plot modal deformations');
end

if nargin < 5
	deformSet = 0;
	onlyUndeformed = true;
else
	if isempty(deformSet)
		deformSet = 1:size(dlm.data.n_displ, 3);
	end
	onlyUndeformed = max(abs(deformSet))==0;
end

cref = ref.C_mgc;

np = size(lattice.N,1);

coordsXundefo = reshape(lattice.XYZ(:,1:4,1)', [4*np,1])*cref;
coordsYundefo = reshape(lattice.XYZ(:,1:4,2)', [4*np,1])*cref;
coordsZundefo = reshape(lattice.XYZ(:,1:4,3)', [4*np,1])*cref;
connectivity = bsxfun(@plus, 1:4, 4*(0:np-1)');

nSets = length(deformSet);
indexLength = floor(log10(max(deformSet))) + 1;
indexArray = repmat('0', [1, indexLength]);


nSurfacePoints = size(coordsXundefo,1);

surfaceConnectivity = connectivity - 1;

nSurfacePanels = size(connectivity, 1);


dataFormat = '%1.4f';
vectorString = [dataFormat, ' ', dataFormat, ' ', dataFormat, '\n'];

for iSet = 1:nSets

	if deformSet(iSet)==0
		% Undeformed model
		coordsX = coordsXundefo;
		coordsY = coordsYundefo;
		coordsZ = coordsZundefo;
		modeID = 0;
	else
		% Deformed model
		coordsX = coordsXundefo + scale*dlm.data.n_displ(:,1,deformSet(iSet));
		coordsY = coordsYundefo + scale*dlm.data.n_displ(:,2,deformSet(iSet));
		coordsZ = coordsZundefo + scale*dlm.data.n_displ(:,3,deformSet(iSet));
		modeID = deformSet(iSet);
	end

	surfacePoints = [coordsX, coordsY, coordsZ];

	index = indexArray;
	tag = num2str(modeID);
	index(indexLength-length(tag)+1: indexLength) = tag;

	fid = fopen([folderName, '/', filename_base, '_mode', index, '.vtk'], 'w');

	fprintf(fid, '# vtk DataFile Version 2.0\n');
	fprintf(fid, 'NeoCASS - Deformed DLM mesh\n');
	fprintf(fid, 'BINARY\n');
	fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');
	fprintf(fid, 'POINTS %d %s\n', nSurfacePoints, 'double');

	array = reshape(surfacePoints', [3*nSurfacePoints,1]);
	fwrite(fid, array', 'double', 0, 'ieee-be');

	fprintf(fid, '\nCELLS %d %d\n', nSurfacePanels, 5*nSurfacePanels);

	array = [4*ones(nSurfacePanels,1), surfaceConnectivity];
	array = reshape(array', [5*nSurfacePanels, 1]);
	fwrite(fid, array, 'int', 0, 'ieee-be');

	fprintf(fid, '\nCELL_TYPES %d\n', nSurfacePanels);
	fwrite(fid, 9*ones(nSurfacePanels,1), 'int', 0, 'ieee-be');


	fclose(fid);

end



return
