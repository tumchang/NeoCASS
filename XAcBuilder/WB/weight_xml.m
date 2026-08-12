function out = weight_xml(in)
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
%     080101      2.1     L.Riccobene      Creation
%
%**************************************************************************
%
% function         out = weight_xml(in)
%
%
%   DESCRIPTION:   Weight and Balance main function (Run it with NEW
%                  version of XML file)
%
%
%         INPUT: NAME           TYPE       DESCRIPTION
%                  
%                in             struct     aircraft struct loaded with
%                                          xml_load from XML file and
%                                          processed by Geo module.
%                                       
%        OUTPUT: NAME           TYPE       DESCRIPTION
%                
%                out            struct     updated aircraft struct after
%                                          W&B computations
%         
%                
%    REFERENCES:
%
%**************************************************************************

% Read input struct
aircraft = in;
if isfield(aircraft,'check')
    if aircraft.check.geo ~= 1
        warning('You haven''t run geometry module. Run it first before weight&balance.')
        return
    end
end
% global AMflag AM
AMflag = false;

if isfield(aircraft,'added_masses')
    try
        AM = load(aircraft.added_masses);
        AMflag = true;
        aircraft.AM = AM;
        disp('added masses loaded')
    catch
        warning('Unable to load Added masses File')
        AMflag = false;
    end
end 

% Aircraft designation
n = 1;
acftidn(1, n) = n; %aircraft.designation; % = n
TotalWettedArea(1, n) = real(aircraft.Wetted_areas.Total_wetted_area);

% global PLOTCGS

%% Add on by Adrien
% global STACLAU STACLAD STACLRU STACTPD STACLEU STACLED STACLTU STACLTD
% global STACAUW
% % % global FOTEZLF STACSPT STACIFL STACISA
% % % FOTEZLF(1)=0;
% % % STACSPT(1)=0;
% % % STACIFL(1)=0;
% % % STACISA(1)=0;
% global IXXINER IYYINER IZZINER IXZINER %WingWeight VTailWeight
% global HTailWeight PylonWeight GearboxWeight NacelleWeight MaxFuelWeight FromMFWtoMTOW CALCOGX CALCOGZ MaxRampWeight
% IXXINER(1)=0;
% IYYINER(1)=0;
% IZZINER(1)=0;
% IXZINER(1)=0;
%%

% if isfield(aircraft.weight_balance,'COG')
% %     PLOTC
%     GS = aircraft.weight_balance.COG;
% else
    PLOTCGS = zeros(30, 4, 15);  % initialise the cg locations
% end
%--------------------------------------------------------------------------
% Parameters defined for internal usage
deg2rad = 2*pi/360;      % conversion from deg. to rad.
KTAS2MS = 0.5144;       % conversion from KTAS to m/s.               
PSI2KPA = 6.894757;     % conversion from PSI to KPa
SEA_LEVEL_P = 101.325;  % sea level pressure condition (kPa)
SEA_LEVEL_D = 1.225;    % sea level density (kg/m^3)
NEWTON2LB = 4.45;       % conversion from Newton to lb
g = 9.81;               % gravity acceleration (m/s^2)
CONSELN = 0;            % set to zero consol number

%--------------------------------------------------------------------------
% Call the modified fuel calculation routine to update fuel CoGs
% LR 25/09/08
aircraft = qfucalc_mod(aircraft);

% Check user specified fuel input consistency
aircraft = check_max_fuel_weight(aircraft);

%--------------------------------------------------------------------------
% Miscellaneous
TargetOperatingCeiling(1, n) = aircraft.miscellaneous.Target_operating_ceiling;
DesignClassification(1, n) = aircraft.miscellaneous.Design_classification;
SpoilerEffectivity(1, n) = aircraft.miscellaneous.Spoiler_effectivity;
UndercarriageLayout(1, n) = aircraft.miscellaneous.Undercarriage_layout;
%--------------------------------------------------------------------------
% Weight & Balance
%--------------------------------------------------------------------------
% System weights
CompletionsWeight(1, n) = aircraft.weight_balance.System.Compl_allowance_plus_paint;
OperatingItemsWeight(1, n) = aircraft.weight_balance.System.Other_operating_items;
LandingGearWeight(1, n) = aircraft.weight_balance.System.Landing_gear;
% LR 18/09/08
AuxLandingGearWeight(1, n) = aircraft.weight_balance.System.Aux_Landing_gear;
FuelSystemWeight(1, n) = aircraft.weight_balance.System.Fuel_system_weight; 
FlightControlsWeight(1, n) = aircraft.weight_balance.System.Flight_controls_weight; 
APUWeight(1, n) = aircraft.weight_balance.System.APU_weight; 
InstrumentsWeight(1, n) = aircraft.weight_balance.System.Instruments_weight; 
AvionicWeight(1, n) = aircraft.weight_balance.System.Avionics_weight; 
HydraulicPneumaticWeight(1, n) = aircraft.weight_balance.System.Hydraulic_Pneumatic_weight; 
ElectricalWeight(1, n) = aircraft.weight_balance.System.Electrical_weight; 
ECSWeight(1, n) = aircraft.weight_balance.System.ECS_anti_icing_grp_weight; 
FurnishingsWeight(1, n) = aircraft.weight_balance.System.Furnishings_Green; 
MiscellaneousWeight(1, n) = aircraft.weight_balance.System.Miscellaneous;
%-------------------------------------------------------------------------------
% Struct weights
WingWeight(1, n) = aircraft.weight_balance.Struct.Wings;
WingletWeight(1, n) = aircraft.weight_balance.Struct.Winglet_and_span_load_penalty;
HTailWeight(1, n) = aircraft.weight_balance.Struct.Horizontal_tail_and_elevator;
VTailWeight(1, n) = aircraft.weight_balance.Struct.Vertical_tail_rudder_and_dorsal;
VentralFinsWeight(1, n) = aircraft.weight_balance.Struct.Ventral_fins;
FuseWeight(1, n) = aircraft.weight_balance.Struct.Fuselage;
%-------------------------------------------------------------------------------
% Power plant weights
if aircraft.Engines1.present
    PylonWeight(1, n) = aircraft.weight_balance.Powerplant.Pylons_and_or_propellers;
    GearboxWeight(1, n) = aircraft.weight_balance.Powerplant.Engines_acc_propeller_gearbox;
    NacelleWeight(1, n) = aircraft.weight_balance.Powerplant.Nacelles;
else
    PylonWeight(1, n) = 0;
    GearboxWeight(1, n) = 0;
    NacelleWeight(1, n) = 0;
end
%-------------------------------------------------------------------------------
% Crew weight
CrewAndCarryonWeight(1, n) = aircraft.weight_balance.Crew.Crew_and_carry_on;
%-------------------------------------------------------------------------------
% Fuel weights
MaxFuelWeight(1, n) = aircraft.weight_balance.Fuel.Maximum_fuel_weight;
FuelAtMTOWMaxPayload(1, n) = aircraft.weight_balance.Fuel.Fuel_to_MTOW_at_maximum_payload;
FinalWingFuelWeight(1, n) = aircraft.weight_balance.Fuel.Maximum_fuel_in_wings;
FuselageFuelWeight(1, n) = aircraft.weight_balance.Fuel.Maximum_fuel_in_auxiliary;
CentralTankWeight(1, n) = aircraft.weight_balance.Fuel.Maximum_fuel_in_central_wingbox;
%-------------------------------------------------------------------------------
% Aircraft general weights
MTOW(1, n) = aircraft.weight_balance.MTOW_Maximum_takeoff_weight;
OEW(1, n) = aircraft.weight_balance.OEW_Operational_empty_weight;
GreenManEmptyWeight(1, n) = aircraft.weight_balance.Green_Manufacturer_empty_weight;
MaxPayloadWeight(1, n) = aircraft.weight_balance.Maximum_payload_weight;
MaxRampWeight(1, n) = aircraft.weight_balance.MRW_Maximum_ramp_weight; 
MZFW(1, n) = aircraft.weight_balance.MZFW_Maximum_zero_fuel_weight; 
%-------------------------------------------------------------------------------
% Merit
MaxPayloadPerPassenger(1, n) = aircraft.weight_balance.Merit.Maximum_payload_per_passenger;
FromMFWtoMTOW(1, n) = aircraft.weight_balance.Merit.Payload_to_MTOW_at_MFW;
PayloadMFWFactor(1, n) = aircraft.weight_balance.Merit.Load_factor_to_MTOW_at_MFW; 
StructuralEfficiency(1, n) = aircraft.weight_balance.Merit.Merit_function_OEW_over_MTOW; 
WingLoading(1, n) = aircraft.weight_balance.Merit.Merit_function_W_over_S_gross; 
ThrustToWeightRatio(1, n) = aircraft.weight_balance.Merit.Merit_function_thrust_to_weight; 
MLDBMFN(1, n) = aircraft.weight_balance.Merit.Merit_function_load_parameter; 
%-------------------------------------------------------------------------------
% Inertia matrix
Imat = aircraft.weight_balance.Imat;
IXXINER(1, n) = aircraft.weight_balance.IXXINER; % Moment_of_inertia_Ixx
IYYINER(1, n) = aircraft.weight_balance.IYYINER; % Moment_of_inertia_Iyy;
IZZINER(1, n) = aircraft.weight_balance.IZZINER; % Moment_of_inertia_Izz;
IXZINER(1, n) = aircraft.weight_balance.IXZINER; % Moment_of_inertia_Ixz;
IYZINER(1, n) = aircraft.weight_balance.IYZINER; % Moment_of_inertia_Iyz;
IXYINER(1, n) = aircraft.weight_balance.IXYINER; % Moment_of_inertia_Ixy;
%-------------------------------------------------------------------------------
% CGs
COECOGX(1, n) = aircraft.weight_balance.MEW_longitudinal_CoG; 
COECOGY(1, n) = aircraft.weight_balance.MEW_lateral_CoG; 
COECOGZ(1, n) = aircraft.weight_balance.MEW_vertical_CoG;
CMPCOGX(1, n) = aircraft.weight_balance.Maximum_payload_at_MTOW_longitudinal_CoG;
CMPCOGY(1, n) = aircraft.weight_balance.Maximum_payload_at_MTOW_lateral_CoG;
CMPCOGZ(1, n) = aircraft.weight_balance.Maximum_payload_at_MTOW_vertical_CoG;
% CMFCOGX(1, n) = aircraft.weight_balance.Maximum_fuel_at_MTOW_longitudinal_CoG;
% CMFCOGY(1, n) = aircraft.weight_balance.Maximum_fuel_at_MTOW_lateral_CoG;
% CMFCOGZ(1, n) = aircraft.weight_balance.Maximum_fuel_at_MTOW_vertical_CoG;
CALCOGX(1, n) = aircraft.weight_balance.Computed_longitudinal_CoG;
CALCOGY(1, n) = aircraft.weight_balance.Computed_lateral_CoG;
CALCOGZ(1, n) = aircraft.weight_balance.Computed_vertical_CoG;
%-------------------------------------------------------------------------------
% Fuel cgs
FinalWingFuelXCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_wing_x_cg; 
FinalWingFuelYCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_wing_y_cg; 
FinalWingFuelZCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_wing_z_cg;
FairingXCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_fairings_x_cg; 
FairingYCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_fairings_y_cg; 
FairingZCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_fairings_z_cg; 
AuxiliaryXCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_x_cg; 
AuxiliaryYCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_y_cg; 
AuxiliaryZCG(1, n) = aircraft.weight_balance.Fuel.Fuel_in_auxiliary_tanks_z_cg;
%-------------------------------------------------------------------------------
% Weight arms
WingXCG(1, n) = aircraft.weight_balance.Struct1_x_cg;
WingYCG(1, n) = aircraft.weight_balance.Struct1_y_cg;
WingZCG(1, n) = aircraft.weight_balance.Struct1_z_cg;
HTailXCG(1, n) = aircraft.weight_balance.Struct.Horizontal_tail_x_cg;
HTailYCG(1, n) = aircraft.weight_balance.Struct.Horizontal_tail_y_cg;
HTailZCG(1, n) = aircraft.weight_balance.Struct.Horizontal_tail_z_cg;
VTailXCG(1, n) = aircraft.weight_balance.Struct.Vertical_tail_x_cg;
VTailYCG(1, n) = aircraft.weight_balance.Struct.Vertical_tail_y_cg;
VTailZCG(1, n) = aircraft.weight_balance.Struct.Vertical_tail_z_cg;
FuseXCG(1, n) = aircraft.weight_balance.Struct.Fuselage_structure_x_cg;
FuseYCG(1, n) = aircraft.weight_balance.Struct.Fuselage_structure_y_cg;
FuseZCG(1, n) = aircraft.weight_balance.Struct.Fuselage_structure_z_cg;
EnginesXCG(1, n) = aircraft.weight_balance.Powerplant1_plus_nacelle_plus_pylon_x_cg;
EnginesXCG(2, n) = aircraft.weight_balance.Powerplant2_plus_nacelle_plus_pylon_x_cg;
EnginesYCG(1, n) = aircraft.weight_balance.Powerplant1_plus_nacelle_plus_pylon_y_cg;
EnginesYCG(2, n) = aircraft.weight_balance.Powerplant2_plus_nacelle_plus_pylon_y_cg;
EnginesZCG(1, n) = aircraft.weight_balance.Powerplant1_plus_nacelle_plus_pylon_z_cg;
EnginesZCG(2, n) = aircraft.weight_balance.Powerplant2_plus_nacelle_plus_pylon_z_cg;
TotalSystemsXCG(1, n) = aircraft.weight_balance.System.Total_systems_or_miscellaneous_x_cg;
TotalSystemsYCG(1, n) = aircraft.weight_balance.System.Total_systems_or_miscellaneous_y_cg;
TotalSystemsZCG(1, n) = aircraft.weight_balance.System.Total_systems_or_miscellaneous_z_cg;

FuelWingXCG(1, n) = FinalWingFuelXCG(1, n);
FuelWingYCG(1, n) = FinalWingFuelYCG(1, n);
FuelWingZCG(1, n) = FinalWingFuelZCG(1, n);
FuelCentralXCG(1, n) = aircraft.weight_balance.Fuel.Fuel_centre_plus_confor_x_cg;
FCENBAY(1, n) = aircraft.weight_balance.Fuel.Fuel_centre_plus_confor_y_cg;
FuelCentralZCG(1, n) = aircraft.weight_balance.Fuel.Fuel_centre_plus_confor_z_cg;
FuelAuxiliaryXCG(1, n) = aircraft.weight_balance.Fuel.Fuel_tank_auxiliary_x_cg;
FAUXBAY(1, n) = aircraft.weight_balance.Fuel.Fuel_tank_auxiliary_y_cg;
FuelAuxiliaryZCG(1, n) = aircraft.weight_balance.Fuel.Fuel_tank_auxiliary_z_cg;

InteriorsXCG(1, n) = aircraft.weight_balance.Payload.Interiors_completion_x_cg;
InteriorsYCG(1, n) = aircraft.weight_balance.Payload.Interiors_completion_y_cg;
InteriorsZCG(1, n) = aircraft.weight_balance.Payload.Interiors_completion_z_cg;
PilotsXCG(1, n) = aircraft.weight_balance.Crew.Pilots_x_cg;
PilotsYCG(1, n) = aircraft.weight_balance.Crew.Pilots_y_cg;
PilotsZCG(1, n) = aircraft.weight_balance.Crew.Pilots_z_cg;
PassengersXCG(1, n) = aircraft.weight_balance.Payload.Passengers_x_cg;
PASSBAY(1, n) = aircraft.weight_balance.Payload.Passengers_y_cg;
PassengersZCG(1, n) = aircraft.weight_balance.Payload.Passengers_z_cg;
BaggageXCG(1, n) = aircraft.weight_balance.Payload.Baggage_and_cargo_x_cg;
BaggageYCG(1, n) = aircraft.weight_balance.Payload.Baggage_and_cargo_y_cg;
BaggageZCG(1, n) = aircraft.weight_balance.Payload.Baggage_and_cargo_z_cg;

% Added to allow principal landing gear positioning into x-z plane
% LR 18/09/08
LandingGearXCG(1, n) = aircraft.miscellaneous.main_landing_gear_x_cg;
LandingGearZCG(1, n) = aircraft.miscellaneous.main_landing_gear_z_cg;
ALandingGearXCG(1, n) = aircraft.miscellaneous.aux_landing_gear_x_cg;
ALandingGearZCG(1, n) = aircraft.miscellaneous.aux_landing_gear_z_cg;

%-------------------------------------------------------------------------------
PassengerWeightCoeff(1, n) = aircraft.weight_balance.Payload.Passenger_weight_coefficient; 
WeightPerPassenger(1, n) = aircraft.weight_balance.Payload.Weight_per_passenger; 
IncrementPerPassenger(1, n) = aircraft.weight_balance.Payload.Weight_increment_per_passenger; 
RampIncrement(1, n) = aircraft.weight_balance.Ramp_increment; 
contwei(1, n) = aircraft.weight_balance.Weight_cont_allow_perc_of_MEW; 
WeightTolerance(1, n) = aircraft.weight_balance.Manufacturer_weights_tolerance; 
MaxFuelDecrement(1, n) = aircraft.weight_balance.MFW_decrement_to_MTOW;
YearAdvancement(1, n) = aircraft.weight_balance.Year_advan_techn_multip;
AttendantWeight(1, n) = aircraft.weight_balance.Crew.Cabin_attendant_weight;
FlightCrewWeight(1, n) = aircraft.weight_balance.Crew.Flight_crew_weight;
%-------------------------------------------------------------------------------
% Fuselage, Cabin, Baggages
FuseLength(1, n) = aircraft.Fuselage.Total_fuselage_length;
FuseVerticalDiameterAft(1, n) = aircraft.Fuselage.Aftfuse_X_sect_vertical_diameter;
FuseDistortionAft(1, n) = aircraft.Fuselage.Aftfuse_Xs_distortion_coefficient;
FuseHorizontalDiameterAft(1, n) = aircraft.Fuselage.Aftfuse_X_sect_horizontal_diameter;
NoseLength(1, n) = aircraft.Fuselage.Nose_length;
TailLength(1, n) = aircraft.Fuselage.Tail_length;

% Added for cabin floor width estimation
% LR 06/06/08
FuseParamAft(1) = aircraft.Fuselage.a0_aft;
FuseParamAft(3) = aircraft.Fuselage.a1_aft;
FuseParamAft(2) = aircraft.Fuselage.b1_aft;
%-------------------------------------------------------------------------------
Passengers(1, n) = aircraft.cabin.Passenger_accomodation;
SeatsAbreast(1, n) = aircraft.cabin.Seats_abreast_in_fuselage; 
cabnspt(1, n) = aircraft.cabin.Seat_pitch; 
CabinLength(1, n) = aircraft.cabin.Cabin_length_to_aft_cab;

% Added for cabin floor width estimation
% LR 16/11/08
% Infer cabin length from geometry if no value has been specified and set
% it if user input exceeds it
computed_CabinLength = FuseLength - NoseLength - TailLength;
if ~CabinLength(1, n)
    CabinLength(1, n) = computed_CabinLength;
else
    if CabinLength~= computed_CabinLength
        warning('Cabin length inserted %6.2f [m] doesn''t correspond to computed value of %6.2f [m]',...
            CabinLength(1, n), computed_CabinLength);
    end
% elseif CabinLength(1, n) > computed_CabinLength
%     CabinLength(1, n) = computed_CabinLength;
end

CabinMaxHeight(1, n) = aircraft.cabin.Cabin_max_internal_height; 
CabinMaxWidth(1, n) = aircraft.cabin.Cabin_max_internal_width;
CabinFloorWidth(1, n) = aircraft.cabin.Cabin_floor_width;
CabinVolume(1, n) = aircraft.cabin.Cabin_volume;
BaggageInstallation(1, n) = aircraft.Baggage.installation_type;      
BaggageApex(1, n) = aircraft.Baggage.Baggage_apex_per_fuselgt;
BaggageVolume(1, n) = aircraft.Baggage.gross_volume;                    
BaggageLength(1, n) = aircraft.Baggage.Baggage_combined_length;
CabinMaxAltitude(1, n) = aircraft.cabin.Maximum_cabin_altitude;
CabinPressureDifferentialPSI(1, n) = aircraft.cabin.Max_pressure_differential;
CrewNumber(1, n) = aircraft.cabin.Cabin_attendant_number;
FlightCrewNumber(1, n) = aircraft.cabin.Flight_crew_number;
FuseWingPosition(1, n) = aircraft.Fuselage.X_sect_chord_at_fuse_wing;
%-------------------------------------------------------------------------------
% Wing 1
WingArea(1, n) = aircraft.Wing1.area;
WingSpan(1, n) = aircraft.Wing1.Span;
WingConfiguration(1, n) = aircraft.Wing1.configuration;
WingPlacement(1, n) = aircraft.Wing1.placement;
WingApex(1, n) = aircraft.Wing1.apex_locale;
WingKink(1, n) = aircraft.Wing1.spanwise_kink1;
WingKink(2, n) = aircraft.Wing1.spanwise_kink2;
WingLESweep(1, n) = aircraft.Wing1.LE_sweep_inboard;
WingLESweep(2, n) = aircraft.Wing1.LE_sweep_midboard;
WingLESweep(3, n) = aircraft.Wing1.LE_sweep_outboard;
WingDihedral(1, n) = aircraft.Wing1.dihedral_inboard;
WingDihedral(2, n) = aircraft.Wing1.dihedral_midboard;
WingDihedral(3, n) = aircraft.Wing1.dihedral_outboard;
WingThickness(1, n) = aircraft.Wing1.thickness_root;
WingThickness(2, n) = aircraft.Wing1.thickness_kink1;
WingThickness(3, n) = aircraft.Wing1.thickness_kink2;
WingThickness(4, n) = aircraft.Wing1.thickness_tip;

try
    WingletIncrement(1, n) = aircraft.Wetted_areas.increment_winglet; 
catch
    WingletIncrement(1, n) = aircraft.Wetted_areas.Winglet; 
end

WingTaper(1, n) = aircraft.Wing1.taper_kink1;
WingTaper(2, n) = aircraft.Wing1.taper_kink2;
WingTaper(3, n) = aircraft.Wing1.taper_tip;

%-------------------------------------------------------------------------------
wletspn(1, n) = aircraft.Wing1.winglet.Span;
SpanMatrixPartition(1:3, n) = aircraft.Wing1.Span_matrix_partition_in_mid_outboard;
RefWingChordOrigin(1, n) = aircraft.Reference_wing.Orig_root_chrd_at_ac_CL;
MACSpanPos(1, n) = aircraft.Reference_wing.non_dim_MAC_y_bar;
WINWYBR(1, n) = MACSpanPos(1, n);                                              % apparently they are the same
RefWingMAC(1, n) = aircraft.Reference_wing.MAC;
RefWingLESweep(1, n) = aircraft.Reference_wing.LE_sweep;
RefWingApex(1, n) = aircraft.Reference_wing.relative_apex;
RefWingAR(1, n)  = aircraft.Reference_wing.Weighted_aspect_ratio;
RefWingHCSweep(1, n)  = aircraft.Reference_wing.Half_chord_sweep;
ReferenceWingArea(1, n)  = aircraft.Reference_wing.Weighted_area;
ReferenceWingArea2(1, n)  = ReferenceWingArea(1, n);                                             % apparently the same after qgeotry call
RefWingThickness(1, n)  = aircraft.Reference_wing.mean_thickness;
WingWeightedTaper(1, n)  = aircraft.Wing1.Weighted_taper_ratio;
WingQCSweep(1, n)  = aircraft.Reference_wing.Quarter_chord_sweep;
RefWingAreaForWB(1, n) = aircraft.Reference_wing.Wing_area_for_weight_balance_analysis;
try
    VortexInducedDragFactor(1, n) = aircraft.Wing1.Fractional_change_vortex_induced_drag_factor;
catch
    VortexInducedDragFactor(1, n) = 0.;
end

%*************************************************************************      ADDED 2008-05-23 
% Added for Mitchell code compatibility
RefWingTaper(1, n) = aircraft.Reference_wing.taper_ratio;
RefWingThickness = RefWingThickness; 
%*************************************************************************
%*************************************************************************      ADDED 2008-05-23 
% Added for Mitchell code compatibility
if aircraft.Vertical_tail.present
    RefVTailArea(1, n) = aircraft.Vertical_tail.reference_wing_area;
    RefVTailTaper(1, n) = aircraft.Vertical_tail.reference_wing_taper_ratio;
    RefVTailLESweep(1, n) = aircraft.Vertical_tail.reference_wing_LE_sweep;
else
    RefVTailArea(1, n) =0;
    RefVTailTaper(1, n) = 0;
    RefVTailLESweep(1, n) = 0;
end
%-------------------------------------------------------------------------------
% Wing 2
wi2gcfg(1, n) = aircraft.Wing2.configuration;
wi2gplc(1, n) = aircraft.Wing2.placement;
wi2gare(1, n) = aircraft.Wing2.area;
%-------------------------------------------------------------------------------
% if wi2gare(n) > 0.001
if aircraft.Wing2.present
WI2WGAR(1, n) = aircraft.Wing2.Weighted_reference_aspect_ratio;
ReferenceWing2Area(1, n) = aircraft.Wing2.Weighted_reference_wing_area;
WI2WTAP(1, n) = aircraft.Wing2.Weighted_taper_ratio;
WI2WQSW(1, n) = aircraft.Wing2.Reference_quarter_chord_sweep;
WI2WTHB(1, n) = aircraft.Wing2.Wing_mean_thickness;
% end
end
%-------------------------------------------------------------------------------
% Horizontal Tail
if aircraft.Horizontal_tail.present
    EmpennageLayout(1, n) = aircraft.Horizontal_tail.empennage_layout;
    HTailArea(1, n) = aircraft.Horizontal_tail.area;
    HTailAR(1, n) = aircraft.Horizontal_tail.AR;
    HTailLESweep(1, n) = aircraft.Horizontal_tail.LE_sweep_inboard;
    HTailLESweep(3, n) = aircraft.Horizontal_tail.LE_sweep_outboard;
    HTailDihedral(1, n) = aircraft.Horizontal_tail.dihedral_inboard;
    HTailDihedral(2, n) = aircraft.Horizontal_tail.dihedral_outboard;
    HTailVerticalLocale(1, n) = aircraft.Horizontal_tail.vertical_locale;
    HTailApex(1, n) = aircraft.Horizontal_tail.apex_locale;
    HTailSpan(1, n) = aircraft.Horizontal_tail.Span;
    HTailKink(1, n) = aircraft.Horizontal_tail.spanwise_kink;
% LR 18/03/2009
% Not needed anymore since control surface definition is changed
% HTailKink(2, n) = aircraft.Horizontal_tail.Elevator.Span;

    HTailTaper(1, n) = aircraft.Horizontal_tail.taper_kink;
    HTailTaper(3, n) = aircraft.Horizontal_tail.taper_tip;
else
    HTailArea(n) = 0;
    EmpennageLayout(n) = 0;
    HTailLESweep  = 0;
    HTailApex = 0;
    HTailVerticalLocale = 0;
    HTailSpan = 0;
    RefHTailLESweep = 0;
    RefHTailArea = 0;
    RefHTailTaper = 0;
    HTailSpanMatrixPartition = 0;
    TailLength = 0;
    
end
%-------------------------------------------------------------------------------
% AP 2009.04.20 - LR 16/02/2010 modified check
ht_flag(1, n) = aircraft.Horizontal_tail.present;

if ht_flag
    
    HTailLongitudinalLocation = aircraft.Horizontal_tail.longitudinal_location;
    HTailVerticalLocation = aircraft.Horizontal_tail.vertical_location;
    HTailMACSpanPos(1, n) = aircraft.Horizontal_tail.reference_wing_Y_bar_non_dim;
    RefHTailThickness(1, n) = aircraft.Horizontal_tail.reference_wing_mean.thickness;
    RefHTailQCSweep(1, n) = aircraft.Horizontal_tail.reference_wing_quarter_chord_sweep;
    HTailMomentArm(1, n) = aircraft.Horizontal_tail.Moment_arm_to_HT;
    HTailSpanMatrixPartition(1:3, n) = aircraft.Horizontal_tail.Span_matrix_partition_in_mid_outboard;
    HTailOriginalRootChord(1, n) = aircraft.Horizontal_tail.original_root_chord;
    % Added for Mitchell code compatibility
    RefHTailArea(1, n) = aircraft.Horizontal_tail.reference_wing_area;
    RefHTailTaper(1, n) = aircraft.Horizontal_tail.reference_wing_taper_ratio;
    RefHTailLESweep(1, n) = aircraft.Horizontal_tail.reference_wing_LE_chord_sweep;
    
else
    
    HTailMACSpanPos(1, n) = 0;
    RefHTailThickness(1, n) = 0;
    RefHTailQCSweep(1, n) = 0;
    HTailMomentArm(1, n) = 0;
    HTailSpanMatrixPartition(1:3, n) = 0;
    HTailOriginalRootChord(1, n) = 0;
    % Added for Mitchell code compatibility
    RefHTailArea(1, n) = 0;
    RefHTailTaper(1, n) = 0;
    RefHTailLESweep(1, n) = 0;
    HTailLongitudinalLocation = 0.;
    HTailVerticalLocation = 0.;
    
end
%-------------------------------------------------------------------------------
% Vertical Tail
if aircraft.Vertical_tail.present
    VTailArea(1, n) = aircraft.Vertical_tail.area;
    VTailAR(1, n) = aircraft.Vertical_tail.AR;
    VTailVerticalLocale(1, n) = aircraft.Vertical_tail.vertical_locale;
    VTailApex(1, n) = aircraft.Vertical_tail.apex_locale;
    VTailSpan(1, n) = aircraft.Vertical_tail.Span;
    VTailTaper(1, n) = aircraft.Vertical_tail.taper_kink;
    VTailTaper(3, n) = aircraft.Vertical_tail.taper_tip;
    VTailLESweep(1, n) = aircraft.Vertical_tail.LE_sweep_inboard;
    VTailLESweep(3, n) = aircraft.Vertical_tail.LE_sweep_outboard;
    VTailKink(1, n) = aircraft.Vertical_tail.spanwise_kink;
else
    VTailArea(n) = 0;
    VTailApex=0;
    VTailSpan = 0;
    RefVTailLESweep = 0;
    VTailVerticalLocale = 0;
    RefVTailArea = 0;
    RefVTailTaper = 0;
    RefVTailThickness = 0;
    VTailSpanMatrixPartition = 0;
end

% LR 18/03/2009
% Not needed anymore since control surface definition is changed
% VTailKink(2, n) = aircraft.Vertical_tail.Rudder.Span;

try
    VTailDorsalLocation(1, n) = aircraft.Vertical_tail.Dorsal_location;
catch
    VTailDorsalLocation(1, n) = 0.;
end

% LR 11/05/2009

% Added twin vertical tail modelling capability
if aircraft.Vertical_tail.present
    try aircraft.Vertical_tail.TwinTail;
        TwinTail = aircraft.Vertical_tail.TwinTail;      % Flag 0/1
        TwinTailSpan = aircraft.Vertical_tail.TwinTailSpan; % Offset in % wing span
        
    catch
        TwinTail = 0;
        TwinTailSpan = 0;
    end
else
    TwinTail = 0;
    TwinTailSpan = 0;
end

%--------------------------------------------------------------------------
if aircraft.Vertical_tail.present
    VTailMACSpanPos(1, n) = aircraft.Vertical_tail.reference_Y_bar_non_dim;
    RefVTailThickness(1, n) = aircraft.Vertical_tail.reference_wing_mean_thickness;
    RefVTailQCSweep(1, n) = aircraft.Vertical_tail.reference_wing_quarter_chord_sweep;
    VTailWettedArea(1, n) = aircraft.Wetted_areas.Vertical_tail;
    VTailMomentArm(1, n) = aircraft.Vertical_tail.Moment_arm_to_VT;
    VTailSpanMatrixPartition(1:3, n) = aircraft.Vertical_tail.Span_matrix_partition_in_mid_outboard;
    VTailOriginalRootChord(1, n) = aircraft.Vertical_tail.original_root_chord;
else
    VTailMACSpanPos(1, n) = 0;
    RefVTailThickness(1, n) = 0;
    RefVTailQCSweep(1, n) = 0;
    VTailWettedArea(1, n) = 0;
    VTailMomentArm(1, n) = 0;
    VTailSpanMatrixPartition(1:3, n) = 0;
    VTailOriginalRootChord(1, n) = 0;
end
DorsalFinsWettedArea(1, n) = aircraft.Wetted_areas.Dorsal_fin;
%--------------------------------------------------------------------------
% LR 16/02/2010 - Added Canard
canard_flag(1, n) = aircraft.Canard.present;

if canard_flag
    
    candare(1, n)   = aircraft.Canard.area;
    CanardAR(1, n)   = aircraft.Canard.AR;
    RefCanardThickness(1, n)   = aircraft.Canard.reference_wing_mean.thickness;
    RefCanardQCSweep(1, n)  = aircraft.Canard.reference_wing_quarter_chord_sweep;
    CanardVerticalLocale(1, n)   = aircraft.Canard.vertical_locale;
    CanardApex(1, n)   = aircraft.Canard.apex_locale;
    CanardMACSpanPos(1, n)   = aircraft.Canard.reference_wing_Y_bar_non_dim;
    CanardXCG(1, n)   = aircraft.weight_balance.Struct.Canard_x_cg;
    CanardYCG(1, n)   = aircraft.weight_balance.Struct.Canard_y_cg;
    CanardZCG(1, n)   = aircraft.weight_balance.Struct.Canard_z_cg;
    CanardSpan(1, n)   = aircraft.Canard.Span;
    CanardTaper(1, n)   = aircraft.Canard.taper_kink;
    CanardTaper(3, n)   = aircraft.Canard.taper_tip;
    CanardLESweep(1, n)   = aircraft.Canard.LE_sweep_inboard;
    CanardLESweep(3, n)   = aircraft.Canard.LE_sweep_outboard;
    CanardKink(1, n)   = aircraft.Canard.spanwise_kink;
    CanardDihedral(1, n)   = aircraft.Canard.dihedral_inboard;
    CanardDihedral(2, n)   = aircraft.Canard.dihedral_outboard;
    CanardSpanMatrixPartition(1:3, :) = aircraft.Canard.Span_matrix_partition_in_mid_outboard;
    CanardOriginalRootChord(1, n)   = aircraft.Canard.original_root_chord;
    
else
 
    CanardXCG(1, n)   = 0.;
    CanardYCG(1, n)   = 0.;
    CanardZCG(1, n)   = 0.;
    RefCanardThickness(1, n)   = 0.;
    RefCanardQCSweep(1, n)  = 0;
    CanardMACSpanPos(1, n)   = 0.;
    CanardSpanMatrixPartition(1:3, :) = 0.;
    CanardOriginalRootChord(1, n)   = 0.;
    CanardXCG(1, n)   = 0.;
    CanardYCG(1, n)   = 0.;
    CanardZCG(1, n)   = 0.;
    
end

%--------------------------------------------------------------------------
% SR 31/05/2010 - Added Tailbooms

tailbooms_flag(1, n) = aircraft.Tailbooms.present;

if tailbooms_flag

    TBSymmetry(1, n) = aircraft.Tailbooms.symmetry;
    TBDiameter(1, n) = aircraft.Tailbooms.diameter;
    TBLength(1, n) = aircraft.Tailbooms.total_length;
    TBxLoc(1, n) = aircraft.Tailbooms.x_location;
    TByLoc(1, n) = aircraft.Tailbooms.y_location;
    TBzLoc(1, n) = aircraft.Tailbooms.z_location;

end

%--------------------------------------------------------------------------

% ********************* Landing Gear ***********************
landinggear_flag(1, n) = aircraft.NewMLG.present;              % AGGIUNTO
auxlandinggear_flag(1, n) = aircraft.Aux_Landing_Gear.present; % AGGIUNTO
% **********************************************************

% Propulsion
EnginesNumber(1, n) = aircraft.Engines1.Number_of_engines;
EnginesNumber(2, n) = aircraft.Engines2.Number_of_engines;
if EnginesNumber(1,n) > 0
    EnginesLayout(1, n) = aircraft.Engines1.Layout_and_config;
    PropellerDiameter(1, n) = aircraft.Engines1.Propeller_diameter;
    NacelleType(1, n) = aircraft.Engines1.Nacelle_body_type;
    NacelleFineness(1, n) = aircraft.Engines1.fineness_ratio;
    EngineMaxDiameter(1, n) = aircraft.Engines1.d_max;
    MaxThrust(1, n) = aircraft.Engines1.Max_thrust;
    EngineYLocale(1, n) = aircraft.Engines1.Y_locale;
    EnginesType(1, n) = aircraft.Engines1.Propulsion_type;
    %-------------------------------------------------------------------------------
    ReverserEffectiveness(1, n) = aircraft.Engines1.Thrust_reverser_effectivness;
    ThrustToWeight(1, n) = aircraft.Engines1.Thrust_to_weight_ratio;
    BypassRatio(1, n) = aircraft.Engines1.Bypass_ratio_to_emulate;
else
    PylonWeight  = 0;
    GearboxWeight  = 0;
    NacelleWeight = 0;
    EngineYLocale = 0;
    NacelleLength = 0;
    EngineMaxDiameter = 0;
end

% 17/03/2009 L.Riccobene - AcBuilder has a different format for Nacelles,
% added a few lines to mantain backward compatibility
% 19/02/2010 L.Riccobene - Updated format since AcBuilder is now a standard
if aircraft.Engines1.present
    
    NacelleXLoc(1, n) = aircraft.Engines1.Nacelle1.longitudinal_location;
    NacelleYLoc(1, n) = aircraft.Engines1.Nacelle1.lateral_location;
    NacelleZLoc(1, n) = aircraft.Engines1.Nacelle1.vertical_location;
    NacelleLength(1, n) = aircraft.Engines1.Nacelle_length_array; 
    
else
    
    NacelleXLoc(1, n) = 0.;
    NacelleYLoc(1, n) = 0.;
    NacelleZLoc(1, n) = 0.;
    NacelleLength(1, n) = 0.;
    
end

if aircraft.Engines2.present
    
    NacelleXLoc(2, n) = aircraft.Engines2.Nacelle3.longitudinal_location;
    NacelleYLoc(2, n) = aircraft.Engines2.Nacelle3.lateral_location;
    NacelleZLoc(2, n) = aircraft.Engines2.Nacelle3.vertical_location;
    NacelleLength(2, n) = aircraft.Engines2.Nacelle_length_array;
    
    EnginesLayout(2, n) = aircraft.Engines2.Layout_and_config;
    PropellerDiameter(2, n) = aircraft.Engines2.Propeller_diameter;
    NacelleType(2, n) = aircraft.Engines2.Nacelle_body_type;
    NacelleFineness(2, n) = aircraft.Engines2.fineness_ratio;
    EngineMaxDiameter(2, n) = aircraft.Engines2.d_max;
    MaxThrust(2, n) = aircraft.Engines2.Max_thrust;
    EngineYLocale(2, n) = aircraft.Engines2.Y_locale;
    EnginesType(2, n) = aircraft.Engines2.Propulsion_type;
    ReverserEffectiveness(2, n) = aircraft.Engines2.Thrust_reverser_effectivness;
    BypassRatio(2, n) = aircraft.Engines2.Bypass_ratio_to_emulate;
    
else
    
    NacelleXLoc(2, n) = 0.;
    NacelleYLoc(2, n) = 0.;
    NacelleZLoc(2, n) = 0.;
    NacelleLength(2, n) = 0.;
    
    EnginesLayout(2, n) = 0;
    PropellerDiameter(2, n) = 0;
    NacelleType(2, n) = 0;
    NacelleFineness(2, n) = 0;
    EngineMaxDiameter(2, n) = 0;
    MaxThrust(2, n) = 0;
    EngineYLocale(2, n) =0;
    EnginesType(2, n) = 0;
    ReverserEffectiveness(2, n) = 0;
    BypassRatio(2, n) = 0;
    
end

%-------------------------------------------------------------------------------
% Fuel
FrontSparPosition(1, n) = aircraft.fuel.Fore_wing_spar_loc_root;
FrontSparPosition(2, n) = aircraft.fuel.Fore_wing_spar_loc_kik1;
FrontSparPosition(3, n) = aircraft.fuel.Fore_wing_spar_loc_kin2;
FrontSparPosition(4, n) = aircraft.fuel.Fore_wing_spar_loc_tip;
RearSparPosition(1, n) = aircraft.fuel.Aft_wing_spar_loc_root;
RearSparPosition(2, n) = aircraft.fuel.Aft_wing_spar_loc_kin1;
RearSparPosition(3, n) = aircraft.fuel.Aft_wing_spar_loc_kin2;
RearSparPosition(4, n) = aircraft.fuel.Aft_wing_spar_loc_tip;
UnusableFuel(1, n) = aircraft.fuel.Unusable_fuel_option;
%-------------------------------------------------------------------------------
% Flight envelope
VDkn(1, n) = aircraft.weight_balance.flight_envelope_prediction.VD_Flight_envelope_dive;
VMOkn(1, n) = aircraft.weight_balance.flight_envelope_prediction.VMO_Flight_envelope;

%-------------------------------------------------------------------------------
% Input for Stability and Control Computations
% To be added to Adrien's file
STACAUW(1, n) = aircraft.stability.All_up_weight;

%--------------------------------------------------------------------------
% Run WB subroutines
%--------------------------------------------------------------------------
% First
rcogs
%--------------------------------------------------------------------------
% Second
wb_weight
%--------------------------------------------------------------------------
% Third
rweig
%--------------------------------------------------------------------------
% Fourth
riner

%--------------------------------------------------------------------------
% Set W&B version
% aircraft.weight_balance.version = wb_version;

%--------------------------------------------------------------------------
% Export all variables and overwrite / copy their values
% Weight and balance output struct

% WB Fuel
aircraft.weight_balance.Fuel.Fuel_in_wing_x_cg = FuelWingXCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_wing_y_cg = FuelWingYCG(1, n);
aircraft.weight_balance.Fuel.Fuel_in_wing_z_cg = FuelWingZCG(1, n);

% WB generic
aircraft.weight_balance.MTOW_Maximum_takeoff_weight = MTOW(1, n);
aircraft.weight_balance.OEW_Operational_empty_weight = OEW(1, n);
aircraft.weight_balance.Green_Manufacturer_empty_weight = GreenManEmptyWeight(1, n);
aircraft.weight_balance.Maximum_payload_weight = MaxPayloadWeight(1, n);
aircraft.weight_balance.Fuel.Maximum_fuel_weight = MaxFuelWeight(1, n);
aircraft.weight_balance.Maximum_fuel_weight = MaxFuelWeight(1, n);
aircraft.weight_balance.MRW_Maximum_ramp_weight = MaxRampWeight(1, n);
aircraft.weight_balance.MZFW_Maximum_zero_fuel_weight = MZFW(1, n);
aircraft.weight_balance.MEW_longitudinal_CoG = COECOGX(1, n);
aircraft.weight_balance.MEW_lateral_CoG = COECOGY(1, n);
aircraft.weight_balance.MEW_vertical_CoG = COECOGZ(1, n);
aircraft.weight_balance.Maximum_payload_at_MTOW_longitudinal_CoG = CMPCOGX(1, n);
aircraft.weight_balance.Maximum_payload_at_MTOW_lateral_CoG = CMPCOGY(1, n);
aircraft.weight_balance.Maximum_payload_at_MTOW_vertical_CoG = CMPCOGZ(1, n);
aircraft.weight_balance.Computed_longitudinal_CoG = CALCOGX(1, n);
aircraft.weight_balance.Computed_lateral_CoG = CALCOGY(1, n);
aircraft.weight_balance.Computed_vertical_CoG = CALCOGZ(1, n);
aircraft.weight_balance.Ramp_increment = RampIncrement(1, n);
aircraft.weight_balance.Weight_cont_allow_perc_of_MEW = contwei(1, n);
aircraft.weight_balance.Manufacturer_weights_tolerance = WeightTolerance(1, n);
aircraft.weight_balance.MFW_decrement_to_MTOW = MaxFuelDecrement(1, n);
aircraft.weight_balance.Year_advan_techn_multip = YearAdvancement(1, n);
aircraft.weight_balance.Crew.Cabin_attendant_weight = AttendantWeight(1, n);
aircraft.weight_balance.Crew.Flight_crew_weight = FlightCrewWeight(1, n);
aircraft.weight_balance.COG = PLOTCGS;

% WB Merit
aircraft.weight_balance.Merit.Maximum_payload_per_passenger = MaxPayloadPerPassenger(1, n);
aircraft.weight_balance.Merit.Payload_to_MTOW_at_MFW = FromMFWtoMTOW(1, n);
aircraft.weight_balance.Merit.Load_factor_to_MTOW_at_MFW = PayloadMFWFactor(1, n);
aircraft.weight_balance.Merit.Merit_function_OEW_over_MTOW = StructuralEfficiency(1, n);
aircraft.weight_balance.Merit.Merit_function_W_over_S_gross = WingLoading(1, n);
aircraft.weight_balance.Merit.Merit_function_thrust_to_weight = ThrustToWeightRatio(1, n);
aircraft.weight_balance.Merit.Merit_function_load_parameter = MLDBMFN(1, n);

% WB inertia matrix
aircraft.weight_balance.IXXINER = IXXINER(1, n);
aircraft.weight_balance.IYYINER = IYYINER(1, n);
aircraft.weight_balance.IZZINER = IZZINER(1, n);
aircraft.weight_balance.IXZINER = IXZINER(1, n);
aircraft.weight_balance.IYZINER = IYZINER(1, n);
aircraft.weight_balance.IXYINER = IXYINER(1, n);
Imat = [IXXINER(1, n), IXYINER(1, n), IXZINER(1, n);...
    IXYINER(1, n), IYYINER(1, n), IYZINER(1, n);...
    IXZINER(1, n), IYZINER(1, n), IZZINER(1, n)];
aircraft.weight_balance.Imat = Imat;

% WB structure
aircraft.weight_balance.Struct1_x_cg = WingXCG(1, n);
aircraft.weight_balance.Struct1_y_cg = WingYCG(1, n);
aircraft.weight_balance.Struct1_z_cg = WingZCG(1, n);
aircraft.weight_balance.Struct.Horizontal_tail_x_cg = HTailXCG(1, n);
aircraft.weight_balance.Struct.Horizontal_tail_y_cg = HTailYCG(1, n);
aircraft.weight_balance.Struct.Horizontal_tail_z_cg = HTailZCG(1, n);
aircraft.weight_balance.Struct.Vertical_tail_x_cg = VTailXCG(1, n);
aircraft.weight_balance.Struct.Vertical_tail_y_cg = VTailYCG(1, n);
aircraft.weight_balance.Struct.Vertical_tail_z_cg = VTailZCG(1, n);
aircraft.weight_balance.Struct.Fuselage_structure_x_cg = FuseXCG(1, n);
aircraft.weight_balance.Struct.Fuselage_structure_y_cg = FuseYCG(1, n);
aircraft.weight_balance.Struct.Fuselage_structure_z_cg = FuseZCG(1, n);
aircraft.weight_balance.Struct.Wings = WingWeight(1, n);
aircraft.weight_balance.Struct.Winglet_and_span_load_penalty = WingletWeight(1, n);
aircraft.weight_balance.Struct.Horizontal_tail_and_elevator = HTailWeight(1, n);
aircraft.weight_balance.Struct.Vertical_tail_rudder_and_dorsal = VTailWeight(1, n);
aircraft.weight_balance.Struct.Ventral_fins = VentralFinsWeight(1, n);
aircraft.weight_balance.Struct.Fuselage = FuseWeight(1, n);
% LR 16/02/2010 - added Canard
aircraft.weight_balance.Struct.Canard_x_cg = CanardXCG(1, n);
aircraft.weight_balance.Struct.Canard_y_cg = CanardYCG(1, n);
aircraft.weight_balance.Struct.Canard_z_cg = CanardZCG(1, n);
% SR 02/06/2010 - added Tailbooms
aircraft.weight_balance.Struct.Tailbooms_x_cg = TBXCG(1, n);
aircraft.weight_balance.Struct.Tailbooms_y_cg = TBYCG(1, n);
aircraft.weight_balance.Struct.Tailbooms_z_cg = TBZCG(1, n);

    
% WB powerplant
aircraft.weight_balance.Powerplant1_plus_nacelle_plus_pylon_x_cg = EnginesXCG(1, n);
aircraft.weight_balance.Powerplant2_plus_nacelle_plus_pylon_x_cg = EnginesXCG(2, n);
aircraft.weight_balance.Powerplant1_plus_nacelle_plus_pylon_y_cg = EnginesYCG(1, n);
aircraft.weight_balance.Powerplant2_plus_nacelle_plus_pylon_y_cg = EnginesYCG(2, n);
aircraft.weight_balance.Powerplant1_plus_nacelle_plus_pylon_z_cg = EnginesZCG(1, n);
aircraft.weight_balance.Powerplant2_plus_nacelle_plus_pylon_z_cg = EnginesZCG(2, n);
aircraft.weight_balance.Powerplant.Pylons_and_or_propellers = PylonWeight(1, n);
aircraft.weight_balance.Powerplant.Engines_acc_propeller_gearbox = GearboxWeight(1, n);
aircraft.weight_balance.Powerplant.Nacelles = NacelleWeight(1, n);

% WB systems
aircraft.weight_balance.System.Compl_allowance_plus_paint = CompletionsWeight(1, n);
aircraft.weight_balance.System.Other_operating_items = OperatingItemsWeight(1, n);
aircraft.weight_balance.System.Landing_gear = LandingGearWeight(1, n);
aircraft.weight_balance.System.Aux_Landing_gear = AuxLandingGearWeight(1, n);
aircraft.weight_balance.System.Fuel_system_weight = FuelSystemWeight(1, n);
aircraft.weight_balance.System.Flight_controls_weight = FlightControlsWeight(1, n);
aircraft.weight_balance.System.APU_weight = APUWeight(1, n);
aircraft.weight_balance.System.Instruments_weight = InstrumentsWeight(1, n);
aircraft.weight_balance.System.Avionics_weight = AvionicWeight(1, n);
aircraft.weight_balance.System.Hydraulic_Pneumatic_weight = HydraulicPneumaticWeight(1, n);
aircraft.weight_balance.System.Electrical_weight = ElectricalWeight(1, n);
aircraft.weight_balance.System.ECS_anti_icing_grp_weight = ECSWeight(1, n);
aircraft.weight_balance.System.Furnishings_Green = FurnishingsWeight(1, n);
aircraft.weight_balance.System.Miscellaneous = MiscellaneousWeight(1, n);
aircraft.weight_balance.System.Total_systems_or_miscellaneous_x_cg = TotalSystemsXCG(1, n);
aircraft.weight_balance.System.Total_systems_or_miscellaneous_y_cg = TotalSystemsYCG(1, n);
aircraft.weight_balance.System.Total_systems_or_miscellaneous_z_cg = TotalSystemsZCG(1, n);

% WB payload
aircraft.weight_balance.Payload.Interiors_completion_x_cg = InteriorsXCG(1, n);
aircraft.weight_balance.Payload.Interiors_completion_y_cg = InteriorsYCG(1, n);
aircraft.weight_balance.Payload.Interiors_completion_z_cg = InteriorsZCG(1, n);
aircraft.weight_balance.Payload.Passengers_x_cg = PassengersXCG(1, n);
aircraft.weight_balance.Payload.Passengers_y_cg = PASSBAY(1, n);
aircraft.weight_balance.Payload.Passengers_z_cg = PassengersZCG(1, n);
aircraft.weight_balance.Payload.Baggage_and_cargo_x_cg = BaggageXCG(1, n);
aircraft.weight_balance.Payload.Baggage_and_cargo_y_cg = BaggageYCG(1, n);
aircraft.weight_balance.Payload.Baggage_and_cargo_z_cg = BaggageZCG(1, n);
aircraft.weight_balance.Payload.Passenger_weight_coefficient = PassengerWeightCoeff(1, n);
aircraft.weight_balance.Payload.Weight_per_passenger = WeightPerPassenger(1, n);
aircraft.weight_balance.Payload.Weight_increment_per_passenger = IncrementPerPassenger(1, n);

% WB crew
aircraft.weight_balance.Crew.Pilots_x_cg = PilotsXCG(1, n);
aircraft.weight_balance.Crew.Pilots_y_cg = PilotsYCG(1, n);
aircraft.weight_balance.Crew.Pilots_z_cg = PilotsZCG(1, n);
aircraft.weight_balance.Crew.Crew_and_carry_on = CrewAndCarryonWeight(1, n);
%--------------------------------------------------------------------------
%
% Values used/modified by WB and saved in other 'aircraft' struct fields

% Miscellaneous
aircraft.miscellaneous.Target_operating_ceiling = TargetOperatingCeiling(1, n);
aircraft.miscellaneous.Design_classification = DesignClassification(1, n);
aircraft.miscellaneous.Spoiler_effectivity = SpoilerEffectivity(1, n);
aircraft.miscellaneous.Undercarriage_layout = UndercarriageLayout(1, n);

% Added to allow principal landing gear positioning into x-z plane
% SR 11/01/12
aircraft.miscellaneous.main_landing_gear_x_cg = LandingGearXCG(n);
aircraft.miscellaneous.main_landing_gear_z_cg = LandingGearZCG(n);
aircraft.miscellaneous.aux_landing_gear_x_cg = ALandingGearXCG(n);
aircraft.miscellaneous.aux_landing_gear_z_cg = ALandingGearZCG(n);

% Cabin
aircraft.cabin.Passenger_accomodation = Passengers(1, n);
aircraft.cabin.Seats_abreast_in_fuselage = SeatsAbreast(1, n);
aircraft.cabin.Seat_pitch = cabnspt(1, n);
aircraft.cabin.Cabin_length_to_aft_cab = CabinLength(1, n);
aircraft.cabin.Cabin_max_internal_height = CabinMaxHeight(1, n);
aircraft.cabin.Cabin_max_internal_width = CabinMaxWidth(1, n);
aircraft.cabin.Cabin_floor_width = CabinFloorWidth(1, n);
aircraft.cabin.Cabin_volume = CabinVolume(1, n);
aircraft.cabin.Maximum_cabin_altitude = CabinMaxAltitude(1, n);
aircraft.cabin.Max_pressure_differential = CabinPressureDifferentialKPa(1, n)*1000;
aircraft.cabin.Cabin_attendant_number = CrewNumber(1, n);
aircraft.cabin.Flight_crew_number = FlightCrewNumber(1, n);

% Baggage
aircraft.Baggage.Baggage_apex_per_fuselgt = BaggageApex(1, n);
aircraft.Baggage.Baggage_combined_length = BaggageLength(1, n);
aircraft.Baggage.gross_volume = BaggageVolume(1, n);

% Additional parameters (needed by W&B)
aircraft.weight_balance.flight_envelope_prediction.VD_Flight_envelope_dive = VDkn(1, n);
aircraft.weight_balance.flight_envelope_prediction.VMO_Flight_envelope = VMOkn(1, n);
aircraft.stability.All_up_weight = STACAUW(1, n);
%

% Return updated aircraft struct
out = aircraft;

% end weight_xml


%--------------------------------------------------------------------------
% AUXILIARY FUNCTIONS
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Computes the local chord length at given span station
%          compute chord on actual planform geometry
%
% function chord = Wing_Chord_At_Span(spanin, spanmtrx, rcrd, tapmtrx, z)

	% if spanin == spanmtrx(1) || spanin == spanmtrx(1)+spanmtrx(2)
   		% correct = -1;% correction to heavyside result
	% else
   		% correct = 0;% no correction to heavyside required
    % end
    
	% identify the taper ratio for given wing segment
	% taprs = tapmtrx(correct + 1 + qxheavy(spanin, spanmtrx(1), 1) + qxheavy(spanin, spanmtrx(1)+spanmtrx(2), 1), z);
	% identify the local span length for given wing segment           
	% spanc = spanmtrx(correct + 1 + qxheavy(spanin, spanmtrx(1), 1) + qxheavy(spanin, spanmtrx(1)+spanmtrx(2), 1));
	% additional corrections before interpolation is executed 
    
	% if spanin > spanmtrx(1) && spanin < spanmtrx(1)+spanmtrx(2)

   		% spanin = spanin-spanmtrx(1);% correct input span to local datum
   		% taprs = taprs/tapmtrx(1,z);% correct identified taper to local datum
   		% rcrd = rcrd*tapmtrx(1,z);% correct for local chord datum   

	% elseif spanin >= spanmtrx(1)+spanmtrx(2)   

   		% spanin = spanin-spanmtrx(1)-spanmtrx(2);% correct input span to local datum
   		% taprs = taprs/tapmtrx(2,z);% correct identified taper to local datum
   		% rcrd = rcrd*tapmtrx(2,z);% correct for local chord datum   

	% end
	
	% chord = rcrd*(1-(1-taprs)*spanin/spanc);% computed chord result

% return

% function [gengewei, gnacewei, gpylnwei, gpropwei] = ewcomp(gMaxThrust, gReverserEffectiveness, gEnginesLayout, gEnginesType, id, z)

	% kthrr = 1+0.18*gReverserEffectiveness(id,z)/100;% factor to increase weight due to thrust rev.
	% gpropwei = 6.13*qxheavy(gEnginesType(id,z),1,1)*gMaxThrust(id,z);% propeller 
	% gengewei = 0.0117*(1+0.2*qxheavy(gEnginesType(id,z),1,1))*(gMaxThrust(id, z)*1000)^1.0572;% dry engine weight
	% gnacewei = 0.345*(1+qxheavy(gEnginesLayout(id,z),4,1))*(1-0.53*qxheavy(gEnginesType(id, z),1,1))*kthrr*gengewei;% nacelle weight
	% gpylnwei = 0.574*(1-qxheavy(gEnginesLayout(id,z),4,1))*(1-qxheavy(gEnginesType(id, z),1,1))*gengewei^0.736;% pylon weight

% return
%--------------------------------------------------------------------------
% Conversion from CAS to TAS for given ISA deviation and altitude

% function ckspd = qxdctks(spd, alt, disa)

	% ckspd = 1479.1 * (qxdthet(alt,disa) * ((((1/(qxdsigm(alt,disa)*qxdthet(alt,disa))*(((1+...
        % ((spd/661.4786)^2)*0.2)^3.5)-1)+1)^(1/3.5))-1)))^0.5;

% return
%--------------------------------------------------------------------------
% Conversion from TAS to Mach Number for given ISA deviation and altitude

% function kmspd = qxdktms(spd, alt, disa)

	% kmspd = spd * 0.5144/(340.3*qxdthet(alt,disa)^0.5);

% return
%--------------------------------------------------------------------------
% Computes the density lapse ratio for given ISA deviation and flight level
%
% function sigma = qxdsigm(alt, disa)
	
	% if alt < 0.0001
   		% alt = 0.0001; % change zero to something small
	% end
	% density lapse ratio at ISA
	% isigm = (qxdthet(alt,0)^4.2561)+qxheavy(alt,361,0)*(2.583-0.4398*(log(alt)));
	% sigma = qxdthet(alt,0)*isigm/qxdthet(alt,disa);% density lapse ratio at dISA

% return
%--------------------------------------------------------------------------
% Computes the temperature lapse ratio for given ISA deviation and flight level
%
% function temper = qxdthet(alt, disa)
	
	% if alt<0.0001

	   % alt = 0.0001;% change zero to something small

	% end

	% temper = 1+(1454*qxheavy(alt,361,0)*(0.00069*alt-0.248)+5.046*disa-alt)/1454;

% return
%--------------------------------------------------------------------------
% A heavyside step function to switch "on" or "off"
%
% function comp1 = qxheavy(input, limit, type)
	
	% if type < 1
		% comp1 = 0.5 + 0.5*tanh(110*(input - limit));
	% else
		% comp1 = round(0.5+0.5*tanh(110*(input- limit)));
	% end
	
% return
