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

function [displ, dwnwsh, ndispl, rot, rot_chord,dwnPhi, dwnu, lk_chord] = set_boundary_condition_CORR(fid, geo, ...
    lattice, dlm, str_data, mode, AERO, SCALE, PLOT_RES,state,V,VINF,vortex_deformed, NDispl_deformed, ...
    colloc_deformed, subdivision)

displ  = [];
dwnwsh = [];
ndispl = [];
rot = [];
rot_chord = [];
dwnPhi = [];
dwnu = [];
lk_chord = [];

counter = 0;

fprintf(fid, '\n - Assemblying boundary displacements and downwash...');

% loop on patches
for n = 1 : geo.nwing 

	fprintf(fid, '\n\t Patch n. %d...', n);

	nytot = geo.ny(n,:);
	nxtot = geo.nx(n,:) + geo.fnx(n,:);
	np = sum(nxtot .* nytot); % get patch number of panels
	
	[D_DISPL, DWN, N_DISPL, ROT, ROT_Chord,DWNPhi, DWNu, LK_Chord] = set_patch_bc_CORR2(n, dlm.aero.cref, state, V, ...
        lattice.MID_DPOINT(counter+1:(counter + np),:), lattice.COLLOC(counter+1:(counter + np),:) ,...
	    lattice.XYZ(counter+1:(counter + np),:,:), lattice.N(counter+1:(counter + np),:),...
        str_data, mode, dlm.aero.k, AERO, SCALE, PLOT_RES, VINF(counter+1:(counter + np),:), ...
        squeeze(vortex_deformed(counter+1:(counter + np),5,:)-vortex_deformed(counter+1:(counter + np),4,:)),...
        NDispl_deformed, colloc_deformed(counter+1:(counter + np),:),lattice.DN(counter+1:(counter + np),:), subdivision,n);
	
	displ  = [displ; D_DISPL];
	dwnwsh = [dwnwsh; DWN];
    ndispl = [ndispl; N_DISPL];
    rot = [rot;ROT];
    rot_chord = [rot_chord;ROT_Chord];
    dwnPhi = [dwnPhi;DWNPhi];
    dwnu = [dwnu;DWNu];
    lk_chord = [lk_chord;LK_Chord];
	counter = counter + np;

	fprintf(fid, 'done.');

end

fprintf(fid, '\n   done.');
