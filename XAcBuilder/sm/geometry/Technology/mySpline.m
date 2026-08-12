%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mySpline
% Dedicated spline function 
%
%   INPUT 
%       pID : profileID
%       Xi  : interpolation points
%       PLOT: flag PLOT 
%
%   OUTPUT 
%       iSpline.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     13.10.13     1.0    F.Dinardo        Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iSpline=mySpline(pID,Xi,PLOT)
global Curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close all, clear all, clc
% figure, axis equal
% pID=1; PLOT=1;
% Xi=[1   0.     0;...
%     .9  .015   0;...
%     .8  .025   .5;...
%     .7  .038   0;...
%     .5  .045   0;...
%     .35 -.5   0.2;...
%     0.7  -.8   0];%;...
% %    .1  .045   0];%;...
% %     .05 .03    0;...
% %      0.  0.     0%...
% %     .05 -.03   0;...
% %     .1  -.045  0;...
% %     .2  -.055  0;...
% %     .35  -.047 0;...
% %     .5  -.045  0;...
% %     .7  -.038  0;...
% %     .8  -.025  0;...
% %     .9  -.015  0;...
% %     1   0.     0];
% [output]=posVectFun(1,1,Xi,[0 0 0]')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=length(Xi(:,1))-1;

dX1=[0 0 0]; dXN1=[0 0 0];

for i=2:N
    if i==2,         
        for j=1:3, dXi_n(i-1,j)=-3*Xi(i-1,j)+3*Xi(i+1,j)-dX1(j); end
    elseif i>2 && i<N
        for j=1:3, dXi_n(i-1,j)=-3*Xi(i-1,j)+3*Xi(i+1,j);        end    
    elseif i==N
        for j=1:3, dXi_n(i-1,j)=-3*Xi(i-1,j)+3*Xi(i+1,j)-dXN1(j);end
    end
end

dA=diag(4*ones(1,N-1)); dA=dA+diag(ones(1,N-2),1); dA=dA+diag(ones(1,N-2),-1); %dA

dXi=dA\dXi_n;

dXi=[dX1;dXi;dXN1];

X=Xi(1,:);

for i=1:N
   [X_tmp]=my_iSpline(Xi(i:i+1,:),dXi(i:i+1,:),PLOT);
   X=[X;X_tmp(2:end,:)];
end


if PLOT
    Curve(pID)=line(X(:,1),X(:,2),X(:,3),'LineWidth',1,'Color','k');    
    set(Curve(pID),...
        'DisplayName',['Curve' num2str(pID) '_Profile'],...
        'Tag',['Curve' num2str(pID) '_Profile']);
   
end
iSpline=struct('pID',pID,'pnt0i',{Xi},'dpt0i',{dXi},'pnt',{X});
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X]=my_iSpline(Xi,dXi,PLOT)  
for j=1:3    
    A(:,j)=[  Xi(1,j);...
             dXi(1,j);...
           -3*Xi(1,j)+3*Xi(2,j)-2*dXi(1,j)-dXi(2,j);...
            2*Xi(1,j)-2*Xi(2,j) + dXi(1,j)+dXi(2,j)];
end    
t=linspace(0,1,11);
for i=1:length(t)
    X(i,:)=[ 1 t(i) t(i)^2  t(i)^3 ]*A;
end 
%X,Xi
%X=X';Xi=Xi';   

%plot3(Xi(:,1),Xi(:,2),Xi(:,3),'or')
%plot3(Xi(:,1),Xi(:,2),Xi(:,3),'--r')
% if PLOT
%     plot3(X(:,1),X(:,2),X(:,3),'b')
% end
end
