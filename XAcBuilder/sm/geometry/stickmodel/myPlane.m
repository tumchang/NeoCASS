function myPlane(pnt,dir)

%% Point, Direction
%     close all, clear all,clc
%     pnt=[0 0 0]';
%     dir  =[1 1 1]';
    %check dimension
        if length(pnt)~=3, disp('Point must be: P=P(x y z)'''); end
        if length(dir)~=3, disp('dir must be: dir=dir(x y z)'''); end
    %check vector column    
        if length(pnt(1,:))>length(pnt(:,1)),  pnt=pnt'; end
        if length(dir(1,:))>length(dir(:,1)),  dir=dir';   end
    % normalize normal direction-> normal versor
        n=dir/norm(dir);
    % projector
        prj  =eye(3)-n*n';
    % tangent & binormal versor
        if norm(prj(:,1))~=0
            t = prj(:,1)/norm(prj(:,1)); 
        elseif norm(prj(:,2))~=0
            t = prj(:,2)/norm(prj(:,2)); 
        else
            t = prj(:,3)/norm(prj(:,3)); 
        end
        b = cross(n,t);
    % vertex of plane
        iPlane.pnt(:,1)=pnt-t-b;
        iPlane.pnt(:,2)=pnt+t-b;
        iPlane.pnt(:,3)=pnt+t+b;
        iPlane.pnt(:,4)=pnt-t+b;
%% Plot  
    hold on,axis equal
%     plot3(pnt(1),pnt(2),pnt(3),'sr')
    quiver3(pnt(1),pnt(2),pnt(3),n(1),n(2),n(3))     ,text(pnt(1)+n(1),pnt(2)+n(2),pnt(3)+n(3),'n')
%     quiver3(pnt(1),pnt(2),pnt(3),t(1),t(2),t(3))     ,text(pnt(1)+t(1),pnt(2)+t(2),pnt(3)+t(3),'t')
%     quiver3(pnt(1),pnt(2),pnt(3),b(1),b(2),b(3))     ,text(pnt(1)+b(1),pnt(2)+b(2),pnt(3)+b(3),'b')
    
%     plot3(iPlane.pnt(1,:),iPlane.pnt(2,:),iPlane.pnt(3,:),'o')
    X=[iPlane.pnt(1,1) iPlane.pnt(1,2);...
       iPlane.pnt(1,4) iPlane.pnt(1,3)];
    Y=[iPlane.pnt(2,1) iPlane.pnt(2,2);...
       iPlane.pnt(2,4) iPlane.pnt(2,3)];
    Z=[iPlane.pnt(3,1) iPlane.pnt(3,2);...
       iPlane.pnt(3,4) iPlane.pnt(3,3)];
   
    surf(X,Y,Z,'EdgeAlpha',0.2,'FaceAlpha',0.2,'FaceColor',[0. 0.5 1])
end
