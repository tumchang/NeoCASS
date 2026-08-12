function [FUSgeo]=cpacsGeoReader_localStruct(comp_struct,FUSgeo,componentTypeName)
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


%% Wrapper 

count=0;
    
%% Positionings

    % Positioning Vectors
    % posStruct include {fromSectionUID, toSectionUID, relative Vector, absolut Vector}
    posStruct={}; 
    % Local Positionings Vectors
    for posNum=1:size(comp_struct.sections{1,1}.section,2)
        % fromSectionUID
        try posStruct{posNum,1} = (comp_struct.positionings{1,1}.positioning{1,posNum}.fromSectionUID{1,1}.CONTENT);end
        % toSectionUID
        try posStruct{posNum,2} = (comp_struct.positionings{1,1}.positioning{1,posNum}.toSectionUID{1,1}.CONTENT);end

        % Reletive Positioning Values
    %    if str2num(comp_struct.cpacsVersion)<2     
%             length     = str2num(comp_struct.positionings{1,1}.positioning{1,posNum}.length{1,1}.CONTENT);
%             sweepAngle = str2num(comp_struct.positionings{1,1}.positioning{1,posNum}.sweepangle{1,1}.CONTENT);
%             dihedral   = str2num(comp_struct.positionings{1,1}.positioning{1,posNum}.dihedralangle{1,1}.CONTENT);
%         else %CPACS VERSION 2.0
            length     = str2num(comp_struct.positionings{1,1}.positioning{1,posNum}.length{1,1}.CONTENT);
            sweepAngle = str2num(comp_struct.positionings{1,1}.positioning{1,posNum}.sweepAngle{1,1}.CONTENT);
            dihedral   = str2num(comp_struct.positionings{1,1}.positioning{1,posNum}.dihedralAngle{1,1}.CONTENT);
%         end

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
   %  save('posStruct1.mat','posStruct')
    for posNum=1:size(comp_struct.sections{1,1}.section,2)
        if isempty(posStruct{posNum,1})==1
            posStruct{posNum,4}=posStruct{posNum,3};
        else
            [posStruct,absVec] = calcAbsVec(posStruct,posNum);
        end
    end

%% Start Transformation
    airfoili={};
    
   %  numOfSections = size(comp_struct.sections{1,1}.section,2);
    
    for SecNum=1:size(comp_struct.sections{1,1}.section,2)
        
%% Read Transformations from CPACS  
        %SecNum
        [trans] = readTrandformations_localStruct(comp_struct,trans,SecNum,posStruct,componentType);
       
%% Coord Sytem Transformation
        
        [airfoil,compDesc]=coordSysTrans_localStruct(trans,SecNum);          %(trans,comp_struct.cpacsVersion,SecNum);
        airfoili{SecNum,1}=airfoil;
        airfoili{SecNum,2}=trans.uIDs.elementUID;

%% Save section and airfoils to struct

        FUSgeo.name = comp_struct.name{1,1}.CONTENT;
        FUSgeo.uID  = comp_struct.ATTRIBUTE.uID;
        FUSgeo.sectionDef.point{SecNum,1}=compDesc{1,1};
        FUSgeo.sectionDef.coorsSys{SecNum,1}=compDesc{1,2};
        FUSgeo.sectionDef.airfoil{SecNum,1}=airfoil;
        FUSgeo.sectionDef.airfoilScaling{SecNum,1}=trans.scaling(:,3);
        FUSgeo.sectionDef.relAirfoil{SecNum,1} = trans.airfoil;
        FUSgeo.sectionDef.relAirfoil{SecNum,2} = trans.uIDs.airfoilUID;            
        FUSgeo.sectionDef.sectionElementUIDs{SecNum,1}.elementUID{1,1}=trans.uIDs.elementUID;
        FUSgeo.sectionDef.sectionUID{SecNum,1}=trans.uIDs.sectionUID;
        %---------------
        FUSgeo.type = componentTypeName; 
        %---------------
        count=count+1;
        FUSgeo.airfoil{count,1}=trans.airfoil;
        FUSgeo.airfoil{count,2}=trans.uIDs.airfoilUID;
        
        % Relative Vector from wing coordinate system to the section
        % coordinate systen (parrend Coordinate system is Wing)
        FUSgeo.sectionDef.secPointRelInWing{SecNum,1}=trans.poitioning.vector'+trans.tranlation(:,2);
    end
 % disp('readTrandformations finished')
%% Save Segments to Struct

    for segNum=1:size(comp_struct.segments{1,1}.segment,2)
        try
            FUSgeo.segmentDef{segNum,1}.fromElementUID=(comp_struct.segments{1,1}.segment{1,segNum}.fromElementUID{1,1}.CONTENT);
        catch
            FUSgeo.segmentDef{segNum,1}.fromElementUID='';
        end
        FUSgeo.segmentDef{segNum,1}.toElementUID=(comp_struct.segments{1,1}.segment{1,segNum}.toElementUID{1,1}.CONTENT);
    end  
        
%% Check Symmetry

%      if isfield(comp_struct.ATTRIBUTE,'symmetry')
%          symmetry=1; 
%      else
%          symmetry=0;
%      end     
    %  FUSgeo.symmetry=symmetry;
        
 if isfield(comp_struct.ATTRIBUTE,'symmetry')           
    switch comp_struct.ATTRIBUTE.symmetry
        case 'no symmetry'
            symmetry=0;
        case 'x-z-plane'
            symmetry=1;
        case 'x-y-plane'
            symmetry=2;
        case 'y-z-plane'
            symmetry=3;
    end
else
   %  fus_struct.ATTRIBUTE.symmetry ='no symmetry';
    symmetry=0;
end   
    
    
%% Symetry Information

    FUSgeo.symmetry=symmetry;

%end
