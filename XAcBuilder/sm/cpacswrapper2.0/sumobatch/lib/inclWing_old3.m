function [NewS] = inclWing(NewS,aircraft,wingNum,CPACSgeo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inclWing                                                              %
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-15 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set new Structure
%% Sweep

% 25% Sweep
SW25=aircraft.wings.SW(wingNum,1:aircraft.wings.nelem(1,wingNum));

% Leadingedg and Tarilingedge Sweep
b   = aircraft.wings.b(wingNum,1:aircraft.wings.nelem(1,wingNum));
c1  = aircraft.wings.c(wingNum,1:aircraft.wings.nelem(1,wingNum));
c2  = aircraft.wings.c(wingNum,2:aircraft.wings.nelem(1,wingNum)+1);
xi  = 0.25;
aircraft.wings.SWle(wingNum,1:aircraft.wings.nelem(1,wingNum))=atan(SW25-xi*(c2./c1-1).*c1./b);
xi  = 1;
aircraft.wings.SWte(wingNum,1:aircraft.wings.nelem(1,wingNum))=atan(aircraft.wings.SWle(wingNum,1:aircraft.wings.nelem(1,wingNum))+xi*(c2./c1-1).*c1./b*2);

%% xyzPos

% wingNames=fieldnames(CPACS.wings);
% absPos = CPACS.wings.(wingNames{wingNum,1}).global{1,1}(1,:);
% absRot = CPACS.wings.(wingNames{wingNum,1}).global{1,2}{1,2};
% 
% 
% 
% [transMat] = eulerTrans(absRot(1),absRot(2),absRot(3),'xyz');
% for i=1:size(CPACS.wings.(wingNames{wingNum,1}).local,1)
%     locVec=CPACS.wings.(wingNames{wingNum,1}).local{i,2}(1,:);
%     locVec=[transMat*locVec']';
%     posVec(i,:)=locVec+absPos;
%     xPos(i,1)=posVec(i,1);
%     yPos(i,1)=posVec(i,2);
%     zPos(i,1)=posVec(i,3);    
% end


%% xyzpos

CPACSgeo.wings.component{wingNum,1}.sectionDef.point

for i=1:size(CPACSgeo.wings.component{wingNum,1}.sectionDef.point,1)
    posVec=CPACSgeo.wings.component{wingNum,1}.sectionDef.point{i,1};
    xPos(i,1)=posVec(1);
    yPos(i,1)=posVec(2);
    zPos(i,1)=posVec(3);    
end


%% Chord

chord=aircraft.wings.c(wingNum,:)';
        
%% Twiste and Dihed

twist(1,1)=aircraft.wings.TW(wingNum,1,1);
dihed(1,1)=aircraft.wings.dihed(wingNum,1);
for i=1:aircraft.wings.nelem(1,wingNum)
    twist(i+1,1)=0;%aircraft.wings.TW(wingNum,i,2);
    dihed(i+1,1)=aircraft.wings.dihed(wingNum,i);
end

%% Airfoils

% Delete dubblel Points fom airfiol
for i=1:aircraft.wings.nelem(1,wingNum)+1          
    [newAirfoil{i,1}]=uniqueColumn(aircraft.airfoils{i,2});
end

% rotate airfoil (for incuding a twist)
for i=1:1:size(newAirfoil,1)
    currAirfiol=newAirfoil{i,1};

    % Rotation point
    p=[0.25,0,0];
    % Rotation Vector
    r=[0 twist(i,1)*180/pi 0];%+absRot;    

    onesVec=ones(size(newAirfoil{i,1},1),1);

    % Discplacement of airfoil
    currAirfiol=currAirfiol-[p(1)*onesVec,p(2)*onesVec,p(3)*onesVec];

    % Transformation Matrix
    [transMat] = eulerTrans(r(1),r(2),r(3),'xyz');

    % Rotation of airfoil and re-displacement
    rotAirfoil{i,1}=[transMat*currAirfiol']'+[p(1)*onesVec,p(2)*onesVec,p(3)*onesVec];
    
    % plot3(newAirfoil{i,1}(:,1),newAirfoil{i,1}(:,2),newAirfoil{i,1}(:,3))
    % hold on
    % plot3(rotAirfoil{i,1}(:,1),rotAirfoil{i,1}(:,2),rotAirfoil{i,1}(:,3),'r')
    % axis equal
end    


% Write a Chracter fiel of the Points
airfoils={};
for i=1:aircraft.wings.nelem(1,wingNum)+1    
    numAirfoil=[rotAirfoil{i,1}(:,1),rotAirfoil{i,1}(:,3)];
    foilstr=char(' ');
    for ii=1:1:size(numAirfoil,1)
        foilstr=[foilstr,num2str(numAirfoil(ii,1)),' ',num2str(numAirfoil(ii,2)),'   '];
    end    
    airfoils{i,1}(1,:)=char(foilstr);
end

%% Gen new file

symmetry=CPACSgeo.wings.component{1,1}.symmetry;

% Counter
try 
    count=size(NewS.Assembly.WingSkeleton,2)+1;
catch
    count=1;
end

% Set Basic settings
if wingNum==3
    NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='detectwinglet,';%'autosym,detectwinglet,'
    
    % Extent the wing (only for vertical wings dh=90°)
    x1=xPos(1,1);
    x2=xPos(2,1);
    k1=sqrt(yPos(1,1)^2+zPos(1,1)^2);
    k2=sqrt(yPos(2,1)^2+zPos(2,1)^2);
    b=(k1-x1/x2*k2)/(1-x1/x2);
    m=(k1-b)/x1;
    k=0;
    x=(k-b)/m;
    y=0;
    z=k;
    
    xPos=[x;xPos];
    yPos=[y;yPos];
    zPos=[z;zPos];
    
    c1=chord(1,1);
    c2=chord(2,1);    
    c=(c1-c2)/(k2-k1)*(k2-k)+c2;
    chord=[c;chord];
    
    twist=[twist(1,1);twist];
    dihed=[dihed(1,1);dihed];    
    airfoils=[airfoils(1,1);airfoils];   
    
else
    NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='autosym,detectwinglet,';
    NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='detectwinglet,';
end
NewS.Assembly.WingSkeleton{1,count}.Attributes.name=['Wing',num2str(wingNum)];
NewS.Assembly.WingSkeleton{1,count}.Attributes.origin=' 0 0 0 ';
NewS.Assembly.WingSkeleton{1,count}.Attributes.rotation=' 0 0 0 ';

% NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Scale             = s.Assembly.WingSkeleton.WingCriterion.Scale;
% NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Breaks            = s.Assembly.WingSkeleton.WingCriterion.Breaks;
% NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Kinks             = s.Assembly.WingSkeleton.WingCriterion.Kinks;
% NewS.Assembly.WingSkeleton{1,count}.WingCriterion.KinkTangents      = s.Assembly.WingSkeleton.WingCriterion.KinkTangents;
% NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Attributes        = s.Assembly.WingSkeleton.WingCriterion.Attributes;

% Other
% NewS.Assembly.WingSkeleton{1,count}.Cap=s.Assembly.WingSkeleton.Cap;

% WingCriterion
% WingCriterion=s.Assembly.WingSkeleton.WingCriterion.RefinementRegion{1,1}.Attributes;

% Generate the new struct
for i=1:size(xPos,1)     
    % aifoil name
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.airfoil='airfoilName';
    % WingSectionName
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.name='WingSectionName';


    % Position of section
    center=num2str([xPos(i,1),yPos(i,1),zPos(i,1)]);% [ledaing edge position, y pos,zPos]
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.center=center; 

    % airfoil
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Text= airfoils{i,1}(1,:);

    % Chord
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.chord=num2str(chord(i,1));

    % Dihedral (is the dihedral of the airfoil)
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.dihedral=num2str(dihed(i,1));

    % Twist (arround the leading edge --> currently not neded, above there is a rotationg of airfoils)
    % NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.twist=num2str(twist(i,1));
    % NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.twist=num2str(absRot(1,1))
    % NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.yaw=num2str(0/180*pi);

    % Other Parameter
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.napprox='-1';
    NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.vbreak='true';    
end

% NewS.Assembly.WingSkeleton{1,count}.WingSection{1,10}.Attributes.twist=num2str(45/180*pi)

%% Gen new file

% for i=1:size(xPos,1)
%     
%     % aifoil name
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.airfoil='airfoilName';
%     % WingSectionName
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.name='WingSectionName';
%     
%     
%     % Position of section
%     center=num2str([xPos(i,1),yPos(i,1),zPos(i,1)]);% [ledaing edge position, y pos,zPos]
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.center=center; 
% 
%     % airfoil
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Text= airfoils{i,1}(1,:);
% 
%     % Chord
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.chord=num2str(aircraft.wings.c(wingNum,i));
%     % Dihedral
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.dihedral=num2str(dihed(i,1));
%     % Twist
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.twist=num2str(twist(i,1));
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.yaw=num2str(0/180*pi);
% 
%     % Other Parameter
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.napprox='-1';
%     NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.vbreak='false';%'true';
% 
%     %WingCriterion used for every section
% %     NewS.Assembly.WingSkeleton{1,count}.WingCriterion.RefinementRegion{1,i}.Attributes=WingCriterion;
% end
