%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mySpline
% Dedicated cubicPatch function 
%
%   INPUT 
%       sID    : surfaceID
%       spline1:  
%       spline2:
%
%   OUTPUT 
%       iSurf.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     10.10.13     1.0    F.Dinardo        Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iSurf=mySurfCub(sID,spline1,spline2)

global Surf

N1=length(spline1.pnt0i); N2=length(spline2.pnt0i); 
if N1~=N2
    disp('spline1 & spline2 hasn''t same number of point');
    N1=min(N1,N2);
end
    
j=1; k=1;
for i=1:N1-1
    spline1.pnt0i(i:i+1,:);
    spline2.pnt0i(i+1:i,:);
    Xi(j:j+3,:)=[spline1.pnt0i(i:i+1,:);spline2.pnt0i(i+1:-1:i,:)];
    dXi_u(j:j+3,:)=[spline1.dpt0i(i:i+1,:);spline2.dpt0i(i+1:-1:i,:)];
    [X_tmp]=my_iSurfBCub(Xi(j:j+3,:),dXi_u(j:j+3,:));
    j=j+4;
    if i==1
       X=[X_tmp];
    else
       X=[X, X_tmp(:,2:end,:)]; 
    end
end
%Dominio della superficie
XD=[min(min(X(:,:,1))) max(max(X(:,:,1)))];
YD=[min(min(X(:,:,2))) max(max(X(:,:,2)))];
ZD=[min(min(X(:,:,3))) max(max(X(:,:,3)))];
D=[XD;YD;ZD];

%IDs profiles
iSurf=struct('ID_s',sID,'IDs_p',[spline1.pID spline2.pID],'pnt',X,'domain',D);

%plot3(Xi(:,1),Xi(:,2),Xi(:,3),'or')
Surf(sID)=surfl(X(:,:,1),X(:,:,2),X(:,:,3));
set(Surf(sID),...
    'DisplayName',['Surf' num2str(sID)],...
    'Tag'        ,['Surf' num2str(sID)]);%,...
%     'EdgeColor'  ,'none',...
%     'FaceAlpha'  ,0.4,...
%     'FaceColor'  ,[.5 .5 .5]);
%set(Surf(sID),'parent',handles)



%plot domain
% plot3([XD(1) XD(2) XD(2) XD(1) XD(1)],[YD(1) YD(1)  YD(2) YD(2) YD(1)],[ZD(1) ZD(1) ZD(1) ZD(1) ZD(1)],'b')
% plot3([XD(1) XD(2) XD(2) XD(1) XD(1)],[YD(1) YD(1)  YD(2) YD(2) YD(1)],[ZD(2) ZD(2) ZD(2) ZD(2) ZD(2)],'b')
% plot3([XD(1) XD(1)],[YD(1) YD(1)],[ZD(1) ZD(2)],'b')
% plot3([XD(2) XD(2)],[YD(1) YD(1)],[ZD(1) ZD(2)],'b')
% plot3([XD(2) XD(2)],[YD(2) YD(2)],[ZD(1) ZD(2)],'b')
% plot3([XD(1) XD(1)],[YD(2) YD(2)],[ZD(1) ZD(2)],'b')
%shading flat
%shading faceted
%shading interp
%colormap(gray);
%xlabel('x'),ylabel('y'),zlabel('z')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X]=my_iSurfBCub(Xi,dXi_u)
%close all, clear all, clc
Xi;dXi_u;

dXi_v=[0 0 0;...
       0 0 0;...
       0 0 0;...
       0 0 0];
dXi_uv=[0 0 0;...
        0 0 0;...
        0 0 0;...
        0 0 0]; 
   
M=[1  0  0  0;...
   0  0  1  0;...
  -3  3 -2 -1;...
   2 -2  1  1];

for j=1:3
    X0i(:,:,j)=[   Xi(1,j)    Xi(4,j)   dXi_u(1,j)  dXi_u(4,j);...
                   Xi(2,j)    Xi(3,j)   dXi_u(2,j)  dXi_u(3,j);...
                  dXi_v(1,j) dXi_v(4,j) dXi_uv(1,j) dXi_uv(4,j);...
                  dXi_v(2,j) dXi_v(3,j) dXi_uv(2,j) dXi_uv(3,j)];
end

u=linspace(0,1,3);
v=linspace(0,1,2);

for i=1:length(u)
    for j=1:length(v)
        for k=1:3
            X(i,j,k)=[1 v(j) v(j)^2 v(j)^3]*M*X0i(:,:,k)*M'*[1 u(i) u(i)^2 u(i)^3]';
        end
    end
end
%X
%figure, hold on, axis equal, view([30 30]),grid on
%%plot3(Xi(:,1),Xi(:,2),Xi(:,3),'or')
% surfl(X(:,:,1),X(:,:,2),X(:,:,3))
% %shading flat
% %shading faceted
% shading interp
% colormap(gray);
% xlabel('x'),ylabel('y'),zlabel('z')
end