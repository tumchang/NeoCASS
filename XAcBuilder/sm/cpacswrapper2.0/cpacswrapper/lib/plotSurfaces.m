function plotSurfaces(CPACSgeo,plotMethod,visable)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plotSurfaces                                                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-08-01 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Settings
if nargin==1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Method
% 0 no plot
% 1 plot with patch regard Segment definitions (has bad performance)
% 2 plot with surf regard Segment definitions 
% 3 plot with surf regard NOT Segment definitions (has no auto airfoil order
%   rotation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plotMethod=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show Airfoils
% 1 yes
% 0 No
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    visable=1;
end

%% Plot Sufaces

fnames=fieldnames(CPACSgeo);
count=0;
for i=1:size(fnames,1)
    if strcmp(fnames{i,1},'wings')
        count=count+1;
        componentTypeNames{count,1}='wings';
    end
    if strcmp(fnames{i,1},'fuselages')
        count=count+1;
        componentTypeNames{count,1}='fuselages';
    end
end
airfoili={};

for comTypNum=1:size(componentTypeNames,1)
    componentTypeName=componentTypeNames{comTypNum,1};
    for compNum=1:size(CPACSgeo.(componentTypeName).component,1)
        for secNum=1:size(CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.airfoil,1)
            airfoili{secNum,1}=CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.airfoil{secNum,1};
            airfoili{secNum,2}=CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.sectionElementUIDs{secNum,1}.elementUID{1,1};
        end
        symmetry=CPACSgeo.(componentTypeName).component{compNum,1}.symmetry;
    
        if size(airfoili,1)>=1
            hold on      
            
%% Plot with Patch (plotMethod 1)           
            if plotMethod==1                 
                %%%%%%%%%%%%%%%%%%%%%%%
                % Ploting of Segments % 
                %%%%%%%%%%%%%%%%%%%%%%%
                rotateAirfoilOrder=0;
                for segNum=1:size(CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef,1)
                    % Select the enement UIDs
                    fromElementUID = (CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef{segNum,1}.fromElementUID);
                    toElementUID   = CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef{segNum,1}.toElementUID;
    
                    % Find the element Position 
                    for foilNum=1:size(airfoili,1)
                        if strcmp(fromElementUID,airfoili{foilNum,2})
                            fromFoilNum=foilNum;
                        end
                        if strcmp(toElementUID,airfoili{foilNum,2})
                            toFoilNum=foilNum;
                        end
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Arifoil rotation Order %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%
                    % If the angle between the normla  vector
                    % of the first airfoil and of the socond airfoil is
                    % gather than 90° then the point order of the
                    % airfoil is inverse. This is only nessearry to
                    % have the right conection order between the
                    % airfoils

                    % Nomal vector of the airfoil
                    fromCoodSys = CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.coorsSys{fromFoilNum,1};
                    toCoodSys   = CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.coorsSys{toFoilNum,1};
                    normVec=[0;0;1];
                    normFrom=fromCoodSys*normVec;
                    normTo=toCoodSys*normVec;
                    % Decide to rotate the order of the airfoil
                    angleAifiol=acos(dot(normTo,normFrom)/(norm(normTo)*norm(normFrom)));
                    if angleAifiol>pi/2 && rotateAirfoilOrder==0;
                        rotateAirfoilOrder=1;
                    end       
                    
                    % Define fromAirfoil and toAirfoil
                    fromAirfoil=airfoili{fromFoilNum,1};
                    toAirfoil=airfoili{toFoilNum,1};
                    
                    % Roate the point order offromAirfoil
                    if rotateAirfoilOrder==1
                        fromAirfoil(:,1)=[rot90(fromAirfoil(:,1)')];
                        fromAirfoil(:,2)=[rot90(fromAirfoil(:,2)')];
                        fromAirfoil(:,3)=[rot90(fromAirfoil(:,3)')];
                        rotateAirfoilOrder=0;
                    end
                    
                    % Plot the Surfaces
                    foil1=airfoili;
                    b=size(fromAirfoil,1)-1;
                    for ii=1:1:b
                       cornerp(1,:)= fromAirfoil(ii,:);
                       cornerp(2,:)= toAirfoil(ii,:);
                       cornerp(3,:)= fromAirfoil(ii+1,:);
                       cornerp(4,:)= toAirfoil(ii+1,:); 

                        vec1(1,:)=cornerp(1,:);
                        vec1(2,:)=cornerp(2,:);
                        vec1(3,:)=cornerp(3,:);
                        vec1(4,:)=cornerp(4,:);

                        vert = [  vec1(1,:);  vec1(2,:);  vec1(3,:);  vec1(4,:)];
                        fac = [1 2 3;2 3 4];
                        col=[0.6 0.6 0.6];
                        tcolor = [col; col];
                        patch('Faces',fac,'Vertices',vert,'FaceVertexCData',tcolor,...
                              'FaceColor','flat','EdgeColor','k')
%                         patch('Faces',fac,'Vertices',vert,'FaceVertexCData',tcolor,...
%                           'FaceColor','none','EdgeColor','k')
                    end

                    % Plot Airfoils
                    if visable==1;
                        plot3(fromAirfoil(:,1),fromAirfoil(:,2),fromAirfoil(:,3),'k','LineWidth',1)
                    end
                    
                    % Is Symetry
                    if symmetry>0 
                        symmetry=2;
                        fromAirfoil(:,symmetry)=-fromAirfoil(:,symmetry);
                        toAirfoil(:,symmetry)=-toAirfoil(:,symmetry);
                        b=size(fromAirfoil,1)-1;
                        for ii=1:1:b
                           cornerp(1,:)= fromAirfoil(ii,:);
                           cornerp(2,:)= toAirfoil(ii,:);
                           cornerp(3,:)= fromAirfoil(ii+1,:);
                           cornerp(4,:)= toAirfoil(ii+1,:); 

                            vec1(1,:)=cornerp(1,:);
                            vec1(2,:)=cornerp(2,:);
                            vec1(3,:)=cornerp(3,:);
                            vec1(4,:)=cornerp(4,:);

                            vert = [  vec1(1,:);  vec1(2,:);  vec1(3,:);  vec1(4,:)];
                            fac = [1 2 3;2 3 4];
                            col=[0.6 0.6 0.6];
                            tcolor = [col; col];
                            patch('Faces',fac,'Vertices',vert,'FaceVertexCData',tcolor,...
                                  'FaceColor','flat','EdgeColor','none')
                        end
                    end   
                end           

                % Plot Settings
                alpha(0.5)
                set(gcf,'Color',[1,1,1])
                
                
%% Plot with surf  (plotMethod 2)            
            elseif plotMethod==2 
                
                %%%%%%%%%%%%%%%%%%%%%%%
                % Ploting of Segments % 
                %%%%%%%%%%%%%%%%%%%%%%%
                count=0;
                numOfSeg =size(CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef,1);
                for segNum=1:numOfSeg
                    count=1+count;
                    % Select the enement UIDs
                    fromElementUID = (CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef{segNum,1}.fromElementUID);
                    toElementUID   = CPACSgeo.(componentTypeName).component{compNum,1}.segmentDef{segNum,1}.toElementUID;

                    % Find the element Position 
                    for foilNum=1:size(airfoili,1)
                        if strcmp(fromElementUID,airfoili{foilNum,2})
                            fromFoilNum(count,1)=foilNum;
                        end
                        if strcmp(toElementUID,airfoili{foilNum,2})
                            toFoilNum(count,1)=foilNum;
                        end
                    end
                      
                    % Plot all conected Elements
                    if toFoilNum(count,1)-fromFoilNum(count,1)~=1 || numOfSeg==segNum                
  
                        X=[];
                        Y=[];
                        Z=[];  
                        rotateAirfoilOrder=0;
                        for ii=count:-1:1  
                            % Add Airfoils 
                            if rotateAirfoilOrder==1
                                X=[X,rot90(airfoili{toFoilNum(ii,1),1}(:,1)')];
                                Y=[Y,rot90(airfoili{toFoilNum(ii,1),1}(:,2)')];
                                Z=[Z,rot90(airfoili{toFoilNum(ii,1),1}(:,3)')];
                            else
                                X=[X,airfoili{toFoilNum(ii,1),1}(:,1)];
                                Y=[Y,airfoili{toFoilNum(ii,1),1}(:,2)];
                                Z=[Z,airfoili{toFoilNum(ii,1),1}(:,3)];
                            end
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%
                            % Arifoil rotation Order %
                            %%%%%%%%%%%%%%%%%%%%%%%%%%
                            % If the angle between the normla  vector
                            % of the first airfoil and of the socond airfoil is
                            % gather than 90° then the point order of the
                            % airfoil is inverse. This is only nessearry to
                            % have the right conection order between the
                            % airfoils
                            
                            % Nomal vector of the airfoil
                            fromCoodSys = CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.coorsSys{fromFoilNum(ii,1),1};
                            toCoodSys   = CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.coorsSys{toFoilNum(ii,1),1};
                            normVec=[0;0;1];
                            normFrom=fromCoodSys*normVec;
                            normTo=toCoodSys*normVec;
                            % Decide to rotate the order of the airfoil
                            angleAifiol=acos(dot(normTo,normFrom)/(norm(normTo)*norm(normFrom)));
                            if isnan(angleAifiol)
                                angleAifiol=0;
                            end
                            if angleAifiol>pi/2 && rotateAirfoilOrder==0;
                                rotateAirfoilOrder=1;
                            elseif angleAifiol>pi/2 && rotateAirfoilOrder==1;
                                rotateAirfoilOrder=0;
                            end                            
                        end
                        % Add Last Airfoil   
                        if rotateAirfoilOrder==1
                            X=[X,rot90(airfoili{fromFoilNum(1,1),1}(:,1)')];
                            Y=[Y,rot90(airfoili{fromFoilNum(1,1),1}(:,2)')];
                            Z=[Z,rot90(airfoili{fromFoilNum(1,1),1}(:,3)')];
                        else
                            X=[X,airfoili{fromFoilNum(1,1),1}(:,1)];
                            Y=[Y,airfoili{fromFoilNum(1,1),1}(:,2)];
                            Z=[Z,airfoili{fromFoilNum(1,1),1}(:,3)];
                        end

                        h=surf(X,Y,Z); 
                        shading interp
                        set(h,'EdgeAlpha',0)
                        
                        % Plot Airfoils                        
                        if visable==1;
                            for ii=count:-1:1
                                plot3(airfoili{fromFoilNum(ii,1),1}(:,1),airfoili{fromFoilNum(ii,1),1}(:,2),airfoili{fromFoilNum(ii,1),1}(:,3),'k','LineWidth',1)
                                plot3(airfoili{toFoilNum(ii,1),1}(:,1),airfoili{toFoilNum(ii,1),1}(:,2),airfoili{toFoilNum(ii,1),1}(:,3),'k','LineWidth',1)
                            end
                        end

                        % Is Symetry then plot the mirrow side (mirrow in x-z-Area)  
                        if symmetry>0 
                            X=[];
                            Y=[];
                            Z=[];
                            % Add First Airfoil  
                            X=airfoili{fromFoilNum(1,1),1}(:,1);
                            Y=-airfoili{fromFoilNum(1,1),1}(:,2);
                            Z=airfoili{fromFoilNum(1,1),1}(:,3);
                            rotateAirfoilOrder=0;
                            for ii=1:count
                                %%%%%%%%%%%%%%%%%%%%%%%%%%
                                % Arifoil rotation Order %
                                %%%%%%%%%%%%%%%%%%%%%%%%%%
                                % If the angle between the normla  vector
                                % of the first airfoil and of the socond airfoil is
                                % gather than 90° then the point order of the
                                % airfoil is inverse. This is only nessearry to
                                % have the right conection order between the
                                % airfoils

                                % Nomal vector of the airfoil
                                fromCoodSys = CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.coorsSys{fromFoilNum(ii,1),1};
                                toCoodSys   = CPACSgeo.(componentTypeName).component{compNum,1}.sectionDef.coorsSys{toFoilNum(ii,1),1};
                                normVec=[0;0;1];
                                normFrom=fromCoodSys*normVec;
                                normTo=toCoodSys*normVec;
                                % Decide to rotate the order of the airfoil
                                angleAifiol=acos(dot(normTo,normFrom)/(norm(normTo)*norm(normFrom)));
                                if angleAifiol>pi/2 && rotateAirfoilOrder==0;
                                    rotateAirfoilOrder=1;
                                elseif angleAifiol>pi/2 && rotateAirfoilOrder==1;
                                    rotateAirfoilOrder=0;
                                end   
                                
                                % Add Airfoils 
                                if rotateAirfoilOrder==1
                                    X=[X,rot90(airfoili{toFoilNum(ii,1),1}(:,1)')];
                                    Y=[Y,-rot90(airfoili{toFoilNum(ii,1),1}(:,2)')];
                                    Z=[Z,rot90(airfoili{toFoilNum(ii,1),1}(:,3)')];
                                else
                                    X=[X,airfoili{toFoilNum(ii,1),1}(:,1)];
                                    Y=[Y,-airfoili{toFoilNum(ii,1),1}(:,2)];
                                    Z=[Z,airfoili{toFoilNum(ii,1),1}(:,3)];
                                end                                
                            
                            end
                            h=surf(X,Y,Z); 
                            shading interp
                            set(h,'EdgeAlpha',0)
                        end                            
                        
                        % Reset the Element list (it will plot only those
                        % elements wich are conected to each other)
                        count=0;
                        fromFoilNum=[];
                        toFoilNum=[];
                    end                    
                end
                
                %Plot Settings               
                colorType={'copper','gray','bone','pink','winter','autumn','summer','hot'};
                colormap(colorType{7});   
%                 set(gcf,'Color',[0.9,0.2,0.9])
                set(gcf,'Color',[1,1,1])
                
%% Plot with surf but NO segment implementd (plotMethod 3)               
             elseif plotMethod==3 
                 
                X=[];Y=[];Z=[];
                for i=size(airfoili,1):-1:1
                    X=[X,airfoili{i,1}(:,1)];
                    Y=[Y,airfoili{i,1}(:,2)];
                    Z=[Z,airfoili{i,1}(:,3)];
                end
                h=surf(X,Y,Z); 
                shading interp
                set(h,'EdgeAlpha',0)

                 % Is Symetry                
                if symmetry>0 
                    X=[];Y=[];Z=[];                   
                    for i=1:size(airfoili,1)
                        X=[X,airfoili{i,1}(:,1)];
                        Y=[Y,-airfoili{i,1}(:,2)];
                        Z=[Z,airfoili{i,1}(:,3)];
                    end
                    h=surf(X,Y,Z); 
                    shading interp
                    set(h,'EdgeAlpha',0)
                end

                %Plot Settings
                colorType={'copper','gray','bone','pink','winter','autumn','summer','hot'};
                colormap(colorType{5});
            else
            end 
        end  
    end
end

%% Plot Settings

axis equal;
grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(-30,30);
axis tight;
camlight left
% camlight(0,0)
lighting phong;
alpha(0.7)
set(gca,'Visible','off')
set(gca,'CameraViewAngleMode','manual')
% set(gcf,'Color',[1,1,1])

set(gcf,'PaperPositionMode','Auto')

fullscreen = get(0,'ScreenSize');
set(1,'Position',[0 -50 fullscreen(3) fullscreen(4)])




