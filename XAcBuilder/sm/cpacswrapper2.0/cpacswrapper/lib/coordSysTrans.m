function [airfoil,compDesc]=coordSysTrans(trans,CPACS_XML,SecNum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  coordSysTrans                                                          %
%  Tranformation of the CPACS coordinatesystem definition.                %
%  Include the Transformation:                                            %
%  1. to WingCoord.Sys                                                    %
%  2. to Section Coord.Sys + Positionings                                 %
%  3. to Element Coord.Sys                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-25 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Use external Function:                                                  %
%       -  coordSysPlot                                                   %
%       -  sphere3D                                                       %
%       -  eulerTrans                                                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inputs

%%%%%%%%%%%%%
% Reference %
%%%%%%%%%%%%%

% Is visable setting
visable=trans.visible(1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Tranformation (to wingCoord.Sys) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trans1=trans.tranlation(:,1);
scal1=trans.scaling(:,1);
rot1=trans.rotation(:,1);

% Is visable setting
visable1=trans.visible(1,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Tranformation (to section Coord.Sys) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trans2=trans.tranlation(:,2);
scal2=trans.scaling(:,2);
rot2=trans.rotation(:,2);

% Is visable setting
visable2=trans.visible(1,3);

% Positioning vector 
posVAbsVec = trans.poitioning.vector;
dihedral   = trans.poitioning.dihedral;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Tranformation (to Element Coord.Sys) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trans3=trans.tranlation(:,3);
scal3=trans.scaling(:,3);
rot3=trans.rotation(:,3);

% Is visable setting
visable3=trans.visible(1,4);
visable4=trans.visible(1,5);

%% Airfoil Definition

airfoil=[];
airfoil=trans.airfoil;
airfoilBasic=airfoil;

%% Reference Coordinate system

% Reference Coordinate System Mtarix
globalChoord=[1 0 0;...
              0 1 0;...
              0 0 1];
% Referenc% Point          
globalRefPoint=[0 0 0]';
p=globalRefPoint;

if visable==1
    % Plot Ref Point
    sphere3D(p,0.1)

    % Plot Cpordinate system
    sysColor='r';
    sysName='glob';
    coordSysPlot(p,globalChoord,sysColor,sysName)
end

%% 1. Tranformation (to wingCoord.Sys)

% Scale Matrix
eyeMat=eye(3);
scaleMat1=[eyeMat(1,:)*scal1(1);eyeMat(2,:)*scal1(2);eyeMat(3,:)*scal1(3)];

% Euler Transformation
[transMat1] = eulerTrans(rot1(1,1),rot1(2,1),rot1(3,1));

% Transformed Coordysytem
coordSys1=transMat1*globalChoord*scaleMat1;

% Transformed point
p1=(p+trans1);

if visable1==1
    % Plot Ref Point
    sphere3D(p1,0.1)
    % Plot Coordinate System
    sysColor='g';
    sysName='wing';
    coordSysPlot(p1,coordSys1,sysColor,sysName)
    % Plot Displacment line
    plot3([p1(1),p(1)],[p1(2),p(2)],[p1(3),p(3)],'k','LineWidth',2) 
end

% Plot test Airfoil
% airfoil=[coordSys1*airfoilBasic']'+[p1(1)*ones(size(airfoilBasic,1),1),p1(2)*ones(size(airfoilBasic,1),1),p1(3)*ones(size(airfoilBasic,1),1)];
% plot3(airfoil(:,1),airfoil(:,2),airfoil(:,3),'b','LineWidth',2)

%% 2. Tranformation (to section Coord.Sys)

trans2=coordSys1*trans2;

% Scale Matrix
eyeMat=eye(3);
scaleMat2=[eyeMat(1,:)*scal2(1);eyeMat(2,:)*scal2(2);eyeMat(3,:)*scal2(3)];

% Positioning vector (sweep, dihed and length)
xposAbs=posVAbsVec(1);
yposAbs=posVAbsVec(2);
zposAbs=posVAbsVec(3);
posAbs=coordSys1*[xposAbs,yposAbs,zposAbs]';%Definition#

% Euler Transformation
[transMat2] = eulerTrans(rot2(1,1),rot2(2,1),rot2(3,1));

% Transformed Coordysytem
coordSys2=coordSys1*transMat2*scaleMat2;

% Plot with positenings
if max(posAbs)~=0
    posGlob=posAbs.*scal1+p1;
    if visable2==1
        sysColor=[0.7 0.7 0.7];
        sysName='positioning';
        sysName='';
        coordSysPlot(posGlob,coordSys2,sysColor,sysName)
        % Plot Displacment line
        plot3([p1(1),posGlob(1)],[p1(2),posGlob(2)],[p1(3),posGlob(3)],'k','LineWidth',2) 
    end
else
    % Global vectorfrom 0 0 0  to section Coord System (if posAbs==0 posGlob=p1)
    posGlob=p1;
end

% Transformed point
p2=posGlob+trans2;%.*scal1;

if visable2==1
    % Plot Ref Point
    sphere3D(p2,0.1)

    % Plot Coordinate System
    sysColor='b';
    sysName=['sec',num2str(SecNum)];
    coordSysPlot(p2,coordSys2,sysColor,sysName)
    % Plot Displacment line
    plot3([p2(1),posGlob(1)],[p2(2),posGlob(2)],[p2(3),posGlob(3)],'k','LineWidth',2) 

    % For corners of xz Area
    xzArea=[0 0 1;...
            1 0 1;...
            0 0 0;...
            1 0 0;]'*1;
    xzArea=[coordSys2*xzArea]+[p2,p2,p2,p2]; 
    X=[xzArea(1,1) xzArea(1,2) ; ...
       xzArea(1,3) xzArea(1,4)];

    Y=[xzArea(2,1) xzArea(2,2) ; ...
       xzArea(2,3) xzArea(2,4)];

    Z=[xzArea(3,1) xzArea(3,2) ; ...
       xzArea(3,3) xzArea(3,4)];
    surf(X,Y,Z,'FaceColor','b', 'EdgeColor', 'none')
    alpha(0.5)

    txtVec=xzArea(:,1)-(xzArea(:,1)-xzArea(:,4))/2;
    text(txtVec(1),txtVec(2),txtVec(3),'section','FontSize',15,'HorizontalAlignment','center') 
end
% Plot test Airfoil
% airfoil=[coordSys2*airfoilBasic']'+[p2(1)*ones(size(airfoilBasic,1),1),p2(2)*ones(size(airfoilBasic,1),1),p2(3)*ones(size(airfoilBasic,1),1)];
% plot3(airfoil(:,1),airfoil(:,2),airfoil(:,3),'b','LineWidth',2)
%% 3. Tranformation (to Element Coord.Sys)

trans3=coordSys2*trans3;

% Scale Matrix
eyeMat=eye(3);
scaleMat3=[eyeMat(1,:)*scal3(1);eyeMat(2,:)*scal3(2);eyeMat(3,:)*scal3(3)];

% Extra Dihed Rotation
if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<2  
    R=[1 0 0;0 cos(dihedral/180*pi) -sin(dihedral/180*pi);0 sin(dihedral/180*pi) cos(dihedral/180*pi)];
else %CPACS VERSION 2.0
    R=[1 0 0;0 1 0;0 0 1];
end

% Euler Transformation
[transMat3] = eulerTrans(rot3(1,1),rot3(2,1),rot3(3,1));

% Transformed Coordysytem
coordSys3=R*coordSys2*transMat3*scaleMat3;

% Transformed point
p3=p2+trans3;%.*scal2;

if visable3==1
    % Plot Ref Point
    sphere3D(p3,0.1)
    % Plot Coordinate System
    sysColor='r';
    sysName='seg1';
    coordSysPlot(p3,coordSys3,sysColor,sysName)
    % Plot Displacment line
    plot3([p3(1),p2(1)],[p3(2),p2(2)],[p3(3),p2(3)],'k','LineWidth',2) 

    % For corners of xz Area
    xzArea=[0 0 1;...
            1 0 1;...
            0 0 0;...
            1 0 0;]'*1;
    xzArea=[coordSys3*xzArea]+[p3,p3,p3,p3]; 
    X=[xzArea(1,1) xzArea(1,2) ; ...
       xzArea(1,3) xzArea(1,4)];

    Y=[xzArea(2,1) xzArea(2,2) ; ...
       xzArea(2,3) xzArea(2,4)];

    Z=[xzArea(3,1) xzArea(3,2) ; ...
       xzArea(3,3) xzArea(3,4)];
    surf(X,Y,Z,'FaceColor','r', 'EdgeColor', 'none')
    alpha(0.5)

    txtVec=xzArea(:,1)-(xzArea(:,1)-xzArea(:,4))/2;
    text(txtVec(1),txtVec(2),txtVec(3),'element','FontSize',15,'HorizontalAlignment','center') 
end

% Test Airfoil
airfoil=[coordSys3*airfoilBasic']'+[p3(1)*ones(size(airfoilBasic,1),1),p3(2)*ones(size(airfoilBasic,1),1),p3(3)*ones(size(airfoilBasic,1),1)];
if visable4==1;
    plot3(airfoil(:,1),airfoil(:,2),airfoil(:,3),'k','LineWidth',1)
end

% Save the component description
compDesc{1,1}=p3;
compDesc{1,2}=coordSys3;

%% Plot Settings
if max(trans.visible)~=0
    axis equal;
    grid on;
    hold on
    xlabel('X'); ylabel('Y'); zlabel('Z');
    view(20,10);
end