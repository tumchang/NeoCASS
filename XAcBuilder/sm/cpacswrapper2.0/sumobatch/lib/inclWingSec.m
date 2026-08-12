function [NewS] = inclWingSec(NewS,aircraft,wingNum,CPACS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inclWingSec                                                           %
%   Include the wing section wise                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-06-30 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set new Structure
%% Sweep

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

% xPos(1,1)=aircraft.wings.startx(1,wingNum);
% yPos(1,1)=aircraft.wings.starty(1,wingNum);
% zPos(1,1)=aircraft.wings.startz(1,wingNum);
% 
% for i=1:aircraft.wings.nelem(1,wingNum)
%     if aircraft.wings.dihed(wingNum,i)<90/180*pi %Horizontal Wing
%         xPos(i+1,1)=sum(aircraft.wings.b(wingNum,1:i).*tan(aircraft.wings.SWle(wingNum,1:i)))+xPos(1,1);
%         yPos(i+1,1)=sum(aircraft.wings.b(wingNum,1:i))+ yPos(1,1);
%         zPos(i+1,1)=sum(aircraft.wings.b(wingNum,1:i).*tan(aircraft.wings.dihed(wingNum,1:i)))+zPos(1,1);
%     else % Vertical wing
%         xPos(i+1,1)=sum(aircraft.wings.b(wingNum,1:i).*tan(aircraft.wings.SWle(wingNum,1:i)))+xPos(1,1);
%         zPos(i+1,1)=sum(aircraft.wings.b(wingNum,1:i))+ yPos(1,1);
%         yPos(i+1,1)=sum(aircraft.wings.b(wingNum,1:i).*tan(90/180*pi-aircraft.wings.dihed(wingNum,1:i)))+yPos(1,1);
%     end       
% end


wingNames=fieldnames(CPACS.wings);
absPos = CPACS.wings.(wingNames{wingNum,1}).global{1,1}(1,:);
for i=1:size(CPACS.wings.(wingNames{wingNum,1}).local,1)
    locVec=CPACS.wings.(wingNames{wingNum,1}).local{i,2}(1,:);
    posVec(i,:)=locVec+absPos;
    xPos(i,1)=posVec(i,1);
    yPos(i,1)=posVec(i,2);
    zPos(i,1)=posVec(i,3);    
end
        
%% Twiste and Dihed

twist(1,1)=aircraft.wings.TW(wingNum,1,1);
dihed(1,1)=aircraft.wings.dihed(wingNum,1);
for i=1:aircraft.wings.nelem(1,wingNum)
    twist(i+1,1)=aircraft.wings.TW(wingNum,i,2);
    dihed(i+1,1)=0;
    %dihed(i+1,1)=aircraft.wings.dihed(wingNum,i)*sign(aircraft.wings.b(wingNum,i));
end

%% Airfoils

% Delete dubblel Points fom airfiol
for i=1:aircraft.wings.nelem(1,wingNum)+1          
    [newAirfoil{i,1}]=uniqueColumn(aircraft.airfoils{i,2});
end
 
% Write a Chracter fiel of the Points
airfoils={};
for i=1:aircraft.wings.nelem(1,wingNum)+1    
    numAirfoil=[newAirfoil{i,1}(:,1),newAirfoil{i,1}(:,3)];
    foilstr=char(' ');
    for ii=1:1:size(numAirfoil,1)
        foilstr=[foilstr,num2str(numAirfoil(ii,1)),' ',num2str(numAirfoil(ii,2)),'   '];
    end    
    airfoils{i,1}(1,:)=char(foilstr);
end


%% Gen new file

try 
    count=size(NewS.Assembly.WingSkeleton,2)+1;
catch
    count=1;
end

% count=0;

for i=1:size(xPos,1)-1
    
    
    % Wingsettings (Attributes)
    
%     if wingNum==3
        NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='detectwinglet,';%'autosym,detectwinglet,'
%     else
%         NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='autosym,detectwinglet,';
%     end
    NewS.Assembly.WingSkeleton{1,count}.Attributes.name=['Wing',num2str(wingNum)];
    NewS.Assembly.WingSkeleton{1,count}.Attributes.origin=' 0 10 0 ';
    NewS.Assembly.WingSkeleton{1,count}.Attributes.rotation=' 0 0 0 ';
    
    
    for k=1:2        
         % aifoil name
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.airfoil='airfoilName';
        % WingSectionName
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.name='WingSectionName';


        % Position of section
        center=num2str([xPos(i+k-1,1),yPos(i+k-1,1),zPos(i+k-1,1)]);% [ledaing edge position, y pos,zPos]
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.center=center; 

        % airfoil
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Text= airfoils{i,1}(1,:);

        % Chord
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.chord=num2str(aircraft.wings.c(wingNum,i+k-1));
        % Dihedral
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.dihedral=num2str(dihed(i+k-1,1));
        % Twist
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.twist=num2str(twist(i+k-1,1));
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.yaw=num2str(0/180*pi);

        % Other Parameter
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.napprox='-1';
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,k}.Attributes.vbreak='true';
    end
    
    count=count+1;

end


