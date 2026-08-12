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
%   DESCRIPTION: Now compute the centre of gravity locations for various
%                loading scenarios
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


% MEW centre of gravity
sumweig = 0.0;

sumwemx = 0.0;
%-------------------------------------
sumwemy = 0.0; % MISSING in the code!!
%-------------------------------------
sumwemz = 0.0;

for i=1:25

    if i ~= 17 && i ~= 18 && i ~= 19 && i ~= 20 && i ~= 22 && i ~= 23 && i ~= 24 && i ~= 25
        
        % this calculations neglects wing fuel, centre tank fuel, auxiliary tank fuel
        % individual passenger collective weight and collective baggage weight
        sumweig = sumweig + PLOTCGS(i, 4, n);% weight accumulator
        
        % weight-moment accumulator for longitudinal axis
        sumwemx = sumwemx + PLOTCGS(i, 1, n)*PLOTCGS(i, 4, n);
        
        % weight-moment accumulator for vertical axis
        sumwemz = sumwemz + PLOTCGS(i, 3, n)*PLOTCGS(i, 4, n);

        % weight-moment accumulator for lateral axis
        sumwemy = sumwemy + PLOTCGS(i, 2, n)*PLOTCGS(i, 4, n);
        
    end
    
end

if AMflag
    sumweig = sumweig + sum(AM(:,4));
    sumwemx = sumwemx + sum(AM(:,1).*AM(:,4));
    sumwemy = sumwemy + sum(AM(:,2).*AM(:,4));
    sumwemz = sumwemz + sum(AM(:,3).*AM(:,4));
end


% COECOGX(n) = 100*( sumwemx/sumweig - ...
%                         (REFWAPX(n)*FuseLength(n) + ...
%                          MACSpanPos(n)*WingSpan(n)/2*tan(deg2rad*REFWLSW(n))) )/REFWMAC(n);
%              
% COECOGZ(n) = 100*sumwemz/( sumweig*FuseVerticalDiameterAft(n) );

% Aircraft MEW CoG
COECOGX(n) = (sumwemx/sumweig)/FuseLength(n);
COECOGY(n) = 0.0;
COECOGZ(n) = (sumwemz/sumweig)/FuseVerticalDiameterAft(n);

% Output
PLOTCGS(29, 1, n) = sumwemx/sumweig;
PLOTCGS(29, 3, n) = sumwemz/sumweig;

fprintf('\n\tCoG for MEW configuration:\n');
fprintf('\tX-position [m]: %10.2f\n', PLOTCGS(29, 1, n));
fprintf('\tY-position [m]: %10.2f\n', PLOTCGS(29, 2, n));
fprintf('\tZ-position [m]: %10.2f\n', PLOTCGS(29, 3, n));

%==========================================================================

% maximum payload centre of gravity - MTOW
% build the fueling schedule

tankts1 = FuelAtMTOWMaxPayload(n) - PLOTCGS(18, 4, n);
tankts2 = tankts1 - PLOTCGS(19, 4, n);
tankts3 = tankts2 - PLOTCGS(20, 4, n);
tankwe1 = 0.0;
tankwe2 = 0.0;
tankwe3 = 0.0;

if tankts1 > 0.0001
    
    % fill the integral wing tanks to max capacity
    tankwe1 = PLOTCGS(18, 4, n);
    
    if tankts2 > 0.0001
        
        % fill the centre tank to max capacity
        tankwe2 = PLOTCGS(19, 4, n);
        
    else
        
        tankwe2 = abs(tankts1);
        
    end
    
    if tankts3 > 0.0001
        
        % fill the auxiliary tank to max capacity
        tankwe3 = PLOTCGS(20, 4, n);
        
    else
        
        tankwe3 = abs(tankts2);
        
    end
    
else
    
    % partially filled integral wing tanks
    tankwe1 = FuelAtMTOWMaxPayload(n);
    
end

sumweig = sumweig + tankwe1 + tankwe2 + tankwe3;   % weight accumulator

% weight-moment accumulator for longitudinal axis
sumwemx = sumwemx + PLOTCGS(18, 1, n)*tankwe1 + PLOTCGS(19, 1, n)*tankwe2 + ...
                                                      PLOTCGS(20, 1, n)*tankwe3;
      
% weight-moment accumulator for vertical axis
sumwemz = sumwemz + PLOTCGS(18, 3, n)*tankwe1 + PLOTCGS(19, 3, n)*tankwe2 + ...
                                                      PLOTCGS(20, 3, n)*tankwe3;
      
% address the impact of crew, operating items and payload
% weight accumulator
sumweig = sumweig + PLOTCGS(17, 4, n) + PLOTCGS(22, 4, n) + ...
                    PLOTCGS(23, 4, n) + PLOTCGS(24, 4, n) + PLOTCGS(25, 4, n);
      
% weight-moment accumulator for longitudinal axis
sumwemx = sumwemx + PLOTCGS(17, 1, n)*PLOTCGS(17, 4, n) + ...
                    PLOTCGS(22, 1, n)*PLOTCGS(22, 4, n) + ...
                    PLOTCGS(23, 1, n)*PLOTCGS(23, 4, n) + ...
                    PLOTCGS(24, 1, n)*PLOTCGS(24, 4, n) + ...
                    PLOTCGS(25, 1, n)*PLOTCGS(25, 4, n);
                
% weight-moment accumulator for vertical axis
sumwemz = sumwemz + PLOTCGS(17, 3, n)*PLOTCGS(17, 4, n) + ...
                    PLOTCGS(22, 3, n)*PLOTCGS(22, 4, n) + ...
                    PLOTCGS(23, 3, n)*PLOTCGS(23, 4, n) + ...
                    PLOTCGS(24, 3, n)*PLOTCGS(24, 4, n) + ...
                    PLOTCGS(25, 3, n)*PLOTCGS(25, 4, n);
                
% CMPCOGX(n) = 100*( sumwemx/sumweig - ...
%                         (REFWAPX(n)*FuseLength(n) + ...
%                          MACSpanPos(n)*WingSpan(n)/2*tan(deg2rad*REFWLSW(n))) )/REFWMAC(n);
%                      
% CMPCOGZ(n) = 100*sumwemz/( sumweig*FuseVerticalDiameterAft(n) );

% Aircraft MTOW CoG
CMPCOGX(n) = (sumwemx/sumweig)/FuseLength(n);
CMPCOGY(n) = 0.0;     
CMPCOGZ(n) = (sumwemz/sumweig)/FuseVerticalDiameterAft(n);

% Output
PLOTCGS(27, 1, n) = sumwemx/sumweig;
PLOTCGS(27, 3, n) = sumwemz/sumweig;

% SR 18/07/2010 Printout of CoG position for MTOW configuration

fprintf('\n\tCoG for MTOW configuration:\n');
fprintf('\tX-position [m]: %10.2f\n', PLOTCGS(27, 1, n));
fprintf('\tY-position [m]: %10.2f\n', PLOTCGS(27, 2, n));
fprintf('\tZ-position [m]: %10.2f\n', PLOTCGS(27, 3, n));

% LR 20/09/2012 Print out MAC position and value

[MAC, YMAC, XLEMAC, XACMAC] = RecoverMACInfo(aircraft);
fprintf('\n\tMean Aerodynamic Chord data:\n');
fprintf('\tMAC value  [m]: %10.2f\n', MAC);
fprintf('\tMAC LE X   [m]: %10.2f\n', XLEMAC);
fprintf('\tMAC AC X   [m]: %10.2f\n', XACMAC);

% Print out the x-position of CoG w.r.t. MAC leading edge 
fprintf('\n\t(XCG-XLEMAC)/MAC [%%]:\n');
fprintf('\tMEW  [%%]: %10.2f\n', abs(PLOTCGS(29, 1, n)-XLEMAC)/MAC*100);
fprintf('\tMTOW [%%]: %10.2f\n', abs(PLOTCGS(27, 1, n)-XLEMAC)/MAC*100);

% END OF FUNCTION BODY
%-------------------------------------------------------------------------------------------------------------------------------------------------------------
