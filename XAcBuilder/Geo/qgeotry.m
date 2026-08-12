function qgeotry(action,n)
% Constants for various properties
global deg2rad knwlbf
%=====
% Output parameters from QGEOTRY
global ReferenceWingArea WingWeightedTaper RefWingAR RefWingThickness WINGEQS LWINGEM RefWingApex WingExposedArea
global WI2GNET NacellePitotLength NacellePitotDiameter
% Input parameters from QGEOTRY
global wletare dcldawl wingase VortexInducedDragFactor clazero wltvorx wletinf wletinr
global wletmac wletthk wletqsw
global FuseWingPosition WTHKROT OriginalFuseWingChord SpanMatrixPartition WingThickMatrix
global XS2CDWF WT2KROT WC2RDWF WS2NMTX WT2KMTX WC2DROT WI2WTHB WI2WMAC
global WI2WARE WI2WGAR WI2WTAP WI2WQSW WI2WHSQ
global FuseParamAft FuseParamFore CIRCUMX 
global HTailSpanMatrixPartition HTailThicknessMatrix HTailMomentArm REFHAPX 
global CanardSpanMatrixPartition CanardThicknessMatrix CNALMOA REFCAPX 
global VTailThicknessMatrix VTailSpanMatrixPartition VTailMomentArm VTAWGAR REFVAPX REFVCRC REFVCAP
global EnginesDiameter NacelleLength ChordAtEngine MaxTotalThrust
global PN
global volflag
%=====
% Scripts for executing the global parameter declarations
% global GPARAMT
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
global CanardArea CanardAR CanardSpan CanardKink CanardTaper canrlam CanardThickness CanardIncidence CanardQCSweep CanardLESweep CanardDihedral CanardVerticalLocale CanardApex canrvol CanardElevatorChord
% Vertical tail definition parameters
global VTailArea VTailAR VTailSpan VTailKink VTailTaper vtallam VTailThickness VTailIncidence VTailQCSweep VTailLESweep VTailDihedral VTailVerticalLocale VTailApex vtalvol RudderChord vtalblt vtalbsl VTailDorsalLocation VTailDorsalSweep vfinvlc vfinhlc vfinvcd vfinvsp vfinvkl vfinvtp vfinvls vfinvdh vfinvhg
% Results from geometry computations
global ZSERDWF RefWingChordOrigin OriginalTipChord ReferenceWingConvention ReferenceWingArea2 RefWingTaper RefWingAR2 RefWingLESweep RefWingQCSweep RefWingHCSweep RefWingMAC MACSpanPos HTailOriginalRootChord RefHTailArea RefHTailTaper RefHTailLESweep RefHTailQCSweep RefHTailHCSweep RefHTailMAC HTailMACSpanPos RefHTailThickness VTailOriginalRootChord RefVTailArea RefVTailTaper RefVTailLESweep RefVTailQCSweep RefVTailHCSweep RefVTailMAC VTailMACSpanPos RefVTailThickness
global CanardOriginalRootChord RefCanardArea RefCanardTaper RefCanardLESweep RefCanardQCSweep RefCanardHCSweep RefCanardMAC CanardMACSpanPos RefCanardThickness
% Engine definition parameters
global ThrustToWeight EnginesNumber EnginesLayout EnginesType EnginesLocalY EnginesLocalX EnginesLocalZ EnginesToeIn EnginesPitch ReverserEffectiveness MaxThrust BypassRatio thrtred NacelleType NacelleFineness EngineMaxDiameter PropellerDiameter 
% Wetted area data
global wingiwt WingWettedArea WingletIncrement WingletWettedArea htaliwt HTailWettedArea canriwt CanardWettedArea vtaliwt VTailWettedArea fuseiwt FuseWettedArea pylniwt PylonWettedArea pwrpiwt PowerplantWettedArea ANCIWET TotalWettedArea
%Fuel tank details
global FrontSparPosition wingsau RearSparPosition FuelTankCutout OutboardFuelSpan UnusableFuel FuelDensity TanksIncrementalWeight FinalWingFuelWeight FinalWingFuelVolume CentreTankPortion IncrementCentreTank CentralTankWeight CentralTankAdjustedVolume FairingTankLength FuseBladderLength IncrementAuxiliaryTanks FuselageFuelWeight FuselageFuelVolume

global CabinMaxHeight CabinMaxWidth cabnlgt CabinFloorWidth BaggageApex BaggageInstallation BaggageVolume BaggageLength

global CanardMomentArm DesignClassification Passengers CabinVolume
%============================================================================
% Define the actions executed by the input interface
%=====
% dummy routine to run the different cases
if nargin<1
  action='initialize';
end
%=====

switch action
    %=================================
    case 'ccabn'
        % this routine computes/checks the cabin & baggage dimensions and properties
        if CabinMaxHeight(n)<0.0001 && FuseVerticalDiameterAft(n)>0.0001
            if FuseDistortionAft(n)>0.5
                CabinMaxHeight(n)=FuseDistortionAft(n)*FuseVerticalDiameterAft(n)-0.15;% double-bubble cabin height
            else
                if WingPlacement(n)<0 || WingPlacement(n)>1
                    CabinMaxHeight(n)=FuseVerticalDiameterAft(n)-0.2;% wingbox does not go through x-section
                else
                    if WingPlacement(n)>0.5
                        % circular x-section cabin height for high wings
                        CabinMaxHeight(n)=FuseVerticalDiameterAft(n)*WingPlacement(n)-WingThickMatrix(2,1)*RefWingChordOrigin(n)/2-0.2;
                    else
                        % circular x-section cabin height for low wings
                        CabinMaxHeight(n)=FuseVerticalDiameterAft(n)*(1-WingPlacement(n))-WingThickMatrix(2,1)*RefWingChordOrigin(n)/2-0.2;
                    end
                end
            end
        end
        if CabinMaxWidth(n)<0.0001 && FuseHorizontalDiameterAft(n)>0.0001
            CabinMaxWidth(n)=FuseHorizontalDiameterAft(n)-0.2;% predict cabin max width
        end
        if CabinFloorWidth(n)<0.0001 && FuseVerticalDiameterAft(n)>0.0001
            if FuseDistortionAft(n)>0.5
                FloorAngle=atan(2*FuseVerticalDiameterAft(n)*(FuseDistortionAft(n)-0.5)/FuseHorizontalDiameterAft(n))+pi;
                FloorRadius=FuseParamAft(1)+FuseParamAft(2)*sin(FloorAngle)+FuseParamAft(3)*cos(2*FloorAngle);
                CabinFloorWidth(n)=2*FloorRadius*cos(FloorAngle-pi)-0.2;% double-bubble floor width
            else
                CabinFloorWidth(n)=((CabinMaxWidth(n)^2)-4*(((FuseVerticalDiameterAft(n)-WingThickMatrix(2,1)*RefWingChordOrigin(n)- ...
                    0.2)/2)^2))^0.5;% predict the floor width
            end
        end
        if volflag>0.0001
            hbar=0.5*((CabinMaxWidth(n)^2)-CabinFloorWidth(n)^2)^0.5;cabth=atan(2*hbar/CabinFloorWidth(n));
            CabinVolume(n)=cabnlgt(n)/4*(CabinMaxWidth(n)*(pi*CabinMaxHeight(n)+cabth*CabinMaxWidth(n))+ ...
                hbar*(2*CabinFloorWidth(n)-pi*CabinMaxWidth(n)));% predict cabin volume
            volflag=0;% reset volume computation flag
        end
        % baggage is to be located underfloor
        if BaggageApex(n)<0.0001
            if BaggageInstallation(n)~=0
                BaggageApex(n)=1.5*NoseLength(n)/FuseLength(n);% estimate the u/flr bagg 1 apex
            else
                BaggageApex(n)=(NoseLength(n)+cabnlgt(n))/FuseLength(n);% est. aft baggage apex
            end
        end
        if BaggageVolume(n)==-1
            MaxBaggageVolumePerPAX=0.382;BaggageScaleFactor=1;% upper limit of baggage vol per PAX = 13.5 cu.ft
            if DesignClassification(n)<2
                BaggageScaleFactor=0.48;% scale for commercial transportation
            elseif DesignClassification(n)==2
                BaggageScaleFactor=0.63;% scale for business jets larger than super midsize
            end
            BaggageVolume(n)=Passengers(n)*BaggageScaleFactor*MaxBaggageVolumePerPAX;% baggage volume prediction
            if BaggageInstallation(n)~=0
                BaggageArea=2*(FuseVerticalDiameterAft(n)-CabinMaxHeight(n)-0.45)*CabinFloorWidth(n)/3;% x-sec area u/floor
                BaggageLength(n)=BaggageVolume(n)/BaggageArea;% estimate u/floor total baggage length
            else
                BaggageLength(n)=BaggageVolume(n)/CabinVolume(n)*cabnlgt(n);% est. aft baggage length
            end
        elseif BaggageVolume(n)<0.0001 && BaggageLength(n)>0.0001
            if BaggageInstallation(n)~=0
                BaggageArea=2*(FuseVerticalDiameterAft(n)-CabinMaxHeight(n)-0.45)*CabinFloorWidth(n)/3;% x-sec area u/floor
                BaggageVolume(n)=BaggageArea*BaggageLength(n);% estimate u/floor baggage volume
            else
                BaggageVolume(n)=CabinVolume(n)/cabnlgt(n)*BaggageLength(n);% estimate baggage volume
            end
        elseif BaggageVolume(n)>0.0001 && BaggageLength(n)<0.0001
            if BaggageInstallation(n)~=0
                BaggageArea=2*(FuseVerticalDiameterAft(n)-CabinMaxHeight(n)-0.45)*CabinFloorWidth(n)/3;% x-sec area u/floor
                BaggageLength(n)=BaggageVolume(n)/BaggageArea;% estimate u/floor baggage length
            else
                BaggageLength(n)=BaggageVolume(n)/CabinVolume(n)*cabnlgt(n);% estimate baggage length
            end
        end
        %=================================
    case 'geom1'
        % The wing number 1 geometric and aerodynamic definitions.
        %=====
        [kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
            netwgae,wsatref,wsarref,wsasref,wsarlsw,wsarqsw,wsarhsw,wsarmac,wsarybr, ...
            wsarthb,inc]=qxemcop(WingKink,WingTaper,WingSpan,WingArea,WingAR, ...
            FuseHorizontalDiameterAft,WingThickness,WingQCSweep,WingLESweep,ReferenceWingConvention,WingPlacement,WingIncidence,n);
        
        %=====
        % output details about the original planform
        WingIncidence(:,n)=inc;
        WingKink(:,n)=kln(:,n);WingSpan(n)=spn(n);WingAR(n)=gar(n);
        WingTaper(:,n)=tap(:,n);WingThickness(2,n)=tmtrx(2,2);WingThickness(3,n)=tmtrx(2,3);
        WTHKROT(n)=troot;RefWingChordOrigin(n)=crot;OriginalFuseWingChord(n)=chwf;
        OriginalTipChord(n)=RefWingChordOrigin(n)*WingTaper(3,n);WCHDRTR(n)=cref;WCHDWFR(n)=chrf;
        WTAPERR(n)=tref;FuseWingPosition(n)=xscd;
        WingQCSweep=qsw;WingLESweep=lsw;SpanMatrixPartition=smtrx;WingThickMatrix=tmtrx;
        
        %=====
        % output details about the chosen reference wing
        WingExposedArea(n)=netwgae;ZSERDWF(n)=xscd/2;
        ReferenceWingArea(n)=wsarref;WingWeightedTaper(n)=wsatref;RefWingAR(n)=wsasref;
        WINWLSW(n)=abs(wsarlsw);RefWingHCSweep(n)=abs(wsarhsw);
        WINWMAC(n)=wsarmac;WINWYBR(n)=wsarybr;RefWingThickness(n)=wsarthb;
        WINGEQS(n)=sum(WingQCSweep)/length(WingQCSweep);
        
        %=====
        % output details about the computed equivalent reference wing
        ReferenceWingArea2(n)=ReferenceWingArea(n);RefWingTaper(n)=WingWeightedTaper(n);RefWingAR2(n)=RefWingAR(n);
        RefWingLESweep(n)=WINWLSW(n);RefWingQCSweep(n)=WingQCSweep(n);RefWingHCSweep(n)=RefWingHCSweep(n);
        RefWingMAC(n)=WINWMAC(n);MACSpanPos(n)=WINWYBR(n);RefWingThickness(n)=RefWingThickness(n);
        comspan=WingSpan(n);
        %=====
        
        % compute location of the reference wing 0.25MAC
        xibad=SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1,n));% inboard sweep adjustment
        xmbad=SpanMatrixPartition(2)*tan(deg2rad*WingLESweep(2,n));% midboard sweep adjustment
        xobad=SpanMatrixPartition(3)*tan(deg2rad*WingLESweep(3,n));% outboard sweep adjustment
        xwing=WingApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
            0.5*WingSpan(n)*(1-WINWYBR(n))*tan(deg2rad*WINWLSW(n))+0.25*WINWMAC(n);
        % locate the reference wing relative apex
        RefWingApex(n)=(WingApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
            0.5*WingSpan(n)*tan(deg2rad*WINWLSW(n)))/FuseLength(n);
        % calculate the length of the wing for supersonic drag prediction
        if (xibad+xmbad+xobad+OriginalTipChord(n))>RefWingChordOrigin(n)
            LWINGEM(1,n)=xibad+xmbad+xobad+OriginalTipChord(n);
        else
            LWINGEM(1,n)=RefWingChordOrigin(n);
        end
        %============================================================================
        % geometric definitions to be used for winglet computations
        %=====
        VortexInducedDragFactor(n) = 0;
        if WingletSpan(n)>0.0001
            null(n)=0.0;% this signifies no juncture chord calc is required
            wletkln(1,n)=0.0;wletkln(2,n)=0.0;% declare the ghost kink location array
            wlettpr(1,n)=0.0;wlettpr(2,n)=0.0;wlettpr(3,n)=WingletTaper(n);% taper ratio
            wltspan(n)=WingletSpan(n)*OriginalTipChord(n);% quantify the winglet span
            % individual winglet planform area
            wletare(n)=wltspan(n)/2*OriginalTipChord(n)*(1+WingletTaper(n));
            wletasr(n)=(wltspan(n)^2)/wletare(n);% winglet geometric aspect ratio
            % set up the winglet thickness distribution
            wletthk(1,n)=WingThickness(4,n);wletthk(2,n)=WingThickness(4,n);
            wletthk(3,n)=WingThickness(4,n);wletthk(4,n)=WingThickness(4,n);
            % Q.chd sweep array
            wletqsw(1,n)=0.0;wletqsw(2,n)=wletqsw(1,n);wletqsw(3,n)=wletqsw(2,n);
            WingletLESweep(2,n)=WingletLESweep(1,n);WingletLESweep(3,n)=WingletLESweep(2,n);% LE sweep array
            %=====
            [kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
                netwgae,wsatref,wsarref,wsasref,wsarlsw,wsarqsw,wsarhsw,wsarmac,wsarybr, ...
                wsarthb,inc]=qxemcop(wletkln,wlettpr,wltspan,wletare,wletasr, ...
                null,wletthk,wletqsw,WingletLESweep,ReferenceWingConvention,null,WingletIncidence,n);
            %=====
            % output details using the chosen reference wing convention
            WingletIncidence(:,n)=inc;
            
            wletqsw(1,n)=wsarqsw;wletmac(n)=wsarmac;
            wletinr(n)=(WingletIncidence(1,n)-WingletIncidence(3,n))*wsarybr+WingletIncidence(1,n);
            % lift-curve slope of section (per deg.)
            dcldawl(n)=0.088*wletasr(n)/(2+(4+wletasr(n)^2)^0.5)*cos(deg2rad*wletqsw(1,n));
            % quantify an equivalent increase in span due to presence of winglets
            wingase(n)=((WingSpan(n)+ ...
                2*wltspan(n)*tan(deg2rad*WingletCantAngle(n)))^2)/(ReferenceWingArea(n)+ ...
                2*wletare(n)*tan(deg2rad*WingletCantAngle(n)));
            % fractional change in vortex-induced drag factor due to improved
            % lift-distribution
            VortexInducedDragFactor(n)=(RefWingAR(n)-wingase(n))/(wingase(n)*(1+pi/150*RefWingAR(n)));
            clazero(n)=dcldawl(n)*3.0;% assume zero-lift at alpha = -3.0 deg.
            wltvorx(n)=1.05/(pi*wletasr(n))+0.007;% winglet induced drag factor
            % estimate the interference generated by the winglet on the wing
            wletinf(n)=(1-WingletCantAngle(n)/90)*((2+4*wletthk(1,n)+ ...
                240*(wletthk(1,n)^4))/2-1)+1;
        end
        %============================================================================
        % The wing number 2 geometric and aerodynamic definitions.
        %
        % see if a second planform geometry has been entered
        WI2WMAC(n)=0.0;% initialise this variable
        if wi2gare(n)>0.001
            [kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
                netwgae,wsatref,wsarref,wsasref,wsarlsw,wsarqsw,wsarhsw,wsarmac,wsarybr, ...
                wsarthb,inc]=qxemcop(wi2gkln,wi2gtap,wi2gspn,wi2gare,wi2ggar, ...
                FuseHorizontalDiameterAft,wi2gthk,wi2gqsw,wi2glsw,ReferenceWingConvention,wi2gplc,wi2ginc,n);
            %=====
            % output details about the original planform
            wi2ginc(:,n)=inc;
            
            wi2gkln(:,n)=kln(:,n);wi2gspn(n)=spn(n);wi2ggar(n)=gar(n);
            wi2gtap(:,n)=tap(:,n);wi2gthk(2,n)=tmtrx(2,2);wi2gthk(3,n)=tmtrx(2,3);
            WT2KROT(n)=troot;WC2DROT(n)=crot;WC2RDWF(n)=chwf;
            WC2DTIP(n)=WC2DROT(n)*wi2gtap(3,n);WC2DRTR(n)=cref;WC2DWFR(n)=chrf;
            WT2PERR(n)=tref;XS2CDWF(n)=xscd;
            wi2gqsw=qsw;wi2glsw=lsw;WS2NMTX=smtrx;WT2KMTX=tmtrx;
            %=====
            % output details about the chosen reference wing
            WI2GNET(n)=netwgae;XS2RDWF(n)=xscd/2;
            WI2WARE(n)=wsarref;WI2WTAP(n)=wsatref;WI2WGAR(n)=wsasref;
            WI2WLSW(n)=abs(wsarlsw);WI2WQSW(n)=abs(wsarqsw);WI2WHSQ(n)=abs(wsarhsw);
            WI2WMAC(n)=wsarmac;WI2WYBR(n)=wsarybr;
            WI2WTHB(n)=wsarthb;WI2GEQS(n)=WI2WQSW(n);
            %=================================
            % An equivalent reference wing must be constructed if two wings are defined.
            % This method was developed by Isikveren and employs work conducted by
            % Munk (stagger theorem), Prandtl, Kerber and Obert.
            %=====
            % compute the superpositioned Oswald Efficiency factor
            spanras=(wi2gspn(n)/WingSpan(n))^2;liftras=(WI2WARE(n)/ReferenceWingArea(n))^2;
            % estimate the mutual drag factor (from Kerber) - this is an analytical
            % representation of original chart
            intsgap=abs(WingPlacement(n)-wi2gplc(n))*FuseVerticalDiameterAft(n)/WingSpan(n);% inter-surf gap
            mdrgfac=((spanras^0.5)+66.167*(intsgap^4)-38.1*(intsgap^3)+ ...
                2.5983*(intsgap^2)+1.697*intsgap)/(276.67*(intsgap^4)- ...
                165.02*(intsgap^3)+35.158*(intsgap^2)+4.6327*intsgap+1);
            % find the equivalent reference wing aspect ratio
            comarea=(ReferenceWingArea(n)+WI2WARE(n));
            areara1=(ReferenceWingArea(n)^2)/comarea;areara2=(WI2WARE(n)^2)/comarea;
            relspn1=WingSpan(n)^2;relspn2=wi2gspn(n)^2;
            asratio=1.05/(areara1/relspn1+areara2/relspn2+ ...
                2*mdrgfac*ReferenceWingArea(n)*WI2WARE(n)/(comarea*WingSpan(n)*wi2gspn(n))- ...
                0.007*pi);
            % compute the equivalent reference wing span
            comspan=(asratio*comarea)^0.5;
            % calculate the equivalent reference wing MAC and leading edge position
            % based on weighted planform areas
            combmac=(ReferenceWingArea(n)*WINWMAC(n)+WI2WARE(n)*WI2WMAC(n))/comarea;%
            combybr=(ReferenceWingArea(n)*WINWYBR(n)*WingSpan(n)+ ...
                WI2WARE(n)*WI2WYBR(n)*wi2gspn(n))/(comarea*comspan);
            mactip1=WingApex(n)*FuseLength(n)+WINWYBR(1)*tan(deg2rad*WINWLSW(n));
            mactip2=wi2gapx(n)*FuseLength(n)+WI2WYBR(1)*tan(deg2rad*WI2WLSW(n));
            macxtip=(mactip1*ReferenceWingArea(n)+mactip2*ReferenceWingArea(n))/comarea;
            % define the equivalent reference wing thickness
            combthk=(RefWingThickness(n)*ReferenceWingArea(n)+WI2WTHB(n)*ReferenceWingArea(n))/comarea;
            % define a new wingtip geometry based on weighted planform areas
            wnxtip1=WingApex(n)*FuseLength(n)+SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1,n))+ ...
                SpanMatrixPartition(2)*tan(deg2rad*WingLESweep(2,n))+ ...
                SpanMatrixPartition(3)*tan(deg2rad*WingLESweep(3,n));
            wnxtip2=wi2gapx(n)*FuseLength(n)+WS2NMTX(1)*tan(deg2rad*wi2glsw(1,n))+ ...
                WS2NMTX(2)*tan(deg2rad*wi2glsw(2,n))+ ...
                WS2NMTX(3)*tan(deg2rad*wi2glsw(3,n));
            cmwxtip=(wnxtip1*ReferenceWingArea(n)+wnxtip2*ReferenceWingArea(n))/comarea;
            combtip=(OriginalTipChord(n)*ReferenceWingArea(n)+WC2DTIP(n)*WI2WARE(n))/comarea;
            % calculate the equivalent weighted leading edge sweep for ref. wing
            comblsw=atan(2*(cmwxtip-macxtip)/((1-combybr)*comspan))/deg2rad;
            % weighted root chord length
            comcref=(combmac-combtip*combybr)/(1-combybr);
            comtref=combtip/comcref;% weighted taper ratio
            % ref. quarter chord sweep
            combqsw=atan(tan(comblsw*deg2rad)-(1-comtref)/(asratio*(1+comtref)))/deg2rad;
            % ref. half chord sweep
            combhsw=atan(tan(comblsw*deg2rad)-2*(1-comtref)/(asratio*(1+comtref)))/deg2rad;
            %=====
            % output details about the computed equivalent reference wing
            ReferenceWingArea2(n)=comarea;RefWingTaper(n)=comtref;RefWingAR2(n)=asratio;
            RefWingLESweep(n)=abs(comblsw);RefWingQCSweep(n)=abs(combqsw);RefWingHCSweep(n)=abs(combhsw);
            RefWingMAC(n)=combmac;MACSpanPos(n)=combybr;RefWingThickness(n)=combthk;
            %=====
            % compute location of the reference wing 0.25MAC
            xwing=cmwxtip+0.25*RefWingMAC(n)- ...
                0.5*comspan*(1-MACSpanPos(n))*tan(deg2rad*RefWingLESweep(n));
            % calculate the length of the wing for supersonic drag prediction
            if (wnxtip2-wi2gapx(n)*FuseLength(n)+WC2DTIP(n))>WC2DROT(n)
                LWINGEM(2,n)=wnxtip2-wi2gapx(n)*FuseLength(n)+WC2DTIP(n);
            else
                LWINGEM(2,n)=WC2DROT(n);
            end
        else
            WI2WTHB(n)=0.0;WI2WARE(n)=0.0;WI2WGAR(n)=0.0;WI2WTAP(n)=0.0;
            WI2WQSW(n)=0.0;LWINGEM(2,n)=0.0;LWINGEM(2,n)=0.0;WI2GNET(n)=0.0;
        end
        %============================================================================
        % The fuselage geometric characteristics.
        % A Fourier Series Expansion (FSE) is conducted to derive the final
        % cross-section geometry. This is crucial because the method must be
        % universally applicable for not only cylindrical but double-bubble and ovoid
        % cross-sections as well. The cross-section circumference calculation is based
        % on an average radius concept.
        % The FSE objective function is called "qxfours.m"
        %=====
        %% Compute the nose and tail length
        NoseLength(1,n)=EpsilonNose(1,n)*FuseVerticalDiameterFore(1,n);
        FuseTailLength(1,n)=EpsilonTail(1,n)*FuseVerticalDiameterAft(1,n);
        
        if FuseVerticalDiameterFore(n)==0
            FuseVerticalDiameterFore(n)=FuseVerticalDiameterAft(n);% error trap for fwd fuse x-sect
        end
        if FuseHorizontalDiameterFore(n)==0
            FuseHorizontalDiameterFore(n)=FuseHorizontalDiameterAft(n);% error trap for fwd fuse x-sect
        end
        [FuseParamFore]=fndfscf(FuseHorizontalDiameterFore,FuseVerticalDiameterFore,FuseDistortionFore,n);% derive FS coeff. for fwd fuse
        [FuseParamAft]=fndfscf(FuseHorizontalDiameterAft,FuseVerticalDiameterAft,FuseDistortionAft,n);% derive FS coeff. for cntr + aft fuse
        % parameters used to quantify the circumference for cross-section
        circfmu=FuseParamFore(1)*pi+2*FuseParamFore(2);% approx. upper curve circum. fwd fuse
        circfml=FuseParamFore(1)*pi-2*FuseParamFore(2);% approx. lower curve circum. fwd fuse
        circumu=FuseParamAft(1)*pi+2*FuseParamAft(2);% approx. upper curve circum. centre + aft
        circuml=FuseParamAft(1)*pi-2*FuseParamAft(2);% approx. lower curve circum. centre + aft
        circfru=2*circfmu/(pi*FuseVerticalDiameterAft(n));% circum. factor for upper fwd fuse geom.
        circfrl=2*circfml/(pi*FuseVerticalDiameterAft(n));% circum. factor for lower fwd fuse geom.
        circmru=2*circumu/(pi*FuseVerticalDiameterAft(n));% circum. factor for upper centre + aft fuselage geom.
        circmrl=2*circuml/(pi*FuseVerticalDiameterAft(n));% circum. factor for lower centre + aft fuselage geom.
        circfrm=(circfmu+circfml)/(pi*FuseVerticalDiameterAft(n));% total cross-section circumference
        circmrm=(circumu+circuml)/(pi*FuseVerticalDiameterAft(n));% total cross-section circumference
        CIRCUMX=[circfru circfrl circmrm circmru circmrl circfrm];% wetted area scaling factor
        %============================================================================
        % Horizontal tail geometric and aerodynamic definitions.
        %=====
        if HTailArea(n)>0.0001
            null(n)=0.0;% this signifies no juncture chord calc is required
            % the empennage only has a 2 segment definition, need to assume that
            % ghost segment 2 is equal to segment 1
            HTailQCSweep(2,n)=HTailQCSweep(1,n);HTailLESweep(2,n)=HTailLESweep(1,n);
            HTailThickness(3,n)=HTailThickness(4,n);
            %=====
            [kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
                netwgae,wsatref,wsarref,wsasref,wsarlsw,wsarqsw,wsarhsw,wsarmac,wsarybr, ...
                wsarthb,inc]=qxemcop(HTailKink,HTailTaper,HTailSpan,HTailArea,HTailAR, ...
                null,HTailThickness,HTailQCSweep,HTailLESweep,ReferenceWingConvention,null,HTailIncidence,n);
            %=====
            % output details about the original planform
            HTailIncidence(:,n)=inc;
            
            HTailKink(:,n)=kln(:,n);HTailSpan(n)=spn(n);HTailAR(n)=gar(n);
            HTailTaper(:,n)=tap(:,n);HTailThickness(2,n)=tmtrx(2,2);HTailThickness(3,n)=tmtrx(2,3);
            HTailDihedral(2,n)=HTailDihedral(3,n);HTHKROT(n)=troot;HTailOriginalRootChord(n)=crot;
            HTailQCSweep=qsw;HTailQCSweep(2,n)=HTailQCSweep(3,n);HTailLESweep=lsw;HTailLESweep(2,n)=HTailLESweep(3,n);
            HTailSpanMatrixPartition=smtrx;HTailThicknessMatrix=tmtrx;
            %=====
            % output details about the chosen reference wing
            RefHTailArea(n)=wsarref;RefHTailTaper(n)=wsatref;HTAWGAR(n)=wsasref;
            RefHTailLESweep(n)=wsarlsw;RefHTailQCSweep(n)=wsarqsw;RefHTailHCSweep(n)=wsarhsw;
            RefHTailMAC(n)=wsarmac;HTailMACSpanPos(n)=wsarybr;
            RefHTailThickness(n)=wsarthb;HTALEQS(n)=RefHTailQCSweep(n);
            %=====
            % compute the moment arm to h-tail 0.25MAC and the volume coefficient
            xibad=HTailSpanMatrixPartition(1)*tan(deg2rad*HTailLESweep(1,n));% inboard sweep adjustment
            xmbad=HTailSpanMatrixPartition(2)*tan(deg2rad*HTailLESweep(2,n));% midboard sweep adjustment
            xobad=HTailSpanMatrixPartition(3)*tan(deg2rad*HTailLESweep(3,n));% outboard sweep adjustment
            xhtal=HTailApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
                0.5*HTailSpan(n)*(1-HTailMACSpanPos(n))*tan(deg2rad*RefHTailLESweep(n))+0.25*RefHTailMAC(n);
            % locate the reference horizontal tail relative apex
            REFHAPX(n)=(HTailApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
                0.5*HTailSpan(n)*tan(deg2rad*RefHTailLESweep(n)))/FuseLength(n);
            HTailMomentArm(n)=abs(xhtal-xwing);% moment arm to h-tail
            % compute the volume coefficient
            htalvol(n)=RefHTailArea(n)*HTailMomentArm(n)/(ReferenceWingArea2(n)*RefWingMAC(n));
        else
            HTailMomentArm(n)=1.0;
        end
        %============================================================================
        % Canard geometric and aerodynamic definitions.
        %=====
        if CanardArea(n)>0.0001
            null(n)=0.0;% this signifies no juncture chord calc is required
            % the empennage only has a 2 segment definition, need to assume that
            % ghost segment 2 is equal to segment 1
            CanardQCSweep(2,n)=CanardQCSweep(1,n);CanardLESweep(2,n)=CanardLESweep(1,n);
            CanardThickness(3,n)=CanardThickness(4,n);
            %=====
            [kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
                netwgae,wsatref,wsarref,wsasref,wsarlsw,wsarqsw,wsarhsw,wsarmac,wsarybr, ...
                wsarthb,inc]=qxemcop(CanardKink,CanardTaper,CanardSpan,CanardArea,CanardAR, ...
                null,CanardThickness,CanardQCSweep,CanardLESweep,ReferenceWingConvention,null,CanardIncidence,n);
            %=====
            % output details about the original planform
            CanardIncidence(:,n)=inc;
            
            CanardKink(:,n)=kln(:,n);CanardSpan(n)=spn(n);CanardAR(n)=gar(n);
            CanardTaper(:,n)=tap(:,n);CanardThickness(2,n)=tmtrx(2,2);CanardThickness(3,n)=tmtrx(2,3);
            CanardDihedral(2,n)=CanardDihedral(3,n);CNHKROT(n)=troot;CanardOriginalRootChord(n)=crot;
            CanardQCSweep=qsw;CanardQCSweep(2,n)=CanardQCSweep(3,n);CanardLESweep=lsw;CanardLESweep(2,n)=CanardLESweep(3,n);
            CanardSpanMatrixPartition=smtrx;CanardThicknessMatrix=tmtrx;
            %=====
            % output details about the chosen reference wing
            RefCanardArea(n)=wsarref;RefCanardTaper(n)=wsatref;CANWGAR(n)=wsasref;
            RefCanardLESweep(n)=wsarlsw;RefCanardQCSweep(n)=wsarqsw;RefCanardHCSweep(n)=wsarhsw;
            RefCanardMAC(n)=wsarmac;CanardMACSpanPos(n)=wsarybr;
            RefCanardThickness(n)=wsarthb;CANREQS(n)=RefCanardQCSweep(n);
            %=====
            % compute the moment arm to h-tail 0.25MAC and the volume coefficient
            xibad=CanardSpanMatrixPartition(1)*tan(deg2rad*CanardLESweep(1,n));% inboard sweep adjustment
            xmbad=CanardSpanMatrixPartition(2)*tan(deg2rad*CanardLESweep(2,n));% midboard sweep adjustment
            xobad=CanardSpanMatrixPartition(3)*tan(deg2rad*CanardLESweep(3,n));% outboard sweep adjustment
            xcanr=CanardApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
                0.5*CanardSpan(n)*(1-CanardMACSpanPos(n))*tan(deg2rad*RefCanardLESweep(n))+0.25*RefCanardMAC(n);
            % locate the reference canard relative apex
            REFCAPX(n)=(CanardApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
                0.5*CanardSpan(n)*tan(deg2rad*RefCanardLESweep(n)))/FuseLength(n);
            CanardMomentArm(n)=abs(xcanr-xwing);% moment arm to canard
            % compute the volume coefficient
            canrvol(n)=RefCanardArea(n)*CanardMomentArm(n)/(ReferenceWingArea2(n)*RefWingMAC(n));
        else
            CanardMomentArm(n)=1.0;
        end
        %============================================================================
        % Vertical tail geometric and aerodynamic definitions.
        % the empennage only has a 2 segment definition, need to assume that
        % ghost segment 2 is equal to segment 1
        %=====
        if VTailArea(n)>0.0001
            null(n)=0.0;% this signifies no juncture chord calc is required
            VTailQCSweep(2,n)=VTailQCSweep(1,n);VTailLESweep(2,n)=VTailLESweep(1,n);
            VTailThickness(3,n)=VTailThickness(4,n);%VTailTaper(1,n)=0.0;
            %=====
            [kln,spn,gar,smtrx,crot,xscd,tap,cref,chrf,tref,chwf,troot,tmtrx,qsw,lsw, ...
                netwgae,wsatref,wsarref,wsasref,wsarlsw,wsarqsw,wsarhsw,wsarmac,wsarybr, ...
                wsarthbinc,inc]=qxemcop(VTailKink,VTailTaper,VTailSpan,VTailArea,VTailAR, ...
                null,VTailThickness,VTailQCSweep,VTailLESweep,ReferenceWingConvention,null,VTailIncidence,n);
            %=====
            % output details about the original planform
            VTailIncidence(:,n)=inc;
            
            VTailKink(:,n)=kln(:,n);VTailSpan(n)=spn(n);VTailAR(n)=gar(n);
            VTailTaper(:,n)=tap(:,n);VTailThickness(2,n)=tmtrx(2,2);VTailThickness(3,n)=tmtrx(2,3);
            VTHKROT(n)=troot;VTailOriginalRootChord(n)=crot;
            VTailQCSweep=qsw;VTailQCSweep(2,n)=VTailQCSweep(3,n);VTailLESweep=lsw;VTailLESweep(2,n)=VTailLESweep(3,n);
            VTailSpanMatrixPartition=2*smtrx;VTailThicknessMatrix=tmtrx;
            %=====
            % output details about the chosen reference wing
            RefVTailArea(n)=wsarref;RefVTailTaper(n)=wsatref;VTAWGAR(n)=wsasref;
            RefVTailLESweep(n)=wsarlsw;RefVTailQCSweep(n)=wsarqsw;RefVTailHCSweep(n)=wsarhsw;
            RefVTailMAC(n)=wsarmac;VTailMACSpanPos(n)=wsarybr;
            RefVTailThickness(n)=wsarthb;VTALEQS(n)=RefVTailQCSweep(n);
            %=====
            % compute the moment arm to v-tail 0.25MAC and the volume coefficient
            xibad=VTailSpanMatrixPartition(1)*tan(deg2rad*VTailLESweep(1,n));% inboard sweep adjustment
            xmbad=VTailSpanMatrixPartition(2)*tan(deg2rad*VTailLESweep(2,n));% midboard sweep adjustment
            xobad=VTailSpanMatrixPartition(3)*tan(deg2rad*VTailLESweep(3,n));% outboard sweep adjustment
            xvtal=VTailApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
                VTailSpan(n)*(1-VTailMACSpanPos(n))*tan(deg2rad*RefVTailLESweep(n))+0.25*RefVTailMAC(n);
            % locate the reference vertical tail relative apex
            REFVAPX(n)=(VTailApex(n)*FuseLength(n)+xibad+xmbad+xobad- ...
                VTailSpan(n)*tan(deg2rad*RefVTailLESweep(n)))/FuseLength(n);
            % locate reference vertical tail down to the fuselage reference plane
            REFVCAP(n)=(VTailApex(n)*FuseLength(n)- ...
                FuseVerticalDiameterAft(n)*abs(VTailVerticalLocale(n))*tan(deg2rad*RefVTailLESweep(n)))/FuseLength(n);
            % reference vertical tail root chord at fuselage reference plane
            REFVCRC(n)=Wing_Chord_At_Span(-FuseVerticalDiameterAft(n)*abs(VTailVerticalLocale(n)),VTailSpanMatrixPartition, ...
                2*RefVTailArea(n)/(VTailSpan(n)*(1+RefVTailTaper(n))),RefVTailTaper,n);
            VTailMomentArm(n)=abs(xvtal-xwing);% moment arm to v-tail
            % compute the volume coefficient
            vtalvol(n)=RefVTailArea(n)*VTailMomentArm(n)/(ReferenceWingArea2(n)*comspan);
        end
        %=================================
        qgeotry('geom2',n);% compute the powerplant dimensions
        %=================================
    case 'geom2'
        % eval(['global' blanks(1) GPARAMT]);% declare the global parameters
        %============================================================================
        if EnginesNumber(1,n) >0.0
        % Predict the engine and subsequent nacelle diameters.
        % Based on methods developed by Isikveren.
        %=====
        NacelleLength(1:2,n)=0.0;% initialise for calculation
        MaxTotalThrust=zeros(2,15);% initialise the by-pass ratio emulation variable
        %=====
        if EnginesNumber(2,n)>0.0
            PN=2;% prediction for primary and secondary powerplants
        else
            PN=1;% prediction for primary powerplants only
        end
        for i=1:PN
            % length of actual wing chord at engine location
            ChordAtEngine(i,n)=Wing_Chord_At_Span(abs(EnginesLocalY(i,n))*WingSpan(n)/2,SpanMatrixPartition, ...
                RefWingChordOrigin(n),WingTaper,n);
            %=====
            OnWing(i,n)=0;% initialise variables
            % predict the engine diameter
            EnginesDiameter(i,n)=((2)^-0.5)*(1.73*log(MaxThrust(i,n))-pi)^0.5;
            NacellePitotDiameter(i,n)=EnginesDiameter(i,n)+0.25;% generic pitot nacelle diameter
            if EngineMaxDiameter(i,n)<0.0001
                % For on-wing installations
                if EnginesLayout(i,n)==1.0 || EnginesLayout(i,n)==2.0
                    OnWing(i,n)=1;% invoke on-wing installation
                end
                % predicted nacelle maximum diameter
                EngineMaxDiameter(i,n)=(4-OnWing(i,n))*(0.0625+EnginesDiameter(i,n)/4);
            else
                EnginesDiameter(i,n)=EngineMaxDiameter(i,n)-0.25;% predicted engine max. diameter
            end
            %=====
            % the propeller diameter has not been given
            if PropellerDiameter(i,n)<0.0001
                PropellerDiameter(i,n)=(qxheavy(EnginesType(i,n),1,1)*3+ ...
                    0.48*qxheavy(EnginesType(i,n),3,1))*EnginesDiameter(i,n);
            end
            if EnginesType(i,n)>0.0001
                NacelleType(i,n)=1;% automatically choose long duct for props
            end
            %=====
            % predicted engine length
            EngineLength=(MaxThrust(i,n)^0.9839)/(2*pi*(1.73*log(MaxThrust(i,n))-pi));
            NacellePitotLength(i,n)=5/3*EngineLength;% generic pitot nacelle length
            if NacelleFineness(i,n)<0.0001 && EnginesLayout(i,n)>3
                % predict the nacelle length for S and straight ducts only
                NacelleLength(i,n)=(5+NacelleType(i,n)+0.44*qxheavy(EnginesType(i,n),3,1)+ ...
                    7/4*qxheavy(EnginesLayout(i,n),4,1))/3*EngineLength+ ...
                    OnWing(i,n)*ChordAtEngine(i,n);
            elseif NacelleFineness(i,n)<0.0001 && EnginesLayout(i,n)<4 && EnginesType(i,n)<0.0001
                NacelleLength(i,n)=NacellePitotLength(i,n);% assume original estimate
            elseif NacelleFineness(i,n)<0.0001 && EnginesLayout(i,n)<4 && EnginesType(i,n)>2
                NacelleLength(i,n)=1.81*NacellePitotLength(i,n);% assume original estimate
            else
                NacelleLength(i,n)=NacelleFineness(i,n)*EngineMaxDiameter(i,n);% user defined nacelle
            end
            %=====
            % check to see if a by-pass ratio emulation is required
            if BypassRatio(i,n)<0.0001
                % predict the by-pass ratio for turbofans -
                % sourced from C. Svoboda, Aircraft Design Journal, 3(2000) 17-31
                BypassRatio(i,n)=3.2+0.01*(MaxThrust(i,n)*1000/knwlbf)^0.5;
                MaxTotalThrust(i,n)=MaxThrust(i,n);
                if EnginesType(i,n)>0.0
                    BypassRatio(i,n)=3*BypassRatio(i,n);% equivalent by-pass for props
                end
            else
                if EnginesType(i,n)>0.0
                    BypassRatio(i,n)=BypassRatio(i,n)/3;% assume fan for modelling purposes
                end
                if BypassRatio(i,n)<3.43
                    BypassRatio(i,n)=3.43;% minimum fan by-pass ratio for emulation
                end
                MaxTotalThrust(i,n)=0.001*knwlbf*(100*(BypassRatio(i,n)-3.2))^2;
                if EnginesType(i,n)>0.0
                    BypassRatio(i,n)=3*BypassRatio(i,n);% assume fan for modelling purposes
                end
            end
            NacelleFineness(i,n)=NacelleLength(i,n)/EngineMaxDiameter(i,n);% compute the nac. fineness
        end
        end
        
        return
        %=================================
    otherwise
        disp([mfilename ': unknown action ''' action ''''])
end
%============================================================================
function [cROSXCF]=fndfscf(hma,vma,vmi,z)
% a shape function correction is introduced for cross-sections having only
% vertical axis-symmetric properties
% set up the easily discernable cross-section points
% note that the distortion coefficient is "FuseDistortionAft"
deltahm=1  ;fusetar=hma(z);% starting point for convergence
the1=pi/2  ;rad1=vmi(z)*vma(z);% distorted vertical radius
the3=3*pi/2;rad3=(1-vmi(z))*vma(z);% distorted vertical radius
the5=pi/2  ;rad5=vmi(z)*vma(z);% distorted vertical radius
crosxc0(1:3)=0.0001;% initial estimate for coefficients
for i=1:2
    if vmi(z)<0.5
        the2=3*pi/2-atan(hma(z)/(2*(0.5-vmi(z))*vma(z)));
        the4=3*pi/2+atan(hma(z)/(2*(0.5-vmi(z))*vma(z)));
    elseif vmi(z)>0.5
        the2=pi/2+atan(hma(z)/(2*(vmi(z)-0.5)*vma(z)));
        the4=pi/2-atan(hma(z)/(2*(vmi(z)-0.5)*vma(z)));
    else
        the2=pi;the4=2*pi;
    end
    rad2=hma(z)/2;% the start point for ray-tracing
    rad4=hma(z)/2;% maximum horizontal radius
    thedat=[the1 the2 the3 the4 the5];% the angular trace matrix
    raddat=[rad1 rad2 rad3 rad4 rad5];% the radii trace matrix
    % the computed correlation coefficients for the cross-section
    [cROSXCF,resnorm]=lsqcurvefitjo('qxfours',crosxc0,thedat,raddat,0,2*pi);
    % ensure the maximum horizontal width is not violated
    if vmi(z)<0.5
        fusehsa=fix(100*2*sin(atan(hma(z)/(2*(0.5- ...
            vmi(z))*vma(z))))*(cROSXCF(1)+cROSXCF(2)*sin(the2)+ ...
            cROSXCF(3)*cos(2*the2)))/100;
    elseif vmi(z)>0.5
        fusehsa=fix(100*2*sin(atan(hma(z)/(2*(vmi(z)- ...
            0.5)*vma(z))))*(cROSXCF(1)+cROSXCF(2)*sin(the2)+ ...
            cROSXCF(3)*cos(2*the2)))/100;
    else
        break;% jump out of the loop
    end
    deltahm=fusehsa/fusetar;hma(z)=hma(z)/deltahm;
end
hma(z)=fusetar;% go back to original input hma(z)

return
%============================================================================
