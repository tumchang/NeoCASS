%bilinear interpolation
close all, clear all, clc

% Xi=[0 0 0;...
%     1 1 1;...
%     2 4 2;...
%     1 3 1];

Xi=[0 0 0;...
    1 0 0;...
    1 1 0;...
    0 1 0];
for i=1:3
    Xi3D(:,:,i)=[Xi(1,i) Xi(2,i);...
                 Xi(4,i) Xi(3,i)];
end

pnt=[2 0.5 0];
%         node=[0 0;1 0;1 1;0 1];
node=Xi;
%         syms u v real
%         No=[1 u v u*v];
%         for i=1:4, Noi(i,:)=subs(No,{u,v},{node(i,1), node(i,2)});  end ,  
%         Aic=Noi\eye(4);     N=No*Aic; 
        Aic =[     1     0     0     0
                  -1     1     0     0
                  -1     0     0     1
                   1    -1     1    -1];
% for i=1:3               
%     pnt(i)=[1 u v u*v]*Aic*Xi(:,i);
% end


syms u v real
mi=[1 u v u*v]*Aic
for i=1:3
    
    Mi(i)=[1 u v u*v]*Aic*Xi(:,i);
end
               
figure(1),hold on, axis equal   

surf(Xi3D(:,:,1),Xi3D(:,:,2),Xi3D(:,:,3))
plot3(pnt(1),pnt(2),pnt(3),'o')
