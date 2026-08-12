function plotWireFrames(CPACSgeo,visable)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plotWireFrames                                                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-08-01 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Plot WireFrames

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
            
%% Plot with surf  (plotMethod 2)            

                
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

                %Plot Airfoils                        
        
                    for ii=count:-1:1
                        plot3(airfoili{fromFoilNum(ii,1),1}(:,1),airfoili{fromFoilNum(ii,1),1}(:,2),airfoili{fromFoilNum(ii,1),1}(:,3),'k','LineWidth',1)
                        plot3(airfoili{toFoilNum(ii,1),1}(:,1),airfoili{toFoilNum(ii,1),1}(:,2),airfoili{toFoilNum(ii,1),1}(:,3),'k','LineWidth',1)
                    end
    
                    
                    nnn=[1,floor(size(airfoili{fromFoilNum(ii,1),1},1)*0.1),...
                            floor(size(airfoili{fromFoilNum(ii,1),1},1)*0.4),...
                            floor(size(airfoili{fromFoilNum(ii,1),1},1)*0.5),...
                            floor(size(airfoili{fromFoilNum(ii,1),1},1)*0.6),...
                            floor(size(airfoili{fromFoilNum(ii,1),1},1)*0.9),...
                            size(airfoili{fromFoilNum(ii,1),1},1)];
                    for NNN=nnn                    
                        plot3( [airfoili{fromFoilNum(ii,1),1}(NNN,1),airfoili{toFoilNum(ii,1),1}(NNN,1)],...
                                [airfoili{fromFoilNum(ii,1),1}(NNN,2),airfoili{toFoilNum(ii,1),1}(NNN,2)],...
                                [airfoili{fromFoilNum(ii,1),1}(NNN,3),airfoili{toFoilNum(ii,1),1}(NNN,3)],...
                                'k','LineWidth',1);
                    end
 
                    % Is Symetry then plot the mirrow side (mirrow in x-z-Area)  
                    if symmetry>0               
                        for ii=count:-1:1
                            plot3(airfoili{fromFoilNum(ii,1),1}(:,1),-airfoili{fromFoilNum(ii,1),1}(:,2),airfoili{fromFoilNum(ii,1),1}(:,3),'k','LineWidth',1)
                            plot3(airfoili{toFoilNum(ii,1),1}(:,1),-airfoili{toFoilNum(ii,1),1}(:,2),airfoili{toFoilNum(ii,1),1}(:,3),'k','LineWidth',1)
                        end
                        
                        for NNN=nnn                    
                            plot3( [airfoili{fromFoilNum(ii,1),1}(NNN,1),airfoili{toFoilNum(ii,1),1}(NNN,1)],...
                                    [-airfoili{fromFoilNum(ii,1),1}(NNN,2),-airfoili{toFoilNum(ii,1),1}(NNN,2)],...
                                    [airfoili{fromFoilNum(ii,1),1}(NNN,3),airfoili{toFoilNum(ii,1),1}(NNN,3)],...
                                    'k','LineWidth',1);
                        end
                    end                            

                    % Reset the Element list (it will plot only those
                    % elements wich are conected to each other)
                    count=0;
                    fromFoilNum=[];
                    toFoilNum=[];                  
            end
                
            %Plot Settings               
            colorType={'copper','gray','bone','pink','winter','autumn','summer','hot'};
            colormap(colorType{7});   
%                 set(gcf,'Color',[0.2,0.2,0.2])
            set(gcf,'Color',[1,1,1])               
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

fullscreen = get(0,'ScreenSize');
set(1,'Position',[0 -50 fullscreen(3) fullscreen(4)])
