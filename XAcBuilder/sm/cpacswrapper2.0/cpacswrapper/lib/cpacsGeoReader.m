function [CPACSgeo]=cpacsGeoReader(CPACS_XML,CPACSgeo,componentTypeName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CPACSegoRead                                                           %
%  Translate the wing and fuselage in gloabal definition                  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-28 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Aplicated functions                                                     %
% - rotVec                                                                %
% - calcAbsVec                                                            %
% - coordSysTrans                                                         %
% - readTrandformations                                                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%  ToDo:                                                                  %
%  -! Simplyfication: exach section can have only one element !           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Settings

% Visable setting of Voordinate Systems(1 = view on, 2 = view off)
% [RefCoodSys WingCoodSys SectionCoodSys ElementCoodSys Airfoils]
trans.visible  =  [0,0,0,0,0];

%% Select Components

% ComponentType:
% 1  Wings
% 2  Fuselage

switch componentTypeName
    case 'wings'
        componentType=1;        
    case 'fuselages'
        componentType=2;
    otherwise
        error('No Correct componentTypeName')
end

if componentType==1  
    comSize=size(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing,2);
else
    try
    comSize=size(CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage,2);
    catch
        error('No Fuselage found')
    end
end

%% Wrapper 

count=0;

for compNum=1:comSize
    
%% Positionings

    if componentType==1  
        component{1,1} = CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing{1,compNum};  
    else
        component{1,1} = CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage{1,compNum};
    end

    % Positioning Vectors
    % posStruct include {fromSectionUID, toSectionUID, relative Vector, absolut Vector}
    posStruct={}; 
    % Local Positionings Vectors
    for posNum=1:size(component{1,1}.sections{1,1}.section,2)
        % fromSectionUID
        try posStruct{posNum,1} = (component{1,1}.positionings{1,1}.positioning{1,posNum}.fromSectionUID{1,1}.CONTENT);end
        % toSectionUID
        try posStruct{posNum,2} = (component{1,1}.positionings{1,1}.positioning{1,posNum}.toSectionUID{1,1}.CONTENT);end

        % Reletive Positioning Values
        if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<2     
            length     = str2num(component{1,1}.positionings{1,1}.positioning{1,posNum}.length{1,1}.CONTENT);
            sweepAngle = str2num(component{1,1}.positionings{1,1}.positioning{1,posNum}.sweepangle{1,1}.CONTENT);
            dihedral   = str2num(component{1,1}.positionings{1,1}.positioning{1,posNum}.dihedralangle{1,1}.CONTENT);
        else %CPACS VERSION 2.0
            length     = str2num(component{1,1}.positionings{1,1}.positioning{1,posNum}.length{1,1}.CONTENT);
            sweepAngle = str2num(component{1,1}.positionings{1,1}.positioning{1,posNum}.sweepAngle{1,1}.CONTENT);
            dihedral   = str2num(component{1,1}.positionings{1,1}.positioning{1,posNum}.dihedralAngle{1,1}.CONTENT);
        end

        % Relative Positioning Vector
        Rot1 = rotVec(-sweepAngle,[0;length;0],3);
        Rot2 = rotVec(dihedral,Rot1,1);        
        xposAbs = Rot2(1);
        yposAbs = Rot2(2);
        zposAbs = Rot2(3);

        % Write to posvStruct
        posStruct{posNum,3} = [xposAbs,yposAbs,zposAbs];    
        posStruct{posNum,6} = [length,sweepAngle,dihedral]; 
    end

    % Absolut Positionings Vectors
    for posNum=1:size(component{1,1}.sections{1,1}.section,2)
        if isempty(posStruct{posNum,1})==1
            posStruct{posNum,4}=posStruct{posNum,3};
        else
            [posStruct,absVec] = calcAbsVec(posStruct,posNum);
        end
    end

%% Start Transformation
    airfoili={};
    for SecNum=1:size(component{1,1}.sections{1,1}.section,2)
        
%% Read Transformations from CPACS  

        [trans] = readTrandformations(component,CPACS_XML,trans,SecNum,componentType,posStruct);

%% Coord Sytem Transformation
        
        [airfoil,compDesc]=coordSysTrans(trans,CPACS_XML,SecNum);
        airfoili{SecNum,1}=airfoil;
        airfoili{SecNum,2}=trans.uIDs.elementUID;

%% Save section and airfoils to struct

        CPACSgeo.(componentTypeName).component{compNum,1}.name = component{1,1}.name{1,1}.CONTENT;
        CPACSgeo.(componentTypeName).component{compNum,1}.uID  = component{1,1}.ATTRIBUTE.uID;
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.point{SecNum,1}=compDesc{1,1};
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.coorsSys{SecNum,1}=compDesc{1,2};
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.airfoil{SecNum,1}=airfoil;
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.airfoilScaling{SecNum,1}=trans.scaling(:,3);
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.relAirfoil{SecNum,1} = trans.airfoil;
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.relAirfoil{SecNum,2} = trans.uIDs.airfoilUID;            
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.sectionElementUIDs{SecNum,1}.elementUID{1,1}=trans.uIDs.elementUID;
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.sectionUID{SecNum,1}=trans.uIDs.sectionUID;
        CPACSgeo.(componentTypeName).component{compNum,1}.type = componentTypeName; 
            
        count=count+1;
        CPACSgeo.(componentTypeName).airfoil{count,1}=trans.airfoil;
        CPACSgeo.(componentTypeName).airfoil{count,2}=trans.uIDs.airfoilUID;
        
        % Relative Vector from wing coordinate system to the section
        % coordinate systen (parrend Coordinate system is Wing)
        CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.secPointRelInWing{SecNum,1}=trans.poitioning.vector'+trans.tranlation(:,2);
    end

%% Save Segments to Struct

    for segNum=1:size(component{1,1}.segments{1,1}.segment,2)
        try
            CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef{segNum,1}.fromElementUID=(component{1,1}.segments{1,1}.segment{1,segNum}.fromElementUID{1,1}.CONTENT);
        catch
            CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef{segNum,1}.fromElementUID='';
        end
        CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef{segNum,1}.toElementUID=(component{1,1}.segments{1,1}.segment{1,segNum}.toElementUID{1,1}.CONTENT);
    end  
        
%% Check Symmetry

     if isfield(component{1,1}.ATTRIBUTE,'symmetry')
         symmetry=1; 
     else
         symmetry=0;
     end     
     CPACSgeo.(componentTypeName).component{compNum,1}.symmetry=symmetry;
        
%% Symetry Information

    CPACSgeo.(componentTypeName).component{compNum,1}.symmetry=symmetry;

end
