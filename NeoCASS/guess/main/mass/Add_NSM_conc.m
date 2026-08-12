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
%**************************************************************************
%  SimSAC Project
%
%  NeoCASS
%  Next generation Conceptual Aero Structural Sizing
%
%                      Sergio Ricci             <ricci@aero.polimi.it>
%                      Luca Cavagna             <cavagna@aero.polimi.it>
%                      Alessandro De Gaspari    <degaspari@aero.polimi.it>
%                      Luca Riccobene           <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%**************************************************************************
%
% Define necessary parameters to write CONM2 card.
%
% Called by:    guess.m
%
% Calls:        CONM2_setup.m
%
% MODIFICATIONS:
%     DATE        VERS     PROGRAMMER       DESCRIPTION
%     080723      1.0      A. Da Ronch      Creation
%     091119      1.3.9    Travaglini       Modification
%     120502      2.1.237  L. Riccobene     Modification
%     180111      2.1.797  L. Riccobene     Modification
%
% Modified by Travaglini replacing wing2 with canard and adding control
% about layout configuration on engines.
%
%**************************************************************************
function [str, IDSUPORT, stick] = Add_NSM_conc(outf, fid, fidOEW, pdcylin,...
    aircraft, geo, stick, str, MESH_LEVEL, EXPORT_REG)

EXPORT_OEW = 1;

if isempty(fidOEW)
    EXPORT_REG = 0;
    EXPORT_OEW = 0;
end

% Initialize variables
str.fus.NSM.conc    = [];                             % concentrated NSM on fuselage                 [kg]  , scalar
str.wing.NSM.conc   = [];                             % concentrated NSM on wing                     [kg]  , scalar
str.vtail.NSM.conc  = [];                             % concentrated NSM on vertical tail            [kg]  , scalar
str.htail.NSM.conc  = [];                             % concentrated NSM on horizontal tail          [kg]  , scalar
str.canard.NSM.conc = [];                             % concentrated NSM on canard                   [kg]  , scalar

fprintf(outf, '\n\tExporting lumped masses...');

MTOTF   = 0;
MTOTW   = 0;
MTOTC   = 0;
MTOTH   = 0;
MTOTV   = 0;
MTOTE   = 0;
MTOTE2  = 0;
% MTOTAUX = 0;
% MTOTLG = 0;
% MTOTBG  = 0;
MTOTFU  = 0;
MTOTCFU = 0;
% MTOTPAX = 0;

% % All nodes (right part)
% ALLndsR = [stick.nodes.fuse, stick.nodes.winrC2, stick.nodes.vert, stick.nodes.horrC2, stick.nodes.canrC2, stick.nodes.tboomsr];
%
% % All nodes' ID (right part)
% ALLIDsR = [stick.ID.fuse; stick.ID.winr; stick.ID.vert; stick.ID.horr; stick.ID.canr, stick.ID.tboomsr];
%
% % Symmetry if applicable
% if isequal(stick.model.symmXZ, 1)
%
%     % Grid points within the LEFT stick model
%     ALLndsL = [stick.nodes.fuse, stick.nodes.winlC2, stick.nodes.vert, stick.nodes.horlC2, stick.nodes.canlC2, stick.nodes.tboomsl];
%
%     % IDs
%     ALLIDsL = [stick.ID.fuse; stick.ID.winl; stick.ID.vert; stick.ID.horl; stick.ID.canl, stick.ID.tboomsl];
%
% end

% Grid points in the plane of symmetry (X-Z)
ALLndsXZ = [stick.nodes.fuse, stick.nodes.vert];

% IDs
ALLIDsXZ = [stick.ID.fuse; stick.ID.vert];

% Find the node nearest to the CG in the symmetry plane
indCG    = find_nearest_node(ALLndsXZ', aircraft.weight_balance.COG(27,1:3,1));
IDSUPORT = ALLIDsXZ(indCG);

% Counter for lumped masses
IDconm = 0;

if EXPORT_REG == 1 % do not export REGRESSION data at first GUESS MOD iteration
    
    %======================================================================
    % Fuselage - Non structural mass from regression analysis
    %======================================================================
    if isequal(pdcylin.stick.model.fuse, 1)
        
        if pdcylin.smartcad.fuse_regr
            
            % Fuselage non structural mass
            massREG = sum(str.fus.WTOT - str.fus.m);
            
            % Compute volume
            SA = meancouple(pi.*geo.fus.r.^2);
            SA_coarse = spline(geo.fus.x_nodes_1_2_thick, SA, geo.fus.x_nodes_1_2);
            dV = SA_coarse.*diff(geo.fus.x_nodes);
            V  = sum(dV);
            
            % Fuselage non structural lumped masses weighted on element volume
            mass_reg1 = massREG.*dV/V;
            
            % Inertia along x axis Jxx
            Jt_regX = (0.25 .* mass_reg1) .*...
                (stick.PBAR.fuse.str_rec_coef.D2.^2 + stick.PBAR.fuse.str_rec_coef.C1.^2);
            
            % Vertical axis inertia Jyy: 1/12 M L^2
            Jt_regY = 1/12 .* mass_reg1 .* stick.fus.Lbeam.^2;
            
            % Hor. axis inertia Jzz: 1/12 M L^2
            Jt_regZ = Jt_regY;
            
            % Nodal mass
            mass_reg2 = zeros(length(stick.PID.fuse)+1, 1);
            Jt_reg2X  = mass_reg2;
            Iglobal   = zeros(3,3,length(stick.PID.fuse)+1);
            %
            mass_reg2(1) = mass_reg1(1) / 2;
            Jt_reg2X(1) = Jt_regX(1) / 2 ;
            Jt_reg2Y(1) = Jt_regY(1) / 2 ;
            Jt_reg2Z(1) = Jt_regZ(1) / 2 ;
            %
            Iglobal(:,:,1) = stick.CBAR.fuse.R(:,:,1) * [ Jt_reg2X(1) 0 0; 0 Jt_reg2Y(1) 0; 0 0 Jt_reg2Z(1)] * stick.CBAR.fuse.R(:,:,1)';
            %
            for i = 2 : length(stick.PID.fuse)
                mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
                Jt_reg2X(i) = (Jt_regX(i-1)+Jt_regX(i)) / 2;
                Jt_reg2Y(i) = (Jt_regY(i-1)+Jt_regY(i)) / 2;
                Jt_reg2Z(i) = (Jt_regZ(i-1)+Jt_regZ(i)) / 2;
                %
                Iglobal(:,:,i) = (stick.CBAR.fuse.R(:,:,i-1) * [ Jt_regX(i-1) 0 0; 0 Jt_regY(i-1) 0; 0 0 Jt_regZ(i-1)] * stick.CBAR.fuse.R(:,:,i-1)' + ...
                    stick.CBAR.fuse.R(:,:,i)   * [ Jt_regX(i)   0 0; 0 Jt_regY(i)   0; 0 0 Jt_regZ(i)]   * stick.CBAR.fuse.R(:,:,i)') * 0.5;
            end
            %
            mass_reg2(end) = mass_reg1(end) / 2;
            Jt_reg2X(end) = Jt_regX(end) / 2 ;
            Jt_reg2Y(end) = Jt_regY(end) / 2 ;
            Jt_reg2Z(end) = Jt_regZ(end) / 2 ;
            %
            Iglobal(:,:,end) = stick.CBAR.fuse.R(:,:,end) * [ Jt_reg2X(end) 0 0; 0 Jt_reg2Y(end) 0; 0 0 Jt_reg2Z(end)] * stick.CBAR.fuse.R(:,:,end)';
            %
            %   CONM2 card
            %
            MTOTF = sum(mass_reg2);
            
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fidOEW, ['\n$ Lumped masses: FUSELAGE ',num2str(MTOTF), ' Kg']);
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            for i = 1:length(stick.PID.fuse) + 1
                IDconm = IDconm + 1;
                BULKdataCONM2(fidOEW, IDconm, stick.ID.fuse(i), 0, mass_reg2(i), 0, 0, 0, ...
                    Iglobal(1,1,i), Iglobal(2,1,i), Iglobal(2,2,i), ...
                    Iglobal(3,1,i), Iglobal(3,2,i), Iglobal(3,3,i));
            end
        end
    end
    
    %======================================================================
    % Wing - Non structural mass from regression analysis
    %======================================================================
    WLE = 0.25;
    WTE = 1.0 - WLE;
    WREGCG = 0;
    
    if isequal(pdcylin.stick.model.winr, 1)
        
        if pdcylin.smartcad.wing_regr
            
            Y  = [0; cumsum(stick.wing.Lbeam_thick)];
            Y2 = 0.5.*(Y(2:end) + Y(1:end-1));
            Yc = [0; cumsum(stick.wing.Lbeam)];
            Yc2 = 0.5.*(Yc(2:end) + Yc(1:end-1));
            V = interp1(Y2, geo.wing.V,  Yc2, 'linear', 'extrap');
            
            % Initialize
            mass_reg1 = zeros(numel(V), 1);
            
            % Wing volume except carry-through
            Vw = V(pdcylin.stick.nwing_carryth+1:end);
            
            % Wing-box non structural mass (cantilever part)
            mass_REG1 = sum(str.wing.WTBOX - str.wing.mbox);
            
            % Wing-box non structural lumped masses weighted on element volume
            mass_reg1(pdcylin.stick.nwing_carryth+1:end) = mass_REG1 *(Vw/sum(Vw));
            
            % Carry-through non structural mass contribution
            if isequal(stick.model.fuse, 1)
                mass_REG2 = sum(str.wing.WTC - 2*sum(str.wing.mc))/2;
                mass_reg1(1:pdcylin.stick.nwing_carryth) = mass_REG2 / pdcylin.stick.nwing_carryth;
            end
            
            % aero chord at beam midpoint
            aeroc = interp1(Y, geo.wing.r,  Yc2, 'linear', 'extrap');
            aeroZ = interp1(Y, geo.wing.Z,  Yc2, 'linear', 'extrap');
            sweep = aeroZ./aeroc;
            
            % wing box chord at beam midpoint
            strc  = interp1(Y, geo.wing.rs,  Yc2, 'linear', 'extrap');
            str_rec_coef = 0.5 .* strc;
            
            % leading edge x coord
            nctadd = length(geo.wing.y)-length(geo.wing.x);
            
            % wing box fraction at beam midpoint
            spar_frac = zeros(length(geo.wing.y),1);
            spar_frac(nctadd+1:end) = geo.wing.spar_frac;
            spar_frac(1:nctadd) = geo.wing.spar_frac(1);
            spar_frac = interp1(Y, spar_frac,  Yc2, 'linear', 'extrap');
            
            % LE cg distance  from spars
            b1 = sweep.*(spar_frac.*aeroc - str_rec_coef).*0.5;
            b2 = sweep.*(aeroc - spar_frac.*aeroc - str_rec_coef).*0.5;
            str_rec_coef = sweep .* str_rec_coef;
            
            % nodal mass
            mass_reg2 = zeros(length(stick.PID.wing)+1, 1);
            OffsetG = zeros(3,2,length(stick.PID.wing)+1);
            %
            mass_reg2(1) = mass_reg1(1) / 2;
            %
            OffsetG(:,1,1) = -stick.CBAR.winr.R(:,:,1)*[0; 0; str_rec_coef(1) + b1(1)];
            OffsetG(:,2,1) = stick.CBAR.winr.R(:,:,1)*[0; 0;  str_rec_coef(1) + b2(1)];
            %
            for i = 2 : length(stick.PID.wing)
                mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
                OffsetG(:,1,i) = -stick.CBAR.winr.R(:,:,i)*[0; 0; str_rec_coef(i) + b1(i)];
                OffsetG(:,2,i) =  stick.CBAR.winr.R(:,:,i)*[0; 0; str_rec_coef(i) + b2(i)];
            end
            mass_reg2(end) = mass_reg1(end) / 2;
            OffsetG(:,1,end) = -stick.CBAR.winr.R(:,:,end)*[0; 0; str_rec_coef(end) + b1(end)];
            OffsetG(:,2,end) =  stick.CBAR.winr.R(:,:,end)*[0; 0; str_rec_coef(end) + b2(end)];
            MTOTW = sum(mass_reg2);
            if isequal(stick.model.symmXZ, 1)
                MTOTW = 2*MTOTW;
            end
            
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fidOEW, ['\n$ Lumped masses: WING ',num2str(MTOTW), ' Kg']);
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            %
            %   CONM2 card
            %
            for i = 1:length(stick.PID.wing)+1
                if mass_reg2(i) > 0.0
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.winr(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), OffsetG(2,1,i), OffsetG(3,1,i),  0, 0, 0, 0, 0, 0);
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.winr(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), OffsetG(2,2,i), OffsetG(3,2,i),  0, 0, 0, 0, 0, 0);
                    WREGCG = WREGCG + (mass_reg2(i)*WLE)*(stick.nodes.winr(1,i)+OffsetG(1,1,i)) + (mass_reg2(i)*WTE)*(stick.nodes.winr(1,i)+OffsetG(1,2,i));
                end
            end
            
            % symmetry
            if isequal(stick.model.symmXZ, 1)
                WREGCG = WREGCG*2;
                for i = 1:length(stick.PID.wing)+1
                    if mass_reg2(i) > 0.0
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.winl(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), -OffsetG(2,1,i), OffsetG(3,1,i),  0, 0, 0, 0, 0, 0);
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.winl(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), -OffsetG(2,2,i), OffsetG(3,2,i),  0, 0, 0, 0, 0, 0);
                    end
                end
            end
            str.wing.regr.M = MTOTW;
            str.wing.regr.CG = WREGCG./MTOTW;
        end
    end
    
    %======================================================================
    % Vertical tail - Non structural mass from regression analysis
    %======================================================================
    if isequal(pdcylin.stick.model.vert, 1)
        
        if pdcylin.smartcad.vt_regr
            Y  = [0; cumsum(stick.vtail.Lbeam_thick)];
            Y2 = 0.5.*(Y(2:end) + Y(1:end-1));
            Yc = [0; cumsum(stick.vtail.Lbeam)];
            Yc2 = 0.5.*(Yc(2:end) + Yc(1:end-1));
            % Interpolate volume
            V = interp1(Y2, geo.vtail.V,  Yc2, 'linear', 'extrap');
            aeroc = interp1(Y, geo.vtail.r,  Yc2, 'linear', 'extrap');
            aeroZ = interp1(Y, geo.vtail.Z,  Yc2, 'linear', 'extrap');
            sweep = aeroZ./aeroc;
            % wing box chord at beam midpoint
            strc  = interp1(Y, geo.vtail.rs,  Yc2, 'linear', 'extrap');
            str_rec_coef = 0.5 .* strc;
            % wing box fraction at beam midpoint
            spar_frac = interp1(Y, geo.vtail.spar_frac,  Yc2, 'linear', 'extrap');
            % LE cg distance  from spars
            b1 = sweep.*(spar_frac.*aeroc - str_rec_coef).*0.5;
            b2 = sweep.*(aeroc - spar_frac.*aeroc - str_rec_coef).*0.5;
            str_rec_coef = sweep .* str_rec_coef;
            OffsetG = zeros(3,2,length(stick.PID.vert)+1);
            OffsetG(:,1,1) = -stick.CBAR.vert.R(:,:,1)*[0; 0; str_rec_coef(1) + b1(1)];
            OffsetG(:,2,1) = stick.CBAR.vert.R(:,:,1)*[0; 0;  str_rec_coef(1) + b2(1)];
            
            % VT box non structural mass
            mass_REG1 = sum(str.vtail.WTBOX - str.vtail.mbox);
            
            % VT box non structural lumped masses weighted on element volume
            % (VT features no carry-through)
            mass_reg1 = mass_REG1 .*(V./sum(V));
            
            % nodal mass
            mass_reg2 = zeros(length(stick.PID.vert)+1, 1);
            mass_reg2(1) = mass_reg1(1) / 2;
            for i = 2 : length(stick.PID.vert)
                mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
                OffsetG(:,1,i) = -stick.CBAR.vert.R(:,:,i)*[0; 0; str_rec_coef(i) + b1(i)];
                OffsetG(:,2,i) =  stick.CBAR.vert.R(:,:,i)*[0; 0; str_rec_coef(i) + b2(i)];
            end
            mass_reg2(end) = mass_reg1(end) / 2;
            OffsetG(:,1,end) = -stick.CBAR.vert.R(:,:,end)*[0; 0; str_rec_coef(end) + b1(end)];
            OffsetG(:,2,end) =  stick.CBAR.vert.R(:,:,end)*[0; 0; str_rec_coef(end) + b2(end)];
            MTOTV = sum(mass_reg2);
            if isequal(aircraft.Vertical_tail.Twin_tail, 1)
                MTOTV = 2*MTOTV;
            end
            
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fidOEW, ['\n$ Lumped masses: VTAIL ',num2str(MTOTV), ' Kg']);
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            %
            %  CONM2 card
            %
            for i = 1:length(stick.PID.vert)+1
                if mass_reg2(i) > 0.0
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.vert(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), OffsetG(2,1,i), OffsetG(3,1,i), 0,0,0,0,0,0);
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.vert(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), OffsetG(2,2,i), OffsetG(3,2,i), 0,0,0,0,0,0);
                end
            end
            
            if isequal(aircraft.Vertical_tail.Twin_tail, 1)
                for i = 1:length(stick.PID.vert)+1
                    if mass_reg2(i) > 0.0
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.vert2(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), -OffsetG(2,1,i), OffsetG(3,1,i), 0,0,0,0,0,0);
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.vert2(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), -OffsetG(2,2,i), OffsetG(3,2,i), 0,0,0,0,0,0);
                    end
                end
                
            end
        end
    end
    
    %======================================================================
    % Horizontal tail - Non structural mass from regression analysis
    %======================================================================
    if isequal(pdcylin.stick.model.horr, 1)
        
        if pdcylin.smartcad.ht_regr
            Y  = [0; cumsum(stick.htail.Lbeam_thick)];
            Y2 = 0.5.*(Y(2:end) + Y(1:end-1));
            Yc = [0; cumsum(stick.htail.Lbeam)];
            Yc2 = 0.5.*(Yc(2:end) + Yc(1:end-1));
            % Interpolate volume
            V = interp1(Y2, geo.htail.V,  Yc2, 'linear', 'extrap');
            aeroc = interp1(Y, geo.htail.r,  Yc2, 'linear', 'extrap');
            aeroZ = interp1(Y, geo.htail.Z,  Yc2, 'linear', 'extrap');
            sweep = aeroZ./aeroc;
            % wing box chord at beam midpoint
            strc  = interp1(Y, geo.htail.rs,  Yc2, 'linear', 'extrap');
            str_rec_coef = 0.5 .* strc;
            nctadd = length(geo.htail.y)-length(geo.htail.x);
            % wing box fraction at beam midpoint
            spar_frac = zeros(length(geo.htail.y),1);
            spar_frac(nctadd+1:end) = geo.htail.spar_frac;
            spar_frac(1:nctadd) = geo.htail.spar_frac(1);
            spar_frac = interp1(Y, spar_frac,  Yc2, 'linear', 'extrap');
            % LE cg distance  from spars
            b1 = sweep.*(spar_frac.*aeroc - str_rec_coef).*0.5;
            b2 = sweep.*(aeroc - spar_frac.*aeroc - str_rec_coef).*0.5;
            str_rec_coef = sweep .* str_rec_coef;
            OffsetG = zeros(3,2,length(stick.PID.hori)+1);
            OffsetG(:,1,1) = -stick.CBAR.horr.R(:,:,1)*[0; 0; str_rec_coef(1) + b1(1)];
            OffsetG(:,2,1) = stick.CBAR.horr.R(:,:,1)*[0; 0;  str_rec_coef(1) + b2(1)];
            
            % Initialize
            mass_reg1 = zeros(numel(V), 1);
            
            % HT volume except carry-through
            Vht = V(pdcylin.stick.nhtail_carryth+1:end);
            
            % HT box non structural mass
            mass_REG1 = sum(str.htail.WTBOX - str.htail.mbox);
            
            % HT box non structural lumped masses weighted on element volume
            mass_reg1(pdcylin.stick.nhtail_carryth+1:end) = mass_REG1 *(Vht/sum(Vht));
            
            % Carry-through non structural mass
            if geo.htail.twc > 0.0
                mass_REG2 = sum(str.htail.WTC - 2*sum(str.htail.mc))/2;
                mass_reg1(1:pdcylin.stick.nhtail_carryth) = mass_REG2 / pdcylin.stick.nhtail_carryth;
            end
            
            % Inertias
            % Nodal mass
            mass_reg2 = zeros(length(stick.PID.hori)+1, 1);
            mass_reg2(1) = mass_reg1(1) / 2;
            
            for i = 2 : length(stick.PID.hori)
                mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
                OffsetG(:,1,i) = -stick.CBAR.horr.R(:,:,i)*[0; 0; str_rec_coef(i) + b1(i)];
                OffsetG(:,2,i) =  stick.CBAR.horr.R(:,:,i)*[0; 0; str_rec_coef(i) + b2(i)];
            end
            mass_reg2(end) = mass_reg1(end) / 2;
            OffsetG(:,1,end) = -stick.CBAR.horr.R(:,:,end)*[0; 0; str_rec_coef(end) + b1(end)];
            OffsetG(:,2,end) =  stick.CBAR.horr.R(:,:,end)*[0; 0; str_rec_coef(end) + b2(end)];
            %
            MTOTH = sum(mass_reg2);
            if isequal(stick.model.symmXZ, 1)
                MTOTH = 2*MTOTH;
            end
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fidOEW, ['\n$ Lumped masses: HTAIL ',num2str(MTOTH), ' Kg']);
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            %
            %   CONM2 card
            %
            for i = 1:length(stick.PID.hori)+1
                if mass_reg2(i) > 0.0
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.horr(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), OffsetG(2,1,i), OffsetG(3,1,i), 0,0,0,0,0,0);
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.horr(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), OffsetG(2,2,i), OffsetG(3,2,i), 0,0,0,0,0,0);
                end
            end
            % symmetry
            if isequal(stick.model.symmXZ, 1)
                for i = 1:length(stick.PID.hori)+1
                    if mass_reg2(i) > 0.0
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.horl(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), -OffsetG(2,1,i), OffsetG(3,1,i), 0,0,0,0,0,0);
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.horl(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), -OffsetG(2,2,i), OffsetG(3,2,i), 0,0,0,0,0,0);
                    end
                end
            end
        end
    end
    
    %======================================================================
    % Canard - Non structural mass from regression analysis
    %======================================================================
    if isequal(pdcylin.stick.model.canr, 1)
        if (pdcylin.smartcad.canard_regr)
            Y  = [0; cumsum(stick.canr.Lbeam_thick)];
            Y2 = 0.5.*(Y(2:end) + Y(1:end-1));
            Yc = [0; cumsum(stick.canr.Lbeam)];
            Yc2 = 0.5.*(Yc(2:end) + Yc(1:end-1));
            % Interpolate volume
            V = interp1(Y2, geo.canard.V,  Yc2, 'linear', 'extrap');
            aeroc = interp1(Y, geo.canard.r,  Yc2, 'linear', 'extrap');
            aeroZ = interp1(Y, geo.canard.Z,  Yc2, 'linear', 'extrap');
            sweep = aeroZ./aeroc;
            % wing box chord at beam midpoint
            strc  = interp1(Y, geo.canard.rs,  Yc2, 'linear', 'extrap');
            str_rec_coef = 0.5 .* strc;
            nctadd = length(geo.canard.y)-length(geo.canard.x);
            % wing box fraction at beam midpoint
            spar_frac = zeros(length(geo.canard.y),1);
            spar_frac(nctadd+1:end) = geo.canard.spar_frac;
            spar_frac(1:nctadd) = geo.canard.spar_frac(1);
            spar_frac = interp1(Y, spar_frac,  Yc2, 'linear', 'extrap');
            % LE cg distance  from spars
            b1 = sweep.*(spar_frac.*aeroc - str_rec_coef).*0.5;
            b2 = sweep.*(aeroc - spar_frac.*aeroc - str_rec_coef).*0.5;
            str_rec_coef = sweep .* str_rec_coef;
            OffsetG = zeros(3,2,length(stick.PID.canr)+1);
            OffsetG(:,1,1) = -stick.CBAR.canr.R(:,:,1)*[0; 0; str_rec_coef(1) + b1(1)];
            OffsetG(:,2,1) = stick.CBAR.canr.R(:,:,1)*[0; 0;  str_rec_coef(1) + b2(1)];
            % Initialize
            mass_reg1 = zeros(numel(V), 1);
            
            % Canard volume except carry-through
            Vcn = V(pdcylin.stick.ncanard_carryth+1:end);
            
            % HT box non structural mass
            mass_REG1 = sum(str.canard.WTBOX - str.canard.mbox);
            
            % HT box non structural lumped masses weighted on element volume
            mass_reg1(pdcylin.stick.ncanard_carryth+1:end) = mass_REG1 *(Vcn/sum(Vcn));
            
            % Carry-through non structural mass
            if geo.canard.twc > 0.0
                mass_REG2 = sum(str.canard.WTC - 2*sum(str.canard.mc))/2;
                mass_reg1(1:pdcylin.stick.ncanard_carryth) = mass_REG2 / pdcylin.stick.ncanard_carryth;
            end
            % nodal mass
            mass_reg2 = zeros(length(stick.PID.canr)+1, 1);
            mass_reg2(1) = mass_reg1(1) / 2;
            for i = 2 : length(stick.PID.canr)
                mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
                OffsetG(:,1,i) = -stick.CBAR.canr.R(:,:,i)*[0; 0; str_rec_coef(i) + b1(i)];
                OffsetG(:,2,i) =  stick.CBAR.canr.R(:,:,i)*[0; 0; str_rec_coef(i) + b2(i)];
            end
            mass_reg2(end) = mass_reg1(end) / 2;
            OffsetG(:,1,end) = -stick.CBAR.canr.R(:,:,end)*[0; 0; str_rec_coef(end) + b1(end)];
            OffsetG(:,2,end) =  stick.CBAR.canr.R(:,:,end)*[0; 0; str_rec_coef(end) + b2(end)];
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fidOEW, '\n$ Lumped masses: CANARD');
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            %
            MTOTC = sum(mass_reg2);
            if isequal(stick.model.symmXZ, 1)
                MTOTC = 2*MTOTC;
            end
            % CONM2 card
            for i = 1:length(stick.PID.canr)+1
                if mass_reg2(i) > 0.0
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.canr(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), OffsetG(2,1,i), OffsetG(3,1,i), 0,0,0,0,0,0);
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fidOEW, IDconm, stick.ID.canr(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), OffsetG(2,2,i), OffsetG(3,2,i), 0,0,0,0,0,0);
                end
            end
            % symmetry
            if isequal(stick.model.symmXZ, 1)
                for i = 1:length(stick.PID.canr)+1
                    if mass_reg2(i) > 0.0
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.canl(i), 0, mass_reg2(i)*WLE, OffsetG(1,1,i), -OffsetG(2,1,i), OffsetG(3,1,i), 0,0,0,0,0,0);
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, stick.ID.canl(i), 0, mass_reg2(i)*WTE, OffsetG(1,2,i), -OffsetG(2,2,i), OffsetG(3,2,i), 0,0,0,0,0,0);
                    end
                end
            end
        end
    end
    
end % export regression

%==========================================================================
% Engines1
%==========================================================================
if EXPORT_OEW
    
    if aircraft.engines1.present
        
        MTOTE = aircraft.weight_balance.COG(7,4,1);
        
        % Update counter
        IDconm = IDconm+1;
        
        % Mass associated to single engine
        M = MTOTE/aircraft.engines1.Number_of_engines;
        
        % Engine1 mid-point coordinates
        Xcg = aircraft.weight_balance.COG(7,1,1);
        Ycg = aircraft.weight_balance.COG(7,2,1);
        Zcg = aircraft.weight_balance.COG(7,3,1);
        
        % Second moments of inertia
        I11 = 0; I21 = 0; I22 = 0;
        I31 = 0; I32 = 0; I33 = 0;
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fidOEW, ['\n$ Lumped masses: ENGINES ',num2str(MTOTE), ' Kg']);
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        
        % This control is intended as preventive, in the sense there is no
        % possibility that a lumped mass in the symmetry plane (XZ) could be
        % associated to nodes out of plane of symmetry for node distribution
        % reasons.
        if isequal(Ycg, 0)
            
            % Set CONM2 parameters
            if aircraft.engines1.Layout_and_config == 0 || aircraft.engines1.Layout_and_config == 1 || aircraft.engines1.Layout_and_config == 2 %|| aircraft.engines1.Layout_and_config == 3
                % link to wing
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.winrC2, stick.ID.winr);
            else
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
            end
            
        else
            
            % Set CONM2 parameters
            if aircraft.engines1.Layout_and_config == 0 || aircraft.engines1.Layout_and_config == 1 || aircraft.engines1.Layout_and_config == 2 %|| aircraft.engines1.Layout_and_config == 3
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup_along_direction(Xcg, Ycg, Zcg, stick.nodes.winrC2, stick.ID.winr, 2);
            else
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
            end
            
        end
        
        % CONM2 card
        BULKdataCONM2(fidOEW, IDconm, IDclc, 0, M, X1offset, X2offset, X3offset, I11, I21, I22, I31, I32, I33);
        
        if isequal(stick.model.symmXZ, 1) && (Ycg ~= 0)
            
            % Update counter
            IDconm = IDconm+1;
            
            % Set CONM2 parameters
            if aircraft.engines1.Layout_and_config == 0 || aircraft.engines1.Layout_and_config == 1 || aircraft.engines1.Layout_and_config == 2 %||aircraft.engines1.Layout_and_config == 3
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup_along_direction(Xcg, -Ycg, Zcg, stick.nodes.winlC2, stick.ID.winl, 2);
            else
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, -Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
            end
            
            % CONM2 card
            BULKdataCONM2(fidOEW, IDconm, IDclc, 0, M, X1offset, X2offset, X3offset, I11, I21, I22, I31, I32, I33);
            
        end
        
        % Save in the total mass
        str.M = str.M + aircraft.weight_balance.COG(7,4,1);
        
    end
    
    %======================================================================
    % Engines2
    %======================================================================
    
    if aircraft.engines2.present
        
        MTOTE2 = aircraft.weight_balance.COG(8,4,1);
        
        % Update counter
        IDconm = IDconm+1;
        
        % Mass associated to single engine
        M = MTOTE2/aircraft.engines2.Number_of_engines;
        
        % CG coordinate of engine2
        Xcg = aircraft.weight_balance.COG(8,1,1);
        Ycg = aircraft.weight_balance.COG(8,2,1);
        Zcg = aircraft.weight_balance.COG(8,3,1);
        
        % Second moments of inertia
        I11 = 0; I21 = 0; I22 = 0;
        I31 = 0; I32 = 0; I33 = 0;
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fidOEW, ['\n$ Lumped masses: ENGINES2 ',num2str(MTOTE2), ' Kg']);
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        
        % This control is intended as preventive, in the sense there is no
        % possibility that a lumped mass in the symmetry plane (XZ) could be
        % associated to nodes out of plane of symmetry for node distribution
        % reasons.
        if isequal(Ycg, 0)
            
            % Set CONM2 parameters
            if aircraft.engines2.Layout_and_config == 0 || aircraft.engines2.Layout_and_config == 1 || aircraft.engines2.Layout_and_config == 2 %||aircraft.engines1.Layout_and_config == 3
                % link to wing
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.winrC2, stick.ID.winr);
            else
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
            end
            
        else
            
            % Set CONM2 parameters
            if aircraft.engines2.Layout_and_config == 0 || aircraft.engines2.Layout_and_config == 1 || aircraft.engines2.Layout_and_config == 2 %||aircraft.engines1.Layout_and_config == 3
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup_along_direction(Xcg, Ycg, Zcg, stick.nodes.winrC2, stick.ID.winr, 2);
            else
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
            end
            
        end
        
        % CONM2 card
        BULKdataCONM2(fidOEW, IDconm, IDclc, 0, M, X1offset, X2offset, X3offset, I11, I21, I22, I31, I32, I33);
        
        if isequal(stick.model.symmXZ, 1) && (Ycg ~= 0)
            
            % Update counter
            IDconm = IDconm+1;
            % Set CONM2 parameters
            if aircraft.engines2.Layout_and_config == 0 || aircraft.engines2.Layout_and_config == 1 || aircraft.engines2.Layout_and_config == 2 %||aircraft.engines1.Layout_and_config == 3
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup_along_direction(Xcg, -Ycg, Zcg, stick.nodes.winlC2, stick.ID.winl, 2);
            else
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, -Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
            end
            % CONM2 card
            BULKdataCONM2(fidOEW, IDconm, IDclc, 0, M, X1offset, X2offset, X3offset, I11, I21, I22, I31, I32, I33);
            
        end
        
        % Save in the total mass
        str.M = str.M + aircraft.weight_balance.COG(8,4,1);
        
    end
    
    %======================================================================
    % Landing gear
    %======================================================================
    % Landing gear total mass
    MTOTLG = aircraft.weight_balance.COG(6,4,1);
    
    % Set coordinates
    Xcg = aircraft.weight_balance.COG(6,1,1);
    Ycg = abs(aircraft.weight_balance.COG(6,2,1));
    Zcg = aircraft.weight_balance.COG(6,3,1);
    
    %
    if MESH_LEVEL == 0 % GUESS MESH - do not export RBE connection to avoid error when SMARTCAD loads the file
        
        if MTOTLG > 0.0 && Xcg > 0.0
            
            fprintf(outf, '\n\t\t- Main landing gear: %g kg, ', MTOTLG);
            
            % Update counter
            IDconm = IDconm+1;
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fidOEW, ['\n$ Lumped masses: MAIN LANDING GEAR ',num2str(MTOTLG), ' Kg']);
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            
            str.M = str.M + MTOTLG;
            
            if Ycg == 0
                
                fprintf(outf, 'exported as simple CONM2.');
                
                % Set CONM2 parameters
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, ALLndsXZ, ALLIDsXZ);
                
                I11 = 0;
                I22 = 0;
                I33 = 0;
                I21 = 0;
                I31 = 0;
                I32 = 0;
                
                % CONM2 card
                BULKdataCONM2(fidOEW, IDconm, IDclc, 0, MTOTLG, X1offset, X2offset, X3offset, I11, I21, I22, I31, I32, I33);
                fprintf(fidOEW, 'PARAM   LANDG   %d\n', IDclc);
                
            else
                
                if isempty(stick.ID.extrar_thick)
                    idlgr = 9000;
                else
                    idlgr = stick.ID.extrar_thick(end) + 1;
                end
                
                if isequal(stick.model.symmXZ, 1)
                    
                    MTOTLG = MTOTLG/2;
                    
                    if isempty(stick.ID.extral_thick)
                        idlgl = 9001;
                    else
                        idlgl = stick.ID.extral_thick(end) + 1;
                    end
                    
                end
                
                ner = length(stick.ID.extrar_thick)+1;
                stick.ID.extrar_thick(ner)      = idlgr;
                stick.nodes.extrar_thick(1,ner) = Xcg;
                stick.nodes.extrar_thick(2,ner) = Ycg;
                stick.nodes.extrar_thick(3,ner) = Zcg;
                BULKdataGRID(fidOEW, stick.ID.extrar_thick(ner), 0, Xcg, Ycg, Zcg, 0, 0, 0);
                
                % Attach landing gear to CT or fuselage
                nrbe = length(stick.link_thick.Ma_thick)+1;
                
                if aircraft.miscellaneous.main_landing_gear_on_fuselage > 0
                    
                    fprintf(outf, 'Exported as CONM2 linked to fuselage through RBE2.');
                    % Create 1 RBE2 with 2 dependent nodes
                    %
                    % Find node to attach landing gear
                    IDclc = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
                    stick.link_thick.Ma_thick(nrbe)   = IDclc;
                    stick.link_thick.RBE2(nrbe).DOF   = 123456;
                    stick.link_thick.RBE2(nrbe).slave = idlgr;
                    BULKdataCONM2(fidOEW, IDconm, idlgr, 0, MTOTLG, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                    fprintf(fidOEW, 'PARAM   LANDG   %d\n', idlgr);
                    
                    if isequal(stick.model.symmXZ, 1)
                        
                        stick.link_thick.RBE2(nrbe).slave(2) = idlgl;
                        nel = length(stick.ID.extral_thick)+1;
                        stick.nodes.extral_thick(1,nel) = Xcg;
                        stick.nodes.extral_thick(2,nel) = -Ycg;
                        stick.nodes.extral_thick(3,nel) = Zcg;
                        stick.ID.extral_thick(nel)      = idlgl;
                        BULKdataGRID(fidOEW, stick.ID.extral_thick(nel), 0, Xcg, -Ycg, Zcg, 0, 0, 0);
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fidOEW, IDconm, idlgl, 0, M, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                        fprintf(fidOEW, 'PARAM   LANDG   %d\n', idlgl);
                        
                    end
                    
                else
                    
                    % Create 2 RBE2 with 2 dependent nodes
                    fprintf(outf, 'Exported as CONM2 linked to wing carry-through through RBE2.');
                    stick.link_thick.Ma_thick(nrbe)   = stick.ID.winr_thick(pdcylin.stick.nwing_carryth_coarse);
                    stick.link_thick.RBE2(nrbe).DOF   = 123456;
                    stick.link_thick.RBE2(nrbe).slave = idlgr;
                    %
                    BULKdataCONM2(fidOEW, IDconm, idlgr, 0, MTOTLG, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                    fprintf(fidOEW, 'PARAM   LANDG %d\n', idlgr);
                    
                    if isequal(stick.model.symmXZ, 1)
                        
                        nel = length(stick.ID.extral_thick)+1;
                        stick.ID.extral_thick(nel)      = idlgl;
                        stick.nodes.extral_thick(1,nel) = Xcg;
                        stick.nodes.extral_thick(2,nel) = -Ycg;
                        stick.nodes.extral_thick(3,nel) = Zcg;
                        BULKdataGRID(fidOEW, stick.ID.extral_thick(nel), 0, Xcg, -Ycg, Zcg, 0, 0, 0);
                        
                        nrbe = nrbe + 1;
                        stick.link_thick.Ma_thick(nrbe)   = stick.ID.winl_thick(pdcylin.stick.nwing_carryth_coarse);
                        stick.link_thick.RBE2(nrbe).DOF   = 123456;
                        stick.link_thick.RBE2(nrbe).slave = idlgl;
                        
                        IDconm = IDconm+1;
                        BULKdataCONM2(fidOEW, IDconm, idlgl, 0, M, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                        fprintf(fidOEW, 'PARAM   LANDG   %d\n', idlgl);
                        
                    end
                    
                end
                
            end
            
        end
        %
    else
        
        if MTOTLG > 0.0 && Xcg > 0.0
            
            fprintf(outf, '\n\t\t- Main landing gears: %g kg, ', MTOTLG);
            
            % Update counter
            IDconm = IDconm+1;
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fidOEW, ['\n$ Lumped masses: MAIN LANDING GEAR ',num2str(MTOTLG), ' Kg']);
            fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            
            str.M = str.M + MTOTLG;
            
            if Ycg == 0
                
                fprintf(outf, 'exported as simple CONM2.');
                % Set CONM2 parameters
                [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, ALLndsXZ, ALLIDsXZ);
                
                I11 = 0;
                I22 = 0;
                I33 = 0;
                I21 = 0;
                I31 = 0;
                I32 = 0;
                
                % CONM2 card
                BULKdataCONM2(fidOEW, IDconm, IDclc, 0, MTOTLG, X1offset, X2offset, X3offset, I11, I21, I22, I31, I32, I33);
                fprintf(fidOEW, 'PARAM   LANDG   %d\n', IDclc);
                
            else
                
                if isempty(stick.ID.extrar)
                    idlgr = 9000;
                else
                    idlgr = stick.ID.extrar(end) +1;
                end
                
                if isequal(stick.model.symmXZ, 1)
                    
                    MTOTLG = MTOTLG/2;
                    if isempty(stick.ID.extral)
                        idlgl = 9001;
                    else
                        idlgl = stick.ID.extral(end) +1;
                    end
                    
                end
                
                ner = length(stick.ID.extrar)+1;
                stick.ID.extrar(ner)      = idlgr;
                stick.nodes.extrar(1,ner) = Xcg;
                stick.nodes.extrar(2,ner) = Ycg;
                stick.nodes.extrar(3,ner) = Zcg;
                BULKdataGRID(fidOEW, stick.ID.extrar(ner), 0, Xcg, Ycg, Zcg, 0, 0, 0);
                
                % Attach landing gear to fuselage or CT
                nrbe = length(stick.link.Ma) + 1;
                
                if aircraft.miscellaneous.main_landing_gear_on_fuselage > 0
                    % Find node to attach landing gear
                    fprintf(outf, 'Linked to fuselage through RBE2.');
                    IDclc = CONM2_setup(Xcg, Ycg, Zcg, stick.nodes.fuse, stick.ID.fuse);
                    stick.link.Ma(nrbe)         = IDclc;
                    stick.link.RBE2(nrbe).DOF   = 123456;
                    stick.link.RBE2(nrbe).slave = idlgr;
                    BULKdataCONM2(fidOEW, IDconm, idlgr, 0, MTOTLG, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                    fprintf(fidOEW, 'PARAM   LANDG   %d\n', idlgr);
                    
                    if isequal(stick.model.symmXZ, 1)
                        
                        stick.link.RBE2(nrbe).slave(2) = idlgl;
                        nel = length(stick.ID.extral)+1;
                        stick.ID.extral(nel)      = idlgl;
                        stick.nodes.extral(1,nel) = Xcg;
                        stick.nodes.extral(2,nel) = -Ycg;
                        stick.nodes.extral(3,nel) = Zcg;
                        BULKdataGRID(fidOEW, stick.ID.extral(nel), 0, Xcg, -Ycg, Zcg, 0, 0, 0);
                        IDconm = IDconm+1;
                        BULKdataCONM2(fidOEW, IDconm, idlgl, 0, MTOTLG, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                        fprintf(fidOEW, 'PARAM   LANDG   %d\n', idlgl);
                        
                    end
                    BULKdataRB2(fidOEW, nrbe, stick.link.Ma(nrbe), stick.link.RBE2(nrbe).DOF, stick.link.RBE2(nrbe).slave);
                    
                else
                    
                    fprintf(outf, 'Linked to wing carry-through through RBE2.');
                    stick.link.Ma(nrbe)         = stick.ID.winr(pdcylin.stick.nwing_carryth);
                    stick.link.RBE2(nrbe).DOF   = 123456;
                    stick.link.RBE2(nrbe).slave = idlgr;
                    BULKdataRB2(fidOEW, nrbe, stick.link.Ma(nrbe), stick.link.RBE2(nrbe).DOF, stick.link.RBE2(nrbe).slave);
                    BULKdataCONM2(fidOEW, IDconm, idlgr, 0, MTOTLG, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                    fprintf(fidOEW, 'PARAM   LANDG   %d\n', idlgr);
                    
                    if isequal(stick.model.symmXZ, 1)
                        nel = length(stick.ID.extral)+1;
                        stick.ID.extral(nel)      = idlgl;
                        stick.nodes.extral(1,nel) = Xcg;
                        stick.nodes.extral(2,nel) = -Ycg;
                        stick.nodes.extral(3,nel) = Zcg;
                        BULKdataGRID(fidOEW, stick.ID.extral(nel), 0, Xcg, -Ycg, Zcg, 0, 0, 0);
                        
                        nrbe = nrbe+1;
                        stick.link.Ma(nrbe)         = stick.ID.winl(pdcylin.stick.nwing_carryth);
                        stick.link.RBE2(nrbe).DOF   = 123456;
                        stick.link.RBE2(nrbe).slave = idlgl;
                        BULKdataRB2(fidOEW, nrbe, stick.link.Ma(nrbe), stick.link.RBE2(nrbe).DOF, stick.link.RBE2(nrbe).slave);
                        
                        IDconm = IDconm+1;
                        BULKdataCONM2(fidOEW, IDconm, idlgl, 0, MTOTLG, 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33);
                        fprintf(fidOEW, 'PARAM   LANDG   %d\n', idlgl);
                        
                    end
                end
            end
        end
    end
    
    % Nose Landing gear total mass
    MNLG = aircraft.weight_balance.COG(9,4,1);
    
    % Set coordinates
    Xcg = aircraft.weight_balance.COG(9,1,1);
    Ycg = abs(aircraft.weight_balance.COG(9,2,1));
    Zcg = aircraft.weight_balance.COG(9,3,1);
    
    if MNLG > 0.0 && Xcg > 0.0
        
        fprintf(outf, '\n\t\t- nose landing gear: %g kg, ', MNLG);
        IDconm = IDconm+1;
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fidOEW, ['\n$ Lumped masses: NOSE LANDING GEAR ',num2str(MNLG), ' Kg']);
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        str.M = str.M + MNLG;
        
        fprintf(outf, 'Exported as simple CONM2.');
        % Set CONM2 parameters
        [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, ALLndsXZ, ALLIDsXZ);
        % CONM2 card
        BULKdataCONM2(fidOEW, IDconm, IDclc, 0, MNLG, X1offset, X2offset, X3offset, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
        
    end
    
end % export_OEW

%==========================================================================
% Auxiliary fuel tank
%==========================================================================
% Fuel mass in auxiliary tanks
MTOTAUX = aircraft.weight_balance.COG(20,4,1);

% Set coordinates
Xcg = aircraft.weight_balance.COG(20,1,1);
Ycg = aircraft.weight_balance.COG(20,2,1);
Zcg = aircraft.weight_balance.COG(20,3,1);

% Second moments of inertia
I11 = 0; I21 = 0; I22 = 0;
I31 = 0; I32 = 0; I33 = 0;

if MTOTAUX > 0.0 && Xcg > 0.0
    
    % Update counter
    IDconm = IDconm + 1;
    
    % Set CONM2 parameters
    [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, ALLndsXZ, ALLIDsXZ);
    
    % CONM2 card
    fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
    fprintf(fid, ['\n$ Lumped masses: AUXILIARY TANK ',num2str(MTOTAUX), ' Kg']);
    fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
    BULKdataCONM2(fid, IDconm, IDclc, 0, MTOTAUX, X1offset, X2offset, X3offset, I11, I21, I22, I31, I32, I33);
    
    % Save in the total mass
    str.M = str.M + MTOTAUX;
    
end

%==========================================================================
% BAGGAGE
%==========================================================================
MTOTBG = aircraft.weight_balance.COG(25,4,1);

if MTOTBG > 0
    
    if isequal(pdcylin.stick.model.fuse, 1)
        
        % mthick = 0.5*(stick.nodes.fuse_thick(1,1:end-1) + stick.nodes.fuse_thick(1,2:end));
        mthick = geo.fus.x_nodes_1_2_thick;
        
        % OLD VERSION
        % domain = [geo.fus.bodl*aircraft.Baggage.Baggage_apex_per_fuselgt + aircraft.Baggage.Baggage_combined_length * pdcylin.MassConf.BagStart, ...
        %           geo.fus.bodl*aircraft.Baggage.Baggage_apex_per_fuselgt + aircraft.Baggage.Baggage_combined_length  * pdcylin.MassConf.BagArrive];
        
        % All these quantities are defined in the global axis system, where the
        % x-axis is not the curvilinear abscissa related to the beam model
        fuselageLength_x = geo.fus.bodl;
        baggageApex_x    = aircraft.Baggage.Baggage_apex_per_fuselgt*fuselageLength_x;
        baggageLength_x  = aircraft.Baggage.Baggage_combined_length;
        
        domain = baggageApex_x + baggageLength_x.*[pdcylin.MassConf.BagStart, pdcylin.MassConf.BagArrive];
        
        GEOCG = mean(domain);
        ind1  = find(mthick >= domain(1));
        ind1  = ind1(1);
        ind2  = find(mthick <= domain(2));
        ind2  = ind2(end);
        if ind1 > ind2
            ind2 = ind1;
        end
        mass_bagg_thick = zeros(length(stick.fus.Lbeam_thick), 1);
        mass_bagg_thick(ind1:ind2) = ...
            MTOTBG.*(stick.fus.Lbeam_thick(ind1:ind2)./sum(stick.fus.Lbeam_thick(ind1:ind2)));
        
        if MESH_LEVEL == 1
            
            mass_reg1 = zeros(length(stick.fus.Lbeam),1);
            fnodes = stick.nodes.fuse(1,:);
            for i=1:length(stick.fus.Lbeam)
                ind1 = find(mthick>=stick.nodes.fuse(1,i));
                ind1 = ind1(1);
                ind2 = find(mthick<stick.nodes.fuse(1,i+1));
                ind2 = ind2(end);
                mass_reg1(i) = sum(mass_bagg_thick(ind1:ind2));
            end
            
        else
            fnodes = stick.nodes.fuse_thick(1,:);
            mass_reg1 = mass_bagg_thick;
        end
        %    Jt_regX = (0.25 .* mass_reg1) .*...
        %    (stick.PBAR.fuse.str_rec_coef.D2.^2 + stick.PBAR.fuse.str_rec_coef.C1.^2);
        %    Jt_regY = 1/12 .* mass_reg1 .* stick.fus.Lbeam.^2;
        %    Jt_regZ = 1/12 .* mass_reg1 .* stick.fus.Lbeam.^2;
        
        % Nodal mass
        mass_reg2 = zeros(length(stick.PID.fuse)+1, 1);
        %    Jt_reg2 = mass_reg2;
        %    Iglobal = zeros(3,3,length(stick.PID.fuse)+1);
        
        mass_reg2(1) = mass_reg1(1) / 2;
        %    Jt_reg2X(1) = Jt_regX(1) / 2 ;
        %    Jt_reg2Y(1) = Jt_regY(1) / 2 ;
        %    Jt_reg2Z(1) = Jt_regZ(1) / 2 ;
        %    Iglobal(:,:,1) = stick.CBAR.fuse.R(:,:,1) * [ Jt_reg2X(1) 0 0; 0 Jt_reg2Y(1) 0; 0 0 Jt_reg2Z(1)] * stick.CBAR.fuse.R(:,:,1)';
        
        for i = 2 : length(stick.PID.fuse)
            mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
            %      Jt_reg2X(i) = (Jt_regX(i-1)+Jt_regX(i)) / 2;
            %      Jt_reg2Y(i) = (Jt_regY(i-1)+Jt_regY(i)) / 2;
            %      Jt_reg2Z(i) = (Jt_regZ(i-1)+Jt_regZ(i)) / 2;
            %      Iglobal(:,:,i) = (stick.CBAR.fuse.R(:,:,i-1) * [ Jt_regX(i-1) 0 0; 0 Jt_regY(i-1) 0; 0 0 Jt_regZ(i-1)] * stick.CBAR.fuse.R(:,:,i-1)' + ...
            %        stick.CBAR.fuse.R(:,:,i) * [ Jt_regX(i) 0 0; 0 Jt_regY(i) 0; 0 0 Jt_regZ(i)] * stick.CBAR.fuse.R(:,:,i)') * 0.5;
        end
        mass_reg2(end) = mass_reg1(end) / 2;
        %    Jt_reg2X(end) = Jt_regX(end) / 2 ;
        %    Jt_reg2Y(end) = Jt_regY(end) / 2 ;
        %    Jt_reg2Z(end) = Jt_regZ(end) / 2 ;
        %    Iglobal(:,:,end) = stick.CBAR.fuse.R(:,:,end)' * [ Jt_reg2X(end) 0 0; 0 Jt_reg2Y(end) 0; 0 0 Jt_reg2Z(end)] * stick.CBAR.fuse.R(:,:,end);
        
        mass_reg2 = massCONC_opt(fnodes, domain, MTOTBG, GEOCG, mass_reg2');
        MTOTBG    = sum(mass_reg2);
        
        fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fid, ['\n$ Lumped masses: BAGGAGE ',num2str(MTOTBG), ' Kg']);
        ind1 = find(mass_reg1);
        fprintf(fid, ['\n$ Fuselage beams: from ', num2str(ind1(1)), ' to ', num2str(ind1(end))]);
        fprintf(fid, ['\n$ Fraction of baggage length: from ', num2str(pdcylin.MassConf.BagStart*100), ' to ', num2str(pdcylin.MassConf.BagArrive*100),' %%']);
        fprintf(fid, '\n$ XML variabile: aircraft.Baggage.Baggage_combined_length = %g m.', baggageLength_x);
        fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        
        % CONM2 card
        for i = 1:length(stick.PID.fuse)+1
            if mass_reg2(i) > 0
                IDconm = IDconm + 1;
                BULKdataCONM2(fid, IDconm, stick.ID.fuse(i), 0, mass_reg2(i), 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
            end
        end
    end
    
end

%==========================================================================
% PASSENGERS
%==========================================================================
MTOTPAX = aircraft.weight_balance.COG(24,4,1);

if MTOTPAX > 0
    
    if isequal(pdcylin.stick.model.fuse, 1)
        
        %         mthick = 0.5*(stick.nodes.fuse_thick(1,1:end-1) + stick.nodes.fuse_thick(1,2:end));
        mthick = geo.fus.x_nodes_1_2_thick;
        
        % OLD VERSION: incorrect definition of cabin length
        %         domain = [geo.fus.lengthN + pdcylin.MassConf.PaxStart * aircraft.cabin.Cabin_length_to_aft_cab,...
        %             geo.fus.lengthN + pdcylin.MassConf.PaxArrive * aircraft.cabin.Cabin_length_to_aft_cab];
        
        SeatsAbreast = aircraft.cabin.Seats_abreast_in_fuselage;
        SeatsPitch  = aircraft.cabin.Passengers_seats_pitch;
        Passengers = aircraft.cabin.Passenger_accomodation;
        if (SeatsAbreast==0)
            nrow = 0;
        else
            nrow   = ceil(Passengers/SeatsAbreast);  
        end
    
        if nrow == 0
            lpass  = 0;
        else
            lpass  = nrow*0.3 + (nrow-1)*SeatsPitch;
        end
    
        ncrabr = 4; % Seats Abreast per crew and attendants
        CockpitCrewNumber  = aircraft.cabin.Flight_crew_number;
        AttendantsNumber  = aircraft.cabin.Cabin_attendant_number;
        crattpitch = 0.7;
        nrowcratt = ceil(CockpitCrewNumber/ncrabr) + ceil(AttendantsNumber/ncrabr);
        lcratt = 0.8 + nrowcratt*0.3 + (nrowcratt-1)*crattpitch; % 0.8 per estremi
    
        % Dim Sedili 0.4 + 0.3 >>> Dist 0.3

% ----------------------------------------------------------------        
% old, replaced by the following line to position passengers correcly matching acbuilder output   
%
%         domain = geo.fus.lengthN + geo.fus.lengthMID.*[pdcylin.MassConf.PaxStart, pdcylin.MassConf.PaxArrive];
% ----------------------------------------------------------------               
        domain = aircraft.cabin.Floor_apex_per_fuselgt + lcratt + lpass.*[pdcylin.MassConf.PaxStart, pdcylin.MassConf.PaxArrive];

        
        GEOCG = mean(domain);
        ind1  = find(mthick >= domain(1));
        ind1  = ind1(1);
        ind2  = find(mthick <= domain(2));
        ind2  = ind2(end);
        if ind1 > ind2
            ind2 = ind1;
        end
        mass_pax_thick = zeros(length(stick.fus.Lbeam_thick),1);
        mass_pax_thick(ind1:ind2) = MTOTPAX.*...
            (stick.fus.Lbeam_thick(ind1:ind2)./sum(stick.fus.Lbeam_thick(ind1:ind2)));
        
        if MESH_LEVEL == 1
            mass_reg1 = zeros(length(stick.fus.Lbeam),1);
            fnodes = stick.nodes.fuse(1,:);
            for i=1:length(stick.fus.Lbeam)
                ind1 = find(mthick>=stick.nodes.fuse(1,i));
                ind1 = ind1(1);
                ind2 = find(mthick<stick.nodes.fuse(1,i+1));
                ind2 = ind2(end);
                mass_reg1(i) = sum(mass_pax_thick(ind1:ind2));
            end
        else
            fnodes = stick.nodes.fuse_thick(1,:);
            mass_reg1 = mass_pax_thick;
        end
        %    Jt_regX = (0.25 .* mass_reg1) .*...
        %    (stick.PBAR.fuse.str_rec_coef.D2.^2 + stick.PBAR.fuse.str_rec_coef.C1.^2);
        %    Jt_regY = 1/12 .* mass_reg1 .* stick.fus.Lbeam.^2;
        %    Jt_regZ = 1/12 .* mass_reg1 .* stick.fus.Lbeam.^2;
        
        % Nodal mass
        mass_reg2 = zeros(length(stick.PID.fuse)+1, 1);
        %    Jt_reg2 = mass_reg2;
        %    Iglobal = zeros(3,3,length(stick.PID.fuse)+1);
        
        mass_reg2(1) = mass_reg1(1) / 2;
        %    Jt_reg2X(1) = Jt_regX(1) / 2 ;
        %    Jt_reg2Y(1) = Jt_regY(1) / 2 ;
        %    Jt_reg2Z(1) = Jt_regZ(1) / 2 ;
        %    Iglobal(:,:,1) = stick.CBAR.fuse.R(:,:,1) * [ Jt_reg2X(1) 0 0; 0 Jt_reg2Y(1) 0; 0 0 Jt_reg2Z(1)] * stick.CBAR.fuse.R(:,:,1)';
        
        for i = 2 : length(stick.PID.fuse)
            mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
            %      Jt_reg2X(i) = (Jt_regX(i-1)+Jt_regX(i)) / 2;
            %      Jt_reg2Y(i) = (Jt_regY(i-1)+Jt_regY(i)) / 2;
            %      Jt_reg2Z(i) = (Jt_regZ(i-1)+Jt_regZ(i)) / 2;
            %      Iglobal(:,:,i) = (stick.CBAR.fuse.R(:,:,i-1) * [ Jt_regX(i-1) 0 0; 0 Jt_regY(i-1) 0; 0 0 Jt_regZ(i-1)] * stick.CBAR.fuse.R(:,:,i-1)' + ...
            %        stick.CBAR.fuse.R(:,:,i) * [ Jt_regX(i) 0 0; 0 Jt_regY(i) 0; 0 0 Jt_regZ(i)] * stick.CBAR.fuse.R(:,:,i)') * 0.5;
        end
        mass_reg2(end) = mass_reg1(end) / 2;
        %    Jt_reg2X(end) = Jt_regX(end) / 2 ;
        %    Jt_reg2Y(end) = Jt_regY(end) / 2 ;
        %    Jt_reg2Z(end) = Jt_regZ(end) / 2 ;
        %    Iglobal(:,:,end) = stick.CBAR.fuse.R(:,:,end)' * [ Jt_reg2X(end) 0 0; 0 Jt_reg2Y(end) 0; 0 0 Jt_reg2Z(end)] * stick.CBAR.fuse.R(:,:,end);
        
        mass_reg2 = massCONC_opt(fnodes, domain, MTOTPAX, GEOCG, mass_reg2');
        MTOTPAX = sum(mass_reg2);
        
        fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fid, ['\n$ Lumped masses: PASSENGERS ',num2str(MTOTPAX), ' Kg']);
        ind1 = find(mass_reg1);
        fprintf(fid, ['\n$ Fuselage beams: from ', num2str(ind1(1)), ' to ', num2str(ind1(end))]);
        fprintf(fid, ['\n$ Fraction of cabin length : from ', num2str(pdcylin.MassConf.PaxStart*100), ' to ', num2str(pdcylin.MassConf.PaxArrive*100),' %%']);
        fprintf(fid, '\n$ Cabin length = %g m.', geo.fus.lengthMID);
        %         fprintf(fid, '\n$ XML variabile: aircraft.cabin.Cabin_length_to_aft_cab = %g m.', aircraft.cabin.Cabin_length_to_aft_cab);
        fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        
        % CONM2 card
        for i = 1:length(stick.PID.fuse)+1
            if mass_reg2(i)>0
                IDconm = IDconm + 1;
                % BULKdataCONM2(fid, IDconm, stick.ID.fuse(i), 0, mass_reg2(i), 0, 0, 0, Iglobal(1,1,i), Iglobal(2,1,i), Iglobal(2,2,i), Iglobal(3,1,i), Iglobal(3,2,i), Iglobal(3,3,i));
                BULKdataCONM2(fid, IDconm, stick.ID.fuse(i), 0, mass_reg2(i), 0, 0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
            end
        end
    end
end

%==========================================================================
% WING TANKS FUEL
%==========================================================================
%
if aircraft.weight_balance.COG(18,4,1) > 0
    %
    if isequal(pdcylin.stick.model.winr, 1)
        bfuel  = pdcylin.MassConf.WfuelArrive * geo.wing.b*0.5;
        afuel  = pdcylin.MassConf.WfuelStart  * geo.wing.b*0.5;
        dV    = geo.wing.V;
        mthick = 0.5*(stick.nodes.winrC2_thick(2,1:end-1) + stick.nodes.winrC2_thick(2,2:end));
        ind1 = find(mthick>=afuel);
        ind1 = ind1(1);
        ind2 = find(mthick<=bfuel);
        
        if isempty(ind2)
            fprintf(1, '\n\t### Warning: fuel tank span too short. No fuel loaded in wings.');
        else
            ind2 = ind2(end);
            mass_fuel_thick = zeros(length(stick.wing.Lbeam_thick),1);
            mass_fuel_thick(ind1:ind2) = (aircraft.weight_balance.COG(18,4,1)/2) .*(dV(ind1:ind2)./sum(dV(ind1:ind2)));
            
            if MESH_LEVEL == 1
                mass_reg1 = zeros(length(stick.wing.Lbeam),1);
                for i=1:length(stick.wing.Lbeam)
                    ind1 = find(mthick>=stick.nodes.winrC2(2,i));
                    ind1 = ind1(1);
                    ind2 = find(mthick<stick.nodes.winrC2(2,i+1));
                    ind2 = ind2(end);
                    mass_reg1(i) = sum(mass_fuel_thick(ind1:ind2));
                end
            else
                mass_reg1 = mass_fuel_thick;
            end
            Jt_regX = mass_reg1'./(stick.PBAR.wing.str_rec_coef.D(1,:).*stick.PBAR.wing.str_rec_coef.C(2,:)*4) .*...
                1/12 .* ( ( (stick.PBAR.wing.str_rec_coef.D(1,:)*2).^3 .* (stick.PBAR.wing.str_rec_coef.C(2,:)*2)) +...
                ((stick.PBAR.wing.str_rec_coef.C(2,:)*2).^3 .* (stick.PBAR.wing.str_rec_coef.D(1,:)*2))  );
            Jt_regY = 1/12 .* mass_reg1 .* stick.wing.Lbeam.^2;
            Jt_regZ = 1/12 .* mass_reg1 .* stick.wing.Lbeam.^2;
            % nodal mass
            mass_reg2 = zeros(length(stick.PID.wing)+1, 1);
            Jt_reg2X = mass_reg2;
            Iglobal = zeros(3,3,length(stick.PID.wing)+1);
            Jt_reg2X(1) = Jt_regX(1) / 2 ;
            Jt_reg2Y(1) = Jt_regY(1) / 2 ;
            Jt_reg2Z(1) = Jt_regZ(1) / 2 ;
            Iglobal(:,:,1) = stick.CBAR.winr.R(:,:,1) * [ Jt_reg2X(1) 0 0; 0 Jt_reg2Y(1) 0; 0 0 Jt_reg2Z(1)] * stick.CBAR.winr.R(:,:,1)';
            mass_reg2(1) = mass_reg1(1) / 2;
            for i = 2 : length(stick.PID.wing)
                mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
                Jt_reg2X(i) = (Jt_regX(i-1)+Jt_regX(i)) / 2;
                Jt_reg2Y(i) = (Jt_regY(i-1)+Jt_regY(i)) / 2;
                Jt_reg2Z(i) = (Jt_regZ(i-1)+Jt_regZ(i)) / 2;
                Iglobal(:,:,i) = (stick.CBAR.winr.R(:,:,i-1) * [ Jt_regX(i-1) 0 0; 0 Jt_regY(i-1) 0; 0 0 Jt_regZ(i-1)] * stick.CBAR.winr.R(:,:,i-1)' + ...
                    stick.CBAR.winr.R(:,:,i) * [ Jt_regX(i) 0 0; 0 Jt_regY(i) 0; 0 0 Jt_regZ(i)] * stick.CBAR.winr.R(:,:,i)') * 0.5;
            end
            mass_reg2(end) = mass_reg1(end) / 2;
            Jt_reg2X(end) = Jt_regX(end) / 2 ;
            Jt_reg2Y(end) = Jt_regY(end) / 2 ;
            Jt_reg2Z(end) = Jt_regZ(end) / 2 ;
            Iglobal(:,:,end) = stick.CBAR.winr.R(:,:,end)' * [ Jt_reg2X(end) 0 0; 0 Jt_reg2Y(end) 0; 0 0 Jt_reg2Z(end)] * stick.CBAR.winr.R(:,:,end);
            MTOTFU = sum(mass_reg2);
            if isequal(stick.model.symmXZ, 1)
                MTOTFU = 2*MTOTFU;
            end
            fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
            fprintf(fid, ['\n$ Lumped masses: WING TANK FUEL ',num2str(MTOTFU), ' Kg']);
            ind1 = find(mass_reg1);
            fprintf(fid, ['\n$ Wing beams: from ', num2str(ind1(1)), ' to ', num2str(ind1(end))]);
            fprintf(fid, ['\n$ Span fraction: from ', num2str(pdcylin.MassConf.WfuelStart*100), ' to ', num2str(pdcylin.MassConf.WfuelArrive*100),' %%']);
            fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
            %
            % CONM2 card
            %
            offset = zeros(3,1);
            for i = 1:length(stick.PID.wing)+1
                if mass_reg2(i) > 0.0
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fid, IDconm, stick.ID.winr(i), 0, mass_reg2(i), offset(1), offset(2), offset(3), Iglobal(1,1,i), Iglobal(2,1,i), Iglobal(2,2,i), Iglobal(3,1,i), Iglobal(3,2,i), Iglobal(3,3,i));
                end
            end
            % symmetry
            if isequal(stick.model.symmXZ, 1)
                for i = 1:length(stick.PID.wing)+1
                    if mass_reg2(i) > 0.0
                        IDconm = IDconm + 1;
                        BULKdataCONM2(fid, IDconm, stick.ID.winl(i), 0, mass_reg2(i), offset(1), -offset(2), offset(3), Iglobal(1,1,i), -Iglobal(2,1,i), Iglobal(2,2,i), Iglobal(3,1,i), -Iglobal(3,2,i), Iglobal(3,3,i));
                    end
                end
            end
        end
    end
end

%==========================================================================
% CENTRAL TANK FUEL
%==========================================================================
if aircraft.weight_balance.COG(19,4,1) > 0
    
    if isequal(pdcylin.stick.model.winr, 1)
        
        mass_reg1 = zeros(length(stick.PID.wing), 1);
        for i = 1:pdcylin.stick.nwing_carryth
            Lcth = sum(stick.wing.Lbeam(1:pdcylin.stick.nwing_carryth));
            mass_reg1(i) = (aircraft.weight_balance.COG(19,4,1)/2) * stick.wing.Lbeam(i) / Lcth;
        end
        Jt_regX = mass_reg1'./(stick.PBAR.wing.str_rec_coef.D(1,:).*stick.PBAR.wing.str_rec_coef.C(2,:)*4) .*...
            1/12 .* ( ( (stick.PBAR.wing.str_rec_coef.D(1,:)*2).^3 .* (stick.PBAR.wing.str_rec_coef.C(2,:)*2)) +...
            ((stick.PBAR.wing.str_rec_coef.C(2,:)*2).^3 .* (stick.PBAR.wing.str_rec_coef.D(1,:)*2))  );
        Jt_regY = 1/12 .* mass_reg1 .* stick.wing.Lbeam.^2;
        Jt_regZ = 1/12 .* mass_reg1 .* stick.wing.Lbeam.^2;
        % nodal mass
        mass_reg2 = zeros(length(stick.PID.wing)+1, 1);
        Jt_reg2X = mass_reg2;
        Iglobal = zeros(3,3,length(stick.PID.wing)+1);
        Jt_reg2X(1) = Jt_regX(1) / 2 ;
        Jt_reg2Y(1) = Jt_regY(1) / 2 ;
        Jt_reg2Z(1) = Jt_regZ(1) / 2 ;
        Iglobal(:,:,1) = stick.CBAR.winr.R(:,:,1) * [ Jt_reg2X(1) 0 0; 0 Jt_reg2Y(1) 0; 0 0 Jt_reg2Z(1)] * stick.CBAR.winr.R(:,:,1)';
        mass_reg2(1) = mass_reg1(1) / 2;
        for i = 2 : length(stick.PID.wing)
            mass_reg2(i) = (mass_reg1(i-1)+mass_reg1(i)) / 2;
            Jt_reg2X(i) = (Jt_regX(i-1)+Jt_regX(i)) / 2;
            Jt_reg2Y(i) = (Jt_regY(i-1)+Jt_regY(i)) / 2;
            Jt_reg2Z(i) = (Jt_regZ(i-1)+Jt_regZ(i)) / 2;
            Iglobal(:,:,i) = (stick.CBAR.winr.R(:,:,i-1) * [ Jt_regX(i-1) 0 0; 0 Jt_regY(i-1) 0; 0 0 Jt_regZ(i-1)] * stick.CBAR.winr.R(:,:,i-1)' + ...
                stick.CBAR.winr.R(:,:,i) * [ Jt_regX(i) 0 0; 0 Jt_regY(i) 0; 0 0 Jt_regZ(i)] * stick.CBAR.winr.R(:,:,i)') * 0.5;
        end
        mass_reg2(end) = mass_reg1(end) / 2;
        Jt_reg2X(end) = Jt_regX(end) / 2 ;
        Jt_reg2Y(end) = Jt_regY(end) / 2 ;
        Jt_reg2Z(end) = Jt_regZ(end) / 2 ;
        Iglobal(:,:,end) = stick.CBAR.winr.R(:,:,end)' * [ Jt_reg2X(end) 0 0; 0 Jt_reg2Y(end) 0; 0 0 Jt_reg2Z(end)] * stick.CBAR.winr.R(:,:,end);
        MTOTCFU = sum(mass_reg2);
        if isequal(stick.model.symmXZ, 1)
            MTOTCFU = 2*MTOTCFU;
        end
        fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fid, ['\n$ Lumped masses: CENTRAL TANK FUEL ',num2str(MTOTCFU), ' Kg']);
        ind1 = find(mass_reg1);
        fprintf(fid, ['\n$ Wing beams: from ', num2str(ind1(1)), ' to ', num2str(ind1(end))]);
        fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        %
        % CONM2 card
        %
        offset = zeros(3,1);
        for i = 1:length(stick.PID.wing)+1
            if mass_reg2(i) > 0.0
                IDconm = IDconm + 1;
                BULKdataCONM2(fid, IDconm, stick.ID.winr(i), 0, mass_reg2(i), offset(1), offset(2), offset(3), Iglobal(1,1,i), Iglobal(2,1,i), Iglobal(2,2,i), Iglobal(3,1,i), Iglobal(3,2,i), Iglobal(3,3,i));
            end
        end
        % symmetry
        if isequal(stick.model.symmXZ, 1)
            for i = 1:length(stick.PID.wing)+1
                if mass_reg2(i) > 0.0
                    IDconm = IDconm + 1;
                    BULKdataCONM2(fid, IDconm, stick.ID.winl(i), 0, mass_reg2(i), offset(1), -offset(2), offset(3), Iglobal(1,1,i), -Iglobal(2,1,i), Iglobal(2,2,i), Iglobal(3,1,i), -Iglobal(3,2,i), Iglobal(3,3,i));
                end
            end
        end
    end
end


%==========================================================================
% Add "dummy" masses, which correspond to row 13,14,15,16,26,28,30 of the
% COG matrix, if they are present. No symmetry flag available, but dummy
% masses can be attached on each aircraft component
%==========================================================================
dummy_masses_row     = [13, 14, 15, 16, 26, 28, 30];
dummy_masses_present = aircraft.weight_balance.COG(dummy_masses_row, 4, 1) ~= 0;

% Recover stick model node database, i.e. coordinates and IDs. Since two
% meshes are present, discard nodes under the field names "_thick", which
% are referred to the finer one (internal to GUESS)

% Field names
componentNamesNodeCoord = fieldnames(stick.nodes);
componentNamesNodeID    = fieldnames(stick.ID);

% Logical indices
IndexNodes = structfun(@(x)~isempty(x), stick.nodes) & cellfun(@(x)isempty(x), strfind(componentNamesNodeCoord, '_thick')) & cellfun(@(x)~isempty(x), strfind(componentNamesNodeCoord, 'C2'));
IndexID    = structfun(@(x)~isempty(x), stick.ID) & cellfun(@(x)isempty(x), strfind(componentNamesNodeID, '_thick'));

% Extract coordinates and IDs. Coordinates are re-arranged in [n x 3]
% matrix instead of [3 x n] as in the database
nodeCoord     = struct2cell(stick.nodes);
nodeID        = struct2cell(stick.ID);
% node_DB_Coord = cell2mat(nodeCoord(IndexNodes)');
node_DB_ID    = cell2mat(nodeID(IndexID));

node_DB_Coord = [stick.nodes.fuse stick.nodes.tboomsr stick.nodes.tboomsl stick.nodes.winrC2 stick.nodes.winlC2 stick.nodes.vert stick.nodes.vert2 stick.nodes.horrC2 stick.nodes.horlC2 stick.nodes.canrC2 stick.nodes.canlC2 stick.nodes.win2rC2 stick.nodes.win2lC2 stick.nodes.extrar stick.nodes.extral];

% Start GRID ID counter for dummy masses from 8000 (necessary for RBE2 attachment)
iddummy = 8000;

if any(dummy_masses_present) && EXPORT_OEW == 1
    
    % "Sampled" dummy masses vector
    dummy_masses_row_s = dummy_masses_row(dummy_masses_present);
    
    % Recover mass value
    MDUMMY = aircraft.weight_balance.COG(dummy_masses_row_s, 4, 1);
    
    for k = 1:numel(dummy_masses_row_s)
        
        % Actual mass index
        mindex = dummy_masses_row_s(k);
        
        % Update total mass
        str.M = str.M + MDUMMY(k);
        
        % Recover mass CG coordinates
        Xcg = aircraft.weight_balance.COG(mindex, 1, 1);
        Ycg = aircraft.weight_balance.COG(mindex, 2, 1);
        Zcg = aircraft.weight_balance.COG(mindex, 3, 1);
        
        % Update CONM2 card counter
        IDconm = IDconm + 1;
        
        % Second moments of inertia (set to 0)
        I11 = 0; I21 = 0; I22 = 0;
        I31 = 0; I32 = 0; I33 = 0;
        
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fidOEW, ['\n$ Lumped masses: DUMMY (row #', num2str(mindex), '),' num2str(MDUMMY(k)), ' Kg']);
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        
        % Find ID for the nearest node (search on the whole aircraft)
        IDextst = CONM2_setup(Xcg, Ycg, Zcg, node_DB_Coord, node_DB_ID);
        
        % Adding masses as RBE2+CONM2 proves to be prone to errors: it can
        % happen that a master node for the dummy mass is already a slave
        % for another RBE2, thus an error is issued. A safer method is
        % adding the dummy mass to the nearest node and to apply an offset-
        % However all the cards related to RBE2+CONM2 are inserted as
        % comments for later use, i.e. substituting the rigid link with a
        % BARin order to have enginle pylon (an additional warning will be
        % written in the *.inc file)
        
        % Preliminary check: to avoid errors check if the new master nodes
        % is a slave of another RBE2
        if any(ismember([stick.link.RBE2.slave], IDextst))
            % Write a warning into *.inc file
            fprintf(fidOEW, '$ [WARNING] Node %d can''t be a master, since it''s a slave of another RBE2\n', IDextst);
            fprintf(fidOEW, '\n$ Uncommenting cards below will produce an error in NeoCASS,\n$ but RBE2 can be substituted with a BAR element\n');
        else
            fprintf(fidOEW, '$ Uncomment cards below to substitute mass offset with RBE2 link. \n$ Remember to comment CONM2 card with offset\n');
        end
        
        % Icrement RBE2 counter
        nrbe = length(stick.link.Ma) + 1;
        
        % Set master, dof and slave for the RBE2
        stick.link.Ma(nrbe)         = IDextst;
        stick.link.RBE2(nrbe).DOF   = 123456;
        stick.link.RBE2(nrbe).slave = iddummy;
        
        % Add node ID and coordinates in GUESS database (stick)
        ner = length(stick.ID.extrar) + 1;
        stick.ID.extrar(ner)      = iddummy;
        stick.nodes.extrar(1,ner) = Xcg;
        stick.nodes.extrar(2,ner) = Ycg;
        stick.nodes.extrar(3,ner) = Zcg;
        
        % Add external store node
        BULKdataGRID(fidOEW, stick.ID.extrar(ner), 0, Xcg, Ycg, Zcg, 0, 0, 0, true);
        
        % Add RBE2 link
        BULKdataRB2(fidOEW, nrbe, stick.link.Ma(nrbe), stick.link.RBE2(nrbe).DOF, stick.link.RBE2(nrbe).slave, true);
        
        % Add CONM2 concentrated mass
        BULKdataCONM2(fidOEW, IDconm, iddummy, 0, MDUMMY(k), 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33, true);
        
        % Increment node ID for the next dummy mass
        iddummy = iddummy + 1;
        
        % Add new mass as a CONM2 with an offset
        fprintf(outf, 'DUMMY mass as a CONM2 with offset');
        
        % Add CONM2 concentrated mass (when CID = -1, offset components are
        % treated as coordinates in the global frame)
        BULKdataCONM2(fidOEW, IDconm, IDextst, -1, MDUMMY(k), Xcg, Ycg, Zcg, I11, I21, I22, I31, I32, I33);
        
    end
    
end

%Repeat the same process of dummy masses for additional masses taken from
%AM matrix
if isfield(aircraft,'AM') && ~isempty(aircraft.AM) && EXPORT_OEW == 1
    
    AMnodes.coord.fuse = stick.nodes.fuse;
    AMnodes.ID.fuse = stick.ID.fuse;
    AMnodes.coord.wing = [stick.nodes.winrC2 stick.nodes.winlC2];
    AMnodes.ID.wing = [stick.ID.winr stick.ID.winl];
    AMnodes.coord.tailbooms = [stick.nodes.tboomsr stick.nodes.tboomsl];
    AMnodes.ID.tailbooms = [stick.ID.tboomsr stick.ID.tboomsl];
    AMnodes.coord.vertical = [stick.nodes.vert stick.nodes.vert2];
    AMnodes.ID.vertical = [stick.ID.vert stick.ID.vert2];
    AMnodes.coord.horizontal = [stick.nodes.horrC2 stick.nodes.horlC2];
    AMnodes.ID.horizontal = [stick.ID.horr stick.ID.horl];
    AMnodes.coord.canard = [stick.nodes.canrC2 stick.nodes.canlC2];
    AMnodes.ID.canard = [stick.ID.canr stick.ID.canl];
    
    Names = {'fuse' 'wing' 'horizontal' 'vertical' 'canard' 'tailbooms'};

    AM = aircraft.AM;
    for k = 1:size(AM,1)
        
        % Update total mass
        str.M = str.M + AM(k,4);
        
        % Recover mass CG coordinates
        Xcg = AM(k, 1);
        Ycg = AM(k, 2);
        Zcg = AM(k, 3);
        
        % Update CONM2 card counter
        IDconm = IDconm + 1;
        
        % Second moments of inertia (set to 0)
        I11 = 0; I21 = 0; I22 = 0;
        I31 = 0; I32 = 0; I33 = 0;
        
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
        fprintf(fidOEW, ['\n$ Lumped masses: ADDITIONAL MASSES (row #', num2str(k), '),' num2str(AM(k,4)), ' Kg']);
        fprintf(fidOEW, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
        
        % Find ID for the nearest node (search on the whole aircraft)
        IDextst = CONM2_setup(Xcg, Ycg, Zcg, AMnodes.coord.(Names{int8(AM(k,5))}), AMnodes.ID.(Names{int8(AM(k,5))}));
        
        % Adding masses as RBE2+CONM2 proves to be prone to errors: it can
        % happen that a master node for the dummy mass is already a slave
        % for another RBE2, thus an error is issued. A safer method is
        % adding the dummy mass to the nearest node and to apply an offset-
        % However all the cards related to RBE2+CONM2 are inserted as
        % comments for later use, i.e. substituting the rigid link with a
        % BARin order to have enginle pylon (an additional warning will be
        % written in the *.inc file)
        
        % Preliminary check: to avoid errors check if the new master nodes
        % is a slave of another RBE2
        if any(ismember([stick.link.RBE2.slave], IDextst))
            % Write a warning into *.inc file
            fprintf(fidOEW, '$ [WARNING] Node %d can''t be a master, since it''s a slave of another RBE2\n', IDextst);
            fprintf(fidOEW, '\n$ Uncommenting cards below will produce an error in NeoCASS,\n$ but RBE2 can be substituted with a BAR element\n');
        else
            fprintf(fidOEW, '$ Uncomment cards below to substitute mass offset with RBE2 link. \n$ Remember to comment CONM2 card with offset\n');
        end
        
        % Icrement RBE2 counter
        nrbe = length(stick.link.Ma) + 1;
        
        % Set master, dof and slave for the RBE2
        stick.link.Ma(nrbe)         = IDextst;
        stick.link.RBE2(nrbe).DOF   = 123456;
        stick.link.RBE2(nrbe).slave = iddummy;
        
        % Add node ID and coordinates in GUESS database (stick)
        ner = length(stick.ID.extrar) + 1;
        stick.ID.extrar(ner)      = iddummy;
        stick.nodes.extrar(1,ner) = Xcg;
        stick.nodes.extrar(2,ner) = Ycg;
        stick.nodes.extrar(3,ner) = Zcg;
        
        % Add external store node
        BULKdataGRID(fidOEW, stick.ID.extrar(ner), 0, Xcg, Ycg, Zcg, 0, 0, 0, true);
        
        % Add RBE2 link
        BULKdataRB2(fidOEW, nrbe, stick.link.Ma(nrbe), stick.link.RBE2(nrbe).DOF, stick.link.RBE2(nrbe).slave, true);
        
        % Add CONM2 concentrated mass
        BULKdataCONM2(fidOEW, IDconm, iddummy, 0, AM(k,4), 0.0, 0.0, 0.0, I11, I21, I22, I31, I32, I33, true);
        
        % Increment node ID for the next dummy mass
        iddummy = iddummy + 1;
        
        % Add new mass as a CONM2 with an offset
        fprintf(outf, 'DUMMY mass as a CONM2 with offset');
        
        % Add CONM2 concentrated mass (when CID = -1, offset components are
        % treated as coordinates in the global frame)
        BULKdataCONM2(fidOEW, IDconm, IDextst, -1, AM(k,4), Xcg, Ycg, Zcg, I11, I21, I22, I31, I32, I33);
        
    end
    
end

%
%==========================================================================

%==========================================================================
% Print summary on file
%==========================================================================
%
if EXPORT_REG
    
    fprintf(fidOEW,  '\n$ Summary of secondary structural masses (as CONM2): ');
    fprintf(fidOEW, ['\n$ Fuselage: ', num2str(MTOTF)]);
    fprintf(fidOEW, ['\n$ Wing: ', num2str(MTOTW)]);
    fprintf(fidOEW, ['\n$ Canard: ', num2str(MTOTC)]);
    fprintf(fidOEW, ['\n$ Htail: ', num2str(MTOTH)]);
    fprintf(fidOEW, ['\n$ Vtail: ', num2str(MTOTV)]);
    fprintf(outf, ['\n\t\t- fuselage sec. structure: ', num2str(MTOTF),' kg.']);
    fprintf(outf, ['\n\t\t- wing sec. structure: ', num2str(MTOTW),' kg.']);
    fprintf(outf, ['\n\t\t- canard sec. structure: ', num2str(MTOTC),' kg.']);
    fprintf(outf, ['\n\t\t- htail sec. structure: ', num2str(MTOTH),' kg.']);
    fprintf(outf, ['\n\t\t- vtail sec. structure: ', num2str(MTOTV),' kg.']);
    
end

if EXPORT_OEW
    
    fprintf(fidOEW,  '\n$ Summary of secondary masses (as CONM2): ');
    fprintf(fidOEW, ['\n$ Engines: ', num2str(MTOTE)]);
    fprintf(fidOEW, ['\n$ Engines2: ', num2str(MTOTE2)]);
    fprintf(fidOEW, ['\n$ Nose landing gear: ', num2str(MNLG)]);
    fprintf(fidOEW, ['\n$ Main landing gear: ', num2str(MTOTLG)]);
    fprintf(outf, ['\n\t\t- engines: ', num2str(MTOTE),' kg.']);
    fprintf(outf, ['\n\t\t- engines2: ', num2str(MTOTE2),' kg.']);
    
    % Dummy masses: print to video and into *.inc file
    if any(dummy_masses_present)
        for k = 1:numel(dummy_masses_row_s)
            fprintf(outf,   ['\n\t\t- Dummy mass (row #', num2str(dummy_masses_row_s(k)) ,'): ', num2str(MDUMMY(k)),' kg.']);
            fprintf(fidOEW, ['\n$ Dummy mass (row #', num2str(dummy_masses_row_s(k)) ,'): ', num2str(MDUMMY(k)),' kg.']);
        end
    end
    
    if isfield(aircraft,'AM') && ~isempty(aircraft.AM)
        for k = 1:size(AM,1)
            fprintf(outf,   ['\n\t\t- Additional mass (row #', num2str(k) ,'): ', num2str(AM(k,4)),' kg.']);
            fprintf(fidOEW, ['\n$ Additional mass (row #', num2str(k) ,'): ', num2str(AM(k,4)),' kg.']);
        end
    end
    
end

fprintf(fid,  '\n$ Summary of payload (as CONM2): ');
fprintf(fid, ['\n$ Wing tank: ', num2str(MTOTFU)]);
fprintf(fid, ['\n$ Central tank: ', num2str(MTOTCFU)]);
fprintf(fid, ['\n$ Auxiliary tank: ', num2str(MTOTAUX)]);
fprintf(fid, ['\n$ Passengers: ', num2str(MTOTPAX)]);
fprintf(fid, ['\n$ Baggage: ', num2str(MTOTBG)]);
fprintf(fid, '\n$-------2-------3-------4-------5-------6-------7-------8-------9-------10');
%
fprintf(outf, ['\n\t\t- wing tank: ', num2str(MTOTFU),' kg.']);
fprintf(outf, ['\n\t\t- central tank: ', num2str(MTOTCFU),' kg.']);
fprintf(outf, ['\n\t\t- auxiliary tank: ', num2str(MTOTAUX),' kg.']);
fprintf(outf, ['\n\t\t- passengers: ', num2str(MTOTPAX),' kg.']);
fprintf(outf, ['\n\t\t- baggage: ', num2str(MTOTBG),' kg.']);
%
fprintf(outf, '\n\tdone.');
