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

function [LB,LW,LF,LT,LE1,LE2,IXI,IYI,IZI,IXZI,WB,WW,WF,WTP,WE,WFUEL,WP,LFUEL] ...
         = scindat(n, IXXINER, IYYINER, IZZINER, IXZINER, ...
                   deg2rad, FuseLength, TailLength, FuseVerticalDiameterAft, NoseLength, FuseHorizontalDiameterAft,...
                   MaxRampWeight, WingWeight, VTailWeight, HTailWeight, PylonWeight, GearboxWeight,...
                   NacelleWeight, MaxFuelWeight, PLOTCGS,...
                   SpanMatrixPartition, WingSpan, RefWingLESweep, WingPlacement, ReferenceWingArea2, RefWingTaper, RefWingThickness, WingDihedral,...
                   RefWingApex, EngineYLocale, NacelleLength, EngineMaxDiameter,...
                   VTailApex, VTailSpan, RefVTailLESweep, VTailVerticalLocale, RefVTailArea, RefVTailTaper, RefVTailThickness, VTailSpanMatrixPartition,...
                   HTailLESweep, HTailApex, HTailVerticalLocale, HTailSpan, RefHTailLESweep, RefHTailArea, RefHTailTaper, HTailSpanMatrixPartition, FromMFWtoMTOW)
               
if (HTailLESweep+HTailApex+HTailVerticalLocale+HTailSpan+RefHTailLESweep+RefHTailArea+RefHTailTaper+HTailSpanMatrixPartition) > 0
    HtailPresent = true;
else
    HtailPresent = false;
end

if (VTailApex+VTailSpan+RefVTailLESweep+VTailVerticalLocale+RefVTailArea+RefVTailTaper+RefVTailThickness+VTailSpanMatrixPartition) > 0
    VtailPresent = true;
else
    VtailPresent = false;
end

if (EngineMaxDiameter + NacelleLength + EngineYLocale + NacelleWeight + GearboxWeight + PylonWeight) > 0
    EnginesPresent = true;
else
    EnginesPresent = false;
end
               
if n < 1
      error('scindat:no_aircraft', 'At least one airplane must be selected!!');
else   
    
    %======================================================================
    % Copied here from qgeotry.m: needed for REFHAPX, REFVCAP, REFVCRC
    % definitions.
    if VtailPresent
        % locate reference vertical tail down to the fuselage reference plane
        REFVCAP(n) = (VTailApex(n)*FuseLength(n)- ...
            FuseVerticalDiameterAft(n)*abs(VTailVerticalLocale(n))*tan(deg2rad*RefVTailLESweep(n)))/FuseLength(n);
        % reference vertical tail root chord at fuselage reference plane
        REFVCRC(n) = Wing_Chord_At_Span(-FuseVerticalDiameterAft(n)*abs(VTailVerticalLocale(n)),VTailSpanMatrixPartition, ...
            2*RefVTailArea(n)/(VTailSpan(n)*(1+RefVTailTaper(n))),RefVTailTaper,n);
    end
    if HtailPresent
        % compute the moment arm to h-tail 0.25MAC and the volume coefficient
        xibad = HTailSpanMatrixPartition(1)*tan(deg2rad*HTailLESweep(1,n));% inboard sweep adjustment
        xmbad = HTailSpanMatrixPartition(2)*tan(deg2rad*HTailLESweep(2,n));% midboard sweep adjustment
        xobad = HTailSpanMatrixPartition(3)*tan(deg2rad*HTailLESweep(3,n));% outboard sweep adjustment
        % locate the reference horizontal tail relative apex
        REFHAPX(n) = (HTailApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
            0.5*HTailSpan(n)*tan(deg2rad*RefHTailLESweep(n)))/FuseLength(n);
    end
    %======================================================================
    
    % central fuselage body length aft of reference wing apex
    LB(1) = FuseLength(n)*(1-RefWingApex(n))-TailLength(n);
    % central fuselage body length forward of reference wing apex        
    LB(2) = FuseLength(n)*RefWingApex(n)-NoseLength(n);
    % fuselage body length aft of reference wing apex         
    LB(3) = FuseLength(n)*(1-RefWingApex(n));
    % fuselage body length forward of reference wing apex         
    LB(4) = FuseLength(n)*RefWingApex(n);
    LB(5) = FuseHorizontalDiameterAft(n);       % fuselage cross-section horizontal diameter
    LB(6) = FuseVerticalDiameterAft(n);       % fuselage cross-section vertical diameter
    % reference wing apex height from fuselage reference plane
    LB(7) = FuseVerticalDiameterAft(n)*abs(0.5-WingPlacement(n));
    LB(8) = 0.0;              % main landing gear distance aft of reference wing apex         
    LB(9) = 0.0;              % body incidence on ground
    % reference wing root chord
    LW(1) = 2*ReferenceWingArea2(n)/( WingSpan(n)*(1 + RefWingTaper(n)) );
    LW(2) = LW(1)*RefWingTaper(n); % reference wing tip chord
    LW(3) = RefWingLESweep(n);       % reference wing leading edge sweep
    LW(4) = WingSpan(n)/2;     % reference wing semi-span
    LW(5) = RefWingThickness(n);       % reference wing mean t/c 
    LW(6) = 0.0;              % reference wing incidence angle
    % reference wing dihedral angle
    LW(7) = atan(2*(SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n))+ ...
                    SpanMatrixPartition(2)*tan(deg2rad*WingDihedral(2,n))+ ...
                    SpanMatrixPartition(3)*tan(deg2rad*WingDihedral(3,n)))/WingSpan(n))/deg2rad; 
    LW(8) = 0.3*LW(1);        % aileron hinge line extended to reference wing root chord
    LW(9) = 0.3*LW(2);        % aileron hinge line extended to reference wing tip chord
    LW(10) = 0.69*LW(4);      % semi-span to inboard aileron
    LW(11) = 0.98*LW(4);      % semi-span to outboard aileron
    if VtailPresent
        % length from reference wing apex to reference vertical tail root chord at FRP
        LF(1) = FuseLength(n)*(REFVCAP(n)-RefWingApex(n));
        LF(2) = REFVCRC(n);       % reference vertical tail root chord at FRP
        LF(3) = 2*RefVTailArea(n)/(VTailSpan(n)*(1+ ...
            RefVTailTaper(n)))*RefVTailTaper(n);    % ref. vertical tail tip chord
        LF(4) = RefVTailLESweep(n);       % reference vertical tail leading edge sweep
        % reference vertical tail span extended down to fuselage reference plane
        LF(5) = VTailSpan(n)+FuseVerticalDiameterAft(n)*abs(VTailVerticalLocale(n));
        % reference horizontal tail height from fuselage reference plane
        LF(6) = FuseVerticalDiameterAft(n)*abs(HTailVerticalLocale(n));
        LF(7) = RefVTailThickness(n);       % reference vertical tail mean t/c
        % approximate fuselage top height at reference vertical tail Q.chd
        LF(8) = FuseVerticalDiameterAft(n)*abs(VTailVerticalLocale(n));
        LF(9) = 0.0;              % rudder hinge line extended to reference vertical root chord
        LF(10) = 0.0;             % rudder hinge line extended to reference vertical tip chord
        LF(11) = 0.0;             % height to lower rudder
        LF(12) = 0.0;             % height to upper rudder
    else
        LF(1:12) = zeros(1,12);
    end
    if HtailPresent
        % length from reference wing apex to reference horizontal tail apex
        LT(1) = FuseLength(n)*(REFHAPX(n)-RefWingApex(n));
        % reference horizontal tail root chord
        LT(2) = 2*RefHTailArea(n)/(HTailSpan(n)*(1+RefHTailTaper(n)));
        LT(3) = 2*LT(2)*RefHTailTaper(n); % reference horizontal tail tip chord
        LT(4) = RefHTailLESweep(n);         % reference horizontal tail leading edge sweep
        LT(5) = HTailSpan(n)/2;       % reference horizontal tail semi-span
    else
        LT(1:5) = zeros(1,5);
    end
    
    if EnginesPresent
    % the LE1s
    LE1(1) = EngineYLocale(1,n)*WingSpan(n)/2;  %fuse CL-primary powerplant 
    LE1(2) = 0.0;             % wing apex-primary engine c.g. (plan)
    LE1(3) = 0.0;             % fuse CL-primary engine c.g.(side)
    LE1(4) = 0.0;             % thrust parameter
    LE1(5) = 0.0;             % thrust parameter
    LE1(6) = 0.0;             % thrust parameter
    LE1(7) = NacelleLength(1,n);    % primary nacelle length
    LE1(8) = EngineMaxDiameter(1,n);    % primary nacelle maximum diameter
    % the LE2s
    LE2(1) = EngineYLocale(2,n)*WingSpan(n)/2;   %fuse CL-secondary powerplant 
    LE2(2) = 0.0;             % wing apex-secondary engine c.g. (plan)
    LE2(3) = 0.0;             % fuse CL-secondary engine c.g.(side)
    LE2(4) = 0.0;             % thrust parameter
    LE2(5) = 0.0;             % thrust parameter
    LE2(6) = 0.0;             % thrust parameter
    LE2(7) = NacelleLength(2,n);    % secondary nacelle length
    LE2(8) = EngineMaxDiameter(2,n);    % secondary nacelle maximum diameter
    else
        LE1 = zeros(1,8);
        LE2 = zeros(1,8);
    end
    
%     factor = 1E3;
    factor = 1;
    
    IXI = IXXINER(n)*factor;
    IYI = IYYINER(n)*factor;
    IZI = IZZINER(n)*factor;
    IXZI = IXZINER(n)*factor;
    
    WW = WingWeight(n);
    WF = VTailWeight(n);
    WTP = HTailWeight(n);
    WE = PylonWeight(n) + GearboxWeight(n) + NacelleWeight(n);
    WFUEL = MaxFuelWeight(n);    
    WP = FromMFWtoMTOW(n);

    % Fuel CG from nose apex
    if sum(PLOTCGS(18:20, 4, n))~=0
        CGF_N = sum(PLOTCGS(18:20, 1, n).*PLOTCGS(18:20, 4, n))/sum(PLOTCGS(18:20, 4, n));
    else
        CGF_N = 0;
    end
    if ~isnan(CGF_N)
        % length to fuel tank cg from datum
        LFUEL = CGF_N - RefWingApex(n)*FuseLength(n);
    else
        LFUEL = RefWingApex(n)*FuseLength(n);
    end
    
    % equate the body weight as residual after deducting the above constituents
    WB = MaxRampWeight(n) - WW - WF - WTP - WE - WFUEL - WP;
    
end