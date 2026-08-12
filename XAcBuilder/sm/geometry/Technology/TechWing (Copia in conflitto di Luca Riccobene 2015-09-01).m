%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TechWing
% Dedicated wing function Tech menu 
% Function works depending TechMode chosen.
%
%   INPUT WingID,TechMode
%       
%       TechMode=1   ->  Generate whole model
%       TechMode=20  ->  Generate Wing Model
%       TechMode=21  ->  Modify   Wing Beam Model
%           varargin: BoardID, nNode
%       TechMode=22  ->  Modify   Wing Aero Panel
%           varargin: BoardID, ni, nPan (ni: ny, nx, nxTED)
%       TechMode=23  ->  Modify   Wing Spar Position
%
%   OUTPUT TechGeoModel.iWing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     10.10.13     1.0    F.Dinardo        Creation
%     13.11.13     2.0    F.Dinardo        Correction of Positioning Vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close all,clear all,clc
% rad=pi/180;pID=0;sID=0;sprID=0;belID=0;abID=0;
% %load C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACS_ACbuilder_V1.0\Projects\B7772VSP.mat
% % ac=B7772VSP;
% % load C:\Users\Nitro\Dropbox\CPACScreator_V1.4\Projects\CPACS_struct.mat
% % load 'C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\CPACS_struct.mat'
% % varargin{1}=CPACS_struct;
% %load 'C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150.mat'
% load 'C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\NeoCASS_Latest_Version_Patched\CPACS_XML.mat'
% varargin{1}=CPACS_XML;
% wingID=1;
% figure(1), hold on, axis equal,view([-135 30])
% title('Surface cubicPatch')
% TechMode=1;
% %ac
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TechWing(wingID,TechMode,AcBeamsW,AcAeroW,varargin)
global handles TechGeoModel
global pID sID sprID belID abID iSpline iSurf  
rad=pi/180;
tic
if TechMode==1 || TechMode==20
% 0.Symmetry    
    for kkkk=1
    ac=varargin{1};
    try
        symmetry=ac.vehicles{1}.aircraft{1}.model{1}.wings{1}.wing{wingID}.ATTRIBUTE.symmetry;
        Mirror=2;
    catch
        symmetry=0;
        Mirror=1;
    end
    %symmetry
    end
% 1.Achieve CPACS data
    for kkkk=1
    WING=ac.vehicles{1}.aircraft{1}.model{1}.wings{1}.wing{wingID};
    % 1.1.Structure for section
%         Nsec=length(ac.vehicles{1}.aircraft{1}.model{1}.wings{1}.wing{wingID}.sections{1}.section);
        Nsec=max(size(ac.vehicles{1}.aircraft{1}.model{1}.wings{1}.wing{wingID}.sections{1}.section));
        %prof_wing().sectName
        for i=1:Nsec
            %1.1.1.Generate new simpliest struct
                %ID section
                %prof(i).sectionID  =i;
                prof_wing(i).sectName =WING.sections{1}.section{i}.ATTRIBUTE.uID;
                prof_wing(i).sectTras =WING.sections{1}.section{i}.transformation{1};
                prof_wing(i).elementID=i;
                prof_wing(i).elemName =WING.sections{1}.section{i}.elements{1}.element{1}.name{1}.CONTENT;
                prof_wing(i).elemProf =WING.sections{1}.section{i}.elements{1}.element{1}.airfoilUID{1}.CONTENT;
                prof_wing(i).elemTras =WING.sections{1}.section{i}.elements{1}.element{1}.transformation{1};
            %1.1.2.Find profile associated with section & assign an ID
                j=1;
                % *** Pulizia stringa nome airfoil elimina ".dat"
                while strcmp(strrep(char(prof_wing(i).elemProf),'.dat',''),ac.vehicles{1}.profiles{1}.wingAirfoils{1}.wingAirfoil{j}.ATTRIBUTE.uID)==0
                    j=j+1;
                end
                prof_wing(i).profileID=j;
                %Achieve point
                x=str2num(ac.vehicles{1}.profiles{1}.wingAirfoils{1}.wingAirfoil{j}.pointList{1}.x{1}.CONTENT); if length(x(1,:))>1, x=x'; end
                y=str2num(ac.vehicles{1}.profiles{1}.wingAirfoils{1}.wingAirfoil{j}.pointList{1}.y{1}.CONTENT); if length(y(1,:))>1, y=y'; end
                z=str2num(ac.vehicles{1}.profiles{1}.wingAirfoils{1}.wingAirfoil{j}.pointList{1}.z{1}.CONTENT); if length(z(1,:))>1, z=z'; end
                prof_wing(i).pnt=cell2mat({x, y, z}); %length(prof_wing(i).pnt)
                %Achieve Leading & Trailing Edge i point
                [~,prof_wing(i).iLE]=min(prof_wing(i).pnt(:,1));  %prof_wing(i).LE=prof_wing(i).pnt(iLE,:);
                [~,prof_wing(i).iTE]=max(prof_wing(i).pnt(:,1));  %prof_wing(i).LE=prof_wing(i).pnt(iLE,:);    
                %Element transformation
                [prof_wing(i).pnt(:,:) Relem(:,:,i)]=transformCPACS(prof_wing(i).elemTras,prof_wing(i).pnt, 0);
                %Section transformation    
                [prof_wing(i).pnt(:,:) Rsect(:,:,i)]=transformCPACS(prof_wing(i).sectTras,prof_wing(i).pnt, 0);                  
%                 prof_wing(i).nPlane=cross(prof_wing(i).pnt(prof_wing(i).iTE,:)-prof_wing(i).pnt(prof_wing(i).iLE,:),...
%                                           prof_wing(i).pnt(prof_wing(i).iTE,:)-prof_wing(i).pnt(ceil(prof_wing(i).iLE,:)                                 )
        end
    % 1.2.Positioning data       
        Npos=length(WING.positionings{1}.positioning);
        %1.2.1.Find section
            h=0;
            for i=1:Npos
                %find from section
                try
                    section_1=WING.positionings{1}.positioning{i}.fromSectionUID{1}.CONTENT;
                catch exception,  
                    section_1='';    
                end
                j=1; 
                while strcmp(section_1, char(prof_wing(j).sectName))==0 && j~=0
                    j=j+1; 
                    if j>Nsec 
                        j=0; 
                        break 
                    end    
                end    
                %find to section
                try                  
                    section_2=WING.positionings{1}.positioning{i}.toSectionUID{1}.CONTENT;
                catch exception
                    section_2='';     
                end
                k=1;    
                while strcmp(section_2, char(prof_wing(k).sectName))==0 && k~=0
                    k=k+1;
                    if k>Nsec
                        k=0; 
                        break    
                    end
                end
                %identify section as numerical ID
                 %identifico le sezioni con ID  numerici
                if j~=0 && k~=0
                    h=h+1;
                    sectID(h,1:2)=[j,k];
                    splineID(h,1:2)=[j+pID,k+pID];
%                 end
                    lenght(h)  =str2num(WING.positionings{1}.positioning{i}.length{1}.CONTENT);                   %lenght(3)=10
                    sweep(h)   =str2num(WING.positionings{1}.positioning{i}.sweepAngle{1}.CONTENT);               %sweep(3)=-10
                    dihedral(h)=str2num(WING.positionings{1}.positioning{i}.dihedralAngle{1}.CONTENT);

                    phi(h,:)=[dihedral(h) 0 -sweep(h)].*rad;
                    R3=[cos(phi(h,3)) -sin(phi(h,3))     0      ;...
                        sin(phi(h,3))  cos(phi(h,3))     0      ;...
                             0              0            1      ];

                    R2=[cos(phi(h,2))    0         sin(phi(h,2));...
                             0           1              0       ;... 
                       -sin(phi(h,2))    0         cos(phi(h,2))]; 

                    R1=[     1           0              0       ;...
                             0        cos(phi(h,1)) -sin(phi(h,1));...
                             0        sin(phi(h,1))  cos(phi(h,1))];


                    R31=R1*R3; 
                    
                    ivect(h,:)=(R31*[0 lenght(h) 0]')';
                    PosVect(h,:)=(R31*[0 lenght(h) 0]')';
                    
                end
            end
         %1.2.2.Profile transformation
            [PosVect]=posVectFun(2,0,ivect,[1 0 0]');
            Npos=h;
            for i=1:Npos                
                for j=1:length(prof_wing(sectID(i,1)).pnt(:,:))
                    prof_wing(sectID(i,1)).pnt_pos(j,:)=(prof_wing(sectID(i,1)).pnt(j,:)'+PosVect.pnt0(i,:)')';
                end        

                for j=1:length(prof_wing(sectID(i,2)).pnt(:,:))
                    prof_wing(sectID(i,2)).pnt_pos(j,:)=(prof_wing(sectID(i,2)).pnt(j,:)'+PosVect.pnt0(i+1,:)')';
                end        
                
            end
    % 1.3.Final transformation in global axis       
        finalTras=WING.transformation{1};
        for i=1:Nsec
            [prof_wing(i).pnt_pos(:,:) Rfin]=transformCPACS(finalTras,prof_wing(i).pnt_pos, 0);
            %Chord x direction
            prof_wing(i).chord=[1 0 0]*(prof_wing(i).pnt_pos(prof_wing(i).iTE,:)'-prof_wing(i).pnt_pos(prof_wing(i).iLE,:)');
            
        end 
        %Wing area
        [~,SpanDir]=max([max(ivect(:,1)),max(ivect(:,2)),max(ivect(:,3))]);
        for i=1:Npos
            %if sectID(i,1)>0
                %A=sectID(i,1);  B=sectID(i,2);
                span(i)    =ivect(i,SpanDir);
                Areai(i)   =(prof_wing(sectID(i,1)).chord + prof_wing(sectID(i,2)).chord)/2*span(i);
                maci(i)    =(prof_wing(sectID(i,1)).chord^2 + prof_wing(sectID(i,2)).chord^2)/2*span(i);
                xLE_maci(i)=(prof_wing(sectID(i,1)).chord*prof_wing(sectID(i,1)).pnt_pos(prof_wing(sectID(i,1)).iLE,1) +...
                             prof_wing(sectID(i,2)).chord*prof_wing(sectID(i,2)).pnt_pos(prof_wing(sectID(i,2)).iLE,1))/2*span(i);
            %end
        end
        Area=sum(Areai);        
        Span=sum(span);
        %AR=(Span*Mirror)^2/(Area*Mirror);
        mac=sum(maci)/Area;
        xLEmac=sum(xLE_maci)/Area;
        
        %toc disp('time to read & allocating CPACS info')
    end
% 2.Generate geometry entities (external surfaces) 
    for kkkk=1
    % 2.1.Generate profiles as spline
        start_ID=pID+1;
        global Curve
        for i=1:length(prof_wing) 
            pID=pID+1;
            iSpline{pID}=mySpline(pID,prof_wing(i).pnt_pos,1); 
            profileIDs(i)=pID;
            handles.Tech.Curve(pID)=Curve(pID);           
        end       
    % 2.2.Generate surfaces as Cubic patch
        %start_ID=sID+1;
        global Surf
        for i=1:Npos                       
            sID=sID+1;
            iSurf{sID}=mySurfCub(sID,...
                                 iSpline{splineID(i,1)},...
                                 iSpline{splineID(i,2)});                
            surfIDs(i)=sID; 
            handles.Tech.Surf(sID)=Surf(sID);            
        end,   
        %toc,disp('time to generate geometrycal profiles & surfaces')
    end
% 3.Rebuilding CPACS info
    for kkkk=1
    % 3.0.section position in percentage of positioning vector projected 
        tollPos=0.005;
        etaSect=PosVect.eta;
    % 3.1.Plot simplyfied 
        LTELinesIDs=[];
        for i=1:Npos                       
            %main points on section A (sectID(i,1))
            A=sectID(i,1); B=sectID(i,2);
            for j=1:3
                xLE0(A,j)=prof_wing(A).pnt_pos(prof_wing(A).iLE,j);                            
                xTE0(A,j)=(prof_wing(A).pnt_pos(1,j)+prof_wing(A).pnt_pos(end,j))/2;
                %main points on section B (sectID(i,2))
                xLE0(B,j)= prof_wing(B).pnt_pos(prof_wing(B).iLE,j);  
                xTE0(B,j)=(prof_wing(B).pnt_pos(1,j)+prof_wing(B).pnt_pos(end,j))/2;
            end                            
            % plot Leading & Trailing Edge
            pID=pID+1;
%                 handles.Tech.Curve(pID)=line([xLE0(A,1) xLE0(B,1) ],...
            Curve(pID)=line([xLE0(A,1) xLE0(B,1) ],...
                            [xLE0(A,2) xLE0(B,2) ],...
                            [xLE0(A,3) xLE0(B,3) ],'LineWidth',1,'Color','k');
            % set(Curve(pID),'DisplayName',['Curve' num2str(pID)
            % '_LeadingEdge']); % per grafica
            pID=pID+1;
            Curve(pID)=line([xTE0(A,1) xTE0(B,1) ],...
                            [xTE0(A,2) xTE0(B,2) ],...
                            [xTE0(A,3) xTE0(B,3) ],'LineWidth',1,'Color','k');
            % set(Curve(pID),'DisplayName',['Curve' num2str(pID)
            % '_TrailingEdge']); % per grafica
%                 BaseCurveIDs(A,:)=[pID-2,pID-1];
            LTELinesIDs=[LTELinesIDs, pID-1,pID];            
        end
    % 3.2.Searching points BiLinear Function
%         node=[0 0;1 0;1 1;0 1];
%         syms u v real
%         No=[1 u v u*v];
%         for i=1:4, Noi(i,:)=subs(No,{u,v},{node(i,1), node(i,2)});  end ,  
%         Aic=Noi\eye(4);     N=No*Aic; 
        Aic =[     1     0     0     0
                  -1     1     0     0
                  -1     0     0     1
                   1    -1     1    -1];
    % 3.3.Trailing Edge Devices
        try
            TED=ac.vehicles{1}.aircraft{1}.model{1}.wings{1}.wing{wingID}.componentSegments{1}.componentSegment{1}.controlSurfaces{1}.trailingEdgeDevices{1};
            Nted=length(TED.trailingEdgeDevice);
            TEDLinesIDs=[];
              
            etaLE_A  =zeros(1,Nted);
            sA       =zeros(1,Nted);
            etaLE_sA =zeros(1,Nted);
            xsiLE_A  =zeros(1,Nted);
            xFLLEA0  =zeros(Nted,3);
            xFLTEA0  =zeros(Nted,3);
            etaLE_B  =zeros(1,Nted);
            xsiLE_B  =zeros(1,Nted);
            sB       =zeros(1,Nted);
            etaLE_sB =zeros(1,Nted);
            xFLLEB0  =zeros(Nted,3);
            xFLTEB0  =zeros(Nted,3);
            
            for i=1:Nted
                try
                    nameTED{i}=TED.trailingEdgeDevice{i}.name{1}.CONTENT;
                catch 
                    nameTED{i}='';
                end
            % innerBoarder
                % catch TED data 
                    etaLE_A(i)=str2num(TED.trailingEdgeDevice{i}.outerShape{1}.innerBorder{1}.etaLE{1}.CONTENT); 
                    %etaTE_A(i)=str2num(TED.trailingEdgeDevice{i}.outerShape{1}.innerBorder{1}.etaTE{1}.CONTENT);
                    xsiLE_A(i)=str2num(TED.trailingEdgeDevice{i}.outerShape{1}.innerBorder{1}.xsiLE{1}.CONTENT);
                % find refering section 
                    output=posVectFun(3,0,PosVect,etaLE_A(i));                                        
                    sA(i) =output{2};
                % lump eta i on section eta               
                    if abs(etaLE_A(i)-etaSect(sectID(sA(i),1)))<tollPos, etaLE_A(i)=etaSect(sectID(sA(i),1)); end
                % rescaling on section                                                
                    etaLE_sA(i)=(etaLE_A(i)-etaSect(sectID(sA(i),1)))/(etaSect(sectID(sA(i),2))-etaSect(sectID(sA(i),1)));
                    %etaTE_sA(i)=(etaLE_A(i)-etaSect(sectID(sA(i),1)))/(etaSect(sectID(sA(i),2))-etaSect(sectID(sA(i),1)))
            % outerBorder 
                % catch TED data
                    etaLE_B(i)=str2num(TED.trailingEdgeDevice{i}.outerShape{1}.outerBorder{1}.etaLE{1}.CONTENT);
                    %etaTE_B(i)=str2num(TED.trailingEdgeDevice{i}.outerShape{1}.outerBorder{1}.etaTE{1}.CONTENT);
                    xsiLE_B(i)=str2num(TED.trailingEdgeDevice{i}.outerShape{1}.outerBorder{1}.xsiLE{1}.CONTENT);
                % find refering section                    
                    output=posVectFun(3,0,PosVect,etaLE_B(i));                                       
                    sB(i)=output{2};
                % lump eta i on section eta               
                    if abs(etaLE_B(i)-etaSect(sectID(sB(i),1)))<tollPos, etaLE_B(i)=etaSect(sectID(sB(i),1)); end
                % rescaling on section
                    etaLE_sB(i)=(etaLE_B(i)-etaSect(sectID(sB(i),1)))/(etaSect(sectID(sB(i),2))-etaSect(sectID(sB(i),1)));                             
                % spatial position
                    for j=1:3                  
                        xFLLEA0(i,j)=[1 xsiLE_A(i),etaLE_sA(i) xsiLE_A(i)*etaLE_sA(i)]*Aic*[ xLE0(sA(i),j) xTE0(sA(i),j) xTE0(sA(i)+1,j) xLE0(sA(i)+1,j)]';
                        %xFLTEA0(i,j)=subs(N,{u,v},{    1     ,etaTE_sA(i)})*[ xLE0(sA(i),j) xTE0(sA(i),j) xTE0(sA(i)+1,j) xLE0(sA(i)+1,j)]';
                        xFLTEA0(i,j)=[1     1     ,etaLE_sA(i)     1     *etaLE_sA(i)]*Aic*[ xLE0(sA(i),j) xTE0(sA(i),j) xTE0(sA(i)+1,j) xLE0(sA(i)+1,j)]';
                        xFLLEB0(i,j)=[1 xsiLE_B(i),etaLE_sB(i) xsiLE_B(i)*etaLE_sB(i)]*Aic*[ xLE0(sB(i),j) xTE0(sB(i),j) xTE0(sB(i)+1,j) xLE0(sB(i)+1,j)]';
                        %xFLTEB0(i,j)=subs(N,{u,v},{    1     ,etaTE_sB(i)})*[ xLE0(sB,j) xTE0(sB,j) xTE0(sB+1,j) xLE0(sB+1,j)]';
                        xFLTEB0(i,j)=[1     1     ,etaLE_sB(i)     1     *etaLE_sB(i)]*Aic*[ xLE0(sB(i),j) xTE0(sB(i),j) xTE0(sB(i)+1,j) xLE0(sB(i)+1,j)]';
                    end    
                % plot boundary lines
                    pID=pID+1;
                    Curve(pID)=line([xFLLEA0(i,1) xFLTEA0(i,1) xFLTEB0(i,1) xFLLEB0(i,1) xFLLEA0(i,1)],...
                                    [xFLLEA0(i,2) xFLTEA0(i,2) xFLTEB0(i,2) xFLLEB0(i,2) xFLLEA0(i,2)],...
                                    [xFLLEA0(i,3) xFLTEA0(i,3) xFLTEB0(i,3) xFLLEB0(i,3) xFLLEA0(i,3)],'LineWidth',1,'Color','b');
                   % set(Curve(pID),'DisplayName',['Curve' num2str(pID) '_TED']); % per grafica                 
                    TEDLinesIDs=[TEDLinesIDs, pID];
            end
            for i=1:Nted, 
                etaTED(2*(i-1)+1:2*i)=[etaLE_A(i) etaLE_B(i)]; 
                xsiTED(2*(i-1)+1:2*i)=[xsiLE_A(i) xsiLE_B(i)];
            end
        catch           
            Nted=0;
            TEDLinesIDs=[];
            etaLE_A=[];     
            xsiLE_A=[];    
            etaLE_B=[];		 
            xsiLE_B=[];
        end
    % 3.4.Spar Positionin
        try
            STRUCTURE=ac.vehicles{1}.aircraft{1}.model{1}.wings{1}.wing{1}.componentSegments{1}.componentSegment{1}.structure{1};
            NsparP=length(STRUCTURE.spars{1}.sparPositions{1}.sparPosition);
            etaSpar=zeros(1,NsparP);
            xsiSpar=zeros(1,NsparP);
            etasSpar=zeros(1,NsparP);
            xSP0=zeros(NsparP,3);
            for i=1:NsparP
                etaSpar(i) =str2num( STRUCTURE.spars{1}.sparPositions{1}.sparPosition{i}.eta{1}.CONTENT);
                xsiSpar(i) =str2num( STRUCTURE.spars{1}.sparPositions{1}.sparPosition{i}.xsi{1}.CONTENT);
                nameSpar{i}=         STRUCTURE.spars{1}.sparPositions{1}.sparPosition{i}.ATTRIBUTE.uID;
                % find refering section
                    output=posVectFun(3,0,PosVect,etaSpar(i));                                        
                    sS(i) =output{2};
                % lump eta i on section eta               
                    if abs(etaSpar(i)-etaSect(sS(i)))<tollPos, etaSpar(i)=etaSect(sS(i)); end
                % rescaling on section                    
                    etasSpar(i)=(etaSpar(i)-etaSect(sectID(sS(i),1)))/(etaSect(sectID(sS(i),2))-etaSect(sectID(sS(i),1)));
                % spatial position               
                for j=1:3                  
                    xSP0(i,j)=[1 xsiSpar(i),etasSpar(i) xsiSpar(i)*etasSpar(i)]*Aic*[ xLE0(sS(i),j) xTE0(sS(i),j) xTE0(sS(i)+1,j) xLE0(sS(i)+1,j)]';
                    %xSPup0(i,j) =
                    %xSPlow0(i,j)=
                end            
            end
            % Number of spars
            NsparS=length(STRUCTURE.spars{1}.sparSegments{1}.sparSegment);
            for i=1:NsparS
                % Number of point per spar
                NsparPP=length(STRUCTURE.spars{1}.sparSegments{1}.sparSegment{i}.sparPositionUIDs{1}.sparPositionUID);
                j=1; k=1; iter=1;
                while j<=NsparPP 
                    if strcmp(STRUCTURE.spars{1}.sparSegments{1}.sparSegment{i}.sparPositionUIDs{1}.sparPositionUID{j}.CONTENT  ,  nameSpar{k})
                        iSpar{i}.posID(j)=k;   
                        iSpar{i}.sS(j)=sS(k);
                        iSpar{i}.eta(j)=etaSpar(k);
                        iSpar{i}.xsi(j)=xsiSpar(k);
                        iSpar{i}.xSP0(j,:)=xSP0(k,:);
                        j=j+1;
                        k=1;                    
                    else 
                        k=k+1;
                    end 
                end  
            end
        catch
            NsparS=2;
            %etaSpar=etaSect;
            iSpar{1}.eta=etaSect;               iSpar{2}.eta=etaSect;
            iSpar{1}.xsi=.2*ones(1,Nsec);       iSpar{2}.xsi=.6*ones(1,Nsec);
            for i=1:Npos
                for j=1:3                  
                    xSP0(sectID(i,1),j)=[1 .2,0 .2*0]*Aic*[ xLE0(sectID(i,1),j) xTE0(sectID(i,1),j) xTE0(sectID(i,2),j) xLE0(sectID(i,2),j)]';
                    xSP0(sectID(i,2),j)=[1 .2,1 .2*1]*Aic*[ xLE0(sectID(i,1),j) xTE0(sectID(i,1),j) xTE0(sectID(i,2),j) xLE0(sectID(i,2),j)]';
                end
            end
            iSpar{1}.xSP0=xSP0;
            for i=1:Npos
                for j=1:3                  
                    xSP0(sectID(i,1),j)=[1 .6,0 .6*0]*Aic*[ xLE0(sectID(i,1),j) xTE0(sectID(i,1),j) xTE0(sectID(i,2),j) xLE0(sectID(i,2),j)]';
                    xSP0(sectID(i,2),j)=[1 .6,1 .6*1]*Aic*[ xLE0(sectID(i,1),j) xTE0(sectID(i,1),j) xTE0(sectID(i,2),j) xLE0(sectID(i,2),j)]';
                end
            end
            iSpar{2}.xSP0=xSP0;
        end
        % plot spars line
        SprLinesIDs=[];        
        for i=1:NsparS
            sprID=sprID+1;
            handles.Tech.SparLine(sprID)=line(iSpar{i}.xSP0(:,1),iSpar{i}.xSP0(:,2),iSpar{i}.xSP0(:,3),'LineWidth',1,'Color','g','Marker','.');
            % set(handles.Tech.SparLine(sprID),'DisplayName',['Curve'
            % num2str(sprID) '_Spar']); % per grafica
            SprLinesIDs=[SprLinesIDs sprID];
        end
    end
% 4.Symmetry
    for kkkk=1
    if symmetry~=0
        if     strcmp(symmetry,'x-z-plane'), sym1= 1; sym2=-1; sym3= 1;
        elseif strcmp(symmetry,'y-z-plane'), sym1=-1; sym2= 1; sym3= 1;
        elseif strcmp(symmetry,'x-y-plane'), sym1= 1; sym2= 1; sym3=-1;
        end

        for i=profileIDs
            pID=pID+1;
            %Curve(pID)=line(sym1*get(Curve(i),'XData'),sym2*get(Curve(i),'YData'),sym3*get(Curve(i),'ZData'),'LineWidth',1,'Color','k');
            %set(Curve(pID),...
               % 'DisplayName',[get(Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')'],...
               % 'Tag'        ,[get(Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')']);
               % per grafica
        end
        for i=LTELinesIDs
            pID=pID+1;
            Curve(pID)=line(sym1*get(Curve(i),'XData'),sym2*get(Curve(i),'YData'),sym3*get(Curve(i),'ZData'),'LineWidth',1,'Color','k');
            %set(Curve(pID),...
             %   'DisplayName',[get(Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')'],...
              %  'Tag'        ,[get(Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')']);
              % per grafica
        end
        for i=TEDLinesIDs
            pID=pID+1;
            Curve(pID)=line(sym1*get(Curve(i),'XData'),sym2*get(Curve(i),'YData'),sym3*get(Curve(i),'ZData'),'LineWidth',1,'Color','b');
            %set(Curve(pID),...
             %   'DisplayName',[get(Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')'],...
              %  'Tag'        ,[get(Curve(i),'DisplayName') '_(Mirror Curve' num2str(i) ')']);
              % per grafica
        end
        for i=SprLinesIDs
            sprID=sprID+1;
            handles.Tech.SparLine(sprID)=line(sym1*get(handles.Tech.SparLine(i),'XData'),sym2*get(handles.Tech.SparLine(i),'YData'),sym3*get(handles.Tech.SparLine(i),'ZData'),'LineWidth',1,'Color','g','Marker','.');
           % set(handles.Tech.SparLine(sprID),...
           %     'DisplayName',[get(handles.Tech.SparLine(i),'DisplayName') '_(Mirror SparLine' num2str(i) ')'],...
           %     'Tag'        ,[get(handles.Tech.SparLine(i),'DisplayName') '_(Mirror SparLine' num2str(i) ')'],...
           %     'Visible','on');
           % per grafica
            SprLinesIDs=[SprLinesIDs sprID];
        end
        for i=surfIDs
            sID=sID+1;
            %Surf(sID)=surf(sym1*get(Surf(i),'XData'),sym2*get(Surf(i),'YData'),sym3*get(Surf(i),'ZData'));
            % set(Surf(sID),'DisplayName',['Surf' num2str(sID) '_(Mirror Surf' num2str(i) ')'],...
            %              'Tag'        ,['Surf' num2str(sID) '_(Mirror Surf' num2str(i) ')']);
            % per grafica
            surfIDs=[surfIDs sID]; 
           % handles.Tech.Surf(sID)=Surf(sID);          
        end
    end

    % set(Surf(:),'EdgeColor'  ,'none','FaceAlpha'  ,0.4,'FaceColor'  ,[.5
    % .5 .5]); % per grafica

%         handles.Tech.Curve = Curve ,handles.Tech.Curve
%         handles.Tech.Surf  = Surf
    %handles.Tech.SparLine = SparLine
%toc,disp('time to read & allocating CPACS''s TED & Spar info')        
    end
% 4.Joint all sigle wings structure in one
    for kkk=1
    %4.1.Main Data
        TechGeoModel.iWing{wingID}.wingID  =wingID;
        TechGeoModel.iWing{wingID}.symmetry=symmetry;
    %4.2.Reference Data
        TechGeoModel.iWing{wingID}.Reference.Area  =Area;
        TechGeoModel.iWing{wingID}.Reference.Span  =Span;
        TechGeoModel.iWing{wingID}.Reference.AR    =(Span*Mirror)^2/(Area*Mirror);%AR;
        TechGeoModel.iWing{wingID}.Reference.mac   =mac;
        TechGeoModel.iWing{wingID}.Reference.xLEmac=xLEmac;
        %iWing.Reference
    %4.3.Geometry Data
        %4.3.1.Section Data
        TechGeoModel.iWing{wingID}.Geometry.prof_wing= prof_wing;        
        %4.3.2.Positioning & CompSegment Data
        TechGeoModel.iWing{wingID}.Geometry.sectID   = sectID;                  
        TechGeoModel.iWing{wingID}.Geometry.lenght   = lenght;
        TechGeoModel.iWing{wingID}.Geometry.sweep    = sweep;
        TechGeoModel.iWing{wingID}.Geometry.dihedral = dihedral;                 
        TechGeoModel.iWing{wingID}.Geometry.PosVect  = ivect; 
        TechGeoModel.iWing{wingID}.Geometry.span     = span;
        TechGeoModel.iWing{wingID}.Geometry.etaSect  = etaSect; 
        TechGeoModel.iWing{wingID}.Geometry.PosVect  = PosVect; 
        %4.3.3.Gometrical Entities Reference IDs
        TechGeoModel.iWing{wingID}.Geometry.profileIDs  = profileIDs;
        TechGeoModel.iWing{wingID}.Geometry.surfIDs     = surfIDs;               
        TechGeoModel.iWing{wingID}.Geometry.LTELinesIDs = LTELinesIDs; 
        
        %TechGeoModel.iWing{wingID}.Geometry       
    %4.4.Trailing Edge Devices (TED)
        try
            TechGeoModel.iWing{wingID}.Geometry.TED.name    = nameTED;
            TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_A = etaLE_A;     
            TechGeoModel.iWing{wingID}.Geometry.TED.xsiLE_A = xsiLE_A;     
            TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_B = etaLE_B;		 
            TechGeoModel.iWing{wingID}.Geometry.TED.xsiLE_B = xsiLE_B;    
            %TechGeoModel.iWing{wingID}.Geometry.TED.xsiLE_B=xsiTED;
            TechGeoModel.iWing{wingID}.Geometry.TED.TEDLinesIDs = TEDLinesIDs;
            %TechGeoModel.iWing{wingID}.Geometry.TED
        end
    %4.5.Structure               
        %TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.xSP0        =xSP0;
        TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar       =iSpar;
%         TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.etaSpar     =etaSpar;
%         TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.xsiSpar     =xsiSpar; 
        TechGeoModel.iWing{wingID}.Geometry.Structure.SprLinesIDs =SprLinesIDs;
        %TechGeoModel.iWing{wingID}.Geometry.Structure.Spar
    end
elseif TechMode==21 || TechMode==22
    for kkk=1
    %iWing.wingID  =wingID;
    symmetry=TechGeoModel.iWing{wingID}.symmetry;
    %4.2.Reference Data
        %Area    =TechGeoModel.iWing{wingID}.Reference.Area;
        Span    =TechGeoModel.iWing{wingID}.Reference.Span;
        %AR      =TechGeoModel.iWing{wingID}.Reference.AR;
        %mac     =TechGeoModel.iWing{wingID}.Reference.mac   ;
        %xLEmac  =TechGeoModel.iWing{wingID}.Reference.xLEmac;
        %iWing.Reference
        %4.3.Geometry Data
            %4.3.1.Section Data
                prof_wing=TechGeoModel.iWing{wingID}.Geometry.prof_wing;        
            %4.3.2.Positioning & CompSegment Data
                sectID   =TechGeoModel.iWing{wingID}.Geometry.sectID;                  
                %lenght   =TechGeoModel.iWing{wingID}.Geometry.lenght;
                %sweep    =TechGeoModel.iWing{wingID}.Geometry.sweep;
                %dihedral =TechGeoModel.iWing{wingID}.Geometry.dihedral;                 
                %ivect    =TechGeoModel.iWing{wingID}.Geometry.PosVect; 
                span     =TechGeoModel.iWing{wingID}.Geometry.span;
                etaSect  =TechGeoModel.iWing{wingID}.Geometry.etaSect;         
            %4.3.3.Gometrical Entities Reference IDs
                profileIDs =TechGeoModel.iWing{wingID}.Geometry.profileIDs;
                surfIDs     =TechGeoModel.iWing{wingID}.Geometry.surfIDs;
                LTELinesIDs=TechGeoModel.iWing{wingID}.Geometry.LTELinesIDs;
        %4.4.Trailing Edge Devices (TED)
            %    iWing.Geometry.TED.name =[]; 
            try
                etaLE_A=TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_A;     
                xsiLE_A=TechGeoModel.iWing{wingID}.Geometry.TED.xsiLE_A;     
                etaLE_B=TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_B;		 
                xsiLE_B=TechGeoModel.iWing{wingID}.Geometry.TED.xsiLE_B;
                %xsiTED =TechGeoModel.iWing{wingID}.Geometry.TED.xsiTED;
                TEDLinesIDs=TechGeoModel.iWing{wingID}.Geometry.TED.TEDLinesIDs;
                %iWing.Geometry.TED
                Nted=length(TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_A);
            end
        %4.5.Structure 
%            xSP0        =TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.xSP0;
            iSpar       =TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar;
%            etaSpar     =TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.etaSpar;
%            xsiSpar     =TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.xsiSpar; 
            SprLinesIDs =TechGeoModel.iWing{wingID}.Geometry.Structure.SprLinesIDs;
            %iWing.Geometry.Strucuture.Spar
    
    Nsec=length(TechGeoModel.iWing{wingID}.Geometry.prof_wing);
    Npos=length(TechGeoModel.iWing{wingID}.Geometry.span);
    
    end
end
%toc,disp('time to save in a structure info')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5.0.section position in percentage of span 
    for kkkk=1
        tollPos=0.005;
        for i=1:Nsec
            if i==1
                %etaSect(i)=0;
                vS_sect(i)=i;
            else
                %etaSect(i)=sum(span(1:i-1))/Span;
                vS_sect(i)=i;
            end
        end
    % 5.1.Plot simplyfied 
        %ibord=1; %BaseCurveIDs=[];
        for i=1:Npos
            if sectID(i,1)~=0           
                %main points on section A (sectID(i,1))
                A=sectID(i,1); B=sectID(i,2);
                for j=1:3
                xLE0(A,j)=prof_wing(A).pnt_pos(prof_wing(A).iLE,j);                            
                xTE0(A,j)=(prof_wing(A).pnt_pos(1,j)+prof_wing(A).pnt_pos(end,j))/2;
                %main points on section B (sectID(i,2))
                xLE0(B,j)= prof_wing(B).pnt_pos(prof_wing(B).iLE,j);  
                xTE0(B,j)=(prof_wing(B).pnt_pos(1,j)+prof_wing(B).pnt_pos(end,j))/2;
                end   
            end
        end
% 3.2.Searching points BiLinear Function
%         node=[0 0;1 0;1 1;0 1];
%         syms u v real
%         No=[1 u v u*v];
%         for i=1:4, Noi(i,:)=subs(No,{u,v},{node(i,1), node(i,2)});  end ,  
%         Aic=Noi\eye(4);     N=No*Aic; 
        Aic =[     1     0     0     0
                  -1     1     0     0
                  -1     0     0     1
                   1    -1     1    -1];
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Technology menù
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6.Beam Model
if TechMode==1 || TechMode==20 || TechMode==21 
    for kkk=1
    % 6.1.get general info & sort         
%         for i=1:Nsec
%             etaSect(i)=sum(span(1:i))/Span;
%             vS_sect(i)=i;
%         end
        etaBeam=etaSect; 
        vS=vS_sect;
        %etaBeam=PosVect.eta
    % 6.2.spatial position of Beam element @ %distance between 1st & last spar 
        dSpar=0.5;
        for i=1:length(etaBeam)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             k=1; 
%             eta_tmp(1)=iSpar{ 1 }.eta(1); xsi_tmp(1)=iSpar{ 1 }.xsi(1);
%             for j=2:length(iSpar{ 1 }.eta)
%                 if iSpar{ 1 }.eta(j)~=eta_tmp(k)
%                     j,k=k+1
%                     eta_tmp(k)=iSpar{ 1 }.eta(j)
%                     xsi_tmp(k)=iSpar{ 1 }.xsi(j)
%                 end
%             end
%             xsiBeamFS(i)=interp1(eta_tmp,xsi_tmp,etaBeam(i));
%             
%             k=1; 
%             eta_tmp(1)=iSpar{ end }.eta(1); xsi_tmp(1)=iSpar{ end }.xsi(1);
%             for j=2:lengthi(iSpar{ end }.eta)
%                 if iSpar{ 1 }.eta(j)~=eta_tmp(k)
%                     k=k+1;
%                     eta_tmp(k)=iSpar{ end }.eta(j);
%                     xsi_tmp(k)=iSpar{ end }.xsi(j);
%                 end
%             end
%             xsiBeamFS(i)=interp1(eta_tmp,xsi_tmp,etaBeam(i));
            xsiBeamFS(i)=interp1(iSpar{ 1 }.eta,iSpar{ 1 }.xsi,etaBeam(i));
            xsiBeamRS(i)=interp1(iSpar{end}.eta,iSpar{end}.xsi,etaBeam(i));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            xsiBeam(i)  =xsiBeamFS(i)+(xsiBeamRS(i)-xsiBeamFS(i))*dSpar;
            if i==1
                etasBeam(i)=0;
                for j=1:3                  
                    xBeam0(i,j)=[1 xsiBeam(i),etasBeam(i) xsiBeam(i)*etasBeam(i)]*Aic*[ xLE0(vS(i),j) xTE0(vS(i),j) xTE0(vS(i)+1,j) xLE0(vS(i)+1,j)]'; 
                end
            else
                etasBeam(i)=1;%(etaBeam(i)-sum(etaBeam(1:i-1)))*Span/span(i);
                for j=1:3                  
                    xBeam0(i,j)=[1 xsiBeam(i),etasBeam(i) xsiBeam(i)*etasBeam(i)]*Aic*[ xLE0(vS(i)-1,j) xTE0(vS(i)-1,j) xTE0(vS(i),j) xLE0(vS(i),j)]'; 
                end
            end     
        end

    % 6.3.defining node by spars segment
        if TechMode==1 || TechMode==20 
            dRib=0.5; %distanza fra le centine [m]
            jAcB = 1        % *********** Aggiunto per AcBuilder *********
            for i=1:length(etaBeam)-1
                BeamSparLength(i)=norm(xBeam0(i+1,:)'-xBeam0(i,:)');
                nodeSect(i)=round(BeamSparLength(i)/dRib)+1;
                wingID                  % ************* controllo
                % *************** Modifica per AcBuilder *****************
                if length(etaBeam) > 3
                nodeSect(i)=AcBeamsW(i) + 1
                else
                %jAcB = i
                nodeSect(i)=AcBeamsW(jAcB) + 1
                jAcB = jAcB + 2
                end
                % ********************************************************
            end
        elseif TechMode==21             
            BoardID=varargin{1};
            dRib=0.5; %distanza fra le centine [m]        
            for i=1:length(etaBeam)-1
                %TechMode 21
                if i~=BoardID
                    %BeamSparLength(i)=norm(xBeam0(i+1,:)'-xBeam0(i,:)');
                    %nodeSect(i)=round(BeamSparLength(i)/dRib);
                    nodeSect(i)=TechGeoModel.iWing{wingID}.beamModel.nodeSect(i);
                else
                    nodeSect(i)=varargin{2};
                end
            end           
        end    
        xBeam=[];
        for i=1:length(etaBeam)-1
            xBeam=[xBeam;...
                   linspace(xBeam0(i,1),xBeam0(i+1,1),nodeSect(i))',...
                   linspace(xBeam0(i,2),xBeam0(i+1,2),nodeSect(i))',...
                   linspace(xBeam0(i,3),xBeam0(i+1,3),nodeSect(i))'];
        end
        zBeam=xBeam(:,3);yBeam=xBeam(:,2);xBeam=xBeam(:,1);
        
        if TechMode==1 || TechMode==20 || TechMode==22
            belID=belID+1; belIDs=belID;                      
        elseif TechMode==21 
            belIDs=TechGeoModel.iWing{wingID}.beamModel.belIDs;
            % display(['BeamLines ' num2str(belIDs) ' refreshed' ]) % per
            % grafica
            delete(handles.Tech.BeamLine(belIDs));
            belID =belIDs(1);
            belIDs=belID;                    
        end 
            handles.Tech.BeamLine(belID)=plot3(xBeam,yBeam,zBeam);
            %set(handles.Tech.BeamLine(belID),'DisplayName',['Curve' num2str(pID) '_Beam'],...
                   %                          'LineWidth'  , 1,...
                   %                          'Color'      ,'r',...
                   %                          'Marker'     ,'d',...
                    %                         'MarkerFaceColor','b',...
                    %                         'MarkerEdgeColor','b',...
                    %                         'MarkerSize' , 4);
                    % per grafica
    % 6.4.Simmetry
        if symmetry~=0
            if strcmp(symmetry,'x-z-plane'),     sym1= 1; sym2=-1; sym3= 1;
            elseif strcmp(symmetry,'y-z-plane'), sym1=-1; sym2= 1; sym3= 1;
            elseif strcmp(symmetry,'x-y-plane'), sym1= 1; sym2= 1; sym3=-1;
            end
            for i=belIDs
                belID=belID+1;
                handles.Tech.BeamLine(belID)=plot3( sym1*get(handles.Tech.BeamLine(i),'XData'),...
                                                    sym2*get(handles.Tech.BeamLine(i),'YData'),...
                                                    sym3*get(handles.Tech.BeamLine(i),'ZData'),'LineWidth',1,'Color','g','Marker','.');
               % set(handles.Tech.BeamLine(belID),'DisplayName',[get(handles.Tech.BeamLine(i),'DisplayName') '_(Mirror SparLine' num2str(i) ')'],...
                     %                            'Tag'        ,[get(handles.Tech.BeamLine(i),'DisplayName') '_(Mirror SparLine' num2str(i) ')'],...
                      %                           'LineWidth'  ,1,...
                       %                          'Color'      ,'r',...
                       %                          'Marker'     ,'d',...
                       %                          'MarkerFaceColor','b',...
                        %                         'MarkerEdgeColor','b',...
                         %                        'MarkerSize' ,4);
                         % per grafica
                belIDs=[belIDs, belID];
            end
        end
    % 6.5.Add info to iWing struct
        TechGeoModel.iWing{wingID}.beamModel.nodeSect   = nodeSect;
		TechGeoModel.iWing{wingID}.beamModel.belIDs     = belIDs;
		TechGeoModel.iWing{wingID}.beamModel.Grid.xBeam = xBeam;
		TechGeoModel.iWing{wingID}.beamModel.Grid.yBeam = yBeam;
		TechGeoModel.iWing{wingID}.beamModel.Grid.zBeam = zBeam;	
        %iWing.beamModel
    end
elseif TechMode==22 
%     nodeSect=iWing.beamModel.nodeSect  ;
% 		iWing.beamModel.belIDs    = belIDs;
% 		iWing.beamModel.Grid.xBeam= xBeam;
% 		iWing.beamModel.Grid.yBeam= yBeam;
% 		iWing.beamModel.Grid.zBeam= zBeam;    
end 
%toc, disp('time to generate beamModel')    
    
%% 7.Aero Pannels Model 
if TechMode==1 || TechMode==20 || TechMode==22
    for kkk=1
    % 6.1.auto pannel sizing 
    if TechMode==1 || TechMode==20 
        detaPan_eta=0.4/PosVect.L;
        for i=1:Nsec-1
            
          if i == 2 && Nsec < 4 % <<<<<<<<<<<<< For AcBuilder *********************
              
            ny(i)   = abs(round((etaSect(i+1)-etaSect(i))/detaPan_eta));
            ny(i) = AcAeroW(i+1,2);
            if ny(i)==0
                ny(i)=2;
            end           
            nx(i)   =AcAeroW(i+1,1); % 14
            
            nxTED(i)= 7;
            
          else % <<<<<<<<<<<<< For AcBuilder *********************
              
            ny(i)   = abs(round((etaSect(i+1)-etaSect(i))/detaPan_eta));
            ny(i) = AcAeroW(i,2);
            if ny(i)==0
                ny(i)=2;
            end           
            nx(i)   =AcAeroW(i,1); % 14
            
            nxTED(i)= 7;
            
          end % <<<<<<<<<<<<< For AcBuilder ********************* 
          
        end
    elseif TechMode==22
        BoardID=varargin{1};
        ni=varargin{2};
        %detaPan_eta=0.4/Span;
        for i=1:Nsec-1
            if i~=BoardID
                ny(i)   =TechGeoModel.iWing{wingID}.aeroPanel.ny(i);
                nx(i)   =TechGeoModel.iWing{wingID}.aeroPanel.nx(i);
                nxTED(i)=TechGeoModel.iWing{wingID}.aeroPanel.nxTED(i);                   
            else
                if ni==1
                    ny(i)   =varargin{3};
                    nx(i)   =TechGeoModel.iWing{wingID}.aeroPanel.nx(i);
                    nxTED(i)=TechGeoModel.iWing{wingID}.aeroPanel.nxTED(i);
                elseif ni==2
                    ny(i)   =TechGeoModel.iWing{wingID}.aeroPanel.ny(i);
                    nx(i)   =varargin{3};
                    nxTED(i)=TechGeoModel.iWing{wingID}.aeroPanel.nxTED(i); 
                elseif ni==3
                    ny(i)   =TechGeoModel.iWing{wingID}.aeroPanel.ny(i);
                    nx(i)   =TechGeoModel.iWing{wingID}.aeroPanel.nx(i);
                    nxTED(i)=varargin{3}; 
                end           
            end
        end
        for i=1:Nted, 
            etaTED(2*(i-1)+1:2*i)=[etaLE_A(i) etaLE_B(i)]; 
            xsiTED(2*(i-1)+1:2*i)=[xsiLE_A(i) xsiLE_B(i)];
        end
    end       
        for i=1:Nsec-1
            if i==1
                vABox(1,1)=1;
                vABox(1,2)=1+ny(i);
            else
                vABox(i,1)=vABox(i-1,2)+1;
                vABox(i,2)=vABox(i,1)+ny(i);
            end
            etaPan(vABox(i,1):vABox(i,2))=linspace(etaSect(i),etaSect(i+1),ny(i)+1);
            vP(vABox(i,1):vABox(i,2))=i.*ones(1,ny(i)+1);
        end
    % 6.2.Insert TED node
        if Nted~=0
        % 6.2.1.Insert TED node
            j=1; h=1;
            for i=1:Nted
                %TED A side
                %search section
                while etaPan(j)<=etaLE_A(i), j=j+1; end
                j=j-1;  vTED_A(i)=j; sectTED_A(i)=vP(j);
                %assign node value                                
                vTED_A(i)=j; sectTED_A(i)=vP(j);
                %min distance criterion
                if etaLE_A(i)>etaPan(vABox(sectTED_A(i),1)) && etaLE_A(i)<=etaPan(vABox(sectTED_A(i),2))
                    if abs(etaPan(j)-etaLE_A(i))<=abs(etaPan(j+1)-etaLE_A(i))
                        etaPan(j)=etaLE_A(i);
                        vTED_A(i)=j;
                    else                   
                        j=j+1;
                        etaPan(j)=etaLE_A(i);
                        vTED_A(i)=j;
                    end
                end
                %TED B side
                %search section
                while etaPan(h)<etaLE_B(i),  h=h+1;      end
                %assign node value  
                vTED_B(i)=h; sectTED_B(i)=vP(h);                
                %min distance criterion
                if etaLE_B(i)>=etaPan(vABox(sectTED_B(i),1)) && etaLE_B(i)<etaPan(vABox(sectTED_B(i),2))
                    if abs(etaPan(h-1)-etaLE_B(i))<=abs(etaPan(h)-etaLE_B(i))
                        h=h-1;
                        etaPan(h)=etaLE_B(i);
                        vTED_B(i)=h;
                    else             
                        etaPan(h)=etaLE_B(i);
                        vTED_B(i)=h;
                    end
                end
            end
        % 6.2.2.TED line       
            vTED=zeros(size(vP));
            for i=1:Nted,
                for j=vTED_A(i):vTED_B(i),
                    vTED(j)=i; 
                end,
            end
            for i=1:Nsec-1
                for j=vABox(i,1):vABox(i,2)
                    if etaPan(j)<=etaPan(vTED_A(1))
                        %1)Before first TED
                        xsiLineTED(j)=xsiTED(1);
                    elseif etaPan(j)>=etaPan(vTED_B(end))
                        %2)After last TED
                        xsiLineTED(j)=xsiTED(end);
                    else
                        if vTED(j)~=0
                            %31)On a TED
                            xsiLineTED(j)=interp1([etaPan(vTED_A(vTED(j))) etaPan(vTED_B(vTED(j)))],...
                                                 [      xsiLE_A(vTED(j))        xsiLE_B(vTED(j)) ],etaPan(j));
                        else
                            %32)Between two different TED
                            k=j;
                            while vTED(k)==0, k=k-1; end
                            h=j;
                            while vTED(h)==0, h=h+1; end
                            xsiLineTED(j)=interp1([etaPan(vTED_B(vTED(k))) etaPan(vTED_A(vTED(h)))],...
                                                 [      xsiLE_B(vTED(k))        xsiLE_A(vTED(h)) ],etaPan(j));
                        end
                    end
                end
            end        
        %6.3.2.vector Aerodynamic Box TED
            for h=1:Nsec-1,
                %inizializzo i box a 1
                Nbox(h)=1; 
                for i=vABox(h,1):vABox(h,2) -1
                    % se la prima posizione i è uguale al 1o elemento del box                    
                    if i==vABox(h,1)              
                        vABoxTED(h,Nbox(h))=i;
                    % se     
                    elseif vTED(i)~=vTED(i+1) 
                        if vTED(i)==0, cost=1; else, cost=0; end
                        %if h==1, cost=0; end
                        %if (i+1*cost)~=vABoxTED(h,Nbox(h))
                            
                            Nbox(h)=Nbox(h)+1;
                            vABoxTED(h,Nbox(h))=i+1*cost; 
                        %end
                    end
                end
                 Nbox(h)=Nbox(h)+1;
                 vABoxTED(h,Nbox(h))=i+1;
            end
            %Check vABoxTED hasn't same element
            for h=1:Nsec-1
                for k=2:Nbox(h)
                    if vABoxTED(h,k-1)==vABoxTED(h,k)
                        vABoxTED(h,k)=0;
                        Nbox(h)=Nbox(h)-1;
                    end
                end
            end;
                
        else
            disp('No TED');
            xsiLineTED=ones(1,length(etaPan));
            Nbox=ones(1,Npos);
        end
    % 6.4.     
        for h=1:Nsec-1
            for i=vABox(h,1):vABox(h,2)    
                etasPan(i)=(etaPan(i)-etaSect(sectID(vP(i),1)))/(etaSect(sectID(vP(i),2))-etaSect(sectID(vP(i),1)));
                xsiPan(i,1:nx(h)+1)      =linspace(   0         ,xsiLineTED(i),  nx(h)+1 );
                xsiPanTED(i,1:nxTED(h)+1)=linspace(xsiLineTED(i),      1      ,nxTED(h)+1);
                for j=1:nx(h)+1 
                    for k=1:3                           
                        %xPann(j,i,k)=subs(N,{u,v},{xsiPann(i,j),etasPann(i)})*[ xLE0(vP(i),k) xTE0(vP(i),k) xTE0(vP(i)+1,k) xLE0(vP(i)+1,k)]'; 
                        Pan{h}.xPan(j,i,k)=[1 xsiPan(i,j)  etasPan(i) xsiPan(i,j)* etasPan(i)]*Aic*[ xLE0(vP(i),k) xTE0(vP(i),k) xTE0(vP(i)+1,k) xLE0(vP(i)+1,k)]';         
                    end
                end
                for j=1:nxTED(h)+1 
                    for k=1:3
                        xTED(1,i,k)=[1 xsiLineTED(i) etasPan(i) xsiLineTED(i)*etasPan(i)]*Aic*[ xLE0(vP(i),k) xTE0(vP(i),k) xTE0(vP(i)+1,k) xLE0(vP(i)+1,k)]';
                        
                        PanTED{h}.xPanTED(j,i,k)=[1 xsiPanTED(i,j)  etasPan(i) xsiPanTED(i,j)* etasPan(i)]*Aic*[ xLE0(vP(i),k) xTE0(vP(i),k) xTE0(vP(i)+1,k) xLE0(vP(i)+1,k)]';
                    end
                end
            end  
        end
    % 6.5.Plot
    if TechMode==1 || TechMode==20
        %plot3(xTED(1,:,1),xTED(1,:,2),xTED(1,:,3),'*-c') 
        abIDs=[];%abIDs{h}=[];
    elseif TechMode==22
        abIDs=TechGeoModel.iWing{wingID}.aeroPanel.abIDs;            
        %abID=abIDs;
        %disp(['deleting aeroBox ' num2str(abIDs) ', and replot']) % per
        %grafica
        delete(handles.Tech.AeroMesh(abIDs))
%             handles.Tech.BeamLine(belID)=plot3(xBeam,yBeam,zBeam); 
%             display(['BeamLine ' num2str(belID) ' refreshed' ])
        abID=abIDs(1)-1; abIDs=[];
    end
    % 6.6.Coloration of Aerodynamic Box
        for h=1:Nsec-1
            %Central Wing
            abID=abID+1;     abIDs=[abIDs, abID];
            handles.Tech.AeroMesh(abID)=surf(Pan{h}.xPan(:,vABox(h,1):vABox(h,2),1),...
                                             Pan{h}.xPan(:,vABox(h,1):vABox(h,2),2),...
                                             Pan{h}.xPan(:,vABox(h,1):vABox(h,2),3));
            %set(handles.Tech.AeroMesh(abID),...
              %  'DisplayName',['Box' num2str(abID) '_AeroMesh'],...
               % 'FaceColor'  ,[.1 0 .8]',...
               % 'EdgeColor'  ,[.5 .5 .5]); 
               % per grafica
            %TED 
            for k=2:Nbox(h)
                abID=abID+1; abIDs=[abIDs, abID];
                %vABoxTED(h,k-1):vABoxTED(h,k)
                handles.Tech.AeroMesh(abID)=surf(PanTED{h}.xPanTED(:,vABoxTED(h,k-1):vABoxTED(h,k),1),...
                                                 PanTED{h}.xPanTED(:,vABoxTED(h,k-1):vABoxTED(h,k),2),...
                                                 PanTED{h}.xPanTED(:,vABoxTED(h,k-1):vABoxTED(h,k),3));
               % set(handles.Tech.AeroMesh(abID),...
                  %  'DisplayName',['Box' num2str(abID) '_AeroMesh'],...
                   % 'EdgeColor',[.5 .5 .5])
                   % per grafica
                    
                colorASurfFlag(h,k-1)=1;
                z=vABoxTED(h,k-1);
                while z<=vABoxTED(h,k) && colorASurfFlag(h,k-1)==1
                    if vTED(z)~=0,   colorASurfFlag(h,k-1)=1; 
                    else,            colorASurfFlag(h,k-1)=0;                        
                    end ,            z=z+1;
                end   
                %1)AeroBox is TED aerofoil
                if  colorASurfFlag(h,k-1), % Per grafica set(handles.Tech.AeroMesh(abID),'FaceColor'  ,[.1 .8 .8]'); 
                %2)AeroBox is not TED aerofoil
                else,                      % Per Grafica set(handles.Tech.AeroMesh(abID),'FaceColor'  ,[.1 0. .8]'); 
                end
            end

        end
    % 6.7.Simmetry 
        if symmetry~=0
            if     strcmp(symmetry,'x-z-plane'), sym1= 1; sym2=-1; sym3= 1;
            elseif strcmp(symmetry,'y-z-plane'), sym1=-1; sym2= 1; sym3= 1;
            elseif strcmp(symmetry,'x-y-plane'), sym1= 1; sym2= 1; sym3=-1;
            end
            for i=abIDs
                abID=abID+1; abIDs=[abIDs, abID];
                %handles.Tech.AeroMesh(abID)=surf(  sym1*get(handles.Tech.AeroMesh(i),'XData'),...
                                                  % sym2*get(handles.Tech.AeroMesh(i),'YData'),...
                                                 %  sym3*get(handles.Tech.AeroMesh(i),'ZData'));%,'LineWidth',1,'Color','g','Marker','.')
                %set(handles.Tech.AeroMesh(abID),...
                  %  'DisplayName',['Box' num2str(abID) '_AeroMesh'],...
                   % 'FaceColor'  ,get(handles.Tech.AeroMesh(i),'FaceColor'),...
                  %  'EdgeColor'  ,get(handles.Tech.AeroMesh(i),'EdgeColor'));
                  % per grafica
            end      
        end
    % 6.8.Add info to iWing struct	           
		TechGeoModel.iWing{wingID}.aeroPanel.ny    =ny;        
        TechGeoModel.iWing{wingID}.aeroPanel.nx    =nx;       
        TechGeoModel.iWing{wingID}.aeroPanel.nxTED =nxTED;               
        TechGeoModel.iWing{wingID}.aeroPanel.abIDs =abIDs;       
        contTED=1;
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        colorASurfFlag(2,2)=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:Npos
            %Central Wing
            %Aefact
            TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.Aefact_span  = etasPan(vABox(i,1):vABox(i,2));    
            TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.Aefact_chord = xsiPan(vABox(i,1),:)/xsiPan(vABox(i,1),end);
            %Vertices
            TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X(1,:) = [Pan{i}.xPan( 1 ,vABox(i,1),1), Pan{i}.xPan( 1 ,vABox(i,1),2), Pan{i}.xPan( 1 ,vABox(i,1),3)];
            TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X(2,:) = [Pan{i}.xPan(end,vABox(i,1),1), Pan{i}.xPan(end,vABox(i,1),2), Pan{i}.xPan(end,vABox(i,1),3)];
            TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X(3,:) = [Pan{i}.xPan(end,vABox(i,2),1), Pan{i}.xPan(end,vABox(i,2),2), Pan{i}.xPan(end,vABox(i,2),3)];
            TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X(4,:) = [Pan{i}.xPan( 1 ,vABox(i,2),1), Pan{i}.xPan( 1 ,vABox(i,2),2), Pan{i}.xPan( 1 ,vABox(i,2),3)];
            
            for h=1:Nbox(i)-1
                TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.Aefact_span =(etasPan(vABoxTED(i,h):vABoxTED(i,h+1))-etasPan(vABoxTED(i,h)))/(etasPan(vABoxTED(i,h+1))-etasPan(vABoxTED(i,h)));
                TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.Aefact_chord=(xsiPanTED(vABoxTED(i,h),:)-xsiPanTED(vABoxTED(i,h),1))/(xsiPanTED(vABoxTED(i,h),end)-xsiPanTED(vABoxTED(i,h),1));
                
                TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.X(1,:)=[PanTED{i}.xPanTED( 1 ,vABoxTED(i, h ),1), PanTED{i}.xPanTED( 1 ,vABoxTED(i, h ),2), PanTED{i}.xPanTED( 1 ,vABoxTED(i, h ),3)];
                TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.X(2,:)=[PanTED{i}.xPanTED(end,vABoxTED(i, h ),1), PanTED{i}.xPanTED(end,vABoxTED(i, h ),2), PanTED{i}.xPanTED(end,vABoxTED(i, h ),3)];
                TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.X(3,:)=[PanTED{i}.xPanTED(end,vABoxTED(i,h+1),1), PanTED{i}.xPanTED(end,vABoxTED(i,h+1),2), PanTED{i}.xPanTED(end,vABoxTED(i,h+1),3)];
                TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.X(4,:)=[PanTED{i}.xPanTED( 1 ,vABoxTED(i,h+1),1), PanTED{i}.xPanTED( 1 ,vABoxTED(i,h+1),2), PanTED{i}.xPanTED( 1 ,vABoxTED(i,h+1),3)];
                
                if colorASurfFlag(i,h)                    
                    TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.name=TechGeoModel.iWing{wingID}.Geometry.TED.name(contTED);
                    contTED=contTED+1;
                else
                    TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.name='Fix';
                end
                TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,h}.name
            end
        end

            
    end
    
end

%save('D150_BoxWing_Wing1.mat','TechGeoModel')
%save('D150_Wing1.mat','TechGeoModel')

toc, disp('time to generate aeroMeshModel') 
    



 