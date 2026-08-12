function [trans] = readTrandformations_localStruct(comp_struct,trans,SecNum,posStruct,componentType)   %(component,CPACS_XML,trans,SecNum,componentType,posStruct)
                   
%%%%%%%%%%%%%%%%%%%%%%%
% Wing Transformation %
%%%%%%%%%%%%%%%%%%%%%%%

% Translation
trans.tranlation(1,1) = str2num(comp_struct.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
trans.tranlation(2,1) = str2num(comp_struct.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
trans.tranlation(3,1) = str2num(comp_struct.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);
% Scaling
trans.scaling(1,1) = str2num(comp_struct.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT);
trans.scaling(2,1) = str2num(comp_struct.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT);
trans.scaling(3,1) = str2num(comp_struct.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT);
% Rotation
trans.rotation(1,1) = str2num(comp_struct.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT);
trans.rotation(2,1) = str2num(comp_struct.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT);
trans.rotation(3,1) = str2num(comp_struct.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT);

%%%%%%%%%%%%%%%%%%%%%%%%%
% Section Tranformation %
%%%%%%%%%%%%%%%%%%%%%%%%%

% Translation
trans.tranlation(1,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
trans.tranlation(2,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
trans.tranlation(3,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);
% Scaling
trans.scaling(1,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT);
trans.scaling(2,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT);
trans.scaling(3,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT);
% Rotation
trans.rotation(1,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT);
trans.rotation(2,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT);
trans.rotation(3,2) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT);

% Section UID
trans.uIDs.sectionUID=comp_struct.sections{1,1}.section{1,SecNum}.ATTRIBUTE.uID;

sectionuid = comp_struct.sections{1,1}.section{1,SecNum}.ATTRIBUTE.uID;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section Element Tranformation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ! Simplyfication: each section can have only one element !

% Translation
trans.tranlation(1,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
trans.tranlation(2,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
trans.tranlation(3,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);
% Scaling
trans.scaling(1,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT);
trans.scaling(2,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT);
trans.scaling(3,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT);
% Rotation
trans.rotation(1,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT);
trans.rotation(2,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT);
trans.rotation(3,3) = str2num(comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT);

% Element UID
trans.uIDs.elementUID=comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.ATTRIBUTE.uID;
elementuid = comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.ATTRIBUTE.uID;

%%%%%%%%%%%%%%%
% Airfoil UID %
%%%%%%%%%%%%%%%

if componentType==1            
    airfoilUID  = (comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT);
    airfoilList = comp_struct.profiles;        
else
    airfoilList = comp_struct.profiles;
  %  airfoilUID  = CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage{1,1}.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT;
    airfoilUID = (comp_struct.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT);
end
trans.uIDs.airfoilUID=airfoilUID;
airfuid = airfoilUID;
% Find the Aifoil in Airfoil List

trans.airfoil=[];
xx = 0; 
% if str2num(comp_struct.cpacsVersion)<2  
%     for ii=1:size(airfoilList,2)
%         foilUID=airfoilList{1,ii}.ATTRIBUTE.uID;
%         if strcmp(airfoilUID,foilUID)
%             %disp('found the required airfoil in the profiles airfoil library!')
%             xx = 1; 
%             for iii=1:size(airfoilList{1,ii}.pointList{1,1}.point,2)
%                  trans.airfoil(iii,1)=str2num(airfoilList{1,ii}.pointList{1,1}.point{1,iii}.x{1,1}.CONTENT);
%                  trans.airfoil(iii,2)=0;
%                  trans.airfoil(iii,3)=str2num(airfoilList{1,ii}.pointList{1,1}.point{1,iii}.y{1,1}.CONTENT);
%             end
%         end
%     end
    
%     if xx == 0; 
%         h = warndlg(sprintf('No such airfoil exist in the profiles airfoil library! \n Will engender error later! \n Make sure your profile library contains the airfoils needed!'), '!! Warning !!','modal');
%         uiwait(h)
%     end
    
% else %CPACS VERSION 2.0
     for ii=1:size(airfoilList,2)
        foilUID=airfoilList{1,ii}.ATTRIBUTE.uID;
        if strcmp(airfoilUID,foilUID)
             %disp('found the required airfoil in the profiles airfoil library!')
             xx = 1; 
             trans.airfoil(:,1)=str2num(airfoilList{1,ii}.pointList{1,1}.x{1,1}.CONTENT);
             trans.airfoil(:,2)=str2num(airfoilList{1,ii}.pointList{1,1}.y{1,1}.CONTENT);
             trans.airfoil(:,3)=str2num(airfoilList{1,ii}.pointList{1,1}.z{1,1}.CONTENT);
             break;
        end
     end
    
     if xx == 0;
         h = warndlg(sprintf('No such airfoil exist in the profiles airfoil library! \n Will engender error later! \n Make sure your profile library contains the airfoils needed!'), '!! Warning !!','modal');
         uiwait(h)
     end
% end


%%%%%%%%%%%%%%%
% Positonings %
%%%%%%%%%%%%%%%

posNum = SecNum;
% Vector
trans.poitioning.vector=posStruct{SecNum,4};
% Vector input
trans.poitioning.length=posStruct{SecNum,6}(1,1);
trans.poitioning.sweepAngle=posStruct{SecNum,6}(1,2);
trans.poitioning.dihedral=posStruct{SecNum,6}(1,3);