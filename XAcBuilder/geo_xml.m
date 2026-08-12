%function xout=geo_xml(xin)
function geo_xml

global sinp_geo sout_geo

global qverson
% QCARD began in Apr00, version gamma Dec01
qverson(1,:)='QCARD-MMVI - Feb 06';
% Constants for various properties
global rhosls g deg2rad asls kmfeet kkglbs
global knwlbf knaumm slspres kpressd
asls=340.3;		  % sonic velocity at sea level standard conditions (m/s)
rhosls=1.225;	  % density at sea level standard (kg/cu.m)
g=9.81;			  % acceleration due to gravity (m/s)
slspres=101.325;  % pressure at sea level standard conditions (kPa)
%kcmspd=0.5144;	  % conversion from KTAS to m/s.
deg2rad=2*pi/360;  % conversion from deg. to rad.
kmfeet=0.3048;    % conversion from m to feet
kkglbs=2.2046;    % conversion from kg to lb
knwlbf=4.45;      % conversion from N to lbf
knaumm=1852.0;    % conversion from nm to m
kpressd=6.894757; % conversion from psi to kPa

% Fuselage definition parameters
global FuseVerticalDiameterFore FuseDistortionFore FuseHorizontalDiameterFore OmegaNose PhiNose EpsilonNose NoseLength FuseShiftFore 
global FuseFractionFore FuseLength FuseVerticalDiameterAft FuseDistortionAft FuseHorizontalDiameterAft OmegaTail PhiTail EpsilonTail 
global FuseTailLength
% Sponson definition parameters
global spsnxlc spsnzlc spsnlgt spsnxzs spsnwid 
% Wing definition parameters
global WingConfiguration WingPlacement WingApex WingArea WingAR WingSpan 
global WingKink WingTaper WingThickness WingIncidence WingQCSweep WingLESweep WingDihedral WingletSpan 
global WingletTaper WingletLESweep WingletCantAngle WingletIncidence FlapChord AileronPosition AileronChord AileronSpan 
global SlatChord SlatSpan
% Fairing definition parameters
global FairingChordFractionFore FairingChordFractionAft FairingFlushness
% Wing 2 definition parameters
% PM 13.10: added Winglets for Wing2
global wi2gcfg wi2gplc wi2gapx wi2gare wi2ggar wi2gspn 
global wi2gkln wi2gtap wi2gthk wi2ginc wi2gqsw wi2glsw wi2gdih wle2spn 
global wle2tap wle2lsw wle2vos wle2inc fla2Crd ail2Pos ail2Chr ail2Spa
global  sla2Crd sla2Spa
% Fairing 2 definition parameters
global fa2rfwd fa2raft fa2rovh 
% Horizontal tail definition parameters
global HTailArea HTailAR HTailSpan HTailKink HTailTaper HTailThickness HTailIncidence 
global HTailQCSweep HTailLESweep HTailDihedral EmpennageLayout HTailVerticalLocale HTailApex HTailElevatorChord 
global HTailThicknessMatrix
% Vertical tail definition parameters
global VTailArea VTailAR VTailSpan VTailKink VTailTaper VTailThickness VTailIncidence 
global VTailQCSweep VTailLESweep VTailDihedral VTailVerticalLocale VTailApex RudderChord  
global vtalblt vtalbsl VTailDorsalLocation VTailDorsalSweep vfinvlc vfinhlc vfinvcd vfinvsp 
global vfinvkl vfinvtp vfinvls vfinvdh 
global VTailThicknessMatrix
% Canard definition parameters
global CanardArea CanardAR CanardSpan CanardKink CanardTaper CanardIncidence CanardQCSweep 
global CanardLESweep CanardDihedral CanardVerticalLocale CanardApex CanardElevatorChord CanardThicknessMatrix CanardThickness
% Results from geometry computations
global WingExposedArea ZSERDWF RefWingChordOrigin OriginalFuseWingChord OriginalTipChord 
global ReferenceWingConvention ReferenceWingArea2 RefWingTaper RefWingAR2 RefWingLESweep RefWingQCSweep RefWingHCSweep RefWingMAC 
global MACSpanPos HTailOriginalRootChord RefHTailArea RefHTailTaper 
global RefHTailLESweep RefHTailQCSweep RefHTailHCSweep RefHTailMAC HTailMACSpanPos RefHTailThickness 
global VTailOriginalRootChord RefVTailArea RefVTailTaper RefVTailLESweep RefVTailQCSweep RefVTailHCSweep RefVTailMAC 
global VTailMACSpanPos RefVTailThickness WC2DROT
global CanardOriginalRootChord RefCanardArea RefCanardTaper 
global RefCanardLESweep RefCanardQCSweep RefCanardHCSweep RefCanardMAC CanardMACSpanPos RefCanardThickness
% Engine definition parameters
global EnginesNumber EnginesLayout EnginesType EnginesLocalY EnginesLocalX EnginesLocalZ EnginesToeIn 
global EnginesPitch MaxThrust BypassRatio NacelleType NacelleFineness EngineMaxDiameter FanCowlLength
global PropellerDiameter PN
% Wetted area data
global wingiwt WingWettedArea WingletIncrement WingletWettedArea htaliwt HTailWettedArea vtaliwt VTailWettedArea 
global fuseiwt FuseWettedArea pylniwt PylonWettedArea pwrpiwt PowerplantWettedArea ANCIWET TotalWettedArea 
global dfinrot dchrdbt dchrdb1 dchrdb2 dspnmtx dthkmtx FuseGeometryMatrix CanardWettedArea canriwt
%Fuel tank details
global FrontSparPosition wingsau RearSparPosition FuelTankCutout OutboardFuelSpan UnusableFuel FuelDensity TanksIncrementalWeight 
global FinalWingFuelWeight FinalWingFuelVolume CentreTankPortion IncrementCentreTank CentralTankWeight CentralTankAdjustedVolume FairingTankLength FuseBladderLength 
global IncrementAuxiliaryTanks FuselageFuelWeight FuselageFuelVolume

global CabinMaxHeight CabinMaxWidth cabnlgt CabinFloorWidth BaggageApex BaggageInstallation BaggageVolume BaggageLength

global xcgwing ycgwing zcgwing xcgfair ycgfair zcgfair xcgtaux ycgtaux 
global zcgtaux xcgwi2g ycgwi2g zcgwi2g xcgfa2r ycgfa2r zcgfa2r VortexInducedDragFactor

% For visualisation
% global winxdat wi2xdat htaxdat vtaxdat canxdat FlTEDEF

%%
global FuseParamAft FuseParamFore
global SpanMatrixPartition WS2NMTX WingWeightedTaper WI2WGAR WI2WARE WI2WTAP WI2WQSW WI2WTHB RefWingApex RefWingAR RefWingThickness RefWingAreaForWB
global HTailMomentArm HTailSpanMatrixPartition VTailMomentArm VTailSpanMatrixPartition DorsalFinsWettedArea CabinVolume FuseWingPosition XS2CDWF WingThickMatrix WT2KMTX CanardMomentArm CTALMOA CanardSpanMatrixPartition
global NacelleXLoc NacelleYLoc NacelleZLoc PYLNCLW ChordAtEngine NacelleLength WingLongitudinalLocation WingVerticalLocation WI2GAPX WI2GAPZ HTailLongitudinalLocation HTailVerticalLocation VTailLongitudinalLocation VTailVerticalLocation CNAPEXX CNAPEXZ
global l_central XFAIR ZFAIR l_fore l_aft Xsponson
global aircraft VTailFuseDepth DesignClassification Passengers

%% Inittialize some values
PylonWettedArea=0;
DorsalFinsWettedArea=0;
ycgwing=0;
ycgfair=0;
ycgtaux=0;

% winxdat=0;
% wi2xdat=0;
% htaxdat=0;
% vtaxdat=0;
% canxdat=0;
PYLNCLW=0;

% The control surface deflection should be an user input
% FlTEDEF=[0;0;0];

NacelleXLoc=[0;0]; NacelleYLoc=[0;0]; NacelleZLoc=[0;0];

aircraft=sinp_geo;
n=1;

DesignClassification(n)=aircraft.miscellaneous.Design_classification;

% make variables determining presence of components conformable
% with 'present' parameter
if ~aircraft.Wing1.present
   aircraft.Wing1.Span=0.0;
   aircraft.Wing1.area=0.0;
   aircraft.Wing1.AR=0.0;
else
   if ~aircraft.Wing1.winglet.present
      aircraft.Wing1.winglet.Span=0.0;
   end
   if ~aircraft.Wing1.aileron.present
      aircraft.Wing1.aileron.Span=0.0;
   end
end
if ~aircraft.Wing2.present
   aircraft.Wing2.Span=0.0;
   aircraft.Wing2.area=0.0;
   aircraft.Wing2.AR=0.0;
else
   if ~aircraft.Wing2.winglet.present
      aircraft.Wing2.winglet.Span=0.0;
   end
   if ~aircraft.Wing2.aileron.present
      aircraft.Wing2.aileron.Span=0.0;
   end
end
if ~aircraft.Horizontal_tail.present
   aircraft.Horizontal_tail.Span=0.0;
   aircraft.Horizontal_tail.area=0.0;
   aircraft.Horizontal_tail.AR=0.0;
end
if ~aircraft.Vertical_tail.present
   aircraft.Vertical_tail.Span=0.0;
   aircraft.Vertical_tail.area=0.0;
   aircraft.Vertical_tail.AR=0.0;
end
if ~aircraft.Canard.present
   aircraft.Canard.Span=0.0;
   aircraft.Canard.area=0.0;
   aircraft.Canard.AR=0.0;
end

%% Fuselage inputs
FuseVerticalDiameterFore(1,n)=aircraft.Fuselage.Forefuse_X_sect_vertical_diameter;
FuseDistortionFore(1,n)=aircraft.Fuselage.Forefuse_Xs_distortion_coefficient;
FuseHorizontalDiameterFore(1,n)=aircraft.Fuselage.Forefuse_X_sect_horizontal_diameter;
OmegaNose(1,n)=aircraft.Fuselage.omega_nose;
PhiNose(1,n)=aircraft.Fuselage.phi_nose;
EpsilonNose(1,n)=aircraft.Fuselage.epsilon_nose;
FuseShiftFore(1,n)=aircraft.Fuselage.shift_fore;
FuseFractionFore(1,n)=aircraft.Fuselage.fraction_fore;
FuseLength(1,n)=aircraft.Fuselage.Total_fuselage_length;
FuseVerticalDiameterAft(1,n)=aircraft.Fuselage.Aftfuse_X_sect_vertical_diameter;
FuseDistortionAft(1,n)=aircraft.Fuselage.Aftfuse_Xs_distortion_coefficient;
FuseHorizontalDiameterAft(1,n)=aircraft.Fuselage.Aftfuse_X_sect_horizontal_diameter;
OmegaTail(1,n)=aircraft.Fuselage.omega_tail;
PhiTail(1,n)=aircraft.Fuselage.phi_tail;
EpsilonTail(1,n)=aircraft.Fuselage.epsilon_tail;
NoseLength(1,n)=FuseVerticalDiameterFore(1,n)*EpsilonNose(1,n);
FuseTailLength(1,n)=FuseVerticalDiameterAft(1,n)*EpsilonTail(1,n);
[FuseParamFore(1,1),FuseParamFore(1,3),FuseParamFore(1,2)]=get_fuse_params(FuseHorizontalDiameterFore(1,n),FuseVerticalDiameterFore(1,n),FuseDistortionFore(1,n));
[FuseParamAft(1,1),FuseParamAft(1,3),FuseParamAft(1,2)]=get_fuse_params(FuseHorizontalDiameterAft(1,n),FuseVerticalDiameterAft(1,n),FuseDistortionAft(1,n));

%% Sponson inputs
spsnxlc(1,n)=0;
spsnzlc(1,n)=0;
spsnlgt(1,n)=0;
spsnxzs(1,n)=0;
spsnwid(1,n)=0;

%% Wing 1 inputs
WingConfiguration(1,n)=aircraft.Wing1.configuration;
WingPlacement(1,n)=aircraft.Wing1.placement;
WingApex(1,n)=aircraft.Wing1.apex_locale;
WingArea(1,n)=aircraft.Wing1.area;
WingSpan(1,n)=aircraft.Wing1.Span;
% WingAR(1,n)=aircraft.Wing1.AR;
WingAR(1,n)= AR(aircraft.Wing1.Span, aircraft.Wing1.area);
WingKink(1,n)=aircraft.Wing1.spanwise_kink1;
WingKink(2,n)=aircraft.Wing1.spanwise_kink2;
WingTaper(1,n)=aircraft.Wing1.taper_kink1;
WingTaper(2,n)=aircraft.Wing1.taper_kink2;
WingTaper(3,n)=aircraft.Wing1.taper_tip;
WingIncidence(1,n)=aircraft.Wing1.root_incidence;
WingIncidence(2,n)=aircraft.Wing1.kink1_incidence;
WingIncidence(3,n)=aircraft.Wing1.kink2_incidence;
WingIncidence(4,n)=aircraft.Wing1.tip_incidence;
WingQCSweep(1,n)=aircraft.Wing1.quarter_chord_sweep_inboard;
WingQCSweep(2,n)=aircraft.Wing1.quarter_chord_sweep_midboard;
WingQCSweep(3,n)=aircraft.Wing1.quarter_chord_sweep_outboard;
WingLESweep(1,n)=aircraft.Wing1.LE_sweep_inboard;
WingLESweep(2,n)=aircraft.Wing1.LE_sweep_midboard;
WingLESweep(3,n)=aircraft.Wing1.LE_sweep_outboard;
WingDihedral(1,n)=aircraft.Wing1.dihedral_inboard;
WingDihedral(2,n)=aircraft.Wing1.dihedral_midboard;
WingDihedral(3,n)=aircraft.Wing1.dihedral_outboard;
if aircraft.Wing1.flap.present
    FlapChord(1,n)=aircraft.Wing1.flap.root_chord;
    FlapChord(2,n)=aircraft.Wing1.flap.kink1_chord;
    FlapChord(3,n)=aircraft.Wing1.flap.kink2_chord;
else
    FlapChord(1,n)=0;
    FlapChord(2,n)=0;
    FlapChord(3,n)=0;
end
if aircraft.Wing1.aileron.present
    AileronPosition(1,n)=aircraft.Wing1.aileron.position;
    AileronChord(1,n)=aircraft.Wing1.aileron.chord;
    AileronSpan(1,n)=aircraft.Wing1.aileron.Span;
else
    AileronPosition(1,n)=0;
    AileronChord(1,n)=0;
    AileronSpan(1,n)=0;
end
if aircraft.Wing1.slat.present
    SlatChord(1,n)=aircraft.Wing1.slat.chord;
    SlatSpan(1,n)=aircraft.Wing1.slat.root_position;
    SlatSpan(2,n)=aircraft.Wing1.slat.tip_position;
else
    SlatChord(1,n)=0;
    SlatSpan(1,n)=0;
    SlatSpan(2,n)=0;
end
% WingThickness(1,n)=aircraft.Wing1.thickness_root;
% WingThickness(2,n)=aircraft.Wing1.thickness_kink1;
% WingThickness(3,n)=aircraft.Wing1.thickness_kink2;
% WingThickness(4,n)=aircraft.Wing1.thickness_tip;

WingThickness(1,n)=get_max_thickness(aircraft.Wing1.airfoilRoot);
WingThickness(2,n)=get_max_thickness(aircraft.Wing1.airfoilKink1);
WingThickness(3,n)=get_max_thickness(aircraft.Wing1.airfoilKink2);
WingThickness(4,n)=get_max_thickness(aircraft.Wing1.airfoilTip);


if aircraft.Wing1.winglet.present
    % PM 13.10: winglet
    WingletSpan(1,n)=aircraft.Wing1.winglet.Span;
    WingletTaper(1,n)=aircraft.Wing1.winglet.taper_ratio;
    WingletLESweep(1,n)=aircraft.Wing1.winglet.LE_sweep;
    WingletCantAngle(1,n)=aircraft.Wing1.winglet.Cant_angle;
    WingletIncidence(1,n)=aircraft.Wing1.winglet.root_incidence;
    WingletIncidence(4,n)=aircraft.Wing1.winglet.tip_incidence;
else
    WingletSpan(1,n)=0;
    WingletTaper(1,n)=0;
    WingletLESweep(1,n)=0;
    WingletCantAngle(1,n)=0;
    WingletIncidence(1,n)=0;
    WingletIncidence(4,n)=0;
end

%% Fairing 1 input
if aircraft.Wing1.fairing.present
    FairingChordFractionFore(1,n)=aircraft.Fairing1.Forward_chord_fraction;
    FairingChordFractionAft(1,n)=aircraft.Fairing1.Aft_chord_fraction;
    FairingFlushness(1,n)=aircraft.Fairing1.flushness;
else
    FairingChordFractionFore(1,n)=0;
    FairingChordFractionAft(1,n)=0;
    FairingFlushness(1,n)=0;
end
ReferenceWingConvention(1,n)=1;

%% Wetted areas icrements
fuseiwt(1,n)=0;
wingiwt(1,n)=0;
WingletIncrement(1,n)=0; 
htaliwt(1,n)=0;
vtaliwt(1,n)=0;
canriwt(1,n)=0;
pylniwt(1,n)=0;
pwrpiwt(1,n)=0;
ANCIWET(1,n)=0;

%% Wing 2 inputs
if aircraft.Wing2.present
    % PM 13.10: if area = 0 => no 2nd wing
    wi2gare(1,n)=aircraft.Wing2.area;
    wi2gcfg(1,n)=aircraft.Wing2.configuration;
else
    wi2gare(1,n)=0;
    wi2gcfg(1,n)=0;
end
if (wi2gare(1,n) > 0.001)
    wi2gcfg(1,n)=aircraft.Wing2.configuration;
    wi2gplc(1,n)=aircraft.Wing2.placement;
    % PM 13.10: added changed to Apex_locale to apex_locale
    wi2gapx(1,n)=aircraft.Wing2.apex_locale;
    wi2gare(1,n)=aircraft.Wing2.area;
    wi2gspn(1,n)=aircraft.Wing2.Span;
%     wi2ggar(1,n)=aircraft.Wing2.AR;
    wi2ggar(1,n)=AR(aircraft.Wing2.Span, aircraft.Wing2.area);
    wi2gkln(1,n)=aircraft.Wing2.spanwise_kink1;
    wi2gkln(2,n)=aircraft.Wing2.spanwise_kink2;
    wi2gtap(1,n)=aircraft.Wing2.taper_kink1;
    wi2gtap(2,n)=aircraft.Wing2.taper_kink2;
    wi2gtap(3,n)=aircraft.Wing2.taper_tip;
    wi2ginc(1,n)=aircraft.Wing2.root_incidence;
    wi2ginc(2,n)=aircraft.Wing2.kink1_incidence;
    wi2ginc(3,n)=aircraft.Wing2.kink2_incidence;
    wi2ginc(4,n)=aircraft.Wing2.tip_incidence;
    wi2gqsw(1,n)=aircraft.Wing2.quarter_chord_sweep_inboard;
    wi2gqsw(2,n)=aircraft.Wing2.quarter_chord_sweep_midboard;
    wi2gqsw(3,n)=aircraft.Wing2.quarter_chord_sweep_outboard;
    wi2glsw(1,n)=aircraft.Wing2.LE_sweep_inboard;
    wi2glsw(2,n)=aircraft.Wing2.LE_sweep_midboard;
    wi2glsw(3,n)=aircraft.Wing2.LE_sweep_outboard;
    wi2gdih(1,n)=aircraft.Wing2.dihedral_inboard;
    wi2gdih(2,n)=aircraft.Wing2.dihedral_midboard;
    wi2gdih(3,n)=aircraft.Wing2.dihedral_outboard;
    if aircraft.Wing2.flap.present
        fla2Crd(1,n)=aircraft.Wing2.flap.root_chord;
        fla2Crd(2,n)=aircraft.Wing2.flap.kink1_chord;
        fla2Crd(3,n)=aircraft.Wing2.flap.kink2_chord;
    else
        fla2Crd(1,n)=0;
        fla2Crd(2,n)=0;
        fla2Crd(3,n)=0;
    end
    if aircraft.Wing2.aileron.present
        ail2Pos(1,n)=aircraft.Wing2.aileron.position;
        ail2Chr(1,n)=aircraft.Wing2.aileron.chord;
        ail2Spa(1,n)=aircraft.Wing2.aileron.Span;
    else
        ail2Pos(1,n)=0;
        ail2Chr(1,n)=0;
        ail2Spa(1,n)=0;
    end
    if aircraft.Wing2.slat.present
        sla2Crd(1,n)=aircraft.Wing2.slat.chord;
        sla2Spa(1,n)=aircraft.Wing2.slat.root_position;
        sla2Spa(2,n)=aircraft.Wing2.slat.tip_position;
    else
        sla2Crd(1,n)=0;
        sla2Spa(1,n)=0;
        sla2Spa(2,n)=0;
    end
        % PM 13.10: added thicknesses
%     wi2gthk(1,n)=aircraft.Wing2.thickness_root;
%     wi2gthk(2,n)=aircraft.Wing2.thickness_kink1;
%     wi2gthk(3,n)=aircraft.Wing2.thickness_kink2;
%     wi2gthk(4,n)=aircraft.Wing2.thickness_tip;
    wi2gthk(1,n)=get_max_thickness(aircraft.Wing2.airfoilRoot);
    wi2gthk(2,n)=get_max_thickness(aircraft.Wing2.airfoilKink1);
    wi2gthk(3,n)=get_max_thickness(aircraft.Wing2.airfoilKink2);
    wi2gthk(4,n)=get_max_thickness(aircraft.Wing2.airfoilTip);
    
    if aircraft.Wing2.winglet.present
        % PM 13.10: added Winglet
        wle2spn(1,n)=aircraft.Wing2.winglet.Span;
        wle2tap(1,n)=aircraft.Wing2.winglet.taper_ratio;
        wle2lsw(1,n)=aircraft.Wing2.winglet.LE_sweep;
        wle2vos(1,n)=aircraft.Wing2.winglet.Cant_angle;
        wle2inc(1,n)=aircraft.Wing2.winglet.root_incidence;
        wle2inc(4,n)=aircraft.Wing2.winglet.tip_incidence;
    else
        wle2spn(1,n)=0;
        wle2tap(1,n)=0;
        wle2lsw(1,n)=0;
        wle2vos(1,n)=0;
        wle2inc(1,n)=0;
        wle2inc(4,n)=0;
    end
end

%% Fairing 2 inputs
if aircraft.Fairing2.present
    fa2rfwd(1,n)=aircraft.Fairing2.Forward_chord_fraction;
    fa2raft(1,n)=aircraft.Fairing2.Aft_chord_fraction;
    fa2rovh(1,n)=aircraft.Fairing2.flushness;
else
    fa2rfwd(1,n)=0;
    fa2raft(1,n)=0;
    fa2rovh(1,n)=0;
end

%% Horizontal tail inputs
if aircraft.Horizontal_tail.present
    EmpennageLayout(1,n)=aircraft.Horizontal_tail.empennage_layout;
    HTailArea(1,n)=aircraft.Horizontal_tail.area;
    HTailSpan(1,n)=aircraft.Horizontal_tail.Span;
%     HTailAR(1,n)=aircraft.Horizontal_tail.AR;
    HTailAR(1,n)=AR(HTailSpan(1,n), HTailArea(1,n));
    HTailKink(1,n)=aircraft.Horizontal_tail.spanwise_kink;
    HTailTaper(1,n)=aircraft.Horizontal_tail.taper_kink;
    HTailTaper(3,n)=aircraft.Horizontal_tail.taper_tip;
    HTailIncidence(1,n)=aircraft.Horizontal_tail.root_incidence;
    HTailIncidence(2,n)=aircraft.Horizontal_tail.kink_incidence;
    HTailIncidence(4,n)=aircraft.Horizontal_tail.tip_incidence;
    HTailQCSweep(1,n)=aircraft.Horizontal_tail.quarter_chord_sweep_inboard;
    HTailQCSweep(3,n)=aircraft.Horizontal_tail.quarter_chord_sweep_outboard;
    HTailLESweep(1,n)=aircraft.Horizontal_tail.LE_sweep_inboard;
    HTailLESweep(3,n)=aircraft.Horizontal_tail.LE_sweep_outboard;
    HTailDihedral(1,n)=aircraft.Horizontal_tail.dihedral_inboard;
    HTailDihedral(3,n)=aircraft.Horizontal_tail.dihedral_outboard;
    HTailVerticalLocale(1,n)=aircraft.Horizontal_tail.vertical_locale;
    HTailApex(1,n)=aircraft.Horizontal_tail.apex_locale;
%     HTailThickness(1,n)=aircraft.Horizontal_tail.thickness_root;
%     HTailThickness(2,n)=aircraft.Horizontal_tail.thickness_kink;
%     HTailThickness(4,n)=aircraft.Horizontal_tail.thickness_tip;
    HTailThickness(1,n)=get_max_thickness(aircraft.Horizontal_tail.airfoilRoot);
    HTailThickness(2,n)=get_max_thickness(aircraft.Horizontal_tail.airfoilKink);
    HTailThickness(4,n)=get_max_thickness(aircraft.Horizontal_tail.airfoilTip);

    if aircraft.Horizontal_tail.Elevator.present
        HTailElevatorChord(1,n)=aircraft.Horizontal_tail.Elevator.chord;
        HTailKink(2,n)=aircraft.Horizontal_tail.Elevator.Span;
    else
        HTailElevatorChord(1,n)=0;
        HTailKink(2,n)=0;
    end

    if (HTailKink(1,n)==1)
        HTailIncidence(3,n)=HTailKink(2,n)*HTailIncidence(4,n)+(1-HTailKink(2,n))*HTailIncidence(1,n);
    else
        HTailIncidence(3,n)=(HTailKink(2,n)-HTailKink(1,n))/(1-HTailKink(1,n))*HTailIncidence(4,n)+(1-HTailKink(2,n))/(1-HTailKink(1,n))*HTailIncidence(2,n); % Ghost kink incidence
    end
else
    EmpennageLayout(1,n)=0;
    HTailArea(1,n)=0;
    HTailAR(1,n)=0;
    HTailSpan(1,n)=0;
    HTailKink(1,n)=0;
    HTailTaper(1,n)=0;
    HTailTaper(3,n)=0;
    HTailIncidence(1,n)=0;
    HTailIncidence(2,n)=0;
    HTailIncidence(4,n)=0;
    HTailQCSweep(1,n)=0;
    HTailQCSweep(3,n)=0;
    HTailLESweep(1,n)=0;
    HTailLESweep(3,n)=0;
    HTailDihedral(1,n)=0;
    HTailDihedral(3,n)=0;
    HTailVerticalLocale(1,n)=0;
    HTailApex(1,n)=0;
    HTailThickness(1,n)=0;
    HTailThickness(2,n)=0;
    HTailThickness(4,n)=0;

    HTailElevatorChord(1,n)=0;
    HTailKink(2,n)=0;
end

%% Canard inputs
if aircraft.Canard.present
    CanardArea(1,n)=aircraft.Canard.area;
    CanardSpan(1,n)=aircraft.Canard.Span;
%     CanardAR(1,n)=aircraft.Canard.AR;
    CanardAR(1,n)=AR(CanardSpan(1,n), CanardArea(1,n));
    CanardKink(1,n)=aircraft.Canard.spanwise_kink;
    CanardTaper(1,n)=aircraft.Canard.taper_kink;
    CanardTaper(3,n)=aircraft.Canard.taper_tip;
    CanardIncidence(1,n)=aircraft.Canard.root_incidence;
    CanardIncidence(2,n)=aircraft.Canard.kink_incidence;
    CanardIncidence(4,n)=aircraft.Canard.tip_incidence;
    CanardQCSweep(1,n)=aircraft.Canard.quarter_chord_sweep_inboard;
    CanardQCSweep(3,n)=aircraft.Canard.quarter_chord_sweep_outboard;
    CanardLESweep(1,n)=aircraft.Canard.LE_sweep_inboard;
    CanardLESweep(3,n)=aircraft.Canard.LE_sweep_outboard;
    CanardDihedral(1,n)=aircraft.Canard.dihedral_inboard;
    CanardDihedral(3,n)=aircraft.Canard.dihedral_outboard;
    CanardVerticalLocale(1,n)=aircraft.Canard.vertical_locale;
    CanardApex(1,n)=aircraft.Canard.apex_locale;
%     CanardThickness(1,n)=aircraft.Canard.thickness_root;
%     CanardThickness(2,n)=aircraft.Canard.thickness_kink;
%     CanardThickness(4,n)=aircraft.Canard.thickness_tip;
    CanardThickness(1,n)=get_max_thickness(aircraft.Canard.airfoilRoot);
    CanardThickness(2,n)=get_max_thickness(aircraft.Canard.airfoilKink);
    CanardThickness(4,n)=get_max_thickness(aircraft.Canard.airfoilTip);

    if aircraft.Canard.Elevator.present
        CanardElevatorChord(1,n)=aircraft.Canard.Elevator.chord;
        CanardKink(2,n)=aircraft.Canard.Elevator.Span;
    else
        CanardElevatorChord(1,n)=0;
        CanardKink(2,n)=0;
    end

    if (CanardKink(1,n)==1)
        CanardIncidence(3,n)=CanardKink(2,n)*CanardIncidence(4,n)+(1-CanardKink(2,n))*CanardIncidence(1,n);
    else
        CanardIncidence(3,n)=(CanardKink(2,n)-CanardKink(1,n))/(1-CanardKink(1,n))*CanardIncidence(4,n)+(1-CanardKink(2,n))/(1-CanardKink(1,n))*CanardIncidence(2,n); % Ghost kink incidence
    end
else
    CanardArea(1,n)=0;
    CanardAR(1,n)=0;
    CanardSpan(1,n)=0;
    CanardKink(1,n)=0;
    CanardTaper(1,n)=0;
    CanardTaper(3,n)=0;
    CanardIncidence(1,n)=0;
    CanardIncidence(2,n)=0;
    CanardIncidence(4,n)=0;
    CanardQCSweep(1,n)=0;
    CanardQCSweep(3,n)=0;
    CanardLESweep(1,n)=0;
    CanardLESweep(3,n)=0;
    CanardDihedral(1,n)=0;
    CanardDihedral(3,n)=0;
    CanardVerticalLocale(1,n)=0;
    CanardApex(1,n)=0;
    CanardThickness(1,n)=0;
    CanardThickness(2,n)=0;
    CanardThickness(4,n)=0;

    CanardElevatorChord(1,n)=0;
    CanardKink(2,n)=0;
end

%% Vertical tail inputs
if aircraft.Vertical_tail.present
    VTailArea(1,n)=aircraft.Vertical_tail.area;
    VTailSpan(1,n)=aircraft.Vertical_tail.Span;
%     VTailAR(1,n)=aircraft.Vertical_tail.AR;
    VTailAR(1,n)=AR(VTailSpan(1,n), VTailArea(1,n));
    VTailKink(1,n)=aircraft.Vertical_tail.spanwise_kink;
    VTailTaper(1,n)=aircraft.Vertical_tail.taper_kink;
    VTailTaper(3,n)=aircraft.Vertical_tail.taper_tip;
    VTailQCSweep(1,n)=aircraft.Vertical_tail.quarter_chord_sweep_inboard;
    VTailQCSweep(3,n)=aircraft.Vertical_tail.quarter_chord_sweep_outboard;
    VTailLESweep(1,n)=aircraft.Vertical_tail.LE_sweep_inboard;
    VTailLESweep(3,n)=aircraft.Vertical_tail.LE_sweep_outboard;
    VTailVerticalLocale(1,n)=aircraft.Vertical_tail.vertical_locale;
    VTailApex(1,n)=aircraft.Vertical_tail.apex_locale;
%     VTailThickness(1,n)=aircraft.Vertical_tail.thickness_root;
%     VTailThickness(2,n)=aircraft.Vertical_tail.thickness_kink;
%     VTailThickness(4,n)=aircraft.Vertical_tail.thickness_tip;
    VTailThickness(1,n)=get_max_thickness(aircraft.Vertical_tail.airfoilRoot);
    VTailThickness(2,n)=get_max_thickness(aircraft.Vertical_tail.airfoilKink);
    VTailThickness(4,n)=get_max_thickness(aircraft.Vertical_tail.airfoilTip);
    VTailDorsalLocation(1,n)=aircraft.Vertical_tail.Dorsal_location;
    VTailDorsalSweep(1,n)=aircraft.Vertical_tail.Dorsal_sweep;
    VTailDihedral(1,n)=aircraft.Vertical_tail.dihedral_inboard;
    VTailDihedral(3,n)=aircraft.Vertical_tail.dihedral_outboard;
    VTailIncidence(1,n)=aircraft.Vertical_tail.root_incidence;
    VTailIncidence(2,n)=aircraft.Vertical_tail.kink_incidence;
    VTailIncidence(4,n)=aircraft.Vertical_tail.tip_incidence;
    if aircraft.Vertical_tail.Rudder.present
        RudderChord(1,n)=aircraft.Vertical_tail.Rudder.chord;
        VTailKink(2,n)=aircraft.Vertical_tail.Rudder.Span;
    else
        RudderChord(1,n)=0;
        VTailKink(2,n)=0;
    end
    
    %Bullet fairing inputs
%    vtalblt(1,n)=aircraft.Vertical_tail.Bullet_more_vertical_tip_chord; 	
%    vtalbsl(1,n)=aircraft.Vertical_tail.Bullet_fairing_slenderness; 
    vtalblt(1,n)=0.0;
    vtalbsl(1,n)=0.0;

    if (VTailKink(1,n)==1)
        VTailIncidence(3,n)=VTailKink(2,n)*VTailIncidence(4,n)+(1-VTailKink(2,n))*VTailIncidence(1,n);
    else
        VTailIncidence(3,n)=(VTailKink(2,n)-VTailKink(1,n))/(1-VTailKink(1,n))*VTailIncidence(4,n)+(1-VTailKink(2,n))/(1-VTailKink(1,n))*VTailIncidence(2,n); % Ghost kink incidence
    end
else
    VTailArea(1,n)=0;
    VTailAR(1,n)=0;
    VTailSpan(1,n)=0;
    VTailKink(1,n)=0;
    VTailTaper(1,n)=0;
    VTailTaper(3,n)=0;
    VTailQCSweep(1,n)=0;
    VTailQCSweep(3,n)=0;
    VTailLESweep(1,n)=0;
    VTailLESweep(3,n)=0;
    VTailVerticalLocale(1,n)=0;
    VTailApex(1,n)=0;
    VTailThickness(1,n)=0;
    VTailThickness(2,n)=0;
    VTailThickness(4,n)=0;
    VTailDorsalLocation(1,n)=0;
    VTailDorsalSweep(1,n)=0;
    VTailDihedral(1,n)=0;
    VTailDihedral(3,n)=0;
    VTailIncidence(1,n)=0;
    VTailIncidence(2,n)=0;
    VTailIncidence(4,n)=0;
    RudderChord(1,n)=0;
    VTailKink(2,n)=0;
    vtalblt(1,n)=0; 	
    vtalbsl(1,n)=0;
end

%% Ventral fin inputs
if aircraft.Ventral_fin.present
    vfinvcd(1,n)=aircraft.Ventral_fin.chord_fraction_at_midfuse;
    vfinvsp(1,n)=aircraft.Ventral_fin.Span;
    vfinvkl(2,n)=aircraft.Ventral_fin.spanwise_kink;
    vfinvtp(2,n)=aircraft.Ventral_fin.taper_kink ; 
    vfinvtp(3,n)=aircraft.Ventral_fin.taper_tip; 
    vfinvls(2,n)=aircraft.Ventral_fin.LE_sweep_inboard; 
    vfinvls(3,n)=aircraft.Ventral_fin.LE_sweep_outboard; 
    vfinvdh(2,n)=aircraft.Ventral_fin.cant_inbord; 
    vfinvdh(3,n)=aircraft.Ventral_fin.cant_outboard; 
    vfinvlc(1,n)=aircraft.Ventral_fin.X_locale;
    vfinhlc(1,n)=aircraft.Ventral_fin.Z_locale;
else
    vfinvcd(1,n)=0;
    vfinvsp(1,n)=0;
    vfinvkl(2,n)=0;
    vfinvtp(2,n)=0; 
    vfinvtp(3,n)=0; 
    vfinvls(2,n)=0; 
    vfinvls(3,n)=0; 
    vfinvdh(2,n)=0; 
    vfinvdh(3,n)=0; 
    vfinvlc(1,n)=0;
    vfinhlc(1,n)=0;
end

PN=0;
%% Main Engines inputs
if aircraft.Engines1.present
    EnginesNumber(1,n)=aircraft.Engines1.Number_of_engines;
    EnginesLayout(1,n)=aircraft.Engines1.Layout_and_config;
    EnginesType(1,n)=aircraft.Engines1.Propulsion_type;
    EnginesLocalY(1,n)=aircraft.Engines1.Y_locale;
    EnginesLocalX(1,n)=aircraft.Engines1.X_locale;
    EnginesLocalZ(1,n)=aircraft.Engines1.Z_locale;
    EnginesToeIn(1,n)=aircraft.Engines1.toe_in;
    EnginesPitch(1,n)=aircraft.Engines1.pitch;
    NacelleType(1,n)=aircraft.Engines1.Nacelle_body_type;
    FanCowlLength(1,n)=aircraft.Engines1.Fan_cowl_length_ratio;
    NacelleFineness(1,n)=aircraft.Engines1.fineness_ratio;
    EngineMaxDiameter(1,n)=aircraft.Engines1.d_max;
    PropellerDiameter(1,n)=aircraft.Engines1.Propeller_diameter;
    MaxThrust(1,n)=aircraft.Engines1.Max_thrust;
    BypassRatio(1,n)=aircraft.Engines1.Bypass_ratio_to_emulate;
    PN=1;
else
    EnginesNumber(1,n)=0;
    EnginesLayout(1,n)=0;
    EnginesType(1,n)=0;
    EnginesLocalY(1,n)=0;
    EnginesLocalX(1,n)=0;
    EnginesLocalZ(1,n)=0;
    EnginesToeIn(1,n)=0;
    EnginesPitch(1,n)=0;
    NacelleType(1,n)=0;
    FanCowlLength(1,n)=0;
    NacelleFineness(1,n)=0;
    EngineMaxDiameter(1,n)=0;
    PropellerDiameter(1,n)=0;
    MaxThrust(1,n)=0;
    BypassRatio(1,n)=0;
end

%% Secondary engines inputs
if aircraft.Engines2.present
    EnginesNumber(2,n)=aircraft.Engines2.Number_of_engines;
    EnginesLayout(2,n)=aircraft.Engines2.Layout_and_config;
    EnginesType(2,n)=aircraft.Engines2.Propulsion_type;
    EnginesLocalY(2,n)=aircraft.Engines2.Y_locale;
    EnginesLocalX(2,n)=aircraft.Engines2.X_locale;
    EnginesLocalZ(2,n)=aircraft.Engines2.Z_locale;
    EnginesToeIn(2,n)=aircraft.Engines2.toe_in;
    EnginesPitch(2,n)=aircraft.Engines2.pitch;
    NacelleType(2,n)=aircraft.Engines2.Nacelle_body_type;
    NacelleFineness(2,n)=aircraft.Engines2.fineness_ratio;
    FanCowlLength(2,n)=aircraft.Engines2.Fan_cowl_length_ratio;
    EngineMaxDiameter(2,n)=aircraft.Engines2.d_max;
    PropellerDiameter(2,n)=aircraft.Engines2.Propeller_diameter;
    MaxThrust(2,n)=aircraft.Engines2.Max_thrust;
    BypassRatio(2,n)=aircraft.Engines2.Bypass_ratio_to_emulate;
    PN=2;
else
    EnginesNumber(2,n)=0;
    EnginesLayout(2,n)=0;
    EnginesType(2,n)=0;
    EnginesLocalY(2,n)=0;
    EnginesLocalX(2,n)=0;
    EnginesLocalZ(2,n)=0;
    EnginesToeIn(2,n)=0;
    EnginesPitch(2,n)=0;
    NacelleType(2,n)=0;
    NacelleFineness(2,n)=0;
    FanCowlLength(2,n)=0;
    EngineMaxDiameter(2,n)=0;
    PropellerDiameter(2,n)=0;
    MaxThrust(2,n)=0;
    BypassRatio(2,n)=0;
end

%% Fuel inputs

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

%wingsau(1,n)=aircraft.fuel.Aux_wing_spar_loc_root;
FuelTankCutout(1,n)=aircraft.fuel.Wing_fuel_tank_cutout_opt;
OutboardFuelSpan(1,n)=aircraft.fuel.Outboard_fuel_tank_span;
UnusableFuel(1,n)=aircraft.fuel.Unusable_fuel_option;
FuelDensity(1,n)=aircraft.fuel.Assumed_fuel_density ;
TanksIncrementalWeight(1,n)=aircraft.fuel.Incr_weight_for_wing_tanks;
CentreTankPortion(1,n)=aircraft.fuel.Centre_tank_portion_used;
IncrementCentreTank(1,n)=aircraft.fuel.Increment_for_centre_tank;
FairingTankLength(1,n)=aircraft.fuel.Fore_fairing_tank_length;
FairingTankLength(2,n)=aircraft.fuel.Aft_fairing_tank_length;
FuseBladderLength(1,n)=aircraft.fuel.Aft_fuse_bladder_length;
IncrementAuxiliaryTanks(1,n)=aircraft.fuel.Increment_for_aux_tanks;

%% Baggage and cabin input

BaggageInstallation(1,n)=aircraft.Baggage.installation_type;
BaggageVolume(1,n)=aircraft.Baggage.gross_volume;

BaggageLength(1,n)=aircraft.Baggage.Baggage_combined_length; 
BaggageApex(1,n)=aircraft.Baggage.Baggage_apex_per_fuselgt;
cabnlgt(1,n)=aircraft.cabin.Cabin_length_to_aft_cab; 
CabinMaxHeight(1,n)=aircraft.cabin.Cabin_max_internal_height;
CabinMaxWidth(1,n)=aircraft.cabin.Cabin_max_internal_width;
CabinFloorWidth(1,n)=aircraft.cabin.Cabin_floor_width;
CabinVolume(1,n)=aircraft.cabin.Cabin_volume;

%% Additional
Passengers(n)=aircraft.cabin.Passenger_accomodation;

%% Execute the geometry routines
%% Locations

qgeotry('geom1',n);
qgeotry('ccabn',n);
Abs_locations;
qwetted(n);
% removed by Martin Lahuta
%qfucalc(n);

%% Add the computed or recomputed data to the structure containing aircraft
% data

%% Fuselage
aircraft.Fuselage.present = 1;

aircraft.Fuselage.Nose_length=NoseLength(1,n);
aircraft.Fuselage.Tail_length=FuseTailLength(1,n);
%
aircraft.Fuselage.a0_fore=FuseParamFore(1,1);
aircraft.Fuselage.a1_fore=FuseParamFore(1,2);
aircraft.Fuselage.b1_fore=FuseParamFore(1,3);
%
% aircraft.Fuselage.a0_nose=FuseParamFore(1,1);
% aircraft.Fuselage.a1_nose=FuseParamFore(1,3);
% aircraft.Fuselage.b1_nose=FuseParamFore(1,2);
%
aircraft.Fuselage.a0_aft=FuseParamAft(1,1);
aircraft.Fuselage.a1_aft=FuseParamAft(1,2);
aircraft.Fuselage.b1_aft=FuseParamAft(1,3);
%
% aircraft.Fuselage.a0_tail=FuseParamAft(1,1);
% aircraft.Fuselage.a1_tail=FuseParamAft(1,3);
% aircraft.Fuselage.b1_tail=FuseParamAft(1,2);

aircraft.Fuselage.X_sect_chord_at_fuse_wing=FuseWingPosition(1,n);
% aircraft.Fuselage.fraction_fore=FuseFractionFore(1,n);
aircraft.Fuselage.geometry_matrix(1:6,1:4)=FuseGeometryMatrix;
aircraft.Fuselage.depth_fuse_vtail=VTailFuseDepth(1,n);

%% Wing 1
% aircraft.Wing1.configuration    =   WingConfiguration(1,n);
% aircraft.Wing1.present          =   1;
% aircarft.Wing1.winglet.present  =   0;
% aircraft.Wing1.aileron.present  =   0;
% aircraft.Wing1.slat.present     =   0;
% aircraft.Wing1.flap.present     =   0;
% aircarft.Fairing1.present       =   0;
% aircraft.Wing2.present          =   0;
% aircarft.Wing2.winglet.present  =   0;
% aircraft.Wing2.aileron.present  =   0;
% aircraft.Wing2.slat.present     =   0;
% aircraft.Wing2.flap.present     =   0;
% aircraft.Fairing2.present       =   0;
% aircarft.Horizontal_tail.present=   0;
% aircarft.Vertical_tail.present  =   0;
% aircraft.Engines1.present       =   0;
% aircraft.Engines2.present       =   0;
% aircraft.Ventral_fin.present    =   0;
% aircraft.Horizontal_tail.Elevator.present = 1;
% aircraft.Vertical_tail.Rudder.present = 1;

% if WingletSpan(1,n) > 0.001
%     aircraft.Wing1.winglet.present = 1;
% end
% if AileronChord(1,n) > 0.001
%     aircraft.Wing1.aileron.present = 1;
% end
% if SlatChord(1,n) > 0.001
%     aircraft.Wing1.slat.present = 1;
% end
% if FlapChord(1,n) > 0.001 || FlapChord(2,n) > 0.001 || FlapChord(3,n) > 0.001
%     aircraft.Wing1.flap.present = 1;
% end

aircraft.Wing1.AR=WingAR(1,n);
% aircraft.Wing1.Span=WingSpan(1,n);
% aircraft.Wing1.area=WingArea(1,n);
aircraft.Wing1.quarter_chord_sweep_inboard=WingQCSweep(1,n);
aircraft.Wing1.quarter_chord_sweep_midboard=WingQCSweep(2,n);
aircraft.Wing1.quarter_chord_sweep_outboard=WingQCSweep(3,n);
% aircraft.Wing1.LE_sweep_inboard=WingLESweep(1,n);
% aircraft.Wing1.LE_sweep_midboard=WingLESweep(2,n);
% aircraft.Wing1.LE_sweep_outboard=WingLESweep(3,n);
aircraft.Wing1.Span_matrix_partition_in_mid_outboard=SpanMatrixPartition(1,1:3)';
aircraft.Wing1.Weighted_taper_ratio=WingWeightedTaper(1,n);
aircraft.Wing1.longitudinal_location=WingLongitudinalLocation;
aircraft.Wing1.vertical_location=WingVerticalLocation;
aircraft.Wing1.Root_Airfoil=wingAirfoilSpline(1,:);
aircraft.Wing1.Kink1_Airfoil=wingAirfoilSpline(2,:);
aircraft.Wing1.Kink2_Airfoil=wingAirfoilSpline(3,:);
aircraft.Wing1.Tip_Airfoil=wingAirfoilSpline(4,:);
aircraft.Wing1.thickness_root=WingThickness(1,n);
aircraft.Wing1.thickness_kink1=WingThickness(2,n);
aircraft.Wing1.thickness_kink2=WingThickness(3,n);
aircraft.Wing1.thickness_tip=WingThickness(4,n);
aircraft.Wing1.thickness_coefs_matrix(1:2,1:3)=WingThickMatrix;
% aircraft.Wing1.spanwise_kink1=WingKink(1,n);
% aircraft.Wing1.spanwise_kink2=WingKink(2,n);
% aircraft.Wing1.taper_kink1=WingTaper(1,n);
% aircraft.Wing1.taper_kink2=WingTaper(2,n);
% aircraft.Wing1.taper_tip=WingTaper(3,n);
aircraft.Wing1.Original_estimated_fuse_wing_chrd=OriginalFuseWingChord(1,n);	
aircraft.Wing1.Original_planform_tip_chord=OriginalTipChord(1,n);
aircraft.Wing1.Fuse_wing_junct_BL_locale=ZSERDWF(1,n);
aircraft.Wing1.Total_exposed_area=WingExposedArea(1,n);
% aircraft.Wing1.root_incidence=WingIncidence(1,n);
% aircraft.Wing1.kink1_incidence=WingIncidence(2,n);
% aircraft.Wing1.kink2_incidence=WingIncidence(3,n);
% aircraft.Wing1.tip_incidence=WingIncidence(4,n);
% aircraft.Wing1.winglet.root_incidence=WingletIncidence(1,n);
% aircraft.Wing1.winglet.tip_incidence=WingletIncidence(3,n);
if ~isempty(VortexInducedDragFactor)
    aircraft.Wing1.Fractional_change_vortex_induced_drag_factor=VortexInducedDragFactor;
end
%% Fairing 1
% if FairingFlushness(n)>0.001
%     aircarft.Fairing1.present       =   1.0;
%     aircraft.Fairing1.l_central=l_central(1,n);
%     aircraft.Fairing1.width=width(1,n);
%     aircraft.Fairing1.thickness=thickness(1,n);
%     aircraft.Fairing1.longitudinal_location=XFAIR(1,n);
%     aircraft.Fairing1.vertical_location=ZFAIR(1,n);
%     aircraft.Fairing1.l_fore=l_fore(1,n);
%     aircraft.Fairing1.l_aft=l_aft(1,n);
% end

if spsnxlc(n)>0.001
    aircraft.sponson.longitudinal_location=Xsponson(1,n);
    aircraft.sponson.vertical_location=Xsponson(1,n);
end

%% Wing 2
%Give a default value to the area of wing 2 which will be needed in W&B
aircraft.Wing2.Weighted_reference_wing_area=0;
aircraft.Wing2.Weighted_reference_aspect_ratio=0;
aircraft.Wing2.Weighted_reference_wing_area=0;
aircraft.Wing2.Weighted_taper_ratio=0;
aircraft.Wing2.Reference_quarter_chord_sweep=0;
aircraft.Wing2.Wing_mean_thickness=0;
if aircraft.Wing2.present
%    aircraft.Wing2.present          =   1.0;
%    aircarft.Wing2.winglet.present  =   0.0;
%    aircraft.Wing2.aileron.present  =   0.0;
%    aircraft.Wing2.slat.present     =   0.0;
%    aircraft.Wing2.flap.present     =   0.0;
   aircraft.Wing2.AR=wi2ggar(1,n);
%    aircraft.Wing2.Span=wi2gspn(1,n);
%    aircraft.Wing2.area=wi2gare(1,n);
    aircraft.Wing2.quarter_chord_sweep_inboard=wi2gqsw(1,n);
    aircraft.Wing2.quarter_chord_sweep_midboard=wi2gqsw(2,n);
    aircraft.Wing2.quarter_chord_sweep_outboard=wi2gqsw(3,n);
%    aircraft.Wing2.LE_sweep_inboard=wi2glsw(1,n);
%    aircraft.Wing2.LE_sweep_midboard=wi2glsw(2,n);
%    aircraft.Wing2.LE_sweep_outboard=wi2glsw(3,n);
    aircraft.Wing2.Weighted_reference_aspect_ratio=WI2WGAR(1,n);
    aircraft.Wing2.Weighted_reference_wing_area=WI2WARE(1,n);
    aircraft.Wing2.Weighted_taper_ratio=WI2WTAP(1,n); 
    aircraft.Wing2.Reference_quarter_chord_sweep=WI2WQSW(1,n);
    aircraft.Wing2.Wing_mean_thickness=WI2WTHB(1,n);
    aircraft.Wing2.longitudinal_location=WI2GAPX;
    aircraft.Wing2.vertical_location=WI2GAPZ;
    aircraft.Wing2.Span_matrix_partition_in_mid_outboard=WS2NMTX(1,1:3)';
    aircraft.Wing2.thickness_root=wi2gthk(1,n);
    aircraft.Wing2.thickness_kink1=wi2gthk(2,n);
    aircraft.Wing2.thickness_kink2=wi2gthk(3,n);
    aircraft.Wing2.thickness_tip=wi2gthk(4,n);
    aircraft.Wing2.thickness_coefs_matrix(1:2,1:3)=WT2KMTX;
    aircraft.Wing2.Root_Airfoil=wi2gAirfoilSpline(1,:);
    aircraft.Wing2.Kink1_Airfoil=wi2gAirfoilSpline(2,:);
    aircraft.Wing2.Kink2_Airfoil=wi2gAirfoilSpline(3,:);
    aircraft.Wing2.Tip_Airfoil=wi2gAirfoilSpline(4,:);
%    aircraft.Wing2.spanwise_kink1=wi2gkln(1,n);
%    aircraft.Wing2.spanwise_kink2=wi2gkln(2,n);
%    aircraft.Wing2.taper_kink1=wi2gtap(1,n);
%    aircraft.Wing2.taper_kink2=wi2gtap(2,n);
%    aircraft.Wing2.taper_tip=wi2gtap(3,n);
%    aircraft.Wing2.root_incidence=wi2ginc(1,n);
%    aircraft.Wing2.kink1_incidence=wi2ginc(2,n);
%    aircraft.Wing2.kink2_incidence=wi2ginc(3,n);
%    aircraft.Wing2.tip_incidence=wi2ginc(4,n);
%    aircraft.Wing2.winglet.root_incidence=wle2inc(1,n);
%    aircraft.Wing2.winglet.tip_incidence=wle2inc(3,n);
    
%    if wle2spn(1,n) > 0.001
%        aircraft.Wing1.winglet.present = 1;
%    end
%    if ail2Chr(1,n) > 0.001
%        aircraft.Wing2.aileron.present = 1;
%    end
%    if sla2Crd(1,n) > 0.001
%        aircraft.Wing2.slat.present = 1;
%    end
%    if fla2Crd(1,n) > 0.001 || fla2Crd(2,n) > 0.001 || fla2Crd(3,n) > 0.001
%        aircraft.Wing2.flap.present = 1;
%    end
    
    aircraft.Reference_wing2.Orig_root_chrd_at_ac_CL=WC2DROT(1,n);
    
    aircraft.Fuselage.X_sect_chord_at_fuse_wing2(1,n)=XS2CDWF(1,n);
    
    % PM 14.10: added if fa2rovh(n)>0.001
%    if fa2rovh(n)>0.001
%        aircarft.Fairing1.present       =      1.0;
%        aircraft.Fairing2.l_central=l_central(2,n);
%        aircraft.Fairing2.width=width(2,n);
%        aircraft.Fairing2.thickness=thickness(2,n);
%        aircraft.Fairing2.longitudinal_location=XFAIR(2,n);
%        aircraft.Fairing2.vertical_location=ZFAIR(2,n);
%        aircraft.Fairing2.l_fore=l_fore(2,n);
%        aircraft.Fairing2.l_aft=l_aft(2,n);
%    end
end

%% Reference wing
aircraft.Reference_wing.taper_ratio=RefWingTaper(1,n);
aircraft.Reference_wing.planform_AR=RefWingAR2(1,n);
% aircraft.Refererence_wing.mean_thickness=RefWingThickness(1,n);
aircraft.Reference_wing.Weighted_area=ReferenceWingArea2(1,n);
aircraft.Reference_wing.LE_sweep=RefWingLESweep(1,n);
aircraft.Reference_wing.MAC=RefWingMAC(1,n);
aircraft.Reference_wing.relative_apex=RefWingApex(1,n);
aircraft.Reference_wing.Orig_root_chrd_at_ac_CL=RefWingChordOrigin(1,n);	
aircraft.Reference_wing.Half_chord_sweep=RefWingHCSweep(1,n);
aircraft.Reference_wing.Quarter_chord_sweep=RefWingQCSweep(1,n);
aircraft.Reference_wing.non_dim_MAC_y_bar=MACSpanPos(1,n);
aircraft.Reference_wing.Weighted_aspect_ratio=RefWingAR(1,n);
aircraft.Reference_wing.mean_thickness=RefWingThickness(1,n);
aircraft.Reference_wing.Wing_area_for_weight_balance_analysis=RefWingAreaForWB(1,n);

%% Horizontal tail

% PM 13.10: HTailArea(n) => HTailArea(1,n)
if HTailArea(1,n)>0.0001
%    aircarft.Horizontal_tail.present=   1.0;
%    aircraft.Horizontal_tail.area=HTailArea(1,n);
   aircraft.Horizontal_tail.AR=HTailAR(1,n);
%    aircraft.Horizontal_tail.Span=HTailSpan(1,n);
%    aircraft.Horizontal_tail.spanwise_kink=HTailKink(1,n);
%    aircraft.Horizontal_tail.taper_kink=HTailTaper(1,n);
%    aircraft.Horizontal_tail.taper_tip=HTailTaper(3,n);
    aircraft.Horizontal_tail.quarter_chord_sweep_inboard=HTailQCSweep(1,n);
    aircraft.Horizontal_tail.quarter_chord_sweep_outboard=HTailQCSweep(3,n);
%    aircraft.Horizontal_tail.LE_sweep_inboard=HTailLESweep(1,n);
%    aircraft.Horizontal_tail.LE_sweep_outboard=HTailLESweep(3,n);
    aircraft.Horizontal_tail.original_root_chord=HTailOriginalRootChord(1,n);
    aircraft.Horizontal_tail.reference_wing_area =RefHTailArea(1,n);
    aircraft.Horizontal_tail.reference_wing_taper_ratio=RefHTailTaper(1,n);
    aircraft.Horizontal_tail.reference_wing_LE_chord_sweep=RefHTailLESweep(1,n);
    aircraft.Horizontal_tail.reference_wing_quarter_chord_sweep=RefHTailQCSweep(1,n);
    aircraft.Horizontal_tail.reference_wing_half_chord_sweep=RefHTailHCSweep(1,n);
    aircraft.Horizontal_tail.reference_wing_MAC=RefHTailMAC(1,n);
    aircraft.Horizontal_tail.reference_wing_Y_bar_non_dim=HTailMACSpanPos(1,n);
    aircraft.Horizontal_tail.thickness_root=HTailThickness(1,n);
    aircraft.Horizontal_tail.thickness_kink=HTailThickness(2,n);
    aircraft.Horizontal_tail.thickness_tip=HTailThickness(4,n);
    aircraft.Horizontal_tail.reference_wing_mean.thickness=RefHTailThickness(1,n);
    aircraft.Horizontal_tail.Moment_arm_to_HT=HTailMomentArm(1,n);
    aircraft.Horizontal_tail.Span_matrix_partition_in_mid_outboard=HTailSpanMatrixPartition(1,1:3)';
    aircraft.Horizontal_tail.longitudinal_location=HTailLongitudinalLocation;
    aircraft.Horizontal_tail.vertical_location=HTailVerticalLocation;
    
    aircraft.Horizontal_tail.thickness_coefs_matrix(1:2,1:3)=HTailThicknessMatrix;
%    aircraft.Horizontal_tail.apex_locale=HTailLongitudinalLocation/FuseLength(1,n);
%    aircraft.Horizontal_tail.vertical_locale=HTailVerticalLocation/FuseVerticalDiameterAft(n);
    aircraft.Horizontal_tail.root_incidence=HTailIncidence(1,n);
    aircraft.Horizontal_tail.kink_incidence=HTailIncidence(2,n);
    aircraft.Horizontal_tail.tip_incidence=HTailIncidence(4,n);
    aircraft.Horizontal_tail.Root_Airfoil=HTAirfoilSpline(1,:);
    aircraft.Horizontal_tail.Kink_Airfoil=HTAirfoilSpline(2,:);
    aircraft.Horizontal_tail.Tip_Airfoil=HTAirfoilSpline(4,:);
    
    if HTailElevatorChord(1,n) > 0.001
        aircraft.Horizontal_tail.Elevator.present = 1;
    end
end

%% Vertical tail

% PM 13.10: HTailArea(n) => HTailArea(1,n)
if VTailArea(1,n)>0.0001
%    aircarft.aircarft.Vertical_tail.present   =   1.0;
%    aircraft.Vertical_tail.area=VTailArea(1,n);
   aircraft.Vertical_tail.AR=VTailAR(1,n);
%    aircraft.Vertical_tail.Span=VTailSpan(1,n);
%    aircraft.Vertical_tail.spanwise_kink=VTailKink(1,n);  
%    aircraft.Vertical_tail.taper_kink=VTailTaper(1,n);
%    aircraft.Vertical_tail.taper_tip=VTailTaper(3,n);
    aircraft.Vertical_tail.quarter_chord_sweep_inboard=VTailQCSweep(1,n);
    aircraft.Vertical_tail.quarter_chord_sweep_outboard=VTailQCSweep(3,n);
%    aircraft.Vertical_tail.LE_sweep_inboard=VTailLESweep(1,n);
%    aircraft.Vertical_tail.LE_sweep_outboard=VTailLESweep(3,n);
    aircraft.Vertical_tail.original_root_chord=VTailOriginalRootChord(1,n);
    aircraft.Vertical_tail.reference_wing_area=RefVTailArea(1,n);
    aircraft.Vertical_tail.reference_wing_taper_ratio=RefVTailTaper(1,n);
    aircraft.Vertical_tail.reference_wing_LE_sweep=RefVTailLESweep(1,n);
    aircraft.Vertical_tail.reference_wing_quarter_chord_sweep=RefVTailQCSweep(1,n);
    aircraft.Vertical_tail.reference_wing_Half_chord_sweep=RefVTailHCSweep(1,n);
    aircraft.Vertical_tail.reference_wing_MAC=RefVTailMAC(1,n);
    aircraft.Vertical_tail.reference_Y_bar_non_dim=VTailMACSpanPos(1,n);
    aircraft.Vertical_tail.reference_wing_mean_thickness=RefVTailThickness(1,n);
    aircraft.Vertical_tail.Moment_arm_to_VT=VTailMomentArm(1,n);
    aircraft.Vertical_tail.Span_matrix_partition_in_mid_outboard=VTailSpanMatrixPartition(1,1:3)';
    aircraft.Vertical_tail.longitudinal_location=VTailLongitudinalLocation;
    aircraft.Vertical_tail.vertical_location=VTailVerticalLocation;
    aircraft.Vertical_tail.thickness_root=VTailThickness(1,n);
    aircraft.Vertical_tail.thickness_kink=VTailThickness(2,n);
    aircraft.Vertical_tail.thickness_tip=VTailThickness(4,n);
    aircraft.Vertical_tail.thickness_coefs_matrix(1:2,1:3)=VTailThicknessMatrix;
%    aircraft.Vertical_tail.root_incidence=VTailIncidence(1,n);
%    aircraft.Vertical_tail.kink_incidence=VTailIncidence(2,n);
%    aircraft.Vertical_tail.tip_incidence=VTailIncidence(4,n);
    aircraft.Vertical_tail.Root_Airfoil=VTAirfoilSpline(1,:);
    aircraft.Vertical_tail.Kink_Airfoil=VTAirfoilSpline(2,:);
    aircraft.Vertical_tail.Tip_Airfoil=VTAirfoilSpline(4,:);
    
%    if RudderChord(1,n) > 0.001
%        aircraft.Vertical_tail.Rudder.present = 1;
%    end
end

%% Canard
if aircraft.Canard.present
    aircraft.Canard.AR=CanardAR(1,n);
    aircraft.Canard.quarter_chord_sweep_inboard=CanardQCSweep(1,n);
    aircraft.Canard.quarter_chord_sweep_outboard=CanardQCSweep(3,n);
%    aircraft.Canard.LE_sweep_inboard=CanardLESweep(1,n);
%    aircraft.Canard.LE_sweep_outboard=CanardLESweep(3,n);
    aircraft.Canard.original_root_chord=CanardOriginalRootChord(1,n);
    aircraft.Canard.reference_wing_area =RefCanardArea(1,n);
    aircraft.Canard.reference_wing_taper_ratio=RefCanardTaper(1,n);
    aircraft.Canard.reference_wing_LE_chord_sweep=RefCanardLESweep(1,n);
    aircraft.Canard.reference_wing_quarter_chord_sweep=RefCanardQCSweep(1,n);
    aircraft.Canard.reference_wing_half_chord_sweep=RefCanardHCSweep(1,n);
    aircraft.Canard.reference_wing_MAC=RefCanardMAC(1,n);
    aircraft.Canard.reference_wing_Y_bar_non_dim=CanardMACSpanPos(1,n);
    aircraft.Canard.reference_wing_mean.thickness=RefCanardThickness(1,n);
    aircraft.Canard.Moment_arm_to_CA=CanardMomentArm(1,n);
    aircraft.Canard.Span_matrix_partition_in_mid_outboard=CanardSpanMatrixPartition(1,1:3)';
    aircraft.Canard.thickness_root=CanardThickness(1,n);
    aircraft.Canard.thickness_kink=CanardThickness(2,n);
    aircraft.Canard.thickness_tip=CanardThickness(4,n);
    aircraft.Canard.thickness_coefs_matrix(1:2,1:3)=CanardThicknessMatrix;
    aircraft.Canard.Root_Airfoil=CNAirfoilSpline(1,:);
    aircraft.Canard.Kink_Airfoil=CNAirfoilSpline(2,:);
    aircraft.Canard.Tip_Airfoil=CNAirfoilSpline(4,:);
    
%    if CanardElevatorChord(1,n) > 0.001
%        aircraft.Canard.Elevator.present = 1;
%    end
end

%% Other components that might be present
%if vfinvsp(1,n) > 0.001
%    aircraft.Vertical_fin.present = 1;
%end
%if EnginesNumber(1,n) > 0.001
%    aircraft.Engines1.present = 1;
%end
%if EnginesNumber(2,n) > 0.001
%    aircraft.Engines2.present = 1;
%end

%% added items

if VTailDorsalLocation>0.001
  aircraft.fins.final_dorsal_root_chord=dfinrot(1,n);
  aircraft.fins.local_dorsal_chord_tip=dchrdbt(1,n);
  aircraft.fins.local_dorsal_chord1=dchrdb1(1,n);
  aircraft.fins.local_dorsal_chord2=dchrdb2(1,n);
  aircraft.fins.dorsal_span_matrix=dspnmtx(1:3);
  aircraft.fins.dorsal_thickness_matrix=dthkmtx;
end

%%Fuel

% commented out by Martin Lahuta
%aircraft.fuel.max_weight_wing=FinalWingFuelWeight(1,n);
%aircraft.fuel.max_vol_wing=FinalWingFuelVolume(1,n);
%aircraft.fuel.max_weight_cent_wing_box=CentralTankWeight(1,n);
%aircraft.fuel.max_vol_cent_wing_box=CentralTankAdjustedVolume(1,n);
%aircraft.fuel.max_weight_aux=FuselageFuelWeight(1,n);
%aircraft.fuel.max_vol_aux=FuselageFuelVolume(1,n);
%aircraft.fuel.Fore_wing_spar_loc_root=FrontSparPosition(1,n);
%aircraft.fuel.Fore_wing_spar_loc_kik1=FrontSparPosition(2,n);
%aircraft.fuel.Fore_wing_spar_loc_kin2=FrontSparPosition(3,n);
%aircraft.fuel.Fore_wing_spar_loc_tip=FrontSparPosition(4,n);
%aircraft.fuel.Aux_wing_spar_loc_root=wingsau(1,n);
%aircraft.fuel.Aft_wing_spar_loc_root=RearSparPosition(1,n);
%aircraft.fuel.Aft_wing_spar_loc_kin1=RearSparPosition(2,n);
%aircraft.fuel.Aft_wing_spar_loc_kin2=RearSparPosition(3,n);
%aircraft.fuel.Aft_wing_spar_loc_tip=RearSparPosition(4,n);
%aircraft.fuel.Outboard_fuel_tank_span=OutboardFuelSpan(1,n);
%aircraft.fuel.Unusable_fuel_option=UnusableFuel(1,n);
%aircraft.fuel.Assumed_fuel_density =FuelDensity(1,n);

%aircraft.weight_balance.Fuel.Fuel_in_wing_x_cg=xcgwing(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_wing_y_cg=ycgwing(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_wing_z_cg=zcgwing(1,n);
%aircraft.weight_balance.Fuel.Fuel_in_wing2_x_cg=xcgwi2g(1,n);
%aircraft.weight_balance.Fuel.Fuel_in_wing2_y_cg=ycgwi2g(1,n);
%aircraft.weight_balance.Fuel.Fuel_in_wing2_z_cg=zcgwi2g(1,n);
%aircraft.weight_balance.Fuel.Fuel_in_fairings_x_cg=xcgfair(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_fairings_y_cg=ycgfair(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_fairings_z_cg=zcgfair(1,n);
%aircraft.weight_balance.Fuel.Fuel_in_fairing2_x_cg=xcgfa2r(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_fairing2_y_cg=ycgfa2r(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_fairing2_z_cg=zcgfa2r(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_x_cg=xcgtaux(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_y_cg=ycgtaux(1,n); 
%aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_z_cg=zcgtaux(1,n);


%% Engines

for i=1:EnginesNumber(1,n)
    
    pylon = ['Pylon' num2str(i)];
    nacelle = ['Nacelle' num2str(i)];
    
    if (EnginesLayout(1,n)==0 || EnginesLayout(1,n)==3) % There are pylons
        
        aircraft.Engines1.(pylon).longitudinal_location=PYLLOCX(1,n);  
        aircraft.Engines1.(pylon).vertical_location=PYLLOCZ(1,n);
        aircraft.Engines1.(pylon).lateral_location=-sign(cos(i*pi))*PYLLOCY(1,n);
        if EnginesLayout(1,n)==0
            aircraft.Engines1.(pylon).rotation=PYLROTX(1,n);
        else
            aircraft.Engines1.(pylon).rotation=sign(cos(i*pi))*PYLROTX(1,n);
        end
        aircraft.Engines1.(pylon).root_chord=PYLRCH(1,n);
        aircraft.Engines1.(pylon).taper_kink1=PYLTAP(1,1);
        aircraft.Engines1.(pylon).taper_kink2=PYLTAP(1,2);
        aircraft.Engines1.(pylon).taper_tip=PYLTAP(1,3);
        aircraft.Engines1.(pylon).LE_sweep_inboard=PYLLESW(1,1);
        aircraft.Engines1.(pylon).LE_sweep_midboard=PYLLESW(1,2);
        aircraft.Engines1.(pylon).LE_sweep_outboard=PYLLESW(1,3);
        aircraft.Engines1.(pylon).inboard_span=PYSPMTRX(1,1);
        aircraft.Engines1.(pylon).midboard_span=PYSPMTRX(1,2); 
        aircraft.Engines1.(pylon).outboard_span=PYSPMTRX(1,3);
        
    end
    
    aircraft.Engines1.(nacelle).longitudinal_location=NacelleXLoc(1,n); 
    aircraft.Engines1.(nacelle).vertical_location=NacelleZLoc(1,n);
    aircraft.Engines1.(nacelle).lateral_location=-sign(cos(i*pi))*NacelleYLoc(1,n); % Engines with even  index are on the starboard, odd on the port side
    aircraft.Engines1.(nacelle).d_max=EngineMaxDiameter(1,n);
    aircraft.Engines1.(nacelle).fineness_ratio=NacelleFineness(1,n);
    aircraft.Engines1.(nacelle).toe_in=EnginesToeIn(1,n);
    aircraft.Engines1.(nacelle).pitch=EnginesPitch(1,n);
    
    aircraft.Engines1.Nacelle_length_array=NacelleLength(1,n);
    
end


% If there are no engines, set to 0 the data that will be required by WB
if EnginesNumber(1,n)==0
    aircraft.Engines1.Nacelle_length_array=0;
    aircraft.Engines1.Nacelle1.longitudinal_location=0;
    aircraft.Engines1.Nacelle1.lateral_location=0;
    aircraft.Engines1.Nacelle1.vertical_location=0;
end

for i=EnginesNumber(1,n)+1:EnginesNumber(1,n)+EnginesNumber(2,n)  
    pylon = ['Pylon' num2str(i)];
    nacelle = ['Nacelle' num2str(i)];
    if (EnginesLayout(2,n)==0 || EnginesLayout(2,n)==3) % There are pylons
        aircraft.Engines2.(pylon).longitudinal_location=PYLLOCX(2,n);  
        aircraft.Engines2.(pylon).vertical_location=PYLLOCZ(2,n);
        aircraft.Engines2.(pylon).lateral_location=-sign(cos(i*pi))*PYLLOCY(2,n);
        if EnginesLayout(2,n)==0
            aircraft.Engines2.(pylon).rotation=PYLROTX(2,n);
        else
            aircraft.Engines2.(pylon).rotation=sign(cos(i*pi))*PYLROTX(2,n);
        end
        aircraft.Engines2.(pylon).root_chord=PYLRCH(2,n); 
        aircraft.Engines2.(pylon).taper_kink1=PYLTAP(2,1);
        aircraft.Engines2.(pylon).taper_kink2=PYLTAP(2,2);
        aircraft.Engines2.(pylon).taper_tip=PYLTAP(2,3);
        aircraft.Engines2.(pylon).LE_sweep_inboard=PYLLESW(2,1);
        aircraft.Engines2.(pylon).LE_sweep_midboard=PYLLESW(2,2);
        aircraft.Engines2.(pylon).LE_sweep_outboard=PYLLESW(2,3); 
        aircraft.Engines2.(pylon).inboard_span=PYSPMTRX(2,1);
        aircraft.Engines2.(pylon).midboard_span=PYSPMTRX(2,2);
        aircraft.Engines2.(pylon).outboard_span=PYSPMTRX(2,3);  
    end
    
    aircraft.Engines2.(nacelle).longitudinal_location=NacelleXLoc(2,n);  
    aircraft.Engines2.(nacelle).vertical_location=NacelleZLoc(2,n);
    aircraft.Engines2.(nacelle).lateral_location=-sign(cos(i*pi))*NacelleYLoc(2,n);
    aircraft.Engines2.(nacelle).d_max=EngineMaxDiameter(2,n);
    aircraft.Engines2.(nacelle).fineness_ratio=NacelleFineness(2,n);
    aircraft.Engines2.(nacelle).toe_in=EnginesToeIn(2,n);
    aircraft.Engines2.(nacelle).pitch=EnginesPitch(2,n);
    
    aircraft.Engines2.Nacelle_length_array=NacelleLength(2,n);
    
end

% If there are no engines, set to 0 the data that will be required by WB
if EnginesNumber(2,n)==0
    aircraft.Engines2.Nacelle_length_array=0;
    aircraft.Engines2.Nacelle3.longitudinal_location=0;
    aircraft.Engines2.Nacelle3.lateral_location=0;
    aircraft.Engines2.Nacelle3.vertical_location=0;
end
    

%% computed wetted areas
aircraft.Wetted_areas.Total_wetted_area=TotalWettedArea(1,n);
aircraft.Wetted_areas.Fuselage_fairing=FuseWettedArea(1,n);
aircraft.Wetted_areas.Wings=WingWettedArea(1,n);
aircraft.Wetted_areas.Winglet=WingletWettedArea(1,n);
aircraft.Wetted_areas.Vertical_tail=VTailWettedArea(1,n);
aircraft.Wetted_areas.Dorsal_fin=DorsalFinsWettedArea(1,n);
aircraft.Wetted_areas.Horizontal_tail=HTailWettedArea(1,n);
aircraft.Wetted_areas.Canard=CanardWettedArea(1,n);
aircraft.Wetted_areas.Pylons=PylonWettedArea(1,n);
aircraft.Wetted_areas.Powerplant=PowerplantWettedArea(1,n);

%%

% aircraft.Engines_results.Wetted_area_pylons=PylonWettedArea(1,n);
% aircraft.Engines_results.Wetted_area_powerplant=PowerplantWettedArea(1,n);
if aircraft.Engines1.present
    aircraft.Engines_results.wing_chord_at_engine_location=ChordAtEngine(:,n);
else
    aircraft.Engines_results.wing_chord_at_engine_location=0;
end
% aircraft.Wing_results.Wetted_area=WingWettedArea(1,n);
% aircraft.Wing_results.Wetted_area_winglet=WingletWettedArea(1,n);
% aircraft.total_wetted_area=TotalWettedArea(1,n);

%xout=xml_format(aircraft);
sout_geo=aircraft;
% xml_save('aircraft.xml',aircraft)
end

function aspect_ratio = AR (span, area)
aspect_ratio = span*span/area;
end

function [a0, a1, b1] = get_fuse_params(ldh, ldv, lxi)
N=40;
b=0.5*ldh;
t=pi/(N-1);
d0=0.5*ldv;
a1=ldv*(2*lxi-1)*0.5;
psi=zeros(1,N);
psi(1)=-pi*0.5;
for i=2:N-1
    psi(i)=psi(1)+t*i;
end
psi(N)=pi*0.5;
y=zeros(1,N);
for i=1:N
    s=sin(psi(i));
    c=tan(psi(i));
    y(i)=a1+s*(2*d0+a1*s)-3*b*c;
end
for i=1:N-1
    if y(i+1)*y(i)<=0
        break
    end
end
psi1=psi(i)+y(i)*(psi(i+1)-psi(i))/(y(i)-y(i+1));
tpsi=psi1+2*1e-6;
while abs(psi1-tpsi)>1e-6
    tpsi=psi1;
    s=sin(tpsi);
    c=tan(tpsi);
    ty=a1+s*(2*d0+a1*s)-3*b*c;
    c=cos(tpsi);
    yp=2*d0*c+a1*2*s*c-3*b/(c*c);
    psi1=tpsi-ty/yp;
end
c=cos(tpsi);
b1=(b/c-d0-a1*sin(tpsi))/(2*c*c);
a0=d0+b1;
end