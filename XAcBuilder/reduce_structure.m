function OUT = reduce_structure (IN)

%------ Check if geometry module has been executed ------------------------

geoF = 0;
if isfield(IN,'check')
    if IN.check.geo
        geoF = 1;
    end
end

%------ Fuselage ----------------------------------------------------------

Fuselage.present = IN.Fuselage.present;
if Fuselage.present
    Fuselage.omega_nose = IN.Fuselage.omega_nose;
    Fuselage.phi_nose = IN.Fuselage.phi_nose;
    Fuselage.epsilon_nose = IN.Fuselage.epsilon_nose;
    Fuselage.Forefuse_X_sect_vertical_diameter = IN.Fuselage.Forefuse_X_sect_vertical_diameter;
    Fuselage.Forefuse_X_sect_horizontal_diameter = IN.Fuselage.Forefuse_X_sect_horizontal_diameter;
    Fuselage.Forefuse_Xs_distortion_coefficient = IN.Fuselage.Forefuse_Xs_distortion_coefficient;
    Fuselage.Nose_length = IN.Fuselage.Nose_length;
    Fuselage.fraction_fore = IN.Fuselage.fraction_fore;
    Fuselage.shift_fore = IN.Fuselage.shift_fore;
    Fuselage.omega_tail = IN.Fuselage.omega_tail;
    Fuselage.phi_tail = IN.Fuselage.phi_tail;
    Fuselage.epsilon_tail = IN.Fuselage.epsilon_tail;
    Fuselage.Aftfuse_X_sect_vertical_diameter = IN.Fuselage.Aftfuse_X_sect_vertical_diameter;
    Fuselage.Aftfuse_X_sect_horizontal_diameter = IN.Fuselage.Aftfuse_X_sect_horizontal_diameter;
    Fuselage.Aftfuse_Xs_distortion_coefficient = IN.Fuselage.Aftfuse_Xs_distortion_coefficient;
    Fuselage.Tail_length = IN.Fuselage.Tail_length;
    Fuselage.Total_fuselage_length = IN.Fuselage.Total_fuselage_length;
    Fuselage.a0_fore = IN.Fuselage.a0_fore;
    Fuselage.a1_fore = IN.Fuselage.a1_fore;
    Fuselage.b1_fore = IN.Fuselage.b1_fore;
    Fuselage.a0_aft = IN.Fuselage.a0_aft;
    Fuselage.a1_aft = IN.Fuselage.a1_aft;
    Fuselage.b1_aft = IN.Fuselage.b1_aft;
end
OUT.Fuselage = Fuselage;

%------ Wing1 -------------------------------------------------------------

Wing1.present = IN.Wing1.present;
if Wing1.present
    Wing1.area = IN.Wing1.area;
    Wing1.Span = IN.Wing1.Span;
    Wing1.AR = IN.Wing1.AR;
    Wing1.spanwise_kink1 = IN.Wing1.spanwise_kink1;
    Wing1.spanwise_kink2 = IN.Wing1.spanwise_kink2;
    Wing1.taper_kink1 = IN.Wing1.taper_kink1;
    Wing1.taper_kink2 = IN.Wing1.taper_kink2;
    Wing1.taper_tip = IN.Wing1.taper_tip;
    Wing1.root_incidence = IN.Wing1.root_incidence;
    Wing1.kink1_incidence = IN.Wing1.kink1_incidence;
    Wing1.kink2_incidence = IN.Wing1.kink2_incidence;
    Wing1.tip_incidence = IN.Wing1.tip_incidence;
    Wing1.LE_sweep_inboard = IN.Wing1.LE_sweep_inboard;
    Wing1.LE_sweep_midboard = IN.Wing1.LE_sweep_midboard;
    Wing1.LE_sweep_outboard = IN.Wing1.LE_sweep_outboard;
    Wing1.dihedral_inboard = IN.Wing1.dihedral_inboard;
    Wing1.dihedral_midboard = IN.Wing1.dihedral_midboard;
    Wing1.dihedral_outboard = IN.Wing1.dihedral_outboard;
    Wing1.airfoilRoot = IN.Wing1.airfoilRoot;
    Wing1.airfoilKink1 = IN.Wing1.airfoilKink1;
    Wing1.airfoilKink2 = IN.Wing1.airfoilKink2;
    Wing1.airfoilTip = IN.Wing1.airfoilTip;
    Wing1.thickness_root = IN.Wing1.thickness_root;
    Wing1.thickness_kink1 = IN.Wing1.thickness_kink1;
    Wing1.thickness_kink2 = IN.Wing1.thickness_kink2;
    Wing1.thickness_tip = IN.Wing1.thickness_tip;
    Wing1.reference_convention = IN.Wing1.reference_convention;
    Wing1.configuration = IN.Wing1.configuration;
    Wing1.winglet.present = IN.Wing1.winglet.present;
    Wing1.winglet.Span = IN.Wing1.winglet.Span;
    Wing1.winglet.taper_ratio = IN.Wing1.winglet.taper_ratio;
    Wing1.winglet.LE_sweep = IN.Wing1.winglet.LE_sweep;
    Wing1.winglet.Cant_angle = IN.Wing1.winglet.Cant_angle;
    Wing1.winglet.root_incidence = IN.Wing1.winglet.root_incidence;
    Wing1.winglet.tip_incidence = IN.Wing1.winglet.tip_incidence;
    Wing1.flap.present = IN.Wing1.flap.present;
    Wing1.flap.root_chord = IN.Wing1.flap.root_chord;
    Wing1.flap.kink1_chord = IN.Wing1.flap.kink1_chord;
    Wing1.flap.kink2_chord = IN.Wing1.flap.kink2_chord;
    Wing1.aileron.present = IN.Wing1.aileron.present;
    Wing1.aileron.chord = IN.Wing1.aileron.chord;
    Wing1.aileron.position = IN.Wing1.aileron.position;
    Wing1.aileron.Span = IN.Wing1.aileron.Span;
    Wing1.aileron.limit_deflection_up = IN.Wing1.aileron.limit_deflection_up;
    Wing1.slat.present = IN.Wing1.slat.present;
    Wing1.slat.chord = IN.Wing1.slat.chord;
    Wing1.slat.root_position = IN.Wing1.slat.root_position;
    Wing1.slat.tip_position = IN.Wing1.slat.tip_position;
    Wing1.fairing.present = IN.Wing1.fairing.present;
    Wing1.fairing.Forward_chord_fraction = IN.Wing1.fairing.Forward_chord_fraction;
    Wing1.fairing.Aft_chord_fraction = IN.Wing1.fairing.Aft_chord_fraction;
    Wing1.fairing.flushness = IN.Wing1.fairing.flushness;
    Wing1.placement = IN.Wing1.placement;
    Wing1.apex_locale = IN.Wing1.apex_locale;
    if geoF
        Wing1.quarter_chord_sweep_inboard = IN.Wing1.quarter_chord_sweep_inboard;
        Wing1.quarter_chord_sweep_midboard = IN.Wing1.quarter_chord_sweep_midboard;
        Wing1.quarter_chord_sweep_outboard = IN.Wing1.quarter_chord_sweep_outboard;
        Wing1.longitudinal_location = IN.Wing1.longitudinal_location;
        Wing1.vertical_location = IN.Wing1.vertical_location;
        Wing1.Span_matrix_partition_in_mid_outboard = IN.Wing1.Span_matrix_partition_in_mid_outboard;
    end
    Wing1.x = IN.Wing1.x;
    Wing1.z = IN.Wing1.z;
end
OUT.Wing1 = Wing1;

%------ Horizontal_tail ---------------------------------------------------

Horizontal_tail.present = IN.Horizontal_tail.present;
if Horizontal_tail.present
    Horizontal_tail.area = IN.Horizontal_tail.area;
    Horizontal_tail.Span = IN.Horizontal_tail.Span;
    Horizontal_tail.AR = IN.Horizontal_tail.AR;
    Horizontal_tail.spanwise_kink = IN.Horizontal_tail.spanwise_kink;
    Horizontal_tail.taper_kink = IN.Horizontal_tail.taper_kink;
    Horizontal_tail.taper_tip = IN.Horizontal_tail.taper_tip;
    Horizontal_tail.root_incidence = IN.Horizontal_tail.root_incidence;
    Horizontal_tail.kink_incidence = IN.Horizontal_tail.kink_incidence;
    Horizontal_tail.tip_incidence = IN.Horizontal_tail.tip_incidence;
    Horizontal_tail.LE_sweep_inboard = IN.Horizontal_tail.LE_sweep_inboard;
    Horizontal_tail.LE_sweep_outboard = IN.Horizontal_tail.LE_sweep_outboard;
    Horizontal_tail.dihedral_inboard = IN.Horizontal_tail.dihedral_inboard;
    Horizontal_tail.dihedral_outboard = IN.Horizontal_tail.dihedral_outboard;
    Horizontal_tail.airfoilRoot = IN.Horizontal_tail.airfoilRoot;
    Horizontal_tail.airfoilKink = IN.Horizontal_tail.airfoilKink;
    Horizontal_tail.airfoilTip = IN.Horizontal_tail.airfoilTip;
    Horizontal_tail.thickness_root = IN.Horizontal_tail.thickness_root;
    Horizontal_tail.thickness_kink = IN.Horizontal_tail.thickness_kink;
    Horizontal_tail.thickness_tip = IN.Horizontal_tail.thickness_tip;
    Horizontal_tail.empennage_layout = IN.Horizontal_tail.empennage_layout;
    Horizontal_tail.Elevator.present = IN.Horizontal_tail.Elevator.present;
    Horizontal_tail.Elevator.chord = IN.Horizontal_tail.Elevator.chord;
    Horizontal_tail.Elevator.Span = IN.Horizontal_tail.Elevator.Span;
    Horizontal_tail.Elevator.limit_deflection_up = IN.Horizontal_tail.Elevator.limit_deflection_up;
    Horizontal_tail.Elevator.limit_deflection_down = IN.Horizontal_tail.Elevator.limit_deflection_down;
    Horizontal_tail.apex_locale = IN.Horizontal_tail.apex_locale;
    Horizontal_tail.vertical_locale = IN.Horizontal_tail.vertical_locale;
    if geoF
        Horizontal_tail.quarter_chord_sweep_inboard = IN.Horizontal_tail.quarter_chord_sweep_inboard;
        Horizontal_tail.quarter_chord_sweep_outboard = IN.Horizontal_tail.quarter_chord_sweep_outboard;
        Horizontal_tail.longitudinal_location = IN.Horizontal_tail.longitudinal_location;
        Horizontal_tail.vertical_location = IN.Horizontal_tail.vertical_location;
        Horizontal_tail.limit_tailplane_deflection_up = IN.Horizontal_tail.limit_tailplane_deflection_up;
        Horizontal_tail.limit_tailplane_deflection_down = IN.Horizontal_tail.limit_tailplane_deflection_down;
        Horizontal_tail.Moment_arm_to_HT = IN.Horizontal_tail.Moment_arm_to_HT;
        Horizontal_tail.reference_wing_half_chord_sweep = IN.Horizontal_tail.reference_wing_half_chord_sweep;
    end
    Horizontal_tail.x = IN.Horizontal_tail.x;
    Horizontal_tail.z = IN.Horizontal_tail.z;
end
OUT.Horizontal_tail = Horizontal_tail;

%------ Vertical_tail -----------------------------------------------------

Vertical_tail.present = IN.Vertical_tail.present;
if Vertical_tail.present
    Vertical_tail.area = IN.Vertical_tail.area;
    Vertical_tail.Span = IN.Vertical_tail.Span;
    Vertical_tail.AR = IN.Vertical_tail.AR;
    Vertical_tail.spanwise_kink = IN.Vertical_tail.spanwise_kink;
    Vertical_tail.taper_kink = IN.Vertical_tail.taper_kink;
    Vertical_tail.taper_tip = IN.Vertical_tail.taper_tip;
    Vertical_tail.root_incidence = IN.Vertical_tail.root_incidence;
    Vertical_tail.kink_incidence = IN.Vertical_tail.kink_incidence;
    Vertical_tail.tip_incidence = IN.Vertical_tail.tip_incidence;
    Vertical_tail.LE_sweep_inboard = IN.Vertical_tail.LE_sweep_inboard;
    Vertical_tail.LE_sweep_outboard = IN.Vertical_tail.LE_sweep_outboard;
    Vertical_tail.dihedral_inboard = IN.Vertical_tail.dihedral_inboard;
    Vertical_tail.dihedral_outboard = IN.Vertical_tail.dihedral_outboard;
    Vertical_tail.airfoilRoot = IN.Vertical_tail.airfoilRoot;
    Vertical_tail.airfoilKink = IN.Vertical_tail.airfoilKink;
    Vertical_tail.airfoilTip = IN.Vertical_tail.airfoilTip;
    Vertical_tail.thickness_root = IN.Vertical_tail.thickness_root;
    Vertical_tail.thickness_kink = IN.Vertical_tail.thickness_kink;
    Vertical_tail.thickness_tip = IN.Vertical_tail.thickness_tip;
    Vertical_tail.Rudder.present = IN.Vertical_tail.Rudder.present;
    Vertical_tail.Rudder.chord = IN.Vertical_tail.Rudder.chord;
    Vertical_tail.Rudder.Span = IN.Vertical_tail.Rudder.Span;
    Vertical_tail.Rudder.limit_deflection = IN.Vertical_tail.Rudder.limit_deflection;
    Vertical_tail.Twin_tail = IN.Vertical_tail.Twin_tail;
    Vertical_tail.Twin_tail_span = IN.Vertical_tail.Twin_tail_span;
    Vertical_tail.vertical_locale = IN.Vertical_tail.vertical_locale;
    Vertical_tail.apex_locale = IN.Vertical_tail.apex_locale;
    if geoF
        Vertical_tail.quarter_chord_sweep_inboard = IN.Vertical_tail.quarter_chord_sweep_inboard;
        Vertical_tail.quarter_chord_sweep_outboard = IN.Vertical_tail.quarter_chord_sweep_outboard;
        Vertical_tail.longitudinal_location = IN.Vertical_tail.longitudinal_location;
        Vertical_tail.vertical_location = IN.Vertical_tail.vertical_location;
    end
    Vertical_tail.x = IN.Vertical_tail.x;
    Vertical_tail.z = IN.Vertical_tail.z;
    
    if geoF
        Vertical_tail.reference_wing_area = IN.Vertical_tail.reference_wing_area;
        Vertical_tail.reference_wing_taper_ratio = IN.Vertical_tail.reference_wing_taper_ratio;
        Vertical_tail.reference_wing_quarter_chord_sweep = IN.Vertical_tail.reference_wing_quarter_chord_sweep;
        Vertical_tail.original_root_chord = IN.Vertical_tail.original_root_chord;
        Vertical_tail.reference_Y_bar_non_dim = IN.Vertical_tail.reference_Y_bar_non_dim;
        Vertical_tail.Moment_arm_to_VT = IN.Vertical_tail.Moment_arm_to_VT;
    end
end
OUT.Vertical_tail = Vertical_tail;

%------ Engines1 ----------------------------------------------------------

Engines1.present = IN.Engines1.present;
if Engines1.present
    Engines1.Layout_and_config = IN.Engines1.Layout_and_config;
    Engines1.Propulsion_type = IN.Engines1.Propulsion_type;
    Engines1.Nacelle_body_type = IN.Engines1.Nacelle_body_type;
    Engines1.symmetry = IN.Engines1.symmetry;
    Engines1.Y_locale = IN.Engines1.Y_locale;
    Engines1.X_locale = IN.Engines1.X_locale;
    Engines1.Z_locale = IN.Engines1.Z_locale;
    Engines1.fineness_ratio = IN.Engines1.fineness_ratio;
    Engines1.d_max = IN.Engines1.d_max;
    Engines1.toe_in = IN.Engines1.toe_in;
    Engines1.pitch = IN.Engines1.pitch;
    Engines1.Thrust_to_weight_ratio = IN.Engines1.Thrust_to_weight_ratio;
    Engines1.Propeller_diameter = IN.Engines1.Propeller_diameter;
    Engines1.Max_thrust = IN.Engines1.Max_thrust;
    Engines1.Bypass_ratio_to_emulate = IN.Engines1.Bypass_ratio_to_emulate;
    Engines1.Thrust_reverser_effectivness = IN.Engines1.Thrust_reverser_effectivness;
    Engines1.Fan_cowl_length_ratio = IN.Engines1.Fan_cowl_length_ratio;
    if geoF
        Engines1.Number_of_engines = IN.Engines1.Number_of_engines;
        Engines1.Nacelle1.longitudinal_location = IN.Engines1.Nacelle1.longitudinal_location;
        Engines1.Nacelle1.vertical_location = IN.Engines1.Nacelle1.vertical_location;
        Engines1.Nacelle1.lateral_location = IN.Engines1.Nacelle1.lateral_location;
        Engines1.Nacelle_length_array = IN.Engines1.Nacelle_length_array;
    end
end
OUT.Engines1 = Engines1;

%------ Engines2 ----------------------------------------------------------

Engines2.present = IN.Engines2.present;
if Engines2.present
    Engines2.Layout_and_config = IN.Engines2.Layout_and_config;
    Engines2.Propulsion_type = IN.Engines2.Propulsion_type;
    Engines2.Nacelle_body_type = IN.Engines2.Nacelle_body_type;
    Engines2.symmetry = IN.Engines2.symmetry;
    Engines2.Y_locale = IN.Engines2.Y_locale;
    Engines2.X_locale = IN.Engines2.X_locale;
    Engines2.Z_locale = IN.Engines2.Z_locale;
    Engines2.fineness_ratio = IN.Engines2.fineness_ratio;
    Engines2.d_max = IN.Engines2.d_max;
    Engines2.toe_in = IN.Engines2.toe_in;
    Engines2.pitch = IN.Engines2.pitch;
    Engines2.Propeller_diameter = IN.Engines2.Propeller_diameter;
    Engines2.Max_thrust = IN.Engines2.Max_thrust;
    Engines2.Bypass_ratio_to_emulate = IN.Engines2.Bypass_ratio_to_emulate;
    Engines2.Thrust_reverser_effectivness = IN.Engines2.Thrust_reverser_effectivness;
    Engines2.Fan_cowl_length_ratio = IN.Engines2.Fan_cowl_length_ratio;
    if geoF
        Engines2.Number_of_engines = IN.Engines2.Number_of_engines;
        Engines2.Nacelle3.longitudinal_location = IN.Engines2.Nacelle3.longitudinal_location;
        Engines2.Nacelle3.vertical_location = IN.Engines2.Nacelle3.vertical_location;
        Engines2.Nacelle3.lateral_location = IN.Engines2.Nacelle3.lateral_location;
        Engines2.Nacelle_length_array = IN.Engines2.Nacelle_length_array;
    end
end

OUT.Engines2 = Engines2;

%------ Tailbooms ---------------------------------------------------------

Tailbooms.present = IN.Tailbooms.present;
if Tailbooms.present
    Tailbooms.x_location = IN.Tailbooms.x_location;
    Tailbooms.y_location = IN.Tailbooms.y_location;
    Tailbooms.z_location = IN.Tailbooms.z_location;
    Tailbooms.symmetry = IN.Tailbooms.symmetry;
    Tailbooms.total_length = IN.Tailbooms.total_length;
    Tailbooms.diameter = IN.Tailbooms.diameter;
    Tailbooms.Angle_z = IN.Tailbooms.Angle_z;
    Tailbooms.Angle_y = IN.Tailbooms.Angle_y;
end
OUT.Tailbooms = Tailbooms;

%------ Canard ------------------------------------------------------------

Canard.present = IN.Canard.present;
if Canard.present
    Canard.area = IN.Canard.area;
    Canard.Span = IN.Canard.Span;
    Canard.AR = IN.Canard.AR;
    Canard.spanwise_kink = IN.Canard.spanwise_kink;
    Canard.taper_kink = IN.Canard.taper_kink;
    Canard.taper_tip = IN.Canard.taper_tip;
    Canard.root_incidence = IN.Canard.root_incidence;
    Canard.kink_incidence = IN.Canard.kink_incidence;
    Canard.tip_incidence = IN.Canard.tip_incidence;
    Canard.LE_sweep_inboard = IN.Canard.LE_sweep_inboard;
    Canard.LE_sweep_outboard = IN.Canard.LE_sweep_outboard;
    Canard.dihedral_inboard = IN.Canard.dihedral_inboard;
    Canard.dihedral_outboard = IN.Canard.dihedral_outboard;
    Canard.airfoilRoot = IN.Canard.airfoilRoot;
    Canard.airfoilKink = IN.Canard.airfoilKink;
    Canard.airfoilTip = IN.Canard.airfoilTip;
    Canard.thickness_root = IN.Canard.thickness_root;
    Canard.thickness_kink = IN.Canard.thickness_kink;
    Canard.thickness_tip = IN.Canard.thickness_tip;
    Canard.Elevator.present = IN.Canard.Elevator.present;
    Canard.Elevator.chord = IN.Canard.Elevator.chord;
    Canard.Elevator.limit_deflection_up = IN.Canard.Elevator.limit_deflection_up;
    Canard.Elevator.limit_deflection_down = IN.Canard.Elevator.limit_deflection_down;
    Canard.apex_locale = IN.Canard.apex_locale;
    Canard.vertical_locale = IN.Canard.vertical_locale;
    Canard.limit_tailplane_deflection_up = IN.Canard.limit_tailplane_deflection_up;
    Canard.limit_tailplane_deflection_down = IN.Canard.limit_tailplane_deflection_down;
    if geoF
        Canard.quarter_chord_sweep_inboard = IN.Canard.quarter_chord_sweep_inboard;
        Canard.quarter_chord_sweep_outboard = IN.Canard.quarter_chord_sweep_outboard;
        Canard.reference_wing_half_chord_sweep = IN.Canard.reference_wing_half_chord_sweep;
        Canard.Moment_arm_to_CA = IN.Canard.Moment_arm_to_CA;
    end
    Canard.z = IN.Canard.z;
    Canard.x = IN.Canard.x;
end
OUT.Canard = Canard;

%------ Wing2 -------------------------------------------------------------

OUT.Wing2.present = 0;

%------ NewMLG ------------------------------------------------------------

OUT.NewMLG.present = IN.NewMLG.present;

%------ Aux_Landing_Gear --------------------------------------------------

OUT.Aux_Landing_Gear.present = IN.Aux_Landing_Gear.present;

%------ Reference_wing ----------------------------------------------------

% OUT.Reference_wing.non_dim_MAC_y_bar = IN.Reference_wing.non_dim_MAC_y_bar;
OUT.Reference_wing = IN.Reference_wing;

%------ fuel --------------------------------------------------------------

fuel.Outboard_fuel_tank_span = IN.fuel.Outboard_fuel_tank_span;
fuel.Wing_fuel_tank_cutout_opt = IN.fuel.Wing_fuel_tank_cutout_opt;
fuel.Unusable_fuel_option = IN.fuel.Unusable_fuel_option;
fuel.Assumed_fuel_density = IN.fuel.Assumed_fuel_density;
fuel.Incr_weight_for_wing_tanks = IN.fuel.Incr_weight_for_wing_tanks;
fuel.Centre_tank_portion_used = IN.fuel.Centre_tank_portion_used;
fuel.Increment_for_centre_tank = IN.fuel.Increment_for_centre_tank;
fuel.Fore_fairing_tank_length = IN.fuel.Fore_fairing_tank_length;
fuel.Aft_fairing_tank_length = IN.fuel.Aft_fairing_tank_length;
fuel.Aft_fuse_bladder_length = IN.fuel.Aft_fuse_bladder_length;
fuel.Increment_for_aux_tanks = IN.fuel.Increment_for_aux_tanks;
fuel.box_ea_loc_root = IN.fuel.box_ea_loc_root;
fuel.box_ea_loc_kink1 = IN.fuel.box_ea_loc_kink1;
fuel.box_ea_loc_kink2 = IN.fuel.box_ea_loc_kink2;
fuel.box_ea_loc_tip = IN.fuel.box_ea_loc_tip;
fuel.box_semispan_root = IN.fuel.box_semispan_root;
fuel.box_semispan_kink1 = IN.fuel.box_semispan_kink1;
fuel.box_semispan_kink2 = IN.fuel.box_semispan_kink2;
fuel.box_semispan_tip = IN.fuel.box_semispan_tip;
if geoF
    fuel.Fore_wing_spar_loc_root = IN.fuel.Fore_wing_spar_loc_root;
    fuel.Fore_wing_spar_loc_kik1 = IN.fuel.Fore_wing_spar_loc_kik1;
    fuel.Fore_wing_spar_loc_kin2 = IN.fuel.Fore_wing_spar_loc_kin2;
    fuel.Fore_wing_spar_loc_tip = IN.fuel.Fore_wing_spar_loc_tip;
    fuel.Aft_wing_spar_loc_root = IN.fuel.Aft_wing_spar_loc_root;
    fuel.Aft_wing_spar_loc_kin1 = IN.fuel.Aft_wing_spar_loc_kin1;
    fuel.Aft_wing_spar_loc_kin2 = IN.fuel.Aft_wing_spar_loc_kin2;
    fuel.Aft_wing_spar_loc_tip = IN.fuel.Aft_wing_spar_loc_tip;
end
OUT.fuel = fuel;

%------ miscellaneous -----------------------------------------------------

miscellaneous.Design_classification = IN.miscellaneous.Design_classification;
miscellaneous.Target_operating_ceiling = IN.miscellaneous.Target_operating_ceiling;
miscellaneous.Spoiler_effectivity = IN.miscellaneous.Spoiler_effectivity;
miscellaneous.Undercarriage_layout = IN.miscellaneous.Undercarriage_layout;
miscellaneous.main_landing_gear_x_cg = IN.miscellaneous.main_landing_gear_x_cg;
miscellaneous.main_landing_gear_z_cg = IN.miscellaneous.main_landing_gear_z_cg;
miscellaneous.aux_landing_gear_x_cg = IN.miscellaneous.aux_landing_gear_x_cg;
miscellaneous.aux_landing_gear_z_cg = IN.miscellaneous.aux_landing_gear_z_cg;
miscellaneous.main_landing_gear_on_fuselage = IN.miscellaneous.main_landing_gear_on_fuselage;
OUT.miscellaneous = miscellaneous;

%------ Baggage -----------------------------------------------------------

Baggage.installation_type = IN.Baggage.installation_type;
Baggage.gross_volume = IN.Baggage.gross_volume;
Baggage.Baggage_combined_length = IN.Baggage.Baggage_combined_length;
Baggage.Baggage_apex_per_fuselgt = IN.Baggage.Baggage_apex_per_fuselgt;
OUT.Baggage = Baggage;

%------ cabin -------------------------------------------------------------

cabin.Cabin_length_to_aft_cab = IN.cabin.Cabin_length_to_aft_cab;
cabin.Cabin_max_internal_height = IN.cabin.Cabin_max_internal_height;
cabin.Cabin_max_internal_width = IN.cabin.Cabin_max_internal_width;
cabin.Cabin_floor_width = IN.cabin.Cabin_floor_width;
cabin.Cabin_volume = IN.cabin.Cabin_volume;
cabin.Cabin_attendant_number = IN.cabin.Cabin_attendant_number;
cabin.Flight_crew_number = IN.cabin.Flight_crew_number;
cabin.Passenger_accomodation = IN.cabin.Passenger_accomodation;
cabin.Seats_abreast_in_fuselage = IN.cabin.Seats_abreast_in_fuselage;
cabin.Maximum_cabin_altitude = IN.cabin.Maximum_cabin_altitude;
cabin.Max_pressure_differential = IN.cabin.Max_pressure_differential;
cabin.Floor_apex_per_fuselgt = IN.cabin.Floor_apex_per_fuselgt;
cabin.Passengers_seats_pitch = IN.cabin.Passengers_seats_pitch;
OUT.cabin = cabin;

%------ Fairing1 ----------------------------------------------------------

if geoF
    if Wing1.present
        Fairing1.present = IN.Fairing1.present;
        if Fairing1.present
            Fairing1.Forward_chord_fraction = IN.Fairing1.Forward_chord_fraction;
            Fairing1.Aft_chord_fraction = IN.Fairing1.Aft_chord_fraction;
            Fairing1.flushness = IN.Fairing1.flushness;
        end
        OUT.Fairing1 = Fairing1;
    end
end

%------ user_input --------------------------------------------------------

OUT.user_input = IN.user_input;

%------ experienced_user_input --------------------------------------------

OUT.experienced_user_input = IN.experienced_user_input;

%------ weight_balance ----------------------------------------------------

weight_balance.System.Compl_allowance_plus_paint = IN.weight_balance.System.Compl_allowance_plus_paint;
weight_balance.System.Fuel_system_weight = IN.weight_balance.System.Fuel_system_weight;
weight_balance.System.Flight_controls_weight = IN.weight_balance.System.Flight_controls_weight;
weight_balance.System.APU_weight = IN.weight_balance.System.APU_weight;
weight_balance.System.Instruments_weight = IN.weight_balance.System.Instruments_weight;
weight_balance.System.Avionics_weight = IN.weight_balance.System.Avionics_weight;
weight_balance.System.Hydraulic_Pneumatic_weight = IN.weight_balance.System.Hydraulic_Pneumatic_weight;
weight_balance.System.Electrical_weight = IN.weight_balance.System.Electrical_weight;
weight_balance.System.ECS_anti_icing_grp_weight = IN.weight_balance.System.ECS_anti_icing_grp_weight;
weight_balance.System.Furnishings_Green = IN.weight_balance.System.Furnishings_Green;
weight_balance.System.Miscellaneous = IN.weight_balance.System.Miscellaneous;
weight_balance.MFW_decrement_to_MTOW = IN.weight_balance.MFW_decrement_to_MTOW;
weight_balance.Year_advan_techn_multip = IN.weight_balance.Year_advan_techn_multip;
weight_balance.Weight_cont_allow_perc_of_MEW = IN.weight_balance.Weight_cont_allow_perc_of_MEW;
weight_balance.Ramp_increment = IN.weight_balance.Ramp_increment;
weight_balance.Manufacturer_weights_tolerance = IN.weight_balance.Manufacturer_weights_tolerance;
weight_balance.Fuel.Maximum_fuel_in_wings = IN.weight_balance.Fuel.Maximum_fuel_in_wings;
weight_balance.Fuel.Maximum_fuel_in_auxiliary = IN.weight_balance.Fuel.Maximum_fuel_in_auxiliary;
weight_balance.Fuel.Maximum_fuel_in_central_wingbox = IN.weight_balance.Fuel.Maximum_fuel_in_central_wingbox;
weight_balance.Payload.Passenger_weight_coefficient = IN.weight_balance.Payload.Passenger_weight_coefficient;
weight_balance.Payload.Weight_per_passenger = IN.weight_balance.Payload.Weight_per_passenger;
weight_balance.Payload.Weight_increment_per_passenger = IN.weight_balance.Payload.Weight_increment_per_passenger;
weight_balance.Crew.Cabin_attendant_weight = IN.weight_balance.Crew.Cabin_attendant_weight;
weight_balance.Crew.Flight_crew_weight = IN.weight_balance.Crew.Flight_crew_weight;
weight_balance.Green_Manufacturer_empty_weight = IN.weight_balance.Green_Manufacturer_empty_weight;
weight_balance.Imat = IN.weight_balance.Imat;
if geoF
    weight_balance.flight_envelope_prediction.VD_Flight_envelope_dive = IN.weight_balance.flight_envelope_prediction.VD_Flight_envelope_dive;
    weight_balance.flight_envelope_prediction.VMO_Flight_envelope = IN.weight_balance.flight_envelope_prediction.VMO_Flight_envelope;
end
if isfield(IN.weight_balance,'COG')
    weight_balance.COG = IN.weight_balance.COG;
else
    weight_balance.COG = zeros(30,4,15);
end
OUT.weight_balance = weight_balance;

%------ Check -------------------------------------------------------------

if isfield(IN,'check')
    OUT.check = IN.check;
else
    OUT.check.geo = 0;
    OUT.check.wb = 0;
end

%------ Added Masses ------------------------------------------------------

if isfield(IN,'added_masses')
    OUT.added_masses = IN.added_masses;
end
if isfield(IN,'AM')
    OUT.AM = IN.AM;
end