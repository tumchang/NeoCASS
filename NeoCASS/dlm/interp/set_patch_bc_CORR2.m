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

function [D_DISPL, dwn, N_DISPL, ROT_Vortex, ROT_Vortex_Chordwise, DWNPhi, DWNu, ...
    LVortex] = set_patch_bc_CORR2(pind, cref, state,...
    V, midpoint, colloc, aero_node, normal_defo, str_data, mode, k_list, AERO, ...
    SCALE, PLOT_RES, VINF, vortex_defo, NDispl_defo, colloc_defo, DeltaNormal, subdivision,n)

if isempty(subdivision)==0
    subdivision=subdivision(n,:);
end
% get total number of active modes
NMODES = size(mode, 3);
if (SCALE)
    colloc    = colloc .* cref;
    midpoint  = midpoint .* cref;
    aero_node = aero_node .* cref;
end


EPS = D2R(0.001); % perturbation value to the mode
mode = mode*EPS;

[Id, Ic, In] = set_patch_interf_matrix(pind, midpoint, colloc, aero_node, str_data, AERO);

np = size(colloc, 1);
nk = length(k_list);
dwn = zeros(np, NMODES, nk);
DWNPhi = zeros(np, NMODES, nk);
DWNu = zeros(np, NMODES, nk);
% % % % % V_dir = repmat([1,0,0], np, 1);


% % % % % if norm(state(3:end))
% % % % %     ARM = (colloc - repmat(AERO.geo.CG, np, 1));
% % % % %     OMEGA_P = cross(ARM, repmat(state(3:end), np, 1), 2);
% % % % %     % add rigid body contributions to collocation point velocity
% % % % %     DeltaAlpha = -OMEGA_P(:,3)/V;
% % % % %     DeltaBetha = -OMEGA_P(:,2)/V;
% % % % % end
% % % % %
% % % % % DIST = colloc - midpoint;
% % % % % DIST = dot(DIST, V_dir, 2);

if (PLOT_RES)
    offset = 100;
    for m = offset:(offset + NMODES)
        figure(m); close;
    end
end

ROT_Normal = zeros(np,3,3,NMODES);
ROT_Vortex = zeros(np,3,3,NMODES);
ROT_Vortex_Chordwise = zeros(np,3,3,2,NMODES);

xdef  = In * NDispl_defo(:,1);
ydef  = In * NDispl_defo(:,2);
zdef  = In * NDispl_defo(:,3);
EQ_DISPL = [xdef, ydef, zdef];

% get original vortex direction (after trim)
aero_node1 = reshape(aero_node(:,1,:),np,3) + EQ_DISPL(1:4:end,:);
aero_node2 = reshape(aero_node(:,2,:),np,3) + EQ_DISPL(2:4:end,:);
aero_node3 = reshape(aero_node(:,3,:),np,3) + EQ_DISPL(3:4:end,:);
aero_node4 = reshape(aero_node(:,4,:),np,3) + EQ_DISPL(4:4:end,:);
ax=((aero_node1(:,1)+aero_node4(:,1))/2+aero_node1(:,1))*0.5;	%vortex first point
ay=(3*aero_node1(:,2)+aero_node4(:,2))/4;
az=(3*aero_node1(:,3)+aero_node4(:,3))/4;
bx=((aero_node2(:,1)+aero_node3(:,1))/2+aero_node2(:,1))*0.5;	%vortex second point
by=(3*aero_node2(:,2)+aero_node3(:,2))/4;
bz=(3*aero_node2(:,3)+aero_node3(:,3))/4;

vortices_points(:,1,:) = [ax ay az];
vortices_points(:,2,:) = [bx by bz];

vortex_defo = [bx-ax , by-ay , bz-az];

normal_defo = -cross(aero_node3-aero_node1,aero_node4-aero_node2,2);
normal_defo_norm = sqrt(normal_defo(:,1).^2 + normal_defo(:,2).^2 +normal_defo(:,3).^2);
normal_defo = normal_defo./repmat(normal_defo_norm,1,3);
normal_defo = normal_defo + DeltaNormal;

if isempty(subdivision)==0
    % get original chordwise vortex (after trim)
    nytot = subdivision(2);
    nxtot = subdivision(1);
    np = sum(nxtot .* nytot); % get patch number of panels
    
    for spanpos = 1:nytot
        for chordpos = 1:nxtot
            if chordpos < nxtot % Not last box
                LVortex(chordpos + nxtot*(spanpos-1),1,:) = ...
                    vortices_points(chordpos + nxtot*(spanpos-1),1,:) - ...
                    vortices_points(chordpos +1 + nxtot*(spanpos-1),1,:);
                LVortex(chordpos + nxtot*(spanpos-1),2,:) = ...
                    vortices_points(chordpos +1 + nxtot*(spanpos-1),2,:) - ...
                    vortices_points(chordpos + nxtot*(spanpos-1),2,:);
            else
                LVortex(chordpos + nxtot*(spanpos-1),1,:) = ...
                    squeeze(vortices_points(chordpos + nxtot*(spanpos-1),1,:)) - ...
                    (aero_node4(chordpos + nxtot*(spanpos-1),:)).';
                LVortex(chordpos + nxtot*(spanpos-1),2,:) = ...  % % % % TODO introduce treatment of hinge line
                    (aero_node3(chordpos + nxtot*(spanpos-1),:)).' - ...
                    squeeze(vortices_points(chordpos + nxtot*(spanpos-1),2,:));
            end
        end
    end
else
    LVortex = [];
end


for m = 1: NMODES
    xdef  = Id * mode(:, 1, m);
    ydef  = Id * mode(:, 2, m);
    zdef  = Id * mode(:, 3, m);
    D_DISPL(:,:,m) = [xdef, ydef, zdef];
    xdef  = Ic * mode(:, 1, m);
    ydef  = Ic * mode(:, 2, m);
    zdef  = Ic * mode(:, 3, m);
    C_DISPL(:,:,m) = [xdef, ydef, zdef];
    xdef  = In * mode(:, 1, m);
    ydef  = In * mode(:, 2, m);
    zdef  = In * mode(:, 3, m);
    N_DISPL(:,:,m) = [xdef, ydef, zdef];
    N_DISPL_with_equilibrium(:,:,m) = N_DISPL(:,:,m) + EQ_DISPL;
    
    if (PLOT_RES)
        offset = 99;
        figure(m + offset); hold on; grid;
        % structural displacements
        plot3(str_data(:,1) + mode(:,1,m), str_data(:,2) + mode(:,2,m), str_data(:,3) + mode(:,3,m),'.k');
        % midpoint displacements
        plot3(midpoint(:,1) + D_DISPL(:,1,m),midpoint(:,2) + D_DISPL(:,2,m),midpoint(:,3) + D_DISPL(:,3,m),'r.');
        % collocation point displacements
        plot3(colloc(:,1) + C_DISPL(:,1,m),colloc(:,2) + C_DISPL(:,2,m),colloc(:,3) + C_DISPL(:,3,m),'yo');
    end
    %   get COLLOCATION POINT normal displacements
    % % % % %     CDISP_corr = C_DISPL(:,:,m);
    % % % % %     if ~isempty(find(imag(C_DISPL)~=0))
    % % % % %         stop = 1;
    % % % % %     end
    % % % % %     if norm(state(3:end))
    % % % % %         for i = 1 : np
    % % % % %             Rot_Vel =   [cos(state(1)+DeltaAlpha(i))*cos(state(2)+DeltaBetha(i)), -cos(state(1)+DeltaAlpha(i))*sin(state(2)+DeltaBetha(i)), -sin(state(1)+DeltaAlpha(i));...
    % % % % %                 sin(state(2)+DeltaBetha(i)),  cos(state(2)+DeltaBetha(i)), 0;...
    % % % % %                 sin(state(1)+DeltaAlpha(i))*cos(state(2)+DeltaBetha(i)), -sin(state(1)+DeltaAlpha(i))*sin(state(2)+DeltaBetha(i)), cos(state(1)+DeltaAlpha(i))];
    % % % % %             CDISP_corr(i,:) = (Rot_Vel*CDISP_corr(i,:)')';
    % % % % %         end
    % % % % %     else
    % % % % %         Rot_Vel =   [cos(state(1))*cos(state(2)), -cos(state(1))*sin(state(2)), -sin(state(1));...
    % % % % %             sin(state(2)),  cos(state(2)), 0;...
    % % % % %             sin(state(1))*cos(state(2)), -sin(state(1))*sin(state(2)), cos(state(1))];
    % % % % %         CDISP_corr = (Rot_Vel*CDISP_corr')';
    % % % % %     end
    CNDISPL = dot(C_DISPL(:,:,m), normal_defo, 2);
    % % % % %     CNDISPL_corr = dot(CDISP_corr, normal_defo, 2) ;
    % % % % %     %   get DOUBLET POINT normal displacements
    % % % % %     DNDISPL = dot(D_DISPL(:,:,m), normal_defo, 2) ;
    % % % % %     DN = (CNDISPL - DNDISPL) ./ DIST;
    
    % get new vectors
    aero_node1 = reshape(aero_node(:,1,:),np,3) + N_DISPL_with_equilibrium(1:4:end,:,m); % aero_node is the undeformed configuration (prior to trim)
    aero_node2 = reshape(aero_node(:,2,:),np,3) + N_DISPL_with_equilibrium(2:4:end,:,m);
    aero_node3 = reshape(aero_node(:,3,:),np,3) + N_DISPL_with_equilibrium(3:4:end,:,m);
    aero_node4 = reshape(aero_node(:,4,:),np,3) + N_DISPL_with_equilibrium(4:4:end,:,m);
    ax=((aero_node1(:,1)+aero_node4(:,1))/2+aero_node1(:,1))*0.5;	%vortex first point
    ay=(3*aero_node1(:,2)+aero_node4(:,2))/4;
    az=(3*aero_node1(:,3)+aero_node4(:,3))/4;
    bx=((aero_node2(:,1)+aero_node3(:,1))/2+aero_node2(:,1))*0.5;	%vortex second point
    by=(3*aero_node2(:,2)+aero_node3(:,2))/4;
    bz=(3*aero_node2(:,3)+aero_node3(:,3))/4;
    
    vortices_points(:,1,:) = [ax ay az];
    vortices_points(:,2,:) = [bx by bz];
    
    vortex_new = [bx-ax , by-ay , bz-az];
    normal_new = -cross(aero_node3-aero_node1,aero_node4-aero_node2,2);
    % % % % %     normal_new_norm = sqrt(normal_new(:,1).^2 + normal_new(:,2).^2 +normal_new(:,3).^2);
    normal_new = normal_new./repmat(normal_defo_norm,1,3); % % % % We take into account also the change of area
    normal_new = normal_new + DeltaNormal;
    
    if isempty(subdivision)==0
        for spanpos = 1:nytot
            for chordpos = 1:nxtot
                if chordpos < nxtot % Not last box
                    LVortex_new(chordpos + nxtot*(spanpos-1),1,:) = ...
                        vortices_points(chordpos + nxtot*(spanpos-1),1,:) - ...
                        vortices_points(chordpos +1 + nxtot*(spanpos-1),1,:);
                    LVortex_new(chordpos + nxtot*(spanpos-1),2,:) = ...
                        vortices_points(chordpos +1 + nxtot*(spanpos-1),2,:) - ...
                        vortices_points(chordpos + nxtot*(spanpos-1),2,:);
                else
                    LVortex_new(chordpos + nxtot*(spanpos-1),1,:) = ...
                        squeeze(vortices_points(chordpos + nxtot*(spanpos-1),1,:)) - ...
                        (aero_node4(chordpos + nxtot*(spanpos-1),:)).';
                    LVortex_new(chordpos + nxtot*(spanpos-1),2,:) = ...  % % % % TODO introduce treatment of hinge line
                        (aero_node3(chordpos + nxtot*(spanpos-1),:)).' - ...
                        squeeze(vortices_points(chordpos + nxtot*(spanpos-1),2,:));
                end
            end
        end
    end
    
    
    % % % % %     normal_new = -cross((colloc_defo+C_DISPL(:,:,m))-[ax ay az],(colloc_defo+C_DISPL(:,:,m))...
    % % % % %         -[bx by bz],2);
    % % % % %     normal_new_norm = sqrt(normal_new(:,1).^2 + normal_new(:,2).^2 +normal_new(:,3).^2);
    % % % % %     normal_new = normal_new./repmat(normal_new_norm,1,3);
    
    
    for index = 1:np
        teta = acos(dot(normal_defo(index,:),(normal_new(index,:)-normal_defo(index,:))...
            /norm(normal_new(index,:)-normal_defo(index,:))));
        axrot = cross(normal_defo(index,:), (normal_new(index,:)-normal_defo(index,:))...
            /norm(normal_new(index,:)-normal_defo(index,:)));
        
        u = axrot./norm(axrot);
        
        ucp = [ 0    -u(3)  u(2); ...
            u(3)  0    -u(1); ...
            -u(2)  u(1)  0    ];
        ROT_Normal(index,:,:,m) = eye(3) + sin(teta)*ucp + (1-cos(teta))*ucp*ucp;
        ROT_Normal(index,:,:,m) = ROT_Normal(index,:,:,m)*norm(normal_new(index,:)-normal_defo(index,:));
        
        temp(index,:) = (squeeze(ROT_Normal(index,:,:,m))*normal_defo(index,:).').';
    end
    
    for index = 1:np
        teta = acos(dot(vortex_defo(index,:)/norm(vortex_defo(index,:)),(vortex_new(index,:)-vortex_defo(index,:))...
            /norm(vortex_new(index,:)-vortex_defo(index,:))));
        axrot = cross(vortex_defo(index,:)/norm(vortex_defo(index,:)), (vortex_new(index,:)-vortex_defo(index,:))...
            /norm(vortex_new(index,:)-vortex_defo(index,:)));
        
        u = axrot./norm(axrot);
        
        ucp = [ 0    -u(3)  u(2); ...
            u(3)  0    -u(1); ...
            -u(2)  u(1)  0    ];
        ROT_Vortex(index,:,:,m) = eye(3) + sin(teta)*ucp + (1-cos(teta))*ucp*ucp;
        ROT_Vortex(index,:,:,m) = ROT_Vortex(index,:,:,m)*norm(vortex_new(index,:)-vortex_defo(index,:))/...
            norm(vortex_defo(index,:));
    end
    if isempty(subdivision)==0
        for segment = 1:2
            for index = 1:np
                teta = acos(dot(LVortex(index,segment,:)/norm(squeeze(LVortex(index,segment,:))),...
                    (LVortex_new(index,segment,:)-LVortex(index,segment,:))/...
                    norm(squeeze(LVortex_new(index,segment,:)-LVortex(index,segment,:)))));
                axrot = cross(LVortex(index,segment,:)/norm(squeeze(LVortex(index,segment,:))),...
                    (LVortex_new(index,segment,:)-LVortex(index,segment,:))/...
                    norm(squeeze(LVortex_new(index,segment,:)-LVortex(index,segment,:))));
                
                u = axrot./norm(squeeze(axrot));
                
                ucp = [ 0    -u(3)  u(2); ...
                    u(3)  0    -u(1); ...
                    -u(2)  u(1)  0    ];
                ROT_Vortex_Chordwise(index,:,:,segment,m) = eye(3) + sin(teta)*ucp + (1-cos(teta))*ucp*ucp;
                ROT_Vortex_Chordwise(index,:,:,segment,m) = ROT_Vortex_Chordwise(index,:,:,segment,m)...
                    *norm(squeeze(LVortex_new(index,segment,:)-LVortex(index,segment,:)))/norm(squeeze(LVortex(index,segment,:)));
            end
        end
    else
        ROT_Vortex_Chordwise = [];
    end
    
    for k = 1:nk
        DWNPhi(:,m,k) = - dot(VINF,temp,2);
        %Different from DN but more complete... the total normal downwash
        % VINF.normal_new is, in this way, equal to VINF.temp + VINF.normal
        DWNu(:,m,k) = 1i .* CNDISPL .* (k_list(k) / cref) * V; %different normals
        % % % % %         dwn(:, m, k) = (1i .* CNDISPL_corr .* (k_list(k) / cref) + DN) ;  % In this way we have a negative downwash for modal displacements in the positive normal directions
        dwn(:, m, k) = 1i .* CNDISPL .* (k_list(k) / cref) + DWNPhi(:,m,k)/V;
    end
end
D_DISPL = D_DISPL/EPS;
N_DISPL = N_DISPL/EPS;
ROT_Vortex = ROT_Vortex/EPS;
ROT_Vortex_Chordwise = ROT_Vortex_Chordwise/EPS;
DWNPhi = DWNPhi/EPS;
DWNu = DWNu/EPS;
dwn = dwn/EPS;
end