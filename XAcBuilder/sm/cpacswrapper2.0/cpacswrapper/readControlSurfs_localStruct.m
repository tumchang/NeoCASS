function [TEDs_Geo] = readControlSurfs_localStruct(TEDs_Struct)

%%%%%%%%%%%%%%%%%%%%%%%
% trailingEdgeDevices %
%%%%%%%%%%%%%%%%%%%%%%%

numOfTED=length( TEDs_Struct );
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
%         numSteps = length(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step);
%         
%         TEDstepRelDeflection=zeros(numSteps,numOfTED);
%         TEDstepHingeLineRotation=zeros(numSteps,numOfTED);
%         TEDstepInnerHingeTranslationX=zeros(numSteps,numOfTED);
%         TEDstepInnerHingeTranslationY=zeros(numSteps,numOfTED);
%         TEDstepInnerHingeTranslationZ=zeros(numSteps,numOfTED);
%         TEDstepOuterHingeTranslationX=zeros(numSteps,numOfTED);
%         TEDstepOuterHingeTranslationY=zeros(numSteps,numOfTED);
%         TEDstepOuterHingeTranslationZ=zeros(numSteps,numOfTED);
        
%         for jstep = 1: numSteps
%             TEDstepRelDeflection(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.relDeflection{1,1}.CONTENT);
%             TEDstepHingeLineRotation(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.hingeLineRotation{1,1}.CONTENT);
%             TEDstepInnerHingeTranslationX(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT);
%             TEDstepInnerHingeTranslationY(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT);
%             TEDstepInnerHingeTranslationZ(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT);
%             
%             try TEDstepOuterHingeTranslationX(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.x{1,1}.CONTENT);
%             catch TEDstepOuterHingeTranslationX(i, jstep) = TEDstepInnerHingeTranslationX(i, jstep); end
%              
%             try TEDstepOuterHingeTranslationY(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.y{1,1}.CONTENT);
%             catch TEDstepOuterHingeTranslationY(i, jstep) = TEDstepInnerHingeTranslationY(i, jstep); end
%              
%             try TEDstepOuterHingeTranslationZ(i, jstep) = str2num(TEDs_Struct{1,i}.path{1,1}.steps{1,1}.step{1,jstep}.outerHingeTranslation{1,1}.z{1,1}.CONTENT);
%             catch TEDstepOuterHingeTranslationZ(i, jstep) = TEDstepInnerHingeTranslationZ(i, jstep); end
%         end
%         
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