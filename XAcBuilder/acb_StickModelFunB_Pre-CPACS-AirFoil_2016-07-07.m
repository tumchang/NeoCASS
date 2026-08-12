function acb_StickModelFunB
    
    %CheckWingLet
    %WingLetsRBE2 = 8;   
    %LeggiFileRBE2(WingLetsRBE2)
    clear AcBuilderTechImp TechGeoModel Guess AcBuilderNameW; 
    global ac AcBuilderTechImp
    %save('f:\rrrr.mat','ac','AcBuilderTechImp')
    disp(' *********** Start Stick Model generation... *************')
   
    % **************** Possibile riattivazione ************
    %structACBprj = xml2struct(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\AcBExpXML.xml'));
    %save(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\ACBprj.mat'),'structACBprj');
	% ************************************************************
	acImp = ac
    
	% ********** Recupero dati ***********************************
    % ** {'Wing1' 'Wing2' 'H_Tail' 'V_Tail' 'Canard' 'WingMK'} **
    % ** {'Wing1' 'Wing2' 'Wing3'  'Wing4'  'Wing5' 'Wing6'}  **
    
    % *** BEAMS ***
    % *** Init ***
    InitB = zeros(1,4);
    Wing1B = InitB;
    Wing2B = InitB;
    VTailB = InitB;
    HTailB = InitB;
    CanardB = InitB;
    FuseB = 0;
    WingMKA = 0;
    WingMKB = 0;
    
    % **** WINGLET ****
    % Wing1
    WingLet1A = 0;
    WingLet1B = 0;
    % Wing 2 - Non Implementato
    WingLet2A = 0;
    WingLet2B = 0;
    % Wing_MK
    WingLetMKA = 0;
    WingLetMKB = 0;
    % ******************
    
    % ************
    
    % Wing1
    Wing1B(1) = acImp.user_input.geometry.beam_model.nwing_inboard;
    Wing1B(2) = acImp.user_input.geometry.beam_model.nwing_midboard;
    Wing1B(3) = acImp.user_input.geometry.beam_model.nwing_outboard;
    Wing1B(4) = acImp.user_input.geometry.beam_model.nwing_carryth;
    %Wing1B % Controllo
    
    % Wing2
    if acImp.Wing2.present == 1
    Wing2B(1) = acImp.user_input.geometry.beam_model.nwing2_inboard;
    Wing2B(2) = acImp.user_input.geometry.beam_model.nwing2_midboard;
    Wing2B(3) = acImp.user_input.geometry.beam_model.nwing2_outboard;
    Wing2B(4) = acImp.user_input.geometry.beam_model.nwing2_carryth;
    %Wing2B
    end
    
    % H_Tail
    HTailB(1) = acImp.user_input.geometry.beam_model.nhtail_inboard;
    HTailB(2) = 0;
    HTailB(3) = acImp.user_input.geometry.beam_model.nhtail_outboard;
    HTailB(4) = acImp.user_input.geometry.beam_model.nhtail_carryth;
    %HTailB
    
    % V_Tail
    VTailB(1) = acImp.user_input.geometry.beam_model.nvtail_inboard;
    VTailB(2) = 0;
    VTailB(3) = acImp.user_input.geometry.beam_model.nvtail_outboard;
    VTailB(4) = 0;%acImp.user_input.geometry.beam_model.nvtail_carryth;
    %VTailB
       
    % Canard
    if acImp.Canard.present == 1
    CanardB(1) = acImp.user_input.geometry.beam_model.ncanard_inboard;
    CanardB(2) = 0;
    CanardB(3) = acImp.user_input.geometry.beam_model.ncanard_outboard;
    CanardB(4) = acImp.user_input.geometry.beam_model.ncanard_carryth;
    %CanardB
    end
    
    % WingMK
    if acImp.WingMK.present == 1
    WingMKB(1) = acImp.user_input.geometry.beam_model.nwingMK_inboard;    %2; %IN
    WingMKB(2) = acImp.user_input.geometry.beam_model.nwingMK_midboard_A; %2; %A
    WingMKB(3) = acImp.user_input.geometry.beam_model.nwingMK_midboard_B; %2; %B
    WingMKB(4) = acImp.user_input.geometry.beam_model.nwingMK_midboard_C; %2; %C
    WingMKB(5) = acImp.user_input.geometry.beam_model.nwingMK_midboard_D; %2; %D
    WingMKB(6) = acImp.user_input.geometry.beam_model.nwingMK_midboard_E; %2; %E
    WingMKB(7) = acImp.user_input.geometry.beam_model.nwingMK_midboard_F; %2; %F
    WingMKB(8) = acImp.user_input.geometry.beam_model.nwingMK_midboard_G; %2; %G
    WingMKB(9) = acImp.user_input.geometry.beam_model.nwingMK_midboard_H; %2; %H
    WingMKB(10) = acImp.user_input.geometry.beam_model.nwingMK_midboard_I;%2; %I
    WingMKB(11) = acImp.user_input.geometry.beam_model.nwingMK_outboard;  %2; %OUT
    WingMKB(12) = acImp.user_input.geometry.beam_model.nwingMK_carryth;   %2; %CT
    %WingMKB
    
    
    end
    
    % WingLet1
    if acImp.Wing1.winglet.present == 1
     WingLet1B(1) = acImp.user_input.geometry.beam_model.nwing_Wlet;%3;
     WingLet1B(2) = 2;
    end
    
    % WingLet2
    if acImp.Wing2.winglet.present == 1
     WingLet2B(1) = acImp.user_input.geometry.beam_model.nwing2_Wlet;%4;   
    end
    
    % WingLetMK
    if acImp.WingMK.winglet.present == 1
     WingLetMKB(1) = acImp.user_input.geometry.beam_model.nwingMK_Wlet;%6;
     WingLetMKB(2) = 2;
    end
    
    
    % Fuselage
    FuseB = acImp.user_input.geometry.beam_model.nfuse;
    % *** END BEAMS ***
    disp('Beam OK!')
    
    % *** AERO PANs ***
    % *** Init ***
    InitA = zeros(6,2);
    Wing1A = InitA;
    Wing2A = InitA;
    HTailA = InitA;
    VTailA = InitA;
    CanardA = InitA;
    % ************
    
    % Wing1
    Wing1A(1,1) = acImp.user_input.geometry.aero_panel.nx.wing_inboard;
    Wing1A(2,1) = acImp.user_input.geometry.aero_panel.nx.wing_midboard;
    Wing1A(3,1) = acImp.user_input.geometry.aero_panel.nx.wing_outboard;
    
    Wing1A(4,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wing_inboard;
    Wing1A(5,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wing_midboard;
    Wing1A(6,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wing_outboard;
    
    Wing1A(1,2) = acImp.user_input.geometry.aero_panel.ny.wing_inboard;
    Wing1A(2,2) = acImp.user_input.geometry.aero_panel.ny.wing_midboard;
    Wing1A(3,2) = acImp.user_input.geometry.aero_panel.ny.wing_outboard;
    
    % Wing2
    if acImp.Wing2.present == 1
    Wing2A(1,1) = acImp.user_input.geometry.aero_panel.nx.wing2_inboard;
    Wing2A(2,1) = acImp.user_input.geometry.aero_panel.nx.wing2_midboard;
    Wing2A(3,1) = acImp.user_input.geometry.aero_panel.nx.wing2_outboard;
    
    Wing2A(4,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wing2_inboard;
    Wing2A(5,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wing2_midboard;
    Wing2A(6,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wing2_outboard;
    
    Wing2A(1,2) = acImp.user_input.geometry.aero_panel.ny.wing2_inboard;
    Wing2A(2,2) = acImp.user_input.geometry.aero_panel.ny.wing2_midboard;
    Wing2A(3,2) = acImp.user_input.geometry.aero_panel.ny.wing2_outboard;
    end
    
    % HTail
    HTailA(1,1) = acImp.user_input.geometry.aero_panel.nx.hori_inboard;
    HTailA(2,1) = 0
    HTailA(3,1) = acImp.user_input.geometry.aero_panel.nx.hori_outboard;
    
    HTailA(4,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.hori_inboard;
    HTailA(5,1) = 0
    HTailA(6,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.hori_outboard;
    
    HTailA(1,2) = acImp.user_input.geometry.aero_panel.ny.hori_inboard;
    HTailA(2,2) = 0;
    HTailA(3,2) = acImp.user_input.geometry.aero_panel.ny.hori_outboard;
    
    % VTail
    VTailA(1,1) = acImp.user_input.geometry.aero_panel.nx.vert_inboard;
    VTailA(2,1) = 0;
    VTailA(3,1) = acImp.user_input.geometry.aero_panel.nx.vert_outboard;
    
    VTailA(4,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.vert_inboard;
    VTailA(5,1) = 0;
    VTailA(6,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.vert_outboard;
    
    VTailA(1,2) = acImp.user_input.geometry.aero_panel.ny.vert_inboard;
    VTailA(2,2) = 0;
    VTailA(3,2) = acImp.user_input.geometry.aero_panel.ny.vert_outboard;
    
    % Canard
    if acImp.Canard.present == 1
    CanardA(1,1) = acImp.user_input.geometry.aero_panel.nx.canard_inboard;
    CanardA(2,1) = 0;
    CanardA(3,1) = acImp.user_input.geometry.aero_panel.nx.canard_outboard;
    
    CanardA(4,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.canard_inboard;
    CanardA(5,1) = 0;
    CanardA(6,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.canard_outboard;
    
    CanardA(1,2) = acImp.user_input.geometry.aero_panel.ny.canard_inboard;
    CanardA(2,2) = 0;
    CanardA(3,2) = acImp.user_input.geometry.aero_panel.ny.canard_outboard;
    end
    
     % WingMK
    if acImp.WingMK.present == 1
        % nx panels
    WingMKA(1,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_inboard;%4;
    WingMKA(2,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_A;%4;
    WingMKA(3,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_B;%4;
    WingMKA(4,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_C;%4;
    WingMKA(5,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_D;%4;
    WingMKA(6,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_E;%4;
    WingMKA(7,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_F;%4;
    WingMKA(8,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_G;%4;
    WingMKA(9,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_H;%4;
    WingMKA(10,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_midboard_I;%4;
    WingMKA(11,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_outboard;%4;
        % nx sup control panels
    WingMKA(12,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_inboard;%3;
    WingMKA(13,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_A;%3;
    WingMKA(14,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_B;%3;
    WingMKA(15,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_C;%3;
    WingMKA(16,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_D;%3;
    WingMKA(17,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_E;%3;
    WingMKA(18,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_F;%3;
    WingMKA(19,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_G;%3;
    WingMKA(20,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_H;%3;
    WingMKA(21,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_midboard_I;%3;
    WingMKA(22,1) = acImp.user_input.geometry.aero_panel.nx.sup_control.wingMK_outboard;%3;
        % ny panels
    WingMKA(1,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_inboard;%4;
    WingMKA(2,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_A;%4;
    WingMKA(3,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_B;%4;
    WingMKA(4,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_C;%4;
    WingMKA(5,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_D;%4;
    WingMKA(6,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_E;%4;
    WingMKA(7,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_F;%4;
    WingMKA(8,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_G;%4;
    WingMKA(9,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_H;%4;
    WingMKA(10,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_midboard_I;%4;    
    WingMKA(11,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_outboard;%4;
    
 
    
    end
    
    if acImp.Wing1.winglet.present == 1  
       
    WingLet1A(1,1) = acImp.user_input.geometry.aero_panel.nx.wing_Wlet; disp('controllo 2015-09-08')%3; % nx
    WingLet1A(2,1) = 0;
    WingLet1A(1,2) = acImp.user_input.geometry.aero_panel.ny.wing_Wlet;%3; % ny
    end
    
    if acImp.Wing2.winglet.present == 1
    WingLet2A(1,1) = acImp.user_input.geometry.aero_panel.nx.wing2_Wlet;%3;
    WingLet2A(2,1) = 0;
    WingLet2A(1,2) = acImp.user_input.geometry.aero_panel.ny.wing2_Wlet;%3;
    end
    
    if acImp.WingMK.winglet.present == 1
    WingLetMKA(1,1) = acImp.user_input.geometry.aero_panel.nx.wingMK_Wlet;%6; % nx
    WingLetMKA(2,1) = 0;
    WingLetMKA(1,2) = acImp.user_input.geometry.aero_panel.ny.wingMK_Wlet;%6; % ny
    end
    
    % *** END AERO PANs ***
    disp('Aero Panels OK!')
    
    %{
    Wing1A 
    Wing2A 
    HTailA 
    VTailA 
    CanardA
    %}    
    % ************************************************************
    
    AcBuilderTechImp.FuseB   = FuseB;
    AcBuilderTechImp.Wing1A  = Wing1A;
    AcBuilderTechImp.Wing1B  = Wing1B;
    AcBuilderTechImp.Wing2A  = Wing2A;
    AcBuilderTechImp.Wing2B  = Wing2B;
    AcBuilderTechImp.HTailA  = HTailA;
    AcBuilderTechImp.HTailB  = HTailB;
    AcBuilderTechImp.VTailA  = VTailA;
    AcBuilderTechImp.VTailB  = VTailB;
    AcBuilderTechImp.CanardA = CanardA;
    AcBuilderTechImp.CanardB = CanardB;
    
    AcBuilderTechImp.WingMKA = WingMKA;
    AcBuilderTechImp.WingMKB = WingMKB;
    
    AcBuilderTechImp.WingLet1A = WingLet1A;
    AcBuilderTechImp.WingLet1B = WingLet1B;
    
    AcBuilderTechImp.WingLet2A = WingLet2A;
    AcBuilderTechImp.WingLet2B = WingLet2B;
    
    AcBuilderTechImp.WingLetMKA = WingLetMKA;
    AcBuilderTechImp.WingLetMKB = WingLetMKB;
    
    % ************ MobSurf *************
    AcBuilderTechImp.MobSurfWing1 = zeros(1,7);
    AcBuilderTechImp.MobSurfWing1(1) = acImp.Wing1.flap.present;
    
    AcBuilderTechImp.MobSurfWing1(2) = acImp.Wing1.flap.root_chord;
    AcBuilderTechImp.MobSurfWing1(3) = acImp.Wing1.flap.kink1_chord;
    
    AcBuilderTechImp.MobSurfWing1(4) = acImp.Wing1.flap.kink1_chord;
    AcBuilderTechImp.MobSurfWing1(5) = acImp.Wing1.flap.kink2_chord;
    
    AcBuilderTechImp.MobSurfWing1(6) = acImp.Wing1.aileron.present;
    AcBuilderTechImp.MobSurfWing1(7) = acImp.Wing1.aileron.chord;
    
    AcBuilderTechImp.MobSurfWing2 = zeros(1,7);
    AcBuilderTechImp.MobSurfWing2(1) = acImp.Wing2.flap.present;
    
    AcBuilderTechImp.MobSurfWing2(2) = acImp.Wing2.flap.root_chord;
    AcBuilderTechImp.MobSurfWing2(3) = acImp.Wing2.flap.kink1_chord;
    
    AcBuilderTechImp.MobSurfWing2(4) = acImp.Wing2.flap.kink1_chord;
    AcBuilderTechImp.MobSurfWing2(5) = acImp.Wing2.flap.kink2_chord;
    
    AcBuilderTechImp.MobSurfWing2(6) = 0;
    AcBuilderTechImp.MobSurfWing2(7) = 0;
    
    AcBuilderTechImp.MobSurfWingMK = zeros(1,23);
    AcBuilderTechImp.MobSurfWingMK(1) = acImp.WingMK.flap.present;
    
    AcBuilderTechImp.MobSurfWingMK(2) = acImp.WingMK.flap.root_chord;
    AcBuilderTechImp.MobSurfWingMK(3) = acImp.WingMK.flap.kink1_chord;
    
    AcBuilderTechImp.MobSurfWingMK(4) = acImp.WingMK.flap.kink1_chord;
    AcBuilderTechImp.MobSurfWingMK(5) = acImp.WingMK.flap.kink2_chord;
    
    AcBuilderTechImp.MobSurfWingMK(6) = acImp.WingMK.flap.kink2_chord;
    AcBuilderTechImp.MobSurfWingMK(7) = acImp.WingMK.flap.kink3_chord;
    
    AcBuilderTechImp.MobSurfWingMK(8) = acImp.WingMK.flap.kink3_chord;
    AcBuilderTechImp.MobSurfWingMK(9) = acImp.WingMK.flap.kink4_chord;
    
    AcBuilderTechImp.MobSurfWingMK(10) = acImp.WingMK.flap.kink4_chord;
    AcBuilderTechImp.MobSurfWingMK(11) = acImp.WingMK.flap.kink5_chord;
    
    AcBuilderTechImp.MobSurfWingMK(12) = acImp.WingMK.flap.kink5_chord;
    AcBuilderTechImp.MobSurfWingMK(13) = acImp.WingMK.flap.kink6_chord;
    
    AcBuilderTechImp.MobSurfWingMK(14) = acImp.WingMK.flap.kink6_chord;
    AcBuilderTechImp.MobSurfWingMK(15) = acImp.WingMK.flap.kink7_chord;
    
    AcBuilderTechImp.MobSurfWingMK(16) = acImp.WingMK.flap.kink7_chord;
    AcBuilderTechImp.MobSurfWingMK(17) = acImp.WingMK.flap.kink8_chord;
    
    AcBuilderTechImp.MobSurfWingMK(18) = acImp.WingMK.flap.kink8_chord;
    AcBuilderTechImp.MobSurfWingMK(19) = acImp.WingMK.flap.kink9_chord;
    
    AcBuilderTechImp.MobSurfWingMK(20) = acImp.WingMK.flap.kink9_chord;
    AcBuilderTechImp.MobSurfWingMK(21) = acImp.WingMK.flap.kink10_chord;
    
    AcBuilderTechImp.MobSurfWingMK(22) = acImp.WingMK.aileron.present;
    AcBuilderTechImp.MobSurfWingMK(23) = acImp.WingMK.aileron.chord;
    
    
    AcBuilderTechImp.MobSurfHT = zeros(1,3);
    AcBuilderTechImp.MobSurfHT(1) = acImp.Horizontal_tail.Elevator.present
    
    AcBuilderTechImp.MobSurfHT(2) = acImp.Horizontal_tail.Elevator.chord
    AcBuilderTechImp.MobSurfHT(3) = acImp.Horizontal_tail.Elevator.Span
    
    
    AcBuilderTechImp.MobSurfVT = zeros(1,3);
    AcBuilderTechImp.MobSurfVT(1) = acImp.Vertical_tail.Rudder.present
    
    AcBuilderTechImp.MobSurfVT(2) = acImp.Vertical_tail.Rudder.chord
    AcBuilderTechImp.MobSurfVT(3) = acImp.Vertical_tail.Rudder.Span
    
    AcBuilderTechImp.MobSurfCN = zeros(1,3);
    AcBuilderTechImp.MobSurfCN(1) = acImp.Canard.Elevator.present
    
    AcBuilderTechImp.MobSurfCN(2) = acImp.Canard.Elevator.chord
    AcBuilderTechImp.MobSurfCN(3) = acImp.Canard.Elevator.Span
    
    % ************************************
    
    % ***** Material *******
    AcBuilderTechImp.EWing1 = acImp.user_input.material_property.wing.esw;
    AcBuilderTechImp.EWing2 = acImp.user_input.material_property.wing2.esw;
    AcBuilderTechImp.EWingMK = acImp.user_input.material_property.wingMK.esw;
    AcBuilderTechImp.EHT = acImp.user_input.material_property.htail.esw;
    AcBuilderTechImp.EVT = acImp.user_input.material_property.vtail.esw;
    AcBuilderTechImp.ECan = acImp.user_input.material_property.canard.esw;    
    % **********************
    
    AcBuilderTechImp.ThePath = strrep(which('CPACScreator'),'CPACScreator.m','')
    AcBuilderTechImp.TheArch = strrep(which('AcBExpCPACS4StickModel.xml'),'AcBExpCPACS4StickModel.xml','')
    
    % *** *** *** Collegamenti Winglets *** *** *** *** *** 
    if acImp.Wing1.winglet.present == 1 && acImp.Wing1.present == 1        
     WingLetsRBE2 = 8;   
     LeggiFileRBE2(WingLetsRBE2)
    end
    
    % Non Implementato
    if acImp.Wing2.winglet.present == 1        
     WingLetsRBE2 = 9;   
     LeggiFileRBE2(WingLetsRBE2)
    end
    
    if acImp.WingMK.winglet.present == 1  && acImp.WingMK.present == 1      
     WingLetsRBE2 = 10;   
     LeggiFileRBE2(WingLetsRBE2)
    end
    
    
    % *** *** *** *** *** *** *** *** *** *** *** *** *** ***
    
    
    %{
    % **** Pulizia Dir AcBSMDir *****
    FolderAcBSM = dir('.\AcBSMDir\')
    for i=1:length(FolderAcBSM)
       if FolderAcBSM(i).isdir == 0
           nomefileAcBSM = FolderAcBSM(i).name
           delete(strcat('.\AcBSMDir\',nomefileAcBSM));
       end
    end
    % *******************************
    %}
    
    save('.\AcBSMDir\AcBuilderTechImpVar.mat','AcBuilderTechImp')
    % Da CPACS Creator
	% Folder Technology, stickmodel
	% Ordine funzioni: Technology_Fun(1,CPACSXMLstruct)
	
	% Technology_Fun(1,CPACSTEST)
	%disp('Matlab CPACS >>> STRUCT XML creation...')
	%[struct_20_D150] = xml2structN(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBuilderSM\CPACS_20_D150.xml'));
	%struct_20_D150 % controllo
    %TOLOAD=struct_20_D150.cpacs{1,1};
	%disp('OK!')
    %Technology_Fun(1,TOLOAD);
    %disp('Set path...')
    %cd('.\sm\geometry')
    disp('Save AcBuilder Tech')
    %pause(5);
    disp('Wait please...')
    try
    cd('.\sm\geometry\')
    %clc
    %disp('***** >>>> Prompt: stick_model to continue <<<< *****')
    disp('***** >>>> Stick_model is now running... Please wait <<<< *****')
    % **** Start Stick Model ****
    catch
        disp('Error!')
    end
end

function LeggiFileRBE2(WingLetsRBE2)
    global AcBuilderTechImp
    addpath(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir'));
    cd(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'\AcBSMDir'));
    
    % Read txt into cell
    % Determina il numero di righe del file
    fid = fopen('Guess_joints_AcB.dat','r');
    i = 1;
    tline = fgetl(fid);
    AFile{i} = tline;
    while ischar(tline)
     i = i+1;
     tline = fgetl(fid);
     AFile{i} = tline;
    end
    fclose(fid);
    
    fid = fopen('Guess_joints_AcB.dat','a+');
    
   
    
     switch WingLetsRBE2
            case 8
            WingKo = 2000;    
            RBE2Line4WLr = sprintf('RBE2    %8d%8d  123456    8501        \n',length(AFile),500+WingKo+1+sum(AcBuilderTechImp.Wing1B(1:end-1)))    
            RBE2Line4WLl = sprintf('RBE2    %8d%8d  123456    8001        \n',length(AFile)+1,WingKo+1+sum(AcBuilderTechImp.Wing1B(1:end-1)))                
            %RBE2Line4WL = 'RBE2           7    2005  123456    8001        '
            
            
            case 9
            WingKo = 6000;
            RBE2Line4WLr = sprintf('RBE2    %8d%8d  123456    9501        \n',length(AFile),500+WingKo+1+sum(AcBuilderTechImp.Wing2B(1:end-1)))                    
            RBE2Line4WLl = sprintf('RBE2    %8d%8d  123456    9001        \n',length(AFile)+1,WingKo+1+sum(AcBuilderTechImp.Wing2B(1:end-1)))                            
            %RBE2Line4WL = 'RBE2           8    6005  123456    9001        ' 
            
            case 10
            WingKo = 7000;
            RBE2Line4WLr = sprintf('RBE2    %8d%8d  123456   10501        \n',length(AFile),500+WingKo+1+sum(AcBuilderTechImp.WingMKB(1:end-1)))                                    
            RBE2Line4WLl = sprintf('RBE2    %8d%8d  123456   10001        \n',length(AFile)+1,WingKo+1+sum(AcBuilderTechImp.WingMKB(1:end-1)))                            
            %RBE2Line4WL = 'RBE2           9    7005  123456   10001        '        
            
            otherwise
                
    end
        
    %fprintf(fid,['RBE2           7    2005  123456    8004        ']);
    fprintf(fid,RBE2Line4WLr);
    fprintf(fid,RBE2Line4WLl);
    fprintf(fid,'\n');
    fclose(fid);
        
    disp('controllo')
    CheckWingLet
    cd(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''));
end


function CheckWingLet
    %load('AcBuilderTechImpVar.mat')
    global AcBuilderTechImp
    fid = fopen('Guess_joints_AcB.dat','r');
    i = 1;
    tline = fgetl(fid);
    AFile{i} = tline;
    BFile{i} = AFile{i};
    SPar = strsplit(AFile{i},' ')
    
    % HTail e Wing1
    if strcmp(SPar{3},num2str(2000+1+sum(AcBuilderTechImp.Wing1B(1:end-1))))==1 && strcmp(SPar{5},num2str(3000+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing 1 tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3000+1+sum(AcBuilderTechImp.HTailB(1:end-1)),8000+1+sum(AcBuilderTechImp.WingLet1B(1:end-1)))                                                
    end
    
    if strcmp(SPar{3},num2str(2500+1+sum(AcBuilderTechImp.Wing1B(1:end-1))))==1 && strcmp(SPar{5},num2str(3500+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing 1 tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3500+1+sum(AcBuilderTechImp.HTailB(1:end-1)),8500+1+sum(AcBuilderTechImp.WingLet1B(1:end-1)))                                                
    end
    
    % HTail e WingMK
    if strcmp(SPar{3},num2str(7000+1+sum(AcBuilderTechImp.WingMKB(1:end-1))))==1 && strcmp(SPar{5},num2str(3000+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing 1 tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3000+1+sum(AcBuilderTechImp.HTailB(1:end-1)),10000+1+sum(AcBuilderTechImp.WingLetMKB(1:end-1)))                                                
    end
    
    if strcmp(SPar{3},num2str(7500+1+sum(AcBuilderTechImp.WingMKB(1:end-1))))==1 && strcmp(SPar{5},num2str(3500+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing 1 tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3500+1+sum(AcBuilderTechImp.HTailB(1:end-1)),10500+1+sum(AcBuilderTechImp.WingLetMKB(1:end-1)))                                                
    end
    
    
    while ischar(tline)
     i = i+1;
     tline = fgetl(fid);
     AFile{i} = tline;
     BFile{i} = AFile{i};
     if length(tline)>4
     SPar = strsplit(AFile{i},' ')
     
     % HTail e Wing1
    if strcmp(SPar{3},num2str(2000+1+sum(AcBuilderTechImp.Wing1B(1:end-1))))==1 && strcmp(SPar{5},num2str(3000+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing 1 tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3000+1+sum(AcBuilderTechImp.HTailB(1:end-1)),8000+1+sum(AcBuilderTechImp.WingLet1B(1:end-1)))                                                
    end
    
    if strcmp(SPar{3},num2str(2500+1+sum(AcBuilderTechImp.Wing1B(1:end-1))))==1 && strcmp(SPar{5},num2str(3500+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing 1 tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3500+1+sum(AcBuilderTechImp.HTailB(1:end-1)),8500+1+sum(AcBuilderTechImp.WingLet1B(1:end-1)))                                                
    end
    
    % HTail e WingMK
    if strcmp(SPar{3},num2str(7000+1+sum(AcBuilderTechImp.WingMKB(1:end-1))))==1 && strcmp(SPar{5},num2str(3000+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing MK tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3000+1+sum(AcBuilderTechImp.HTailB(1:end-1)),10000+1+sum(AcBuilderTechImp.WingLetMKB(1:end-1)))                                                
    end
    
    if strcmp(SPar{3},num2str(7500+1+sum(AcBuilderTechImp.WingMKB(1:end-1))))==1 && strcmp(SPar{5},num2str(3500+1+sum(AcBuilderTechImp.HTailB(1:end-1))))== 1 
        disp ('Wing MK tip connected to Htail tip')
        BFile{i} = sprintf('RBE2    %8s%8d  123456%8d        ',SPar{2},3500+1+sum(AcBuilderTechImp.HTailB(1:end-1)),10500+1+sum(AcBuilderTechImp.WingLetMKB(1:end-1)))                                                
    end
     else
         
     end
    end
    fclose(fid);
    
    %delete('Guess_joints_AcB.dat');
    
    fid = fopen('Guess_joints_AcB.dat', 'w');
    for i = 1:numel(BFile)
     if BFile{i+1} == -1
        fprintf(fid,'%s', BFile{i});
        break
     else
        fprintf(fid,'%s\n', BFile{i});
     end
    end
    fclose(fid);
end