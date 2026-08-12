function [AERODATA]=aeroDataFromCpacs(CPACS_XML)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AreoFromCPACS                                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.1                                                   %
% LastModified:     2012-10-31 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Notes:
% - Altitude is used from  toolspecific/tornado
%   (...model/reference/point)
% - The Reference point ist used from CPACS
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<1
    initialize 
    [ s ] = xml2struct('a320test.xml');
    CPACS_XML=s.cpacs{1,1};
end

%% Setting

% Load Altitude from toospecifics
try
    altitude = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.altitude{1,1}.CONTENT);
catch
    altitude=11000;
    disp('Altitude is Set to 11000 m')
end 

homeDir=pwd;
[rho,a,p,mu,T]=ISA(altitude);

%% CPACS version Specifics
if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<2     
    CPversionType{1,1}='global';
    CPversionType{2,1}='controlSurfacesPolars';
    CPversionType{3,1}='controlSurfacePolars';
elseif str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)==2 %CPACS VERSION 2.0
    CPversionType{1,1}='analyses';
    CPversionType{2,1}='controlSurfacesPerformanceMaps';
    CPversionType{3,1}='controlSurfacePerformanceMap';
elseif str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)==2.01 %CPACS VERSION 2.01
    CPversionType{1,1}='analyses';
    CPversionType{2,1}='aeroPerformanceMap';
    CPversionType{3,1}='controlSurfaces';
    CPversionType{4,1}='controlSurface';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reading Arrays from CPACS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Global Parameter

% Array
machNumber      = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.machNumber{1,1}.CONTENT)';
angleOfYaw      = pi/180*str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.angleOfYaw{1,1}.CONTENT)'; 
angleOfAttack   = pi/180*str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.angleOfAttack{1,1}.CONTENT)'; 
try reynoldsNumber  = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.reynoldsNumber{1,1}.CONTENT)'; catch reynoldsNumber=0; end
try cfx             = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfx{1,1}.CONTENT           )'; end;
try cfy             = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfy{1,1}.CONTENT           )'; end;
try cfz             = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfz{1,1}.CONTENT           )'; end;
try cmx             = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmx{1,1}.CONTENT           )'; end;
try cmy             = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmy{1,1}.CONTENT           )'; end;
try cmz             = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmz{1,1}.CONTENT           )'; end;

%% Extra parameter (not define in theCPACS shema jet)
try
    cD0 = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cD0{1,1}.CONTENT)';
catch
    warning('No cD0')
end

  
%% Damping derivatives

% Array

% CPACS 1.6 
try dcfxdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdp{1,1}.CONTENT)'; end;
try dcfxdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdr{1,1}.CONTENT)'; end;
try dcfxdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdq{1,1}.CONTENT)'; end;
try dcfydp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydp{1,1}.CONTENT)'; end;
try dcfydr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydr{1,1}.CONTENT)'; end;
try dcfydq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydq{1,1}.CONTENT)'; end;
try dcfzdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdp{1,1}.CONTENT)'; end;
try dcfzdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdr{1,1}.CONTENT)'; end;
try dcfzdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdq{1,1}.CONTENT)'; end;
try dcmxdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdr{1,1}.CONTENT)'; end;
try dcmxdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdp{1,1}.CONTENT)'; end;
try dcmxdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdq{1,1}.CONTENT)'; end;
try dcmydp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydp{1,1}.CONTENT)'; end;
try dcmydq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydq{1,1}.CONTENT)'; end;
try dcmydr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydr{1,1}.CONTENT)'; end;
try dcmzdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdp{1,1}.CONTENT)'; end;
try dcmzdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdq{1,1}.CONTENT)'; end;
try dcmzdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdr{1,1}.CONTENT)'; end;

% CPACS 2.0
try dcfxdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdpstar{1,1}.CONTENT)'; end;
try dcfxdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdrstar{1,1}.CONTENT)'; end;
try dcfxdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdqstar{1,1}.CONTENT)'; end;
try dcfydp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydpstar{1,1}.CONTENT)'; end;
try dcfydr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydrstar{1,1}.CONTENT)'; end;
try dcfydq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydqstar{1,1}.CONTENT)'; end;
try dcfzdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdpstar{1,1}.CONTENT)'; end;
try dcfzdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdrstar{1,1}.CONTENT)'; end;
try dcfzdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdqstar{1,1}.CONTENT)'; end;
try dcmxdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdrstar{1,1}.CONTENT)'; end;
try dcmxdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdpstar{1,1}.CONTENT)'; end;
try dcmxdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdqstar{1,1}.CONTENT)'; end;
try dcmydp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydpstar{1,1}.CONTENT)'; end;
try dcmydq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydqstar{1,1}.CONTENT)'; end;
try dcmydr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydrstar{1,1}.CONTENT)'; end;
try dcmzdp = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdpstar{1,1}.CONTENT)'; end;
try dcmzdq = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdqstar{1,1}.CONTENT)'; end;
try dcmzdr = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdrstar{1,1}.CONTENT)'; end;


%% controlSurfacesPolars

% Controlsurfaces Absolut deflection
% csGeometys = {uid, relative Deflection, Rotation}
csGeometys={};
wings=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings;
count=0;

if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<2   
    try
        for wingNum=1:size(wings{1,1}.wing,2)
            for wingCsNum=1:size(wings{1,1}.wing{1,wingNum}.controlSurfaces{1,1}.controlSurface,2)
                controlSurfaces=wings{1,1}.wing{1,wingNum}.controlSurfaces;        
                count=count+1;
                % CS uID
                csGeometys{count,1}=controlSurfaces{1,1}.controlSurface{1,wingCsNum}.ATTRIBUTE.uID;
                for step=1:size(controlSurfaces{1,1}.controlSurface{1,wingCsNum}.path{1,1}.step,2)
                    csGeometys{count,2}(step,1)=str2num(controlSurfaces{1,1}.controlSurface{1,wingCsNum}.path{1,1}.step{1,step}.relDeflection{1,1}.CONTENT);
                    csGeometys{count,3}(step,1)=str2num(controlSurfaces{1,1}.controlSurface{1,wingCsNum}.path{1,1}.step{1,step}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT);
                end
            end
        end
    end
elseif str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)>=2 %CPACS VERSION 2.0
   try 
        controlType='trailingEdgeDevice';
        for wingNum=1:size(wings{1,1}.wing,2)
            for wingCsNum=1:size(wings{1,1}.wing{1,wingNum}.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.([controlType,'s']){1,1}.(controlType),2)
                controlGeo=wings{1,1}.wing{1,wingNum}.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.([controlType,'s']){1,1}.(controlType);        
                count=count+1;
                % CS uID
                csGeometys{count,1}=controlGeo{1,wingCsNum}.ATTRIBUTE.uID;
                for step=1:size(controlGeo{1,wingCsNum}.path{1,1}.steps{1,1}.step,2)
                    csGeometys{count,2}(step,1)=str2num(controlGeo{1,wingCsNum}.path{1,1}.steps{1,1}.step{1,step}.relDeflection{1,1}.CONTENT);
                    csGeometys{count,3}(step,1)=str2num(controlGeo{1,wingCsNum}.path{1,1}.steps{1,1}.step{1,step}.hingeLineRotation{1,1}.CONTENT);
                end
            end
        end
    end
end

% CPACS version
if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<=2     
    maxCsNum=size(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}),2);
elseif str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)==2.01 %CPACS VERSION 2.01
    maxCsNum=size(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,1}.(CPversionType{4,1}),2);
end

% Conrtolsurfacs Polars
try
    for csNum=1:maxCsNum
        
        % Chose peroformance map path by CPACS version
        if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<2     
            csPerfoMap=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1};
            % CS UID
            controlSurfaceUID=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.controlSurfaceUID{1,1}.CONTENT;  
        elseif str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)==2 %CPACS VERSION 2.0
            csPerfoMap=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1};
            % CS UID
            controlSurfaceUID=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.controlSurfaceUID{1,1}.CONTENT;
        elseif str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)==2.01 %CPACS VERSION 2.01
            csPerfoMap=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,1}.(CPversionType{4,1}){1,csNum};
            % CS UID
            controlSurfaceUID=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,1}.(CPversionType{4,1}){1,csNum}.controlSurfaceUID{1,1}.CONTENT;
        end
  
        % Find CS UID
        for i=1:size(csGeometys,1)
            if strcmp(csGeometys{i,1},controlSurfaceUID)
                csGeoNum=i;
            end
        end
        
        % CS Derivative array
        try  machNumberCS       = str2num(csPerfoMap.machNumber{1,1}.CONTENT    )'; end;
        try  reynoldsNumberCS   = str2num(csPerfoMap.reynoldsNumber{1,1}.CONTENT)'; end;
        try  angleOfYawCS       = str2num(csPerfoMap.angleOfYaw{1,1}.CONTENT    )'; end;
        try  angleOfAttackCS    = str2num(csPerfoMap.angleOfAttack{1,1}.CONTENT )'; end;
        try  relDeflectionCS    = str2num(csPerfoMap.relDeflection{1,1}.CONTENT )'; end;
        try  dcfx               = str2num(csPerfoMap.dcfx{1,1}.CONTENT          )'; end;
        try  dcfy               = str2num(csPerfoMap.dcfy{1,1}.CONTENT          )'; end;
        try  dcfz               = str2num(csPerfoMap.dcfz{1,1}.CONTENT          )'; end;
        try  dcmx               = str2num(csPerfoMap.dcmx{1,1}.CONTENT          )'; end;
        try  dcmy               = str2num(csPerfoMap.dcmy{1,1}.CONTENT          )'; end;
        try  dcmz               = str2num(csPerfoMap.dcmz{1,1}.CONTENT          )'; end;        

        try cs{csNum,1}.controlSurfaceUID =  controlSurfaceUID; end;
        try cs{csNum,1}.machNumberCS      =  machNumberCS     ; end;
        try cs{csNum,1}.reynoldsNumberCS  =  reynoldsNumberCS ; end;
        try cs{csNum,1}.angleOfYawCS      =  angleOfYawCS     ; end;
        try cs{csNum,1}.angleOfAttackCS   =  angleOfAttackCS  ; end;
        try cs{csNum,1}.relDeflectionCS   =  relDeflectionCS  ; end;
        try cs{csNum,1}.absDeflectionCS   =  interp1(csGeometys{csGeoNum,2},csGeometys{csGeoNum,3},relDeflectionCS);end;
        try cs{csNum,1}.dcfx              =  dcfx             ; end;
        try cs{csNum,1}.dcfy              =  dcfy             ; end;
        try cs{csNum,1}.dcfz              =  dcfz             ; end;
        try cs{csNum,1}.dcmx              =  dcmx             ; end;
        try cs{csNum,1}.dcmy              =  dcmy             ; end;
        try cs{csNum,1}.dcmz              =  dcmz             ; end;
    end
catch    
    errCase = lasterror;
    disp('Warning Massage:')
    disp(errCase.message)
    disp(errCase.identifier)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate AERODATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AERODATA={};

[machNumberVec, Mam, Man] =unique(machNumber);
[angleOfYawVec, Aym, Ayn] =unique(angleOfYaw);
[angleOfAttackVec, Aam, Aan] =unique(angleOfAttack);
[reynoldsNumberVec, Rem, Ren] =unique(reynoldsNumber);

% Reihenfolge         
count=0;
for iii=1:size(machNumberVec,2) 
    for iiii=1:size(reynoldsNumberVec,2) 
        for ii=1:size(angleOfYawVec,2)
            for i=1:size(angleOfAttackVec,2)
                count=count+1;
                    
%% Global Parameter

                AERODATA.TASrange(1,iii)                              =      machNumber(1,Mam(1,iii))*a;
                AERODATA.MArange(1,iii)                               =      machNumber(1,Mam(1,iii));
                AERODATA.betarange(1,ii)                              =      angleOfYaw(1,Aym(1,ii)); 
                AERODATA.alpharange(1,i)                              =      angleOfAttack(1,Aam(1,i));
                AERODATA.reynoldsNumberVec(1,iiii)                    =      reynoldsNumberVec(1,Rem(1,iiii));
                try  AERODATA.CD(i,ii,iii,iiii)   =      cfx(1,count);                end;
                try  AERODATA.CC(i,ii,iii,iiii)   =      cfy(1,count);                end; 
                try  AERODATA.CL(i,ii,iii,iiii)   =      cfz(1,count);                end; 
                try  AERODATA.Cl(i,ii,iii,iiii)   =      cmx(1,count);                end; 
                try  AERODATA.Cm(i,ii,iii,iiii)   =      cmy(1,count);                end; 
                try  AERODATA.Cn(i,ii,iii,iiii)   =      cmz(1,count);                end; 
                % AERODATA.Cx(Aan(1,count),Ayn(1,count),Man(1,count))
            
%% Transformation from aircraft fix {f} in aerodynamic coodinate {a} system with alpha and betha
                % x_a = f2aTransform * x_f

                betha=AERODATA.betarange(1,ii);
                alpha=AERODATA.alpharange(1,i);

                f2aTransform=[cos(betha)*cos(alpha),        -sin(betha),          cos(betha)*sin(alpha) ;...
                              cos(alpha)*sin(betha),         cos(betha),          sin(betha)*sin(alpha) ;...
                                        -sin(alpha),                  0,                     cos(alpha)];

                % Transformation from Aircraft fix to Global {G}   
                try Cxyz=f2aTransform*[AERODATA.CD(i,ii,iii,iiii),AERODATA.CC(i,ii,iii,iiii),AERODATA.CL(i,ii,iii,iiii)]';end
                try AERODATA.Cx(i,ii,iii,iiii)=  Cxyz(1,1); end 
                try AERODATA.Cy(i,ii,iii,iiii)=  Cxyz(2,1);  end; 
                try AERODATA.Cz(i,ii,iii,iiii)=  Cxyz(3,1);  end; 
            
%% Extra parameter (not define in theCPACS shema jet)
                try 
                    AERODATA.CD0(i,ii,iii,iiii)  =   cD0(1,count);  
                end            
                       
%% Damping derivatives

                try AERODATA.CDp(i,ii,iii,iiii) = dcfxdp(1,count);  end;
                try AERODATA.CDq(i,ii,iii,iiii) = dcfxdr(1,count);  end;
                try AERODATA.CDr(i,ii,iii,iiii) = dcfxdq(1,count);  end;

                try AERODATA.CCp(i,ii,iii,iiii) = dcfydp(1,count);  end;
                try AERODATA.CCq(i,ii,iii,iiii) = dcfydq(1,count);  end;
                try AERODATA.CCr(i,ii,iii,iiii) = dcfydr(1,count);  end;

                try AERODATA.CLp(i,ii,iii,iiii) = dcfzdp(1,count);  end;
                try AERODATA.CLq(i,ii,iii,iiii) = dcfzdq(1,count);  end;
                try AERODATA.CLr(i,ii,iii,iiii) = dcfzdr(1,count);  end;
                
                % Transformation from Aircraft fix to Global {G} 
                try Cxyzp=f2aTransform*[AERODATA.CDp(i,ii,iii,iiii),AERODATA.CCp(i,ii,iii,iiii),AERODATA.CLp(i,ii,iii,iiii)]';end
                try Cxyzq=f2aTransform*[AERODATA.CDq(i,ii,iii,iiii),AERODATA.CCq(i,ii,iii,iiii),AERODATA.CLq(i,ii,iii,iiii)]';end
                try Cxyzr=f2aTransform*[AERODATA.CDr(i,ii,iii,iiii),AERODATA.CCr(i,ii,iii,iiii),AERODATA.CLr(i,ii,iii,iiii)]';end
                
                try AERODATA.Cxp(i,ii,iii,iiii) = Cxyzp(1,1);  end;
                try AERODATA.Cxq(i,ii,iii,iiii) = Cxyzq(1,1);  end;
                try AERODATA.Cxr(i,ii,iii,iiii) = Cxyzr(1,1);  end;

                try AERODATA.Cyp(i,ii,iii,iiii) = Cxyzp(2,1);  end;
                try AERODATA.Cyq(i,ii,iii,iiii) = Cxyzq(2,1);  end;
                try AERODATA.Cyr(i,ii,iii,iiii) = Cxyzr(2,1);  end;

                try AERODATA.Czp(i,ii,iii,iiii) = Cxyzp(3,1);  end;
                try AERODATA.Czq(i,ii,iii,iiii) = Cxyzq(3,1);  end;
                try AERODATA.Czr(i,ii,iii,iiii) = Cxyzr(3,1);  end;

                try AERODATA.Clp(i,ii,iii,iiii) = dcmxdr(1,count);  end;
                try AERODATA.Clq(i,ii,iii,iiii) = dcmxdp(1,count);  end;
                try AERODATA.Clr(i,ii,iii,iiii) = dcmxdq(1,count);  end;

                try AERODATA.Cmp(i,ii,iii,iiii) = dcmydp(1,count);  end;
                try AERODATA.Cmq(i,ii,iii,iiii) = dcmydq(1,count);  end;
                try AERODATA.Cmr(i,ii,iii,iiii) = dcmydr(1,count);  end;

                try AERODATA.Cnp(i,ii,iii,iiii) = dcmzdp(1,count);  end;
                try AERODATA.Cnq(i,ii,iii,iiii) = dcmzdq(1,count);  end;
                try AERODATA.Cnr(i,ii,iii,iiii) = dcmzdr(1,count);  end;
                
            end
        end
    end
end

 
%% CS Derivative array

try
    for csNum=1:maxCsNum  
        try AERODATA.dnames{csNum}=cs{csNum,1}.controlSurfaceUID; catch AERODATA.dnames{csNum}=csNum; end; 
        count=0;
        for iii=1:size(machNumberVec,2) 
            for iiii=1:size(reynoldsNumberVec,2) 
                for ii=1:size(angleOfYawVec,2)
                    for i=1:size(angleOfAttackVec,2)                   
                        
                        for iiiii=1:size(cs{csNum,1}.relDeflectionCS,2)   
                            count=count+1;
                            try AERODATA.relCsDefl(iiiii,csNum) = cs{csNum,1}.relDeflectionCS(1,iiiii); end;
                            try AERODATA.absCsDefl(iiiii,csNum) = cs{csNum,1}.absDeflectionCS(1,iiiii); end
                            
                            try AERODATA.CDd(i,ii,iii,iiii,iiiii,csNum) = cs{csNum,1}.dcfx(1,count);        end; 
                            try AERODATA.CCd(i,ii,iii,iiii,iiiii,csNum) = cs{csNum,1}.dcfy(1,count);        end; 
                            try AERODATA.CLd(i,ii,iii,iiii,iiiii,csNum) = cs{csNum,1}.dcfz(1,count);        end; 
                            
                            % Transformation from Aircraft fix to Global{G} 
                            try Cxyzd=f2aTransform*[AERODATA.CDd(i,ii,iii,iiii,iiiii,csNum) ,AERODATA.CCd(i,ii,iii,iiii,iiiii,csNum) ,AERODATA.CLd(i,ii,iii,iiii,iiiii,csNum)]';end                            
                            try AERODATA.Cxd(i,ii,iii,iiii,iiiii,csNum) = Cxyzd(1,1);        end; 
                            try AERODATA.Cyd(i,ii,iii,iiii,iiiii,csNum) = Cxyzd(2,1);        end; 
                            try AERODATA.Czd(i,ii,iii,iiii,iiiii,csNum) = Cxyzd(3,1);        end; 
                            
                            try AERODATA.Cld(i,ii,iii,iiii,iiiii,csNum) = cs{csNum,1}.dcmx(1,count);        end; 
                            try AERODATA.Cmd(i,ii,iii,iiii,iiiii,csNum) = cs{csNum,1}.dcmy(1,count);        end; 
                            try AERODATA.Cnd(i,ii,iii,iiii,iiiii,csNum) = cs{csNum,1}.dcmz(1,count);        end;
                        end
                    end
                end
            end
        end
    end
end




%% Alpha and Betha Gradients   

for iii=1:size(machNumberVec,2)
    for iiii=1:size(reynoldsNumberVec,2) 
        for ii=1:size(angleOfYawVec,2)
            for i=1:size(angleOfAttackVec,2)           
           
                % Calc Alpha Gradients
                try
                    if i==1
                        AERODATA.CDa(i,ii,iii,iiii)   =        (AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        AERODATA.CCa(i,ii,iii,iiii)   =        (AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        AERODATA.CLa(i,ii,iii,iiii)   =        (AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        
                        AERODATA.Cxa(i,ii,iii,iiii)   =        (AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        AERODATA.Cya(i,ii,iii,iiii)   =        (AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        AERODATA.Cza(i,ii,iii,iiii)   =        (AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        
                        AERODATA.Cla(i,ii,iii,iiii)   =        (AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        AERODATA.Cma(i,ii,iii,iiii)   =        (AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                        AERODATA.Cna(i,ii,iii,iiii)   =        (AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));
                    elseif i==size(angleOfAttackVec,2)                  
                        AERODATA.CDa(i,ii,iii,iiii)   =        (AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1));
                        AERODATA.CCa(i,ii,iii,iiii)   =        (AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1));
                        AERODATA.CLa(i,ii,iii,iiii)   =        (AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1));
                        
                        AERODATA.Cxa(i,ii,iii,iiii)   =        (AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1));  
                        AERODATA.Cya(i,ii,iii,iiii)   =        (AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        AERODATA.Cza(i,ii,iii,iiii)   =        (AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        
                        AERODATA.Cla(i,ii,iii,iiii)   =        (AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        AERODATA.Cma(i,ii,iii,iiii)   =        (AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        AERODATA.Cna(i,ii,iii,iiii)   =        (AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                    else  
                        s1=(AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.CDa(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant 
                        
                        s1=(AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.CCa(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant 
                        
                        s1=(AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.CLa(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant                         
                        
                        s1=(AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.Cxa(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant 

                        s1=(AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.Cya(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.Cza(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.Cla(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.Cma(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i-1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i-1)); 
                        s2=(AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i+1,ii,iii,iiii))/(AERODATA.alpharange(1,i)-AERODATA.alpharange(1,i+1));                 
                        AERODATA.Cna(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant
                    end
                end


                % Calc Betha Gradients
                try
                    if ii==1
                        AERODATA.CDb(i,ii,iii,iiii)   =        (AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        AERODATA.CCb(i,ii,iii,iiii)   =        (AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        AERODATA.CLb(i,ii,iii,iiii)   =        (AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        
                        AERODATA.Cxb(i,ii,iii,iiii)   =        (AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        AERODATA.Cyb(i,ii,iii,iiii)   =        (AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        AERODATA.Czb(i,ii,iii,iiii)   =        (AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        
                        AERODATA.Clb(i,ii,iii,iiii)   =        (AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        AERODATA.Cmb(i,ii,iii,iiii)   =        (AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        AERODATA.Cnb(i,ii,iii,iiii)   =        (AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));
                        
                    elseif ii==size(angleOfYawVec,2)      
                        AERODATA.CDb(i,ii,iii,iiii)   =        (AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1));
                        AERODATA.CCb(i,ii,iii,iiii)   =        (AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1));
                        AERODATA.CLb(i,ii,iii,iiii)   =        (AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1));
                        
                        AERODATA.Cxb(i,ii,iii,iiii)   =        (AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1));  
                        AERODATA.Cyb(i,ii,iii,iiii)   =        (AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        AERODATA.Czb(i,ii,iii,iiii)   =        (AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        
                        AERODATA.Clb(i,ii,iii,iiii)   =        (AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        AERODATA.Cmb(i,ii,iii,iiii)   =        (AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        AERODATA.Cnb(i,ii,iii,iiii)   =        (AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        
                    else                           
                        s1=(AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.CD(i,ii,iii,iiii)-AERODATA.CD(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.CDb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant 
                        
                        s1=(AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.CC(i,ii,iii,iiii)-AERODATA.CC(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.CCb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant 
                        
                        s1=(AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.CL(i,ii,iii,iiii)-AERODATA.CL(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.CLb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant  
                        
                        s1=(AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.Cx(i,ii,iii,iiii)-AERODATA.Cx(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.Cxb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant 

                        s1=(AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.Cy(i,ii,iii,iiii)-AERODATA.Cy(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.Cyb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.Cz(i,ii,iii,iiii)-AERODATA.Cz(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.Czb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.Cl(i,ii,iii,iiii)-AERODATA.Cl(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.Clb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.Cm(i,ii,iii,iiii)-AERODATA.Cm(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.Cmb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant

                        s1=(AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i,ii-1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii-1)); 
                        s2=(AERODATA.Cn(i,ii,iii,iiii)-AERODATA.Cn(i,ii+1,iii,iiii))/(AERODATA.betarange(1,ii)-AERODATA.betarange(1,ii+1));                 
                        AERODATA.Cnb(i,ii,iii,iiii)  =  (s1+s2)/2; % Mean Gradiant
                    end
                end
            end
        end
    end
end




%% Referece values

AERODATA.S = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.area{1,1}.CONTENT)';
AERODATA.c = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.length{1,1}.CONTENT)'; 
AERODATA.refPoint(1,1) = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.point{1,1}.x{1,1}.CONTENT)'; 
AERODATA.refPoint(1,2) = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.point{1,1}.y{1,1}.CONTENT)'; 
AERODATA.refPoint(1,3) = str2num(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.point{1,1}.z{1,1}.CONTENT)'; 

%% Save data under analysis

% if size(Aab,2)*size(Ayb,2)*size(Mab,2)>1
%     analysis.parameterSweep.AERODATA = AERODATA;
% else
%     analysis.AERODATA = AERODATA;
% end


