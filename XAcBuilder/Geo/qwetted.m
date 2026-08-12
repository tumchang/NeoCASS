function qwetted(n)
% Constants for various properties
global aircraft % Aggiunto
global rhosls kcmspd g deg2rad asls
%=====
% Input parameters from QVIEWAC
global PYLNCLW pylnwfl
%=====
% Input parameters from QGEOTRY
global RefWingChordOrigin FuseWingPosition WTHKROT OriginalFuseWingChord WINGTHB EnginesDiameter SpanMatrixPartition WingThickMatrix
global XS2CDWF WT2KROT WC2RDWF WS2NMTX WT2KMTX WC2DROT
global WI2WTHB WI2WMAC
global FuseParamAft CIRCUMX
global HTailOriginalRootChord HTailSpanMatrixPartition RefHTailThickness HTailThicknessMatrix
global VTailThicknessMatrix VTailOriginalRootChord VTailSpanMatrixPartition RefVTailThickness
global CanardOriginalRootChord CanardSpanMatrixPartition RefCanardThickness CanardThicknessMatrix
global NacelleLength NacellePitotLength NacellePitotDiameter PN
%=====
% Output parameters from QWETTED
global CutoutThickness1 CutoutChord1 CutoutThickness2 CutoutChord2 CutoutThickness3 CutoutChord3 CutoutThickness4 CutoutChord4
global CutoutSpan1 CutoutSpan2 CutoutSpan3 CutoutSpan4 RefWingAreaForWB
global FuseGeometryMatrix
global WI2GWET
global drshint vchrdb0 dfinrot vchrdb1 dchrdb1 vchrdb2 dchrdb2 vchrdbt
global dchrdbt dthkmtx dspnmtx DorsalFinsWettedArea
global NAWBASE NACEWET PowerplantWettedArea TotalWettedArea FUSEFIN
%=====
% Scripts for executing the global parameter declarations
% Fuselage definition parameters
global FuseVerticalDiameterFore FuseDistortionFore FuseHorizontalDiameterFore OmegaNose PhiNose EpsilonNose NoseLength FuseShiftFore FuseFractionFore FuseLength FuseVerticalDiameterAft FuseDistortionAft FuseHorizontalDiameterAft OmegaTail PhiTail EpsilonTail FuseTailLength
% Sponson definition parameters
global spsnxlc spsnzlc spsnlgt spsnxzs spsnwid
% Wing definition parameters
global WingConfiguration wingprl winglam WingPlacement WingApex WingArea WingAR WingSpan WingKink WingTaper WingThickness WingIncidence WingQCSweep WingLESweep WingDihedral WingletSpan WingletTaper WingletLESweep WingletCantAngle WingletIncidence FlapChord AileronPosition AileronChord AileronSpan SlatChord SlatSpan
% Fairing definition parameters
global FairingChordFractionFore FairingChordFractionAft FairingFlushness
% Wing 2 definition parameters
global wi2gcfg wi2gprl wi2glam wi2gplc wi2gapx wi2gare wi2ggar wi2gspn wi2gkln wi2gtap wi2gthk wi2ginc wi2gqsw wi2glsw wi2gdih fla2Crd ail2Pos ail2Chr ail2Spa sla2Crd sla2Spa
% Fairing 2 definition parameters
global fa2rfwd fa2raft fa2rovh
% Horizontal tail definition parameters
global HTailArea HTailAR HTailSpan HTailKink HTailTaper htallam HTailThickness HTailIncidence HTailQCSweep HTailLESweep HTailDihedral EmpennageLayout HTailVerticalLocale HTailApex htalvol HTailElevatorChord
% Canard definition parameters
global CanardArea CanardAR CanardSpan CanardKink CanardTaper CanardThickness CanardIncidence CanardQCSweep CanardLESweep CanardDihedral CanardVerticalLocale CanardApex canrvol CanardElevatorChord 
% Vertical tail definition parameters
global VTailArea VTailAR VTailSpan VTailKink VTailTaper vtallam VTailThickness VTailIncidence VTailQCSweep VTailLESweep VTailDihedral VTailVerticalLocale VTailApex vtalvol RudderChord vtalblt vtalbsl VTailDorsalLocation VTailDorsalSweep vfinvlc vfinhlc vfinvcd vfinvsp vfinvkl vfinvtp vfinvls vfinvdh vfinvhg
% Results from geometry computations
global WingExposedArea ZSERDWF OriginalTipChord ReferenceWingConvention ReferenceWingArea2 RefWingTaper RefWingAR RefWingLESweep RefWingQCSweep RefWingHCSweep RefWingMAC MACSpanPos RefWingThickness RefHTailArea RefHTailTaper RefHTailLESweep RefHTailQCSweep RefHTailHCSweep RefHTailMAC HTailMACSpanPos RefVTailArea RefVTailTaper RefVTailLESweep RefVTailQCSweep RefVTailHCSweep RefVTailMAC VTailMACSpanPos
global RefCanardArea RefCanardTaper RefCanardLESweep RefCanardQCSweep RefCanardHCSweep RefCanardMAC CanardMACSpanPos
% Engine definition parameters
global ThrustToWeight EnginesNumber EnginesLayout EnginesType EnginesLocalY EnginesLocalX EnginesLocalZ EnginesToeIn EnginesPitch ReverserEffectiveness MaxThrust BypassRatio thrtred NacelleType NacelleFineness EngineMaxDiameter PropellerDiameter
% Wetted area data
global wingiwt WingWettedArea WingletIncrement WingletWettedArea htaliwt HTailWettedArea canriwt CanardWettedArea vtaliwt VTailWettedArea fuseiwt FuseWettedArea pylniwt PylonWettedArea pwrpiwt ANCIWET
%Fuel tank details
global FrontSparPosition wingsau RearSparPosition FuelTankCutout OutboardFuelSpan UnusableFuel FuelDensity TanksIncrementalWeight FinalWingFuelWeight FinalWingFuelVolume CentreTankPortion IncrementCentreTank CentralTankWeight CentralTankAdjustedVolume FairingTankLength FuseBladderLength IncrementAuxiliaryTanks FuselageFuelWeight FuselageFuelVolume

global CabinMaxHeight CabinMaxWidth cabnlgt CabinFloorWidth BaggageApex BaggageInstallation BaggageVolume BaggageLength
%============================================================================
% eval(['global' blanks(1) GPARAMT]);% declare the global parameters
% Estimate the wing number one wetted area.
% Based on methods using Isikveren but with Raymer underlying premise.
%=====
onwgcta=0.0;% aft fuse mounted, S or straight duct engines (primary)
if EnginesNumber(1,n)>0
    %=================================
    if EnginesLayout(1,n)<3.0
        % calculate the lateral wing distance to inboard cut-out
        CutoutSpan1=0.5*(EnginesLocalY(1,n)*WingSpan(n)-EnginesDiameter(1,n));
        CutoutThickness1=Wing_Thickness_At_Span(CutoutSpan1,SpanMatrixPartition,WingThickMatrix);% thickness at cut 1
        CutoutChord1=Wing_Chord_At_Span(CutoutSpan1,SpanMatrixPartition,RefWingChordOrigin(n),WingTaper,n);
        % calculate the lateral wing distance to outboard cut-out
        CutoutSpan2=0.5*(EnginesLocalY(1,n)*WingSpan(n)+EnginesDiameter(1,n));
        CutoutThickness2=Wing_Thickness_At_Span(CutoutSpan2,SpanMatrixPartition,WingThickMatrix);% thickness at cut 2
        CutoutChord2=Wing_Chord_At_Span(CutoutSpan2,SpanMatrixPartition,RefWingChordOrigin(n),WingTaper,n);
        % estimate the amount of cut-out due to on-wing installation
        onwgct1=wetcomp(CutoutChord1,CutoutChord2/CutoutChord1,EnginesDiameter(1,n), ...
            CutoutThickness1,CutoutThickness2/CutoutThickness1);
        if PN>1
            % calculate the lateral wing distance to inboard cut-out
            CutoutSpan3=0.5*(EnginesLocalY(2,n)*WingSpan(n)-EnginesDiameter(2,n));
            CutoutThickness3=Wing_Thickness_At_Span(CutoutSpan3,SpanMatrixPartition,WingThickMatrix);% thickness at cut 3
            CutoutChord3=Wing_Chord_At_Span(CutoutSpan3,SpanMatrixPartition,RefWingChordOrigin(n),WingTaper,n);
            % calculate the lateral wing distance to outboard cut-out
            CutoutSpan4=0.5*(EnginesLocalY(2,n)*WingSpan(n)+EnginesDiameter(2,n));
            CutoutThickness4=Wing_Thickness_At_Span(CutoutSpan4,SpanMatrixPartition,WingThickMatrix);% thickness at cut 4
            CutoutChord4=Wing_Chord_At_Span(CutoutSpan4,SpanMatrixPartition,RefWingChordOrigin(n),WingTaper,n);
            % estimate the amount of cut-out due to on-wing installation
            onwgct2=wetcomp(CutoutChord3,CutoutChord4/CutoutChord3,EnginesDiameter(2,n), ...
                CutoutThickness3,CutoutThickness4/CutoutThickness3);
        else
            onwgct2=0.0;% no decrement due to secondary powerplant
        end
        %=================================
        onwgcta=onwgct1+onwgct2;% tally the total wetted decrement
    end
else
    onwgcta = 0;
end
%=====
% predict the inboard wing wetted area (less the fuse barrel)

wingwti=wetcomp(OriginalFuseWingChord(n),RefWingChordOrigin(n)*WingTaper(1,n)/OriginalFuseWingChord(n),...
    SpanMatrixPartition(1)-FuseWingPosition(n)/2,WingThickness(1,n),WingThickMatrix(2,2)/WingThickMatrix(2,1));
% predict the midboard wing wetted area
wingwtm=wetcomp(RefWingChordOrigin(n)*WingTaper(1,n),WingTaper(2,n)/WingTaper(1,n),...
    SpanMatrixPartition(2),WingThickMatrix(2,2),WingThickMatrix(1,2));
% predict the outboard wing wetted area
wingwto=wetcomp(RefWingChordOrigin(n)*WingTaper(2,n),WingTaper(3,n)/WingTaper(2,n),...
    SpanMatrixPartition(3),WingThickMatrix(2,3),WingThickMatrix(1,3));

WingWettedArea(n)=wingwti+wingwtm+wingwto-onwgcta+wingiwt(n);% final wing wetted
RefWingAreaForWB=WingWettedArea(n);% store the wing area for weights analysis
%============================================================================
% Estimate the winglets wetted area.
%=====
if WingletSpan(n)>0.0001
    WingletWettedArea(n)=wetcomp(RefWingChordOrigin(n)*WingTaper(3,n),WingletTaper(n), ...
        RefWingChordOrigin(n)*WingTaper(3,n)*WingletSpan(n),WingThickness(4,n),1);
else
    WingletWettedArea(n)=0;% no winglets to add
end
WingletWettedArea(n)=WingletWettedArea(n)+WingletIncrement(n);% tally the winglet wetted with increment
%============================================================================
% Estimate the wing number two wetted area.
% Based on methods using Isikveren but with Raymer underlying premise.
%=====
WI2GWET(n)=0.0;% default of no wetted area for wing number two
on2gcta=0.0;% tally the total wetted decrement
if wi2gare(n)>0.0001
    % predict the inboard wing wetted area (less the fuse barrel)
    wi2gwti=wetcomp(WC2RDWF(n),WC2DROT(n)*wi2gtap(1,n)/WC2RDWF(n),...
        WS2NMTX(1)-XS2CDWF(n)/2,wi2gthk(1,n),WT2KMTX(2,2)/WT2KMTX(2,1));
    % predict the midboard wing wetted area
    wi2gwtm=wetcomp(WC2DROT(n)*wi2gtap(1,n),wi2gtap(2,n)/wi2gtap(1,n),...
        WS2NMTX(2),WT2KMTX(2,2),WT2KMTX(1,2));
    % predict the outboard wing wetted area
    wi2gwto=wetcomp(WC2DROT(n)*wi2gtap(2,n),wi2gtap(3,n)/wi2gtap(2,n),...
        WS2NMTX(3),WT2KMTX(2,3),WT2KMTX(1,3));
    WI2GWET(n)=wi2gwti+wi2gwtm+wi2gwto-on2gcta;% final wing No.2 wetted
    WingWettedArea(n)=WingWettedArea(n)+WI2GWET(n);% tally the total wetted area
end
%============================================================================
% Estimate the fuselage wetted area.
%=====
% define the constituent fuselage section geometries
% investigate the upper fuselage forebody
[acoef,bcoef,abarc,bdlgt]=gocomp(OmegaNose(n),PhiNose(n),EpsilonNose(n),...
    FuseVerticalDiameterFore(n),1);
FuseGeometryMatrix=[acoef bcoef abarc bdlgt];
% investigate the lower fuselage forebody
FuseGeometryMatrix(2,:)=[acoef bcoef abarc bdlgt];
% investigate the lower fuselage aftbody
[acoef,bcoef,abarc,bdlgt]=gocomp(OmegaTail(n),PhiTail(n),EpsilonTail(n),...
    FuseVerticalDiameterAft(n),1);
FuseGeometryMatrix(5,:)=[acoef bcoef abarc bdlgt];
% investigate the upper fuselage aftbody
FuseGeometryMatrix(4,:)=[acoef bcoef abarc bdlgt];
% cylindrical fuselage
FuseGeometryMatrix(3,:)=[FuseVerticalDiameterAft(n) 0 (FuseLength(n)-FuseGeometryMatrix(1,4)-FuseGeometryMatrix(4,4))*(1- ...
    FuseFractionFore(n)) (FuseLength(n)-FuseGeometryMatrix(1,4)-FuseGeometryMatrix(4,4))*(1- ...
    FuseFractionFore(n))];
% tapered fuselage frustum
FuseGeometryMatrix(6,:)=[FuseVerticalDiameterAft(n) 0 ((((FuseLength(n)-FuseGeometryMatrix(1,4)- ...
    FuseGeometryMatrix(4,4))*FuseFractionFore(n))^2)+ ...
    (FuseVerticalDiameterFore(n)-FuseVerticalDiameterAft(n))^2)^0.5 ((((FuseLength(n)-FuseGeometryMatrix(1,4)- ...
    FuseGeometryMatrix(4,4))*FuseFractionFore(n))^2)+(FuseVerticalDiameterFore(n)-FuseVerticalDiameterAft(n))^2)^0.5];
%=====
% sum the constituent wetted areas
cfuswet=0.0;
for i=1:5
    % correction to wetted area due to cross-section distortion is included
    cfuswet=cfuswet+CIRCUMX(i)*pi*FuseGeometryMatrix(i,1)*FuseGeometryMatrix(i,3);
end
% additional increment due to presence of fwd fuse tapering
cfusewet=cfuswet+(CIRCUMX(3)+CIRCUMX(6))*pi*FuseGeometryMatrix(6,1)*FuseGeometryMatrix(6,3)/2;
%=====
% compute the fuselage fineness ratio, i.e. based on vertical cross-section
% diameter
FUSEFIN(n)=FuseLength(n)/FuseVerticalDiameterAft(n);% fuselage fineness
%=====
% Estimate the fuselage-wing fairing wetted area. Method based on
% Isikveren. Use empirical correlation between fairing compared to total
% fuselage length.
%=====
wfrlgth=(FairingChordFractionFore(n)+FairingChordFractionAft(n))/100*RefWingChordOrigin(n);% estimate the fairing length
% final fairing wetted area for primary wing
WFAIWET(n)=0.75*wfrlgth/FuseLength(n)*cfuswet;
if wi2gare(n)>0.0001
    wf2lgth=(fa2rfwd(n)+fa2raft(n))/100*WC2DROT(n);% estimate the fairing length
    % new wetted area estimate with second wing
    WFAIWET(n)=WFAIWET(n)+ ...
        0.75*wf2lgth/FuseLength(n)*cfuswet;
end
FuseWettedArea(n)=cfuswet+fuseiwt(n)+0.2*WFAIWET(n);% final fuselage wetted area
%============================================================================
% Estimate the horizontal tail wetted area.
%=====
% locate where the v-tail is placed on the aft fuse geometry
% Add abs() since with tailbooms configuration VT apex is greater than
% fuselage length (i.e. greater than 1.)
% **** AGGIUNTO 2016-06-21 *****

% ******************
if VTailArea(n)>0.0001 % **** 2016-06-21 solo r200
vtallca = FuseLength(n)*abs(1-VTailApex(n))-VTailOriginalRootChord(n)/2;

% estimate fuse diameter in side view
fusudsv = FuseGeometryMatrix(4,1)*vtallca^FuseGeometryMatrix(4,2);% upper geometry
fusldsv = FuseGeometryMatrix(5,1)*vtallca^FuseGeometryMatrix(5,2);% upper geometry
fuseldi = fusudsv+fusldsv;% total local fuselage diameter
% v-tail cut-out span
vtalslc = fusudsv+(FuseGeometryMatrix(5,4)-vtallca)*tan(PhiTail(n)*deg2rad)- ...
    fuseldi*VTailVerticalLocale(n);
vtalcut = Wing_Chord_At_Span(vtalslc/2,VTailSpanMatrixPartition,VTailOriginalRootChord(n),VTailTaper,n);% fuse-vtail chord
end % **** 2016-06-21 solo r211

%=====
if HTailArea(n)>0.0001
    if EmpennageLayout(n)>0.5
        if EmpennageLayout(n)<1.0
            % cruciform
        else
            % the h-tail is located on the v-tail (T-tail)
            vttkcut=vtalcut*VTailThickness(1,n);% thickness at fuse-vtail cut
            htalslc=vttkcut;% h-tail cut-out
        end
        htalslc=0.0;% no fuselage cut-out is to be examined
    else
        % the h-tail is located on the fuselage (conventional)
        % locate where the h-tail is placed on the aft fuse geometry
        % Add abs() since with tailbooms configuration HT apex is greater than
        % fuselage length (i.e. greater than 1.)
        htallca=FuseLength(n)*abs(1-HTailApex(n))-HTailOriginalRootChord(n)/2;
        % local fuse diameter in plan view
        fusudsv=FuseGeometryMatrix(4,1)*htallca^FuseGeometryMatrix(4,2);% upper geometry
        % h-tail cut-out span
        htalslc=fusudsv+(FuseGeometryMatrix(5,4)-htallca)*tan(PhiTail(n)*deg2rad)- ...
            FuseVerticalDiameterAft(n)*HTailVerticalLocale(n);
    end
    %=====
    htalcut=Wing_Chord_At_Span(htalslc/2,HTailSpanMatrixPartition,HTailOriginalRootChord(n),HTailTaper,n);% fuse-htail chord
    % predict the inboard h-tail wetted area (less span cut-out)
    htalwti=wetcomp(htalcut,HTailOriginalRootChord(n)*HTailTaper(1,n)/htalcut,...
        HTailSpanMatrixPartition(1)-htalslc/2,HTailThickness(1,n),HTailThicknessMatrix(2,2)/HTailThicknessMatrix(2,1));
    % predict the midboard h-tail wetted area
    htalwtm=wetcomp(HTailOriginalRootChord(n)*HTailTaper(1,n),HTailTaper(2,n)/HTailTaper(1,n),...
        HTailSpanMatrixPartition(2),HTailThicknessMatrix(2,2),HTailThicknessMatrix(1,2));
    % predict the outboard h-tail wetted area
    htalwto=wetcomp(HTailOriginalRootChord(n)*HTailTaper(2,n),HTailTaper(3,n)/HTailTaper(2,n),...
        HTailSpanMatrixPartition(3),HTailThicknessMatrix(2,3),HTailThicknessMatrix(1,3));
    % final estimate for wetted area
    HTailWettedArea(n)=htalwti+htalwtm+htalwto+htaliwt(n);
else
    HTailWettedArea(n)=0.0;% no horizontal tail exists
end
%============================================================================
% Estimate the Canard wetted area.
%=====
if CanardArea(n)>0.0001
    % the canard is located on the fuselage (conventional)
    % locate where the h-tail is placed on the fore fuse geometry
    canrlca=FuseLength(n)*(1-CanardApex(n))-CanardOriginalRootChord(n)/2;
    % local fuse diameter in plan view
    fusudsv=FuseGeometryMatrix(4,1)*canrlca^FuseGeometryMatrix(4,2);% upper geometry
    % canard cut-out span
    canrslc=fusudsv+(FuseGeometryMatrix(5,4)-canrlca)*tan(PhiNose(n)*deg2rad)- ...
        FuseVerticalDiameterFore(n)*CanardVerticalLocale(n);
    %=====
    canrcut=Wing_Chord_At_Span(canrslc/2,CanardSpanMatrixPartition,CanardOriginalRootChord(n),CanardTaper,n);% fuse-canard chord
    % predict the inboard canard wetted area (less span cut-out)
    canrwti=wetcomp(canrcut,CanardOriginalRootChord(n)*CanardTaper(1,n)/canrcut,...
        CanardSpanMatrixPartition(1)-canrslc/2,CanardThickness(1,n),CanardThicknessMatrix(2,2)/CanardThicknessMatrix(2,1));
    % predict the midboard canard wetted area
    canrwtm=wetcomp(CanardOriginalRootChord(n)*CanardTaper(1,n),CanardTaper(2,n)/CanardTaper(1,n),...
        CanardSpanMatrixPartition(2),CanardThicknessMatrix(2,2),CanardThicknessMatrix(1,2));
    % predict the outboard canard wetted area
    canrwto=wetcomp(CanardOriginalRootChord(n)*CanardTaper(2,n),CanardTaper(3,n)/CanardTaper(2,n),...
        CanardSpanMatrixPartition(3),CanardThicknessMatrix(2,3),CanardThicknessMatrix(1,3));
    % final estimate for wetted area
    CanardWettedArea(n)=canrwti+canrwtm+canrwto+canriwt(n);
else
    CanardWettedArea(n)=0.0;% no canard exists
end
%============================================================================
% Estimate the vertical tail wetted area.
%=====
if VTailArea(n)>0.0001
    % predict the inboard v-tail wetted area (less span cut-out)
    vtalwti=wetcomp(vtalcut,VTailOriginalRootChord(n)*VTailTaper(1,n)/vtalcut,...
        VTailSpanMatrixPartition(1)-vtalslc/2,VTailThickness(1,n),VTailThicknessMatrix(2,2)/VTailThicknessMatrix(2,1));
    % predict the midboard v-tail wetted area
    vtalwtm=wetcomp(VTailOriginalRootChord(n)*VTailTaper(1,n),VTailTaper(2,n)/VTailTaper(1,n),...
        VTailSpanMatrixPartition(2),VTailThicknessMatrix(2,2),VTailThicknessMatrix(1,2));
    % predict the midboard v-tail wetted area
    vtalwto=wetcomp(VTailOriginalRootChord(n)*VTailTaper(2,n),VTailTaper(3,n)/VTailTaper(2,n),...
        VTailSpanMatrixPartition(3),VTailThicknessMatrix(2,3),VTailThicknessMatrix(1,3));
    % final estimate for wetted area
    VTailWettedArea(n)=(vtalwti+vtalwtm+vtalwto)/2+vtaliwt(n);
    % check to see if a T-tail arrangement is employed
    if EmpennageLayout(n)==1
        % increment the vertical tail wetted area with a bullet
        bullwet=wetcomp(VTailOriginalRootChord(n)*VTailTaper(3,n),1,2*HTailOriginalRootChord(n)*HTailThickness(1,n), ...
            VTailThickness(4,n),1)/2;
        VTailWettedArea(n)=VTailWettedArea(n)+bullwet;
    end
else
    VTailWettedArea(n)=0.0;
end
%============================================================================
% Estimate the dorsal fin wetted area.
%=====
if VTailDorsalLocation(n)>0.0001
    % the dorsal fin root chord (w/o v-tail)
    dfinrop=(VTailApex(n)-VTailDorsalLocation(n))*FuseLength(n);%+ ...
    %(1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2*tan(VTailLESweep(1,n)*deg2rad);
    %=====
    % find out the height for intersection between dorsal and v-tail
    hbar=dfinrop*sin((90-VTailDorsalSweep(n))*deg2rad)/sin((VTailDorsalSweep(n)- ...
        VTailLESweep(1,n))*deg2rad);
    drshint=hbar*sin((90-VTailLESweep(1,n))*deg2rad);
    %=====
    % establish the local dorsal fin thickness matrix
    vchrdb0=Wing_Chord_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2,VTailSpanMatrixPartition,VTailOriginalRootChord(n), ...
        VTailTaper,n);% v-tail chrd @ root
    dfinrot(n)=dfinrop+vchrdb0;% the final dorsal root chord
    vchrdb1=Wing_Chord_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2+drshint/3,VTailSpanMatrixPartition, ...
        VTailOriginalRootChord(n),VTailTaper,n);% v-tail chrd @ 1
    dchrdb1=vchrdb1+2*dfinrop/3;% local dorsal chord @ 1
    vchrdb2=Wing_Chord_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2+2*drshint/3,VTailSpanMatrixPartition, ...
        VTailOriginalRootChord(n),VTailTaper,n);% v-tail chrd @ 2
    dchrdb2=vchrdb2+dfinrop/3;% local dorsal chord @ 2
    vchrdbt=Wing_Chord_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2+drshint,VTailSpanMatrixPartition, ...
        VTailOriginalRootChord(n),VTailTaper,n);% v-tail chrd @ tip
    dchrdbt=vchrdbt;% local dorsal chord @ tip
    dorthkr=Wing_Thickness_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2,VTailSpanMatrixPartition, ...
        VTailThicknessMatrix)*vchrdb0/dfinrot(n);% thickness @ root
    dorthk1=Wing_Thickness_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2+drshint/3,VTailSpanMatrixPartition, ...
        VTailThicknessMatrix)*vchrdb1/dchrdb1;% thickness @ 1
    dorthk2=Wing_Thickness_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2+2*drshint/3,VTailSpanMatrixPartition, ...
        VTailThicknessMatrix)*vchrdb2/dchrdb2;% thickness @ 2
    dorthkt=Wing_Thickness_At_Span((1-2*VTailVerticalLocale(n))*FuseVerticalDiameterAft(n)/2+drshint,VTailSpanMatrixPartition, ...
        VTailThicknessMatrix)*vchrdbt/dchrdbt;% thickness @ tip
    dthkmtx=[dorthk1/dorthkr dorthk2/dorthk1 dorthkt/dorthk2; ...
        dorthkr dorthk1 dorthk2];
    %=====
    dspnmtx=[drshint/3 drshint/3 drshint/3];% dorsal span matrix
    %=====
    DorsalFinsWettedArea=wetcomp(dfinrop,0,drshint,dorthkr,dorthkt/dorthkr)/2;
    % final estimate for wetted area
    VTailWettedArea(n)=VTailWettedArea(n)+DorsalFinsWettedArea;
end
%============================================================================
% Estimate the nacelle wetted area.
%=====
% Legend for powerplant configuration selection:
% (0) slung in vicinity of the wing
% (1) on-wing nacelle (2) on-wing integrated with undercarraige
% (3) aft-fuse
% (4) Straight duct   (5) S-duct
% nacetype (1) long-duct (2)short-duct
NACEWET(1:2,n)=0;% initialise for calculation
for i=1:PN
    % the nacelle diameter and length parameters for further treatment
    psq=(NacelleLength(i,n)/(4.81))^2;
    msq=(EngineMaxDiameter(i,n)/(4.93))^2;
    %   dsq=(EngineMaxDiameter(i,n)^2)/97.22;lsq=(NacelleLength(i,n)^2)/92.54;
    %=====
    % predict the nacelle wetted area for all installations
    nacewec=2*0.2028*(pi^2)*EngineMaxDiameter(i,n)*(((4.7595*psq+1.1333*msq)^0.5)+ ...
        ((4.2874*psq+1.8375*msq)^0.5)- ...
        ((0.1175*psq+0.3918*msq)^0.5)- ...
        (0.3820*psq+0.8913*msq)^0.5);
    % now compute the basic pitot nacelle wetted area
    psq=(NacellePitotLength(i,n)/(4.81))^2;
    msq=(NacellePitotDiameter(i,n)/(4.93))^2;
    NAWBASE(i,n)=2*0.2028*(pi^2)*NacellePitotDiameter(i,n)*(((4.7595*psq+1.1333*msq)^0.5)+ ...
        ((4.2874*psq+1.8375*msq)^0.5)- ...
        ((0.1175*psq+0.3918*msq)^0.5)- ...
        (0.3820*psq+0.8913*msq)^0.5);
    if EnginesLayout(i,n)<1
        NAWBASE(i,n)=nacewec;% make sure pitot
    end
    %=====
    if EnginesLayout(i,n)==1
        nacewec=nacewec/2;% adjust the computed wetted area
        % account for the two side panels
        nacewec=nacewec+2*NacelleLength(i,n)*EngineMaxDiameter(i,n)/2;
    elseif EnginesLayout(i,n)==2
        % account for the two side panels
        nacewec=nacewec+2*NacelleLength(i,n)*EngineMaxDiameter(i,n)/2;
    end
    NACEWET(i,n)=nacewec*EnginesNumber(i,n);% compute wetted area for all
end
%=====
if pylnwfl>0.0001
    PylonWettedArea(n)=PYLNCLW(n)+pylniwt(n);% the final total pylon wetted area
else
    pylnwfl=1;
end
% the final total nacelle wetted area
PowerplantWettedArea(n)=NACEWET(1,n)+NACEWET(2,n)+pwrpiwt(n);
%============================================================================
% Estimate the total wetted area for aircraft.
TotalWettedArea(n) = WingWettedArea(n) + WingletWettedArea(n) + FuseWettedArea(n) + HTailWettedArea(n) + VTailWettedArea(n)+ ...
    PylonWettedArea(n) + PowerplantWettedArea(n) + ANCIWET(n);

if ~isreal(TotalWettedArea(n))
    fprintf('!Warning: Total wetted area is complex, making it real.\n');
    TotalWettedArea(n) = real(TotalWettedArea(n));
end

% save('qwetuav.mat');

return
%============================================================================
function [acoef,bcoef,abarc,bdlgt]=gocomp(angleb,angler,fin,diam,orien)
global deg2rad
% This routine computes the various coefficients required for geometrical
% definition and subsequent computation of fuselage wetted area.
% Based on method developed by Isikveren.
bdlgt=fin*diam;% body length calculation
dslc=angleb-angler;% adjusted body slope to reference angle
% compute the values of the geometric model
bcoef=0.54+0.1*tan(deg2rad*dslc);% geometric model exponent
acoef=diam/(2*bdlgt^bcoef);% geometrical model coefficient
% this section computes the integral coefficent used as an approximation
% for wetted area prediction later on
evalfl=(((bdlgt)^(2*bcoef))+((acoef*bcoef)^2)*(bdlgt)^(4*bcoef-2))^0.5;
evalfq=(((bdlgt/4)^(2*bcoef))+((acoef*bcoef)^2)*(bdlgt/4)^(4*bcoef-2))^0.5;
acoefp=exp((log(evalfq)-(1-log(4)/log(bdlgt))*log(evalfl))/(log(4)/log(bdlgt)));
bcoefp=(log(evalfl)-log(acoefp))/log(bdlgt);
abarc=acoefp/(1+bcoefp)*bdlgt^(bcoefp+1);% integral coefficient
return
%============================================================================
function wetted=wetcomp(chord,stapr,span,thick,ttapr)
% This routine predicts the wetted area of lifting surfaces
a=2;b=8.5;
weta=chord*span;wetb=(a+b*thick^2)*(1+stapr);
wetc=2/3*b*(thick^2)*(ttapr-1)*(1+2*stapr);
wetted=weta*(wetb+wetc);
%wetc=1+stapr+2*b*(thick^2)*(ttapr-1)*(3+2*span*(stapr-1))/3;
%wetted=weta*wetb*wetc;
return
%============================================================================