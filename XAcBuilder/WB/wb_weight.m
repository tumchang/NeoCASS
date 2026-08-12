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
%   DESCRIPTION:  Execute mass estimation
%
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
% ********************************************
  %global FuelforWingCoGACB; 
  %global FuelforCenWingCoGACB; 
  %global FuelforAuxWingCoGACB;
  %load('y:\MatStruct.mat','ac')
  %save('y:\MatStruct.mat','ac')
  % *********** Read User Input Mass CoGs Flag *********
  fileflag=which('wb_flag_user_mass.txt');
  fid = fopen(fileflag);
  %tlineflag = fgetl(fileID)
  tlineflag = fgetl(fid);
  fclose(fid);
  massUserImp=zeros(1,23);
  if (strcmp(tlineflag,'159')==1)
      disp('OK - Lettura file con masse componenti imposte')
       CoGsMOD=159;
       fid = fopen(which('wb_file_user_dep.txt'));
       tline = fgetl(fid);
       lineUserMass=1; % Indice per lettura riga file
       while ischar(tline)
          %disp(tline)
          massUserImp(1,lineUserMass)=str2double(tline);
          tline = fgetl(fid);
          lineUserMass=lineUserMass+1;
      end
      fclose(fid);
      %massUserImp      
  else
      disp('NO Masse imposte')
      CoGsMOD=160;
  end  
  % *****************************************************
  
  
% ********************************************

if YearAdvancement(n) < 0.0001

    YearAdvancement(n) = 1990; % set to default value

end

% Advanced technology multiplier (AdvancedTechnologyMultiplier)
AdvancedTechnologyMultiplier = 0.9985^(1.016 * (YearAdvancement(n) - 1975));

% VMO speed for bird strike
vmo = VMOkn(n) * KTAS2MS;

% Dive Mach number at sea level standard
md = VDkn(n) * KTAS2MS / 340.3;

% Vehicular lift-curve slope estimate based on Helmbold equation and Prandtl-Glauert compressibility correction
CLaA1 = 5.04 * RefWingAR(n) / (5.04/pi+ (((RefWingAR(n)/cos(deg2rad * RefWingHCSweep(n)))^2)+...
    ((5.04/pi)^2) - (RefWingAR(n) * qxdktms(qxdctks(VMOkn(n), 200,0),200,0)^2))^0.5);

% if isnan( MTOW(n) ) || ~MTOW(n)

    % Initial iteration starting point (A380/Antonov An-225 weight, state
    % of art maximum weight for an airplane. This should avoid "complex"
    % weights in the iteration process.
    MTOW(n) = 600000.0;         % assumed initial iteration result

% end

%--------------------------------------------------------------------------
% The weights estimation is tiered into two modes of computation:
% (1) closed form prediction and
% (2) MTOW transcendental prediction
%--------------------------------------------------------------------------
% The closed form mode.
%
%
% compute delta P for cabin pressurisation adjustment
if (TargetOperatingCeiling(n) < 0.0001 && EnginesType(1,n) > 0)

    % default turboprop to 31000 ft service ceiling
    TargetOperatingCeiling(n) = 310;

elseif (TargetOperatingCeiling(n) < 0.0001 && EnginesType(1,n) < 0.0001)

    % default turbofan to 41000 ft service ceiling
    TargetOperatingCeiling(n) = 410;

end

if (CabinMaxAltitude(n)<0.0001 && DesignClassification(n)<2)

    % default cabin pressure altitude
    CabinMaxAltitude(n) = 8000;

elseif (CabinMaxAltitude(n)<0.0001 && DesignClassification(n)==2)

    % default cabin pressure altitude for small bizjets
    CabinMaxAltitude(n) = 7000;

elseif (CabinMaxAltitude(n)<0.0001 && DesignClassification(n)>2)

    % default cabin pressure altitude for large bizjets
    CabinMaxAltitude(n) = 6000;
end

% initial guess for maximum altitude
mcbalt = TargetOperatingCeiling(n);

% quantify the pressure differential
CabinPressureDifferentialPSI(n) = (qxdthet(CabinMaxAltitude(n) / 100,0)*qxdsigm(CabinMaxAltitude(n)/100,0) -...
    qxdthet(TargetOperatingCeiling(n),0)*qxdsigm(TargetOperatingCeiling(n),0)) * SEA_LEVEL_P / PSI2KPA;
CabinPressureDifferentialKPa = CabinPressureDifferentialPSI(n) * PSI2KPA;
%--------------------------------------------------------------------------
% Systems weight estimation.

TotalSystemsWeight(n) = FuelSystemWeight(n) + FlightControlsWeight(n) + APUWeight(n) +...
    InstrumentsWeight(n) + AvionicWeight(n) + HydraulicPneumaticWeight(n) +...
    ElectricalWeight(n) + ECSWeight(n) + FurnishingsWeight(n) +...
    MiscellaneousWeight(n);

% equivalent internal cabin diameter EquivalentCabinDiameter
EquivalentCabinDiameter = (2 * CabinMaxHeight(n) + CabinMaxWidth(n))/3;

if PassengerWeightCoeff(n) < 0.0001 && Passengers(n)~=0

    % pax coefficient for commercial transport
    PaxCoeffCommercial = 55.168 + 10.344 * SeatsAbreast(n) + 13.592 * qxheavy(Passengers(n), 181,1) +...
        2.616 * qxheavy(Passengers(n),181,1)*SeatsAbreast(n) - 3.9865 * Passengers(n)^0.3494;

    % pax coefficient for business jets
    PaxCoeffBusiness = 15.561+38.27 * CabinVolume(n)/Passengers(n) + 4297.1*EquivalentCabinDiameter/Passengers(n)*(1-4.7923/CabinLength(n));

    % **** Mod 2017-05-18 ***
    if PaxCoeffBusiness == Inf
        PaxCoeffBusiness=PaxCoeffCommercial;
    end
    % ***********************
    
    % final value
    PassengerWeightCoeff(n) = PaxCoeffCommercial + qxheavy(DesignClassification(n),2,1) * (PaxCoeffBusiness - PaxCoeffCommercial);
    
else
    
    PassengerWeightCoeff(n) = 88; %Survey on standard weights of passengers and baggage, NEA for EASA

end

if TotalSystemsWeight(n)<0.0001

    % *** Mod 2017-05-19
      if Passengers(n)==0
    TotalSystemsWeight(n) = 0.6 * AdvancedTechnologyMultiplier * PassengerWeightCoeff(n) ;
      else
    % ***      
  
    TotalSystemsWeight(n) = 0.6 * AdvancedTechnologyMultiplier * PassengerWeightCoeff(n) * Passengers(n); % otherwise Scott-Nguyen
      end
end

% LR 18/09/08 added aux landing gear weight
%TotalSystemsWeight(n) = TotalSystemsWeight(n) + ALandingGearWeight(n); % ***** Mod. 2016-07-03: Disattivata
ALandingGearWeight(n)=0;
% Save auxiliary landing gear
 if CoGsMOD==159
     ALandingGearWeight(n)=massUserImp(1,12);
 end

PLOTCGS(9, 4, n) = ALandingGearWeight(n);


% ****** TEST INTERIOR *****************
% if CoGsMOD==159
%     MYINTEWEI(n)=massUserImp(1,15);
% end

% PLOTCGS(21, 4, n) = MYINTEWEI(n);
% **************************************





%--------------------------------------------------------------------------
% Paint weight
% LR 17/02/2012 Paint computation moved into a seprated function
% PaintWeight(n) = 0.12 * TotalWettedArea(n);
PaintWeight(n) = paint_weight(TotalWettedArea(n));
if isnan(PaintWeight(n))
    PaintWeight(n) = 0;
end

% Completions weight estimation.
% Final completions includes paint and contingency. This is based on Scott-Nguyen

if CompletionsWeight(n) < 0.0001

    CompletionsWeight(n) = 0.4 * PassengerWeightCoeff(n) * Passengers(n) + PaintWeight(n); % + GreenManEmptyWeight(n) * contwei(n)/100; GreenManEmpyWeight has not been calculated yet. It took the value from the previous aircraft...

end

%--------------------------------------------------------------------------
% Payload weight estimation
% The suggested combined weight is 99.7 kg, however, need to recognise that
% typical business jet assumption is 90.7 kg for PAX and baggage.

if (WeightPerPassenger(n) < 0.0001)

    WeightPerPassenger(n) = 90.719; % assume 200 lb per PAX

end

if (IncrementPerPassenger(n) < 0.0001)

    IncrementPerPassenger(n) = 9.07; % assume 20 lb as incremental

end

% note that one passenger person is defined to be at least 88.5 kg


%--------------------------------------------------------------------------
% UPDATE WEIGHT MODULE PARAMS
% PLOTCGS(24,4,n) = Passengers(n) * 88.5; % store value for cg analysis
PLOTCGS(24,4,n) = Passengers(n) * WeightPerPassenger(n); % store value for cg analysis
PassengersWeight(n) = Passengers(n) * WeightPerPassenger(n); % maximum passenger + baggage weight
IncrementalPAXWeight(n) = Passengers(n) * IncrementPerPassenger(n); % incremental weight per PAX
PLOTCGS(25,4,n) = IncrementalPAXWeight(n) + PassengersWeight(n) - PLOTCGS(24,4,n);% value for cg analysis

 if CoGsMOD==159
    PassengersWeight(n) = massUserImp(1,16);
    IncrementalPAXWeight(n) = massUserImp(1,17);
    PLOTCGS(24,4,n) = PassengersWeight(n); %
    PLOTCGS(25,4,n) = IncrementalPAXWeight(n); % value for cg analysis 
 end

MaxPayloadWeight(n) = PassengersWeight(n) + IncrementalPAXWeight(n); % combined maximum payload
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% Fuel weight estimation using Isikveren's method. Scope is given to predict:
% (1) fuel in the wings
% (2) fuel in the centre-tank
% (3) fuel in the auxiliary fuselage tank

FuelWeight(n) = FinalWingFuelWeight(n) + CentralTankWeight(n) + FuselageFuelWeight(n); % maximum fuel weight

%
PLOTCGS(18,4,n) = FinalWingFuelWeight(n);% store value for cg analysis
PLOTCGS(19,4,n) = CentralTankWeight(n);% store value for cg analysis
PLOTCGS(20,4,n) = FuselageFuelWeight(n);% store value for cg analysis

% if (MaxFuelDecrement(n)<0.0001 && DesignClassification(n)<2)
% 
%     MaxFuelDecrement(n) = FuelWeight(n) - 2/3*MaxPayloadWeight(n);% estimate max fuel decrement if null
% 
% elseif (MaxFuelDecrement(n)<0.0001 && DesignClassification(n)==2)
% 
%     % estimate max fuel decrement if null for small business jet
%     MaxFuelDecrement(n) = FuelWeight(n) - MaxPayloadWeight(n) + 362.9;
% 
% elseif (MaxFuelDecrement(n)<0.0001 && DesignClassification(n)>2)
% 
%     % estimate max fuel decrement if null for small business jet
%     MaxFuelDecrement(n) = FuelWeight(n) - MaxPayloadWeight(n) + 725.8;
% 
% end

if (MaxFuelDecrement(n)<0.0001)

    MaxFuelDecrement(n)=0.0;% cannot increment fuel from max fuel

end

FuelAtMTOWMaxPayload(n) = FuelWeight(n) - MaxFuelDecrement(n) - RampIncrement(n); % fuel weight for MZFW to MTOW

if FuelAtMTOWMaxPayload(n) < 0
   
    FuelAtMTOWMaxPayload(n) = 0;

end

%--------------------------------------------------------------------------
% Crew weight estimation. Typical weights from SAWE statistics.
if (CrewNumber(n)>0.0001 && AttendantWeight(n)<0.0001)

    AttendantWeight(n) = 75.0;% canned fa weight

end

CrewAndCarryonWeight(n) = AttendantWeight(n) * CrewNumber(n);% compute the fa weight
% ***** Mod. 2016-07-03: Disattivata
%PLOTCGS(23,4,n) = CrewAndCarryonWeight(n);% store value for cg analysis *** Default example 300=75*4

% ** Mod. 2016-07-03: For NeoCASS COG Matrix - XLS Load Data from AcBuilder
if CoGsMOD==159
%     if ~exist(ac.weight_balance.COG_AddOns.Crew)
%         % Inizialize
%          ac.weight_balance.COG_AddOns.Crew = CrewAndCarryonWeight(n);
%     end
        
PLOTCGS(23,4,n) = aircraft.weight_balance.COG_AddOns.Crew;
else
PLOTCGS(23,4,n) = CrewAndCarryonWeight(n);% store value for cg analysis *** Default example 300=75*4    
end
% *********************************************************************

if FlightCrewWeight(n)<0.0001

    FlightCrewWeight(n) = 85.0;% canned fc weight

end

FlightCrewTotalWeight(n) = FlightCrewWeight(n) * FlightCrewNumber(n);% compute the fc weight

 if CoGsMOD==159
 FlightCrewTotalWeight(n)=massUserImp(1,14);
 end

PLOTCGS(22,4,n) = FlightCrewTotalWeight(n);% store value for cg analysis *** Default Example 175=85*2

TotalCrewWeight(n) = CrewAndCarryonWeight(n) + FlightCrewTotalWeight(n);% total crew weight

%--------------------------------------------------------------------------
% Operating items weight estimation.
if OperatingItemsWeight(n)<0.0001

    %FlightManualWeight(n) = 18.0; % flight manual weight (40 lb)
    %Flight manual removed
    
    ConsumablesWeight(n) = 5.4 * Passengers(n); % galley consumables/potable water and toilet chem
    %     OperatingItemsWeight(n) = FlightManualWeight(n) + ConsumablesWeight(n) + UnusableFuel(n); % total operating items
    OperatingItemsWeight(n) = ConsumablesWeight(n) + UnusableFuel(n);
    %Operating Items Weight added to interior weight
end

PLOTCGS(21,4,n) = CompletionsWeight(n) + OperatingItemsWeight(n);

if CoGsMOD==159
    PLOTCGS(21,4,n) =massUserImp(1,15);
end

PLOTCGS(21,4,n) = CompletionsWeight(n); % store value for cg analysis
    
% LR 16/10/2012 avoid counting aux landing gear two times
 if CoGsMOD==159
 TotalSystemsWeight(n)= massUserImp(1,13);
 end

%PLOTCGS(17,4,n) = TotalSystemsWeight(n) - ALandingGearWeight(n) + WeightTolerance(n) + OperatingItemsWeight(n); % *** Rev. 2016-07-03 Mod System per NeoCASS. % store value for cg analysis
PLOTCGS(17,4,n) = TotalSystemsWeight(n);

% **************** Punto di Controllo --- Si può Eliminare ***********
% ALandingGearWeight(n);
% PLOTCGS(17,4,n);
% TotalSystemsWeight(n);
%ALandingGearWeight(n)
% WeightTolerance(n);
%OperatingItemsWeight(n)
% *********************************************************************
%--------------------------------------------------------------------------
% The transcendental mode. Main convergence algorithm for MTOW estimation.
% Uses simple iteration.
%

mtow1 = ReferenceWingArea(n) / ReferenceWingArea2(n);
if aircraft.Wing2.present
    mtow2 = ReferenceWing2Area(n) / ReferenceWingArea2(n);
end
mtowi = 1.0 + MTOW(n);
MZFW(n) = mtowi;% set off the iterations

% Wing no.1 weight prediction
DesignFactor = 1.2051 + 0.0824 * WingPlacement(n) +...
    0.0241 * SpoilerEffectivity(n)/100 - 0.01755 * qxheavy(UndercarriageLayout(n),1,1);% design factor for configuration
ThicknessFactor = 16.5*sin(2*pi * RefWingThickness(n));% wing thickness factor

%--------------------------------------------------------------------------
% Fuselage weight prediction
% equivalent diameter if ellipse fuse diameter
EquivalentDiameter = (2*FuseVerticalDiameterAft(n) + FuseHorizontalDiameterAft(n))/3;
PressureCorrection = 1.066 * exp(2.95877e-3 * CabinPressureDifferentialKPa);% correction for pressure differential

% correction factor for doors, windows and freight floors
% correction for landing gear, dependent upon landing gear location and wing
% placement
LandingGearCorrection = 1.1 + 0.033 * qxheavy(WingPlacement(1,n),0.25,1)*(1 - qxheavy(UndercarriageLayout(n),1,1));
% correction for powerplant and landing gear placement
if EnginesNumber(1,n)>0
    EnginesCorrection = qxheavy(EnginesLayout(1,n),3,1) * 6.6e-4 * ((NoseLength(n) +...
        CabinLength(n) - 0.4 * FuseLength(n) - 0.65 * RefWingChordOrigin(n))^2) / FuseWingPosition(n) - qxheavy(UndercarriageLayout(n),1,1) * 0.00331;
else
    EnginesCorrection = 0;
end

%--------------------------------------------------------------------------
% Landing gear weight prediction
if EnginesNumber(1,n)>0
    LGWeightPrediction = 587 - 153 * (qxheavy(EnginesLayout(1,n),3,1) +...
        qxheavy(WingPlacement(1,n),0.25,1) - qxheavy(WingPlacement(1,n),0.25,1) * qxheavy(UndercarriageLayout(n),1,1));
else
    LGWeightPrediction = 587 - 153 * (qxheavy(WingPlacement(1,n),0.25,1) -...
         qxheavy(WingPlacement(1,n),0.25,1) * qxheavy(UndercarriageLayout(n),1,1));
end
%--------------------------------------------------------------------------
% Powerplant weight prediction
PylonWeight(n) = 0.0;
GearboxWeight(n) = 0.0;
NacelleWeight(n) = 0.0;

if EnginesNumber(1,n)>0.0
    
    if EnginesNumber(2,n)>0.0
        
        PN=2; % prediction for primary and secondary powerplants
        
    else
        
        PN=1; % prediction for primary powerplants only
        
    end
    
    for i = 1:PN
        
        % predict the complete primary and secondary powerplant weight
        [DryEngineWeight, NacelleWeight2, PylonWeight2, PropellerWeight] = ewcomp(MaxThrust, ReverserEffectiveness, EnginesLayout, EnginesType, i, n);
        % prediction for total pylon weight
        PylonWeight(n) = PylonWeight(n) + EnginesNumber(i,n) * (PylonWeight2 + PropellerWeight);
        % prediction for total powerplant weight
        GearboxWeight(n) = GearboxWeight(n) + EnginesNumber(i,n) * DryEngineWeight;
        % prediction for total nacelle weight
        NacelleWeight(n) = NacelleWeight(n) + AdvancedTechnologyMultiplier * EnginesNumber(i,n) * NacelleWeight2;
        
        % sum the normalised primary powerplant installation weight
        if i<2
            %disp('Punto motore 1')
            PowerplantWeight = (PylonWeight(n) + GearboxWeight(n) + NacelleWeight(n))/2;
            
            
            
            PLOTCGS(7,4,n) = 2 * PowerplantWeight; % store value for cg analysis
            
        else
            %disp('Punto motore 2')
            PLOTCGS(8,4,n) = PylonWeight(n) + GearboxWeight(n) + NacelleWeight(n) - 2*PowerplantWeight; % store value for cg analysis - S.R.(09/01/11) added 2*
            
        end
        
    end
else
    PLOTCGS(7,4,n) = 0;
    PLOTCGS(8,4,n) = 0;
end

% LR 15/03/10 check on main landing gear presence
if LandingGearWeight(n) == 0.
    lndgr_flag = true;
else
    lndgr_flag = false;
    PLOTCGS(6, 4, n) = LandingGearWeight(n);    % store value for cg analysis
end

%--------------------------------------------------------------------------
% Start iterative weight refinement

% set an iteration counter
count = 1;
massforacbuilder=zeros(1,26); 
while abs(MTOW(n) - mtowi) > 0.5

    mtowi = MTOW(n);

    %----------------------------------------------------------------------
    % Identify the critical load case, i.e. manouevre or gust


    mu = 2 * WingSpan(n) * mtow1 * MZFW(n)/(CLaA1 * ReferenceWingArea(n)^2);    % mass parameter
    Kg = 0.88 * mu / (5.3 + mu);    % gust alleviation factor

    % gust load factor at FL 200
    ngust = 1 + Kg * CLaA1 * 1.225 * qxdsigm(200, 0) *...
        15.2 * qxdctks(VMOkn(n), 200, 0) * KTAS2MS * ReferenceWingArea(n)/(2 * g * mtow1 * MZFW(n));

    % predicted ultimate load factor
    nult = 1.5 * (2.5 * qxheavy(2.5, ngust, 1) + ngust * qxheavy(ngust, 2.5, 1));

    %----------------------------------------------------------------------
    % Wing weight estimation. This is based on Linnell method with some
    % modifications made to the coefficients.
    %
    % Here are the coefficients

    alp = 0.0328;
    bet = 1.5;
    del = 1.5;
    zii = 1.1;
    eps = 1.5;
    phi = 0.656;

    % structural stiffness factor
    sstf = 1 + 1.31 * (SEA_LEVEL_D * (vmo^2)/(2*1000*g))^2 * nult^-3;

    % final wing weight prediction
    WingWeight(n) = AdvancedTechnologyMultiplier * alp * DesignFactor * (mtow1 * mtowi * nult *...
        ReferenceWingArea(n) * (RefWingAR(n)^bet)*(zii + WingWeightedTaper(n)/2) * (sstf^del)/(ThicknessFactor * cos(WingQCSweep(n)*deg2rad)^eps))^phi;

    % single out wing no. 1 weight
    wingmas = WingWeight(n);

    if CoGsMOD==159
      WingWeight(n)=massUserImp(1,1);
      wingmas=WingWeight(n);
    end
    
    
    PLOTCGS(1, 4, n) = WingWeight(n);% store value for cg analysis

    %----------------------------------------------------------------------
    % Winglet weight estimation. This is based on a simple wetted area
    % premise. An additional contribution accounts for span load revision.
    

    if wletspn(n)>0.0001

        WingletWeight(n) = 0.5 * WingWeight(n) * (WingletIncrement(n) / RefWingAreaForWB + 0.7 * abs(VortexInducedDragFactor(n)));

    else

        WingletWeight(n) = 0;

    end

    % check if a second wing has been defined
    wi2gmas=0;
    wi2present(1, n) = aircraft.Wing2.present;
    if wi2present(1, n)
%     if wi2gare(n) > 0.0001

        DesignFactor = 1.2051 + 0.0824 * wi2gplc(n) +...
            0.0241 * SpoilerEffectivity(n)/100 - 0.01755 * qxheavy(UndercarriageLayout(n),1,1);    % design factor for configuration
        ThicknessFactor = 16.5 * sin(2 * pi * WI2WTHB(n));   % wing thickness factor

        % structural stiffness factor
        sstf = 1 + 1.31 * SEA_LEVEL_D * (vmo^2)/(2*1000*g) * nult^-3;

        % final wing weight prediction
        % ************** MOD WING2 ************************************
        %WING2WEI(n) = AdvancedTechnologyMultiplier * alp * DesignFactor * (mtow2 * mtowi * nult *...
        %ReferenceWing2Area(n) * (WI2WGAR(n)^bet)*(zii + WI2WTAP(n)/2) * (sstf^del)/(ThicknessFactor * cos(WI2WQSW(n)*deg2rad)^eps))^phi;
        % *************************************************************
        
        % **************** ORIGINALE ****************************
        WingWeight(n) = WingWeight(n) + AdvancedTechnologyMultiplier * alp * DesignFactor * (mtow2*mtowi * nult *...
           ReferenceWing2Area(n) * (WI2WGAR(n)^bet)* (zii+ WI2WTAP(n)/2)*(sstf^del)/(ThicknessFactor*cos(WI2WQSW(n)*deg2rad)^eps))^phi;
        
        wi2gmas = WingWeight(n) - wingmas; % single out wing no. 2 weight
        % *******************************************************
        
        %wi2gmas = WingWeight(n) - wingmas; % single out wing no. 2 weight
        
      % *** Per Massa Ala2 Imposta *** 
      if CoGsMOD==159
       wi2gmas=massUserImp(1,2);
       WingWeight(n)=massUserImp(1,1);
       wingmas=WingWeight(n);      
      end
      % ******************************  

        PLOTCGS(2, 4, n) = wi2gmas;   % store value for cg analysis
    else
        PLOTCGS(2, 4, n) = 0.;
    end

    % Landing gear weight estimation. This is based on Linnell method with some
    % modifications made to the coefficients.
    
    if lndgr_flag       
        LandingGearWeight(n) = AdvancedTechnologyMultiplier * LGWeightPrediction * (mtowi/14000)^1.05;
        
        %ALandingGearWeight(n)=0;% TEST Non verificato ***********
                
    if landinggear_flag == 0
        LandingGearWeight(n)=0; % Carrello assente 
    end 
    
    if CoGsMOD==159 % Con massa imposta
      LandingGearWeight(n)=massUserImp(1,11);
    end      
        
        PLOTCGS(6, 4, n) = LandingGearWeight(n);    % store value for cg analysis
    end
    


if EnginesNumber(1,n)>0    
    % Predict the engine, nacelle and pylon weights. Only two different
    % types of powerplants are permitted for a given layout.
    % The two sets are called primary and secondary.
%
    % S.R.(09/01/11) changed ThrustToWeight(n) in ThrustToWeight(1,n)
    if ThrustToWeight(1,n) > 0

        PylonWeight(n)=0.0;
        GearboxWeight(n)=0.0;
        NacelleWeight(n)=0.0;

        % user has opted for a fixed thrust-to-weight iterative algorithm
        MaxThrust(1, n) = ThrustToWeight(1,n) * mtowi * 9.81/1000 / (EnginesNumber(1,n) + EnginesNumber(2,n));
        MaxThrust(2, n) = MaxThrust(1, n); % even split with all engines

        %%%%%%%%%%%%%% WARNING %%%%%%%%%%%%%%%
        % Here a call to the geotry function is simply replaced
        % The call is commented and the original text of the function is
        % reported inside wb_weight script
        %
        % qgeotry('geom2',n); % call the engine geometric sizing routine
        %

        % ENGINE GEOMETRIC SIZING ROUTINE *********************************

        % Predict the engine and subsequent nacelle diameters.
        % Based on methods developed by Isikveren.

        NacelleLength(1:2,n) = 0.0;% initialise for calculation
        MaxTotalThrust = zeros(2,15);% initialise the by-pass ratio emulation variable

        for i=1:PN

            % length of actual wing chord at engine location

            ChordAtEngine(i, n) = Wing_Chord_At_Span(abs(EngineYLocale(i,n))*WingSpan(n)/2, SpanMatrixPartition, RefWingChordOrigin(n), WingTaper,n);
            OnWing(i, n) = 0;  % initialise variables

            % predict the engine diameter
            EngineDiameter(i, n) = ((2)^-0.5)*(1.73*log(MaxThrust(i,n))-pi)^0.5;

            NacellePitotDiameter(i, n) = EngineDiameter(i, n) + 0.25;% generic pitot nacelle diameter

            if EngineMaxDiameter(i, n) < 0.0001

                % For on-wing installations
                if EnginesLayout(i, n) == 1.0 || EnginesLayout(i, n) == 2.0

                    OnWing(i, n) = 1;% invoke on-wing installation

                end

                % predicted nacelle maximum diameter
                EngineMaxDiameter(i, n) = (4-OnWing(i,n))*(0.0625 + EngineDiameter(i, n)/4);

            else

                EngineDiameter(i, n) = EngineMaxDiameter(i,n) - 0.25;% predicted engine max. diameter

            end

            % the propeller diameter has not been given
            if PropellerDiameter(i, n)<0.0001

                PropellerDiameter(i, n) = (qxheavy(EnginesType(i,n),1,1)*3 +...
                    0.48 * qxheavy(EnginesType(i,n),3,1))*EngineDiameter(i,n);

            end

            if EnginesType(i, n)>0.0001

                NacelleType(i, n) = 1;% automatically choose long duct for props

            end

            % predicted engine length
            EngineLength = (MaxThrust(i, n)^0.9839)/(2*pi*(1.73*log(MaxThrust(i, n))-pi));
            NacellePitotLength(i, n) = 5/3*EngineLength;% generic pitot nacelle length

            if NacelleFineness(i, n) < 0.0001 && EnginesLayout(i, n) > 3

                % predict the nacelle length for S and straight ducts only
                NacelleLength(i, n) = (5+NacelleType(i,n)+0.44*qxheavy(EnginesType(i,n),3,1) +...
                    7/4*qxheavy(EnginesLayout(i,n),4,1))/3*EngineLength + OnWing(i,n)*ChordAtEngine(i,n);

            elseif NacelleFineness(i, n) < 0.0001 && EnginesLayout(i, n) < 4 && EnginesType(i, n) < 0.0001

                NacelleLength(i, n) = NacellePitotLength(i,n);% assume original estimate

            elseif NacelleFineness(i, n) < 0.0001 && EnginesLayout(i, n) < 4 && EnginesType(i, n) > 2

                NacelleLength(i, n) = 1.81*NacellePitotLength(i, n);% assume original estimate

            else

                NacelleLength(i, n) = NacelleFineness(i, n) * EngineMaxDiameter(i, n);% user defined nacelle

            end

            % check to see if a by-pass ratio emulation is required
            if BypassRatio(i, n) < 0.0001

                % predict the by-pass ratio for turbofans sourced from C.
                % Svoboda, Aircraft Design Journal, 3(2000) 17-31

                BypassRatio(i, n) = 3.2 + 0.01*(MaxThrust(i,n)*1000/NEWTON2LB)^0.5;
                MaxTotalThrust(i, n) = MaxThrust(i, n);

                if EnginesType(i, n) > 0.0
                    BypassRatio(i, n) = 3 * BypassRatio(i, n);% equivalent by-pass for props
                end

            else

                if EnginesType(i, n) > 0.0
                    BypassRatio(i, n) = BypassRatio(i, n)/3;% assume fan for modelling purposes
                end

                if BypassRatio(i, n) < 3.43
                    BypassRatio(i, n) = 3.43;% minimum fan by-pass ratio for emulation
                end

                MaxTotalThrust(i, n) = 0.001*NEWTON2LB*(100*(BypassRatio(i,n)-3.2))^2;

                if EnginesType(i, n) > 0.0
                    BypassRatio(i, n) = 3*BypassRatio(i, n);% assume fan for modelling purposes
                end

            end

            NacelleFineness(i,n) = NacelleLength(i,n)/EngineMaxDiameter(i,n);% compute the nac. fineness
        end

        % end of copy and paste *******************************************

        for i = 1:PN

            % predict the complete primary and secondary powerplant weight
            [DryEngineWeight, NacelleWeight2, PylonWeight2, PropellerWeight] = ewcomp(MaxThrust, ReverserEffectiveness, EnginesLayout, EnginesType, i, n);

            % prediction for total pylon weight
            PylonWeight(n) = EnginesNumber(i, n)*(PylonWeight2+PropellerWeight) + PylonWeight(n);

            % prediction for total powerplant weight
            GearboxWeight(n) = EnginesNumber(i, n)*DryEngineWeight + GearboxWeight(n);

            % prediction for total nacelle weight
            NacelleWeight(n) = AdvancedTechnologyMultiplier*EnginesNumber(i, n)*NacelleWeight2 + NacelleWeight(n);

            % sum the normalised primary powerplant installation weight

            if i < 2

                PowerplantWeight = (PylonWeight(n) + GearboxWeight(n) + NacelleWeight(n))/2;
                % store value for cg analysis
                PLOTCGS(7, 4, n) = 2 * PowerplantWeight;
               %disp('Punto motore 7')
               %if CoGsMOD==159 % Con massa imposta
                % PLOTCGS(7, 4, n)=massUserImp(1,6);
               %end 

            else
                %disp('Punto motore 8')
                % store value for cg analysis
                PLOTCGS(8, 4, n) = PylonWeight(n) + GearboxWeight(n) + NacelleWeight(n) - 2*PowerplantWeight; % S.R.(09/01/11) added 2*  

            end

        end

    end
end
    
    if CoGsMOD==159
        PLOTCGS(7,4,n)=massUserImp(1,6);
        PLOTCGS(8,4,n)=massUserImp(1,7);
     end
    %----------------------------------------------------------------------
    % credit given for bending alleviation if TOLS configuration selected

    %     if WingConfiguration(n) > 0.0001 && wi2gcfg(n) > 0.0001
    

    if WingConfiguration(n) ~= 0 && wi2gcfg(n) ~= 0 % 0 = conventional wing

        % wing structural weight effect on bending due to other oblique wing
        wingrel = -0.8 * wi2gmas/mtowi;
        wi2grel = -0.8 * wingmas/mtowi;
        powrrel = -3 * PowerplantWeight/(mtowi*WINWYBR(n)) * EngineYLocale(1,n)^2;

        wrelief = 1 + wingrel + powrrel;
        wr2lief = 1 + wi2grel + powrrel;

        WingWeight(n) = wrelief * wingmas + wr2lief * wi2gmas;
        PLOTCGS(1, 4, n) = wrelief * wingmas;% store value for cg analysis
        PLOTCGS(2, 4, n) = wr2lief * wi2gmas;% store value for cg analysis

    end

    %----------------------------------------------------------------------
    % Fuselage weight estimation. This is based on Linnell method with some
    % modifications made to the coefficients.
    % Here are the coefficients

    alp = 0.585;
    bet = 0.5;
    del = 3.75;
    zii = 0.75;
    eps = 0.4;
    phi = 0.4;
    fii = 0.45;
    gam = 0.3;
    
    if EnginesNumber(1,n) > 0

    mtowb = mtowi - (WingWeight(n) + WingletWeight(n) + (1-UndercarriageLayout(n)) * LandingGearWeight(n) +...
        (GearboxWeight(n)+NacelleWeight(n)) * (1-qxheavy(EnginesLayout(1,n),3,1)) + FinalWingFuelWeight(n));
    else
        mtowb = mtowi - (WingWeight(n) + WingletWeight(n) + (1-UndercarriageLayout(n)) * LandingGearWeight(n) +...
        FinalWingFuelWeight(n));
    end
    Pcor = EnginesCorrection * mtowi; % correction for powerplant and landing gear placment

    % fuselage weight prediction
    
    FuseWeight(n) = AdvancedTechnologyMultiplier * (Pcor + alp * PressureCorrection * LandingGearCorrection * ((FuseLength(n)/EquivalentDiameter)^bet)*...
        ((FuseLength(n)*EquivalentDiameter)^zii)*((nult/del)^eps)*(mtowb^phi)*(md/fii)^gam);

    % If complex value is reached exit iteration process and save previous
    % fuselage weight
    if ~isreal(FuseWeight)
        warning('warn:wb_weight',...
            'Fuselage weight reached a complex weight, exiting process at %2d-th iteration', count);
        fprintf('Fuselage weight value:\n');
        disp(FuseWeight(n))
        break
    end
    
    if CoGsMOD==159
      FuseWeight(n)=massUserImp(1,5);
    end
    
    PLOTCGS(5, 4, n) = FuseWeight(n);% store value for cg analysis
    %----------------------------------------------------------------------
    % Horizontal tail weight estimation.

    if (HTailArea(n) > 0.0001)

        alp = 4.4;
        bet = 1e4;
        nhtlwei = mtowi * nult * (HTailArea(n)^2) * HTailAR(n);
        dhtlwei = bet * (WingArea(n) + wi2gare(n)) * RefHTailThickness(n) * (cos(RefHTailQCSweep(n)*deg2rad))^1.8;

        HTailWeight(n) = AdvancedTechnologyMultiplier * alp*(nhtlwei/dhtlwei)^0.56;

    else

        HTailWeight(n)=0.0; % no horizontal tail is specified

    end
    
    %%% TEST %%%
    %HTailWeight(n)=3900.0;
    %massUserImp(1,1)
    if CoGsMOD==159
         HTailWeight(n)=massUserImp(1,3);
    end
    %%%%%%%%%%%%%
    % HTailWeight(n)
    PLOTCGS(3,4,n) = HTailWeight(n); % store value for cg analysis

    %----------------------------------------------------------------------
    % Vertical tail weight estimation.

    if VTailArea(n) > 0.0001

        alp = 0.8926 + EmpennageLayout(n) * 0.6514;% weight penalty adjusted for T-tail

        if HTailArea(n) < 0.0001

            % If a horizontal tail is not selected, an equivalent method is required to
            % to predict the vertical tail weight based on the above methodology. The
            % idea is to use the horizontal tail weight equation on the vertical tail
            % and use the normalised weight-area relationship for the final vertical tail
            % result.

            nhtlwei = mtowi * nult * (VTailArea(n)^2) * VTailAR(n);
            dhtlwei = 1e4 * (WingArea(n) + wi2gare(n)) * RefVTailThickness(n)*(cos(RefVTailQCSweep(n)*deg2rad))^1.8;
            bet = (AdvancedTechnologyMultiplier*4.4*(nhtlwei/dhtlwei)^0.56)/VTailArea(n);
            nvtlwei = RefVTailThickness(n) * cos(RefVTailQCSweep(n)*deg2rad);

        else

            nvtlwei = RefHTailThickness(n) * cos(RefHTailQCSweep(n)*deg2rad);
            bet = HTailWeight(n)/HTailArea(n);

        end

        dvtlwei = RefVTailThickness(n) * cos(RefVTailQCSweep(n) * deg2rad);
        VTailWeight(n) = AdvancedTechnologyMultiplier * alp * bet * VTailArea(n) * nvtlwei/dvtlwei;

    else

        VTailWeight(n) = 0.0; % no vertical tail is specified

    end

    if CoGsMOD==159
         VTailWeight(n)=massUserImp(1,4);
    end
    
    
    PLOTCGS(4, 4, n) = VTailWeight(n);% store value for cg analysis

    % TwinTail = 0/1 (0 = no twin tail; 1 = twin tail present)
    if TwinTail

        PLOTCGS(4,  4, n) = PLOTCGS(4, 4, n)/2;
        PLOTCGS(10, 4, n) = PLOTCGS(4, 4, n);

    end

    %----------------------------------------------------------------------
    % Ventral fin weight estimation. This is based on a simple wetted area
    % premise.
    VentralFinsWeight(n) = 0.0;

    %----------------------------------------------------------------------
    % Dorsal fin weight estimation.
    
    if VTailDorsalLocation(n)>0.0001

        DorsalFinsWeight = VTailWeight(n)/VTailWettedArea(n) * DorsalFinsWettedArea;
        VTailWeight(n) = VTailWeight(n) + DorsalFinsWeight;

    end

    %----------------------------------------------------------------------
    % Canard weight estimation (copied from HT).

    if canard_flag

        alp = 4.4;
        bet = 1e4;
        ncandwei = mtowi * nult * (candare(n)^2) * CanardAR(n);
        dcandwei = bet * (WingArea(n) + wi2gare(n)) * RefCanardThickness(n) * (cos(RefCanardQCSweep(n)*deg2rad))^1.8;

        CanardWeight(n) = AdvancedTechnologyMultiplier * alp*(ncandwei/dcandwei)^0.56;

    else

        CanardWeight(n) = 0.0; % no canard is specified

    end

    if CoGsMOD==159
       CanardWeight(n)=massUserImp(1,9);
    end
    
    PLOTCGS(11, 4, n) = CanardWeight(n); % store value for cg analysis
   
    %----------------------------------------------------------------------
    % SR 31/05/2010 - Tailbooms weight estimation (from Howe)

    if tailbooms_flag

        TBWeight(n)=0.23*sqrt((VDkn(n)*KTAS2MS)*TBLength(n)/2*TBDiameter(n))*(pi*TBDiameter(n)*TBLength(n)+pi*TBDiameter(n)/2)^1.2;

        if TBSymmetry(n) == 1
            TBWeight(n) = TBWeight(n)*2;
        end

    else

        TBWeight(n)=0;

    end
 
    if CoGsMOD==159
       TBWeight(n)=massUserImp(1,10);
    end
    

    PLOTCGS(12, 4, n) = TBWeight(n); % store Tailbooms mass value for cg analysis


    %----------------------------------------------------------------------
    % Green Manufacturer's Weight Empty
    GreenManEmptyWeight(n) = WingWeight(n) + WingletWeight(n) + HTailWeight(n) +...
        VTailWeight(n) + VentralFinsWeight(n) + CanardWeight(n) + TBWeight(n) + LandingGearWeight(n) +...
        PylonWeight(n) + GearboxWeight(n) + NacelleWeight(n) +...
        FuseWeight(n) + TotalSystemsWeight(n) + ALandingGearWeight(n); % + WeightTolerance(n);
    
    if AMflag
        GreenManEmptyWeight(n) = GreenManEmptyWeight(n) + sum(AM(:,4));
    end
    
    % *********** CONTROLLO *************
    %disp('****controllo no mass imp')
    %ALandingGearWeight(n);
    %PLOTCGS(17,4,n);
    %TotalSystemsWeight(n);
    %WeightTolerance(n);
    %WingletWeight(n)
    %VentralFinsWeight(n)
    %OperatingItemsWeight(n)
    
    %PylonWeight(n)
    %GearboxWeight(n)
    %NacelleWeight(n)  
    %FuseWeight(n)
    %TotalSystemsWeight(n) 
    %WeightTolerance(n)
    %disp('*****')
    % *********************************
    
  if CoGsMOD==159
    GreenManEmptyWeight(n) = WingWeight(n) + wi2gmas + WingletWeight(n) + HTailWeight(n) +...            % Aggiunto wi2gmas
        VTailWeight(n) + VentralFinsWeight(n) + CanardWeight(n) + TBWeight(n) + LandingGearWeight(n) +...
        massUserImp(1,6) + massUserImp(1,7) +...
        FuseWeight(n) + TotalSystemsWeight(n) + ALandingGearWeight(n);% + WeightTolerance(n) +...
        
    %disp('-----------controllo mass imp')
    %WingWeight(n)
    %wi2gmas
    %WingletWeight(n)
    %HTailWeight(n)
    %VTailWeight(n)
    %VentralFinsWeight(n)
    %CanardWeight(n)
    %TBWeight(n)
    %LandingGearWeight(n)
    %massUserImp(1,6)
    %massUserImp(1,7)
    %FuseWeight(n)
    %TotalSystemsWeight(n)
    %WeightTolerance(n)
    %ALandingGearWeight(n)
    
    %disp('-------------------')
    
         % PylonWeight(n) + GearboxWeight(n) + NacelleWeight(n)
       %CanardWeight(n)=massUserImp(1,9);
   end
    %----------------------------------------------------------------------
    % Predict the spec Operational Weight Empty
    OEW(n) = GreenManEmptyWeight(n) + PLOTCGS(21,4,n)  + TotalCrewWeight(n); % + OperatingItemsWeight(n);  already added to CompletionsWeight
    %----------------------------------------------------------------------
    % Predict the spec Maximum Zero Fuel Weight.
    MZFW(n) = OEW(n) + MaxPayloadWeight(n);
    %----------------------------------------------------------------------
    % Predict the spec Maximum Takeoff Weight.
    MTOW(n) = MZFW(n) + FuelAtMTOWMaxPayload(n);
    
    %disp('CONTROLLO MTOW')
    %GreenManEmptyWeight(n)
    %CompletionsWeight(n)
    %TotalCrewWeight(n)
    %CrewAndCarryonWeight(n)
    %OperatingItemsWeight(n)
    %MaxPayloadWeight(n)
    %FuelAtMTOWMaxPayload(n)
    %disp('************')
    
    

    % Give a weight resume at each iteration
    fprintf('\n\tIteration #%2d\n', count);
    fprintf('\tStructural weights:\n');
    fprintf('\tWing weight [Kg]:                       %10.2f\n', WingWeight(n));
    fprintf('\tHT weight [Kg]:                         %10.2f\n', HTailWeight(n));
    fprintf('\tVT weight [Kg]:                         %10.2f\n', VTailWeight(n));
    fprintf('\tCanard weight [Kg]:                     %10.2f\n', CanardWeight(n));
    fprintf('\tTailbooms weight [Kg]:                  %10.2f\n', TBWeight(n));
    fprintf('\tFuselage weight [Kg]:                   %10.2f\n', FuseWeight(n));
    fprintf('\tEngine1 group weight [kg]:              %10.2f\n', PLOTCGS(7, 4, n));
    fprintf('\tEngine2 group weight [kg]:              %10.2f\n', PLOTCGS(8, 4, n));
    fprintf('\tLanding gear weight  [kg]:              %10.2f\n', LandingGearWeight(n));
    fprintf('\tOperational empty weight [Kg]:          %10.2f\n', OEW(n));
    fprintf('\tGreen Manufactures Empty weight [Kg]:   %10.2f\n', GreenManEmptyWeight(n));
    fprintf('\tMax zero fuel weight [Kg]:              %10.2f\n', MZFW(n));
%     fprintf('\tMax Take-off weight [Kg]:               %10.2f\n', MTOW(n));
    MTOWdisp = sum(PLOTCGS(:, 4,n));
    if AMflag
        MTOWdisp = MTOWdisp + sum(AM(:,4));
    end
    fprintf('\tMax Take-off weight [Kg]:               %10.2f\n', MTOWdisp);
    fprintf('\tMax Fuel weight @ MTOW [Kg]:            %10.2f\n', FuelAtMTOWMaxPayload(n));
    fprintf('\tMax Fuel weight (nominal) [Kg]:         %10.2f\n', FuelWeight(n));

    % Update counter
    count = count + 1;
        
end


%--------------------------------------------------------------------------
% Predict the spec Maximum Ramp Weight.
MaxRampWeight(n) = MTOW(n) + RampIncrement(n);

%--------------------------------------------------------------------------
% Merit functions.
%
% maximum payload per PAX
MaxPayloadPerPassenger(n) = WeightPerPassenger(n) + IncrementPerPassenger(n);

% payload to MTOW at MFW
FromMFWtoMTOW(n) = MaxRampWeight(n) - (FuelWeight(n) + OEW(n));

% load factor to MTOW at MFW
% LR 1/3/2012 avoid NaN of Inf when no passengers are specified
if Passengers(n)
    PayloadMFWFactor(n) = FromMFWtoMTOW(n) / (Passengers(n) * MaxPayloadPerPassenger(n))*100;
else
    PayloadMFWFactor(n) = 0;
end

% structural efficiency
StructuralEfficiency(n) = OEW(n) / MTOW(n)*100;

% wing loading W/S(gross)
WingLoading(n) = MTOW(n) / (WingArea(n)+wi2gare(n));

% thrust-to-weight ratio
if EnginesNumber(1,n)>0
    ThrustToWeightRatio(n) = 101.94 * (EnginesNumber(1,n) * MaxThrust(1,n) +...
        EnginesNumber(2,n) * MaxThrust(2,n)) / MTOW(n);
else
    ThrustToWeightRatio(n) = 0;
end

% ******** Generazione Weights per Modulo COGs ************
    massforjava(1,1)= PLOTCGS(1, 4, n);              % Wing1
    massforjava(1,2)= PLOTCGS(2, 4, n);              % Wing2 - In Wing2
    massforjava(1,3)= PLOTCGS(3, 4, n);              % Horizontal Tail
    massforjava(1,4)= PLOTCGS(4, 4, n);              % Vertical Tail
    massforjava(1,5)= PLOTCGS(5, 4, n);              % Fuselage
    massforjava(1,6)= PLOTCGS(7, 4, n);        % Powerplant 1
    massforjava(1,7)= PLOTCGS(8, 4, n);        % Powerplant 2
    massforjava(1,8)= PLOTCGS(10, 4, n);                       % Vertical Tail 2
    massforjava(1,9)= PLOTCGS(11, 4, n);               % Canard
    massforjava(1,10)= PLOTCGS(12, 4, n);            % Tailboom
    massforjava(1,11)= PLOTCGS(6, 4, n);             % Landing Gear - CG non calcolato
    massforjava(1,12)= PLOTCGS(9, 4, n);            % Auxiliary Landing Gear - CG non calcolato
    massforjava(1,13)= PLOTCGS(17, 4, n);%+WeightTolerance(n);  % Total system or MiscellaneousTotalSystemsWeight(n)
    massforjava(1,14)= PLOTCGS(22, 4, n);             % Pilots TotalCrewWeight(n);
    massforjava(1,15)= PLOTCGS(21, 4, n);% Interior. Weight in Fuselage
    massforjava(1,16)= PLOTCGS(24, 4, n);             % Passengers - Verificare
    massforjava(1,17)= PLOTCGS(25, 4, n);             % Baggage and cargo - Verificare
    massforjava(1,18)= 0;                      % Fuel Tank wing - CG non calcolato
    massforjava(1,19)= 0;                      % Fuel Tank centre - CG non calcolato
    massforjava(1,20)= 0;                      % Fuel Tank aux - CG non calcolato
    massforjava(1,21)= PLOTCGS(18, 4, n);              %FuelforWingCoGACB;      % ac.fuel.max_weight_wing;
    massforjava(1,22)= PLOTCGS(19, 4, n);    %FuelforCenWingCoGACB;   % ac.fuel.max_weight_cent_wing_box;
    massforjava(1,23)= PLOTCGS(20, 4, n);          %FuelforAuxWingCoGACB;   % CG non calcolato
    massforjava(1,24)= sum(PLOTCGS(:, 4, n));
    if AMflag
        massforjava(1,24)=massforjava(1,24) + sum(AM(:,4));
    end
    massforjava(1,25)= GreenManEmptyWeight(n);
    
fileID = fopen('wb_file_dep.txt','w'); % Il file viene creato in WB\wb_weight.m
for oo=1:25
fprintf(fileID,'%10.2f\n', massforjava(1,oo));
end
fclose(fileID);

% PLOTCGS(:,:,1)
%{
WingWeight(n)
WingletWeight(n) 
HTailWeight(n) 
VTailWeight(n) 
VentralFinsWeight(n) 
CanardWeight(n) 
TBWeight(n) 
LandingGearWeight(n) 
PylonWeight(n) 
GearboxWeight(n)  
NacelleWeight(n)        
FuseWeight(n) 
TotalSystemsWeight(n) 
WeightTolerance(n)
FuelAtMTOWMaxPayload(n)
MaxPayloadWeight(n)
PassengersWeight(n)
IncrementalPAXWeight(n)
%}
% ***************************************************

% end of wb_weight function