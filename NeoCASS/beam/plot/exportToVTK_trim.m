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

Res = beam_model.Res;
lattice_vlm = beam_model.Aero.lattice_vlm;

naer = size(Res.CPaero.F0,1);

ADOF = [];
for k=1:length(beam_model.Aero.ID)
	n1 = lattice_vlm.DOF(k,1,1);
	n2 = lattice_vlm.DOF(k,1,2);
	ADOF = [ADOF, [n1:n2]];
end


F0 = Res.CPaero.F0;
State   = zeros(naer, 3, size(Res.CPaero.State,2));
Control = zeros(naer, 3, size(Res.CPaero.Control,2));
Defo    = zeros(naer, 3, size(Res.CPaero.Defo,2));
for k=1:naer
	offset = (ADOF(k)-1)*3;
	State(k,1,:) = Res.CPaero.State(offset+1,:);
	State(k,2,:) = Res.CPaero.State(offset+2,:);
	State(k,3,:) = Res.CPaero.State(offset+3,:);
	Control(k,1,:) = Res.CPaero.Control(offset+1,:);
	Control(k,2,:) = Res.CPaero.Control(offset+2,:);
	Control(k,3,:) = Res.CPaero.Control(offset+3,:);
	Defo(k,1,:) = Res.CPaero.Defo(offset+1,:);
	Defo(k,2,:) = Res.CPaero.Defo(offset+2,:);
	Defo(k,3,:) = Res.CPaero.Defo(offset+3,:);
end



scale = 1;

ntrim = 2;

colore{1} = 'blue';
colore{2} = 'red';


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
  Ftot = beam_model.Res.CPaero.F0;
  for k=1:5
    Ftot(:,1) = Ftot(:,1) + beam_model.Res.CPaero.State(1:3:end,k).* UX(k);
    Ftot(:,2) = Ftot(:,2) + beam_model.Res.CPaero.State(2:3:end,k).* UX(k);
    Ftot(:,3) = Ftot(:,3) + beam_model.Res.CPaero.State(3:3:end,k).* UX(k);
  end
  for k=1:length(beam_model.Res.Aero.RTrim_sol.Control)
    Ftot(:,1)=   Ftot(:,1) + beam_model.Res.CPaero.Control(1:3:end,k).* beam_model.Res.Aero.RTrim_sol.Control(k) * pi/180;
    Ftot(:,2)=   Ftot(:,2) + beam_model.Res.CPaero.Control(2:3:end,k).* beam_model.Res.Aero.RTrim_sol.Control(k) * pi/180;
    Ftot(:,3)=   Ftot(:,3) + beam_model.Res.CPaero.Control(3:3:end,k).* beam_model.Res.Aero.RTrim_sol.Control(k) * pi/180;
  end

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

 

% CFnetable = zeros(naer,3,2);
% CPnetable = zeros(naer,2);
% 
% for n = 1 : ntrim
%     
%     sol = [beam_model.Res.FM.Value(n,2:6),beam_model.Res.CS.Value(n,beam_model.Aero.Trim.CS.MPC == 0)];
%     
%     
%     [rho, p, T, a] = ISA_h(beam_model.Aero.state.ALT);
%     
%     pref = 0.5*rho*(a*beam_model.Aero.state.Mach)^2/scale;
%     
%     dof = (1:length(lattice_vlm.N))';
%     
%     CPne = F0;
%     
%     for i = 1 : 5
%         CPne = CPne +  squeeze(State(:,:,i))*sol(i);
%     end
%     
%     for i = 1 : length(find(beam_model.Aero.Trim.CS.MPC == 0))
%         CPne = CPne +  Control(:,:,i)*sol(i+5);
%     end
%     
%     if n == 2
%         CPned = zeros(length(dof),3);
%         
%         
%         for m = 1:beam_model.Info.ngrid 
%             dof = beam_model.Node.DOF(m, 1:6);
%             % DISPLACEMENT DOF
%             index = find(dof);
%             if ~isempty(index)
%                 for jj = 1 : length(index)
%                     if index(jj)<=3
%                        CPned = CPned +  Defo(:,:,dof(index(jj)))*beam_model.Res.NDispl(m,index(jj));
%                     else
%                         CPned = CPned + Defo(:,:,dof(index(jj))) * beam_model.Res.NDispl(m,index(jj));
%                     end
%                 end
%             end
%            
%         end
%          CPne = CPne + CPned;
%     end
%     
%     
%     CFnetable(:,:,n) = -CPne; %-dot(CPne,beam_model.Aero.lattice_vlm.N,2);
%     CPnetable(:,n) = -dot(CPne,beam_model.Aero.lattice_vlm.N,2);
% end 



if (nargin == 1) || isempty(folderName)
	folderName = './';
end

if nargin<=2 || isempty(filename_base)
	filename_base = 'exportedTrimResults';
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


cref = 1;

np = size(lattice_vlm.N,1);

coordsXundefo = reshape(lattice_vlm.XYZ(:,1:4,1)', [4*np,1])*cref;
coordsYundefo = reshape(lattice_vlm.XYZ(:,1:4,2)', [4*np,1])*cref;
coordsZundefo = reshape(lattice_vlm.XYZ(:,1:4,3)', [4*np,1])*cref;
connectivity = bsxfun(@plus, 1:4, 4*(0:np-1)');

deformSet = [0,1];
nSets = length(deformSet);
indexLength = floor(log10(max(deformSet))) + 1;
indexArray = repmat('0', [1, indexLength]);


nSurfacePoints = size(coordsXundefo,1);

surfaceConnectivity = connectivity - 1;

nSurfacePanels = size(connectivity, 1);


dataFormat = '%1.4f';
vectorString = [dataFormat, ' ', dataFormat, ' ', dataFormat, '\n'];

nSets = 1;
for iSet = 1:nSets

	if deformSet(iSet)==0
		% Undeformed model
		coordsX = coordsXundefo;
		coordsY = coordsYundefo;
		coordsZ = coordsZundefo;
		modeID = 0;
	else
		% % Deformed model
		% coordsX = coordsXundefo + scale*dlm.data.n_displ(:,1,deformSet(iSet));
		% coordsY = coordsYundefo + scale*dlm.data.n_displ(:,2,deformSet(iSet));
		% coordsZ = coordsZundefo + scale*dlm.data.n_displ(:,3,deformSet(iSet));
		% modeID = deformSet(iSet);
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


	fprintf(fid, '\nCELL_DATA %d\n', nSurfacePanels);
% 	fprintf(fid, 'SCALARS %s %s\n', 'CPundefo', 'double');
% 	fprintf(fid, 'LOOKUP_TABLE %s\n', 'default');
% 
% 	fwrite(fid, CPne(:,1), 'double', 0, 'ieee-be');
% 
% 	fprintf(fid, 'SCALARS %s %s\n', 'CPdefo', 'double');
% 	fprintf(fid, 'LOOKUP_TABLE %s\n', 'default');
% 
% 	fwrite(fid, CPne(:,2), 'double', 0, 'ieee-be');



	fprintf(fid, '\nVECTORS %s %s\n', 'CFundefo', 'double');

	array = reshape(Ftot', [3*nSurfacePanels, 1]);
	fwrite(fid, array, 'double', 0, 'ieee-be');

	fprintf(fid, '\nVECTORS %s %s\n', 'CFdefo', 'double');

	array = reshape(FtotD', [3*nSurfacePanels, 1]);
	fwrite(fid, array, 'double', 0, 'ieee-be');



	fclose(fid);
end



return
