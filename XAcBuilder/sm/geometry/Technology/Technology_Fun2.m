%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Technology_Fun
% Main function of technology menu 
% Function works depending TechMode chosen.
%
%   INPUT TechMode,ID
%       
%       TechMode=1   ->  Generate whole model
%           varargin: ac ->  CPACS struct
%       TechMode=10  ->  Generate Fuselage Model
%       TechMode=11  ->  Modify   Fuselage Beam Model
%           varargin: [],nNode 
%       TechMode=20  ->  Generate Wing Model
%       TechMode=21  ->  Modify   Wing Beam Model
%           varargin: BoardID, nNode
%       TechMode=22  ->  Modify   Wing Aero Panel
%           varargin: BoardID, ni, nPan (ni: ny, nx, nxTED)
%       TechMode=23  ->  Modify   Wing Spar Position
%
%   OUTPUT TechGeoModel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     10.10.13      1.    F.Dinardo        Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Technology_Fun(TechMode,varargin)
global handles TechGeoModel
global pID sID sprID belID abID Spline iSurf 

%0.Component's IDs 
    if TechMode==1
        ac=varargin{1};
        pID=0;sID=0; sprID=0; belID=0; abID=0;
        Nfus=length(ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage);  FusIDs =1:Nfus;
        Nwing=length(ac.vehicles{1}.aircraft{1}.model{1}.wings{1}.wing);         WingIDs=1:Nwing;  
        ac.header{1}.name{1}.CONTENT
        TechGeoModel.header.name=ac.header{1}.name{1}.CONTENT;
    else
        %TechGeoModel
        if     TechMode==10 || TechMode==11        
            FusIDs= varargin{1}; 
            WingIDs=1; %dummy ID
        elseif TechMode==20 || TechMode==21 || TechMode==22 || TechMode==23
            FusIDs=1;  %dummy ID
            WingIDs=varargin{1};
        end  
    end      
%1.Fuselage Genrator   
    for i=FusIDs  
        if     TechMode== 1 || TechMode==10 
            TechFuselage(i,TechMode,ac);
        elseif TechMode==11
            %BoardID=varargin{2}; 
            n=varargin{3};
            TechFuselage(i,TechMode,[],n);
        end
    end
%2.Wing Generator     
    for i=WingIDs, 
        if     TechMode== 1 || TechMode==20   
            TechWing(i,TechMode,ac);            
        elseif TechMode==21 
            BoardID=varargin{2}; n=varargin{3};
            TechWing(i,TechMode,BoardID,n);
        elseif TechMode==22
            BoardID=varargin{2}; ni=varargin{3};
            TechWing(i,TechMode,BoardID,ni,varargin{4});
        end
    end
%3.Rendering
    set(handles.Tech.Surf(:)    ,'EdgeColor','none','FaceAlpha'  ,0.4,'FaceColor'  ,[.5 .5 .5]);
    set(handles.Tech.AeroMesh(:),'EdgeAlpha',0.5);
    %shading interp
%4.Generate List Data
    %4.1.Beam Data
        j=1;
        %Fuselges        
        for i=1:length(TechGeoModel.iFus)
            %TechGeoModel.iFus{i}.beamModel
            beam_data{j,1}=['n fuse' num2str(TechGeoModel.iFus{i}.fusID)]; beam_data{j,2}=''; beam_data{j,3}=TechGeoModel.iFus{i}.beamModel.nodeSect; j=j+1;
        end  
        %Wings   
        for i=1:length(TechGeoModel.iWing)
            %TechGeoModel.iWing{i}.beamModel.nodeSect
            for k=1:length(TechGeoModel.iWing{i}.beamModel.nodeSect)
                beam_data{j,1}=['n wing' num2str(i) '_board' num2str(k)]; beam_data{j,2}=''; beam_data{j,3}=TechGeoModel.iWing{i}.beamModel.nodeSect(k); j=j+1;
            end
            beam_data{j,1}=['n wing' num2str(i) 'carryth']; beam_data{j,2}=''; beam_data{j,3}=2; 
            j=j+1;
        end      
    %4.2.Aero Panel Data 
        j=1;
        for i=1:length(TechGeoModel.iWing)
            %TechGeoModel.iWing{i}.aeroPanel
            for k=1:length(TechGeoModel.iWing{i}.aeroPanel.ny)
                                     %1234      5       678901     2        345678                             
                aeroPanel_data{j,1}=['wing' num2str(i) ' board' num2str(k) ' ny   '];  aeroPanel_data{j,2}=''; aeroPanel_data{j,3}=TechGeoModel.iWing{i}.aeroPanel.ny(k);    j=j+1;
                aeroPanel_data{j,1}=['wing' num2str(i) ' board' num2str(k) ' nx   '];  aeroPanel_data{j,2}=''; aeroPanel_data{j,3}=TechGeoModel.iWing{i}.aeroPanel.nx(k);    j=j+1;
                aeroPanel_data{j,1}=['wing' num2str(i) ' board' num2str(k) ' nxTED'];  aeroPanel_data{j,2}=''; aeroPanel_data{j,3}=TechGeoModel.iWing{i}.aeroPanel.nxTED(k); j=j+1;
            end
        end      
%5.Add data struct 2 TechModel    
    TechGeoModel.beam_data=beam_data;
    TechGeoModel.aeroPanel_data=aeroPanel_data;
%5.Save TechGeoModel
%     [File,Path] = uiputfile('*mat','Save WorkSpce TechGeoModel as: ','prova');
%     save(strcat(Path,File),'TechGeoModel','-mat') 
%     j=1;
%     while ~isspace(TechGeoModel.header.name(j)) && j<=length(TechGeoModel.header.name)
%         j=j+1;
%         
%     end
%     
%    File=[TechGeoModel.header.name(1:j-1) '_TechGeoModel.mat'];
    
    File=[TechGeoModel.header.name '_TechGeoModel.mat'];    
    save(strcat('../Projects\',File),'-mat') 
    
%     light('Position',[0 10 10],'Style','infinite');
%     shading interp
%     colormap(gray),
%     alpha(0.4)
%     set(techFig.cubicPatch,'Visible','on');
%     set(techFig.beamModel ,'Visible','on');
%     set(techFig.aeroPannel,'Visible','on');
end
    
    
    

