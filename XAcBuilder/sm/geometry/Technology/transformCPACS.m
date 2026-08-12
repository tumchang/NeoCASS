%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transformCPACS
% Dedicated Tech trasformation function 
%
%   INPUT 
%       Transformation:  CPACSstruct, struct containing vectors of rotation, scaling and translation
%       profile       :  cell array of point list, xyz in row
%       PlotFlag      :  0)no  1)yes, indicate also number of figure
%
%   OUTPUT 
%       profile_transformed: cell array of point list xyz in row
%       R321               : rotation Matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     10.10.13     1.0    F.Dinardo        Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [profile_transformed R321]=transformCPACS(Transformation,profile,PlotFlag)
rad=pi/180;
%size(profile)
phi(1)=str2num(Transformation.rotation{1}.x{1}.CONTENT);
phi(2)=str2num(Transformation.rotation{1}.y{1}.CONTENT);
phi(3)=str2num(Transformation.rotation{1}.z{1}.CONTENT);
%Trasformation.scaling{1}
scl(1)=str2num(Transformation.scaling{1}.x{1}.CONTENT);
scl(2)=str2num(Transformation.scaling{1}.y{1}.CONTENT);
scl(3)=str2num(Transformation.scaling{1}.z{1}.CONTENT);
%Trasformation.translation{1}
trsl(1)=str2num(Transformation.translation{1}.x{1}.CONTENT);
trsl(2)=str2num(Transformation.translation{1}.y{1}.CONTENT);
trsl(3)=str2num(Transformation.translation{1}.z{1}.CONTENT);

N=length(profile);
phi=phi*rad;
R3=[cos(phi(3)) -sin(phi(3))     0      ;...
    sin(phi(3))  cos(phi(3))     0      ;...
       0           0             1      ];
   
R2=[cos(phi(2))    0         sin(phi(2));...
     0             1            0       ;... 
   -sin(phi(2))    0         cos(phi(2))]; 
      
R1=[   1           0            0       ;...
       0        cos(phi(1)) -sin(phi(1));...
       0        sin(phi(1))  cos(phi(1))];
R321=R3*R2*R1;   
for i=1:N
    profile_transformed(i,:)=(R321*(diag(scl)*profile(i,:)')+trsl')';
end

if PlotFlag>0
    figure(PlotFlag),hold on,axis equal, grid on
    plot3(profile_transformed(:,1),profile_transformed(:,2),profile_transformed(:,3),'.r')
    xlabel('x'),ylabel('y'),zlabel('z')
end