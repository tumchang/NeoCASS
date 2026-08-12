function newSpline=airfoilInterp(spline,numOfPoints)

for i=1:size(spline,1);  
    
    % Distacnce between each point
    diffVec=spline{i,1}(1:end-1,:)-spline{i,1}(2:end,:);
    lengthVec=sqrt(sum(diffVec.*diffVec,2));
    
    % Position on the lenths of the spline
    for ii=1:size(lengthVec,1)
        lengthVecAbs(ii,1)=sum(lengthVec(1:ii,1));
    end
    
    % The Lenths of the spliee
    splineLength=sum(lengthVec);
    
    % New distance between the points
    newLength=splineLength/(numOfPoints-1);
    
    % New point position on the spline
    pointPos=(newLength:newLength:splineLength)';
    
    if ~isempty(spline{i,1})
        % Use the first point
        newSpline{i,1}(1,:)=spline{i,1}(1,:);

        % Linear interpolation beween two points
        for ii=1:size(pointPos,1)
            % Find the new piont
            fp=find(pointPos(ii,1)>lengthVecAbs==0)-1;

            % Local position of the new point between left and right old points
            if fp(1)==0
                dSp=pointPos(ii,1);
            else
                dSp=pointPos(ii,1)-lengthVecAbs(fp(1));
            end
            dSs=lengthVec(fp(1)+1,1);

            % left and right old points
            p1=spline{i,1}(fp(1)+1,:);
            p2=spline{i,1}(fp(1)+2,:);

            % New Point Location
            p12=p2-p1;
            p3=p1+p12*dSp/dSs;

            % Add new point to new spline
            newSpline{i,1}(ii+1,:)=p3;              
        end
    end
    
    % Add minimum point
    [nN,mN]=min(newSpline{i,1}(:,1));
    [n,m]=min(spline{i,1}(:,1));
    if nN~=n
        minPoint=spline{i,1}(m,:);
        [nN2,mN2]=sort(newSpline{i,1}(:,1));
        lr=mN2(1:2);
        newSpline{i,1}=[newSpline{i,1}(1:min(lr),:);minPoint;newSpline{i,1}(max(lr):end,:)];
    end
      
      
    % Plot for Compare
%         hold on
%         plot3(newSpline{i,1}(:,1),newSpline{i,1}(:,2),newSpline{i,1}(:,3),'r')
%         plot3(newSpline{i,1}(:,1),newSpline{i,1}(:,2),newSpline{i,1}(:,3),'*r')
%         
%         plot3(spline{i,1}(:,1),spline{i,1}(:,2),spline{i,1}(:,3),'k')
%         plot3(spline{i,1}(:,1),spline{i,1}(:,2),spline{i,1}(:,3),'k*')
%         axis equal
    %     
    %     hold on
    %     plot(newSpline{i,1}(:,1),newSpline{i,1}(:,3),'r')
    %     plot(newSpline{i,1}(:,1),newSpline{i,1}(:,3),'*r')
    %     
    %     plot(spline{i,1}(:,1),spline{i,1}(:,3),'k')
    %     plot(spline{i,1}(:,1),spline{i,1}(:,3),'k*')
    %     axis equal
    
end
