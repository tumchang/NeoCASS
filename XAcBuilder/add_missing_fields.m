function OUT = add_missing_fields (IN)

%------ Fuselage ----------------------------------------------------------

Fuselage = IN.Fuselage;
Fuselage.present = 1;
Fuselage.z = 0;
Fuselage.x = 0;
Fuselage.y = 0;
Fuselage.X_sect_chord_at_fuse_wing = 0;
Fuselage.geometry_matrix = zeros(6,4);
Fuselage.depth_fuse_vtail = 0;

OUT.Fuselage = Fuselage;

%------ Wing1 -------------------------------------------------------------

Wing1 = IN.Wing1;
Wing1.present = 1;
Wing1.thickness_root = 0;
Wing1.thickness_kink1 = 0;
Wing1.thickness_kink2 = 0;
Wing1.thickness_tip = 0;
Wing1.position = 0;
Wing1.limit_deflection_down = 0;
Wing1.x = 0;
Wing1.y = 0;
Wing1.z = 0;
Wing1.quarter_chord_sweep_inboard = 0;
Wing1.quarter_chord_sweep_midboard = 0;
Wing1.quarter_chord_sweep_outboard = 0;
Wing1.Span_matrix_partition_in_mid_outboard = zeros(3,1);
Wing1.Weighted_taper_ratio = 0;
Wing1.longitudinal_location = 0;
Wing1.vertical_location = 0;
Wing1.Root_Airfoil = [];
Wing1.Kink1_Airfoil = [];
Wing1.Kink2_Airfoil = [];
Wing1.Tip_Airfoil = [];
Wing1.thickness_coefs_matrix = zeros(2,3);
Wing1.Original_estimated_fuse_wing_chrd = 0;
Wing1.Original_planform_tip_chord = 0;
Wing1.Fuse_wing_junct_BL_locale = 0;
Wing1.Total_exposed_area = 0;
Wing1.Fractional_change_vortex_induced_drag_factor = 0;

OUT.Wing1 = Wing1;

%------ Wing2 (not available in NeoCASS)-----------------------------------

Wing2 = Wing1;
Wing2.airfoilRoot = '0012';
Wing2.airfoilKink1 = '0012';
Wing2.airfoilKink2 = '0012';
Wing2.airfoilTip = '0012';
Wing2.present = 0;

OUT.Wing2 = Wing2;

%------ WingMK (not available in NeoCASS)----------------------------------

WingMK.present = 0;
WingMK.area = 0;
WingMK.Span = 0;
WingMK.AR = 0;
for i = 1:10
    field1 = ['spanwise_kink' num2str(i)];
    field2 = ['taper_kink' num2str(i)];
    WingMK.(field1) = 0;
    WingMK.(field2) = 0;
end
WingMK.taper_tip = 0;
WingMK.root_incidence = 0;
for i = 1:10
    field1 = ['incidence_kink' num2str(i)];
    WingMK.(field1) = 0;
end
WingMK.tip_incidence = 0;
WingMK.LE_sweep_inboard = 0;
letters = ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I'];
for i=1:length(letters)
    field = ['LE_sweep_midboard_' letters(i)];
    WingMK.(field) = 0;
end
WingMK.LE_sweep_outboard = 0;
WingMK.LE_dihedral_inboard = 0;
for i=1:length(letters)
    field = ['LE_dihedral_midboard_' letters(i)];
    WingMK.(field) = 0;
end
WingMK.LE_dihedral_outboard = 0;
WingMK.airfoilRoot = '0012';
for i=1:10
    field = ['airfoilKink' num2str(i)];
    WingMK.(field) = '0012';
end
WingMK.airfoilTip = '0012';
WingMK.thickness_root = 0;
for i=1:10
    field = ['thickness_kink' num2str(i)];
    WingMK.(field) = 0;
end
WingMK.thickness_tip = 0;
WingMK.reference_convention = 0;
WingMK.configuration = 0;
WingMK.winglet = OUT.Wing1.winglet;
WingMK.flap.present = 0;
WingMK.flap.root_chord = 0;
for i=1:10
    field = ['kink' num2str(i) '1_chord'];
    WingMK.flap.(field) = 0;
end
WingMK.aileron = OUT.Wing1.aileron;
WingMK.slat = OUT.Wing1.slat;
WingMK.fairing = OUT.Wing1.fairing;
WingMK.placement = 0;
WingMK.apex_locale = 0;
WingMK.Sectors_AsWinglets = 0;
WingMK.winglet_start_at_kink = 0;
WingMK.area_Corr = 0;
WingMK.Span_Corr = 0;
WingMK.AR_Corr = 0;
WingMK.x = 0;
WingMK.y = 0;
WingMK.z = 0;

OUT.WingMK = WingMK;

%------ Horizontal_tail ---------------------------------------------------

Horizontal_tail = IN.Horizontal_tail;
Horizontal_tail.thickness_root = 0;
Horizontal_tail.thickness_kink = 0;
Horizontal_tail.thickness_tip = 0;
Horizontal_tail.limit_tailplane_deflection_up = 0;
Horizontal_tail.limit_tailplane_deflection_down = 0;
Horizontal_tail.x = 0;
Horizontal_tail.y = 0;
Horizontal_tail.z = 0;
Horizontal_tail.quarter_chord_sweep_inboard = 0;
Horizontal_tail.quarter_chord_sweep_outboard = 0;
Horizontal_tail.original_root_chord = 0;
Horizontal_tail.reference_wing_area = 0;
Horizontal_tail.reference_wing_taper_ratio = 0;
Horizontal_tail.reference_wing_LE_chord_sweep = 0;
Horizontal_tail.reference_wing_quarter_chord_sweep = 0;
Horizontal_tail.reference_wing_half_chord_sweep = 0;
Horizontal_tail.reference_wing_MAC = 0;
Horizontal_tail.reference_wing_Y_bar_non_dim = 0;
Horizontal_tail.reference_wing_mean.thickness = 0;
Horizontal_tail.Moment_arm_to_HT = 0;
Horizontal_tail.Span_matrix_partition_in_mid_outboard = zeros(3,1);
Horizontal_tail.longitudinal_location = 0;
Horizontal_tail.vertical_location = 0;
Horizontal_tail.thickness_coefs_matrix = zeros(2,3);
Horizontal_tail.Root_Airfoil = 0;
Horizontal_tail.Kink_Airfoil = 0;
Horizontal_tail.Tip_Airfoil = 0;

OUT.Horizontal_tail = Horizontal_tail;

%------ Vertical_tail -----------------------------------------------------

Vertical_tail = IN.Vertical_tail;
Vertical_tail.thickness_root = 0;
Vertical_tail.thickness_kink = 0;
Vertical_tail.thickness_tip = 0;
Vertical_tail.x = 0;
Vertical_tail.y = 0;
Vertical_tail.z = 0;
Vertical_tail.Dorsal_location = 0;
Vertical_tail.Dorsal_sweep = 0;
Vertical_tail.Bullet_more_vertical_tip_chord = 0;
Vertical_tail.Bullet_fairing_slenderness = 0;
Vertical_tail.quarter_chord_sweep_inboard = 0;
Vertical_tail.quarter_chord_sweep_outboard = 0;
Vertical_tail.original_root_chord = 0;
Vertical_tail.reference_wing_area = 0;
Vertical_tail.reference_wing_taper_ratio = 0;
Vertical_tail.reference_wing_LE_sweep = 0;
Vertical_tail.reference_wing_quarter_chord_sweep = 0;
Vertical_tail.reference_wing_Half_chord_sweep = 0;
Vertical_tail.reference_wing_MAC = 0;
Vertical_tail.reference_Y_bar_non_dim = 0;
Vertical_tail.reference_wing_mean_thickness = 0;
Vertical_tail.Moment_arm_to_VT = 0;
Vertical_tail.Span_matrix_partition_in_mid_outboard = zeros(3,1);
Vertical_tail.longitudinal_location = 0;
Vertical_tail.vertical_location = 0;
Vertical_tail.thickness_coefs_matrix = zeros(2,3);
Vertical_tail.Root_Airfoil = 0;
Vertical_tail.Kink_Airfoil = 0;
Vertical_tail.Tip_Airfoil = 0;

OUT.Vertical_tail = Vertical_tail;

%------ Engines1 ----------------------------------------------------------

Engines1 = IN.Engines1;
Engines1.y = 0;
Engines1.x = 0;
Engines1.z = 0;
Engines1.Nacelle1.d_max = 0;
Engines1.Nacelle1.fineness_ratio = 0;
Engines1.Nacelle1.toe_in = 0;
Engines1.Nacelle1.pitch = 0;
Engines1.Pylon1.longitudinal_location = 0;
Engines1.Pylon1.vertical_location = 0;
Engines1.Pylon1.lateral_location = 0;
Engines1.Pylon1.rotation = 0;
Engines1.Pylon1.root_chord = 0;
Engines1.Pylon1.taper_kink1 = 0;
Engines1.Pylon1.taper_kink2 = 0;
Engines1.Pylon1.taper_tip = 0;
Engines1.Pylon1.LE_sweep_inboard = 0;
Engines1.Pylon1.LE_sweep_midboard = 0;
Engines1.Pylon1.LE_sweep_outboard = 0;
Engines1.Pylon1.inboard_span = 0;
Engines1.Pylon1.midboard_span = 0;
Engines1.Pylon1.outboard_span = 0;
Engines1.Pylon2 = Engines1.Pylon1;
Engines1.Nacelle2 = Engines1.Nacelle1;

OUT.Engines1 = Engines1;

%------ Engines2 ----------------------------------------------------------

Engines2 = IN.Engines2;
Engines2.Thrust_to_weight_ratio = 0;
Engines2.y = 0;
Engines2.x = 0;
Engines2.z = 0;
Engines2.Nacelle3.d_max = 0;
Engines2.Nacelle3.fineness_ratio = 0;
Engines2.Nacelle3.toe_in = 0;
Engines2.Nacelle3.pitch = 0;
Engines2.Pylon3.longitudinal_location = 0;
Engines2.Pylon3.vertical_location = 0;
Engines2.Pylon3.lateral_location = 0;
Engines2.Pylon3.rotation = 0;
Engines2.Pylon3.root_chord = 0;
Engines2.Pylon3.taper_kink1 = 0;
Engines2.Pylon3.taper_kink2 = 0;
Engines2.Pylon3.taper_tip = 0;
Engines2.Pylon3.LE_sweep_inboard = 0;
Engines2.Pylon3.LE_sweep_midboard = 0;
Engines2.Pylon3.LE_sweep_outboard = 0;
Engines2.Pylon3.inboard_span = 0;
Engines2.Pylon3.midboard_span = 0;
Engines2.Pylon3.outboard_span = 0;
Engines2.Pylon4 = Engines2.Pylon3;
Engines2.Nacelle4 = Engines2.Nacelle3;

OUT.Engines2 = Engines2;

%------ Tailbooms ---------------------------------------------------------

Tailbooms = IN.Tailbooms;
Tailbooms.y = 0;
Tailbooms.x = 0;
Tailbooms.z = 0;

OUT.Tailbooms = Tailbooms;

%------ Canard ------------------------------------------------------------

Canard = IN.Canard;
Canard.thickness_root = 0;
Canard.thickness_kink = 0;
Canard.thickness_tip = 0;
Canard.Elevator.Span = 1;
Canard.limit_deflection_up = 0;
Canard.limit_deflection_down = 0;
Canard.x = 0;
Canard.y = 0;
Canard.z = 0;
Canard.quarter_chord_sweep_inboard = 0;
Canard.quarter_chord_sweep_outboard = 0;
Canard.original_root_chord = 0;
Canard.reference_wing_area = 0;
Canard.reference_wing_taper_ratio = 0;
Canard.reference_wing_LE_chord_sweep = 0;
Canard.reference_wing_quarter_chord_sweep = 0;
Canard.reference_wing_half_chord_sweep = 0;
Canard.reference_wing_MAC = 0;
Canard.reference_wing_Y_bar_non_dim = 0;
Canard.reference_wing_mean.thickness = 0;
Canard.Moment_arm_to_CA = 0;
Canard.Span_matrix_partition_in_mid_outboard = zeros(3,1);
Canard.thickness_coefs_matrix = zeros(2,3);
Canard.Root_Airfoil = 0;
Canard.Kink_Airfoil = 0;
Canard.Tip_Airfoil = 0;

OUT.Canard = Canard;

%------ Ventral Fin -------------------------------------------------------

Ventral_fin.present = 0;
Ventral_fin.chord_fraction_at_midfuse = 0;
Ventral_fin.Span = 0;
Ventral_fin.spanwise_kink = 0;
Ventral_fin.taper_kink = 0;
Ventral_fin.taper_tip = 0;
Ventral_fin.LE_sweep_inboard = 0;
Ventral_fin.LE_sweep_outboard = 0;
Ventral_fin.cant_inbord = 0;
Ventral_fin.cant_outboard = 0;
Ventral_fin.X_locale = 0;
Ventral_fin.Z_locale = 0;
Ventral_fin.x = 0;
Ventral_fin.y = 0;
Ventral_fin.z = 0;

OUT.Ventral_fin = Ventral_fin;

%------ NewMLG ------------------------------------------------------------

NewMLG = IN.NewMLG;
NewMLG.x_loc_vs_fus = 0;
NewMLG.y_loc_vs_span = 0;
NewMLG.z_loc_vs_fus_diam = 0;
NewMLG.symmetry = 0;
NewMLG.total_length = 0;
NewMLG.diameter = 0;
NewMLG.campo_aggiuntivo = 0;
NewMLG.x = 0;
NewMLG.y = 0;
NewMLG.z = 0;

OUT.NewMLG = NewMLG;

%------ Aux_Landing_Gear --------------------------------------------------

Aux_Landing_Gear = IN.Aux_Landing_Gear;
Aux_Landing_Gear.x_loc_vs_fus = 0;
Aux_Landing_Gear.y_loc_vs_span = 0;
Aux_Landing_Gear.z_loc_vs_fus_diam = 0;
Aux_Landing_Gear.symmetry = 0;
Aux_Landing_Gear.total_length = 0;
Aux_Landing_Gear.diameter = 0;
Aux_Landing_Gear.campo_aggiuntivo = 0;
Aux_Landing_Gear.x = 0;
Aux_Landing_Gear.y = 0;
Aux_Landing_Gear.z = 0;

OUT.Aux_Landing_Gear = Aux_Landing_Gear;

%------ CheckVersion ------------------------------------------------------

OUT.CheckVersion = 1.1;

%------ Reference_wing ----------------------------------------------------

Reference_wing.convention = 0;
Reference_wing.taper_ratio = 0;
Reference_wing.planform_AR = 0;
Reference_wing.Weighted_area = 0;
Reference_wing.LE_sweep = 0;
Reference_wing.MAC = 0;
Reference_wing.relative_apex = 0;
Reference_wing.Orig_root_chrd_at_ac_CL = 0;
Reference_wing.Half_chord_sweep = 0;
Reference_wing.Quarter_chord_sweep = 0;
Reference_wing.non_dim_MAC_y_bar = 0;
Reference_wing.Weighted_aspect_ratio = 0;
Reference_wing.mean_thickness = 0;
Reference_wing.Wing_area_for_weight_balance_analysis = 0;

OUT.Reference_wing = Reference_wing;

%------ Wetted_areas ------------------------------------------------------

Wetted_areas.increment_fuselage_fairing = 0;
Wetted_areas.increment_wings = 0;
Wetted_areas.increment_winglet = 0;
Wetted_areas.increment_Horizontal_tail = 0;
Wetted_areas.increment_Vertical_tail = 0;
Wetted_areas.increment_pylons = 0;
Wetted_areas.increment_powerplant = 0;
Wetted_areas.anciliary_final = 0;
Wetted_areas.Total_wetted_area = 0;
Wetted_areas.Fuselage_fairing = 0;
Wetted_areas.Wings = 0;
Wetted_areas.Winglet = 0;
Wetted_areas.Vertical_tail = 0;
Wetted_areas.Dorsal_fin = 0;
Wetted_areas.Horizontal_tail = 0;
Wetted_areas.Canard = 0;
Wetted_areas.Pylons = 0;
Wetted_areas.Powerplant = 0;

OUT.Wetted_areas = Wetted_areas;

%------ fuel --------------------------------------------------------------

fuel = IN.fuel;
fuel.Aux_wing_spar_loc_root = 0;
fuel.Fore_wing_spar_loc_root = 0;
fuel.Fore_wing_spar_loc_kik1 = 0;
fuel.Fore_wing_spar_loc_kin2 = 0;
fuel.Fore_wing_spar_loc_tip = 0;
fuel.Aft_wing_spar_loc_root = 0;
fuel.Aft_wing_spar_loc_kin1 = 0;
fuel.Aft_wing_spar_loc_kin2 = 0;
fuel.Aft_wing_spar_loc_tip = 0;
fuel.max_weight_wing = 0;
fuel.max_vol_wing = 0;
fuel.max_weight_cent_wing_box = 0;
fuel.max_vol_cent_wing_box = 0;
fuel.max_weight_aux = 0;
fuel.max_vol_aux = 0;

OUT.fuel = fuel;

%------ miscellaneous -----------------------------------------------------

miscellaneous = IN.miscellaneous;
miscellaneous.main_landing_gear_on_fuselage = 0;
% miscellaneous.main_landing_gear_x_cg = 0;
miscellaneous.main_landing_gear_y_cg = 0;
% miscellaneous.main_landing_gear_z_cg = 0;
% miscellaneous.aux_landing_gear_x_cg = 0;
miscellaneous.aux_landing_gear_y_cg = 0;
% miscellaneous.aux_landing_gear_z_cg = 0;

OUT.miscellaneous = miscellaneous;

%------ Baggage -----------------------------------------------------------

OUT.Baggage = IN.Baggage;

%------ cabin -------------------------------------------------------------

cabin = IN.cabin;
cabin.Seat_pitch = 0;
cabin.Max_pressure_differential = 0;

OUT.cabin = cabin;

%------ weight_balance ----------------------------------------------------

weight_balance = IN.weight_balance;
weight_balance.Other_operating_items = 0;
weight_balance.Aux_Landing_gear = 0;
weight_balance.Landing_gear = 0;
weight_balance.Total_systems_or_miscellaneous_x_cg = 0;
weight_balance.Total_systems_or_miscellaneous_y_cg = 0;
weight_balance.Total_systems_or_miscellaneous_z_cg = 0;
weight_balance.Fuel.Maximum_fuel_weight = 0;
weight_balance.Fuel.Fuel_to_MTOW_at_maximum_payload = 0;
weight_balance.Fuel.Fuel_tank_wing_x_cg = 0;
weight_balance.Fuel.Fuel_tank_wing_y_cg = 0;
weight_balance.Fuel.Fuel_tank_wing_z_cg = 0;
weight_balance.Fuel.Fuel_centre_plus_confor_x_cg = 0;
weight_balance.Fuel.Fuel_centre_plus_confor_y_cg = 0;
weight_balance.Fuel.Fuel_centre_plus_confor_z_cg = 0;
weight_balance.Fuel.Fuel_tank_auxiliary_x_cg = 0;
weight_balance.Fuel.Fuel_tank_auxiliary_y_cg = 0;
weight_balance.Fuel.Fuel_tank_auxiliary_z_cg = 0;
weight_balance.Fuel.Fuel_in_wing_x_cg = 0;
weight_balance.Fuel.Fuel_in_wing_y_cg = 0;
weight_balance.Fuel.Fuel_in_wing_z_cg = 0;
weight_balance.Fuel.Fuel_in_fairings_x_cg = 0;
weight_balance.Fuel.Fuel_in_fairings_y_cg = 0;
weight_balance.Fuel.Fuel_in_fairings_z_cg = 0;
weight_balance.Fuel.Fuel_in_auxiliary_tanks_x_cg = 0;
weight_balance.Fuel.Fuel_in_auxiliary_tanks_y_cg = 0;
weight_balance.Fuel.Fuel_in_auxiliary_tanks_z_cg = 0;
weight_balance.Payload.Interiors_completion_x_cg = 0;
weight_balance.Payload.Interiors_completion_y_cg = 0;
weight_balance.Payload.Interiors_completion_z_cg = 0;
weight_balance.Payload.Passengers_x_cg = 0;
weight_balance.Payload.Passengers_y_cg = 0;
weight_balance.Payload.Passengers_z_cg = 0;
weight_balance.Payload.Baggage_and_cargo_x_cg = 0;
weight_balance.Payload.Baggage_and_cargo_y_cg = 0;
weight_balance.Payload.Baggage_and_cargo_z_cg = 0;
weight_balance.Struct.Wings = 0;
weight_balance.Struct.Winglet_and_span_load_penalty = 0;
weight_balance.Struct.Horizontal_tail_and_elevator = 0;
weight_balance.Struct.Vertical_tail_rudder_and_dorsal = 0;
weight_balance.Struct.Ventral_fins = 0;
weight_balance.Struct.Fuselage = 0;
weight_balance.Struct.Horizontal_tail_x_cg = 0;
weight_balance.Struct.Horizontal_tail_y_cg = 0;
weight_balance.Struct.Horizontal_tail_z_cg = 0;
weight_balance.Struct.Vertical_tail_x_cg = 0;
weight_balance.Struct.Vertical_tail_y_cg = 0;
weight_balance.Struct.Vertical_tail_z_cg = 0;
weight_balance.Struct.Vertical_tail2_x_cg = 0;
weight_balance.Struct.Vertical_tail2_y_cg = 0;
weight_balance.Struct.Vertical_tail2_z_cg = 0;
weight_balance.Struct.Fuselage_structure_x_cg = 0;
weight_balance.Struct.Fuselage_structure_y_cg = 0;
weight_balance.Struct.Fuselage_structure_z_cg = 0;
weight_balance.Struct.Canard_x_cg = 0;
weight_balance.Struct.Canard_y_cg = 0;
weight_balance.Struct.Canard_z_cg = 0;
weight_balance.Struct.Tailbooms_x_cg = 0;
weight_balance.Struct.Tailbooms_y_cg = 0;
weight_balance.Struct.Tailbooms_z_cg = 0;
weight_balance.Struct.NewMLG_x_cg = 0;
weight_balance.Struct.NewMLG_y_cg = 0;
weight_balance.Struct.NewMLG_z_cg = 0;
weight_balance.Struct.Aux_Landing_Gear_x_cg = 0;
weight_balance.Struct.Aux_Landing_Gear_y_cg = 0;
weight_balance.Struct.Aux_Landing_Gear_z_cg = 0;
weight_balance.Struct.Wings2 = 0;
weight_balance.Powerplant.Pylons_and_or_propellers = 0;
weight_balance.Powerplant.Engines_acc_propeller_gearbox = 0;
weight_balance.Powerplant.Nacelles = 0;
weight_balance.Crew.Crew_and_carry_on = 0;
weight_balance.Crew.Pilots_x_cg = 0;
weight_balance.Crew.Pilots_y_cg = 0;
weight_balance.Crew.Pilots_z_cg = 0;
weight_balance.Green_Manufacturer_empty_weight = 0;
weight_balance.MTOW_Maximum_takeoff_weight = 0;
weight_balance.OEW_Operational_empty_weight = 0;
weight_balance.Maximum_payload_weight = 0;
weight_balance.Maximum_fuel_weight = 0;
weight_balance.MRW_Maximum_ramp_weight = 0;
weight_balance.MZFW_Maximum_zero_fuel_weight = 0;
weight_balance.Merit.Maximum_payload_per_passenger = 0;
weight_balance.Merit.Payload_to_MTOW_at_MFW = 0;
weight_balance.Merit.Load_factor_to_MTOW_at_MFW = 0;
weight_balance.Merit.Merit_function_OEW_over_MTOW = 0;
weight_balance.Merit.Merit_function_W_over_S_gross = 0;
weight_balance.Merit.Merit_function_thrust_to_weight = 0;
weight_balance.Merit.Merit_function_load_parameter = 0;
weight_balance.MEW_longitudinal_CoG = 0;
weight_balance.MEW_lateral_CoG = 0;
weight_balance.MEW_vertical_CoG = 0;
weight_balance.Maximum_payload_at_MTOW_longitudinal_CoG = 0;
weight_balance.Maximum_payload_at_MTOW_lateral_CoG = 0;
weight_balance.Maximum_payload_at_MTOW_vertical_CoG = 0;
weight_balance.Computed_longitudinal_CoG = 0;
weight_balance.Computed_lateral_CoG = 0;
weight_balance.Computed_vertical_CoG = 0;
weight_balance.Struct1_x_cg = 0;
weight_balance.Struct1_y_cg = 0;
weight_balance.Struct1_z_cg = 0;
weight_balance.Struct2_x_cg = 0;
weight_balance.Struct2_y_cg = 0;
weight_balance.Struct2_z_cg = 0;
weight_balance.Powerplant1_plus_nacelle_plus_pylon_x_cg = 0;
weight_balance.Powerplant1_plus_nacelle_plus_pylon_y_cg = 0;
weight_balance.Powerplant1_plus_nacelle_plus_pylon_z_cg = 0;
weight_balance.Powerplant2_plus_nacelle_plus_pylon_x_cg = 0;
weight_balance.Powerplant2_plus_nacelle_plus_pylon_y_cg = 0;
weight_balance.Powerplant2_plus_nacelle_plus_pylon_z_cg = 0;
weight_balance.miscellaneous.main_landing_gear_x_cg = 0;
weight_balance.miscellaneous.main_landing_gear_y_cg = 0;
weight_balance.miscellaneous.main_landing_gear_z_cg = 0;
weight_balance.miscellaneous.aux_landing_gear_x_cg = 0;
weight_balance.miscellaneous.aux_landing_gear_y_cg = 0;
weight_balance.miscellaneous.aux_landing_gear_z_cg = 0;
weight_balance.MTOW_CoG_x_cg = 0;
weight_balance.MTOW_CoG_y_cg = 0;
weight_balance.MTOW_CoG_z_cg = 0;
weight_balance.MEW_CoG_x_cg = 0;
weight_balance.MEW_CoG_y_cg = 0;
weight_balance.MEW_CoG_z_cg = 0;
weight_balance.Imat = zeros(3,3);
weight_balance.IXXINER = -1;
weight_balance.IYYINER = -1;
weight_balance.IZZINER = -1;
weight_balance.IXZINER = -1;
weight_balance.IYZINER = 0;
weight_balance.IXYINER = 0;
weight_balance.COG_AddOns.Crew = 0;
weight_balance.System.Hydraulic_Pneumatic_weight = 0;
weight_balance.System.Electrical_weight = 0;
weight_balance.System.ECS_anti_icing_grp_weight = 0;
weight_balance.System.Furnishing_Green = 0;
weight_balance.System.Miscellaneous = 0;
weight_balance.System.Compl_allowance_plus_paint = 0;
weight_balance.System.Fuel_system_weight = 0;
weight_balance.System.Flight_controls_weight = 0;
weight_balance.System.APU_weight = 0;
weight_balance.System.Instruments_weight = 0;
weight_balance.System.Avionics_weight = 0;
weight_balance.System.Landing_gear = 0;
weight_balance.System.Aux_Landing_gear = 0;
weight_balance.System.Other_operating_items = 0;
weight_balance.System.Total_systems_or_miscellaneous_x_cg = 0;
weight_balance.System.Total_systems_or_miscellaneous_y_cg = 0;
weight_balance.System.Total_systems_or_miscellaneous_z_cg = 0;
if isfield(weight_balance,'COG')
    weight_balance.COG = IN.weight_balance.COG;
else
    weight_balance.COG = zeros(30,4,15);
end

OUT.weight_balance = weight_balance;

%------ flight_envelope_prediction ----------------------------------------

flight_envelope_prediction.VD_Flight_envelope_dive = 0;
flight_envelope_prediction.VMO_Flight_envelope = 0;

OUT.flight_envelope_prediction = flight_envelope_prediction;

%------ user_input --------------------------------------------------------

OUT.user_input = IN.user_input;

%------ experienced_user_input --------------------------------------------

OUT.experienced_user_input = IN.experienced_user_input;

%------ stability ---------------------------------------------------------

OUT.stability.All_up_weight = 0;

%------ MiscGeometry ------------------------------------------------------

MiscGeometry.WingLets.Wing1.Sy = 0;
MiscGeometry.WingLets.Wing1.Sx = 0;
MiscGeometry.WingLets.Wing1.Sz = 0;
MiscGeometry.WingLets.Wing2.Sy = 0;
MiscGeometry.WingLets.Wing2.Sx = 0;
MiscGeometry.WingLets.Wing2.Sz = 0;
MiscGeometry.WingLets.WingMK.Sy = 0;
MiscGeometry.WingLets.WingMK.Sx = 0;
MiscGeometry.WingLets.WingMK.Sz = 0;

OUT.MiscGeometry = MiscGeometry;

%------ Fairing1 ----------------------------------------------------------

if isfield(IN,'Fairing1')
    OUT.Fairing1 = IN.Fairing1;
end

%------ Fairing2 ----------------------------------------------------------

Fairing2.present = 0;
Fairing2.Forward_chord_fraction = 0;
Fairing2.Aft_chord_fraction = 0;
Fairing2.flushness = 0;

OUT.Fairing2 = Fairing2;

%------ Designation -------------------------------------------------------

OUT.designation = 0;

%------ wing --------------------------------------------------------------

OUT.wing.Fractional_change_vortex_induced_drag_factor = 0;

%------ Sponson -----------------------------------------------------------

OUT.Sponson.length = 0;

%------ Engines_results ---------------------------------------------------

OUT.Engines_results.wing_chord_at_engine_location = 0;

%------ Checks ------------------------------------------------------------

OUT.check.geo = 0;
OUT.check.wb = 0;

%------ Added Masses ------------------------------------------------------

if isfield(IN,'added_masses')
    OUT.added_masses = IN.added_masses;
end