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
%*******************************************************************************
%  SimSAC Project
%
%  NeoCASS
%  Next generation Conceptual Aero Structural Sizing  
%
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Luca Riccobene       <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%*******************************************************************************
%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     080101      1.0     L.Cavagna        Creation
%     160412      1.1     F.Fonte          Display node ID
%
%*******************************************************************************
%
% figHandle = plotLinearDispl(beam_model, resultsStruct, resSet, defoScale)
%
%   DESCRIPTION: Plot beam model with a linear deformation applied
%
%
%*******************************************************************************

function figHandle = plotLinearDispl(beam_model, resultsStruct, resSet, defoScale)

nSet = size(resultsStruct.NDispl,3);

nSelectedSet = length(resSet);


figHandle = zeros(nSelectedSet,1);


setZoom = false;
nver = ver();
isoctave = strcmp(nver(1).Name, 'Octave');

if ~isoctave
	% Modify behaviour of 3d zoom as in pre-2016 versions
	nameModules = {nver.Name};
	position = strcmp(nameModules, 'MATLAB');
	if str2num(nver(position).Version)>=9
		setZoom = true;
	end

	% Check if software or hardware opengl used
	openglData = opengl('data');

	if openglData.Software
		simplifiedPlot = true;
	else
		simplifiedPlot = false;
	end

else
	% With octave always print a simplified model
	simplifiedPlot = true;
end


aeroUsed = '';
switch(resultsStruct.SOL)
case {'Static linear unrestrained trim'}
	aeroUsed = 'VLM';
case {'Linear flutter'}
	aeroUsed = 'DLM';
case {'Vibration modes'}
	aeroUsed = 'DLM';
end

isAero = false;
switch aeroUsed
case 'DLM'
	isAero = ~isempty(beam_model.Aero.lattice_dlm) ...
	       && isfield(resultsStruct, 'dlmData');
case 'VLM'
	isAero = ~isempty(beam_model.Aero.lattice_vlm);
end

for jSet = 1:nSelectedSet

	iSet = resSet(jSet);
	if iSet > nSet
		fprintf('WARNING ! ! ! required set %d not available, skipping...\n', iSet);
		continue
	end

	switch(resultsStruct.SOL)
	case {'Static linear unrestrained trim'}
		figName = sprintf('trimSolution%.2d', iSet);
		titleName = sprintf('Trim solution %d', iSet);
	case {'Vibration modes'}
		figName = sprintf('normalMode%.2d', iSet);
		titleName = sprintf('Normal Mode $%d$, $f_0 = %1.3f~Hz$', iSet, resultsStruct.Omega(iSet)/2/pi);
	end


	figHandle(jSet) = figure();
	hold on;
	set(figHandle(jSet), 'Visible','on');
	set(figHandle(jSet), 'Name', figName);
	set(figHandle(jSet), 'NumberTitle','off'); 
	grid on;

	set(gca, 'fontsize', 16);
	title(titleName);

	nver = ver();
	isoctave = strcmp(nver(1).Name, 'Octave');

	if setZoom
		setAxes3DPanAndZoomStyle(zoom,gca,'camera');
	end

	% Plot undeformed model ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	if ~simplifiedPlot || ~isAero
		hNode = plotNode(beam_model.Node);
		set(hNode, 'color', [0.5,0.5,0.5]);
	end

	[hBar, hOff, hCon] = plot_3n_line_elem(beam_model.Bar, beam_model.PBar, beam_model.Node);
	set(hBar, 'edgeColor', [0.5,0.5,0.5]);
	set(hOff, 'edgeColor', [0.5,0.5,0.5]);
	set(hCon, 'edgeColor', [0.5,0.5,0.5]);
	delete(hOff);

	[hBar, hOff, hCon] = plot_3n_line_elem(beam_model.Beam, beam_model.PBeam, beam_model.Node);
	set(hBar, 'edgeColor', [0.5,0.5,0.5]);
	set(hCon, 'edgeColor', [0.5,0.5,0.5]);
	delete(hOff);

	%plot_beam_aero_nodes(beam_model.Info.ngrid, beam_model.Node);

	if ~simplifiedPlot
		hSpc = plot_spc(beam_model.Node.Coord, 1:length(beam_model.Node.ID), beam_model.SPC);
		set(hSpc, 'color', [0.5,0.5,0.5]);

		hRbe2 = plot_beam_RBE2(beam_model.Node, beam_model.RBE2);
		set(hRbe2, 'edgecolor', [0.5,0.5,0.5]);
	end

	if isAero
		switch aeroUsed
		case 'VLM'
			lattice = beam_model.Aero.lattice_vlm;
			scale = 1;
			hAero = plotAeroMesh(lattice, scale);
			set(hAero, 'edgeColor', [0.5,0.5,0.5]);
			set(hAero, 'faceColor', [0.5,0.5,0.5]);
			set(hAero, 'faceAlpha', 0.5);
		case 'DLM'
			lattice = beam_model.Aero.lattice_dlm;
			scale = beam_model.Aero.ref.C_mgc;
			hAero = plotAeroMesh(lattice, scale);
			set(hAero, 'edgeColor', [0.5,0.5,0.5]);
			set(hAero, 'faceColor', [0.5,0.5,0.5]);
			set(hAero, 'faceAlpha', 0.5);
		end
	end

	% Plot deformed model ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	nNodes = length(beam_model.Node.ID);
	defoNode.ID = beam_model.Node.ID;
	defoNode.Coord = beam_model.Node.Coord + defoScale*resultsStruct.NDispl(:,1:3,iSet);
	defoNode.R = zeros(3,3,nNodes);

	% update nodal rotation matrix
	for iNode = 1:nNodes
		R(:,:,iNode) =  Rmat(defoScale.*resultsStruct.NDispl(iNode,4:6,iSet)) * beam_model.Node.R(:,:,iNode);
	end
 
	if ~simplifiedPlot || ~isAero
		hNode = plotNode(defoNode);
	end

	[hBar, hOff, hCon] = plot_3n_line_elem(beam_model.Bar,  beam_model.PBar,  defoNode);
	[hBar, hOff, hCon] = plot_3n_line_elem(beam_model.Beam, beam_model.PBeam, defoNode);

	%plot_beam_aero_nodes(beam_model.Info.ngrid, beam_model.Node);

	if ~simplifiedPlot
		hRbe2 = plot_beam_RBE2(defoNode, beam_model.RBE2);
	end

	if isAero
		switch aeroUsed
		case 'VLM'
			lattice = beam_model.Aero.lattice_defo;
			meshScale = 1;

			hAero = plotAeroMesh(lattice, meshScale);
		case 'DLM'
			lattice = beam_model.Aero.lattice_dlm;
			meshScale = beam_model.Aero.ref.C_mgc;

			displData.n_displ = resultsStruct.dlmData.n_displ(:,:,iSet);

			hAero = plotAeroMesh(lattice, meshScale, displData, defoScale);
		end
	end


	axis equal;
	view([37.5 30]);
end

return
%*******************************************************************************

%*******************************************************************************
function hNode = plotNode(Node);

nNode = length(Node.ID);

position = 1:nNode;

hNode = plot3(Node.Coord(position, 1), Node.Coord(position, 2), Node.Coord(position, 3), ...
              'kx', 'MarkerSize', 4, 'MarkerFaceColor','k');
return
%*******************************************************************************


%*******************************************************************************
function [hBar, hOff, hColl] = plot_3n_line_elem(Bar, Pbar, Node)

nBar = length(Bar.ID);

if nBar==0
	hBar = []; hOff = []; hColl = [];
	return
end

n1 = Bar.Conn(:, 1);
n2 = Bar.Conn(:, 2);
n3 = Bar.Conn(:, 3);

offset1 = zeros(nBar,3);
offset2 = zeros(nBar,3);
offset3 = zeros(nBar,3);

for iBar = 1:nBar
	offset1(iBar,:) = (Node.R(:,:,n1(iBar)) * Bar.Offset((iBar), 1:3)')';
	offset2(iBar,:) = (Node.R(:,:,n2(iBar)) * Bar.Offset((iBar), 4:6)')';
	offset3(iBar,:) = (Node.R(:,:,n3(iBar)) * Bar.Offset((iBar), 7:9)')';
end

% Complete node table with offset
nodeOff = [Node.Coord(n1,:) + offset1;
           Node.Coord(n2,:) + offset2;
           Node.Coord(n3,:) + offset3];

connectivity = [(1:nBar)', nBar+(1:nBar)'; nBar+(1:nBar)', 2*nBar+(1:nBar)'];

hBar = trisurf(connectivity, nodeOff(:,1), nodeOff(:,2), nodeOff(:,3));
set(hBar, 'edgecolor', 'k');
set(hBar, 'LineWidth',2, 'MarkerSize', 6, 'MarkerFaceColor','r');


X = [Node.Coord([n1;n2;n3],:); nodeOff];
connectivity = [(1:3*nBar)'; 3*nBar + (1:3*nBar)'];
hOff = trisurf(connectivity, X(:,1), X(:,2), X(:,3));
set(hOff, 'LineStyle', '--')
set(hOff, 'edgecolor', 'k')


% % collocation points
hColl = [];
% nPnt = 10;
% nLines = 8;
% X = zeros(nPnt*nBar,3);
% connectivity = zeros(nLines*nBar,2);
% 
% for iBar = 1:nBar
% 
% 	pos0 = nPnt*(iBar-1);
% 
% 	% stress points
% 	X(pos0+1,:) = Bar.Colloc(1,:,iBar);
% 	for k=1:4
% 		X(pos0+1+k,:) = Bar.Colloc(1,:,iBar) + (Bar.R(:,:,4,iBar)*[0 Pbar.Str_point(k,:,Bar.PID(iBar))]')';
% 	end
% 
% 	X(pos0+6,:) = Bar.Colloc(2,:,iBar);
% 	for k=1:4
% 		X(pos0+6+k,:) = Bar.Colloc(2,:,iBar) + (Bar.R(:,:,5,iBar)*[0 Pbar.Str_point(k,:,Bar.PID(iBar))]')';
% 	end
% 
% 	pos0line = nLines*(iBar-1);
% 	connectivity(pos0line + (1:nLines),:) = [(pos0+1)*ones(4,1), pos0+(2:5)'; (pos0+6)*ones(4,1), pos0+(7:10)'];
% 
% end
% 
% 
% hColl = trisurf(connectivity, X(:,1), X(:,2), X(:,3));
% set(hColl, 'LineStyle', '--')
% set(hColl, 'edgecolor', 'c')
% set(hColl, 'marker', 'v')
% set(hColl, 'markersize', 2)


return
%*******************************************************************************

%*******************************************************************************
function [hOff, hcon] = plot_conm(Coord, conm_node, offset)

nConm = length(conm_node);

if nConm==0
	hOff = []; ncon = [];
	return
end

cx = [Coord(conm_node,1) + offset(:,1); Coord(conm_node,1)];
cy = [Coord(conm_node,2) + offset(:,2); Coord(conm_node,2)];
cz = [Coord(conm_node,3) + offset(:,3); Coord(conm_node,3)];

connectivity = [(1:nConm)', nConm + (1:nConm)'];
hOff = trisurf(connectivity, cx, cy, cz);
set(hOff, 'LineStyle', '--')
set(hOff, 'edgecolor', 'k')

hcon = plot3(cx(1:nConm), cy(1:nConm), cz(1:nConm), ...
             'ko', 'MarkerSize', 2, 'MarkerFaceColor','k');

return
%*******************************************************************************

%*******************************************************************************
function hRbe2 = plot_beam_RBE2(Node, RBE2)
if isempty(RBE2)
nRbe2=0;
else 
nRbe2 = length(RBE2.ID);
end
if nRbe2 == 0
	hRbe2 = [];
	return
end

nConn = 0;

for iRbe2 = 1 : nRbe2
	ns = length(RBE2.IDS(iRbe2).data);
	nConn = nConn + ns;
end

connectivity = zeros(nConn,2);

iConn = 0;
for iRbe2 = 1 : nRbe2
	nSlave = length(RBE2.IDS(iRbe2).data);
	mast = find(Node.ID == RBE2.IDM(iRbe2));
	for jSlave = 1 : nSlave
		slv = find(Node.ID == RBE2.IDS(iRbe2).data(jSlave));
		iConn = iConn + 1;
		connectivity(iConn, :) = [mast, slv];
	end
end

hRbe2 = trisurf(connectivity, Node.Coord(:,1), Node.Coord(:,2), Node.Coord(:,3));
set(hRbe2, 'LineStyle', '-')
set(hRbe2, 'LineWidth', 2)
set(hRbe2, 'edgecolor', 'r')


return
