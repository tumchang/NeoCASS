function [NewS] = inclFus(NewS,aircraft)
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
%NewS.Assembly.BodySkeleton.Attributes.akimatg  = 'false';

% Statdar Settings
% NewS.Assembly.BodySkeleton.Cap = s.Assembly.BodySkeleton.Cap;
% NewS.Assembly.BodySkeleton.MeshCriterion = s.Assembly.BodySkeleton.MeshCriterion;
% NewS.Assembly.BodySkeleton.Attributes = s.Assembly.BodySkeleton.Attributes;

%% Set new Structure
%% Frames

newFrames={};
count=0;
for i=1:size(aircraft.fuselage.frames,1)   
    foil=aircraft.fuselage.frames{i,1};
    if size(foil,1)>1
        count=count+1;
        newFrames{count,1}=foil;
        count2=0;
        for ii=1:size(newFrames{count,1}(:,2),1)
            if newFrames{count,1}(ii,3)>=0
                count2=count2+1;
                newFrames2{count,1}(count2,1)=newFrames{count,1}(ii,1);
                newFrames2{count,1}(count2,3)=newFrames{count,1}(ii,2);
                newFrames2{count,1}(count2,2)=newFrames{count,1}(ii,3);
            end
        end
    end      
end

% Delete dubblel Points fom airfiol
count=0;
for i=1:size(newFrames2,1)  
    [newFrames2{i,1}]=uniqueColumn(newFrames2{i,1});
    if ~isempty(newFrames2{i,1})&&size(newFrames2{i,1},1)>1
        count=count+1;
        newFrames3{count,1}=newFrames2{i,1};
    end
end

% Write string
frames={};
for i=1:1:size(newFrames3,1)
    numAirfoil=[];
    [val pos]=sort(newFrames3{i,1}(:,3));
    numAirfoil=[newFrames3{i,1}(pos,2),newFrames3{i,1}(pos,3)];
    numAirfoil=[0,numAirfoil(1,2);numAirfoil;0,numAirfoil(end,2)];
    [numAirfoil]=uniqueColumn(numAirfoil);
    foilstr=char(' ');
    for ii=1:size(numAirfoil,1)
        stri=['  ',num2str(numAirfoil(ii,1)),' ',num2str(numAirfoil(ii,2)),'   '];
        foilstr=[foilstr,stri];
    end
    frames{i,1}(1,:)=char(foilstr);
    % hold on
    % plot3(newFrames3{i,1}(1,1)+numAirfoil(:,1)*0,numAirfoil(:,1),numAirfoil(:,2))
    % axis equal
    % view(90,0) 
end    

%% Gen new file
for i=1:size(frames,1) 
    
    % Frames
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Text=frames{i,1}(1,:);
    
    % Center
    center=[' ',num2str(newFrames3{i,1}(1,1)),' 0',' 0 '];
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.center=char(center);
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.height = num2str(aircraft.fuselage.d/2);
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.width  = num2str(aircraft.fuselage.d/2);
    NewS.Assembly.BodySkeleton.BodyFrame{1,i}.Attributes.name=['FuselageFrame',num2str(i)];
         
end
