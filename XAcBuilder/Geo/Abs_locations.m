
%=====
global NacelleLength ChordAtEngine PN NacelleXLoc NacelleYLoc NacelleZLoc WingLongitudinalLocation WingVerticalLocation WI2GAPX WI2GAPZ HTailLongitudinalLocation HTailVerticalLocation VTailLongitudinalLocation VTailVerticalLocation
global l_central width thickness XFAIR ZFAIR l_fore l_aft FuseFractionFore Xsponson Zsponson
global VTailFuseDepth

global aircraft
n=1;


%% Pylons and nacelles

% % Location of the powerplants.
% Legend for powerplant configuration selection:
% (0) slung in vicinity of the wing 
% (1) on-wing nacelle (2) on-wing integrated with undercarraige
% (3) aft-fuse
% (4) Straight duct   (5) S-duct
% nacetype (0) short-duct (1) long-duct 

% Initialize the Y location of the nacelles: it is 0 by default
yloc=0;

for i=1:PN
   if i==1 && ~aircraft.Engines1.present
      continue
   end
   if i==2 && ~aircraft.Engines2.present
      continue
   end
% not applicable for aft-fuse, S-duct and straight duct installations
   if EnginesLayout(i,n)<3.0
% longitudinal location of engine wing chord leading edge   
      if EnginesLocalY(i,n)*WingSpan(n)/2<SpanMatrixPartition(1)
% engines located at inboard segment
	 xlenge=WingApex(n)*FuseLength(n)+ ...
		  abs(EnginesLocalY(i,n))*WingSpan(n)/2*tan(deg2rad*WingLESweep(1,n));
	 zlenge=(2*WingPlacement(n)-1)*FuseVerticalDiameterAft(n)/2+ ...
		  abs(EnginesLocalY(i,n))*WingSpan(n)*tan(deg2rad*WingDihedral(1,n))/2;
         sparlc=1.0;% used for pylon drafting
      elseif EnginesLocalY(i,n)*WingSpan(n)/2>=SpanMatrixPartition(1) && EnginesLocalY(i,n)*WingSpan(n)/2<SpanMatrixPartition(2)+SpanMatrixPartition(1)
% engines located at midboard segment
	 xlenge=WingApex(n)*FuseLength(n)+ ...
		  SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1,n))+ ...
                  (abs(EnginesLocalY(i,n))*WingSpan(n)/2- ...
                  SpanMatrixPartition(1))*tan(deg2rad*WingLESweep(2,n));
         zlenge=(2*WingPlacement(n)-1)*FuseVerticalDiameterAft(n)/2+ ...
                  SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n))+ ...
                  (abs(EnginesLocalY(i,n))*WingSpan(n)/2- ...
                  SpanMatrixPartition(1))*tan(deg2rad*WingDihedral(2,n));
         sparlc=2.0;% used for pylon drafting
      elseif EnginesLocalY(i,n)*WingSpan(n)/2>=SpanMatrixPartition(2)+SpanMatrixPartition(1)
% engines located at outboard segment
         xlenge=WingApex(n)*FuseLength(n)+ ...
                  SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1,n))+ ...
                  SpanMatrixPartition(2)*tan(deg2rad*WingLESweep(2,n))+ ...
                  (abs(EnginesLocalY(i,n))*WingSpan(n)/2- ...
                  SpanMatrixPartition(2)-SpanMatrixPartition(1))*tan(deg2rad*WingLESweep(3,n));
         zlenge=(2*WingPlacement(n)-1)*FuseVerticalDiameterAft(n)/2+ ...
                  SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1,n))+ ...
                  SpanMatrixPartition(2)*tan(deg2rad*WingDihedral(2,n))+ ...
                  (abs(EnginesLocalY(i,n))*WingSpan(n)/2- ...
                  SpanMatrixPartition(2)-SpanMatrixPartition(1))*tan(deg2rad*WingDihedral(3,n));
         sparlc=3.0;% used for pylon drafting
      end
   end      
%=====
% generate the placement coordinates for each powerplant option
% all powerplant installations have common y
   yloc=EnginesLocalY(i,n)*WingSpan(n)/2;
%=================================
% only applicable for slung engines
   if EnginesLayout(i,n)<0.0001   
% distinghuish between long and short ducts for placement on draft
      if NacelleType(i,n)>0.0001
% long duct placement      
	 xloc=xlenge-NacelleLength(i,n)+EnginesLocalX(i,n)*ChordAtEngine(i,n);
      else
% short duct placement
	 if FanCowlLength(i,n)<0.0001
	    FanCowlLength(i,n)=70.0;% default to fan cowl length 70% of nacelle
         end
         xloc=xlenge-NacelleLength(i,n)*FanCowlLength(i,n)/100+EnginesLocalX(i,n)*ChordAtEngine(i,n);
      end
      if EnginesLocalZ(i,n)>=0.0   
% nacelle in wing vicinity - local wing chord is used as datum for x & z
	 zloc=zlenge-EngineMaxDiameter(i,n)/2-EnginesLocalZ(i,n)*ChordAtEngine(i,n)- ...
	       Wing_Thickness_At_Span(abs(EnginesLocalY(i,n))*WingSpan(n)/2,SpanMatrixPartition, ...
               WingThickMatrix)*ChordAtEngine(i,n)/2;
         zlok=zloc;
      elseif EnginesLocalZ(i,n)<0.0
% nacelle above wing - local wing chord is used as datum for x & z
	 zloc=zlenge+EngineMaxDiameter(i,n)/2+abs(EnginesLocalZ(i,n))*ChordAtEngine(i,n)+ ...
	       Wing_Thickness_At_Span(abs(EnginesLocalY(i,n))*WingSpan(n)/2,SpanMatrixPartition, ...
               WingThickMatrix)*ChordAtEngine(i,n)/2;
         zlok=zloc;
      end      
%=================================
% nacelle-wing integrated configurations
   elseif EnginesLayout(i,n)==1 || EnginesLayout(i,n)==2
       
       % *******************************************************
       % disp('CONTROLLO FLUSSO') % Rev. 2016-06-01
       % *******************************************************
       
% on-wing nacelle - intersection of powerplant with wing geometry
      xloc=xlenge-NacelleLength(i,n)+EnginesLocalX(i,n)*ChordAtEngine(i,n);
      if EnginesLocalZ(i,n)~=1.0 || EnginesLocalZ(i,n)~=-1.0 
	 EnginesLocalZ(i,n)=1.0;% default to main nacelle on wing premise
      end
      if EnginesLocalZ(i,n)==-1.0  
% main nacelle on wing underside
	 zlok=zlenge-Wing_Thickness_At_Span(abs(EnginesLocalY(i,n))*WingSpan(n)/2, ...
	       SpanMatrixPartition,WingThickMatrix)*ChordAtEngine(i,n)/2-EngineMaxDiameter(i,n)/2;
	 zloc=zlok+Wing_Thickness_At_Span(abs(EnginesLocalY(i,n))*WingSpan(n)/2,SpanMatrixPartition, ...
	       WingThickMatrix)*ChordAtEngine(i,n)+EngineMaxDiameter(i,n)/2;
      elseif EnginesLocalZ(i,n)==1.0
          % **********************************************************
          % disp('CONTROLLO FLUSSO - MOTORE ON WING') % Rev. 2016-06-01
          % **********************************************************
% main nacelle on wing upperside
	 zloc=zlenge+Wing_Thickness_At_Span(abs(EnginesLocalY(i,n))*WingSpan(n)/2, ...
	       SpanMatrixPartition,WingThickMatrix)*ChordAtEngine(i,n)/2+EngineMaxDiameter(i,n)/2;
	 zlok=zloc-Wing_Thickness_At_Span(abs(EnginesLocalY(i,n))*WingSpan(n)/2,SpanMatrixPartition, ...
	       WingThickMatrix)*ChordAtEngine(i,n)-EngineMaxDiameter(i,n)/2;
       % ***************************************************************
       % disp('VARIABILI POSIZIONE Z') % Rev. 2016-06-01
       % zloc;
       % zlok;
       % ***************************************************************
       
      end          
% aft-fuse mounted on pylons powerplant arrangement
   elseif EnginesLayout(i,n)>2.0
% aft-fuse mounted pylons - x & z depends on relative fuselage measures   
      xloc=EnginesLocalX(i,n)*FuseLength(n);
      zloc=EnginesLocalZ(i,n)*FuseVerticalDiameterAft(n);zlok=zloc;
   end
   % *************************************************************
   % disp('CONTROLLO - var engzlc') % - Rev. 2016-06-01
   % EnginesLocalZ;
   % *************************************************************
   NacelleXLoc(i,n)=xloc;NacelleZLoc(i,n)=zlok; NacelleYLoc(i,n)=yloc; %%%% !!!!!!!!!!!!! WARNING - CORRECTION FOR ENGINE IN WING - NacelleZLoc(i)=zloc >>>> NacelleZLoc(i)=zlok VEDI riga 447
   
   % **************************************************************
   % zloc;
   % zlok;
   % NacelleZLoc;
   % **************************************************************
end

%% Computes the position of the wing 1 apex
% Longitudinal location
WingLongitudinalLocation=WingApex(1,n)*FuseLength(1,n);

%Vertical location
WingVerticalLocation=(2*WingPlacement(n)-1)*FuseVerticalDiameterAft(n)/2;

   
%% Computes the position of the wing 2 apex
% If there is a second wingm compute its position
if aircraft.Wing2.present
    % Longitudinal location
    WI2GAPX=wi2gapx(1,n)*FuseLength(1,n);

    %Vertical location
    WI2GAPZ=(2*wi2gplc(n)-1)*FuseVerticalDiameterAft(n)/2;
% If there is no second wing just set to the default value 0
else 
    WI2GAPX=0;
    WI2GAPZ=0;
end
%% Position of the horizontal tail apex

  if EmpennageLayout(n)>0.001
     if EmpennageLayout(n)<=VTailKink(1,n)
        xincr=EmpennageLayout(n)/VTailKink(1,n)*VTailSpanMatrixPartition(1)*tan(deg2rad*VTailLESweep(1,n))+ ...
              VTailOriginalRootChord(n)*VTailTaper(1,n)*0.1;
        zincr=EmpennageLayout(n)/VTailKink(1,n)*VTailSpanMatrixPartition(1);
     elseif EmpennageLayout(n)>VTailKink(1,n) && EmpennageLayout(n)<=VTailKink(2,n)  
        xincr=VTailSpanMatrixPartition(1)*tan(deg2rad*VTailLESweep(1,n))+ ...
              (EmpennageLayout(n)-VTailKink(1,n))/(VTailKink(2,n)- ...
              VTailKink(1,n))*VTailSpanMatrixPartition(2)*tan(deg2rad*VTailLESweep(2,n))+ ...
              VTailOriginalRootChord(n)*VTailTaper(2,n)*0.1;
        zincr=VTailSpanMatrixPartition(1)+(EmpennageLayout(n)-VTailKink(1,n))/(VTailKink(2,n)- ...
              VTailKink(1,n))*VTailSpanMatrixPartition(2);
     elseif EmpennageLayout(n)>VTailKink(2,n)   
        xincr=VTailSpanMatrixPartition(1)*tan(deg2rad*VTailLESweep(1,n))+ ...
              VTailSpanMatrixPartition(2)*tan(deg2rad*VTailLESweep(2,n))+ ...
              (EmpennageLayout(n)-VTailKink(2,n))/(1- ...
              VTailKink(2,n))*VTailSpanMatrixPartition(3)*tan(deg2rad*VTailLESweep(3,n))+ ...
              VTailOriginalRootChord(n)*VTailTaper(3,n)*0.1;
        zincr=VTailSpanMatrixPartition(1)+VTailSpanMatrixPartition(2)+ ...
              (EmpennageLayout(n)-VTailKink(2,n))/(1- ...
              VTailKink(2,n))*VTailSpanMatrixPartition(3);
     end      
  else
     xincr=0.0;zincr=0.0;% user has selected the horizontal and vertical
  end
  if xincr>0.0
     HTailApex(n)=VTailApex(n)+xincr/FuseLength(n);
     HTailVerticalLocale(n)=VTailVerticalLocale(n)+zincr/FuseVerticalDiameterAft(n);
  end

  % Longitudinal location
  HTailLongitudinalLocation=FuseLength(1,n)*HTailApex(n);
  % Vertical location
  HTailVerticalLocation=FuseVerticalDiameterAft(n)*HTailVerticalLocale(n);

%% Position of vertical tail apex
% Longitudinal location
VTailLongitudinalLocation=VTailApex(n)*FuseLength(1,n);

% Vertical location
VTailVerticalLocation=FuseVerticalDiameterAft(n)*VTailVerticalLocale(n);

%% Position of the fairing
   if FairingChordFractionFore(n)<0.0001
      FairingChordFractionFore(n)=50;
   end
   if FairingChordFractionAft(n)<0.0001
      FairingChordFractionAft(n)=50;
   end
%=====
% create wing no. 1 fairing
   if FairingFlushness(n)>0.001
      if FairingFlushness(n)<1.0
         FairingFlushness(n)=1.0;% minimum acceptable value
      end
      % Length of the central elliptical cylinder
      l_central(1,n)=0.4*RefWingChordOrigin(n);
      % Width of the ellipse
      width(1,n)=FuseWingPosition(n);
      % Heigth of the ellipse
      thickness(1,n)=FairingFlushness(n)*WingThickMatrix(2,1)*RefWingChordOrigin(n)/2;
      % Positioning of the fairing
      XFAIR(1,n)=WingApex(n)*FuseLength(n)+30/100*RefWingChordOrigin(n);
      ZFAIR(1,n)=(2*WingPlacement(n)-1)*FuseVerticalDiameterAft(n)/2+WingThickMatrix(2,1)*RefWingChordOrigin/2;
      l_fore(1,n)=(30+FairingChordFractionFore(n))/100*RefWingChordOrigin(n);
      l_aft(1,n)=(30+FairingChordFractionAft(n))/100*RefWingChordOrigin(n);
   end
   
%=====
   if aircraft.Wing2.present
% create wing no. 2 fairing
      if fa2rfwd(n)<0.0001
         fa2rfwd(n)=50;
      end
      if fa2raft(n)<0.0001
         fa2raft(n)=50;
      end
      if fa2rovh(n)>0.001
         if fa2rovh(n)<1.0
            fa2rovh(n)=1.0;% minimum acceptable value
         end
         % Length of the central elliptical cylinder
       l_central(2,n)=0.4*WC2DROT(n);
      % Width of the ellipse
      width(2,n)=XS2CDWF(n);
      % Heigth of the ellipse
      thickness(2,n)=fa2rovh(n)*WT2KMTX(2,1)*WC2DROT(n)/2;
      % Positioning of the fairing
      XFAIR(2,n)=wi2gapx(n)*FuseLength(n)+30/100*WC2DROT(n);
      ZFAIR(2,n)=(2*wi2gplc(n)-1)*FuseVerticalDiameterAft(n)/2;
                 (2*WingPlacement(n)-1)*FuseVerticalDiameterAft(n)/2;
      l_fore(2,n)=(30+fa2rfwd(n))/100*WC2DROT(n);
      l_aft(2,n)=(30+fa2raft(n))/100*WC2DROT(n);
      end
   end

   if (FuseFractionFore(1,n)==0 || FuseFractionFore(1,n)==1)
       FuseFractionFore(1,n)=0.5;
   end

%% Sponson
% create the ancillary fairing or sponson
   if spsnxlc(n)>0.001
      if spsnlgt(n)<0.001
         spsnlgt(n)=0.40;% default length
      end
      if spsnxzs(n)<0.001
         spsnxzs(n)=3.50;% default slenderness
      end
      if spsnwid(n)<0.001
         spsnwid(n)=FuseWingPosition(n)/FuseHorizontalDiameterAft(n);% default width
      end
%Positionning of the sponson
      Xsponson(1,n)=spsnxlc(n)*FuseLength(n);
      Zsponson(1,n)=(2*spsnzlc(n)-1)*FuseVerticalDiameterAft(n)/2; 
   end   
 
     
%% Compute the airfoil data for wing 1, wing 2, Horizontal Tail and
% Vertical Tail

wingAirfoilSpline=wgcomp(aircraft.Wing1.airfoilRoot,RefWingChordOrigin,WingTaper,SpanMatrixPartition,WingLESweep,WingIncidence,WingDihedral,n);

if aircraft.Wing2.present
    wi2gAirfoilSpline=wgcomp(aircraft.Wing2.airfoilRoot,WC2DROT,wi2gtap,WS2NMTX,wi2glsw,wi2ginc,wi2gdih,n);
end

if aircraft.Horizontal_tail.present
    HTAirfoilSpline=wgcomp(aircraft.Horizontal_tail.airfoilRoot,HTailOriginalRootChord,HTailTaper,HTailSpanMatrixPartition,HTailLESweep,HTailIncidence,HTailDihedral,n);
end

if aircraft.Canard.present
    CNAirfoilSpline=wgcomp(aircraft.Canard.airfoilRoot,CanardOriginalRootChord,CanardTaper,CanardSpanMatrixPartition,CanardLESweep,CanardIncidence,CanardDihedral,n);
end

if aircraft.Vertical_tail.present
    VTAirfoilSpline=wgcomp(aircraft.Vertical_tail.airfoilRoot,VTailOriginalRootChord,VTailTaper,VTailSpanMatrixPartition,VTailLESweep,VTailIncidence,VTailDihedral,n);
end


%% Powerplants and pylons
% Draw the powerplants.
% The nacelle drawings are based on an analytical geometry method developed
% by Isikveren. A template quadrant is first produced and symmetry is
% subsequently employed for the full figure.
%%=====
clear xval yval zval;
% Legend for powerplant configuration selection:
% (0) slung in vicinity of the wing
% (1) on-wing nacelle
% (2) on-wing integrated with undercarraige
% (3) aft-fuse
% (4) Straight duct
% (5) S-duct
% nacetype (0) short-duct (1) long-duct
%=====
for i=1:PN
    %=====
    % construct the basic nacelle quadrant template used for all powerplant types
    seg=12;
    for k=0:seg
        theta(k+1,1:seg+1)=k/seg*pi/2;
    end
    for j=0:seg
        tparam=pi*j/(2*seg);
        if EnginesType(i)>3
            % if a pusher turboprop or propfan selected, reverse the nacelle orientation
            xval(seg+1:1,j+1)=exp(tparam)*sin(tparam)*NacelleLength(i)/4.81;
        else
            % generate traditional intake fore and nozzle aft orientation
            xval(1:seg+1,j+1)=exp(tparam)*sin(tparam)*NacelleLength(i)/4.81;
        end
        % generate the arcing radial values for y & z coordinate computation
        lrad(1:seg+1,j+1)=(exp(tparam)*cos(tparam)+1)*EngineMaxDiameter(i)/4.93;
    end
    yval=lrad.*cos(theta);% y coordinates
    zval=lrad.*sin(theta);% z coordinates
    %=================================
    % not applicable for aft-fuse, S-duct and straight duct installations
    if EnginesLayout(i)<3.0
        % longitudinal location of engine wing chord leading edge
        if EnginesLocalY(i)*WingSpan/2<SpanMatrixPartition(1)
            % engines located at inboard segment
            xlenge=WingApex*FuseLength+ ...
                abs(EnginesLocalY(i))*WingSpan/2*tan(deg2rad*WingLESweep(1));
            zlenge=(2*WingPlacement-1)*FuseVerticalDiameterAft/2+ ...
                abs(EnginesLocalY(i))*WingSpan*tan(deg2rad*WingDihedral(1))/2;
            sparlc=1.0;% used for pylon drafting
        elseif EnginesLocalY(i)*WingSpan/2>=SpanMatrixPartition(1) && EnginesLocalY(i)*WingSpan/2<SpanMatrixPartition(2)+SpanMatrixPartition(1)
            % engines located at midboard segment
            xlenge=WingApex*FuseLength+ ...
                SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1))+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                SpanMatrixPartition(1))*tan(deg2rad*WingLESweep(2));
            zlenge=(2*WingPlacement-1)*FuseVerticalDiameterAft/2+ ...
                SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1))+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                SpanMatrixPartition(1))*tan(deg2rad*WingDihedral(2));
            sparlc=2.0;% used for pylon drafting
        elseif EnginesLocalY(i)*WingSpan/2>=SpanMatrixPartition(2)+SpanMatrixPartition(1)
            % engines located at outboard segment
            xlenge=WingApex*FuseLength+ ...
                SpanMatrixPartition(1)*tan(deg2rad*WingLESweep(1))+ ...
                SpanMatrixPartition(2)*tan(deg2rad*WingLESweep(2))+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                SpanMatrixPartition(2)-SpanMatrixPartition(1))*tan(deg2rad*WingLESweep(3));
            zlenge=(2*WingPlacement-1)*FuseVerticalDiameterAft/2+ ...
                SpanMatrixPartition(1)*tan(deg2rad*WingDihedral(1))+ ...
                SpanMatrixPartition(2)*tan(deg2rad*WingDihedral(2))+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                SpanMatrixPartition(2)-SpanMatrixPartition(1))*tan(deg2rad*WingDihedral(3));
            sparlc=3.0;% used for pylon drafting
        end
    end
    %=====
    % generate the placement coordinates for each powerplant option
    % all powerplant installations have common y
    yloc=EnginesLocalY(i)*WingSpan/2;
    %=================================
    % only applicable for slung engines
    if EnginesLayout(i)<0.0001
        % distinghuish between long and short ducts for placement on draft
        if NacelleType(i)>0.0001
            % long duct placement
            xloc=xlenge-NacelleLength(i)+EnginesLocalX(i)*ChordAtEngine(i);
        else
            % short duct placement
            if FanCowlLength(i)<0.0001
                FanCowlLength(i)=70.0;% default to fan cowl length 70% of nacelle
            end
            xloc=xlenge-NacelleLength(i)*FanCowlLength(i)/100+EnginesLocalX(i)*ChordAtEngine(i);
        end
        if EnginesLocalZ(i)>=0.0
            % nacelle in wing vicinity - local wing chord is used as datum for x & z
            zloc=zlenge-EngineMaxDiameter(i)/2-EnginesLocalZ(i)*ChordAtEngine(i)- ...
                Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2,SpanMatrixPartition, ...
                WingThickMatrix)*ChordAtEngine(i)/2;
            zlok=zloc;
        elseif EnginesLocalZ(i)<0.0
            % nacelle above wing - local wing chord is used as datum for x & z
            zloc=zlenge+EngineMaxDiameter(i)/2+abs(EnginesLocalZ(i))*ChordAtEngine(i)+ ...
                Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2,SpanMatrixPartition, ...
                WingThickMatrix)*ChordAtEngine(i)/2;
            zlok=zloc;
        end
        %=================================
        % nacelle-wing integrated configurations
    elseif EnginesLayout(i)==1 || EnginesLayout(i)==2
        % on-wing nacelle - intersection of powerplant with wing geometry
        xloc=xlenge-NacelleLength(i)+EnginesLocalX(i)*ChordAtEngine(i);
        if EnginesLocalZ(i)~=1.0 || EnginesLocalZ(i)~=-1.0
            EnginesLocalZ(i)=1.0;% default to main nacelle on wing premise
        end
        if EnginesLocalZ(i)==-1.0
            % main nacelle on wing underside
            zlok=zlenge-Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2, ...
                SpanMatrixPartition,WingThickMatrix)*ChordAtEngine(i)/2-EngineMaxDiameter(i)/2;
            zloc=zlok+Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2,SpanMatrixPartition, ...
                WingThickMatrix)*ChordAtEngine(i)+EngineMaxDiameter(i)/2;
        elseif EnginesLocalZ(i)==1.0
            % main nacelle on wing upperside
            zloc=zlenge+Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2, ...
                SpanMatrixPartition,WingThickMatrix)*ChordAtEngine(i)/2+EngineMaxDiameter(i)/2;
            zlok=zloc-Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2,SpanMatrixPartition, ...
                WingThickMatrix)*ChordAtEngine(i)-EngineMaxDiameter(i)/2;
        end
        if WingConfiguration~=-2 || wi2gcfg~=-2
            % special side flat panels for on-wing powerplants
            xvaf(1,:)=xval(1,:);xvaf(2,:)=xval(1,:);
            yvaf(1,:)=yval(1,:);yvaf(2,:)=yval(1,:);
            zvaf(1,:)=zval(1,:);
            zvaf(2,:)=zvaf(1,:)+Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2, ...
                SpanMatrixPartition,WingThickMatrix)*ChordAtEngine(i)/2+EngineMaxDiameter(i)/2;
            % special horizontal flat panels for on-wing powerplants
            yvag(1,:)=yval(1,:);yvag(2,:)=-yvag(1,:);zvag=zeros(2,13);

        end

    elseif EnginesLayout(i)>2.0
        % aft-fuse mounted pylons - x & z depends on relative fuselage measures
        xloc=EnginesLocalX(i)*FuseLength;
        zloc=EnginesLocalZ(i)*FuseVerticalDiameterAft;zlok=zloc;zcorr=zloc;
    end

    NacelleXLoc(i)=xloc;NacelleZLoc(i)=zlok; NacelleYLoc(i,n)=yloc; %%%% !!!!!!!!!!!!! WARNING - CORRECTION FOR ENGINE IN WING - NacelleZLoc(i)=zloc >>>> NacelleZLoc(i)=zlok VEDI riga 133
    %=================================
    % Draw the pylons for (0) slung under(over)wing and
    %                     (3) aft-fuse mounted on pylons
    %=====
    % pylon draft assuming no TOLS with WPEBS (see Isikveren)
    if EnginesLayout(i)<0.0001 && WingConfiguration<0.0001 && wi2gcfg<0.0001
        engcthk=Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2,SpanMatrixPartition,WingThickMatrix);
        % call a special routine that generates all input pylon data for drafting
        [pspnmtx,pthkmtx,pylonxr,pylnlsw,pylninc,pylndih,pdumapx, ...
            pdumlgt,pfintap,pylnwet]=pycomp(EnginesLayout,WingConfiguration,wi2gcfg,EnginesLocalZ, ...
            xlenge,zlenge,xloc,zloc,zval,ChordAtEngine(i),engcthk,sparlc, ...
            FuseWingPosition,WingSpan,WingKink,RearSparPosition,NacelleLength,EnginesLocalY,0,0,i);

        % draft the powerplant pylons in starboard
        ycorr=-EnginesLocalY(i)*WingSpan/2;% place the object laterally
        if EnginesLocalZ(i)<0.0
            signc=-1.0;% overwing podded
        else
            signc=1.0;% underwing podded
        end
        % place the object vertically
        zcorr=zloc+signc*max(zval(:,1))-pspnmtx(1);

        PYLNCLW=pylnwet*EnginesNumber(i);% pylon wetted area
        % increment the total powerplant wetted area and re-evaluate the total wetted
        % area for aircraft.
        %          PowerplantWettedArea=PowerplantWettedArea+PylonWettedArea;TotalWettedArea=TotalWettedArea+PowerplantWettedArea;
        %=================================
        % pylon draft assuming TOLS with WPEBS (see Isikveren)
    elseif EnginesLayout(i)<0.0001 && WingConfiguration>0.0001 && wi2gcfg>0.0001
        % starboard lower pylon
        engcthk=Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2,SpanMatrixPartition,WingThickMatrix);
        % call a special routine that generates all input pylon data for drafting
        [pspnmtx,pthkmtx,pylonxr,pylnlsw,pylninc,pylndih,pdumapx, ...
            pdumlgt,pfintap,pylnwe1]=pycomp(EnginesLayout,WingConfiguration,wi2gcfg,EnginesLocalZ, ...
            xlenge,zlenge,xloc,zloc,zval,ChordAtEngine(i),engcthk,sparlc, ...
            FuseWingPosition,WingSpan,WingKink,RearSparPosition,NacelleLength,EnginesLocalY,1,0,i);

        ycorr=EnginesLocalY(i)*WingSpan/2;% place the object laterally
        zcorr=zloc-max(zval(:,1))-pspnmtx(1);% place the object vertically
        zwraw=zwraw+ycorr;ywraw=ywraw+zcorr;% geo placement corrections

        % port lower pylon
        xlengs=2*WingApex*FuseLength-xlenge;
        [pspnmtx,pthkmtx,pylonxr,pylnlsw,pylninc,pylndih,pdumapx, ...
            pdumlgt,pfintap,pylnwe2]=pycomp(EnginesLayout,WingConfiguration,wi2gcfg,EnginesLocalZ, ...
            xlengs,zlenge,xloc,zloc,zval,ChordAtEngine(i),engcthk,sparlc, ...
            FuseWingPosition,WingSpan,WingKink,RearSparPosition,NacelleLength,EnginesLocalY,1,1,i);

        ycorr=-EnginesLocalY(i)*WingSpan/2;                % place the object laterally
        zcorr=zloc-max(zval(:,1))-pspnmtx(1);       % place the object vertically
        %             zwraw=zwraw+ycorr;ywraw=ywraw+zcorr;        % geo placement corrections
        %             surfmat(61+(i-1)*8)=surf(xwraw,zwraw,ywraw);% construct the pylon
        %=====
        if EnginesLocalY(i)*WingSpan/2<WS2NMTX(1)
            % engines located at inboard segment
            xl2nge=wi2gapx*FuseLength+ ...
                abs(EnginesLocalY(i))*WingSpan/2*tan(deg2rad*wi2glsw(1));
            zl2nge=((2*wi2gplc-1)*FuseVerticalDiameterAft/2+ ...
                abs(EnginesLocalY(i))*WingSpan*tan(deg2rad*wi2gdih(1))/2);
        elseif EnginesLocalY(i)*WingSpan/2>=WS2NMTX(1) && EnginesLocalY(i)*WingSpan/2<WS2NMTX(2)+WS2NMTX(1)
            % engines located at midboard segment
            xl2nge=wi2gapx*FuseLength+ ...
                WS2NMTX(1)*tan(deg2rad*wi2glsw(1))+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                WS2NMTX(1))*tan(deg2rad*wi2glsw(2));
            zl2nge=((2*wi2gplc-1)*FuseVerticalDiameterAft/2+ ...
                abs(EnginesLocalY(i))*WingSpan*tan(deg2rad*wi2gdih(1))/2)+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                WS2NMTX(1))*tan(deg2rad*wi2gdih(2));
        elseif EnginesLocalY(i)*WingSpan/2>=WS2NMTX(2)+WS2NMTX(1)
            % engines located at outboard segment
            xl2nge=wi2gapx*FuseLength+ ...
                WS2NMTX(1)*tan(deg2rad*wi2glsw(1))+ ...
                WS2NMTX(2)*tan(deg2rad*wi2glsw(2))+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                WS2NMTX(2)-WS2NMTX(1))*tan(deg2rad*wi2glsw(3));
            zl2nge=((2*wi2gplc-1)*FuseVerticalDiameterAft/2+ ...
                abs(EnginesLocalY(i))*WingSpan*tan(deg2rad*wi2gdih(1))/2)+ ...
                WS2NMTX(2)*tan(deg2rad*wi2gdih(2))+ ...
                (abs(EnginesLocalY(i))*WingSpan/2- ...
                WS2NMTX(2)-WS2NMTX(1))*tan(deg2rad*wi2gdih(3));
        end
        % %=====
        % starboard upper pylon
        EN2ECHD(i)=Wing_Chord_At_Span(abs(EnginesLocalY(i))*WingSpan/2,WS2NMTX, ...
            WC2DROT,wi2gtap);
        engcthk=Wing_Thickness_At_Span(abs(EnginesLocalY(i))*WingSpan/2,WS2NMTX,WT2KMTX);
        xl2ngs=2*wi2gapx*FuseLength-xl2nge;
        % call a special routine that generates all input pylon data for drafting
        [pspnmtx,pthkmtx,pylonxr,pylnlsw,pylninc,pylndih,pdumapx, ...
            pdumlgt,pfintap,pylnwe3]=pycomp(EnginesLayout,WingConfiguration,wi2gcfg,EnginesLocalZ, ...
            xl2ngs,zl2nge,xloc,zloc,zval,EN2ECHD(i),engcthk,sparlc, ...
            FuseWingPosition,WingSpan,WingKink,RearSparPosition,NacelleLength,EnginesLocalY,2,0,i);

        ycorr=-EnginesLocalY(i)*WingSpan/2;% place the object laterally
        zcorr=zloc+max(zval(:,1))-pspnmtx(1);% place the object vertically
        zwraw=zwraw+ycorr;ywraw=ywraw+zcorr;% geo placement corrections
        %             surfmat(63+(i-1)*8)=surf(xwraw,zwraw,ywraw);% construct the pylon
        %=====
        % port upper pylon
        % call a special routine that generates all input pylon data for drafting
        [pspnmtx,pthkmtx,pylonxr,pylnlsw,pylninc,pylndih,pdumapx, ...
            pdumlgt,pfintap,pylnwe4]=pycomp(EnginesLayout,WingConfiguration,wi2gcfg,EnginesLocalZ, ...
            xl2nge,zl2nge,xloc,zloc,zval,EN2ECHD(i),engcthk,sparlc, ...
            FuseWingPosition,WingSpan,WingKink,RearSparPosition,NacelleLength,EnginesLocalY,2,1,i);

        ycorr=EnginesLocalY(i)*WingSpan/2;% place the object laterally
        zcorr=zloc+max(zval(:,1))-pspnmtx(1);% place the object vertically
        zwraw=zwraw+ycorr;ywraw=ywraw+zcorr;% geo placement corrections

        %=====
        PYLNCLW=pylnwe1+pylnwe2+pylnwe3+pylnwe4;% pylon wetted area
        % % increment the total powerplant wetted area and re-evaluate the total wetted
        % % area for aircraft.
        PowerplantWettedArea=PowerplantWettedArea+PylonWettedArea;TotalWettedArea=TotalWettedArea+PowerplantWettedArea;
        %=================================
    elseif EnginesLayout(i)==3.0 || EnginesLayout(i)==4.0
        % dummy variables for the function call
        pylninc(1:4)=0.0;% dummy incidence of zero
        if EnginesLayout(i)==4.0
            pylndih(1:3)=0.0;% no dihedral for straight duct
            pspn1=max(yval(:,1))-max(yval(:,13));
            pspn2=0.5*(abs(EnginesLocalZ(i))*FuseVerticalDiameterAft-pspn1-max(yval(:,13)));
        else
            pylndih(1:3)=-5.0;% dummy dihedral of 5 deg.
            pspn1=max(zval(:,1))-max(zval(:,13));
            pspn2=0.5*(abs(EnginesLocalY(i))*WingSpan/2-pspn1-max(zval(:,13)));
        end
        pdumapx=1.0;% dummy location
        %=====
        % construct the thickness matrix
        pthkmtx=[1.00 1.00 1.00; ...
            0.08 0.08 0.08];% assumed pylon thickness matrix
        %=====
        % construct the span matrix
        pspn3=pspn2;
        pspnmtx=[pspn1 pspn2 pspn3];% pylon span matrix
        %=====
        % pylon taper ratio matrix
        if EnginesType(i)<3
            pylonxr=NacelleLength(i);
            pfintap(1)=1.0;pfintap(2)=1.14;pfintap(3)=1.28;
            pylnlsw(1)=0.0;pdumlgt=xloc;
        else
            % set values specific to propfan power plants
            pylonxr=0.39*NacelleLength(i);
            pfintap(1)=1.0;pfintap(2)=1.0;pfintap(3)=1.0;
            pylnlsw(1)=-15.0;pdumlgt=xloc+0.2*NacelleLength(i);
        end
        pylnlsw(2)=pylnlsw(1);pylnlsw(3)=pylnlsw(2);

        % draft the powerplant pylons in starboard
        % place the object vertically and laterally
        if EnginesLayout(i)==4.0
            ycorr=-EnginesLocalZ(i)*FuseVerticalDiameterAft+max(yval(:,13));
            zloc=0;
        else
            ycorr=-EnginesLocalY(i)*WingSpan/2+max(zval(:,13));
            zloc=zloc-EnginesLocalY(i)*WingSpan/2*tan(pylndih(1)*deg2rad)- ...
                pthkmtx(1,1)*pthkmtx(2,1)*pylonxr/2;
        end
        % This routine predicts the wetted area of the pylons
        weta=pylonxr*pspnmtx(2);wetb=2+8.5*pthkmtx(2,2)^2;
        stapr=pfintap(2)/pfintap(1);
        wetc=0.0;
        pylnwet=weta*(wetb+wetc);
        PYLNCLW=pylnwet*EnginesNumber(i);% pylon wetted area
        % increment the total powerplant wetted area and re-evaluate the total wetted
        % area for aircraft.
        PowerplantWettedArea=PowerplantWettedArea+PylonWettedArea;TotalWettedArea=TotalWettedArea+PowerplantWettedArea;
    end

    if EnginesLayout(i)==3.0
        PYLROTX(i,n)=180;
    elseif EnginesLayout(i)==0.0
        PYLROTX(i,n)=-signc*90;
    end


    if (EnginesLayout(i,n)==0 || EnginesLayout(i,n)==3)

        if EnginesLayout(i,n)==0
            tiltcorr=EnginesPitch(i,n);
            % tiltcorr is a correction factor to the root chord and X
            % locale of the nacelle. tiltcorr ensures that the pylon does
            % not pierce through the inlet or outlet of the nacelle.
        else
            tiltcorr=EnginesToeIn(i,n);
        end

        pylonxr=pylonxr*abs(cos(tiltcorr*pi/180));
        PYLRCH(i,n)=((1-pfintap(1))*abs(NacelleZLoc(i)-zcorr)/(pspnmtx(1)*0.95) + 1)*pylonxr*0.95;
        PYLTAP(i,:)=0.95*pylonxr/PYLRCH(i,n).*[pfintap(1);pfintap(2);pfintap(3)];
        PYLLESW(i,:)=[pylnlsw(1);pylnlsw(2);pylnlsw(3)];
        PYSPMTRX(i,:)=[pspnmtx(1)*0.95+abs(NacelleZLoc(i)-zcorr);pspnmtx(2);pspnmtx(3)];
        PYLLOCX(i,n)=xloc+(pspnmtx(1)+abs(NacelleZLoc(i)-zcorr))*tan(tiltcorr*pi/180);
        PYLLOCY(i,n)=-ycorr;
        PYLLOCZ(i,n)=NacelleZLoc(i);
    end

end % the powerplants are finished

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Further precisions for strutural analysis
if aircraft.Vertical_tail.present %****** SOLO QUESTO IF, il resto era presente - 
if (VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4>0 && VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4<FuseLength(1,n))
    if (VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4<EpsilonNose(1,n)*FuseVerticalDiameterFore(1,n))
        beta=0.54+0.1*tan(OmegaNose(1,n)-PhiNose(1,n));
        VTailFuseDepth(1,n)=2*FuseVerticalDiameterFore(1,n)^(1-beta)/2+((VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4)/EpsilonNose(1,n))^beta;
    elseif (VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4>EpsilonNose(1,n)*FuseVerticalDiameterFore(1,n) && VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4<FuseFractionFore(1,n)*(FuseLength(1,n)-EpsilonNose(1,n)*FuseVerticalDiameterFore(1,n)-EpsilonTail(1,n)*FuseVerticalDiameterAft(1,n))+EpsilonNose(1,n)*FuseVerticalDiameterFore(1,n))
        xquarterVT=(VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4 - EpsilonNose(1,n)*FuseVerticalDiameterFore(1,n))/(FuseFractionFore(1,n)*(FuseLength(1,n)-EpsilonNose(1,n)*FuseVerticalDiameterFore(1,n)-EpsilonTail(1,n)*FuseVerticalDiameterAft(1,n)));
        VTailFuseDepth(1,n)=FuseVerticalDiameterFore(1,n)*(1-xquarterVT)+FuseVerticalDiameterAft(1,n)*xquarterVT;
    elseif (VTailApex(1,n)*FuseLength(1,n)+VTailOriginalRootChord(1,n)/4>FuseLength(1,n)-EpsilonTail(1,n)*FuseVerticalDiameterAft(1,n))
        beta=0.54+0.1*tan(OmegaTail(1,n)-PhiTail(1,n));
        VTailFuseDepth(1,n)=2*FuseVerticalDiameterAft(1,n)^(1-beta)/2+((FuseLength(1,n)-VTailApex(1,n)*FuseLength(1,n)-VTailOriginalRootChord(1,n)/4)/EpsilonTail(1,n))^beta;
    else
        VTailFuseDepth(1,n)=FuseVerticalDiameterAft(1,n);
    end
else 
    VTailFuseDepth(1,n)=0;
end
else
     VTailFuseDepth(1,n)=0;
end % **** Per If Aggiunto riga 641
