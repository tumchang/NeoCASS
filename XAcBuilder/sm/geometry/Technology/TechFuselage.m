%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TechFuselage
% Dedicated fuselage Tech menu function 
% Function works depending TechMode chosen.
%
%   INPUT FusID,TechMode
%       
%       TechMode=1   ->  Generate whole model
%           varargin: ac ->  CPACS struct
%       TechMode=10  ->  Generate Fuselage Model
%       TechMode=11  ->  Modify   Fuselage Beam Model
%           varargin: [],nNode 
%
%   OUTPUT TechGeoModel.iFus
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     10.10.13     1.3    F.Dinardo        Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TechFuselage(fusID,TechMode,MyBeams,varargin)
global handles TechGeoModel  
global pID sID sprID belID abID iSpline iSurf 
rad=pi/180;

if TechMode==1 || TechMode==10
    ac=varargin{1};
   
    try
        symmetry=ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.ATTRIBUTE.symmetry;
        Mirror=2;
    catch
        symmetry=0;
        Mirror=1;
    end
    symmetry
%1.Achieve CPACS data
    %1.1.Structure for section
        ac =varargin{1};
        Nsec=length(ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.sections{1}.section);
        for i=1:Nsec
            %1.1.1.Generate new simpliest struct
                prof_fus(i).sectName   =ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.sections{1}.section{i}.ATTRIBUTE.uID;
                prof_fus(i).sectTras   =ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.sections{1}.section{i}.transformation{1};
                prof_fus(i).elementID  =i;
                prof_fus(i).elemName   =ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.sections{1}.section{i}.elements{1}.element{1}.name{1}.CONTENT;
                prof_fus(i).elemProf   =ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.sections{1}.section{i}.elements{1}.element{1}.profileUID{1}.CONTENT;
                prof_fus(i).elemTras   =ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.sections{1}.section{i}.elements{1}.element{1}.transformation{1};
            %1.1.2.Find profile associated with section & assign an ID
                j=1;
                while strcmp(char(prof_fus(i).elemProf),ac.vehicles{1}.profiles{1}.fuselageProfiles{1}.fuselageProfile{j}.ATTRIBUTE.uID)==0
                    j=j+1;
                end
                prof_fus(i).profileID=j;
                x=str2num(ac.vehicles{1}.profiles{1}.fuselageProfiles{1}.fuselageProfile{j}.pointList{1}.x{1}.CONTENT); if length(x(1,:))>1, x=x'; end
                y=str2num(ac.vehicles{1}.profiles{1}.fuselageProfiles{1}.fuselageProfile{j}.pointList{1}.y{1}.CONTENT); if length(y(1,:))>1, y=y'; end
                z=str2num(ac.vehicles{1}.profiles{1}.fuselageProfiles{1}.fuselageProfile{j}.pointList{1}.z{1}.CONTENT); if length(z(1,:))>1, z=z'; end
                prof_fus(i).pnt=cell2mat({x, y, z});
                %Element transformation
                prof_fus(i).pnt(:,:)=transformCPACS(prof_fus(i).elemTras,prof_fus(i).pnt, 0);
                %Section transformation    
                prof_fus(i).pnt(:,:)=transformCPACS(prof_fus(i).sectTras,prof_fus(i).pnt, 0);   
        end
    %1.2.Positioning data  
        Npos=length(ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.positionings{1}.positioning);        
        h=0;
        %1.2.1.Find section
            for i=1:Npos
                %find from section
                try
                    section_1=ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.positionings{1}.positioning{i}.fromSectionUID{1}.CONTENT;
                catch exception,  
                    section_1='';    
                end
                j=1; 
                while strcmp(section_1, char(prof_fus(j).sectName))==0 && j~=0
                    j=j+1; 
                    if j>Nsec 
                        j=0; 
                        break 
                    end    
                end    
                %find to section
                try                  
                    section_2=ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.positionings{1}.positioning{i}.toSectionUID{1}.CONTENT;
                catch exception
                    section_2='';     
                end
                k=1;    
                while strcmp(section_2, char(prof_fus(k).sectName))==0 && k~=0
                    k=k+1;
                    if k>Nsec
                        k=0; 
                        break    
                    end
                end
                %identify section as numerical ID
%                 sectID(i,1:2)=[j,k]; %identifico le sezioni con ID  numerici
                if j~=0 && k~=0
                    h=h+1;
                    sectID(h,1:2)=[j,k];
                    splineID(h,1:2)=[j+pID,k+pID];
                
                    lenght(h)  =str2num(ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.positionings{1}.positioning{i}.length{1}.CONTENT);
                    sweep(h)   =str2num(ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.positionings{1}.positioning{i}.sweepAngle{1}.CONTENT);
                    dihedral(h)=str2num(ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.positionings{1}.positioning{i}.dihedralAngle{1}.CONTENT);

                    phi(h,:)=[dihedral(h) 0 -sweep(h)].*rad;
                    R3=[cos(phi(h,3)) -sin(phi(h,3))     0      ;...
                        sin(phi(h,3))  cos(phi(h,3))     0      ;...
                           0           0             1      ];

                    R2=[cos(phi(h,2))    0         sin(phi(h,2));...
                         0             1            0       ;... 
                       -sin(phi(h,2))    0         cos(phi(h,2))]; 

                    R1=[   1           0            0       ;...
                           0        cos(phi(h,1)) -sin(phi(h,1));...
                           0        sin(phi(h,1))  cos(phi(h,1))];
                    R31=R1*R3;   

                    ivect(h,:)=(R31*[0 lenght(h) 0]')';

                    if h==1
                        vect_from(h,:)=[0 0 0];
                        vect_to(h,:)  =(vect_from(h,:)'+ivect(h,:)')';
                    else
                        vect_from(h,:)=vect_to(h-1,:);
                        vect_to(h,:)  =(vect_from(h,:)'+ivect(h,:)')';
                    end 
                end
            end
        %1.2.2.Profile transformation
            Npos=h;
            for i=1:Npos
                if sectID(i,1)>0 
                    for j=1:length(prof_fus(sectID(i,1)).pnt(:,:))
                        prof_fus(sectID(i,1)).pnt_pos(j,:)=(prof_fus(sectID(i,1)).pnt(j,:)'+vect_from(i,:)')';
                    end        
                end
                if sectID(i,1)>0 
                    for j=1:length(prof_fus(sectID(i,2)).pnt(:,:))
                        prof_fus(sectID(i,2)).pnt_pos(j,:)=(prof_fus(sectID(i,2)).pnt(j,:)'+vect_to(i,:)')';
                    end        
                end
            end
    %1.3.Final transformation in global axis
        finalTras=ac.vehicles{1}.aircraft{1}.model{1}.fuselages{1}.fuselage{fusID}.transformation{1};
        for i=1:Nsec
            prof_fus(i).pnt_pos(:,:)=transformCPACS(finalTras,prof_fus(i).pnt_pos, 0);
            %Extraction of fuselage profile
            [~, ival]=max(prof_fus(i).pnt_pos(:,3));   upperFus(i,:)=prof_fus(i).pnt_pos(ival,:);
            [~, ival]=min(prof_fus(i).pnt_pos(:,3));   lowerFus(i,:)=prof_fus(i).pnt_pos(ival,:);
            [~, ival]=max(prof_fus(i).pnt_pos(:,2));   side_FusR(i,:)=prof_fus(i).pnt_pos(ival,:);
            [~, ival]=min(prof_fus(i).pnt_pos(:,2));   side_FusL(i,:)=prof_fus(i).pnt_pos(ival,:);
        end
% 2.Generate geometry entities (external surfaces)
    % 2.1.Generate profiles as spline         
        global Curve
        for i=1:length(prof_fus)
            pID=pID+1;
            iSpline{pID}=mySpline(pID,prof_fus(i).pnt_pos,0);
            %handles.Tech.Curve(pID)=Curve(pID);
            proflieID(i)=pID;
        end
    % 2.2.Generate surfaces as Cubic patch        
        j=1; global Surf
        for i=1:length(sectID)
            if sectID(i,1)~=0 && sectID(i,2)~=0
                sID=sID+1;
                iSurf{sID}=mySurfCub(sID,...
                                     iSpline{splineID(i,1)},...
                                     iSpline{splineID(i,2)});
                surfIDs(j)=sID; j=j+1;
                handles.Tech.Surf(sID)=Surf(sID);
                
            end
        end  
    % 2.3.ProfileLines
        %profiles 
       ProfileLinesIDs=pID:pID+3;
       handles.Tech.Curve(pID)=plot3(upperFus(:,1),  upperFus(:,2), upperFus(:,3), 'LineWidth',1,'Color','k'); set(handles.Tech.Curve(pID),'DisplayName',['Curve' num2str(pID) '_Spar']);  pID=pID+1;
       handles.Tech.Curve(pID)=plot3(lowerFus(:,1),  lowerFus(:,2), lowerFus(:,3), 'LineWidth',1,'Color','k'); set(handles.Tech.Curve(pID),'DisplayName',['Curve' num2str(pID) '_Spar']);  pID=pID+1;
       handles.Tech.Curve(pID)=plot3(side_FusR(:,1), side_FusR(:,2),side_FusR(:,3),'LineWidth',1,'Color','k'); set(handles.Tech.Curve(pID),'DisplayName',['Curve' num2str(pID) '_Spar']);  pID=pID+1;
       handles.Tech.Curve(pID)=plot3(side_FusL(:,1), side_FusL(:,2),side_FusL(:,3),'LineWidth',1,'Color','k'); set(handles.Tech.Curve(pID),'DisplayName',['Curve' num2str(pID) '_Spar']);  pID=pID+1;
        
    % 2.4.Simmetry
        if symmetry~=0
            if     strcmp(symmetry,'x-z-plane'), sym1= 1; sym2=-1; sym3= 1;
            elseif strcmp(symmetry,'y-z-plane'), sym1=-1; sym2= 1; sym3= 1;
            elseif strcmp(symmetry,'x-y-plane'), sym1= 1; sym2= 1; sym3=-1;
            end

            for i=ProfileLinesIDs
                pID=pID+1;
                handles.Tech.Curve(pID)=plot3(sym1*get(handles.Tech.Curve(i),'XData'),sym2*get(handles.Tech.Curve(i),'YData'),sym3*get(handles.Tech.Curve(i),'ZData'),'LineWidth',1,'Color','k');
                %set(handles.Tech.Curve(pID),...                
                    %'Tag'        ,[get(handles.Tech.Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')']);
                    %'DisplayName',[get(handles.Tech.Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')'],...
            end 
            for i=surfIDs
                sID=sID+1;
                Surf(sID)=surf(sym1*get(Surf(i),'XData'),sym2*get(Surf(i),'YData'),sym3*get(Surf(i),'ZData'));
                % **** Per Grafica *****
                %set(Surf(sID),'DisplayName',['Surf' num2str(sID) '_(Mirror Surf' num2str(i) ')'],...
                %              'Tag'        ,['Surf' num2str(sID) '_(Mirror Surf' num2str(i) ')']);
                % ******
                surfIDs=[surfIDs sID]; 
                handles.Tech.Surf(sID)=Surf(sID);          
            end
        end    
%4.Joint all sigles wing structure in one
    for kk=1
%     iFus=struct('fusID',  fusID,...
%                'prof_fus',prof_fus,...
%                'sectID',  sectID,...
%                'lenght',  lenght,...
%                'sweep',   sweep,...
%                'dihedral',dihedral,...
%                'splineID',splineID,...
%                'surfID',  surfIDs);
           
           
   TechGeoModel.iFus{fusID}.fusID             = fusID;
   TechGeoModel.iFus{fusID}.symmetry          = symmetry;
   TechGeoModel.iFus{fusID}.Geometry.prof_fus = prof_fus;
   TechGeoModel.iFus{fusID}.Geometry.sectID   = sectID;
   TechGeoModel.iFus{fusID}.Geometry.lenght   = lenght;
   TechGeoModel.iFus{fusID}.Geometry.sweep    = sweep;
   TechGeoModel.iFus{fusID}.Geometry.dihedral = dihedral;
   
   TechGeoModel.iFus{fusID}.Geometry.splineID = splineID;
   TechGeoModel.iFus{fusID}.Geometry.surfID   = surfIDs;
   %%%%
   TechGeoModel.iFus{fusID}.Geometry.profile.upper = upperFus;
   TechGeoModel.iFus{fusID}.Geometry.profile.lower = lowerFus;
   TechGeoModel.iFus{fusID}.Geometry.profile.sideL = side_FusL;
   %%%
%beam model
    end
elseif TechMode==11
    
    for kk=1
       symmetry=TechGeoModel.iFus{fusID}.symmetry; 
       %TechGeoModel.iFus{fusID}.fusID;
       %prof_fus = TechGeoModel.iFus{fusID}.Geometry.prof_fus;
       %sectID   = TechGeoModel.iFus{fusID}.Geometry.sectID;
       %lenght   = TechGeoModel.iFus{fusID}.Geometry.lenght;
       %sweep    = TechGeoModel.iFus{fusID}.Geometry.sweep;
       %dihedral = TechGeoModel.iFus{fusID}.Geometry.dihedral;

       %splineID = TechGeoModel.iFus{fusID}.Geometry.splineID;
       %surfID   = TechGeoModel.iFus{fusID}.Geometry.surfID;
    end
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
if TechMode==1 || TechMode==10 
    dRib=0.5;
    nfuse=round((side_FusR(end,1)-side_FusR(1,1))/dRib);
    nfuse=MyBeams; disp('Inserimento') % ***** Aggiunto per AcBuilder ***
    xbeam=linspace(side_FusR(1,1),side_FusR(end,1),nfuse);
    belIDs=[];
    belID=belID+1;
    %erase equal spatial position 
    j=1; k=1;
    side_FusR_tmp(j,:)= side_FusR(1,:);
    side_FusL_tmp(k,:)= side_FusL(1,:);
    for i=2:length(side_FusR(:,1))
        if side_FusR_tmp(j,1)~=side_FusR(i,1)
           j=j+1; 
           side_FusR_tmp(j,:)= side_FusR(i,:);           
        end
        if side_FusL_tmp(k,1)~=side_FusL(i,1)
           k=k+1; 
           side_FusL_tmp(k,:)= side_FusL(i,:);           
        end
    end
                
    ybeam=interp1(side_FusR_tmp(:,1),(side_FusR_tmp(:,2)+side_FusL_tmp(:,2))/2,xbeam);
    zbeam=interp1(side_FusR_tmp(:,1),           side_FusR_tmp(:,3)        ,xbeam);
      
    
elseif TechMode==11  
    belIDs=TechGeoModel.iFus{fusID}.beamModel.belIDs;
    % display(['BeamLines ' num2str(belIDs) ' refreshed' ]) % per grafica
    delete(handles.Tech.BeamLine(belIDs));
    belID =belIDs(1);
    %belIDs=belID; 
    belIDs=[];
    
    nfuse=varargin{2};
    xbeam_old=TechGeoModel.iFus{fusID}.beamModel.xBeam;
    ybeam_old=TechGeoModel.iFus{fusID}.beamModel.yBeam;
    zbeam_old=TechGeoModel.iFus{fusID}.beamModel.zBeam;
    
    xbeam=linspace(xbeam_old(1),xbeam_old(end),nfuse);
    ybeam=interp1(xbeam_old,ybeam_old,xbeam);
    zbeam=interp1(xbeam_old,zbeam_old,xbeam);    
end
    
    belIDs=[belIDs belID];
    handles.Tech.BeamLine(belID)=line(xbeam, ybeam, zbeam,'LineWidth',1,'Color','r','Marker','d','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',4); 
    % set(handles.Tech.BeamLine(belID),'DisplayName',['Curve' num2str(pID)
    % '_Spar']); % Per grafica
    if symmetry~=0
        if     strcmp(symmetry,'x-z-plane'), sym1= 1; sym2=-1; sym3= 1;
        elseif strcmp(symmetry,'y-z-plane'), sym1=-1; sym2= 1; sym3= 1;
        elseif strcmp(symmetry,'x-y-plane'), sym1= 1; sym2= 1; sym3=-1;
        end
        for i=belIDs
            belID=belID+1;
            handles.Tech.BeamLine(belID)=plot3( sym1*get(handles.Tech.BeamLine(i),'XData'),...
                                                sym2*get(handles.Tech.BeamLine(i),'YData'),...
                                                sym3*get(handles.Tech.BeamLine(i),'ZData'),'LineWidth',1,'Color','g','Marker','.');
            %set(handles.Tech.BeamLine(belID),'DisplayName',[get(handles.Tech.BeamLine(i),'DisplayName') '_(Mirror SparLine' num2str(i) ')'],...
                                             %'Tag'        ,[get(handles.Tech.BeamLine(i),'DisplayName') '_(Mirror SparLine' num2str(i) ')'],...
                                             %'LineWidth'  ,1,...
                                             %'Color'      ,'r',...
                                             %'Marker'     ,'d',...
                                             %'MarkerFaceColor','b',...
                                             %'MarkerEdgeColor','b',...
                                            % 'MarkerSize' ,4);  
                                         % Per grafica                                           
            belIDs=[belIDs, belID];
        end
    end
    TechGeoModel.iFus{fusID}.beamModel.nodeSect = nfuse;
    TechGeoModel.iFus{fusID}.beamModel.belIDs   = belID;
    TechGeoModel.iFus{fusID}.beamModel.belIDs   = belIDs;
    TechGeoModel.iFus{fusID}.beamModel.xBeam    = xbeam;
    TechGeoModel.iFus{fusID}.beamModel.yBeam    = ybeam;
    TechGeoModel.iFus{fusID}.beamModel.zBeam    = zbeam;
    

                
        


        
        
            
        
            
        


                                                                                                                                                                                                                    













