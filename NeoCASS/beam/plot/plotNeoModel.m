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
% function fig = plot_beam_model(nfig, varargin)
%
%   DESCRIPTION: Plot beam model struct (structural and aerodynamic model)
%
%         INPUT: NAME           TYPE       DESCRIPTION
%                nfig           integer    figure index to be opened
%                'aero_param'   OPTIONAL   Enable extra aerodynamic plots
%                                          'aero_param', [P_WAKE P_N]
%                                          P_WAKE boolean to enable plot of wake
%                                          P_N boolean to enable plot of normals
%                                       
%        OUTPUT: NAME           TYPE       DESCRIPTION
%                fig            integer    figure handler
%
%    REFERENCES:
%
%*******************************************************************************

function figHandle = plotNeoModel(beam_model, figHandle)

plotBody = true;

if  nargin==1 || isempty(figHandle)
	figHandle = figure();
else
	figHandle = figure(figHandle);
end
hold on;
set(figHandle, 'Visible','on', 'Name', 'NeoCASS - Model plot', 'NumberTitle','off'); 
grid;

% plot NODES
ngrid = beam_model.Info.ngrid;
position = 1:ngrid;

NodeCoord = beam_model.Node.Coord;

plot3(NodeCoord(position, 1), NodeCoord(position, 2), ...
      NodeCoord(position, 3), 'kx', 'MarkerSize', 4, 'MarkerFaceColor','k');

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



% plot beams / bars
plot_3n_line_elem(beam_model.Bar, beam_model.PBar, beam_model.Node);

plot_3n_line_elem(beam_model.Beam, beam_model.PBeam, beam_model.Node);

plot_beam_aero_nodes(beam_model.Node);

plot_conm(beam_model.Node.Coord, beam_model.ConM.Node, beam_model.ConM.Offset);

plot_spc(beam_model.Node.Coord, beam_model.Node.ID, beam_model.SPC);

plot_beam_RBE2(beam_model.Node, beam_model.RBE2);

if plotBody && isfield(beam_model.Aero, 'body') 
	if isfield(beam_model.Aero.body, 'lattice') && ~isempty(beam_model.Aero.body.lattice);
		hSurf = plotAeroBody(beam_model.Aero.body.lattice.Elem, 1);
	end
end

if ~isempty(beam_model.Aero.lattice_vlm)
	lattice = beam_model.Aero.lattice_vlm;
	scale = 1;
elseif ~isempty(beam_model.Aero.lattice_dlm)
	lattice = beam_model.Aero.lattice_dlm;
	scale = beam_model.Aero.ref.C_mgc;
end
hAero = plotAeroMesh(lattice, scale);

axis equal;
view([37.5 30]);
set(gca, 'fontsize', 16);
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');


return
%*******************************************************************************

%*******************************************************************************
function [hBar, hOff, hColl] = plot_3n_line_elem(Bar, Pbar, Node)

nBar = length(Bar.ID);

if nBar==0
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
nPnt = 10;
nLines = 8;
X = zeros(nPnt*nBar,3);
connectivity = zeros(nLines*nBar,2);

for iBar = 1:nBar

	pos0 = nPnt*(iBar-1);

	% stress points
	X(pos0+1,:) = Bar.Colloc(1,:,iBar);
	for k=1:4
		X(pos0+1+k,:) = Bar.Colloc(1,:,iBar) + (Bar.R(:,:,4,iBar)*[0 Pbar.Str_point(k,:,Bar.PID(iBar))]')';
	end

	X(pos0+6,:) = Bar.Colloc(2,:,iBar);
	for k=1:4
		X(pos0+6+k,:) = Bar.Colloc(2,:,iBar) + (Bar.R(:,:,5,iBar)*[0 Pbar.Str_point(k,:,Bar.PID(iBar))]')';
	end

	pos0line = nLines*(iBar-1);
	connectivity(pos0line + (1:nLines),:) = [(pos0+1)*ones(4,1), pos0+(2:5)'; (pos0+6)*ones(4,1), pos0+(7:10)'];

end


hColl = trisurf(connectivity, X(:,1), X(:,2), X(:,3));
set(hColl, 'LineStyle', '--')
set(hColl, 'edgecolor', 'c')
set(hColl, 'marker', 'v')
set(hColl, 'markersize', 2)


return
%*******************************************************************************

%*******************************************************************************
function [hOff, hcon] = plot_conm(Coord, conm_node, offset)

nConm = length(conm_node);

if nConm==0
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
function hOff = plot_beam_RBE2(Node, RBE2)
if isempty(RBE2)
    nRbe2 = 0;
else
    nRbe2 = length(RBE2.ID);
end

if nRbe2 == 0
	hOff = [];
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

hOff = trisurf(connectivity, Node.Coord(:,1), Node.Coord(:,2), Node.Coord(:,3));
set(hOff, 'LineStyle', '-')
set(hOff, 'LineWidth', 2)
set(hOff, 'edgecolor', 'r')

%*******************************************************************************
function hRbe0 = plot_beam_aero_nodes(Node)

lineaer = '--k+';

if isempty(Node.Aero)
	hRbe0 = [];
	return
end

nGrid = length(Node.ID);

rbe0Table = zeros(nGrid,1);

for iGrid=1:nGrid
	rbe0Table(iGrid) = length(Node.Aero.Index(iGrid).data);
end

nRbe0 = sum(rbe0Table);

posMaster = find(rbe0Table);
nMaster = length(posMaster);

cx = Node.Coord(:,1);
cy = Node.Coord(:,2);
cz = Node.Coord(:,3);

connectivity = zeros(nRbe0,2);

pos = 0;
for iMaster = 1:nMaster
	jMaster = posMaster(iMaster);
	nRbeLoc = rbe0Table(jMaster);
	connectivity(pos+(1:nRbeLoc),1) = jMaster;
	connectivity(pos+(1:nRbeLoc),2) = Node.Aero.Index(jMaster).data;
	pos = pos + nRbeLoc;
end

hOff = trisurf(connectivity, cx, cy, cz);
set(hOff, 'LineStyle', '--')
set(hOff, 'edgecolor', 'k')


return




return
