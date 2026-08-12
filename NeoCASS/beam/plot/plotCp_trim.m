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

function exportToVTK_trim(beam_model, folderName, filename_base)

% Recover aero forces along str nodes
aero_data = [];
for index=1:length(beam_model.Aero.ID);
  n1 = beam_model.Aero.lattice_vlm.DOF(index,1,1);
  n2 = beam_model.Aero.lattice_vlm.DOF(index,1,2);
  for j=n1:n2
    coord = (beam_model.Aero.lattice_vlm.VORTEX([j],[4],:) + beam_model.Aero.lattice_vlm.VORTEX([j],[5],:)).*0.5;
    aero_data = [aero_data; [coord(:,:,1), coord(:,:,2), coord(:,:,3)]];
  end
end
naer = size(aero_data,1);


% Get Normal and surface
v1 = permute(beam_model.Aero.lattice_vlm.XYZ(:,4,:) - beam_model.Aero.lattice_vlm.XYZ(:,1,:), [1,3,2]);
v2 = permute(beam_model.Aero.lattice_vlm.XYZ(:,2,:) - beam_model.Aero.lattice_vlm.XYZ(:,1,:), [1,3,2]);

surfVect = cross(v1,v2);
panelArea = sqrt(surfVect(:,1).^2 + surfVect(:,2).^2 + surfVect(:,3).^2);

qinf = beam_model.Res.state.qinf;


% Rigid trim
  CREF = beam_model.Aero.ref.C_mgc;
  BREF = beam_model.Aero.ref.b_ref;
  SREF = beam_model.Aero.ref.S_ref;
  VREF2 = 2*beam_model.Aero.state.AS;
  UX(1) = beam_model.Res.Aero.RTrim_sol.Alpha * pi/180;
  UX(2) = beam_model.Res.Aero.RTrim_sol.Betha * pi/180;
  UX(3) = beam_model.Res.Aero.RTrim_sol.P * CREF/VREF2;
  UX(4) = beam_model.Res.Aero.RTrim_sol.Q * BREF/VREF2;
  UX(5) = beam_model.Res.Aero.RTrim_sol.R * BREF/VREF2;
  ACC = beam_model.Res.Aero.RTrim_sol.ACC;
  FtotR = beam_model.Res.CPaero.F0;
  for k=1:5
    FtotR(:,1) = FtotR(:,1) + beam_model.Res.CPaero.State(1:3:end,k).* UX(k);
    FtotR(:,2) = FtotR(:,2) + beam_model.Res.CPaero.State(2:3:end,k).* UX(k);
    FtotR(:,3) = FtotR(:,3) + beam_model.Res.CPaero.State(3:3:end,k).* UX(k);
  end
  for k=1:length(beam_model.Res.Aero.RTrim_sol.Control)
    FtotR(:,1)=   FtotR(:,1) + beam_model.Res.CPaero.Control(1:3:end,k).* beam_model.Res.Aero.RTrim_sol.Control(k) * pi/180;
    FtotR(:,2)=   FtotR(:,2) + beam_model.Res.CPaero.Control(2:3:end,k).* beam_model.Res.Aero.RTrim_sol.Control(k) * pi/180;
    FtotR(:,3)=   FtotR(:,3) + beam_model.Res.CPaero.Control(3:3:end,k).* beam_model.Res.Aero.RTrim_sol.Control(k) * pi/180;
  end

PtotR = -sum(FtotR.*beam_model.Aero.lattice_vlm.N, 2);
CFtotR = FtotR./repmat(panelArea, [1,3])/qinf;
CPtotR = PtotR./panelArea/qinf;

% Deformable trim
  UX(1) = beam_model.Res.Aero.DTrim_sol.Alpha * pi/180;
  UX(2) = beam_model.Res.Aero.DTrim_sol.Betha * pi/180;
  UX(3) = beam_model.Res.Aero.DTrim_sol.P * CREF/VREF2;
  UX(4) = beam_model.Res.Aero.DTrim_sol.Q * BREF/VREF2;
  UX(5) = beam_model.Res.Aero.DTrim_sol.R * BREF/VREF2;
  ACC = beam_model.Res.Aero.DTrim_sol.ACC;
  FtotD = beam_model.Res.CPaero.F0;
  for k=1:5
    FtotD(:,1) = FtotD(:,1) + beam_model.Res.CPaero.State(1:3:end,k).* UX(k);
    FtotD(:,2) = FtotD(:,2) + beam_model.Res.CPaero.State(2:3:end,k).* UX(k);
    FtotD(:,3) = FtotD(:,3) + beam_model.Res.CPaero.State(3:3:end,k).* UX(k);
  end
  for k=1:length(beam_model.Res.Aero.DTrim_sol.Control)
    FtotD(:,1)=   FtotD(:,1) + beam_model.Res.CPaero.Control(1:3:end,k).* beam_model.Res.Aero.DTrim_sol.Control(k) * pi/180;
    FtotD(:,2)=   FtotD(:,2) + beam_model.Res.CPaero.Control(2:3:end,k).* beam_model.Res.Aero.DTrim_sol.Control(k) * pi/180;
    FtotD(:,3)=   FtotD(:,3) + beam_model.Res.CPaero.Control(3:3:end,k).* beam_model.Res.Aero.DTrim_sol.Control(k) * pi/180;
  end

PtotD = -sum(FtotD.*beam_model.Aero.lattice_vlm.N, 2);
CFtotD = FtotD./repmat(panelArea, [1,3])/qinf;
CPtotD = PtotD./panelArea/qinf;

 
np = size(beam_model.Aero.lattice_vlm.N,1);
coordsXundefo = reshape(beam_model.Aero.lattice_vlm.XYZ(:,1:4,1)', [4*np,1]);
coordsYundefo = reshape(beam_model.Aero.lattice_vlm.XYZ(:,1:4,2)', [4*np,1]);
coordsZundefo = reshape(beam_model.Aero.lattice_vlm.XYZ(:,1:4,3)', [4*np,1]);
connectivity = bsxfun(@plus, 1:4, 4*(0:np-1)');



% Plot rigid trim
figure; hold on;
hSurf = trisurf(connectivity, coordsXundefo, coordsYundefo, coordsZundefo, CPtotR);
axis equal;
grid on


hQuiver = quiver3(aero_data(:,1), aero_data(:,2), aero_data(:,3), ...
                  FtotR(:,1), FtotR(:,2), FtotR(:,3), 'r');
set(hQuiver, 'linewidth', 1.5)

colorbar
title(colorbar, 'C_p [-]')
title('Rigid trim results')

%setAxes3DPanAndZoomStyle(zoom,gca,'camera')

if isfield(beam_model.Aero, 'lattice_defo') && ~isempty(beam_model.Aero.lattice_defo)
	coordsX = reshape(beam_model.Aero.lattice_defo.XYZ(:,1:4,1)', [4*np,1]);
	coordsY = reshape(beam_model.Aero.lattice_defo.XYZ(:,1:4,2)', [4*np,1]);
	coordsZ = reshape(beam_model.Aero.lattice_defo.XYZ(:,1:4,3)', [4*np,1]);
	isDefo = true;
	aero_data = [];
	for index=1:length(beam_model.Aero.ID);
		n1 = beam_model.Aero.lattice_defo.DOF(index,1,1);
		n2 = beam_model.Aero.lattice_defo.DOF(index,1,2);
		for j=n1:n2
			coord = (beam_model.Aero.lattice_defo.VORTEX([j],[4],:) + beam_model.Aero.lattice_defo.VORTEX([j],[5],:)).*0.5;
			aero_data = [aero_data; [coord(:,:,1), coord(:,:,2), coord(:,:,3)]];
		end
	end

else
	coordsX = coordsXundefo; 
	coordsY = coordsYundefo;
	coordsZ = coordsZundefo;
	isDefo = false;
end

% Plot deformable trim
figure; hold on;
hSurf = trisurf(connectivity, coordsX, coordsY, coordsZ, CPtotD);
axis equal;
grid on

if isDefo
	hSurf = trisurf(connectivity, coordsXundefo, coordsYundefo, coordsZundefo);
	set(hSurf, 'faceColor', 'b');
	set(hSurf, 'edgeColor', [0.5, 0.5, 0.5]);
	set(hSurf, 'faceAlpha', 0);
end

hQuiver = quiver3(aero_data(:,1), aero_data(:,2), aero_data(:,3), ...
                  FtotD(:,1), FtotD(:,2), FtotD(:,3), 'r');
set(hQuiver, 'linewidth', 1.5)


colorbar
title(colorbar, 'C_p [-]')
title('Deformable trim results')

% % Matlab 2016
% setAxes3DPanAndZoomStyle(zoom,gca,'camera')

return
