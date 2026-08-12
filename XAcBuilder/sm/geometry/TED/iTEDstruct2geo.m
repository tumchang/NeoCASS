function [iTED_Geo] = iTEDstruct2geo(iTED_Struct)

%%%%%%%%%%%%%%%%%%%%%%%
% trailingEdgeDevices 
% read TEDstruct into TEDgeo format
% reformat the data in TEDstruct, so that data are more compact in TEDgeo
%%%%%%%%%%%%%%%%%%%%%%%

numOfTED = 1;
 
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
    try TEDetaLE(1,i)=str2num(iTED_Struct.outerShape{1,1}.innerBorder{1,1}.etaLE{1,1}.CONTENT); end
    try TEDetaTE(1,i)=str2num(iTED_Struct.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT); end
    try
%         TEDxsiLE(1,i)=str2num(iTED_Struct.outerShape{1,1}.innerBorder{1,1}.ksiLE{1,1}.CONTENT);
%     catch
        TEDxsiLE(1,i)=str2num(iTED_Struct.outerShape{1,1}.innerBorder{1,1}.xsiLE{1,1}.CONTENT);
    end
    
    % outer discription
    try TEDetaLE(2,i)=str2num(iTED_Struct.outerShape{1,1}.outerBorder{1,1}.etaLE{1,1}.CONTENT); end
    try TEDetaTE(2,i)=str2num(iTED_Struct.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT); end
    try
%         TEDxsiLE(2,i)=str2num(iTED_Struct.outerShape{1,1}.outerBorder{1,1}.ksiLE{1,1}.CONTENT);
%     catch
        TEDxsiLE(2,i)=str2num(iTED_Struct.outerShape{1,1}.outerBorder{1,1}.xsiLE{1,1}.CONTENT);
    end
    
    % inner leadingEdgeShape --------------------------- %
    try TEDrelHeightLE(1,i)=str2num(iTED_Struct.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT); end
    try TEDxsiUpperSkin(1,i)=str2num(iTED_Struct.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT); end
    try TEDxsiLowerSkin(1,i)=str2num(iTED_Struct.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT); end
    % -------------------------------------------------- %
    
    % outer leadingEdgeShape -------------------------- %
    try TEDrelHeightLE(2,i)=str2num(iTED_Struct.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT); end
    try TEDxsiUpperSkin(2,i)=str2num(iTED_Struct.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT); end
    try TEDxsiLowerSkin(2,i)=str2num(iTED_Struct.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT); end
    % ------------------------------------------------- %
    
    % TED's path reading - innerHingePoint------------- %
    %-------------------------------------------------- %
    
    TEDhingeXsi=zeros(2,numOfTED);
    TEDhingeRelHeight=zeros(2,numOfTED);
    
    try TEDhingeXsi(1,i) = str2num(iTED_Struct.path{1,1}.innerHingePoint{1,1}.hingeXsi{1,1}.CONTENT); end
    try TEDhingeRelHeight(1,i) = str2num(iTED_Struct.path{1,1}.innerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT); end
    
    % TED's path reading - outerHingePoint------------- %
    try TEDhingeXsi(2,i) = str2num(iTED_Struct.path{1,1}.outerHingePoint{1,1}.hingeXsi{1,1}.CONTENT); end
    try TEDhingeRelHeight(2,i) = str2num(iTED_Struct.path{1,1}.outerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT); end
    
    % TED's path reading - Steps ------------- %
   try
        numSteps = length(iTED_Struct.path{1,1}.steps{1,1}.step);
        
        TEDstepRelDeflection=zeros(numSteps,numOfTED);
        TEDstepHingeLineRotation=zeros(numSteps,numOfTED);
        TEDstepInnerHingeTranslationX=zeros(numSteps,numOfTED);
        TEDstepInnerHingeTranslationY=zeros(numSteps,numOfTED);
        TEDstepInnerHingeTranslationZ=zeros(numSteps,numOfTED);
        TEDstepOuterHingeTranslationX=zeros(numSteps,numOfTED);
        TEDstepOuterHingeTranslationY=zeros(numSteps,numOfTED);
        TEDstepOuterHingeTranslationZ=zeros(numSteps,numOfTED);
        
        for jstep = 1: numSteps
            TEDstepRelDeflection(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.relDeflection{1,1}.CONTENT);
            TEDstepHingeLineRotation(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.hingeLineRotation{1,1}.CONTENT);
            TEDstepInnerHingeTranslationX(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT);
            TEDstepInnerHingeTranslationY(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT);
            TEDstepInnerHingeTranslationZ(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT);
            
            try TEDstepOuterHingeTranslationX(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.x{1,1}.CONTENT);
            catch TEDstepOuterHingeTranslationX(i, jstep) = TEDstepInnerHingeTranslationX(i, jstep); end
             
            try TEDstepOuterHingeTranslationY(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.y{1,1}.CONTENT);
            catch TEDstepOuterHingeTranslationY(i, jstep) = TEDstepInnerHingeTranslationY(i, jstep); end
             
            try TEDstepOuterHingeTranslationZ(i, jstep) = str2num(iTED_Struct.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.z{1,1}.CONTENT);
            catch TEDstepOuterHingeTranslationZ(i, jstep) = TEDstepInnerHingeTranslationZ(i, jstep); end
        end
        
    catch
        disp('no steps info about the trailing Edge Device of this TED')
    end
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
    try TEDname{i,1}=iTED_Struct.name{1,1}.CONTENT; end
    TEDuid{i,1}=['none: numOfTED = ',num2str(numOfTED)];
    try TEDuid{i,1}=iTED_Struct.ATTRIBUTE.uID; end
    iTED_Geo.TEDname=TEDname{i,1};
    iTED_Geo.TEDuid=TEDuid{i,1};
    try iTED_Geo.etaLE=[TEDetaLE(1,i),TEDetaLE(2,i)];end
    try iTED_Geo.etaTE=[TEDetaTE(1,i),TEDetaTE(2,i)];end
    try iTED_Geo.xsiLE=[TEDxsiLE(1,i),TEDxsiLE(2,i)];end
    try iTED_Geo.relHeightLE=[TEDrelHeightLE(1,i),TEDrelHeightLE(2,i)];end
    try iTED_Geo.xsiUpperSkin=[TEDxsiUpperSkin(1,i),TEDxsiUpperSkin(2,i)];end
    try iTED_Geo.xsiLowerSkin=[TEDxsiLowerSkin(1,i),TEDxsiLowerSkin(2,i)];end
    
    try iTED_Geo.hingeXsi=[TEDhingeXsi(1,i),TEDhingeXsi(2,i)]; end
    try iTED_Geo.hingeRelHeight=[TEDhingeRelHeight(1,i),TEDhingeRelHeight(2,i)]; end
    
    try iTED_Geo.stepRelDeflection=TEDstepRelDeflection(i,:); end
    try iTED_Geo.stepHingeLineRotation=TEDstepHingeLineRotation(i,:); end
    try iTED_Geo.stepInnerHingeTranslationX=TEDstepInnerHingeTranslationX(i,:); end
    try iTED_Geo.stepInnerHingeTranslationY=TEDstepInnerHingeTranslationY(i,:); end
    try iTED_Geo.stepInnerHingeTranslationZ=TEDstepInnerHingeTranslationZ(i,:); end
    
    try iTED_Geo.stepOuterHingeTranslationX=TEDstepOuterHingeTranslationX(i,:); end
    try iTED_Geo.stepOuterHingeTranslationY=TEDstepOuterHingeTranslationY(i,:); end
    try iTED_Geo.stepOuterHingeTranslationZ=TEDstepOuterHingeTranslationZ(i,:); end
end

end