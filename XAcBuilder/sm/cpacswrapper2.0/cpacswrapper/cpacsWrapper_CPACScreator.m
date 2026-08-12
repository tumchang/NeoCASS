function [CPACSgeo,CPACS_XML]=cpacsWrapper_CPACScreator(file,CPACS_XML)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Read CPACS                                                            %
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0b                                                  %
% LastModified:     2010-04-07 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
% Note:             Subfunction 'readwings' based on 'readgeomety'        %
%                   written by Felix Dorbath                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%       - fill the rest functions
%       - Landiggear ist noch nicht ausreichend in CPACS definiert und
%         muss hier noch angepasst werden.
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: cpacsWrapper_ACbuilder add trailing edge devices to CPACSgeo
% for simplicity and consistency of the whole code -- by Pengfei

%% Settings
warning off
initialize

%% Read XML

% disp('read XML ... ')
% CPACS_TXT = fileread(path);
% CPACS_XML = xml_parseany(CPACS_TXT);

if nargin==1
    disp('read XML ... ')
    [cpacs] = xml2struct(file);
    CPACS_XML=cpacs.cpacs{1,1};
end

%% Version Number

% CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT='2.0';
% disp(['CPACS Version Hard Coded !!!'])
try
    disp(['CPACS Version ',CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT])
catch
    version=questdlg('No CPACS Version Number Found! Chose CPACS version','Chose CPACS version','CPACS 2.0','Older than 2.0','default') ;
    
    if strcmp(version,'CPACS 2.0')
        CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT='2.0';
    else
        CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT='1.6';
    end
end

% Differences to XML-Toolbox
%   CONTENT     <-- Text
%   ATTRIBUTE   <-- Attributes

%% Under Functions
%%      Aircraft

% % Read Wings (and References)
[CPACSgeo]=readwings(CPACS_XML);

% Read Fuselage
[CPACSgeo]=readfuselage(CPACS_XML,CPACSgeo);

% Read Engine
[CPACSgeo]=readengine(CPACS_XML,CPACSgeo);

% Read Landinggear
[CPACSgeo]=readlg(CPACS_XML,CPACSgeo);

% Read Weight
[CPACSgeo]=readweight(CPACS_XML,CPACSgeo);

% Read CG
[CPACSgeo]=readCG(CPACS_XML,CPACSgeo);

% Read Inertial
[CPACSgeo]=readI(CPACS_XML,CPACSgeo);

%%      Analysis

% Read Load Cases
[CPACSgeo]=readLoadCase(CPACS_XML,CPACSgeo);

% Read State
[CPACSgeo]=readState(CPACS_XML,CPACSgeo);

% Read Results
[CPACSgeo]=readResults(CPACS_XML,CPACSgeo);

%% End

disp('readgeo abgeschlossen')

%% Save

% save('CPACSgeo','CPACSgeo')

%% Setting

warning on

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                       - Sub Functions -                               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                           - Aircraft -                                %%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         - Read Wings -                                %%
function [CPACSgeo]=readwings(CPACS_XML)

% Output Struct definition
CPACSgeo={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run Outer Surface Wrapper %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

componentTypeName='wings';
[CPACSgeo]=cpacsGeoReader(CPACS_XML,CPACSgeo,componentTypeName);
CPACSgeo.aircraftName=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT;

%%%%%%%%%%%%%%%%%%%
% controlSurfaces %
%%%%%%%%%%%%%%%%%%%

% ToDo
% - absolut positions having regard to Segments
% - Leading edge devises, spoilers

comSize=size(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing,2);
%comSize=1;
componentTypeName='wings';

for compNum=1:comSize
    clear ContStructgeo sparsRibsgeo  sparsRibs_Struct contSurf_Struct
    
    component{1,1} = CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing{1,compNum};
    % ContStruct.trailingEdgeDevices={};
    
    %% Control Surfacses
    try
        numOfcompSeg = length(component{1,1}.componentSegments{1,1}.componentSegment);
        for compSegNum = 1: numOfcompSeg                                              % Just in case in the future more componentSegment may be applied.
            
            compSeg_Struct =  component{1,1}.componentSegments{1,1}.componentSegment{1,compSegNum};
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % trailingEdgeDevices %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            %         if isfield(compSeg_Struct, 'controlSurfaces')
            %             disp('reading controlSurfaces')
            %             TEDs_Struct = compSeg_Struct.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice;
            %             [TEDs_geo] = readControlSurfs(TEDs_Struct);
            %             CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.controlSurfaces.TEDs = TEDs_geo;
            %         end
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % Spars and Ribs %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            %         if isfield(compSeg_Struct, 'structure')
            %             disp('reading strctures')
            %             sparsRibs_Struct =  compSeg_Struct.structure{1,1};
            %             [sparsRibsgeo] = readSparsRibs(sparsRibs_Struct);
            %             CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.structure = sparsRibsgeo;
            %         end
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % wingFuelTanks %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            %             if isfield(compSeg_Struct, 'wingFuelTanks')
            %                wingFT_Struct = compSeg_Struct.wingFuelTanks{1,1};
            %                [wingFTgeo] = readFuelTanks(wingFT_Struct);
            %             end
            
            %%%%%%%%%%%%%%%%%%%%%%
            % leadingEdgeDevices %
            %%%%%%%%%%%%%%%%%%%%%%
            
            %numOfLED=size(controlSurfaces{1,1}.leadingEdgeDevices{1,1}.leadingEdgeDevice,2);
            %controlSurfaces{1,1}.leadingEdgeDevices;
            
            
            %%%%%%%%%%%%
            % spoilers %
            %%%%%%%%%%%%
            
            %numOfSpD=size(controlSurfaces{1,1}.spoilers{1,1}.spoiler,2);
            %controlSurfaces{1,1}.spoilers;
            
            
            
            CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.uID = compSeg_Struct.ATTRIBUTE.uID;
            CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.name = compSeg_Struct.name;
            CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.fromElementUID = compSeg_Struct.fromElementUID;
            CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.toElementUID = compSeg_Struct.toElementUID;
        end
        
        %     CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.wingFuelTanks = wingFTgeo;
        
    end
    
    disp(['The ',componentTypeName,' ',num2str(compNum) ,' has no control devices'])
end


%%%%%%%%%%%%%%
% references %
%%%%%%%%%%%%%%

reference=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference;
CPACSgeo.ref.area=reference{1,1}.area{1,1}.CONTENT;
CPACSgeo.ref.length=reference{1,1}.length{1,1}.CONTENT;
try
    CPACSgeo.ref.point(1,1)=str2num(reference{1,1}.point{1,1}.x{1,1}.CONTENT);
    CPACSgeo.ref.point(1,2)=str2num(reference{1,1}.point{1,1}.y{1,1}.CONTENT);
    CPACSgeo.ref.point(1,3)=str2num(reference{1,1}.point{1,1}.z{1,1}.CONTENT);
catch
    CPACSgeo.ref.point(1,1)=0;
    CPACSgeo.ref.point(1,2)=0;
    CPACSgeo.ref.point(1,3)=0;
    warning('No refpoint define in cpacs')
end

% %Calc References
% for compNum=1:size(CPACSgeo.wings.component)
%     area=[];
%     loacalSpan=[];
%     for n=1:size(CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys)-1
%         chordVec1=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n,1}*[1;0;0];
%         chordVec2=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n+1,1}*[1;0;0];
%         chordLenth1=sqrt(chordVec1(1,1)^2+chordVec1(2,1)^2+chordVec1(3,1)^2);
%         chordLenth2=sqrt(chordVec2(1,1)^2+chordVec2(2,1)^2+chordVec2(3,1)^2);
%         spVec=CPACSgeo.wings.component{compNum,1}.sectionDef.point{n+1,1}-CPACSgeo.wings.component{compNum,1}.sectionDef.point{n,1};
%         loacalSpan(n,1)=sqrt(spVec(2,1)^2+spVec(3,1)^2);
%         area(n,1)=loacalSpan(n,1)*(chordLenth1+chordLenth2)/2;
%     end
%     if CPACSgeo.wings.component{compNum,1}.symmetry
%         compArea(compNum,1)=sum(area)*2;
%         compSpan(compNum,1)=sum(loacalSpan)*2;
%     else
%         compArea(compNum,1)=sum(area);
%         compSpan(compNum,1)=sum(loacalSpan);
%     end
% end
%
% CPACSgeo.ref.span=compSpan;

%Calc References
for compNum=1:size(CPACSgeo.wings.component)
    area=[];
    loacalSpan=[];
    for n=1:size(CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys)-1
        chordVec1=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n,1}*[1;0;0];
        chordVec2=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n+1,1}*[1;0;0];
        chordLenth1=sqrt(chordVec1(1,1)^2+chordVec1(2,1)^2+chordVec1(3,1)^2);
        chordLenth2=sqrt(chordVec2(1,1)^2+chordVec2(2,1)^2+chordVec2(3,1)^2);
        spVec=CPACSgeo.wings.component{compNum,1}.sectionDef.point{n+1,1}-CPACSgeo.wings.component{compNum,1}.sectionDef.point{n,1};
        loacalSpan(n,1)=sqrt(spVec(2,1)^2+spVec(3,1)^2);
        area(n,1)=loacalSpan(n,1)*(chordLenth1+chordLenth2)/2;
    end
    if CPACSgeo.wings.component{compNum,1}.symmetry
        compArea(compNum,1)=sum(area)*2;
        compSpan(compNum,1)=sum(loacalSpan)*2;
    else
        compArea(compNum,1)=sum(area);
        compSpan(compNum,1)=sum(loacalSpan);
    end
    
    CPACSgeo.wings.component{compNum,1}.compSpan = compSpan(compNum,1);
    CPACSgeo.wings.component{compNum,1}.compArea = compArea(compNum,1);
    CPACSgeo.wings.component{compNum,1}.localSpan = loacalSpan;
    CPACSgeo.wings.component{compNum,1}.halfSpan = compSpan(compNum,1)/2;
  %   CPACSgeo.wings.component{compNum,1}.sectionDef.localSpan = loacalSpan;
end

CPACSgeo.ref.span=compSpan;

clear('-regexp','[^CPACS_TXT,^CPACS_XML,^path,^UIDwings,^CPACSgeo]*');

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         - Read Fuselage -                             %%
function [CPACSgeo]=readfuselage(CPACS_XML,CPACSgeo)

try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Run Outer Surface Wrapper %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    componentTypeName='fuselages';
    [CPACSgeo]=cpacsGeoReader(CPACS_XML,CPACSgeo,componentTypeName);
    
    for fusNum=1:length(CPACSgeo.fuselages.component)
        for i=1:length( CPACSgeo.fuselages.component{fusNum,1}.sectionDef.point)
            
            airfoil=CPACSgeo.fuselages.component{fusNum,1}.sectionDef.airfoil;
            % Calculation of each area with profile geometrie and scaling
            [geom] = polygeom(airfoil{i,1}(:,2),airfoil{i,1}(:,3));
            sec_area(1,i)=geom(1,1);
            
            xpos(i,1)=CPACSgeo.fuselages.component{fusNum,1}.sectionDef.point{i,1}(1,1);
            
            
        end
        % Alternate Diameter
        d_alt=sqrt(max(sec_area)/pi)*2;
        fuselage.d    = d_alt;
        % Fuselage Length
        fuselage.l    = max(xpos)-min(xpos);
        
        
        CPACSgeo.fuselages.component{fusNum,1}.diameter=fuselage.d;
        CPACSgeo.fuselages.component{fusNum,1}.length=fuselage.l;
    end
catch
    disp('read CPACSgeo: Non Fuselage ')
end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         - Read Engines -                              %%
function [CPACSgeo]=readengine(CPACS_XML,CPACSgeo)

try
    % Aircraft Engiens
    aircraftEngine=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines;
    
    for i=1:length(aircraftEngine{1,1}.engine)
        % Engine position
        x=str2num(aircraftEngine{1,1}.engine{1,i}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
        y=str2num(aircraftEngine{1,1}.engine{1,i}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
        try z=str2num(aircraftEngine{1,1}.engine{1,i}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);catch; z=0; end
        CPACSgeo.engine.pos(i,:)=[x,y,z];
        % Symmetrie
        if isfield(aircraftEngine{1,1}.engine{1,i}.ATTRIBUTE,'symmetry')
            CPACSgeo.engine.sym(i,1)=1;                                          %-> include information about Symetrie
        else
            CPACSgeo.engine.sym(i,1)=0;
        end
        
        try
            aircraftEngineUID{1,i}=aircraftEngine{1,1}.engine{1,i}.engineUID{1,1}.CONTENT;
        catch
            aircraftEngineUID{1,i}='';
            warning('readCPACS: no specific Engine UID')
        end
    end
    
    % Select Engine fom Pool
    UIDnumber=[];
    try
        engines=CPACS_XML.vehicles{1,1}.engines;
        for i=1:length(CPACS_XML.vehicles{1,1}.engines{1,1}.engine)
            engineUID{1,i}=engines{1,1}.engine{1,i}.ATTRIBUTE.uID;
            for ii=1:length(aircraftEngine)
                if ~isempty(aircraftEngineUID{1,ii})
                    if ~isempty(findstr(engineUID{1,i}(1,:),aircraftEngineUID{1,ii}(1,:)))
                        UIDnumber(ii,1)=i;
                    end
                end
            end
        end
    catch
        warning('readCPACS: no selection of Engine fom Pool')
    end
catch
    UIDnumber=[];
end

% Select the Engine Data
if ~isempty(UIDnumber)
    for i=1:length(aircraftEngine)
        % Engine Name
        try CPACSgeo.engine.name{i,1} = engines{1,1}.engine{1,UIDnumber(i,1)}.name{1,1}.CONTENT;end
        % Static Thrust
        if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<2
            try CPACSgeo.engine.T_0(i,1)  = str2num(engines{1,1}.engine{1,UIDnumber(i,1)}.global{1,1}.thrust00{1,1}.CONTENT); end
        else %CPACS VERSION 2.0
            try CPACSgeo.engine.T_0(i,1)  = str2num(engines{1,1}.engine{1,UIDnumber(i,1)}.analysis{1,1}.thrust00{1,1}.CONTENT); end
        end
    end
else
    warning('no correct Engine find in Engine Pool')
    CPACSgeo.engine={};
end
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         - Read Landinggear -                          %%
function [CPACSgeo]=readlg(CPACS_XML,CPACSgeo)

k=1;

% Nose Landingear
try
    landingGear=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.landingGear;
    noseGears=landingGear{1,1}.noseGears;
    
    for i=1:length(noseGears{1,1}.noseGear)
        % Landingger Piston Length
        CPACSgeo.lg.length(k,1)=noseGears{1,1}.noseGear{1,i}.totalLength;
        
        % Landinggear Position (her the positionon is defined as groud
        % tutch point !)
        x = str2num(noseGears{1,1}.noseGear{1,i}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
        y = str2num(noseGears{1,1}.noseGear{1,i}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
        z = str2num(noseGears{1,1}.noseGear{1,i}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);
        CPACSgeo.lg.pos(k,:)=[x,y,z];
        k=k+1;
        % ... ?
    end
    
catch
    warning('no nose Landinggear defined in CPACSgeo')
    CPACSgeo.lg={};
end

% Main Landingear
try
    landingGear=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.landingGear;
    mainGears=landingGear{1,1}.mainGears;
    
    
    for i=1:length(mainGears{1,1}.mainGear)
        % Landingger Piston Length
        CPACSgeo.lg.length(k,1)=mainGears{1,1}.mainGear{1,i}.totalLength;
        
        % Landinggear Position (her the positionon is defined as groud
        % tutch point !)
        x = str2num(mainGears{1,1}.mainGear{1,i}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
        y = str2num(mainGears{1,1}.mainGear{1,i}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
        z = str2num(mainGears{1,1}.mainGear{1,i}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);
        CPACSgeo.lg.pos(k,:)=[x,y,z];
        k=k+1;
        % ... ?
    end
    
catch
    warning('no main Landinggear defined in CPACSgeo')
    CPACSgeo.lg={};
end



end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         - Read Weight -                               %%
function [CPACSgeo]=readweight(CPACS_XML,CPACSgeo)

weight={};
try
    globalCPACS=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.global;
    massBreakdown =CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.massBreakdown;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for old CPACSgeo visions %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % form massBreakdown
    % TakeOff mass
    try; weight.mTOM(1,1)=str2num(massBreakdown{1,1}.mTOM{1,1}.massDescription{1,1}.mass{1,1}.CONTENT);end
    % OperatingEmptyMass
    try; weight.mOEM(1,1)=str2num(massBreakdown{1,1}.mTOM{1,1}.mZeroFuel{1,1}.oEM{1,1}.massDescription{1,1}.mass{1,1}.CONTENT);end
    % ZeroFuelMass
    try; weight.mZFM(1,1)=str2num(massBreakdown{1,1}.mTOM{1,1}.mZeroFuel{1,1}.massDescription{1,1}.mass{1,1}.CONTENT);end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % For new CPACSgeo visions (1.6) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % form massBreakdown
    % OperatingEmptyMass
    try; weight.mOEM(1,1)    = str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.mass{1,1}.CONTENT);end
    % Pyload
    try; weight.payload(1,1) = str2num(massBreakdown{1,1}.payload{1,1}.massDescription{1,1}.mass{1,1}.CONTENT);end
    % Fuel
    try; weight.fuel(1,1)    = str2num(massBreakdown{1,1}.fuel{1,1}.massDescription{1,1}.mass{1,1}.CONTENT);end
    % TakeOff mass
    try; weight.mTOM(1,1)    = str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.mass{1,1}.CONTENT);end
    % ZeroFuelMass
    try; weight.mZFM(1,1)    = str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.mass{1,1}.CONTENT);end
    % maximum Laning Mass
    try; weight.mMLM(1,1)     = str2num(massBreakdown{1,1}.designMasses{1,1}.mMLM{1,1}.mass{1,1}.CONTENT);end
    % maximum Ramp Mass
    try; weight.mMRM(1,1)     = str2num(massBreakdown{1,1}.designMasses{1,1}.mMRM{1,1}.mass{1,1}.CONTENT);end
    % maximum Fuel Mass
    try; weight.mFM(1,1)     = str2num(massBreakdown{1,1}.designMasses{1,1}.mFM{1,1}.mass{1,1}.CONTENT);end
    
catch
    warning('no Weight defined in CPACSgeo')
end

CPACSgeo.weight=weight;

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         - Read CG -                                   %%
function [CPACSgeo]=readCG(CPACS_XML,CPACSgeo)

% Design CGs
try
    massBreakdown =CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.massBreakdown;
    % TakeOff mass CG location (Design CG)
    try CPACSgeo.CG.mTOM(1,1)=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.location{1,1}.x{1,1}.CONTENT);     catch;  CPACSgeo.CG.mTOM(1,1)=0; warning('readCPACS: CG.mTOM x set 0'); end
    try CPACSgeo.CG.mTOM(2,1)=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.location{1,1}.y{1,1}.CONTENT);     catch;  CPACSgeo.CG.mTOM(2,1)=0; warning('readCPACS: CG.mTOM y set 0'); end
    try CPACSgeo.CG.mTOM(3,1)=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.location{1,1}.z{1,1}.CONTENT);     catch;  CPACSgeo.CG.mTOM(3,1)=0; warning('readCPACS: CG.mTOM z set 0'); end
    % OperatingEmptyMass CG location
    try CPACSgeo.CG.mOEM(1,1)=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.location{1,1}.x{1,1}.CONTENT);  catch;  CPACSgeo.CG.mOEM(1,1)=0; warning('readCPACS: CG.oEM x set 0'); end;
    try CPACSgeo.CG.mOEM(2,1)=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.location{1,1}.y{1,1}.CONTENT);  catch;  CPACSgeo.CG.mOEM(2,1)=0; warning('readCPACS: CG.oEM y set 0'); end;
    try CPACSgeo.CG.mOEM(3,1)=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.location{1,1}.z{1,1}.CONTENT);  catch;  CPACSgeo.CG.mOEM(3,1)=0; warning('readCPACS: CG.oEM z set 0'); end;
    % ZeroFuelMass CG location (Design CG)
    try CPACSgeo.CG.mZFM(1,1)=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.location{1,1}.x{1,1}.CONTENT); catch;  CPACSgeo.CG.mZFM(1,1)=0; warning('readCPACS: CG.mZFM x set 0'); end;
    try CPACSgeo.CG.mZFM(2,1)=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.location{1,1}.y{1,1}.CONTENT); catch;  CPACSgeo.CG.mZFM(2,1)=0; warning('readCPACS: CG.mZFM y set 0'); end;
    try CPACSgeo.CG.mZFM(3,1)=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.location{1,1}.z{1,1}.CONTENT); catch;  CPACSgeo.CG.mZFM(3,1)=0; warning('readCPACS: CG.mZFM z set 0'); end;
catch
    warning('no CG location defined in CPACSgeo')
end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         - Read Inertial  -                            %%
function [CPACSgeo]=readI(CPACS_XML,CPACSgeo)


try
    massBreakdown =CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.massBreakdown;
    % TakeOff mass Moment of inertia
    CPACSgeo.J.mTOM.Jxx=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.massInertia{1,1}.Jxx{1,1}.CONTENT);
    CPACSgeo.J.mTOM.Jyy=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.massInertia{1,1}.Jyy{1,1}.CONTENT);
    CPACSgeo.J.mTOM.Jzz=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.massInertia{1,1}.Jzz{1,1}.CONTENT);
    CPACSgeo.J.mTOM.Jxy=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.massInertia{1,1}.Jxy{1,1}.CONTENT);
    CPACSgeo.J.mTOM.Jxz=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.massInertia{1,1}.Jxz{1,1}.CONTENT);
    CPACSgeo.J.mTOM.Jyz=str2num(massBreakdown{1,1}.designMasses{1,1}.mTOM{1,1}.massInertia{1,1}.Jyz{1,1}.CONTENT);
    
    % OperatingEmptyMass Moment of inertia
    CPACSgeo.J.mOEM.Jxx=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.massInertia{1,1}.Jxx{1,1}.CONTENT);
    CPACSgeo.J.mOEM.Jyy=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.massInertia{1,1}.Jyy{1,1}.CONTENT);
    CPACSgeo.J.mOEM.Jzz=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.massInertia{1,1}.Jzz{1,1}.CONTENT);
    CPACSgeo.J.mOEM.Jxy=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.massInertia{1,1}.Jxy{1,1}.CONTENT);
    CPACSgeo.J.mOEM.Jxz=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.massInertia{1,1}.Jxz{1,1}.CONTENT);
    CPACSgeo.J.mOEM.Jyz=str2num(massBreakdown{1,1}.mOEM{1,1}.massDescription{1,1}.massInertia{1,1}.Jyz{1,1}.CONTENT);
    
    % ZeroFuelMass Moment of inertia
    CPACSgeo.J.mZFM.Jxx=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.massInertia{1,1}.Jxx{1,1}.CONTENT);
    CPACSgeo.J.mZFM.Jyy=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.massInertia{1,1}.Jyy{1,1}.CONTENT);
    CPACSgeo.J.mZFM.Jzz=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.massInertia{1,1}.Jzz{1,1}.CONTENT);
    CPACSgeo.J.mZFM.Jxy=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.massInertia{1,1}.Jxy{1,1}.CONTENT);
    CPACSgeo.J.mZFM.Jxz=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.massInertia{1,1}.Jxz{1,1}.CONTENT);
    CPACSgeo.J.mZFM.Jyz=str2num(massBreakdown{1,1}.designMasses{1,1}.mZFM{1,1}.massInertia{1,1}.Jyz{1,1}.CONTENT);
    
catch
    warning('no Inertia defined in CPACSgeo')
    CPACSgeo.J={};
end

end%function

%%                                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - Analysis -                              %%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - Load Case -                             %%
function [CPACSgeo]=readLoadCase(CPACS_XML,CPACSgeo)

try
    % Load Case
    loadCases=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.loadCases;
    for i=1:length(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.loadCases{1,1}.loadCase)
        % Load Case from Aircraft
        CPACSgeo.loadCase.uID{i,1} = loadCases{1,1}.loadCase{1,1}.ATTRIBUTE.uID;
        totalCoefficients{i,1}  = loadCases{1,1}.loadCase{1,1}.totalCoefficients;
        flow{i,1}               = loadCases{1,1}.loadCase{1,1}.flow;
        
        % Load Case from Lifting Line
        %CPACSgeo.loadCase.uID=CPACS_XML.toolspecific{1,1}.liftingLine{1,1}.loadCases{1,1}.loadCaseUID{1,i};
    end
catch
    warning('no Load Case defined in CPACSgeo')
end

try
    % Flight Case
    flightDynamics=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.global{1,1}.flightDynamics;
    for i=1:lenght(flightDynamics{1,1}.flightCase)
        CPACSgeo.flightCase.standardAltitude(i,1)   = flightDynamics{1,1}.flightCase{1,i}.standardAltitude{1,1}.CONTENT;
        CPACSgeo.flightCase.vCAS(i,1)               = flightDynamics{1,1}.flightCase{1,i}.vCAS{1,1}.CONTENT;
        CPACSgeo.flightCase.configuration(i,1)      = flightDynamics{1,1}.flightCase{1,i}.configuration; %!
        CPACSgeo.flightCase.gear(i,1)               = flightDynamics{1,1}.flightCase{1,i}.gear; %!
    end
catch
    warning('no Flight Case defined in CPACSgeo')
end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - State -                                 %%
function [CPACSgeo]=readState(CPACS_XML,CPACSgeo)

% Singel Run Paramenter
state={};
state.AS=100;
state.alpha=0;
state.betha=0;
state.P=0;
state.Q=0;
state.R=0;
state.ALT=10000;
state.rho=1.225;
state.pgcorr=1;

% Data From CPACS Toospecifics (Only for a singl runTonado)
try;state.AS    = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.airspeed{1,1}.CONTENT);end
try;state.alpha = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.angleOfAttack{1,1}.CONTENT);end
try;state.betha = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.angleOfYaw{1,1}.CONTENT);end
try;state.P     = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.p{1,1}.CONTENT);end
try;state.Q     = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.q{1,1}.CONTENT);end
try;state.R     = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.r{1,1}.CONTENT);end
try;state.rho   = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.rho{1,1}.CONTENT);end
try;state.ALT   = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.state{1,1}.altitude{1,1}.CONTENT);end
try;state.pgcorr = str2num(CPACS_XML.toolspecific{1,1}.tornado{1,1}.toolParameters{1,1}.prandtlGlauertCorrection{1,1}.CONTENT);end


% Load Altitude
[rho,a,p,mu,T]=ISA(state.ALT);

% Calc Mach Number
state.Ma=state.AS/a;

% Constand State Parameter
analysis.parameterSweep.state=state;

homeDir=pwd;
% Load Aerodata from CPACS (used in runTornadoSweep)
try
    [AERODATA]=aeroDataFromCpacs(CPACS_XML);
    analysis.parameterSweep.AERODATA = AERODATA;
    
    % Pramaeter Sweep only for: Airspeed, alpha, betha (each must have a value)
    analysis.parameterSweep.state.AS    = analysis.parameterSweep.AERODATA.TASrange;
    analysis.parameterSweep.state.alpha = analysis.parameterSweep.AERODATA.alpharange;
    analysis.parameterSweep.state.betha = analysis.parameterSweep.AERODATA.betarange;
    analysis.parameterSweep.state.Ma    = analysis.parameterSweep.AERODATA.MArange;
    try analysis.parameterSweep.state.csNames      = analysis.parameterSweep.AERODATA.dnames;    catch analysis.parameterSweep.state.csNames = {};     end;
    try analysis.parameterSweep.state.csDeflectios = analysis.parameterSweep.AERODATA.absCsDefl; catch analysis.parameterSweep.state.csDeflectios ={}; end;
    try analysis.parameterSweep.state.csRelDeflectios = analysis.parameterSweep.AERODATA.relCsDefl; catch analysis.parameterSweep.state.csDeflectios ={}; end;
catch
    warning('No sweep parameter for aerocalculation from CPACS')
end
cd(homeDir);

analysis.state=state;
CPACSgeo.analysis=analysis;

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - results -                               %%
function [CPACSgeo]=readResults(CPACS_XML,CPACSgeo)

CPACSgeo.results={};

end%function

%%                                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
function [TEDs_Geo] = readControlSurfs(TEDs_Struct)

%%%%%%%%%%%%%%%%%%%%%%%
% trailingEdgeDevices %
%%%%%%%%%%%%%%%%%%%%%%%

numOfTED=size( TEDs_Struct,2);
% TEDelt [control1 control2 ...]
TEDetaLE=ones(2,numOfTED)*NaN;
TEDetaTE=ones(2,numOfTED)*NaN;
TEDxsiLE=ones(2,numOfTED)*NaN;

%-------------------------------------------%
TEDrelHeightLE=ones(2,numOfTED)*NaN;
TEDxsiUpperSkin=ones(2,numOfTED)*NaN;
TEDxsiLowerSkin=ones(2,numOfTED)*NaN;
%-------------------------------------------%

TEDname={};
% Read from the CPACSgeo struct
for i=1:numOfTED
    % inner discription
    try TEDetaLE(1,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.innerBorder{1,1}.etaLE{1,1}.CONTENT); end
    try TEDetaTE(1,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT); end
    try
%         TEDxsiLE(1,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.innerBorder{1,1}.ksiLE{1,1}.CONTENT);
%     catch
        TEDxsiLE(1,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.innerBorder{1,1}.xsiLE{1,1}.CONTENT);
    end
    
    % outer discription
    try TEDetaLE(2,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.outerBorder{1,1}.etaLE{1,1}.CONTENT); end
    try TEDetaTE(2,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT); end
    try
%         TEDxsiLE(2,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.outerBorder{1,1}.ksiLE{1,1}.CONTENT);
%     catch
        TEDxsiLE(2,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.outerBorder{1,1}.xsiLE{1,1}.CONTENT);
    end
    
    % inner leadingEdgeShape --------------------------- %
    try TEDrelHeightLE(1,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT); end
    try TEDxsiUpperSkin(1,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT); end
    try TEDxsiLowerSkin(1,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT); end
    % -------------------------------------------------- %
    
    % outer leadingEdgeShape -------------------------- %
    try TEDrelHeightLE(2,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT); end
    try TEDxsiUpperSkin(2,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT); end
    try TEDxsiLowerSkin(2,i)=str2num(TEDs_Struct{1,i}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT); end
    % ------------------------------------------------- %
    
    % TED's path reading - innerHingePoint------------- %
    %-------------------------------------------------- %
    
    TEDhingeXsi=zeros(2,numOfTED);
    TEDhingeRelHeight=zeros(2,numOfTED);
    
    try TEDhingeXsi(1,i) = str2num(TEDs_Struct{1,i}.path{1,1}.innerHingePoint{1,1}.hingeXsi{1,1}.CONTENT); end
    try TEDhingeRelHeight(1,i) = str2num(TEDs_Struct{1,i}.path{1,1}.innerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT); end
    
    % TED's path reading - outerHingePoint------------- %
    try TEDhingeXsi(2,i) = str2num(TEDs_Struct{1,i}.path{1,1}.outerHingePoint{1,1}.hingeXsi{1,1}.CONTENT); end
    try TEDhingeRelHeight(2,i) = str2num(TEDs_Struct{1,i}.path{1,1}.outerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT); end
    
    % TED's path reading - Steps ------------- %
   % try
        numSteps = length(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step);
        
        TEDstepRelDeflection=zeros(numSteps,numOfTED);
        TEDstepHingeLineRotation=zeros(numSteps,numOfTED);
        TEDstepInnerHingeTranslationX=zeros(numSteps,numOfTED);
        TEDstepInnerHingeTranslationY=zeros(numSteps,numOfTED);
        TEDstepInnerHingeTranslationZ=zeros(numSteps,numOfTED);
        TEDstepOuterHingeTranslationX=zeros(numSteps,numOfTED);
        TEDstepOuterHingeTranslationY=zeros(numSteps,numOfTED);
        TEDstepOuterHingeTranslationZ=zeros(numSteps,numOfTED);
        
        for jstep = 1: numSteps
            TEDstepRelDeflection(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.relDeflection{1,1}.CONTENT);
            TEDstepHingeLineRotation(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.hingeLineRotation{1,1}.CONTENT);
            TEDstepInnerHingeTranslationX(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT);
            TEDstepInnerHingeTranslationY(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT);
            TEDstepInnerHingeTranslationZ(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT);
            
            try TEDstepOuterHingeTranslationX(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.x{1,1}.CONTENT);
            catch TEDstepOuterHingeTranslationX(i, jstep) = TEDstepInnerHingeTranslationX(i, jstep); end
             
            try TEDstepOuterHingeTranslationY(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.y{1,1}.CONTENT);
            catch TEDstepOuterHingeTranslationY(i, jstep) = TEDstepInnerHingeTranslationY(i, jstep); end
             
            try TEDstepOuterHingeTranslationZ(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.z{1,1}.CONTENT);
            catch TEDstepOuterHingeTranslationZ(i, jstep) = TEDstepInnerHingeTranslationZ(i, jstep); end
        end
        
%     catch
%         disp('no steps info about the trailing Edge Device of this TED')
%     end
    %---------------------------------------------------------%
    %---------------------------------------------------------%
    
    
    % Fill NaN's
    for ii=1:2
        if isnan(TEDetaTE(ii,i))
            TEDetaTE(ii,i)=TEDetaLE(ii,i);
        end
    end
    
    for ii=1:2
        if isnan(TEDetaLE(ii,i))
            TEDetaLE(ii,i)=TEDetaTE(ii,i);
        end
    end
    
    if max(max(isnan(TEDetaLE(:,i))+isnan(TEDetaTE(:,i))+isnan(TEDxsiLE(:,i))))>0
        error('Bad Case in CPACS Wrapper')
    end
    
    %-----------------------------------
    % Fill leadingEdgeShape NaN's ----------------------------%
    for ii=1:2
        if isnan(TEDrelHeightLE(ii,i))
            TEDrelHeightLE(ii,i)=0.5;
        end
        
        if isnan(TEDxsiUpperSkin(ii,i))
            TEDxsiUpperSkin(ii,i)=0.85;
        end
        
        if isnan(TEDxsiLowerSkin(ii,i))
            TEDxsiLowerSkin(ii,i)=0.85;
        end
    end
    %------------------------------------
    
    % Names of Control Surfaces
    TEDname{i,1}=['none: numOfTED = ',num2str(numOfTED)];
    try TEDname{i,1}=TEDs_Struct{1,i}.name{1,1}.CONTENT; end
    TEDuid{i,1}=['none: numOfTED = ',num2str(numOfTED)];
    try TEDuid{i,1}=TEDs_Struct{1,i}.ATTRIBUTE.uID; end
    TEDs_Geo{i,1}.TEDname=TEDname{i,1};
    TEDs_Geo{i,1}.TEDuid=TEDuid{i,1};
    try TEDs_Geo{i,1}.etaLE=[TEDetaLE(1,i),TEDetaLE(2,i)];end
    try TEDs_Geo{i,1}.etaTE=[TEDetaTE(1,i),TEDetaTE(2,i)];end
    try TEDs_Geo{i,1}.xsiLE=[TEDxsiLE(1,i),TEDxsiLE(2,i)];end
    try TEDs_Geo{i,1}.relHeightLE=[TEDrelHeightLE(1,i),TEDrelHeightLE(2,i)];end
    try TEDs_Geo{i,1}.xsiUpperSkin=[TEDxsiUpperSkin(1,i),TEDxsiUpperSkin(2,i)];end
    try TEDs_Geo{i,1}.xsiLowerSkin=[TEDxsiLowerSkin(1,i),TEDxsiLowerSkin(2,i)];end
    
    try TEDs_Geo{i,1}.hingeXsi=[TEDhingeXsi(1,i),TEDhingeXsi(2,i)]; end
    try TEDs_Geo{i,1}.hingeRelHeight=[TEDhingeRelHeight(1,i),TEDhingeRelHeight(2,i)]; end
    
    try TEDs_Geo{i,1}.stepRelDeflection=TEDstepRelDeflection(i,:); end
    try TEDs_Geo{i,1}.stepHingeLineRotation=TEDstepHingeLineRotation(i,:); end
    try TEDs_Geo{i,1}.stepInnerHingeTranslationX=TEDstepInnerHingeTranslationX(i,:); end
    try TEDs_Geo{i,1}.stepInnerHingeTranslationY=TEDstepInnerHingeTranslationY(i,:); end
    try TEDs_Geo{i,1}.stepInnerHingeTranslationZ=TEDstepInnerHingeTranslationZ(i,:); end
    
    try TEDs_Geo{i,1}.stepOuterHingeTranslationX=TEDstepOuterHingeTranslationX(i,:); end
    try TEDs_Geo{i,1}.stepOuterHingeTranslationY=TEDstepOuterHingeTranslationY(i,:); end
    try TEDs_Geo{i,1}.stepOuterHingeTranslationZ=TEDstepOuterHingeTranslationZ(i,:); end
end

end

function  [sparsRibsgeo] = readSparsRibs(sparsRibs_Struct)

%--------------RibsDefinition---------------%
ribs_struct = sparsRibs_Struct.ribsDefinitions{1,1}.ribsDefinition;
numRibsDefinition = length(ribs_struct);

ribs_uID = cell(1,numRibsDefinition);
ribs_ribReference = cell(1,numRibsDefinition);
ribs_etaStart = ones(1,numRibsDefinition)*NaN;
ribs_etaEnd = ones(1,numRibsDefinition)*NaN;
ribs_ribStart = cell(1,numRibsDefinition);
ribs_ribEnd =  cell(1,numRibsDefinition);
ribs_numberOfRibs = ones(1,numRibsDefinition)*NaN;
ribs_CrossingBehavior = cell(1,numRibsDefinition);
ribs_ribRotationReference = cell(1,numRibsDefinition);
ribs_rotz = ones(1,numRibsDefinition)*NaN;
ribs_rotx = ones(1,numRibsDefinition)*NaN;

for i = 1:numRibsDefinition
   ribs_uID{1,i} = ribs_struct{1,i}.ATTRIBUTE.uID;
   ribs_ribReference{1,i} = ribs_struct{1,i}.ribsPositioning{1,1}.ribReference{1,1}.CONTENT;
   ribs_etaStart(1,i) = str2double(ribs_struct{1,i}.ribsPositioning{1,1}.etaStart{1,1}.CONTENT);
   ribs_etaEnd(1,i) = str2double(ribs_struct{1,i}.ribsPositioning{1,1}.etaEnd{1,1}.CONTENT);
   ribs_ribStart{1,i} = ribs_struct{1,i}.ribsPositioning{1,1}.ribStart{1,1}.CONTENT;
   ribs_ribEnd{1,i} = ribs_struct{1,i}.ribsPositioning{1,1}.ribEnd{1,1}.CONTENT;
   ribs_numberOfRibs(1,i) = str2double(ribs_struct{1,i}.ribsPositioning{1,1}.numberOfRibs{1,1}.CONTENT);
   ribs_CrossingBehavior{1,i} = ribs_struct{1,i}.ribsPositioning{1,1}.ribCrossingBehaviour{1,1}.CONTENT;
   ribs_ribRotationReference{1,i} = ribs_struct{1,i}.ribsPositioning{1,1}.ribRotation{1,1}.ribRotationReference{1,1}.CONTENT;
   ribs_rotz(1,i) = str2double(ribs_struct{1,i}.ribsPositioning{1,1}.ribRotation{1,1}.z{1,1}.CONTENT);
   try ribs_rotx(1,i) = str2double(ribs_struct{1,i}.ribsPositioning{1,1}.ribRotation{1,1}.x{1,1}.CONTENT);
   catch ribs_rotx(1,i) = ribs_rotz(1,i);  end
   
%--------------SparsPosition----------------%
spars_struct = sparsRibs_Struct.spars{1,1}.sparPositions{1,1}.sparPosition;
numSparPosition = length(spars_struct);

spars_uID = cell(1,numSparPosition);
spars_eta = ones(1,numSparPosition)*NaN;
spars_xsi = ones(1,numSparPosition)*NaN;

for i = 1:numSparPosition
spars_uID{1,i} = spars_struct{1,i}.ATTRIBUTE.uID;
spars_eta(1,i) = str2double(spars_struct{1,i}.eta{1,1}.CONTENT);
spars_xsi(1,i) = str2double(spars_struct{1,i}.xsi{1,1}.CONTENT);
end

%--------------SparSegment----------------%
spars_segment = sparsRibs_Struct.spars{1,1}.sparSegments{1,1}.sparSegment;
numSparSegment = length(spars_segment);

spars_segmentuID = cell(1, numSparSegment);
spars_segmentPositions = cell(1, numSparSegment);

for i = 1: numSparSegment
   spars_segmentuID{1,i} = spars_segment{1,i}.ATTRIBUTE.uID;
   
   spars_segment_positions = spars_segment{1,i}.sparPositionUIDs{1,1}.sparPositionUID;
   
   numSegPosition = length(spars_segment_positions);
   segPositnsUID = cell(1,numSegPosition);
   
   for j = 1: numSegPosition
     segPositnsUID{1,j} = spars_segment_positions{1,j}.CONTENT;
   end
   
   spars_segmentPositions{1,i} = segPositnsUID;
end

sparsRibsgeo.ribsDefinitions.uIDs = ribs_uID;
sparsRibsgeo.ribsDefinitions.ribReference = ribs_ribReference;
sparsRibsgeo.ribsDefinitions.etaStart = ribs_etaStart;
sparsRibsgeo.ribsDefinitions.etaEnd = ribs_etaEnd;
sparsRibsgeo.ribsDefinitions.ribStart = ribs_ribStart;
sparsRibsgeo.ribsDefinitions.ribEnd = ribs_ribEnd;
sparsRibsgeo.ribsDefinitions.numberOfRibs = ribs_numberOfRibs;
sparsRibsgeo.ribsDefinitions.ribCrossingBehavior = ribs_CrossingBehavior;
sparsRibsgeo.ribsDefinitions.ribRotationReference = ribs_ribRotationReference;
sparsRibsgeo.ribsDefinitions.rotz = ribs_rotz;
sparsRibsgeo.ribsDefinitions.rotx = ribs_rotx;

sparsRibsgeo.spars.positions.uIDs = spars_uID;
sparsRibsgeo.spars.positions.eta = spars_eta;
sparsRibsgeo.spars.positions.xsi = spars_xsi;
sparsRibsgeo.spars.segments.uIDs = spars_segmentuID;
sparsRibsgeo.spars.segments.positions = spars_segmentPositions;

end
end
%}