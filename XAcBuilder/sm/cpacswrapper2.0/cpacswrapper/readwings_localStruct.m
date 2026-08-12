function [WINGgeo]=readwings_localStruct(WINGgeo, wing_struct)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run Outer Surface Wrapper %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

componentTypeName='wings';
[WINGgeo]=cpacsGeoReader_localStruct(wing_struct,WINGgeo, componentTypeName);

% disp('Wing1 CPACSgeoReader finished')

%    WINGgeo.aircraftName=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT;

%%%%%%%%%%%%%%%%%%%
% controlSurfaces %
%%%%%%%%%%%%%%%%%%%

% ToDo
% - absolut positions having regard to Segments
% - Leading edge devises, spoilers

%% Control Surfacses
try
    numOfcompSeg = length(wing_struct.componentSegments{1,1}.componentSegment);
    for compSegNum = 1: numOfcompSeg                                              % Just in case in the future more componentSegment may be applied.
        
        compSeg_Struct =  wing_struct.componentSegments{1,1}.componentSegment{1,compSegNum};
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % trailingEdgeDevices %
        %%%%%%%%%%%%%%%%%%%%%%%
        
        %     if isfield(compSeg_Struct, 'controlSurfaces')
        %         disp('reading controlSurfaces')
        %         TEDs_Struct = compSeg_Struct.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice;
        %         [TEDs_geo] = readControlSurfs(TEDs_Struct);
        %         WINGgeo.componentSegment{compSegNum,1}.controlSurfaces.TEDs = TEDs_geo;
        %     end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % Spars and Ribs %
        %%%%%%%%%%%%%%%%%%%%%%%
        
        %     if isfield(compSeg_Struct, 'structure')
        %         sparsRibs_Struct =  compSeg_Struct.structure{1,1};
        %         [sparsRibsgeo] = readSparsRibs(sparsRibs_Struct);
        %          WINGgeo.componentSegment{compSegNum,1}.structure = sparsRibsgeo;
        %     end
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % wingFuelTanks %
        %%%%%%%%%%%%%%%%%%%%%%%
        
        %             if isfield(compSeg_Struct, 'wingFuelTanks')
        %                wingFT_Struct = compSeg_Struct.wingFuelTanks{1,1};
        %                [wingFTgeo] = readFuelTanks(wingFT_Struct);
        %             end
        
        
        WINGgeo.componentSegment{compSegNum,1}.uID = compSeg_Struct.ATTRIBUTE.uID;
        WINGgeo.componentSegment{compSegNum,1}.name = compSeg_Struct.name;
        WINGgeo.componentSegment{compSegNum,1}.fromElementUID = compSeg_Struct.fromElementUID;
        WINGgeo.componentSegment{compSegNum,1}.toElementUID = compSeg_Struct.toElementUID;
        
        
        %     CPACSgeo.(componentTypeName).component{compNum,1}.componentSegment{compSegNum,1}.wingFuelTanks = wingFTgeo;
        
    end
end
% disp(['The ',componentTypeName,' ',num2str(compNum) ,' has no control devices'])

area=[];
loacalSpan=[];
for n=1:size(WINGgeo.sectionDef.coorsSys)-1
    chordVec1=WINGgeo.sectionDef.coorsSys{n,1}*[1;0;0];
    chordVec2=WINGgeo.sectionDef.coorsSys{n+1,1}*[1;0;0];
    chordLenth1=sqrt(chordVec1(1,1)^2+chordVec1(2,1)^2+chordVec1(3,1)^2);
    chordLenth2=sqrt(chordVec2(1,1)^2+chordVec2(2,1)^2+chordVec2(3,1)^2);
    spVec=WINGgeo.sectionDef.point{n+1,1}-WINGgeo.sectionDef.point{n,1};
    loacalSpan(n,1)=sqrt(spVec(2,1)^2+spVec(3,1)^2);
    area(n,1)=loacalSpan(n,1)*(chordLenth1+chordLenth2)/2;
    
end
if WINGgeo.symmetry == 1
    compArea = sum(area)*2;
    compSpan = sum(loacalSpan)*2;
else
    compArea = sum(area);
    compSpan = sum(loacalSpan);
end

WINGgeo.compSpan = compSpan;
WINGgeo.localSpan = loacalSpan;
WINGgeo.compArea = compArea;
WINGgeo.halfSpan = compSpan/2;
% WINGgeo.sectionDef.localSpan = loacalSpan;
end





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
end

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


%{
    %% Control Surfacses
        try
            %%%%%%%%%%%%%%%%%%%%%%%
            % trailingEdgeDevices %
            %%%%%%%%%%%%%%%%%%%%%%%

            numOfTED=size(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice,2);
            % TEDelt [control1 control2 ...]
            TEDetaLE=ones(2,numOfTED)*NaN;
            TEDetaTE=ones(2,numOfTED)*NaN;
            TEDksiLE=ones(2,numOfTED)*NaN;
            TEDname={};
            % Read from the CPACSgeo struct
            for i=1:numOfTED
                % inner discription
                try TEDetaLE(1,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.innerBorder{1,1}.etaLE{1,1}.CONTENT); end
                try TEDetaTE(1,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT); end
                try
                    TEDksiLE(1,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.innerBorder{1,1}.ksiLE{1,1}.CONTENT);
                catch
                    TEDksiLE(1,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.innerBorder{1,1}.xsiLE{1,1}.CONTENT);
                end
                
                % outer discription
                try TEDetaLE(2,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.outerBorder{1,1}.etaLE{1,1}.CONTENT); end
                try TEDetaTE(2,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT); end
                try
                    TEDksiLE(2,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.outerBorder{1,1}.ksiLE{1,1}.CONTENT);
                catch
                    TEDksiLE(2,i)=str2num(wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.outerShape{1,1}.outerBorder{1,1}.xsiLE{1,1}.CONTENT);
                end
                
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
                
                if max(max(isnan(TEDetaLE(:,i))+isnan(TEDetaTE(:,i))+isnan(TEDksiLE(:,i))))>0
                    error('Bad Case in CPACS Wrapper')
                end
                
                % Names of Control Surfaces
                TEDname{i,1}=wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.name{1,1}.CONTENT;
                TEDuid{i,1}=wing_struct.componentSegments{1,1}.componentSegment{1,1}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,i}.ATTRIBUTE.uID;
                ContStruct.trailingEdgeDevices{i,1}.TEDname=TEDname{i,1};
                ContStruct.trailingEdgeDevices{i,1}.TEDuid=TEDuid{i,1};
                try ContStruct.trailingEdgeDevices{i,1}.etaLE=[TEDetaLE(1,i),TEDetaLE(2,i)];end
                try ContStruct.trailingEdgeDevices{i,1}.etaTE=[TEDetaTE(1,i),TEDetaTE(2,i)];end
                try ContStruct.trailingEdgeDevices{i,1}.ksiLE=[TEDksiLE(1,i),TEDksiLE(2,i)];end
            end

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

            WINGgeo.controlSurfaces.definition=ContStruct;
            WINGgeo.controlSurfaces.reference.fromElementUID=wing_struct.componentSegments{1,1}.componentSegment{1,1}.fromElementUID;
            WINGgeo.controlSurfaces.reference.toElementUID=wing_struct.componentSegments{1,1}.componentSegment{1,1}.toElementUID;

        catch
            disp(['The ',componentTypeName,' ',' has no control devices'])
        end
%}