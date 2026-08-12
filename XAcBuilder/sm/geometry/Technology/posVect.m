%function []=posVect(pnt0)
 close all, clear all, clc
% pnt0=[0 0 0;...
%       1 1 0;...
%       2 1 1;...
%       3 0 1];
PosVect=[0         1.9750    0     ;...
         2.0698    3.1752    0.2778;...
         5.8599    8.9562    1.0997;...
         0.5384    0.6351    0.5329;...
         0.5412    0.2851    0.7832;...
         0.7082    0.0000    1.0905;...
         0.5412   -0.2851    0.7832;...
         0.5384   -0.6351    0.5329;...
         6.7535  -10.3219    1.2674;...
         0.5996   -3.7850    0.0661];  

N=length(PosVect(:,1))+1;
pnt0=zeros(N,3);
pntP=zeros(N,3);
li  =zeros(N,1);
sl  =zeros(N,1);
eta =zeros(N,1);
n=[1 0 0]';
prj=eye(3)-n*n';
%project vector on a plane 
for i=2:N
    pnt0(i,:)=[sum(PosVect(1:i-1,1)),sum(PosVect(1:i-1,2)),sum(PosVect(1:i-1,3))];    
    pntP(i,:)=(prj*pnt0(i,:)')';  
    li(i)=norm(pntP(i,:)'-pntP(i-1,:)');
    sl(i)=sl(i-1)+li(i);
end
L=sl(end);
for i=2:N
    eta(i)=sl(i)/L;
end

etaS=0.8;
ieta=1;
while eta(ieta)<etaS
    
    if eta(ieta)<etaS,disp([num2str(ieta)]), end
    ieta=ieta+1;
end
ieta=ieta-1;
C=((pnt0(ieta+1,:)'-pnt0(ieta,:)')*(etaS-eta(ieta))+pnt0(ieta,:)')';

    
        
    
hold on, axis equal    
plot3(pnt0(:,1),pnt0(:,2),pnt0(:,3))  
plot3(pntP(:,1),pntP(:,2),pntP(:,3),'r')
plot3([pnt0(1:ieta,1);C(1)],[pnt0(1:ieta,2);C(2)],[pnt0(1:ieta,3);C(3)],'g','Linewidth',3)
