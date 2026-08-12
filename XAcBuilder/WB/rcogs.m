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
%   DESCRIPTION:   Execute the centre of gravity prediction routines
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
%
% *********** Read User input COGS coordinates *****************
  fileflag=which('wb_flag_user_mass.txt');
  fid = fopen(fileflag);
  tlineflag = fgetl(fid);
  fclose(fid);
  
  cogsImp=zeros(1,69); % 3 x 23 elements
  if (strcmp(tlineflag,'159')==1)
      disp('OK - Lettura file con cogs componenti')
       CoGsMOD=159;
       fid = fopen(which('wb_file_user_cogs.txt'));
       tline = fgetl(fid);
       lineUserCogs=1; % Indice per lettura riga file
       while ischar(tline)
          %disp(tline)
          cogsImp(1,lineUserCogs)=str2double(tline);
          tline = fgetl(fid);
          lineUserCogs=lineUserCogs+1;
      end
      fclose(fid);
      %cogsImp % CONTROLLO      
  else
      disp('NO COGs imposti')
     CoGsMOD=160;
      %ALNDGWEI(n)=0;
      %wi2gmas=0;
  end  
% **************************************************************




if EnginesNumber(2, n) > 0.0
    PN = 2;% prediction for primary and secondary powerplants
else
    PN = 1;% prediction for primary powerplants only
end


% Added here a call to qgeotry
% This routine computes/checks the cabin & baggage dimensions and properties

% Predict cabin height
if CabinMaxHeight(n) < 0.0001 && FuseVerticalDiameterAft(n) > 0.0001

    if FuseDistortionAft(n) > 0.5
        CabinMaxHeight(n) = FuseDistortionAft(n)*FuseVerticalDiameterAft(n) - 0.15;  % double-bubble cabin height
    else
        if WingPlacement(n) < 0 || WingPlacement(n) > 1
            CabinMaxHeight(n) = FuseVerticalDiameterAft(n) - 0.2;  % wingbox does not go through x-section
        else
            if WingPlacement(n) > 0.5
                % circular x-section cabin height for high wings
                CabinMaxHeight(n) = FuseVerticalDiameterAft(n)*WingPlacement(n) - WingThickness(2,1)*RefWingChordOrigin(n)/2 - 0.2;
            else
                % circular x-section cabin height for low wings
                CabinMaxHeight(n) = FuseVerticalDiameterAft(n)*(1-WingPlacement(n)) - WingThickness(2,1)*RefWingChordOrigin(n)/2 - 0.2;
            end
        end
    end

end

% Predict cabin max width
if CabinMaxWidth(n) < 0.0001 && FuseHorizontalDiameterAft(n) > 0.0001
    CabinMaxWidth(n) = FuseHorizontalDiameterAft(n) - 0.2;
end

% Predict cabin floor width
if CabinFloorWidth(n) < 0.0001 && FuseVerticalDiameterAft(n) > 0.0001

    if FuseDistortionAft(n) > 0.5

        FloorAngle = atan(2*FuseVerticalDiameterAft(n)*(FuseDistortionAft(n)-0.5)/FuseHorizontalDiameterAft(n)) + pi;
        FloorRadius = FuseParamAft(1) + FuseParamAft(2)*sin(FloorAngle) + FuseParamAft(3)*cos(2*FloorAngle);

        % double-bubble floor width
        CabinFloorWidth(n) = 2*FloorRadius*cos(FloorAngle-pi) - 0.2;

    else

        % predict the floor width
        CabinFloorWidth(n) = ((CabinMaxWidth(n)^2)-4*(((FuseVerticalDiameterAft(n) - WingThickness(2,1)*RefWingChordOrigin(n)- 0.2)/2)^2))^0.5;

    end

end

% Predict cabin volume
if ~CabinVolume

    hbar = 0.5*( (CabinMaxWidth(n)^2) - CabinFloorWidth(n)^2 )^0.5;
    cabth = atan(2*hbar/CabinFloorWidth(n));
    CabinVolume(n) = CabinLength(n)/4 * (CabinMaxWidth(n)*(pi*CabinMaxHeight(n) + cabth*CabinMaxWidth(n))+...
        hbar*(2*CabinFloorWidth(n) - pi*CabinMaxWidth(n)));

end

% Predict baggage apex: baggage is located underfloor and can be
% shifted aft/rear along fuselage following BaggageInstallation (installation type)
% values.
%%%%SR if BaggageApex(n) < 0.0001
    if BaggageApex(n) < 0.0001

    if BaggageInstallation(n) ~= 0
        % estimate the underfloor baggage 1 apex
        BaggageApex(n) = 1.5*NoseLength(n)/FuseLength(n);
    else
        % estimate aft baggage apex
        BaggageApex(n) = (NoseLength(n) + CabinLength(n))/FuseLength(n);
    end

    end

%%%%SR end

% Predict baggage volume and combined length
if BaggageVolume(n) == -1

    % upper limit of baggage vol per PAX = 13.5 cu.ft
    MaxBaggageVolumePerPAX = 0.382; % m^3
    BaggageScaleFactor = 1;     % scale factor

    % aircraft.miscellaneous.Design_classification = DesignClassification
    if DesignClassification(n) < 2
        BaggageScaleFactor = 0.48;              % scale for commercial transportation
    elseif DesignClassification(n) == 2
        BaggageScaleFactor = 0.63;              % scale for business jets larger than super midsize
    end

    BaggageVolume(n) = Passengers(n)*BaggageScaleFactor*MaxBaggageVolumePerPAX;                    % baggage volume prediction

    if BaggageInstallation(n) ~= 0
        BaggageArea = 2*(FuseVerticalDiameterAft(n)-CabinMaxHeight(n)-0.45)*CabinFloorWidth(n)/3;	% x-sec area u/floor
        BaggageLength(n) = BaggageVolume(n)/BaggageArea;                        % estimate u/floor total baggage length
    else
        BaggageLength(n) = BaggageVolume(n)/CabinVolume(n)*CabinLength(n);          % est. aft baggage length
    end

elseif BaggageVolume(n) < 0.0001 && BaggageLength(n) > 0.0001

    if BaggageInstallation(n)~=0
        BaggageArea = 2*(FuseVerticalDiameterAft(n)-CabinMaxHeight(n)-0.45)*CabinFloorWidth(n)/3;	% x-sec area u/floor
        BaggageVolume(n) = BaggageArea*BaggageLength(n);                        % estimate u/floor baggage volume
    else
        BaggageVolume(n) = CabinVolume(n)/CabinLength(n)*BaggageLength(n);          % estimate baggage volume
    end

elseif BaggageVolume(n) > 0.0001 && BaggageLength(n) < 0.0001

    if BaggageInstallation(n) ~= 0
        BaggageArea = 2*(FuseVerticalDiameterAft(n)-CabinMaxHeight(n)-0.45)*CabinFloorWidth(n)/3;	% x-sec area u/floor
        BaggageLength(n) = BaggageVolume(n)/BaggageArea;                        % estimate u/floor baggage length
    else
        BaggageLength(n) = BaggageVolume(n)/CabinVolume(n)*CabinLength(n);          % estimate baggage length
    end

end



% Wing no.1 longitudinal and vertical cg (hybrid Torenbeek & SAWE)

if MACSpanPos(n) > WingKink(1, n)

    % MAC is located after kink 1 zone
%%%%SR    if WingXCG(n) < 0.0001 && WingConfiguration(n) ~= 1

        WingXCG(n) = ( FuseLength(n)*WingApex(n) +...
            SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1, n)) +...
            (MACSpanPos(n) - ...
            WingKink(n))*SpanMatrixPartition(2)*tan(deg2rad*WingLESweep(2,n)) + ...
            0.49*Wing_Chord_At_Span( MACSpanPos(n)*WingSpan(n)/2, SpanMatrixPartition, ...
            RefWingChordOrigin(n), WingTaper, n ) )/FuseLength(n);

%%%%SR    end

%%%%SR    if WingZCG(n) < 0.0001

        WingZCG(n) = ( FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5) + ...
            SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n)) + ...
            (MACSpanPos(n)- ...
            WingKink(n))*SpanMatrixPartition(2)*tan(deg2rad*WingDihedral(2, ...
            n)) )/FuseVerticalDiameterAft(n);

%%%%SR    end

else

    % otherwise MAC is in kink 1 zone
%%%%SR    if WingXCG(n) < 0.0001 && WingConfiguration(n) ~= 1

        WingXCG(n) = ( FuseLength(n)*WingApex(n) + ...
            MACSpanPos(n)*SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1,n)) + ...
            0.49*Wing_Chord_At_Span( MACSpanPos(n)*WingSpan(n)/2, SpanMatrixPartition, ...
            RefWingChordOrigin(n), WingTaper, n ) )/FuseLength(n);

%%%%SR    end

%%%%SR    if WingZCG(n) < 0.0001

        WingZCG(n) = ( FuseVerticalDiameterAft(n)*(WingPlacement(n)-0.5) + ...
            MACSpanPos(n)*SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1, ...
            n)) )/FuseVerticalDiameterAft(n);

%%%%SR    end

end

if WingConfiguration(n) ~= 0

    WingXCG(n) = ( FuseLength(n)*WingApex(n) + ...
        (FrontSparPosition(1,n) + ...
        RearSparPosition(1,n))/2*RefWingChordOrigin(n) )/FuseLength(n);

end
%WingXCG(n)=0.3 % Test
% Output
PLOTCGS(1, 1, n) = WingXCG(n)*FuseLength(n);% x-axis
PLOTCGS(1, 2, n) = WingYCG(n)*FuseLength(n);% y-axis
PLOTCGS(1, 3, n) = WingZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
WingXCG(n)=cogsImp(1,1); % x
WingYCG(n)=cogsImp(1,2); % y
WingZCG(n)=cogsImp(1,3); % z
PLOTCGS(1, 1, n) = WingXCG(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(1, 2, n) = WingYCG(n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(1, 3, n) = WingZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************

%==========================================================================
% Originally commented in the code - modified 06/11/2008

wi2present(1,n) = aircraft.Wing2.present;
if wi2present(1,n) == 1
% if wi2gare(n) > 0.0001

    % Added these variable to handle Wing2 case
    WS2NMTX = aircraft.Wing2.Span_matrix_partition_in_mid_outboard;
    wi2glsw(1, n) = aircraft.Wing2.LE_sweep_inboard;
    wi2glsw(2, n) = aircraft.Wing2.LE_sweep_midboard;
    wi2glsw(3, n) = aircraft.Wing2.LE_sweep_outboard;
    wi2gspn(1, n) = aircraft.Wing2.Span;
    WI2WLSW(1, n) = aircraft.Wing2.Reference_LE_sweep;
    wi2gapx(1, n) = aircraft.Wing2.apex_locale;
    WI2WYBR(1, n) = aircraft.Wing2.Reference_non_dim_y_bar;
    WI2WMAC(1, n) = aircraft.Wing2.Reference_MAC;


    wi2apxr = WS2NMTX(1)*tan(deg2rad*wi2glsw(1, n))+ ...
        WS2NMTX(2)*tan(deg2rad*wi2glsw(2, n))+ ...
        WS2NMTX(3)*tan(deg2rad*wi2glsw(3, n));
    wi2apxf = wi2gspn(n)/2*tan(deg2rad*WI2WLSW(n));
    ne2apex = wi2gapx(n) + (wi2apxr - wi2apxf)/FuseLength(n);

    % wing no.2 longitudinal cg (Torenbeek & SAWE)
    WI2GBAX(n) = ((ne2apex + WI2WYBR(n)*wi2gspn(n)/2*tan(deg2rad*WI2WLSW(n))+ ...
        0.4*WI2WMAC(n))/FuseLength(n)) + wi2gapx(1,n); % Aggiunta somma  wi2gapx(1,n) per visualizzazione diamante in posizione corretta
    

    PLOTCGS(2, 1, n) = WI2GBAX(n)*FuseLength(n);
    
    % **** Aggiunto per Posizione Z: Approssimato in placement (da
    % sistemare) ********************************************************
    %WI2GBAZ(n) = aircraft.Wing2.placement * FuseVerticalDiameterAft(n)
    %PLOTCGS(2, 3, n) = WI2GBAZ(n) %/ FuseVerticalDiameterAft(n)
    % ********************************************************************
    
    %WI2GBAZ(n) = aircraft.Wing2.z                               % Aggiunto
    %PLOTCGS(2, 3, n) = WI2GBAZ(n) * FuseVerticalDiameterAft(n)      % Aggiunto
    
    %WI2GBAX(n) = PLOTCGS(2, 1, n)/FuseLength(n)   % Aggiunto
    % disp('Controllo')
    % WI2GBAX(n) % Controllo

% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
WI2GBAX(n)=cogsImp(1,4); % x
WI2GBAY(n)=cogsImp(1,5); % y
WI2GBAZ(n)=cogsImp(1,6); % z
PLOTCGS(2, 1, n) = WI2GBAX(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(2, 2, n) = WI2GBAY(n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(2, 3, n) = WI2GBAZ(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************
    
    
    
end
%==========================================================================

% h-tail longitudinal and vertical cg (hybrid Torenbeek & SAWE)

if HTailArea(n) > 0.0001

    if HTailMACSpanPos(n) > HTailKink(1, n)

        % MAC is located after kink 1 zone
%%%%SR        if HTailXCG(n) < 0.0001

            if EmpennageLayout(1, n)
                HTailApexAbs = HTailLongitudinalLocation;
            else
                HTailApexAbs = FuseLength(n)*HTailApex(n);
            end

            HTailXCG(n) = ( HTailApexAbs + ...
                HTailKink(n)*HTailSpan(n)/2*tan(deg2rad*HTailLESweep(1,n)) + ...
                (HTailMACSpanPos(n)- ...
                HTailKink(n))*HTailSpan(n)/2*tan(deg2rad*HTailLESweep(3,n)) + ...
                0.42*tailchord(HTailTaper(1,n),HTailTaper(3,n), HTailOriginalRootChord(n),HTailMACSpanPos(n),HTailKink(n)) )/FuseLength(n);
%%%%SR        end

%%%%SR        if HTailZCG(n) < 0.0001

            if EmpennageLayout(1, n)
                HTailVerticalLocationAbs = HTailVerticalLocation;
            else
                HTailVerticalLocationAbs = FuseVerticalDiameterAft(n)*HTailVerticalLocale(n);
            end

            HTailZCG(n) = ( HTailVerticalLocationAbs + ...
                HTailSpanMatrixPartition(1)*tan(deg2rad*HTailDihedral(1,n)) + ...
                (HTailMACSpanPos(n) - ...
                HTailKink(n))*HTailSpanMatrixPartition(2)*tan(deg2rad*HTailDihedral(2, ...
                n)) )/FuseVerticalDiameterAft(n);

%%%%SR        end

    else

        % otherwise MAC is in kink 1 zone
%%%%SR        if HTailXCG(n) < 0.0001

            HTailXCG(n) = ( FuseLength(n)*HTailApex(n) + ...
                HTailMACSpanPos(n)*tan(deg2rad*HTailLESweep(1,n))*HTailSpan(n)/2 + ...
                0.42*tailchord(HTailTaper(1,n),HTailTaper(3,n), HTailOriginalRootChord(n),HTailMACSpanPos(n),HTailKink(n)) )/FuseLength(n);

%%%%SR        end

%%%%SR        if HTailZCG(n) < 0.0001

            HTailZCG(n) = ( FuseVerticalDiameterAft(n)*HTailVerticalLocale(n) + ...
                HTailMACSpanPos(n)*HTailSpanMatrixPartition(1)*tan(deg2rad*HTailDihedral(1, ...
                n)) )/FuseVerticalDiameterAft(n);

%%%%SR        end

    end

end
%HTailXCG(n)=0.1;
% Output
PLOTCGS(3, 1, n) = HTailXCG(n)*FuseLength(n);% x-axis
PLOTCGS(3, 2, n) = HTailYCG(n)*FuseLength(n);% y-axis
PLOTCGS(3, 3, n) = HTailZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
HTailXCG(n)=cogsImp(1,7); % x
HTailYCG(n)=cogsImp(1,8); % y
HTailZCG(n)=cogsImp(1,9); % z
PLOTCGS(3, 1, n) = HTailXCG(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(3, 2, n) = HTailYCG(n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(3, 3, n) = HTailZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************
% Vertical tail longitudinal and vertical cg (hybrid Torenbeek & SAWE)
if VTailArea(n) > 0.0001

    if VTailMACSpanPos(n) > VTailKink(1, n)

        % MAC is located after kink 1 zone
%%%%SR        if VTailXCG(n) < 0.0001

            VTailXCG(n) = ( FuseLength(n)*VTailApex(n) + ...
                 VTailKink(n)*VTailSpan(n)*tan(deg2rad*VTailLESweep(1,n)) + ...
                (VTailMACSpanPos(n) - ...
                VTailKink(n))*VTailSpan(n)*tan(deg2rad*VTailLESweep(3,n)) + ...
                0.42*tailchord(VTailTaper(1,n),VTailTaper(3,n), VTailOriginalRootChord(n),VTailMACSpanPos(n),VTailKink(n)) )/FuseLength(n);

%%%%SR        end

    else

        % otherwise MAC is in kink 1 zone
%%%%SR        if VTailXCG(n) < 0.0001

            VTailXCG(n) = ( FuseLength(n)*VTailApex(n) + ...
                VTailMACSpanPos(n)*VTailSpan(n)*tan(deg2rad*VTailLESweep(1,n)) + ...
                0.42*tailchord(VTailTaper(1,n),VTailTaper(3,n), VTailOriginalRootChord(n),VTailMACSpanPos(n),VTailKink(n)) )/FuseLength(n);

%%%%SR        end

    end

    VTailZCG(n) = ( FuseVerticalDiameterAft(n)*VTailVerticalLocale(n) + ...
        VTailMACSpanPos(n)*VTailSpan(n) )/FuseVerticalDiameterAft(n);
else
    VTailXCG(n) = 0;
    VTailZCG(n) = 0;

end

% Output
PLOTCGS(4, 1, n) = VTailXCG(n)*FuseLength(n);% x-axis
% PLOTCGS(4, 2, n) = TwinTailSpan*WingSpan(n);  % y-axis
PLOTCGS(4, 2, n) = 0;  % y-axis
PLOTCGS(4, 3, n) = VTailZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
VTailXCG(n)=cogsImp(1,10); % x
VTailYCG(n)=cogsImp(1,11); % y
VTailZCG(n)=cogsImp(1,12); % z
PLOTCGS(4, 1, n) = VTailXCG(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(4, 2, n) = 0;%VTailYCG(n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(4, 3, n) = VTailZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************



% TwinTail = 0/1 (0 = no twin tail; 1 = twin tail present)

if TwinTail

%
% Modified SR 11/06/2010
% Y position of CoG assigned explicitely otherwise always =0

    VTailYCG(n) = TwinTailSpan*WingSpan/2;

    PLOTCGS(4,  2, n) =  TwinTailSpan*WingSpan(n)/2;% y-axis
    PLOTCGS(10, 1, n) =  PLOTCGS(4, 1, n);         % x-axis
    PLOTCGS(10, 2, n) = -TwinTailSpan*WingSpan(n)/2;% y-axis
    PLOTCGS(10, 3, n) =  PLOTCGS(4, 3, n);         % z-axis

end

% LR added on 16/02/2010
% Canard longitudinal and vertical cg (copied from HT)
%
if canard_flag

    if CanardMACSpanPos(n) > CanardKink(1, n)

        % MAC is located after kink 1 zone
%%%%SR        if CanardXCG(n) < 0.0001
          
            CanardApex = FuseLength(n)*CanardApex(n);

            CanardXCG(n) = ( CanardApex + ...
                CanardKink(n)*CanardSpan(n)/2*tan(deg2rad*CanardLESweep(1,n)) + ...        
                (CanardMACSpanPos(n)- ...
                CanardKink(n))*CanardSpan(n)/2*tan(deg2rad*CanardLESweep(3,n)) + ...
                0.42*tailchord(CanardTaper(1,n),CanardTaper(3,n), CanardOriginalRootChord(n),CanardMACSpanPos(n),CanardKink(n)) )/FuseLength(n);    
            
%%%                0.42*Wing_Chord_At_Span( CanardMACSpanPos(n)*CanardSpan(n)/2, CanardSpanMatrixPartition, ...
%%%                CanardOriginalRootChord(n), CanardTaper, n ) )/FuseLength(n);
           
%%%%SR        end

%%%%SR        if CanardZCG(n) < 0.0001

            CanardVerticalLocale = FuseVerticalDiameterAft(n)*CanardVerticalLocale(n);

            CanardZCG(n) = ( CanardVerticalLocale + ...
                CanardSpanMatrixPartition(1)*tan(deg2rad*CanardDihedral(1,n)) + ...
                (CanardMACSpanPos(n) - ...
                CanardKink(n))*CanardSpanMatrixPartition(2)*tan(deg2rad*CanardDihedral(2, ...
                n)) )/FuseVerticalDiameterAft(n);

%%%%SR        end

    else

        % otherwise MAC is in kink 1 zone
%%%%SR        if CanardXCG(n) < 0.0001

            CanardXCG(n) = ( FuseLength(n)*CanardApex(n) + ...
            CanardMACSpanPos(n)*tan(deg2rad*CanardLESweep(1,n))*CanardSpan(n)/2 + ...
            0.42*tailchord(CanardTaper(1,n),CanardTaper(3,n), CanardOriginalRootChord(n),CanardMACSpanPos(n),CanardKink(n)) )/FuseLength(n);    
            
%%%%        0.42*Wing_Chord_At_Span(CanardMACSpanPos(n)*CanardSpan(n)/2, CanardSpanMatrixPartition, ...
%%%%                CanardOriginalRootChord(n), CanardTaper, n) )/FuseLength(n);
            
%%%%SR        end

%%%%SR        if CanardZCG(n) < 0.0001

            CanardZCG(n) = ( FuseVerticalDiameterAft(n)*CanardVerticalLocale(n) + ...
                CanardMACSpanPos(n)*CanardSpanMatrixPartition(1)*tan(deg2rad*CanardDihedral(1, ...
                n)) )/FuseVerticalDiameterAft(n);

%%%%SR        end

    end

end

% Output
PLOTCGS(11, 1, n) = CanardXCG(n)*FuseLength(n);% x-axis
PLOTCGS(11, 2, n) = CanardYCG(n)*FuseLength(n);% y-axis
PLOTCGS(11, 3, n) = CanardZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
CanardXCG(n)=cogsImp(1,25); % x
CanardYCG(n)=cogsImp(1,26); % y
CanardZCG(n)=cogsImp(1,27); % z
PLOTCGS(11, 1, n) = CanardXCG(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(11, 2, n) = CanardYCG(n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(11, 3, n) = CanardZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************

%--------------------------------------------------------------------------
% SR 31/05/2010 - Added Tailbooms
%{
% **** ORIGINALE **********************************************************
if tailbooms_flag
    TBXCG(n) = TBxLoc(n)+ 0.5*TBLength(n)/FuseLength(n);
    TBZCG(n) = TBzLoc(n);
    TBYCG(n) = TByLoc(n)*WingSpan/2;
else
    TBXCG(n) = 0.0;
    TBZCG(n) = 0.0;
    TBYCG(n) = 0.0;
end

%Output
% *************************************************************************
%}

    % *********** Rotazione Tailbooms ********************
 if tailbooms_flag
   TBAngleZ=(pi/180)*aircraft.Tailbooms.Angle_z;
   TBAngleY=(pi/180)*aircraft.Tailbooms.Angle_y;
   cg_gap=0;%aircraft.Tailbooms.axial_cg_gap;
    if abs(TBAngleY)>0
     TBnewZ = sin(TBAngleY)*(0.5+cg_gap)*TBLength(n)/FuseVerticalDiameterAft(n);
     TBnewX = cos(TBAngleZ)*cos(TBAngleY);
     TBnewY = (0.5+cg_gap)*TBLength(n)*cos(TBAngleY)*sin(TBAngleZ)/(WingSpan*0.5); % verifica cos(angley)?
    else
     TBnewZ = 0;
     TBnewX = cos(TBAngleZ);
     TBnewY = (0.5+cg_gap)*TBLength(n)*sin(TBAngleZ)/(WingSpan*0.5);
    end

    %kmodaz=cos(TBAngleY)*cos(TBAngleZ)*cos(TBAngleZ)
    %TBxLoc(n)
    %TBLength(n)
    %FuseLength(n)
% *****************************************************
    
    TBXCG(n) = TBxLoc(n) + ((TBnewX)*(0.5+cg_gap)*TBLength(n)/FuseLength(n));
    TBZCG(n) = TBzLoc(n) + TBnewZ;
    TBYCG(n) = (-TBnewY+TByLoc(n))*WingSpan/2;
    %TByLoc(n)
    %WingSpan
    
else
    TBXCG(n) = 0.0;
    TBZCG(n) = 0.0;
    TBYCG(n) = 0.0;
end

PLOTCGS(12, 1, n) = TBXCG(n)* FuseLength(n);
PLOTCGS(12, 2, n) = TBYCG(n);%* WingSpan(n)/2;
PLOTCGS(12, 3, n) = TBZCG(n)* FuseVerticalDiameterAft(n);


% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
    
% *****************************
%{
if tailbooms_flag
   
    TBAngleZ=(pi/180)*aircraft.Tailbooms.Angle_z;
    TBAngleY=(pi/180)*aircraft.Tailbooms.Angle_y;
    cg_gap=aircraft.Tailbooms.axial_cg_gap;
    
    if abs(TBAngleY)>0
     TBnewZ = sin(TBAngleY)*(0.5+cg_gap)*TBLength(n)/FuseVerticalDiameterAft(n);
     TBnewX = cos(TBAngleZ)*cos(TBAngleY);
     TBnewY = (0.5+cg_gap)*TBLength(n)*cos(TBAngleY)*sin(TBAngleZ)/(WingSpan*0.5); % verifica cos(angley)?
    else
     TBnewZ = 0;
     TBnewX = cos(TBAngleZ);
     TBnewY = (0.5+cg_gap)*TBLength(n)*sin(TBAngleZ)/(WingSpan*0.5);
    end
    
    TBXCG(n) = TBxLoc(n) + ((TBnewX)*(0.5+cg_gap)*TBLength(n)/FuseLength(n));
    TBZCG(n) = TBzLoc(n) + TBnewZ;
    TBYCG(n) = (-TBnewY+TByLoc(n))*WingSpan/2;    
else
    TBXCG(n) = 0.0;
    TBZCG(n) = 0.0;
    TBYCG(n) = 0.0;
end
%}
% *****************************

TBXCG(n)=cogsImp(1,28); % x
TBYCG(n)=cogsImp(1,29); % y
TBZCG(n)=cogsImp(1,30); % z
PLOTCGS(12, 1, n) = TBXCG(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(12, 2, n) = TBYCG(n);%*FuseLength(n);% cogsImp(1,2)
PLOTCGS(12, 3, n) = TBZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************



% fuselage longitudinal and vertical cg (Torenbeek)

%%%%SR if FuseXCG(n) < 0.0001

    CentralFuseLength = FuseLength(n) - NoseLength(n) - TailLength(n);
    HalfFuseLength = CentralFuseLength/2 + NoseLength(n);
    % fuselage longitudinal cg (geometric handbook)
    FuseXCG(n) = ( HalfFuseLength - (NoseLength(n)^2)/(NoseLength(n) + ...
        2*CentralFuseLength + TailLength(n))/3 + ...
        (TailLength(n)^2)/(NoseLength(n) + ...
        2*CentralFuseLength + TailLength(n))/3 )/FuseLength(n);% x-axis

    % adjust the isolated fuselage cg due to propulsion installation
    if EnginesNumber(1,n)>0
        for i = 1:PN
            
            if EnginesLayout(i, n) < 3
                
                % on-wing nacelle (2) on-wing integrated with undercarraige
                FuseXCG(n) = FuseXCG(n) + 0.03;% based on Torenbeek
                
            elseif EnginesLayout(i, n) > 3
                
                % aft fuselage mounted striaght and S-ducts
                FuseXCG(n) = FuseXCG(n) + 0.10;% based on Torenbeek
                
            else
                
                % aft fuselage mounted on pylons
                FuseXCG(n) = FuseXCG(n) + 0.08;% based on Torenbeek
                
            end
            
        end
    end

%%%%SR end

%%%%SR if FuseZCG(n) < 0.0001

    FuseZCG(n) = -0.1; % z-axis

%%%%SR end

% Output
PLOTCGS(5, 1, n) = FuseXCG(n)*FuseLength(n);% x-axis
PLOTCGS(5, 3, n) = FuseZCG(n)*FuseVerticalDiameterAft(n);% z-axis


% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
FuseXCG(n)=cogsImp(1,13); % x
FuseYCG(n)=cogsImp(1,14); % y
FuseZCG(n)=cogsImp(1,15); % z
PLOTCGS(5, 1, n) = FuseXCG(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(5, 2, n) = FuseYCG(n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(5, 3, n) = FuseZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************


% Main landing gear: if not specified place the main landing gear CoG on
% the wing one
%
if landinggear_flag
    if LandingGearXCG(n) ~= 0
      %PLOTCGS(6, 1, n) = PLOTCGS(1, 1, n); % x-axis
      %LandingGearXCG(n) = PLOTCGS(6, 1, n)/FuseLength(n);
      PLOTCGS(6, 1, n) =LandingGearXCG(n);%57.70%PLOTCGS(1, 1, n); % x-axis
      LandingGearXCG(n) = PLOTCGS(6, 1, n)/FuseLength(n);    
    else
      PLOTCGS(6, 1, n) = PLOTCGS(1, 1, n);% x-axis
      LandingGearXCG(n) = PLOTCGS(1, 1, n)/FuseLength(n);
    end
    
    if LandingGearZCG(n) ~= 0
      %PLOTCGS(6, 3, n) = PLOTCGS(1, 3, n); % z-axis
      PLOTCGS(6, 3, n)=LandingGearZCG(n);    
      LandingGearZCG(n) = PLOTCGS(6, 3, n)/FuseVerticalDiameterAft(n);
    else
       PLOTCGS(6, 3, n) = PLOTCGS(1, 3, n);
       LandingGearZCG(n) = PLOTCGS(6, 3, n)/FuseVerticalDiameterAft(n);% z-axis
    end
    
    % ***************** Assegnazione valori Baricentri personalizzati *********
      if (CoGsMOD == 159)
      LandingGearXCG(n)=cogsImp(1,31); % x
      LandingGearYCG(n)=cogsImp(1,32); % y
      LandingGearZCG(n)=cogsImp(1,33); % z
      PLOTCGS(6, 1, n) = LandingGearXCG(n)*FuseLength(n);% cogsImp(1,1)
      PLOTCGS(6, 2, n) = LandingGearYCG(n)*FuseLength(n);% cogsImp(1,2)
      PLOTCGS(6, 3, n) = LandingGearZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
      end
    % *************************************************************************
else
    PLOTCGS(6, 1, n) = 0; % x-axis
    LandingGearXCG(n) = PLOTCGS(6, 1, n)/FuseLength(n);
    PLOTCGS(6, 3, n) = 0; % z-axis
    LandingGearZCG(n) = PLOTCGS(6, 3, n)/FuseVerticalDiameterAft(n);        
end

% powerplant longitudinal and vertical cg (Torenbeek, SAWE and geom. handbook)

% ***** Aggiunto *********** CG powerplant set default **************************
% ***** For Bug on/off Engine2 in CoGs ******************************************
EnginesXCG(1,n) = 0;% x-axis
EnginesYCG(1,n) = 0;% y-axis
EnginesZCG(1,n) = 0;% z-axis
EnginesXCG(2,n) = 0;% x-axis
EnginesYCG(2,n) = 0;% y-axis
EnginesZCG(2,n) = 0;% z-axis
% *******************************************************************************
if EnginesNumber(1,n)>0
    for i = 1:PN
        
        %%%%SR    if EnginesXCG(i, n) < 0.0001
        
        EnginesXCG(i, n) = ( NacelleXLoc(i, n) + ...
            0.4*NacelleLength(i, n) )/FuseLength(n);% x-axis
        
        %%%%SR    end
        
        %%%%SR    if EnginesYCG(i, n) <= 0.
        
        % Improve this part!
        EnginesYCG(i, n) = NacelleYLoc(i, n); % y-axis
        
        %%%%SR    end
        
        %%%%SR    if EnginesZCG(i, n) < 0.0001
        
        EnginesZCG(i, n) = NacelleZLoc(i, n)/FuseVerticalDiameterAft(n);% z-axis
        
        %%%%SR    end
        
    end
end

% Output
PLOTCGS(7, 1, n) = EnginesXCG(1,n)*FuseLength(n);% x-axis
PLOTCGS(7, 2, n) = EnginesYCG(1,n);% y-axis
PLOTCGS(7, 3, n) = EnginesZCG(1,n)*FuseVerticalDiameterAft(n);% z-axis
PLOTCGS(8, 1, n) = EnginesXCG(2,n)*FuseLength(n);% x-axis
PLOTCGS(8, 2, n) = EnginesYCG(2,n);% y-axis
PLOTCGS(8, 3, n) = EnginesZCG(2,n)*FuseVerticalDiameterAft(n);% z-axis


% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
EnginesXCG(1, n)=cogsImp(1,16); % x
EnginesYCG(1, n)=cogsImp(1,17); % y
EnginesZCG(1, n)=cogsImp(1,18); % z
PLOTCGS(7, 1, n) = EnginesXCG(1, n)*FuseLength(n);% cogsImp(1,1)
%PLOTCGS(7, 2, n) = EnginesYCG(1, n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(7, 2, n) = EnginesYCG(1, n)/WingSpan(n)/2;
PLOTCGS(7, 3, n) = EnginesZCG(1, n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)


EnginesXCG(2, n)=cogsImp(1,19); % x
EnginesYCG(2, n)=cogsImp(1,20); % y
EnginesZCG(2, n)=cogsImp(1,21); % z
PLOTCGS(8, 1, n) = EnginesXCG(2, n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(8, 2, n) = EnginesYCG(2, n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(8, 3, n) = EnginesZCG(2, n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************


%==========================================================================
% Commented in the code
%
%FSYSBAX
%FCTLBAX
%APUSBAX
%INSTBAX
%AVIOBAX
%HYPNBAX
%ELECBAX
%ECSGBAX
%==========================================================================

% systems longitudinal and vertical cg (SAWE - assumed corresponding to fuse)

%%%%SR if TotalSystemsXCG(n) < 0.0001

    TotalSystemsXCG(n) = FuseXCG(n);% x-axis

%%%%SR end

%%%%SR if TotalSystemsZCG(n) < 0.0001

    TotalSystemsZCG(n) = 0.9999*FuseZCG(n);% z-axis % Inserito parametro 0.9999 per visualizzazione in CoGs

%%%%SR end

% Output
PLOTCGS(17, 1, n) = TotalSystemsXCG(n)*FuseLength(n);% x-axis
PLOTCGS(17, 3, n) = TotalSystemsZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
if (CoGsMOD == 159)
TotalSystemsXCG(n)=cogsImp(1,37); % x
TotalSystemsYCG(n)=cogsImp(1,38); % y
TotalSystemsZCG(n)=cogsImp(1,39); % z
PLOTCGS(17, 1, n) = TotalSystemsXCG(n)*FuseLength(n);% cogsImp(1,1)
PLOTCGS(17, 2, n) = TotalSystemsYCG(n)*FuseLength(n);% cogsImp(1,2)
PLOTCGS(17, 3, n) = TotalSystemsZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
end
% *************************************************************************


% wing integral tanks horizontal and vertical cg

%%%%SR if FuelWingXCG(n) < 0.0001

    FuelWingXCG(n) = FinalWingFuelXCG; % x-axis

%%%%SR end

%%%%SR if FuelWingYCG(n) < 0.

    FuelWingYCG(n) = FinalWingFuelYCG; % y-axis

%%%%SR end

%%%%SR if FuelWingZCG(n) < 0.0001

    FuelWingZCG(n) = FinalWingFuelZCG; % z-axis

%%%%SR end

% Output
PLOTCGS(18, 1, n) = FuelWingXCG(n)*FuseLength(n);% x-axis
PLOTCGS(18, 2, n) = FuelWingYCG(n)*FuseLength(n);% y-axis
PLOTCGS(18, 3, n) = FuelWingZCG(n)*FuseVerticalDiameterAft(n);% z-axis


% centre fuel tank(s) horizontal and vertical cg (geometric handbook)

%%%%SR if FuelCentralXCG(n) < 0.0001

    FuelCentralXCG(n) = FairingXCG;% x-axis

%%%%SR end

%%%%SR if FuelCentralZCG(n) < 0.0001

    FuelCentralZCG(n) = FairingZCG;% z-axis

%%%%SR end

% Output
PLOTCGS(19, 1, n) = FuelCentralXCG(n)*FuseLength(n);% x-axis
PLOTCGS(19, 3, n) = FuelCentralZCG(n)*FuseVerticalDiameterAft(n);% z-axis


% auxiliary tank horizontal and vertical cg (geometric handbook)

%%%%SR if FuelAuxiliaryXCG(n) < 0.0001

    FuelAuxiliaryXCG(n) = AuxiliaryXCG;

%%%%SR end

%%%%SR if FuelAuxiliaryZCG(n) < 0.0001

    FuelAuxiliaryZCG(n) = AuxiliaryZCG;

%%%%SR end

% Output
PLOTCGS(20, 1, n) = FuelAuxiliaryXCG(n)*FuseLength(n);% x-axis
PLOTCGS(20, 3, n) = FuelAuxiliaryZCG(n)*FuseVerticalDiameterAft(n);% z-axis


% interiors horizontal and vertical cg (geometric handbook)
%%%%SR if InteriorsXCG(n) < 0.0001

    InteriorsXCG(n) = ( NoseLength(n) + ...
        CabinLength(n)/2 )/FuseLength(n);% x axis

%%%%SR end

%%%%SR if InteriorsZCG(n) < 0.0001

    InteriorsZCG(n) = ( CabinMaxHeight(n)*0.4-0.5*((CabinMaxWidth(n)^2) - ...
        CabinFloorWidth(n)^2)^0.5 )/FuseVerticalDiameterAft(n);% z axis

%%%%SR end

% Output
PLOTCGS(21, 1, n) = InteriorsXCG(n)*FuseLength(n);% x-axis
PLOTCGS(21, 3, n) = InteriorsZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
  if (CoGsMOD == 159)
    InteriorsXCG(n)=cogsImp(1,43); % x
    InteriorsYCG(n)=cogsImp(1,44); % y
    InteriorsZCG(n)=cogsImp(1,45); % z
    PLOTCGS(21, 1, n) = InteriorsXCG(n)*FuseLength(n);% cogsImp(1,1)
    PLOTCGS(21, 2, n) = InteriorsYCG(n)*FuseLength(n);% cogsImp(1,2)
    PLOTCGS(21, 3, n) = InteriorsZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
  end
% *************************************************************************


% pilots horizontal and vertical cg (airframer data)

%%%%SR if PilotsXCG(n) < 0.0001
    
    % Modifica per Cabina Mobile
    PilotsXCG(n) = (aircraft.cabin.Floor_apex_per_fuselgt + 0.4)/FuseLength(n);
    

%%%%SR end

%%%%SR if PilotsZCG(n) < 0.0001

    PilotsZCG(n) = ( RefWingChordOrigin(n)*WingThickness(1, n)/2 + ...
        0.65 )/FuseVerticalDiameterAft(n) - 0.5;

%%%%SR end

% Output
PLOTCGS(22, 1, n) = PilotsXCG(n)*FuseLength(n);% x-axis
PLOTCGS(22, 3, n) = PilotsZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
  if (CoGsMOD == 159)
    PilotsXCG(n)=cogsImp(1,40); % x
    PilotsYCG(n)=cogsImp(1,41); % y
    PilotsZCG(n)=cogsImp(1,42); % z
    PLOTCGS(22, 1, n) = PilotsXCG(n)*FuseLength(n);% cogsImp(1,1)
    PLOTCGS(22, 2, n) = PilotsYCG(n)*FuseLength(n);% cogsImp(1,2)
    PLOTCGS(22, 3, n) = PilotsZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
  end
% *************************************************************************


% Auxiliary landing gear: if not specified place the auxiliary landing gear
% CoG on the pilots' one
%

if auxlandinggear_flag
   
  if ~ALandingGearXCG(n)
    %PLOTCGS(9, 1, n) = ALandingGearXCG(n)*FuseLength(n);% x-axis
    %ALandingGearXCG(n) = PLOTCGS(9, 1, n)/FuseLength(n);% x-axis
    PLOTCGS(9, 1, n) = ALandingGearXCG(n)*FuseLength(n);% x-axis
    ALandingGearXCG(n) = PLOTCGS(9, 1, n)/FuseLength(n);% x-axis
  else
    %PLOTCGS(9, 1, n) = PLOTCGS(22, 1, n); % Zona Piloti?
    PLOTCGS(9, 1, n) = ALandingGearXCG(n)*FuseLength(n);% x-axis   
  end
  
  if ~ALandingGearZCG(n)
    PLOTCGS(9, 3, n) = ALandingGearZCG(n)*FuseVerticalDiameterAft(n);% z-axis
    ALandingGearZCG(n) = PLOTCGS(9, 3, n)/FuseVerticalDiameterAft(n);
  else
    %PLOTCGS(9, 3, n) = PLOTCGS(22, 3, n); % Zona Piloti ?
    PLOTCGS(9, 3, n) = ALandingGearZCG(n)*FuseVerticalDiameterAft(n);% z-axis
  end
  
      % ***************** Assegnazione valori Baricentri personalizzati *********
      if (CoGsMOD == 159)
      ALandingGearXCG(n)=cogsImp(1,34); % x
      ALandingGearYCG(n)=cogsImp(1,35); % y
      ALandingGearZCG(n)=cogsImp(1,36); % z
      PLOTCGS(9, 1, n) = ALandingGearXCG(n)*FuseLength(n);% cogsImp(1,1)
      PLOTCGS(9, 2, n) = ALandingGearYCG(n)*FuseLength(n);% cogsImp(1,2)
      PLOTCGS(9, 3, n) = ALandingGearZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
      end
    % *************************************************************************
  
else
    PLOTCGS(9, 1, n) = 0; % x-axis
    ALandingGearXCG(n) = PLOTCGS(9, 1, n)/FuseLength(n);
    PLOTCGS(9, 3, n) = 0; % z-axis
    ALandingGearZCG(n) = PLOTCGS(9, 3, n)/FuseVerticalDiameterAft(n);
end

% Commented in the code, line missing...
%FATTBAX(n)=

% passengers/payload horizontal and vertical centre of gravity (airframer data)

%%%%SR if PassengersXCG(n) < 0.0001
    
    % ***** ORIGINALE *********************************
    PassengersXCG(n) = ( NoseLength(n) + ...
        CabinLength(n)/2 )/FuseLength(n);% x axis
    %  !!!!! Viene sovrascritto tra qualche riga !!!!! 
    % *************************************************
    % ******* Modifica per Cabina mobile ******
    SeatsPitch  = aircraft.cabin.Passengers_seats_pitch;
    if (SeatsAbreast==0)
       nrow = 0;
    else
       nrow   = ceil(Passengers/SeatsAbreast);  
    end
    
    if nrow == 0
    lpass  = 0;
    else
    lpass  = nrow*0.3 + (nrow-1)*SeatsPitch;
    end
    
    ncrabr = 4; % Seats Abreast per crew and attendants
    CockpitCrewNumber  = aircraft.cabin.Flight_crew_number;
    AttendantsNumber  = aircraft.cabin.Cabin_attendant_number;
    crattpitch = 0.7;
%     nrowcratt = round(CrewNumber/ncrabr) + round(AttendantsNumber/ncrabr);
    nrowcratt = ceil(CockpitCrewNumber/ncrabr) + ceil(AttendantsNumber/ncrabr);
    lcratt = 0.8 + nrowcratt*0.3 + (nrowcratt-1)*crattpitch; % 0.8 per estremi
    
    % Dim Sedili 0.4 + 0.3 >>> Dist 0.3
       
    PassengersXCG(n) = ( aircraft.cabin.Floor_apex_per_fuselgt + ...
       lcratt + lpass/2 )/FuseLength(n);% x axis
     
   % *******************************************************
   
%%%%SR end

%%%%SR if PassengersZCG(n) < 0.0001

    PassengersZCG(n) = PilotsZCG(n);% z axis

%%%%SR end

% Output
PLOTCGS(24, 1, n) = PassengersXCG(n)*FuseLength(n);% x-axis
PLOTCGS(24, 3, n) = PassengersZCG(n)*FuseVerticalDiameterAft(n);% z-axis

      
% ***************** Assegnazione valori Baricentri personalizzati *********
  if (CoGsMOD == 159)
     PassengersXCG(n)=cogsImp(1,46); % x
     PassengersYCG(n)=cogsImp(1,47); % y
     PassengersZCG(n)=cogsImp(1,48); % z
     PLOTCGS(24, 1, n) = PassengersXCG(n)*FuseLength(n);% cogsImp(1,1)
     PLOTCGS(24, 2, n) = PassengersYCG(n)*FuseLength(n);% cogsImp(1,2)
     PLOTCGS(24, 3, n) = PassengersZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
  end
% *************************************************************************



% Crew horizontal and vertical centre of gravity (airframer data)
PLOTCGS(23, 1, n) = PassengersXCG(n)*FuseLength(n);% x-axis
PLOTCGS(23, 3, n) = PassengersZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% baggage horizontal and vertical centre of gravity (geometric handbook)

%%%%SR if BaggageXCG(n) < 0.0001

    BaggageXCG(n) = ( BaggageApex(n)*FuseLength(n) + ...
        BaggageLength(n)/2 )/FuseLength(n);% x-axis

%%%%SR end

%%%%SR if BaggageZCG(n) < 0.0001

    BaggageZCG(n) = -( 0.6*CabinMaxHeight(n) + 0.06 - ...
        FuseVerticalDiameterAft(n)/2 )/FuseVerticalDiameterAft(n);% z-axis

%%%%SR end

% % Output
PLOTCGS(25, 1, n) = BaggageXCG(n)*FuseLength(n);% x-axis
PLOTCGS(25, 3, n) = BaggageZCG(n)*FuseVerticalDiameterAft(n);% z-axis

% ***************** Assegnazione valori Baricentri personalizzati *********
  if (CoGsMOD == 159)
    BaggageXCG(n)=cogsImp(1,49); % x
    BaggageYCG(n)=cogsImp(1,50); % y
    BaggageZCG(n)=cogsImp(1,51); % z
    PLOTCGS(25, 1, n) = BaggageXCG(n)*FuseLength(n);% cogsImp(1,1)
    PLOTCGS(25, 2, n) = BaggageYCG(n)*FuseLength(n);% cogsImp(1,2)
    PLOTCGS(25, 3, n) = BaggageZCG(n)*FuseVerticalDiameterAft(n);% cogsImp(1,3)
  end
% *************************************************************************
% size(PLOTCGS);          % ****** Controllo
% PLOTCGS;             % ****** Controllo