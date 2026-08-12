function [NewS] = inclFus(NewS,CPACSgeo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inclFus                                                               %
%                                                                         %
%   Include Fuselage component                                            %   
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-08-03 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Stet Basic settings

NewS.Assembly.BodySkeleton.Attributes.rotation = ' 0 0 0 ';
NewS.Assembly.BodySkeleton.Attributes.origin   = ' 0 0 0 ';
NewS.Assembly.BodySkeleton.Attributes.name     = ['Fuselage'];
NewS.Assembly.BodySkeleton.Attributes.akimatg  = 'true';

% Statdar Settings
% NewS.Assembly.BodySkeleton.Cap = s.Assembly.BodySkeleton.Cap;
% NewS.Assembly.BodySkeleton.MeshCriterion = s.Assembly.BodySkeleton.MeshCriterion;
% NewS.Assembly.BodySkeleton.Attributes = s.Assembly.BodySkeleton.Attributes;

%% Set new Structure
%% Frames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete dubblel Points fom airfiol %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count=0;
uniquFoils={};
for i=1:size(CPACSgeo.fuselages.component{1,1}.sectionDef.airfoil,1) 
    if size(CPACSgeo.fuselages.component{1,1}.sectionDef.airfoil{i,1},1)>1
        [uniquFoils{i,1}]=uniqueColumn(CPACSgeo.fuselages.component{1,1}.sectionDef.airfoil{i,1});
    end
end

% Select only one side of fuselage Profile (delete all points wehre y<0)
newFrames={};
newFrames2={};
count=0;

for i=1:size(uniquFoils,1)   
    foil= uniquFoils{i,1};
    if size(foil,1)>0
        count=count+1;
        % If Profile is only a point then create a cicle
        if size(foil,1)==1
            % Round y value
            maxDeci=10; %Maximum decimal places
            foil(:,2)=round(foil(:,2)*10^maxDeci)/(10^maxDeci);
            
            % Make a cicle from Point
            n=48;   % Numbers of point in the cicle
            r=0.01; % Radius of cicle
            angle=[0:pi/n:pi]';
            y=sin(angle)*r;
            z=cos(angle)*r;
            x=zeros(size(z,1),1);
            foil2=ones(size(z,1),1)*foil+[x,y,z];
            % Round Foil
            foil2(:,2)=round(foil2(:,2)*10^maxDeci)/(10^maxDeci);
            foil=foil2;           
        end
        newFrames{count,1}=foil;
        count2=0;
        for ii=1:size(newFrames{count,1}(:,2),1)-1
            if newFrames{count,1}(ii,2)>=0
                count2=count2+1;
                newFrames2{count,1}(count2,1)=newFrames{count,1}(ii,1);
                newFrames2{count,1}(count2,2)=newFrames{count,1}(ii,2);
                newFrames2{count,1}(count2,3)=newFrames{count,1}(ii,3);
                              
            end
            %hold on 
            %plot3(newFrames2{count,1}(:,1),newFrames2{count,1}(:,2),newFrames2{count,1}(:,3))
        end
        if isempty(newFrames2)
             count=count-1;
             warning('There was a Fuselage section found wich will be ignorr')
        end
    end      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete secions wich are too close Mean distance %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count=0;
for i=1:size(newFrames2,1)
%     if ~isempty(newFrames2{i,1})
        count=count+1;
        x(count,1)=newFrames2{i,1}(1,1);   
%     end
end

% Minimum distance Value
minDist=0.2; %0.1 = delete if smaler then 10% of mean value
dx=x(2:end,1)-x(1:end-1,1);
deletSections=dx<mean(dx)*minDist;

% Sum all deleted section an deside if not delete
dxDel=deletSections.*dx;
countDx=dxDel(1,1);
for i=1:size(deletSections,1)-1
    countDx=countDx+dxDel(i+1,1);      
    if dxDel(i+1,1)==0;
        countDx=0;
    end
    if countDx>mean(dx)*minDist
        deletSections(i+1,1)=0;
        countDx=0;
    end 
end

count=1;
newFrames3={};
newFrames3{count,1}=newFrames2{1,1};
%plot3(newFrames2{1,1}(:,1),newFrames2{1,1}(:,2),newFrames2{1,1}(:,3))
for i=1:size(newFrames2,1)-1    
    if ~deletSections(i,1)
        count=count+1;
        newFrames3{count,1}=newFrames2{i+1,1};        
        %hold on
        %plot3(newFrames2{i+1,1}(:,1),newFrames2{i+1,1}(:,2),newFrames2{i+1,1}(:,3))
    else
        disp(['Delete Fuselage Section ',num2str(i+1)])
        %hold on
        %plot3(newFrames2{i+1,1}(:,1),newFrames2{i+1,1}(:,2),newFrames2{i+1,1}(:,3),'r')
    end
end

newFrames2=newFrames3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete dubblel Points fom airfiol %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count=0;
newFrames3={};
for i=1:size(newFrames2,1) 
    if size(newFrames2{i,1},1)>1
        [newFrames2{i,1}]=uniqueColumn(newFrames2{i,1});
    end
    if ~isempty(newFrames2{i,1})&&size(newFrames2{i,1},1)>1
        count=count+1;
        newFrames3{count,1}=newFrames2{i,1};
    end
end
newFrames4=newFrames2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add last frame to clode the fuselage %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% centerY=min(newFrames3{count,1}(:,2))+(max(newFrames3{count,1}(:,2))-min(newFrames3{count,1}(:,2)))/2;
% centerZ=min(newFrames3{count,1}(:,3))+(max(newFrames3{count,1}(:,3))-min(newFrames3{count,1}(:,3)))/2;
% scale=0.01;
% newFrames3{count+1,1}=[newFrames3{count,1}(:,1),(newFrames3{count,1}(:,2)-centerY)*scale+centerY,(newFrames3{count,1}(:,3)-centerZ)*scale+centerZ];
% 

%%%%%%%%%%%%%%%%
% Write string %
%%%%%%%%%%%%%%%%
frames={}; 
count=0;
for i=1:1:size(newFrames4,1)
    numAirfoil=[];    
    
    deltaZ=(max(newFrames4{i,1}(:,3))-min(newFrames4{i,1}(:,3)))/2+min(newFrames4{i,1}(:,3));% verschiebung des koordinaten systems
    [val pos]=sort(atan((newFrames4{i,1}(:,3)-deltaZ)./newFrames4{i,1}(:,2))); %Winlkel zwischen z aches und punkt
    numAirfoil=[newFrames4{i,1}(pos,2),newFrames4{i,1}(pos,3)];
    numAirfoil=[0,numAirfoil(1,2);numAirfoil;0,numAirfoil(end,2)];
    numAirfoil=round(numAirfoil*1000000)/1000000;% rounding
    
    % Make Unique
    [numAirfoil]=uniqueColumn(numAirfoil);
    
    %plot(numAirfoil(:,1),numAirfoil(:,2),'-')
    
    % Delete points wich are to cloese to eache other
    maxDiameter=max(max(numAirfoil(:,1))-min(numAirfoil(:,1)),max(numAirfoil(:,2))-min(numAirfoil(:,2))); % Maximum diameter
    delPos=find((sum(abs(numAirfoil(1:end-1,:)-numAirfoil(2:end,:))<0.01*maxDiameter,2)==2)==1);% calc vectorlength and find the nearest point position
    count2=0;
    numAirfoil2=[];
    for ii=1:size(numAirfoil,1)
        if isempty(find(delPos==ii))
            count2=count2+1;            
            numAirfoil2(count2,:)=numAirfoil(ii,:);
        else
            disp(['del nearest point in ',num2str(i),', ',num2str(ii)])
        end
    end
    numAirfoil=numAirfoil2;
    
    % Write the string
    if size(numAirfoil,1)>1
        count=count+1;
        foilstr=char(' ');
        for ii=1:size(numAirfoil,1)
            stri=['  ',num2str(numAirfoil(ii,1)),' ',num2str(numAirfoil(ii,2)),'   '];
            foilstr=[foilstr,stri];
        end
        frames{count,1}(1,:)=char(foilstr);
    end
    %hold on

%     plot3(newFrames4{i,1}(1,1)+numAirfoil(:,1)*0,numAirfoil(:,1),numAirfoil(:,2),'-')
%     plot3(newFrames4{i,1}(1,1)+numAirfoil(:,1)*0,numAirfoil(:,1),numAirfoil(:,2),'*g')
%     plot3(newFrames4{i,1}(1,1)+numAirfoil(end,1)*0,numAirfoil(end,1),numAirfoil(end,2),'*r')
%     plot3(newFrames4{i,1}(1,1)+numAirfoil(1,1)*0,numAirfoil(1,1),numAirfoil(1,2),'*r')
%     axis equal
%     view(90,0) 
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deform the end section for better mesh generation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% (if the last cikle is to flat, there are problems with mesh generations)
% foilstr=char(' ');
% delta=max(numAirfoil(:,2))-min(numAirfoil(:,2));
% ymax=max(numAirfoil(:,1));
% a2b= delta/ymax;
% if a2b<0.5 || a2b>2 
%     for ii=1:size(numAirfoil,1)    
%         stri=['  ',num2str(numAirfoil(ii,1)/ymax*delta),' ',num2str(numAirfoil(ii,2)),'   '];
%         foilstr=[foilstr,stri];
%     end
%     frames{count,1}='';
%     frames{count,1}(1,:)=char(foilstr);
% end

%% Gen new file
for i=1:size(frames,1) 
    
    % Frames
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Text=frames{i,1}(1,:);
    
    % Center
    center=[' ',num2str(newFrames4{i,1}(1,1)),' 0',' 0 '];
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.center=char(center);
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.height = num2str(2);
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.width  = num2str(2);
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.name=['FuselageFrame',num2str(i)];
         
end
