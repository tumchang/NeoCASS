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
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Luca Riccobene       <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%**************************************************************************
%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     080101      2.0     L.Riccobene      Creation
%
%**************************************************************************
%
% function       Script called by weight_xml main function
%
%
%   DESCRIPTION:  Execute the balance and inertia prediction routines
%
%         INPUT: NAME           TYPE       DESCRIPTION
%                  
%                                       
%        OUTPUT: NAME           TYPE       DESCRIPTION
%                
%         
%                
%    REFERENCES:
%
%**************************************************************************


if CALCOGX(n) < 0.0001

    CALCOGX(n) = CMPCOGX(n);  % default cg is max payload at MTOW

end

if CALCOGZ(n) < 0.0001

    CALCOGZ(n) = CMPCOGZ(n);  % default cg is max payload at MTOW

end

fprintf('\n\tInertia estimation [Kgm^2]\n');

% check if the user requests a prediction for inertias
if IXXINER(n) < 0.0001 && IYYINER(n) < 0.0001 && IZZINER(n) < 0.0001 && IXZINER(n) < 0.0001

    % Modified scindat function
    [LB,LW,LF,LT,LE1,LE2,IXI,IYI,IZI,IXZI,WB,WW,WF,WTP,WE,WFUEL,WP,LFUEL] ...
        = scindat(n, IXXINER, IYYINER, IZZINER, IXZINER, ...
        deg2rad, FuseLength, TailLength, FuseVerticalDiameterAft, NoseLength, FuseHorizontalDiameterAft,...
        MaxRampWeight, WingWeight, VTailWeight, HTailWeight, PylonWeight, GearboxWeight,...
        NacelleWeight, MaxFuelWeight, PLOTCGS,...
        SpanMatrixPartition, WingSpan, RefWingLESweep, WingPlacement, ReferenceWingArea2, RefWingTaper, RefWingThickness, WingDihedral,...
        RefWingApex, EngineYLocale, NacelleLength, EngineMaxDiameter,...
        VTailApex, VTailSpan, RefVTailLESweep, VTailVerticalLocale, RefVTailArea, RefVTailTaper, RefVTailThickness, VTailSpanMatrixPartition,...
        HTailLESweep, HTailApex, HTailVerticalLocale, HTailSpan, RefHTailLESweep, RefHTailArea, RefHTailTaper, HTailSpanMatrixPartition, FromMFWtoMTOW);

    LCG = MACSpanPos(n)*WingSpan(n)/2*tan(deg2rad*RefWingLESweep(n)) + ...
        CALCOGX(n)/100*RefWingMAC(n);      % length to longitudinal cg from datum

    HCG = CALCOGZ(n)/100*FuseVerticalDiameterAft(n);    % length to vertical cg from datum


    %     if CONSELN ~= 39

    WGT = MTOW(n); % run inertia computation for MTOW

    %     else
    %
    %         IXXINER(n) = 1;
    %         IYYINER(n) = 1;
    %         IZZINER(n) = 1;
    %         IXZINER(n) = 1;
    %         WGT = STACAUW(n);   % assume the AUW selected in S&C routine
    %
    %     end

    % access the Mitchell inertia computation routine - can conduct either a
    % parametric (statistical) based method or approach it analytically (this is
    % invoked by arbitrarily setting wing weight to zero)

    if IXXINER(n) == -1 || IYYINER(n) == -1 || IZZINER(n) == -1 || IXZINER(n) == -1

        %         [IX, IY, IZ, IXZ] = scinert(LB, LW, LF, LT, LE1, LE2, VTailMomentArm(n), ...
        %             HTailMomentArm(n), WB, WW, WF, WTP, WE, WFUEL, WP, ...
        %             LCG, HCG, IXI, IYI, IZI, IXZI, 0, WGT, LFUEL);
        %

        fprintf('\n\tRefined inertia estimate:\n');
        
        if AMflag
            AMmass = sum(AM(:,4));
            AMxcg = sum(AM(:,1).*AM(:,4))/AMmass;
            AMycg = sum(AM(:,2).*AM(:,4))/AMmass;
            AMzcg = sum(AM(:,3).*AM(:,4))/AMmass;
            %Put temporarly addidtional masses to field 30 of the COG to
            %estimate inertia
            originalRow = PLOTCGS(30,:,1);
            PLOTCGS(30,4,1) = originalRow(4) + AMmass;
            PLOTCGS(30,1,1) = (originalRow(1)*originalRow(4) + AMxcg*AMmass)/(originalRow(4)+AMmass);
            PLOTCGS(30,2,1) = (originalRow(2)*originalRow(4) + AMycg*AMmass)/(originalRow(4)+AMmass);
            PLOTCGS(30,3,1) = (originalRow(3)*originalRow(4) + AMzcg*AMmass)/(originalRow(4)+AMmass);    
        end
         
        Imat = refined_inertia_calc(PLOTCGS, EnginesNumber);
        
        if AMflag
            %restore original values
            PLOTCGS(30,:,1) = originalRow;
        end

    else

        % Coarse approximation (always referred to CoG)

        fprintf('\n\tCoarse approximation (w.r.t. CoG):\n');
        
        if AMflag
            %correct mtow to avoid taking additional masses twice
            WGT = WGT - sum(AM(:,4));
        end

        [IX, IY, IZ, IXZ] = scinert(LB, LW, LF, LT, LE1, LE2, VTailMomentArm(n), ...
            HTailMomentArm(n), WB, 0, WF, WTP, WE, WFUEL, WP, ...
            LCG, HCG, IXI, IYI, IZI, IXZI, 0, WGT, LFUEL);
        
        if AMflag
            %correct inertias with additional masses
            AMmass = sum(AM(:,4));
            AMxcg = sum(AM(:,1).*AM(:,4))/AMmass;
            AMycg = sum(AM(:,2).*AM(:,4))/AMmass;
            AMzcg = sum(AM(:,3).*AM(:,4))/AMmass;
            
            Dx = AMxcg - PLOTCGS(27,1,1);
            Dy = AMycg - PLOTCGS(27,2,1);
            Dz = AMzcg - PLOTCGS(27,3,1);
            
            IX = IX + AMmass * (Dy^2 + Dz^2);
            IY = IY + AMmass * (Dz^2 + Dx^2);
            IZ = IZ + AMmass * (Dx^2 + Dy^2);
        end

        Imat = [IX,   0, IXZ;...
            0,  IY,   0;...
            IXZ,   0,  IZ];
       


    end

    % Store single values
    IXXINER(n) = Imat(1, 1);
    IYYINER(n) = Imat(2, 2);
    IZZINER(n) = Imat(3, 3);
    IXZINER(n) = Imat(1, 3);
    IYZINER(n) = Imat(2, 3);
    IXYINER(n) = Imat(1, 2);


else

    fprintf('\tUsing user defined inertias.\n');

    Imat = [IXXINER,       0, IXZINER;...
        0, IYYINER,       0;...
        IXZINER,       0, IZZINER];

end

fprintf('\tIxx = %12.8g\n\tIyy = %12.8g\n\tIzz = %12.8g\n\tIxy = %12.8g\n\tIyz = %12.8g\n\tIxz = %12.8g\n',...
    IXXINER, IYYINER, IZZINER, IXYINER, IYZINER, IXZINER);
fprintf('\tdone.\n');