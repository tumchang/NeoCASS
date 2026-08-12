function aircraft = qfucalc_mod (aircraft)

n = 1;
deg2rad = 2*pi/360;  % conversion from deg. to rad.

% Fuselage
FuseLength(1,n) = aircraft.Fuselage.Total_fuselage_length;
FuseVerticalDiameterAft(1, n) = aircraft.Fuselage.Aftfuse_X_sect_vertical_diameter;
FuseHorizontalDiameterAft(1, n) = aircraft.Fuselage.Aftfuse_X_sect_horizontal_diameter;
FuseDistortionAft(1, n) = aircraft.Fuselage.Aftfuse_Xs_distortion_coefficient; 
FuseTailLength(1,n) = aircraft.Fuselage.Tail_length;

FuseParamAft(1) = aircraft.Fuselage.a0_aft;
FuseParamAft(3) = aircraft.Fuselage.a1_aft;
FuseParamAft(2) = aircraft.Fuselage.b1_aft;

% Wing 1
RefWingChordOrigin(1,n) = aircraft.Reference_wing.Orig_root_chrd_at_ac_CL;
FuseWingPosition(1,n) = aircraft.Fuselage.X_sect_chord_at_fuse_wing;
SpanMatrixPartition = aircraft.Wing1.Span_matrix_partition_in_mid_outboard;
WingThickMatrix = aircraft.Wing1.thickness_coefs_matrix;
OriginalFuseWingChord(1,n) = aircraft.Wing1.Original_estimated_fuse_wing_chrd;
ReferenceWingConvention(1,n) = aircraft.Reference_wing.convention;
WingSpan(1,n) = aircraft.Wing1.Span;
WingKink(1,n) = aircraft.Wing1.spanwise_kink1;
WingKink(2,n) = aircraft.Wing1.spanwise_kink2;
WingTaper(1,n) = aircraft.Wing1.taper_kink1;
WingTaper(2,n) = aircraft.Wing1.taper_kink2;
WingTaper(3,n) = aircraft.Wing1.taper_tip;
WingPlacement(1,n) = aircraft.Wing1.placement;
WingDihedral(1,n) = aircraft.Wing1.dihedral_inboard;
WingDihedral(2,n) = aircraft.Wing1.dihedral_midboard;
WingDihedral(3,n) = aircraft.Wing1.dihedral_outboard;
WingThickness(1,n) = aircraft.Wing1.thickness_root;
WingThickness(2,n) = aircraft.Wing1.thickness_kink1;
WingThickness(3,n) = aircraft.Wing1.thickness_kink2;
WingThickness(4,n) = aircraft.Wing1.thickness_tip;
WingApex(1,n) = aircraft.Wing1.apex_locale;
WingArea(1,n) = aircraft.Wing1.area;
WingAR(1,n) = aircraft.Wing1.AR;
WingIncidence(1,n) = aircraft.Wing1.root_incidence;
WingIncidence(2,n) = aircraft.Wing1.kink1_incidence;
WingIncidence(3,n) = aircraft.Wing1.kink2_incidence;
WingIncidence(4,n) = aircraft.Wing1.tip_incidence;
WingQCSweep(1,n) = aircraft.Wing1.quarter_chord_sweep_inboard;
WingQCSweep(2,n) = aircraft.Wing1.quarter_chord_sweep_midboard;
WingQCSweep(3,n) = aircraft.Wing1.quarter_chord_sweep_outboard;
WingLESweep(1,n) = aircraft.Wing1.LE_sweep_inboard;
WingLESweep(2,n) = aircraft.Wing1.LE_sweep_midboard;
WingLESweep(3,n) = aircraft.Wing1.LE_sweep_outboard;

% Wing thickness
[kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
    netwgae,wsatref,wsarref,wsasref,wsarlsw,wsarqsw,wsarhsw,wsarmac,wsarybr, ...
    wsarthb,inc] = qxemcop(WingKink, WingTaper, WingSpan, WingArea, WingAR, ...
    FuseHorizontalDiameterAft, WingThickness, WingQCSweep, WingLESweep, ReferenceWingConvention, WingPlacement, WingIncidence, n);
WTHKROT(n) = troot;

% Wing 2
%wi2gare(1,n) = aircraft.Wing2.area;
wi2present(1,n) = aircraft.Wing2.present;
if wi2present(1, n)
%if wi2gare(1,n) > 0.0001

    WS2NMTX = aircraft.Wing2.Span_matrix_partition_in_mid_outboard;
    WT2KMTX = aircraft.Wing2.thickness_coefs_matrix;
    wi2gspn(1,n) = aircraft.Wing2.Span;
    wi2glsw(1,n) = aircraft.Wing2.LE_sweep_inboard;
    wi2glsw(2,n) = aircraft.Wing2.LE_sweep_midboard;
    wi2glsw(3,n) = aircraft.Wing2.LE_sweep_outboard;
    wi2gplc(1,n) = aircraft.Wing2.placement;
    wi2gapx(1,n) = aircraft.Wing2.apex_locale;
    wi2gplc(1,n) = aircraft.Wing2.placement;
    wi2gare(1,n) = aircraft.Wing2.area;
    wi2ggar(1,n) = aircraft.Wing2.AR;
    wi2gspn(1,n) = aircraft.Wing2.Span;
    wi2gkln(1,n) = aircraft.Wing2.spanwise_kink1;
    wi2gkln(2,n) = aircraft.Wing2.spanwise_kink2;
    wi2gtap(1,n) = aircraft.Wing2.taper_kink1;
    wi2gtap(2,n) = aircraft.Wing2.taper_kink2;
    wi2gtap(3,n) = aircraft.Wing2.taper_tip;
    wi2ginc(1,n) = aircraft.Wing2.root_incidence;
    wi2ginc(2,n) = aircraft.Wing2.kink1_incidence;
    wi2ginc(3,n) = aircraft.Wing2.kink2_incidence;
    wi2ginc(4,n) = aircraft.Wing2.tip_incidence;
    wi2gqsw(1,n) = aircraft.Wing2.quarter_chord_sweep_inboard;
    wi2gqsw(2,n) = aircraft.Wing2.quarter_chord_sweep_midboard;
    wi2gqsw(3,n) = aircraft.Wing2.quarter_chord_sweep_outboard;
    wi2glsw(1,n) = aircraft.Wing2.LE_sweep_inboard;
    wi2glsw(2,n) = aircraft.Wing2.LE_sweep_midboard;
    wi2glsw(3,n) = aircraft.Wing2.LE_sweep_outboard;
    wi2gdih(1,n) = aircraft.Wing2.dihedral_inboard;
    wi2gdih(2,n) = aircraft.Wing2.dihedral_midboard;
    wi2gdih(3,n) = aircraft.Wing2.dihedral_outboard;
    wi2gthk(1,n) = aircraft.Wing2.thickness_root;
    wi2gthk(2,n) = aircraft.Wing2.thickness_kink1;
    wi2gthk(3,n) = aircraft.Wing2.thickness_kink2;
    wi2gthk(4,n) = aircraft.Wing2.thickness_tip;

    [kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
        netwgae,wsatref,wsarref2,wsasref2,wsarlsw,wsarqsw2,wsarhsw,wsarmac,wsarybr, ...
        wsarthb2,inc] = qxemcop(wi2gkln, wi2gtap, wi2gspn, wi2gare, wi2ggar, ...
        FuseHorizontalDiameterAft, wi2gthk, wi2gqsw, wi2glsw, ReferenceWingConvention, wi2gplc, wi2ginc, n);

    WC2DROT(n) = crot;
    XS2CDWF(1,n) = xscd;
    WT2KROT(n) = troot;
    WC2RDWF(n) = chwf;

    % Added some fields for Wing2 - 06/10/2008
    aircraft.Wing2.Weighted_reference_aspect_ratio = wsasref2;
    aircraft.Wing2.Weighted_reference_wing_area = wsarref2;
    aircraft.Wing2.Reference_quarter_chord_sweep = wsarqsw2;
    aircraft.Wing2.Wing_mean_thickness = wsarthb2;
    aircraft.Wing2.Reference_LE_sweep = abs(wsarlsw);
    aircraft.Wing2.Reference_non_dim_y_bar = wsarybr;
    aircraft.Wing2.Reference_MAC = wsarmac;

end

% Fairings
FairingChordFractionFore(1,n) = aircraft.Fairing1.Forward_chord_fraction;
FairingChordFractionAft(1,n) = aircraft.Fairing1.Aft_chord_fraction;
FairingFlushness(1,n) = aircraft.Fairing1.flushness;

% Fuel
% wingspf(1, n) = aircraft.fuel.Fore_wing_spar_loc_root;
% wingspf(2, n) = aircraft.fuel.Fore_wing_spar_loc_kik1;
% wingspf(3, n) = aircraft.fuel.Fore_wing_spar_loc_kin2;
% wingspf(4, n) = aircraft.fuel.Fore_wing_spar_loc_tip;
% wingspa(1, n) = aircraft.fuel.Aft_wing_spar_loc_root;
% wingspa(2, n) = aircraft.fuel.Aft_wing_spar_loc_kin1;
% wingspa(3, n) = aircraft.fuel.Aft_wing_spar_loc_kin2;
% wingspa(4, n) = aircraft.fuel.Aft_wing_spar_loc_tip;

%==========================================================================
% Modification 18/03/2009 L.Riccobene
% Added checks to preserve compatibility with previous file and granting
% usage of new ones
try
    FuelTankCutout(1, n) = aircraft.fuel.Wing_fuel_tank_cutout_opt;
catch
    FuelTankCutout(1, n) = aircraft.fuel.Wing1_fuel_tank_cutout_opt;
end
OutboardFuelSpan(1, n) = aircraft.fuel.Outboard_fuel_tank_span;
UnusableFuel(1, n) = aircraft.fuel.Unusable_fuel_option;
FuelDensity(1, n) = aircraft.fuel.Assumed_fuel_density ;
try
    TanksIncrementalWeight(1, n) = aircraft.fuel.Incr_weight_for_wing_tanks;
catch
    TanksIncrementalWeight(1, n) = 0.;
end
try
    CentreTankPortion(1, n) = aircraft.fuel.Centre_tank_portion_used;
catch
    CentreTankPortion(1, n) = aircraft.fuel.Centre_tank1_portion_used;
end
try
    IncrementCentreTank(1, n) = aircraft.fuel.Increment_for_centre_tank;
catch
    IncrementCentreTank(1, n) = 0.;
end
try
    FairingTankLength(1, n) = aircraft.fuel.Fore_fairing_tank_length;
    FairingTankLength(2, n) = aircraft.fuel.Aft_fairing_tank_length;
catch
    FairingTankLength(1, n) = aircraft.fuel.Fore_fairing1_tank_length;
    FairingTankLength(2, n) = aircraft.fuel.Aft_fairing1_tank_length;
end
FuseBladderLength(1, n) = aircraft.fuel.Aft_fuse_bladder_length;
try
    IncrementAuxiliaryTank(1, n) = aircraft.fuel.Increment_for_aux_tanks;
catch
    IncrementAuxiliaryTank(1, n) = 0.;
end
%==========================================================================

% Cabin
CabinMaxHeight(1, n) = aircraft.cabin.Cabin_max_internal_height;
CabinMaxWidth(1, n) = aircraft.cabin.Cabin_max_internal_width;
CabinFloorWidth(1, n) = aircraft.cabin.Cabin_floor_width;

% Engines
EnginesNumber(1, n) = aircraft.Engines1.Number_of_engines;
EnginesNumber(2, n) = aircraft.Engines2.Number_of_engines;
if EnginesNumber(1, n) > 0
    % Set engines number
    if EnginesNumber(2, n) > 0.0
        PN = 2;% prediction for primary and secondary powerplants
         EnginesDiameter(2, n) = aircraft.Engines2.d_max;
         EnginesLayout(2, n) = aircraft.Engines2.Layout_and_config;
         EnginesLocalY(2, n) = aircraft.Engines2.Y_locale;
    else
        PN = 1;% prediction for primary powerplants only
        EnginesDiameter(2, n) = 0;
         EnginesLayout(2, n) = 0;
         EnginesLocalY(2, n) = 0;
    end
    EnginesDiameter(1, n) = aircraft.Engines1.d_max;
    EnginesLayout(1, n) = aircraft.Engines1.Layout_and_config;
    EnginesLocalY(1, n) = aircraft.Engines1.Y_locale;    
    
    if EnginesLayout(1, n) < 3.0
        
        % calculate the lateral wing distance to inboard cut-out
        CutoutSpan1 = EnginesLocalY(1,n)*WingSpan(n) - EnginesDiameter(1,n)*0.5;
        CutoutThickness1 = Wing_Thickness_At_Span(CutoutSpan1, SpanMatrixPartition, WingThickMatrix);% thickness at cut 1
        CutoutChord1 = Wing_Chord_At_Span(CutoutSpan1, SpanMatrixPartition, RefWingChordOrigin(n), WingTaper, n);
        
        % calculate the lateral wing distance to outboard cut-out
        CutoutSpan2 = EnginesLocalY(1,n)*WingSpan(n) + EnginesDiameter(1,n)*0.5;
        CutoutThickness2 = Wing_Thickness_At_Span(CutoutSpan2, SpanMatrixPartition, WingThickMatrix);% thickness at cut 2
        CutoutChord2 = Wing_Chord_At_Span(CutoutSpan2, SpanMatrixPartition, RefWingChordOrigin(n), WingTaper, n);
        
        if PN>1
            
            % calculate the lateral wing distance to inboard cut-out
            CutoutSpan3 = EnginesLocalY(2,n)*WingSpan(n) - EnginesDiameter(2,n)*0.5;
            CutoutThickness3 = Wing_Thickness_At_Span(CutoutSpan3, SpanMatrixPartition, WingThickMatrix);% thickness at cut 3
            CutoutChord3 = Wing_Chord_At_Span(CutoutSpan3, SpanMatrixPartition, RefWingChordOrigin(n), WingTaper, n);
            
            % calculate the lateral wing distance to outboard cut-out
            CutoutSpan4 = EnginesLocalY(2,n)*WingSpan(n) + EnginesDiameter(2,n)*0.5;
            CutoutThickness4 = Wing_Thickness_At_Span(CutoutSpan4, SpanMatrixPartition, WingThickMatrix);% thickness at cut 4
            CutoutChord4 = Wing_Chord_At_Span(CutoutSpan4, SpanMatrixPartition, RefWingChordOrigin(n), WingTaper, n);
            
        else
            
            CutoutSpan3 = 0.;
            CutoutSpan4 = 0.;
            
        end
        
    else
        
        CutoutSpan1 = 0.;
        CutoutSpan2 = 0.;
        CutoutSpan3 = 0.;
        CutoutSpan4 = 0.;
        
    end
else
    CutoutSpan1 = 0.;
    CutoutSpan2 = 0.;
    CutoutSpan3 = 0.;
    CutoutSpan4 = 0.;
    CutoutThickness1 = 0;
    CutoutChord1 = 0;
    CutoutThickness2 = 0;
    CutoutChord2 = 0;
end

%==========================================================================
% Calculate wingbox extent

% Box elastic axis position (chord percentage)
BoxEA = zeros(4, 1);
BoxEA(1) = aircraft.fuel.box_ea_loc_root;
BoxEA(2) = aircraft.fuel.box_ea_loc_kink1;
BoxEA(3) = aircraft.fuel.box_ea_loc_kink2;
BoxEA(4) = aircraft.fuel.box_ea_loc_tip;

% Set, conventionally, elastic axis position to middle wing
test = BoxEA == 0.;
if any(test)
    BoxEA(test) = .5;
end

% Wing front spar locations (chord percentage)
BoxSparOffset = zeros(4, 1);
BoxSparOffset(1) = aircraft.fuel.box_semispan_root;
BoxSparOffset(2) = aircraft.fuel.box_semispan_kink1;
BoxSparOffset(3) = aircraft.fuel.box_semispan_kink2;
BoxSparOffset(4) = aircraft.fuel.box_semispan_tip;

% Check if semispan is zero (set default value, a wingbox that spans
% between 30% to 70% of local chord)
test = BoxSparOffset == 0.;
if any(test)
    BoxSparOffset(test) = .2;
end

% Compute fore spar positions
FrontSparPosition(:, n) = BoxEA - BoxSparOffset;

test = FrontSparPosition(:, n) <= 0.;
if any(test)
    error('Fore spar exceeds wing limits!');
end

% Compute rear spar positions
RearSparPosition(:, n) = BoxEA + BoxSparOffset;

test = RearSparPosition(:, n) >= 1.;
if any(test)
    error('Rear spar exceeds wing limits!');
end

% Uncomment to see chord at the four stations (root, kink1, kink2, tip)
% c = zeros(4, 1);
% c(1) = Wing_Chord_At_Span(XSECDWF(n)/2, WSPNMTX, WCHDROT, wingtap, n);
% c(2) = Wing_Chord_At_Span(wingkln(1, n)*wingspn(n)/2, WSPNMTX, WCHDROT, wingtap, n);
% c(3) = Wing_Chord_At_Span(wingkln(2, n)*wingspn(n)/2, WSPNMTX, WCHDROT, wingtap, n);
% c(4) = Wing_Chord_At_Span(wingspn(n)/2, WSPNMTX, WCHDROT, wingtap, n);
% assignin('base', 'c', c);

%==========================================================================

if FuelDensity(n) < 0.0001
    FuelDensity(n) = 0.802;% fuel density default is 0.802 kg/cu.m
end

FuelDensity(n) = FuelDensity * 1000; %to kg/m3

%==========================================================================

% Inspect if the user wants nominal tank span or has specified it
if OutboardFuelSpan(n) < 0.0001
    OutboardFuelSpan(n) = 0.70;% user selected 70% wing span for tank
end

if OutboardFuelSpan(n) > 0.99
    OutboardFuelSpan(n) = 0.99;% idiot-proof the max tank span
end

%==========================================================================

% intialise the centre of gravity objectives
% xcgwing=0.;
% ycgwing=0.;
% zcgwing=0.;
FairingXCG=0.;
FairingYCG=0.;
FairingZCG=0.;
AuxiliaryXCG=0.;
AuxiliaryYCG=0.;
AuxiliaryZCG=0.;

%==========================================================================
% Compute the inboard tank (No. 1) volume
%

Tank1Length = SpanMatrixPartition(1) - FuseWingPosition(n)/2;% tank length
Tank1ChordFrac1 = abs(FrontSparPosition(1, n) - RearSparPosition(1, n));% usable chord fraction
Tank1Thickness1 = Wing_Thickness_At_Span(FuseWingPosition(n)/2, SpanMatrixPartition, WingThickMatrix);% thickness at wing-fuse

% local chord length at wing-fuse
Tank1Chord1 = Wing_Chord_At_Span(FuseWingPosition(n)/2, SpanMatrixPartition, RefWingChordOrigin, WingTaper, n);
Tank1ChordFrac2 = abs(FrontSparPosition(2, n) - RearSparPosition(2, n));% usable chord fraction
Tank1Thickness2 = Wing_Thickness_At_Span(WingKink(1, n)*WingSpan(n)/2, SpanMatrixPartition, WingThickMatrix);% thickness at kink 1

% local chord length at kink 1 station
Tank1Chord2 = Wing_Chord_At_Span(WingKink(1, n)*WingSpan(n)/2, SpanMatrixPartition, RefWingChordOrigin, WingTaper, n);

% predict the No. 1 tank volume and centre of gravity
[Tank1Volume, Tank1YCG] = Available_Volume(Tank1Length, Tank1ChordFrac1, Tank1Thickness1, Tank1Chord1(n), Tank1ChordFrac2, Tank1Thickness2, Tank1Chord2(n));
Tank1Volume = 2*Tank1Volume;

% locate forward and aft spar centroid at kink 1
SparCentroidKink1 = Tank1Length*tan(deg2rad*WingLESweep(1,n))+Tank1Chord2(n)*(RearSparPosition(2,n)+FrontSparPosition(2,n))/2;

% locate the non-dimensional longitudinal cg of tank 1
Tank1XCG = (FuseLength(n)*WingApex(n)+FuseWingPosition(n)/2*tan(deg2rad*WingLESweep(1,n))+ ...
    Tank1Chord1(n)*(RearSparPosition(1,n)+FrontSparPosition(1,n))/2 +...
    Tank1YCG/Tank1Length*(SparCentroidKink1-Tank1Chord1(n)/2))/FuseLength(n);

% locate the non-dimensional vertical cg of tank 1
Tank1ZCG = (FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5)+ ...
    (Tank1YCG+FuseWingPosition(n)/2)*tan(deg2rad*WingDihedral(1,n)))/FuseVerticalDiameterAft(n);

%==========================================================================
% Predict the centre tank volume
%

% default no fuel in centre tank
CentralTankVolume=0.0;
CentralTankXCG=0.0;
CentralTankZCG=0.0;
CentralTankAdjustedVolume(n)=0;
CentralTankWeight(n)=0;

if CentreTankPortion(n) > 0.0001
    CentralTankVolume = CentreTankPortion(n)/100*2*Available_Volume(FuseWingPosition(n)/2,Tank1ChordFrac1,WingThickness(1,n), ...
        OriginalFuseWingChord(n),Tank1ChordFrac1,WTHKROT(n),RefWingChordOrigin(n));
    CentralTankAdjustedVolume(n) = CentralTankVolume+IncrementCentreTank(n)/FuelDensity(n);
    CentralTankWeight(n) = CentralTankAdjustedVolume(n)*FuelDensity(n);
    CentralTankXCG = (FuseLength(n)*WingApex(n)+FuseWingPosition(n)/2*tan(deg2rad*WingLESweep(1,n))+ ...
        OriginalFuseWingChord(n)*(RearSparPosition(1,n)+FrontSparPosition(1,n))/2)/FuseLength(n);% x cg
    CentralTankZCG = RefWingChordOrigin(n)*WingThickness(1,n)/(2*FuseVerticalDiameterAft(n))-0.5;% z cg
end

%==========================================================================
% Compute the midboard tank (No. 2) volume and centre of gravity
%

Tank2Length = SpanMatrixPartition(2);% tank length
Tank2ChordFrac2 = abs(FrontSparPosition(3,n)-RearSparPosition(3,n));% usable chord fraction
Tank2Thickness2 = Wing_Thickness_At_Span(WingKink(2,n)*WingSpan(n)/2,SpanMatrixPartition,WingThickMatrix);% thickness at kink 2

% local chord length at kink 2 station
Tank2Chord2 = Wing_Chord_At_Span(WingKink(2,n)*WingSpan(n)/2,SpanMatrixPartition,RefWingChordOrigin,WingTaper,n);

% predict the No. 2 volume
[Tank2Volume, Tank2YCG] = Available_Volume(Tank2Length,Tank1ChordFrac2,Tank1Thickness2,Tank1Chord2(n),Tank2ChordFrac2,Tank2Thickness2,Tank2Chord2(n));
Tank2Volume = 2*Tank2Volume;

SparCentroidKink2 = Tank1Length*tan(deg2rad*WingLESweep(1,n))+Tank2Length*tan(deg2rad*WingLESweep(2,n))+ ...
    Tank2Chord2(n)*(RearSparPosition(3,n)+FrontSparPosition(3,n))/2;

% locate the non-dimensional longitudinal cg of tank 2
Tank2XCG = (FuseLength(n)*WingApex(n)+SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1,n))+ ...
    Tank1Chord2(n)*(RearSparPosition(2,n)+FrontSparPosition(2,n))/2+ ...
    Tank2YCG/Tank2Length*(SparCentroidKink2-SparCentroidKink1))/FuseLength(n);

% locate the non-dimensional vertical cg of tank 2
Tank2ZCG = (FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5)+SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n))+ ...
    Tank2YCG*tan(deg2rad*WingDihedral(2,n)))/FuseVerticalDiameterAft(n);

%==========================================================================
% Compute the remaining outboard tank (No. 3) volume
%

Tank3Length = SpanMatrixPartition(3);% tank length
Tank3ChordFrac2 = abs(FrontSparPosition(4,n)-RearSparPosition(4,n));% usable chord fraction
Tank3Thickness2 = Wing_Thickness_At_Span(WingSpan(n)/2,SpanMatrixPartition,WingThickMatrix);% thickness at outboard station

% local chord length at outboard tank station
Tank3Chord2 = Wing_Chord_At_Span(WingSpan(n)/2,SpanMatrixPartition,RefWingChordOrigin,WingTaper,n);

% predict the No. 3 tank volume
[Tank3Volume,Tank3YCG] = Available_Volume(Tank3Length,Tank2ChordFrac2,Tank2Thickness2,Tank2Chord2(n),Tank3ChordFrac2,Tank3Thickness2,Tank3Chord2(n));
Tank3Volume = 2*Tank3Volume;
SparCentroidTip = Tank1Length*tan(deg2rad*WingLESweep(1,n))+Tank2Length*tan(deg2rad*WingLESweep(2,n))+ ...
    Tank3Length*tan(deg2rad*WingLESweep(3,n))+Tank3Chord2(n)*(RearSparPosition(4,n)+FrontSparPosition(4,n))/2;

% locate the non-dimensional longitudinal cg of tank 3
Tank3XCG = (FuseLength(n)*WingApex(n)+SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1,n))+ ...
    SpanMatrixPartition(2)*tan(deg2rad*WingLESweep(2,n))+ ...
    Tank2Chord2(n)*(RearSparPosition(3,n)+FrontSparPosition(3,n))/2+ ...
    Tank3YCG/Tank3Length*(SparCentroidTip-SparCentroidKink2))/FuseLength(n);

% locate the non-dimensional vertical cg of tank 3
Tank3ZCG = (FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5)+SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n))+ ...
    SpanMatrixPartition(2)*tan(deg2rad*WingDihedral(2,n))+ ...
    Tank3YCG*tan(deg2rad*WingDihedral(3,n)))/FuseVerticalDiameterAft(n);

%==========================================================================
% Type of tank cut-out, i.e. max engine diameter or not
%

if FuelTankCutout(n) > 0.0001
    if EnginesLayout(1, n) < 3.0
        % estimate the equivalent lspard at this locale
        Cutout1ChordFrac1 = lpcomp(CutoutSpan1,Tank1ChordFrac1,Tank1ChordFrac2,Tank2ChordFrac2,Tank3ChordFrac2,WingKink,WingSpan, ...
            FuseWingPosition,SpanMatrixPartition,n);
        Cutout1ChordFrac2 = lpcomp(CutoutSpan2,Tank1ChordFrac1,Tank1ChordFrac2,Tank2ChordFrac2,Tank3ChordFrac2,WingKink,WingSpan, ...
            FuseWingPosition,SpanMatrixPartition,n);
        % estimate the cut-out volume - primary
        Cutout1Volume = 2*Available_Volume(EnginesDiameter(1,n),Cutout1ChordFrac1,CutoutThickness1,CutoutChord1,Cutout1ChordFrac2,CutoutThickness2,CutoutChord2);
        if PN > 1
            Cutout2ChordFrac1 = lpcomp(CutoutSpan3,Tank1ChordFrac1,Tank1ChordFrac2,Tank2ChordFrac2,Tank3ChordFrac2,WingKink,WingSpan, ...
                FuseWingPosition,SpanMatrixPartition,n);
            Cutout2ChordFrac2 = lpcomp(CutoutSpan4,Tank1ChordFrac1,Tank1ChordFrac2,Tank2ChordFrac2,Tank3ChordFrac2,WingKink,WingSpan, ...
                FuseWingPosition,SpanMatrixPartition,n);
            % estimate the cut-out volume -secondary
            Cutout2Volume = 2*Available_Volume(EnginesDiameter(2,n),Cutout2ChordFrac1,CutoutThickness3,CutoutChord3,Cutout2ChordFrac2,CutoutThickness4,CutoutChord4);
        else
            Cutout2Volume = 0.0;% no secondary powerplant has been selected
        end
    else
        % aft fuse mounted, S or straight duct engines (primary)
        Cutout1Volume = 0.0;
        Cutout2Volume = 0.0;
    end
else
    Cutout1Volume = 0.0;
    Cutout2Volume = 0.0;% no cut-out to be employed
end

%==========================================================================
% Maximum fuel in wings predicted, now adjust for limited outboard
% tank span
%

if OutboardFuelSpan(n) < WingKink(1, n)
    
    OuterCutLength = (WingKink(1,n)-OutboardFuelSpan(n))*WingSpan(n)/2;% length to cut out from No. 1
    % estimate the equivalent lspard at this locale
    OuterCutChordFrac = 2*(Tank1ChordFrac1-Tank1ChordFrac2)/(FuseWingPosition(n)-WingKink(1,n)*WingSpan(n))*(OutboardFuelSpan(n)*WingSpan(n)/2- ...
        FuseWingPosition(n))/2+Tank1ChordFrac1;
    OuterCutThickness = Wing_Thickness_At_Span(OutboardFuelSpan(n)*WingSpan(n)/2,SpanMatrixPartition,WingThickMatrix);% thickness at tank end
    % local chord length at tank end station
    OuterCutChord = Wing_Chord_At_Span(OutboardFuelSpan(n)*WingSpan(n)/2,SpanMatrixPartition,RefWingChordOrigin,WingTaper,n);
    % predict the tank volume cut-out from No. 1
    [OuterCutVolume, OuterCutYCG] = Available_Volume(OuterCutLength,OuterCutChordFrac,OuterCutThickness,OuterCutChord(n),Tank1ChordFrac2,Tank1Thickness2,Tank1Chord2(n));
    OuterCutVolume = OuterCutVolume*2;
    % locate the non-dimensional longitudinal cg of tank 1 cut-out
    OuterCutFrontSpar = FrontSparPosition(2,n)-2*(FrontSparPosition(2,n)-FrontSparPosition(1,n))/(WingKink(1,n)*WingSpan(n)- ...
        FuseWingPosition(n))*OuterCutLength;
    OuterCutRearSpar = RearSparPosition(2,n)-2*(RearSparPosition(2,n)-RearSparPosition(1,n))/(WingKink(1,n)*WingSpan(n)- ...
        FuseWingPosition(n))*OuterCutLength;
    OuterCutXCG = (FuseLength(n)*WingApex(n)+OutboardFuelSpan(n)*WingSpan(n)/2*tan(deg2rad*WingLESweep(1,n))+ ...
        OuterCutChord(n)*(OuterCutRearSpar+OuterCutFrontSpar)/2+ ...
        OuterCutYCG/OuterCutLength*(SparCentroidKink1-OuterCutChord(n)/2- ...
        (OutboardFuelSpan(n)*WingSpan(n)-FuseWingPosition(n))/2*tan(deg2rad*WingLESweep(1, ...
        n))))/FuseLength(n);
    % locate the non-dimensional vertical cg of tank 1 cut-out
    OuterCutZCG = (FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5)+ ...
        OutboardFuelSpan(n)*WingSpan(n)/2*tan(deg2rad*WingDihedral(1,n)))/FuseVerticalDiameterAft(n);
    WingFuelVolume = Tank1Volume - OuterCutVolume;% tally the maximum fuel that can be stored in wings
    WingFuelXCG = (Tank1XCG*Tank1Volume-OuterCutXCG*OuterCutVolume)/WingFuelVolume;% adjusted x cg
    %======================================================================
%     ycgmast = (ycenog1/fuselgt(n)*uscvol1-ycenoge/fuselgt(n)*uscvola)/uscvolo;% adjusted y cg
    %======================================================================
    WingFuelZCG = (Tank1ZCG*Tank1Volume-OuterCutZCG*OuterCutVolume)/WingFuelVolume;% adjusted z cg
    
elseif OutboardFuelSpan(n) >= WingKink(1,n) && OutboardFuelSpan(n) < WingKink(2,n)
    
    OuterCutLength = (WingKink(2,n)-OutboardFuelSpan(n))*WingSpan(n)/2;% length to cut out from No. 2
    % estimate the equivalent lspard at this locale
    OuterCutChordFrac = (Tank1ChordFrac2-Tank2ChordFrac2)/(WingKink(1,n)-WingKink(2,n))*(OutboardFuelSpan(n)-WingKink(1,n))+ ...
        Tank1ChordFrac2;
    OuterCutThickness = Wing_Thickness_At_Span(OutboardFuelSpan(n)*WingSpan(n)/2,SpanMatrixPartition,WingThickMatrix);% thickness at tank end
    % local chord length at tank end station
    OuterCutChord = Wing_Chord_At_Span(OutboardFuelSpan(n)*WingSpan(n)/2,SpanMatrixPartition,RefWingChordOrigin,WingTaper,n);
    % predict the tank volume cut-out from No. 2
    [OuterCutVolume, OuterCutYCG] = Available_Volume(OuterCutLength,OuterCutChordFrac,OuterCutThickness,OuterCutChord(n),Tank2ChordFrac2,Tank2Thickness2,Tank2Chord2(n));
    OuterCutVolume = OuterCutVolume*2;
    % locate the non-dimensional longitudinal cg of tank 2 cut-out
    OuterCutFrontSpar = FrontSparPosition(3,n)-2*(FrontSparPosition(3,n)-FrontSparPosition(2,n))/((WingKink(2,n)- ...
        WingKink(1,n))*WingSpan(n))*OuterCutLength;
    OuterCutRearSpar = RearSparPosition(3,n)-2*(RearSparPosition(3,n)-RearSparPosition(2,n))/((WingKink(2,n)- ...
        WingKink(1,n))*WingSpan(n))*OuterCutLength;
    OuterCutXCG = (FuseLength(n)*WingApex(n)+ ...
        WingKink(1,n)*WingSpan(n)/2*tan(deg2rad*WingLESweep(1,n))+ ...
        (OutboardFuelSpan(n)-WingKink(1,n))*WingSpan(n)/2*tan(deg2rad*WingLESweep(2,n))+ ...
        OuterCutChord(n)*(OuterCutRearSpar+OuterCutFrontSpar)/2+ ...
        OuterCutYCG/OuterCutLength*(SparCentroidKink2-OuterCutChord(n)/2- ...
        (SpanMatrixPartition(1)-FuseWingPosition(n)/2)*tan(deg2rad*WingLESweep(1,n))- ...
        (OutboardFuelSpan(n)-WingKink(1,n))*WingSpan(n)/2*tan(deg2rad*WingLESweep(2, ...
        n))))/FuseLength(n);
    % locate the non-dimensional vertical cg of tank 2 cut-out
    OuterCutZCG = (FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5)+ ...
        SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n))+ ...
        (OutboardFuelSpan(n)-WingKink(1,n))*WingSpan(n)/2*tan(deg2rad*WingDihedral(2, ...
        n)))/FuseVerticalDiameterAft(n);
    % tally the maximum fuel that can be stored in the wings
    WingFuelVolume = Tank1Volume + Tank2Volume - OuterCutVolume;
    WingFuelXCG = (Tank1XCG*Tank1Volume+Tank2XCG*Tank2Volume-OuterCutXCG*OuterCutVolume)/WingFuelVolume;% x cg
    %======================================================================
%     ycgmast = (ycenog1/fuselgt(n)*uscvol1+ycenog2/fuselgt(n)*uscvol2-ycenoge/fuselgt(n)*uscvola)/uscvolo;% y cg
    %======================================================================
    WingFuelZCG = (Tank1ZCG*Tank1Volume+Tank2ZCG*Tank2Volume-OuterCutZCG*OuterCutVolume)/WingFuelVolume;% z cg
    
elseif OutboardFuelSpan(n) >= WingKink(2,n)
    OuterCutLength = (1-OutboardFuelSpan(n))*WingSpan(n)/2;% length to cut out from No. 3
    % estimate the equivalent lspard at this locale
    OuterCutChordFrac = (Tank2ChordFrac2-Tank3ChordFrac2)/(WingKink(2,n)-1)*(OutboardFuelSpan(n)-WingKink(2,n))+ ...
        Tank2ChordFrac2;
    OuterCutThickness = Wing_Thickness_At_Span(OutboardFuelSpan(n)*WingSpan(n)/2,SpanMatrixPartition,WingThickMatrix);% thickness at tank end
    % local chord length at tank end station
    OuterCutChord = Wing_Chord_At_Span(OutboardFuelSpan(n)*WingSpan(n)/2,SpanMatrixPartition,RefWingChordOrigin,WingTaper,n);
    % predict the tank volume cut-out from No. 3
    [OuterCutVolume, OuterCutYCG] = Available_Volume(OuterCutLength,OuterCutChordFrac,OuterCutThickness,OuterCutChord(n),Tank3ChordFrac2,Tank3Thickness2,Tank3Chord2(n));
    OuterCutVolume = OuterCutVolume*2;
    % locate the non-dimensional longitudinal cg of tank 3 cut-out
    OuterCutFrontSpar = FrontSparPosition(4,n)-2*(FrontSparPosition(4,n)-FrontSparPosition(3,n))/((1- ...
        WingKink(2,n))*WingSpan(n))*OuterCutLength;
    OuterCutRearSpar = RearSparPosition(4,n)-2*(RearSparPosition(4,n)-RearSparPosition(3,n))/((1- ...
        WingKink(2,n))*WingSpan(n))*OuterCutLength;
    OuterCutXCG = (FuseLength(n)*WingApex(n)+ ...
        WingKink(1,n)*WingSpan(n)/2*tan(deg2rad*WingLESweep(1,n))+ ...
        WingKink(2,n)*WingSpan(n)/2*tan(deg2rad*WingLESweep(2,n))+ ...
        (OutboardFuelSpan(n)-WingKink(2,n))*WingSpan(n)/2*tan(deg2rad*WingLESweep(3,n))+ ...
        OuterCutChord(n)*(OuterCutRearSpar+OuterCutFrontSpar)/2+ ...
        OuterCutYCG/OuterCutLength*(SparCentroidTip-OuterCutChord(n)/2- ...
        (SpanMatrixPartition(1)-FuseWingPosition(n)/2)*tan(deg2rad*WingLESweep(1,n))- ...
        SpanMatrixPartition(2)*tan(deg2rad*WingLESweep(2,n))- ...
        (OutboardFuelSpan(n)-WingKink(2,n))*WingSpan(n)/2*tan(deg2rad*WingLESweep(3, ...
        n))))/FuseLength(n);
    % locate the non-dimensional vertical cg of tank 3 cut-out
    OuterCutZCG = (FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5)+ ...
        SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n))+ ...
        SpanMatrixPartition(2)*tan(deg2rad*WingDihedral(2,n))+ ...
        (OutboardFuelSpan(n)-WingKink(2,n))*WingSpan(n)/2*tan(deg2rad*WingDihedral(3, ...
        n)))/FuseVerticalDiameterAft(n);
    % tally the maximum fuel that can be stored in the wings
    WingFuelVolume = Tank1Volume + Tank2Volume + Tank3Volume - OuterCutVolume;
    WingFuelXCG = (Tank1XCG*Tank1Volume+Tank2XCG*Tank2Volume+Tank3XCG*Tank3Volume- ...
        OuterCutXCG*OuterCutVolume)/WingFuelVolume;% adjusted x cg
    %======================================================================        
%     ycgmast = (ycenog1/fuselgt(n)*uscvol1+ycenog2/fuselgt(n)*uscvol2+ycenog3/fuselgt(n)*uscvol3- ...
%         ycenoge/fuselgt(n)*uscvola)/uscvolo;% adjusted y cg
    %======================================================================
    WingFuelZCG = (Tank1ZCG*Tank1Volume+Tank2ZCG*Tank2Volume+Tank3ZCG*Tank3Volume- ...
        OuterCutZCG*OuterCutVolume)/WingFuelVolume;% adjusted z cg
end

if OutboardFuelSpan(n) >= 2*CutoutSpan2/WingSpan(n)
    % engine cut-out - primary only
    WingFuelVolume = WingFuelVolume - FuelTankCutout(n)*Cutout1Volume;
end

if OutboardFuelSpan(n) >= 2*CutoutSpan4/WingSpan(n)
    % engine cut-out - primary and secondary
    WingFuelVolume = WingFuelVolume - FuelTankCutout(n)*Cutout2Volume;
end

%==========================================================================
% intially predicted maximum fuel weight in wing No. 1
AdjustedWingFuelVolume = WingFuelVolume+TanksIncrementalWeight(n)/FuelDensity(n);
AdjustedWingFuelWeight = AdjustedWingFuelVolume*FuelDensity(n);
%==========================================================================
% check if a second wing has been defined
%
uscvole=0.0;
xcgmas2=0.0;
%===========
ycgmas2=0.0;
%===========
zcgmas2=0.0;% default no fuel in wing 2
centvo2=0.0;
xcogce2=0.0;
zcogce2=0.0;% default no fuel in centre tank
%

if wi2present(1,n) == 1
%if wi2gare(n) > 0.0001
    %=====
    % compute the inboard tank (No. 1) volume
    Tank1Length = WS2NMTX(1)-XS2CDWF(n)/2;% tank length
    Tank1Thickness1 = Wing_Thickness_At_Span(XS2CDWF(n)/2,WS2NMTX,WT2KMTX);% thickness at wing-fuse
    % local chord length at wing-fuse
    Tank1Chord1 = Wing_Chord_At_Span(XS2CDWF(n)/2,WS2NMTX,WC2DROT,wi2gtap,n);
    Tank1Thickness2 = Wing_Thickness_At_Span(wi2gkln(1,n)*wi2gspn(n)/2,WS2NMTX,WT2KMTX);% thickness at kink 1
    % local chord length at kink 1 station
    Tank1Chord2=Wing_Chord_At_Span(wi2gkln(1,n)*wi2gspn(n)/2,WS2NMTX,WC2DROT,wi2gtap,n);
    % predict the No. 1 tank volume
    [Tank1Volume,Tank1YCG]=Available_Volume(Tank1Length,Tank1ChordFrac1,Tank1Thickness1,Tank1Chord1(n),Tank1ChordFrac2,Tank1Thickness2,Tank1Chord2(n));
    Tank1Volume=2*Tank1Volume;
    % locate forward and aft spar centroid at kink 1
    SparCentroidKink1=Tank1Length*tan(deg2rad*wi2glsw(1,n))+Tank1Chord2(n)*(RearSparPosition(2,n)+FrontSparPosition(2,n))/2;
    % locate the non-dimensional longitudinal cg of tank 1
    Tank1XCG=(FuseLength(n)*wi2gapx(n)+XS2CDWF(n)/2*tan(deg2rad*wi2glsw(1,n))+ ...
        Tank1Chord1(n)*(RearSparPosition(1,n)+FrontSparPosition(1,n))/2+ ...
        Tank1YCG/Tank1Length*(SparCentroidKink1-Tank1Chord1(n)/2))/FuseLength(n);
    % locate the non-dimensional vertical cg of tank 1
    Tank1ZCG=(FuseVerticalDiameterAft(n)*(wi2gplc(n)-0.5)+ ...
        (Tank1YCG+XS2CDWF(n)/2)*tan(deg2rad*wi2gdih(1,n)))/FuseVerticalDiameterAft(n);
    %=================================
    % predict the centre tank volume
    if CentreTankPortion(n)>0.0001
        centvo2=CentreTankPortion(n)/100*2*Available_Volume(XS2CDWF(n)/2,Tank1ChordFrac1, ...
            wi2gthk(1,n),WC2RDWF(n),Tank1ChordFrac1,WT2KROT(n),WC2DROT(n));
        CentralTankAdjustedVolume(n)=CentralTankAdjustedVolume(n)+centvo2*1000;
        CentralTankWeight(n)=CentralTankAdjustedVolume(n)*FuelDensity(n);
        xcogce2=(FuseLength(n)*wi2gapx(n)+XS2CDWF(n)/2*tan(deg2rad*wi2glsw(1,n))+ ...
            WC2RDWF(n)*(RearSparPosition(1,n)+FrontSparPosition(1,n))/2)/FuseLength(n);% x cg
        zcogce2=WC2DROT(n)*wi2gthk(1,n)/(2*FuseVerticalDiameterAft(n))-0.5;% z cg
    end
    %=================================
    % compute the midboard tank (No. 2) volume
    Tank2Length=WS2NMTX(2);% tank length
    Tank2Thickness2=Wing_Thickness_At_Span(wi2gkln(2,n)*wi2gspn(n)/2,WS2NMTX,WT2KMTX);% thickness at kink 2
    % local chord length at kink 2 station
    Tank2Chord2=Wing_Chord_At_Span(wi2gkln(2,n)*wi2gspn(n)/2,WS2NMTX,WC2DROT,wi2gtap,n);
    % predict the No. 2 volume
    [Tank2Volume,Tank2YCG]=Available_Volume(Tank2Length,Tank1ChordFrac2,Tank1Thickness2,Tank1Chord2(n),Tank2ChordFrac2,Tank2Thickness2,Tank2Chord2(n));
    Tank2Volume=2*Tank2Volume;
    SparCentroidKink2=Tank1Length*tan(deg2rad*wi2glsw(1,n))+Tank2Length*tan(deg2rad*wi2glsw(2,n))+ ...
        Tank2Chord2(n)*(RearSparPosition(3,n)+FrontSparPosition(3,n))/2;
    % locate the non-dimensional longitudinal cg of tank 2
    Tank2XCG=(FuseLength(n)*wi2gapx(n)+WS2NMTX(1)*tan(deg2rad*wi2glsw(1,n))+ ...
        Tank1Chord2(n)*(RearSparPosition(2,n)+FrontSparPosition(2,n))/2+ ...
        Tank2YCG/Tank2Length*(SparCentroidKink2-SparCentroidKink1))/FuseLength(n);
    % locate the non-dimensional vertical cg of tank 2
    Tank2ZCG=(FuseVerticalDiameterAft(n)*(wi2gplc(n)-0.5)+WS2NMTX(1)*tan(deg2rad*wi2gdih(1,n))+ ...
        Tank2YCG*tan(deg2rad*wi2gdih(2,n)))/FuseVerticalDiameterAft(n);
    %=====
    % compute the remaining outboard tank (No. 3) volume
    Tank3Length=WS2NMTX(3);% tank length
    Tank3Thickness2=Wing_Thickness_At_Span(wi2gspn(n)/2,WS2NMTX,WT2KMTX);% thickness at outboard station
    % local chord length at outboard tank station
    Tank3Chord2=Wing_Chord_At_Span(wi2gspn(n)/2,WS2NMTX,WC2DROT,wi2gtap,n);
    % predict the No. 3 tank volume
    [Tank3Volume,Tank3YCG]=Available_Volume(Tank3Length,Tank2ChordFrac2,Tank2Thickness2,Tank2Chord2(n),Tank3ChordFrac2,Tank3Thickness2,Tank3Chord2(n));
    Tank3Volume=2*Tank3Volume;
    SparCentroidTip=Tank1Length*tan(deg2rad*wi2glsw(1,n))+Tank2Length*tan(deg2rad*wi2glsw(2,n))+ ...
        Tank3Length*tan(deg2rad*wi2glsw(3,n))+Tank3Chord2(n)*(RearSparPosition(4,n)+FrontSparPosition(4,n))/2;
    % locate the non-dimensional longitudinal cg of tank 3
    Tank3XCG=(FuseLength(n)*wi2gapx(n)+WS2NMTX(1)*tan(deg2rad*wi2glsw(1,n))+ ...
        WS2NMTX(2)*tan(deg2rad*wi2glsw(2,n))+ ...
        Tank2Chord2(n)*(RearSparPosition(3,n)+FrontSparPosition(3,n))/2+ ...
        Tank3YCG/Tank3Length*(SparCentroidTip-SparCentroidKink2))/FuseLength(n);
    % locate the non-dimensional vertical cg of tank 3
    Tank3ZCG=(FuseVerticalDiameterAft(n)*(wi2gplc(n)-0.5)+WS2NMTX(1)*tan(deg2rad*wi2gdih(1,n))+ ...
        WS2NMTX(2)*tan(deg2rad*wi2gdih(2,n))+ ...
        Tank3YCG*tan(deg2rad*wi2gdih(3,n)))/FuseVerticalDiameterAft(n);
    %=====
    % maximum fuel in wings predicted, now adjust for limited outboard
    % tank span
    if OutboardFuelSpan(n)<=wi2gkln(1,n)
        
        OuterCutLength=(wi2gkln(1,n)-OutboardFuelSpan(n))*wi2gspn(n)/2;% length to cut out from No. 1
        % estimate the equivalent lspard at this locale
        OuterCutChordFrac=2*(Tank1ChordFrac1-Tank1ChordFrac2)/(XS2CDWF(n)-wi2gkln(1,n)*wi2gspn(n))*(OutboardFuelSpan(n)*wi2gspn(n)/2- ...
            XS2CDWF(n))/2+Tank1ChordFrac1;
        OuterCutThickness=Wing_Thickness_At_Span(OutboardFuelSpan(n)*wi2gspn(n)/2,WS2NMTX,WT2KMTX);% thickness at tank end
        % local chord length at tank end station
        OuterCutChord=Wing_Chord_At_Span(OutboardFuelSpan(n)*wi2gspn(n)/2,WS2NMTX,WC2DROT,wi2gtap,n);
        % predict the tank volume cut-out from No. 1
        [OuterCutVolume,OuterCutYCG]=Available_Volume(OuterCutLength,OuterCutChordFrac,OuterCutThickness,OuterCutChord(n),Tank1ChordFrac2,Tank1Thickness2,Tank1Chord2(n));
        OuterCutVolume=OuterCutVolume*2;
        % locate the non-dimensional longitudinal cg of tank 1 cut-out
        OuterCutFrontSpar=FrontSparPosition(2,n)-2*(FrontSparPosition(2,n)-FrontSparPosition(1,n))/(wi2gkln(1,n)*wi2gspn(n)- ...
            XS2CDWF(n))*OuterCutLength;
        OuterCutRearSpar=RearSparPosition(2,n)-2*(RearSparPosition(2,n)-RearSparPosition(1,n))/(wi2gkln(1,n)*wi2gspn(n)- ...
            XS2CDWF(n))*OuterCutLength;
        OuterCutXCG=(FuseLength(n)*wi2gapx(n)+OutboardFuelSpan(n)*wi2gspn(n)/2*tan(deg2rad*wi2glsw(1,n))+ ...
            OuterCutChord(n)*(OuterCutRearSpar+OuterCutFrontSpar)/2+ ...
            OuterCutYCG/OuterCutLength*(SparCentroidKink1-OuterCutChord(n)/2- ...
            (OutboardFuelSpan(n)*wi2gspn(n)-XS2CDWF(n))/2*tan(deg2rad*wi2glsw(1, ...
            n))))/FuseLength(n);
        % locate the non-dimensional vertical cg of tank 1 cut-out
        OuterCutZCG=(FuseVerticalDiameterAft(n)*(wi2gplc(n)-0.5)+ ...
            OutboardFuelSpan(n)*wi2gspn(n)/2*tan(deg2rad*wi2gdih(1,n)))/FuseVerticalDiameterAft(n);
        uscvole=Tank1Volume-OuterCutVolume;% tally the maximum fuel that can be stored in wings
        xcgmas2=(Tank1XCG*Tank1Volume-OuterCutXCG*OuterCutVolume)/uscvole;% adjusted x cg
        %==================================================================
%         ycgmas2=(ycenog1/fuselgt(n)*uscvol1-ycenoge/fuselgt(n)*uscvola)/uscvole;% adjusted y cg
        %==================================================================
        zcgmas2=(Tank1ZCG*Tank1Volume-OuterCutZCG*OuterCutVolume)/uscvole;% adjusted z cg
        
    elseif OutboardFuelSpan(n)>wi2gkln(1,n) && OutboardFuelSpan(n)<=wi2gkln(2,n)
        OuterCutLength=(wi2gkln(2,n)-OutboardFuelSpan(n))*wi2gspn(n)/2;% length to cut out from No. 2
        % estimate the equivalent lspard at this locale
        OuterCutChordFrac=(Tank1ChordFrac2-Tank2ChordFrac2)/(wi2gkln(1,n)-wi2gkln(2,n))*(OutboardFuelSpan(n)-wi2gkln(1,n))+ ...
            Tank1ChordFrac2;
        OuterCutThickness=Wing_Thickness_At_Span(OutboardFuelSpan(n)*wi2gspn(n)/2,WS2NMTX,WT2KMTX);% thickness at tank end
        % local chord length at tank end station
        OuterCutChord=Wing_Chord_At_Span(OutboardFuelSpan(n)*wi2gspn(n)/2,WS2NMTX,WC2DROT,wi2gtap,n);
        % predict the tank volume cut-out from No. 2
        [OuterCutVolume,OuterCutYCG]=Available_Volume(OuterCutLength,OuterCutChordFrac,OuterCutThickness,OuterCutChord(n),Tank2ChordFrac2,Tank2Thickness2,Tank2Chord2(n));
        OuterCutVolume=OuterCutVolume*2;
        % locate the non-dimensional longitudinal cg of tank 2 cut-out
        OuterCutFrontSpar=FrontSparPosition(3,n)-2*(FrontSparPosition(3,n)-FrontSparPosition(2,n))/((wi2gkln(2,n)- ...
            wi2gkln(1,n))*wi2gspn(n))*OuterCutLength;
        OuterCutRearSpar=RearSparPosition(3,n)-2*(RearSparPosition(3,n)-RearSparPosition(2,n))/((wi2gkln(2,n)- ...
            wi2gkln(1,n))*wi2gspn(n))*OuterCutLength;
        OuterCutXCG=(FuseLength(n)*wi2gapx(n)+ ...
            wi2gkln(1,n)*wi2gspn(n)/2*tan(deg2rad*wi2glsw(1,n))+ ...
            (OutboardFuelSpan(n)-wi2gkln(1,n))*wi2gspn(n)/2*tan(deg2rad*wi2glsw(2,n))+ ...
            OuterCutChord(n)*(OuterCutRearSpar+OuterCutFrontSpar)/2+ ...
            OuterCutYCG/OuterCutLength*(SparCentroidKink2-OuterCutChord(n)/2- ...
            (WS2NMTX(1)-XS2CDWF(n)/2)*tan(deg2rad*wi2glsw(1,n))- ...
            (OutboardFuelSpan(n)-wi2gkln(1,n))*wi2gspn(n)/2*tan(deg2rad*wi2glsw(2, ...
            n))))/FuseLength(n);
        % locate the non-dimensional vertical cg of tank 2 cut-out
        OuterCutZCG=(FuseVerticalDiameterAft(n)*(wi2gplc(n)-0.5)+ ...
            WS2NMTX(1)*tan(deg2rad*wi2gdih(1,n))+ ...
            (OutboardFuelSpan(n)-wi2gkln(1,n))*wi2gspn(n)/2*tan(deg2rad*wi2gdih(2, ...
            n)))/FuseVerticalDiameterAft(n);
        % tally the maximum fuel that can be stored in the wings
        uscvole=Tank1Volume+Tank2Volume-OuterCutVolume;
        xcgmas2=(Tank1XCG*Tank1Volume+Tank2XCG*Tank2Volume-OuterCutXCG*OuterCutVolume)/uscvole;% xcg
        %==================================================================
%         ycgmas2=(ycenog1/fuselgt(n)*uscvol1+ycenog2/fuselgt(n)*uscvol2-ycenoge/fuselgt(n)*uscvola)/uscvole;% ycg
        %==================================================================
        zcgmas2=(Tank1ZCG*Tank1Volume+Tank2ZCG*Tank2Volume-OuterCutZCG*OuterCutVolume)/uscvole;% zcg
        
    elseif OutboardFuelSpan(n)>wi2gkln(2,n)
        OuterCutLength=(1-OutboardFuelSpan(n))*wi2gspn(n)/2;% length to cut out from No. 3
        % estimate the equivalent lspard at this locale
        OuterCutChordFrac=(Tank2ChordFrac2-Tank3ChordFrac2)/(wi2gkln(2,n)-1)*(OutboardFuelSpan(n)-wi2gkln(2,n))+ ...
            Tank2ChordFrac2;
        OuterCutThickness=Wing_Thickness_At_Span(OutboardFuelSpan(n)*wi2gspn(n)/2,WS2NMTX,WT2KMTX);% thickness at tank end
        % local chord length at tank end station
        OuterCutChord=Wing_Chord_At_Span(OutboardFuelSpan(n)*wi2gspn(n)/2,WS2NMTX,WC2DROT,wi2gtap,n);
        % predict the tank volume cut-out from No. 3
        [OuterCutVolume,OuterCutYCG]=Available_Volume(OuterCutLength,OuterCutChordFrac,OuterCutThickness,OuterCutChord(n),Tank3ChordFrac2,Tank3Thickness2,Tank3Chord2(n));
        OuterCutVolume=OuterCutVolume*2;
        % locate the non-dimensional longitudinal cg of tank 3 cut-out
        OuterCutFrontSpar=FrontSparPosition(4,n)-2*(FrontSparPosition(4,n)-FrontSparPosition(3,n))/((1- ...
            wi2gkln(2,n))*wi2gspn(n))*OuterCutLength;
        OuterCutRearSpar=RearSparPosition(4,n)-2*(RearSparPosition(4,n)-RearSparPosition(3,n))/((1- ...
            wi2gkln(2,n))*wi2gspn(n))*OuterCutLength;
        OuterCutXCG=(FuseLength(n)*wi2gapx(n)+ ...
            wi2gkln(1,n)*wi2gspn(n)/2*tan(deg2rad*wi2glsw(1,n))+ ...
            wi2gkln(2,n)*wi2gspn(n)/2*tan(deg2rad*wi2glsw(2,n))+ ...
            (OutboardFuelSpan(n)-wi2gkln(2,n))*wi2gspn(n)/2*tan(deg2rad*wi2glsw(3,n))+ ...
            OuterCutChord(n)*(OuterCutRearSpar+OuterCutFrontSpar)/2+ ...
            OuterCutYCG/OuterCutLength*(SparCentroidTip-OuterCutChord(n)/2- ...
            (WS2NMTX(1)-XS2CDWF(n)/2)*tan(deg2rad*wi2glsw(1,n))- ...
            WS2NMTX(2)*tan(deg2rad*wi2glsw(2,n))- ...
            (OutboardFuelSpan(n)-wi2gkln(2,n))*wi2gspn(n)/2*tan(deg2rad*wi2glsw(3, ...
            n))))/FuseLength(n);
        % locate the non-dimensional vertical cg of tank 3 cut-out
        OuterCutZCG=(FuseVerticalDiameterAft(n)*(wi2gplc(n)-0.5)+ ...
            WS2NMTX(1)*tan(deg2rad*wi2gdih(1,n))+ ...
            WS2NMTX(2)*tan(deg2rad*wi2gdih(2,n))+ ...
            (OutboardFuelSpan(n)-wi2gkln(2,n))*wi2gspn(n)/2*tan(deg2rad*wi2gdih(3, ...
            n)))/FuseVerticalDiameterAft(n);
        % tally the maximum fuel that can be stored in the wings
        uscvole=Tank1Volume+Tank2Volume+Tank3Volume-OuterCutVolume;
        xcgmas2=(Tank1XCG*Tank1Volume + Tank2XCG*Tank2Volume + Tank3XCG*Tank3Volume- ...
            OuterCutXCG*OuterCutVolume)/uscvole;% adjusted x cg
        %==================================================================
%         ycgmas2=(ycenog1/fuselgt(n)*uscvol1+ycenog2/fuselgt(n)*uscvol2+ycenog3/fuselgt(n)*uscvol3- ...
%             ycenoge/fuselgt(n)*uscvola)/uscvole;% adjusted y cg
        %==================================================================        
        zcgmas2=(Tank1ZCG*Tank1Volume+Tank2ZCG*Tank2Volume+Tank3ZCG*Tank3Volume- ...
            OuterCutZCG*OuterCutVolume)/uscvole;% adjusted z cg
    end
    %=====
    % intially predicted maximum fuel weight in wing No. 2
    AdjustedWingFuelVolume = AdjustedWingFuelVolume + uscvole*1000;
    AdjustedWingFuelWeight = AdjustedWingFuelVolume*FuelDensity(n);
end

% compute the combined wing 1 and wing 2 non-dimensional centre of gravity
FinalWingFuelXCG = (WingFuelXCG*WingFuelVolume + xcgmas2*uscvole)/(WingFuelVolume + uscvole); % x cg
% ycgwing = (ycgmast*uscvolo + ycgmas2*uscvole)/(uscvolo + uscvole); % y cg
FinalWingFuelYCG = 0.0;
FinalWingFuelZCG = (WingFuelZCG*WingFuelVolume + zcgmas2*uscvole)/(WingFuelVolume + uscvole); % z cg

%==========================================================================
% predict the auxiliary tank volumes

%=====
% first compute the volume existing in the fuselage for potential
% fuel storage

if CabinMaxWidth(n) < 0 || CabinFloorWidth(n) < 0

    if CabinMaxHeight(n) < 0.0001 && FuseVerticalDiameterAft(n) > 0.0001
        if FuseDistortionAft(n) > 0.5
            CabinMaxHeight(n) = FuseDistortionAft(n)*FuseVerticalDiameterAft(n)-0.15;% double-bubble cabin height
        else
            if WingPlacement(n) < 0 || WingPlacement(n) > 1
                CabinMaxHeight(n) = FuseVerticalDiameterAft(n)-0.2;% wingbox does not go through x-section
            else
                if WingPlacement(n) > 0.5
                    % circular x-section cabin height for high wings
                    CabinMaxHeight(n) = FuseVerticalDiameterAft(n)*WingPlacement(n)-WingThickMatrix(2,1)*RefWingChordOrigin(n)/2-0.2;
                else
                    % circular x-section cabin height for low wings
                    CabinMaxHeight(n) = FuseVerticalDiameterAft(n)*(1-WingPlacement(n))-WingThickMatrix(2,1)*RefWingChordOrigin(n)/2-0.2;
                end
            end
        end
    end
    if CabinMaxWidth(n) < 0.0001 && FuseHorizontalDiameterAft(n) > 0.0001
        CabinMaxWidth(n) = FuseHorizontalDiameterAft(n)-0.2;    % predict cabin max width
    end
    if CabinFloorWidth(n) < 0.0001 && FuseVerticalDiameterAft(n) > 0.0001
        if FuseDistortionAft(n) > 0.5
            FloorAngle = atan(2*FuseVerticalDiameterAft(n)*(FuseDistortionAft(n)-0.5)/FuseHorizontalDiameterAft(n))+pi;
            FloorRadius = FuseParamAft(1)+FuseParamAft(2)*sin(FloorAngle)+FuseParamAft(3)*cos(2*FloorAngle);
            CabinFloorWidth(n) = 2*FloorRadius*cos(FloorAngle-pi)-0.2;% double-bubble floor width
        else
            CabinFloorWidth(n) = ((CabinMaxWidth(n)^2)-4*(((FuseVerticalDiameterAft(n)-WingThickMatrix(2,1)*RefWingChordOrigin(n)- ...
                0.2)/2)^2))^0.5;% predict the floor width
        end
    end

end

FuseArea = pi/36*(2*FuseVerticalDiameterAft(n)+FuseHorizontalDiameterAft(n))^2;% entire fuselage xsec area
FloorHeight = CabinMaxHeight(n)+0.1-FuseVerticalDiameterAft(n)/2;
CabinAngle = real(asin((CabinFloorWidth(n)+0.2)/FuseHorizontalDiameterAft(n)));
UnderfloorArea = CabinAngle*(FuseHorizontalDiameterAft(n)^2)/4-(CabinFloorWidth(n)+0.2)*FloorHeight/2;% uflr xsec area


ForeFairingMaxVolume=0.0;
ForeFairingRemovedVolume=0.0;
ForeFairingXCG=0.0;
ForeFairingZCG=0.0;% default no fuel in fwd fairing
FairingThickness = 0;
FairingWidth = 0;
FairingFuelArea = 0;
if (FairingFlushness(n)*WingThickness(1,n)*RefWingChordOrigin(n)/2-WingPlacement(1,n)*FuseVerticalDiameterAft(n)) > 0.0001

    % estimate the amount of fuel to be stored in forward fairing
    FairingThickness = FairingFlushness(n)*WingThickness(1,n)*RefWingChordOrigin(n)/2-WingPlacement(1,n)*FuseVerticalDiameterAft(n);% fairing maximum height
    FairingWidth = FuseWingPosition(n)/2;% maximum horizontal fuselage width
    FairingFuelArea = UnderfloorArea+pi*FairingThickness*FairingWidth/4;
    if FairingTankLength(1,n) > 0.0001
        FairingLength = (1-FairingTankLength(1,n)/100)*FairingChordFractionFore(n)/100*RefWingChordOrigin(n);
        FairingSemiY = (FairingLength/(FairingChordFractionFore(n)/100*RefWingChordOrigin(n))*FairingWidth^2)^0.5;
        FairingSemiZ = (FairingLength/(FairingChordFractionFore(n)/100*RefWingChordOrigin(n))*FairingThickness^2)^0.5;
        ForeFairingRemovedVolume = 0.92*(UnderfloorArea+pi*FairingSemiY*FairingSemiZ/4)*FairingLength;% volume to be removed
        ForeFairingMaxVolume = 0.92*FairingFuelArea*FairingChordFractionFore(n)/100*RefWingChordOrigin(n);% max possible volume
        % horizontal non-dimensional cg location
        ForeFairingXCG = (FuseLength(n)*WingApex(n)+RefWingChordOrigin(n)*FrontSparPosition(1,n)-FairingLength/3)/FuseLength(n);
        ForeFairingZCG = WingPlacement(n)-0.5;% vertical non-dimensional cg location
    end  
end
%=====
% estimate the amount of fuel to be stored in aft fairing
AftFairingMaxVolume=0.0;
AftFairingRemovedVolume=0.0;
AftFairingXCG=0.0;% default no fuel in aft fairing
if (FairingFlushness(n)*WingThickness(1,n)*RefWingChordOrigin(n)/2-WingPlacement(1,n)*FuseVerticalDiameterAft(n)) > 0.0001
    if FairingTankLength(2, n) > 0.0001
        FairingLength = (1-FairingTankLength(2,n)/100)*FairingChordFractionAft(n)/100*RefWingChordOrigin(n);
        FairingSemiY = (FairingLength/(FairingChordFractionAft(n)/100*RefWingChordOrigin(n))*FairingWidth^2)^0.5;
        FairingSemiZ = (FairingLength/(FairingChordFractionAft(n)/100*RefWingChordOrigin(n))*FairingThickness^2)^0.5;
        AftFairingRemovedVolume = 0.92*(UnderfloorArea+pi*FairingSemiY*FairingSemiZ/4)*FairingLength;% volume to be removed
        AftFairingMaxVolume = 0.92*FairingFuelArea*FairingChordFractionAft(n)/100*RefWingChordOrigin(n);% max possible volume
        % horizontal non-dimensional cg location
        AftFairingXCG = (FuseLength(n)*WingApex(n)+RefWingChordOrigin(n)*RearSparPosition(1,n)+FairingLength/3)/FuseLength(n);
    end
end
%=====
% combined centre of gravity locations for conformal fairing tanks only
if CentreTankPortion(n) > 0.0001 || FairingTankLength(1, n) > 0.0001 || FairingTankLength(2, n) > 0.0001
    if (CentralTankVolume+centvo2+ForeFairingMaxVolume-ForeFairingRemovedVolume+ AftFairingMaxVolume-AftFairingRemovedVolume) ~= 0
        FairingXCG = (CentralTankXCG*CentralTankVolume+xcogce2*centvo2+ForeFairingXCG*(ForeFairingMaxVolume-ForeFairingRemovedVolume)+ ...
            AftFairingXCG*(AftFairingMaxVolume-AftFairingRemovedVolume))/(CentralTankVolume+centvo2+ForeFairingMaxVolume-ForeFairingRemovedVolume+ ...
            AftFairingMaxVolume-AftFairingRemovedVolume);% x cg
    else
        FairingXCG = 0;
    end
    FairingYCG = 0.0;
    FairingZCG = ForeFairingZCG;% z cg
end
%=====

% Estimate the amount of fuel to be stored in aft-fuselage tank
AuxiliaryVolume = 0.0;% default no fuel in auxiliary tank
if FuseBladderLength(n) > 0.0001
    AuxiliaryArea = FuseArea - UnderfloorArea;
    AuxiliaryVolume = 0.92*AuxiliaryArea*FuseBladderLength(n);% total volume for fuel
    AuxiliaryXCG = 1-(FuseTailLength(n)+FuseBladderLength(n)/2)/FuseLength(n);% non-dimensional horizontal cg
    AuxiliaryYCG = 0.0;
    AuxiliaryZCG = ((FuseVerticalDiameterAft(n)-FairingThickness)*0.4-FloorHeight)/FuseVerticalDiameterAft(n);% non-dim vertical cg
end

%==========================================================================
% tally all sources for auxiliary fuel storage
FuselageFuelVolume(n) = ForeFairingMaxVolume - ForeFairingRemovedVolume + AftFairingMaxVolume - AftFairingRemovedVolume + AuxiliaryVolume + ...
    IncrementAuxiliaryTank(n)/FuelDensity(n);
FuselageFuelWeight(n) = FuselageFuelVolume(n)*FuelDensity(n);

%==========================================================================
% predict the unusuable fuel if user has not specified it
%

if UnusableFuel(n) < 0.0001
    UnusableFuel(n) = 0.02*AdjustedWingFuelWeight;
    % Commented to extend fuel computations to UAVs
%     if fuelusu(n) < 30
%         fuelusu(n) = 30;% unusuable fuel cannot be less than 30 kg
%     end
end

%==========================================================================
% final adjusted predicted maximum fuel weight in wings
%

FinalWingFuelVolume(n) = AdjustedWingFuelVolume - UnusableFuel(n)/FuelDensity(n);
FinalWingFuelWeight(n) = FinalWingFuelVolume(n)*FuelDensity(n);

%==========================================================================
% Ouput parameters from QFUCALC
aircraft.weight_balance.Fuel.Fuel_in_wing_x_cg = FinalWingFuelXCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_wing_y_cg = FinalWingFuelYCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_wing_z_cg = FinalWingFuelZCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_fairings_x_cg = FairingXCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_fairings_y_cg = FairingYCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_fairings_z_cg = FairingZCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_x_cg = AuxiliaryXCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_y_cg = AuxiliaryYCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_z_cg = AuxiliaryZCG(1, n);

% ****** For Cogs Weight Module *********
global FuelforWingCoGACB; 
global FuelforCenWingCoGACB; 
global FuelforAuxWingCoGACB;
FuelforWingCoGACB=FinalWingFuelWeight(1, n);
FuelforCenWingCoGACB=CentralTankWeight(1, n);
FuelforAuxWingCoGACB=FuselageFuelWeight(1, n);
% ****************************************

aircraft.fuel.max_weight_wing = FinalWingFuelWeight(1, n);
aircraft.fuel.max_vol_wing = FinalWingFuelVolume(1, n);
aircraft.fuel.max_weight_cent_wing_box = CentralTankWeight(1, n);
aircraft.fuel.max_vol_cent_wing_box = CentralTankAdjustedVolume(1, n);
aircraft.fuel.max_weight_aux = FuselageFuelWeight(1, n);
aircraft.fuel.max_vol_aux = FuselageFuelVolume(1, n);

% Overwrite values
aircraft.fuel.box_ea_loc_root  = BoxEA(1);
aircraft.fuel.box_ea_loc_kink1 = BoxEA(2);
aircraft.fuel.box_ea_loc_kink2 = BoxEA(3);
aircraft.fuel.box_ea_loc_tip   = BoxEA(4);

aircraft.fuel.box_semispan_root  = BoxSparOffset(1);
aircraft.fuel.box_semispan_kink1 = BoxSparOffset(2);
aircraft.fuel.box_semispan_kink2 = BoxSparOffset(3);
aircraft.fuel.box_semispan_tip   = BoxSparOffset(4);

aircraft.fuel.Fore_wing_spar_loc_root = FrontSparPosition(1, n);
aircraft.fuel.Fore_wing_spar_loc_kik1 = FrontSparPosition(2, n);
aircraft.fuel.Fore_wing_spar_loc_kin2 = FrontSparPosition(3, n);
aircraft.fuel.Fore_wing_spar_loc_tip  = FrontSparPosition(4, n);

aircraft.fuel.Aft_wing_spar_loc_root = RearSparPosition(1, n);
aircraft.fuel.Aft_wing_spar_loc_kin1 = RearSparPosition(2, n);
aircraft.fuel.Aft_wing_spar_loc_kin2 = RearSparPosition(3, n);
aircraft.fuel.Aft_wing_spar_loc_tip  = RearSparPosition(4, n);

%==========================================================================


%==========================================================================
% Auxiliary functions

function comp2 = lpcomp(lspan, lsp1, lsp2, lsp3, lsp4, kln, spn, xsec, wsp, z)
% compute the equivalent lspard at any station
%

if lspan <= kln(1, z)*spn(z)/2
    % estimate the equivalent lspard at inboard
    comp2 = (lsp1-lsp2)/(xsec(z)/2-wsp(1))*(lspan-xsec(z)/2) + lsp1;
elseif lspan > kln(1, z)*spn(z) && lspan <= kln(2,z)*spn(z)
    % estimate the equivalent lspard at midboard
    comp2 = -(lsp2-lsp3)/wsp(2)*(lspan-wsp(1)) + lsp2;
elseif lspan > kln(2, z)
    % estimate the equivalent lspard at outboard
    comp2 = -(lsp3-lsp4)/wsp(3)*(lspan-wsp(1) + wsp(2)) + lsp3;
end