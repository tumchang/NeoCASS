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
%	exportToVTK_model(beam_model, folderName, filename_base, struRes, deformSet, scale)
%
%
%   Author: Federico Fonte
%***********************************************************************************************************************

function exportToVTK_model(beam_model, folderName, filename_base, struRes, deformSet, scale)

if (nargin == 1) || isempty(folderName)
	folderName = './';
end

if nargin<=2 || isempty(filename_base)
	filename_base = 'exportedStruModel';
end

if nargin < 4
	deformSet = 0;
	onlyUndeformed = true;
else
	if isempty(deformSet)
		deformSet = 0:size(struRes.NDispl, 3);
	end
	onlyUndeformed = max(abs(deformSet))==0;
end

dataFormat = '%1.4f';
vectorString = [dataFormat, ' ', dataFormat, ' ', dataFormat, '\n'];


ngrid = length(beam_model.Node.ID);

pointsCoordUndefo = beam_model.Node.Coord;
nPoints = size(pointsCoordUndefo,1);

nSets = length(deformSet);
if onlyUndeformed
	indexLength = 2;
	indexArray = '00';
else
	indexLength = floor(log10(max(deformSet))) + 1;
	indexArray = repmat('0', [1, indexLength]);
end

% Plot 3 node elements
connectivity = [beam_model.Bar.Conn; beam_model.Beam.Conn];

if ~isempty(beam_model.Node.Aero);
	hasAeronodes = false(nPoints,1);
	for iNode = 1:nPoints
		if ~isempty(beam_model.Node.Aero.Index(iNode).data)
			hasAeronodes(iNode) = true;
		end
	end
	hasAeronodes = find(hasAeronodes);
	nAeronode = length(hasAeronodes);


	aeroNodeConn = zeros(2*nAeronode,3);
	for iNode = 1:nAeronode
		nodePos = hasAeronodes(iNode);
		aeroNodeConn((iNode-1)*2 + 1,:) = [beam_model.Node.Aero.Index(nodePos).data(1:2)', nodePos];
		aeroNodeConn((iNode-1)*2 + 2,:) = [beam_model.Node.Aero.Index(nodePos).data(3:4)', nodePos];
	end

	connectivity = [connectivity; aeroNodeConn];
end

beamConnectivity = connectivity - 1;

nBeamElements = size(connectivity, 1);

for iSet = 1:nSets
	if deformSet(iSet)==0
		% Undeformed model
		pointsCoord = pointsCoordUndefo;
		modeID = 0;
	else
		% Deformed model
		pointsCoord = pointsCoordUndefo + scale*struRes.NDispl(:,1:3,deformSet(iSet));
		modeID = deformSet(iSet);
	end

	index = indexArray;
	tag = num2str(modeID);
	index(indexLength-length(tag)+1: indexLength) = tag;


	fid = fopen([folderName, '/', filename_base, '_mode', index, '.vtk'], 'w');

	fprintf(fid, '# vtk DataFile Version 2.0\n');
	fprintf(fid, 'NeoCASS - Deformed structural model\n');
	fprintf(fid, 'BINARY\n');
	fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');
	fprintf(fid, 'POINTS %d %s\n', nPoints, 'double');

	array = reshape(pointsCoord', [3*nPoints,1]);
	fwrite(fid, array', 'double', 0, 'ieee-be');

	fprintf(fid, '\nCELLS %d %d\n', nBeamElements, 4*nBeamElements);

	array = [3*ones(nBeamElements,1), beamConnectivity];
	array = reshape(array', [4*nBeamElements, 1]);
	fwrite(fid, array, 'int', 0, 'ieee-be');

	fprintf(fid, '\nCELL_TYPES %d\n', nBeamElements);
	fwrite(fid, 21*ones(nBeamElements,1), 'int', 0, 'ieee-be');


	fclose(fid);
end



return
