function [aircraft,analysis]=tornadoWrapper(CPACSgeo,CPACS_XML,wingPosVec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Geometry input for Tornado                                            %
%                                                                         %
%   - zugriff auf readgeo                                                 %
%   - ortnet CPACS daten den vordefinierten Stucts zu                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.1b                                                  %
% LastModified:     2011-04-10 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
% ToDo:
% wings
%   - slat
%   - votex lattice from CPACS 
%   - WARNINGS
% weights
% state
%   - loadcases
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Load lib
initialize

%% Settings

% Info
disp('write Tornado input')

% Airplane Name
aircraft.aircraftName=CPACSgeo.aircraftName; 

warning off
%% Under Functions
%%      Aircraft
% Wings
if nargin<3
    wingPosVec=[];
end
[aircraft]=wings(CPACSgeo,aircraft,CPACS_XML,wingPosVec);

% Airfoils
[aircraft]=airfoils(CPACSgeo,aircraft);

% References
[aircraft]=references(CPACSgeo,aircraft);

% Fuselage
if isfield(CPACSgeo,'fuselages')
    [aircraft]=fuselage(CPACSgeo,aircraft);
end

% Engine
[aircraft]=engine(CPACSgeo,aircraft);

% Landingear
[aircraft]=lg(CPACSgeo,aircraft);

% Weight
[aircraft]=weight(CPACSgeo,aircraft);

% Center of Gravity
[aircraft]=CG(CPACSgeo,aircraft);

% Inertial
[aircraft]=inertial(CPACSgeo,aircraft);

%%      Analysis
analysis={};

% Load Case
[analysis]=loadCase(CPACSgeo,analysis);

% State
[analysis]=state(CPACSgeo,analysis);

% Results
[analysis]=results(CPACSgeo,analysis);
%% Save 
% save (aircraft.aircraftName,'aircraft')
% save ([aircraft.aircraftName,'_analysis'],'analysis')
% disp(['Wrappping time: ',num2str(toc), ' s'])

warning on
end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                      - Under Functions -                              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                           - Aircraft -                                %%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - Wings -                                  %%
function [aircraft]=wings(CPACSgeo,aircraft,CPACS_XML,wingPosVec)


    %%%%%%%%%%%%%%%%%    
    %%% Settings  %%%
    %%%%%%%%%%%%%%%%%  

    %number of wings (scalar)    
    geo.nwing= size(CPACSgeo.wings.component,1); 
    
    % Select a wing order (Tornado need the main wing on position 1)
    for i=1:geo.nwing
        wingNamesS{i,1}=CPACSgeo.wings.component{i,1}.name;
    end
    wingName='';
    for i=1:size(wingNamesS,1)
        wingName=[wingName,' ',wingNamesS{i,1},' = ',num2str(i),','];
    end
    
    % Wing order
    autoSelectinRefWing=1;
    % 0 Select with GUI
    % 1 Select auo by using the maximum area
    
    if autoSelectinRefWing==0 
        if size(wingNamesS,1)>1 
            if isempty(wingPosVec)
                vec=1:geo.nwing;
                % Input Window
                wingPosVec = str2num(str2mat(inputdlg(['Insert the order of: ',wingName],'Wing Order',1,{num2str(vec)})));
                if isempty(wingPosVec)
                    wingPosVec=1:geo.nwing;
                end

                disp('New wing positions:')
                for i=1:size(wingNamesS,1)
                    disp([wingNamesS{i,1},' = ',num2str(wingPosVec(1,i))]);
                end
            elseif wingPosVec(1,1)==0 %Auto Set Wingpos
                wingPosVec=1:geo.nwing;                       
            else
                if size(wingPosVec,2)~=size(wingNamesS,1)
                    error('wingPosVec size is unequal to number of wings')
                end
            end
        else
            wingPosVec=1;
        end
    else
        for compNum=1:size(CPACSgeo.wings.component)     
            area=[];
            for n=1:size(CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys)-1            
                chordVec1=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n,1}*[1;0;0];
                chordVec2=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n+1,1}*[1;0;0];
                chordLenth1=sqrt(chordVec1(1,1)^2+chordVec1(2,1)^2+chordVec1(3,1)^2);
                chordLenth2=sqrt(chordVec2(1,1)^2+chordVec2(2,1)^2+chordVec2(3,1)^2);
                spVec=CPACSgeo.wings.component{compNum,1}.sectionDef.point{n+1,1}-CPACSgeo.wings.component{compNum,1}.sectionDef.point{n,1};
                loacalSpan=sqrt(spVec(2,1)^2+spVec(3,1)^2);
                area(n,1)=loacalSpan*(chordLenth1+chordLenth2)/2;
            end
            if CPACSgeo.wings.component{compNum,1}.symmetry
                compArea(compNum,1)=sum(area)*2;
            else
                compArea(compNum,1)=sum(area);
            end
        end
        [val,pos]=sort(-compArea);
        wingPosVec=pos';
    end
        
    
    %wing names
    geo.wingNames={wingNamesS{wingPosVec,1}}';

    %number of partitions on each wing (1d array)    ? 3 oder 4
    count=0;
    for i=wingPosVec
        count=1+count;
        geo.nelem(1,count)=size(CPACSgeo.wings.component{i,1}.sectionDef.sectionUID,1)-1;       
    end
    
    %%%%%%%%%%%%%%%%%    
    %%% Surfaces  %%%
    %%%%%%%%%%%%%%%%% 
            
    % Check Symetry 
    count=0;
    for i=wingPosVec 
        count=1+count;
        geo.symetric(1,count)=CPACSgeo.wings.component{i,1}.symmetry;
    end
        
    %Partition starting coordinate (2d array)
    count=0;     
    for i=wingPosVec         
        count=1+count;
        geo.startx(1,count)=CPACSgeo.wings.component{i,1}.sectionDef.point{1,1}(1,1);
        geo.starty(1,count)=CPACSgeo.wings.component{i,1}.sectionDef.point{1,1}(2,1);
        geo.startz(1,count)=CPACSgeo.wings.component{i,1}.sectionDef.point{1,1}(3,1);
    end

    %Chord (2d array) C1  
    count=0;     
    for i=wingPosVec         
        count=1+count; 
        for ii=1:geo.nelem(1,count)+1
            xAxe=[1;0;0];
            coorsSys=CPACSgeo.wings.component{i,1}.sectionDef.coorsSys{ii,1};
            vec=coorsSys*xAxe;
            % Length of projectet Vector on x-z-Area
            geo.c(count,ii)=sqrt(vec(1,1)^2+vec(3,1)^2); 
        end
    end
    
    %span(distance root->tip chord) (2d array)   
    count=0;     
    for i=wingPosVec         
        count=1+count; 
        for ii=1:geo.nelem(1,count)
            vec=CPACSgeo.wings.component{i,1}.sectionDef.point{ii+1,1}(:,1)-CPACSgeo.wings.component{i,1}.sectionDef.point{ii,1}(:,1);  
            % Length of projectet Vector on y-z-Area
            geo.b(count,ii)=sqrt(vec(3,1)^2+vec(2,1)^2)*sign(vec(2,1));   % defined alawys posetive   
           
        end
    end
    bSign=sign(geo.b);
    geo.b=abs(geo.b);
    
    %Dihedral (2d array) V-Stellung
    count=0;     
    for i=wingPosVec         
        count=1+count; 
        for ii=1:geo.nelem(1,count)    
            vec=CPACSgeo.wings.component{i,1}.sectionDef.point{ii+1,1}(:,1)-CPACSgeo.wings.component{i,1}.sectionDef.point{ii,1}(:,1);
            % Angle of projectet Vector on y-z-Area (angle between Vector
            % and y-axe)
            dh=atan(vec(3)/vec(2)); 
            if bSign(count,ii)==-1
                dh=pi-dh*bSign(count,ii);
            end            
            if isnan(dh)
              dh=0;
            end
            geo.dihed(count,ii)=dh;
        end
    end     

    %Taper ratio (2d array)
    count=0;     
    for i=wingPosVec         
        count=1+count; 
        for ii=1:geo.nelem(1,count)
            c1=geo.c(count,ii);
            c2=geo.c(count,ii+1);
            geo.T(count,ii)=c2/c1;                             
        end
    end

    %Sweep (2d array)
    count=0;     
    for i=wingPosVec         
        count=1+count; 
        for ii=1:geo.nelem(1,count)
            vec=CPACSgeo.wings.component{i,1}.sectionDef.point{ii+1,1}(:,1)-CPACSgeo.wings.component{i,1}.sectionDef.point{ii,1}(:,1);
            % Angle of projectet Vector on x-y-Area (angle between Vector
            % and y-axe)
            x1=CPACSgeo.wings.component{i,1}.sectionDef.point{ii,1}(1,1);
            x2=CPACSgeo.wings.component{i,1}.sectionDef.point{ii+1,1}(1,1);
            c1=geo.c(count,ii);
            c2=geo.c(count,ii+1);

            geo.SWle(count,ii)=atan((x2-x1)/geo.b(count,ii));
            geo.SW25(count,ii)=atan(((x2+c2/4)-(x1+c1/4))/geo.b(count,ii));          
            geo.SWte(count,ii)=atan(((x2+c2)-(x1+c1))/geo.b(count,ii)); 
        end
    end
    geo.SW=geo.SW25;   

    %partition twist (3d array)<1 inboard, 2 outboard>  
    count=0;     
    for i=wingPosVec         
        count=1+count; 
        for ii=1:geo.nelem(1,count)  
            % Angle of projectet Vector on x-z-Area (angle between Vector
            % and x-axe)
            xAxe=[1;0;0];
            coorsSys=CPACSgeo.wings.component{i,1}.sectionDef.coorsSys{ii,1};
            %vec=coorsSys*xAxe;
            vec=(xAxe'*coorsSys)';
            tw=abs(atan(vec(3)/vec(1)));
            geo.TW(count,ii,1)=tw; %changed (2012 10 19)      
             
            coorsSys=CPACSgeo.wings.component{i,1}.sectionDef.coorsSys{ii+1,1};
            vec=(xAxe'*coorsSys)';
            tw=abs(atan(vec(3)/vec(1)));
            geo.TW(count,ii,2)=tw;%changed (2012 10 19)
            
            % ToDo: Der errechnete Twist ist noch der um die leading edge.
            % In Tornado wird jedoch um die 25% vertwistet, dies ist hier
            % noch unberücksicht
            
            if bSign(count,ii)==-1
                geo.TW(count,ii,1)=-geo.TW(count,ii,1);
                geo.TW(count,ii,2)=-geo.TW(count,ii,2);
            end  
        end
    end

    %Partition airfoils (3d array) %1 inboard, 2 outboard
    count=0;
    for i=wingPosVec
        count=1+count;
        for ii=1:geo.nelem(1,count)
            % untransfored Airfoil
            geo.foil(count,ii,1)={[CPACSgeo.wings.component{i,1}.sectionDef.relAirfoil{ii,2},'.DAT']};      %1...(n-1)section
            geo.foil(count,ii,2)={[CPACSgeo.wings.component{i,1}.sectionDef.relAirfoil{ii+1,2},'.DAT']};    %n+1...n section
            
            foil1 = CPACSgeo.wings.component{i,1}.sectionDef.relAirfoil{ii,1};    foil1(:,2) = [];    
            foil2 = CPACSgeo.wings.component{i,1}.sectionDef.relAirfoil{ii+1,1};  foil2(:,2) = []; 
            
            [C_foil1,I_foil1] = min(foil1(:,1));      foil1_up = flipud(foil1(1:I_foil1,:));  foil1_low = foil1(I_foil1:end,:);
            [C_foil2,I_foil2] = min(foil2(:,1));      foil2_up = flipud(foil2(1:I_foil2,:));  foil2_low = foil2(I_foil2:end,:);
            
            numPoints_foil1_up = length(foil1_up);     numPoints_foil1_low = length(foil1_low); 
            numPoints_foil2_up = length(foil2_up);     numPoints_foil2_low = length(foil2_low); 
            %---------write the airfoil into a Tornado foil file-----------
            %----------*****************-----------***************---------
            hline=sprintf('%%Copied Airfoil from CPACS for Tornado\n');
            upsurf = sprintf('%%UPPER SURFACE\n');
            losurf = sprintf('%%LOWER SURFACE\n');
            
            file_tor = geo.foil{count,ii,1}; 
            fid = fopen(file_tor,'w');
            fprintf(fid, '%s', hline);
            fprintf(fid, '%d   %d\n',numPoints_foil1_up, numPoints_foil1_low);
            fprintf(fid, '%s', upsurf);
            
            for j=1:numPoints_foil1_up
                fprintf(fid,'%f   %f\n', foil1_up(j,:));
            end
            fprintf(fid, '%s', losurf);
            for j=1:numPoints_foil1_low
                fprintf(fid,'%f   %f\n',foil1_low(j,:));
            end
            fclose(fid); 
            copyfile(file_tor, '..\T135_export\aircraft\airfoil')
            
            %---------*****************-----------***************---------
            %-------------------------------------------------------------
            file_tor2 = geo.foil{count,ii,2}; 
            fid2 = fopen(file_tor2,'w');
            fprintf(fid2, '%s', hline);
            fprintf(fid2, '%d   %d\n', numPoints_foil2_up, numPoints_foil2_low);
            fprintf(fid2, '%s', upsurf);
            
            for j=1:numPoints_foil2_up
                fprintf(fid,'%f   %f\n', foil2_up(j,:));
            end
            fprintf(fid, '%s', losurf);
            for j=1:numPoints_foil2_low
                fprintf(fid,'%f   %f\n',foil2_low(j,:));
            end
            copyfile(file_tor2, '..\T135_export\aircraft\airfoil')
        end
    end


    %%%%%%%%%%%%%%%%%%%%
    %%% Wing Lattice %%%
    %%%%%%%%%%%%%%%%%%%%

    %number of panels in span (2d array) 
    warning('Vortex lattice simplification: constant factors, no intelligenc')
    ny=1; %number of panals spanwise
    count=0;     
    for i=wingPosVec         
        count=1+count;
        for ii=1:geo.nelem(1,count)
            geo.ny(count,ii)=round(geo.b(count,ii)*ny);     
            if round(geo.b(count,ii)*ny)==0;
                geo.ny(count,ii)=2; 
            end
        end
    end

    %number of panels on chord (2d array)
    warning('Vortex lattice simplification: constant factors, no intelligenc')
    count=0;     
    for i=wingPosVec         
        count=1+count;
        for ii=1:geo.nelem(1,count)
            geo.nx(count,ii)=5;         
        end
    end

    %%%%%%%%%%%%%%%
    %%% Control %%%
    %%%%%%%%%%%%%%%   
    
    for wingNum=wingPosVec
        % flap space def  
        for ii=1:geo.nelem(1,wingNum)
            geo.flapped(wingNum,ii)=0;
            geo.fsym(wingNum,ii)=1; 
            geo.fnx(wingNum,ii)=0;
            geo.fc(wingNum,ii)=0;
        end
    end
    
    %Flap deflection vector
    geo.flap_vector=zeros(geo.nwing,max(geo.nelem));

    count=0;
    countFlap=0;
    for wingNum=wingPosVec
        count=1+count;    
        
        if ~isfield(CPACSgeo.wings.component{wingNum,1},'controlSurfaces')
            break
        end

        %%%%%%%%%%%%%%%%%%%%%%
        % leadingEdgeDevices %                                          
        %%%%%%%%%%%%%%%%%%%%%%
        
        % # Not Implemented in Tornado
        %numOfLED=size(controlSurfaces{1,1}.leadingEdgeDevices{1,1}.leadingEdgeDevice,2);
        %controlSurfaces{1,1}.leadingEdgeDevices;


        %%%%%%%%%%%%
        % spoilers %                                                    
        %%%%%%%%%%%%
        
        % # Not Implemented in Tornado
        %numOfSpD=size(controlSurfaces{1,1}.spoilers{1,1}.spoiler,2);
        %controlSurfaces{1,1}.spoilers;
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % trailingEdgeDevices %
        %%%%%%%%%%%%%%%%%%%%%%%
        
        % TEDelt [control1 control2 ...]
        % Preperation of CS data 
        
        TEDyAbs=[];
        TEDchord=[];
        meanTEDksi=[];
        meanTEDeta=[];
        TEDetaLE=[];
        TEDetaTE=[];
        TEDname={};
        TEDuid={};
        numOfTED = size(CPACSgeo.wings.component{wingNum,1}.controlSurfaces.definition.trailingEdgeDevices,1);
        for flNum=1:numOfTED   

            TED=CPACSgeo.wings.component{wingNum,1}.controlSurfaces.definition.trailingEdgeDevices{flNum,1};

            % For the case that only TEDetaLE has not the size like TEDetaTE or
            % in the other direction
            TEDdef=[0,0];
            if isfield(TED,'etaLE')
                TEDetaLE=TED.etaLE;
                TEDdef(1,1)=1;
            end
            if isfield(TED,'etaTE')
                TEDetaTE=TED.etaTE;
                TEDdef(1,2)=1;
            end
            
            % Using the mean values for needed simplification in Tornado
            if TEDdef(1,1)==1 && TEDdef(1,2)==1
                meanTEDeta(1,flNum)=mean([TEDetaLE(1),TEDetaTE(1)]);
                meanTEDeta(2,flNum)=mean([TEDetaLE(2),TEDetaTE(2)]);             
            elseif TEDdef(1,1)==1 && TEDdef(1,2)==0
                meanTEDeta(:,flNum)=[TEDetaLE]';
            elseif TEDdef(1,1)==0 && TEDdef(1,2)==1
                meanTEDeta(:,flNum)=[TEDetaTE]';
            else
                Warning('There is no definbiton of a flap')
            end                  

            TEDksiLE=TED.ksiLE;
            meanTEDksi(1,flNum)=mean(TED.ksiLE);

            % Writing the absolute values
            TEDyAbs(1,flNum)=meanTEDeta(1,flNum)*sum(geo.b(count,:)); %inner boarde trailing edge device position
            TEDyAbs(2,flNum)=meanTEDeta(2,flNum)*sum(geo.b(count,:)); %outer boader trailing edge device position
            TEDchord=1-meanTEDksi; % chord of the trailing edge device
            TEDname{1,flNum}=TED.TEDname;
            TEDuid{1,flNum}=TED.TEDuid;
        end

        % Incuding of new sections where the control surfaces are shoud be
        if ~isempty(TEDyAbs)
            
            y_new=[];
            y_new=[TEDyAbs(1,:),TEDyAbs(2,:)];
            y_new=sort(y_new);
            y_new=unique(y_new);
            wingNums=[];
            wingNums(1,1:size(y_new,2))=wingNum;            
            % Minimum section span [m]: there are only defined new section
            % if thay are not so close to an consisting section (thats is
            % neded for a homogen pannel distribution)
            minSecSpan=0.2; 
            % Adding of sections
            ac.wings=geo;
            [ac]=addWingSec(ac,wingNums,y_new,minSecSpan);
            geo=ac.wings;

            % Reset control 
            for ii=1:geo.nelem(1,count)
                geo.flapped(count,ii)=0;
                geo.fsym(count,ii)=0; 
                geo.fnx(count,ii)=0;
                geo.fc(count,ii)=0;
                geo.flapID(count,ii)=0;
            end

            % Including of the control definition in the new sections
            % New Span vector 
            b_abs(count,1)=0;
            %for i=1:length(geo.nelem)    
                % Absolute Span
            for ii=1:geo.nelem(1,count)
                b_abs(count,ii+1)=sum(geo.b(count,1:ii));
            end
            %end
            % Serching for the position again because of minSecSpan 
            n=0;
            k=0;
            pos1=[];
            pos2=[];
            for i=1:geo.nelem(1,count)+1
                for ii=1:size(TEDyAbs,2)
                    delt1=abs(TEDyAbs(1,ii)-b_abs(count,i));
                    delt2=abs(TEDyAbs(2,ii)-b_abs(count,i));
                    if delt1<=minSecSpan
                       n=n+1;
                       pos1(1,n)=i; 
                    end 
                    if delt2<minSecSpan
                       k=k+1;
                       pos2(1,k)=i; 
                    end                         
                end         
            end          
            % Define the Control Surfaces
            pos12=[pos1;pos2];
            for i=1:size(pos1,2)
                countFlap=countFlap+1;
                geo.flapID(count,min(pos12(:,i)):max(pos12(:,i))-1)=countFlap; %Define a flapID
                geo.flapped(count,min(pos12(:,i)):max(pos12(:,i))-1)=1;                
                geo.fc(count,min(pos12(:,i)):max(pos12(:,i))-1)=TEDchord(1,i);  
                geo.fnx(count,min(pos12(:,i)):max(pos12(:,i))-1)=2;  %#

                % Chose the type of deflection
                if ~isempty(findstr(TEDname{1,i}, 'Aileron'))
                    sym=0;                                                 % UnSymmetrical Flapdeflection
                else
                    sym=1;                                                 % Symmetrical Flapdeflection
                end
                geo.fsym(count,min(pos12(:,i)):max(pos12(:,i))-1)=sym;      
            end 
        end         
    end
    
    % Save 
    aircraft.wings=geo; 
    
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - airfoils -                               %%
function [aircraft]=airfoils(CPACSgeo,aircraft)

    % Profile Names
    for i=1:size(CPACSgeo.wings.airfoil,1)
        foilNames{i,1}=CPACSgeo.wings.airfoil{i,2};
    end
    
    n=0;
    for i=1:size(aircraft.wings.foil,1)             %wing
        for ii=1:size(aircraft.wings.foil,2)+1      %section 
           if ii>=2
               foilname=aircraft.wings.foil(i,ii-1,2);
           else
               foilname=aircraft.wings.foil(i,ii);
           end
           if ~isempty(foilname{1,1})
           %%%%%%%%%%%%%%%%%%%%     
                for k=1:size(foilNames,1)          
                   if strcmp(CPACSgeo.wings.airfoil{k,2},foilname{1,1}(1,1:end-4))
                       n=n+1;
                       aircraft.airfoils(n,:)={CPACSgeo.wings.airfoil{k,2},CPACSgeo.wings.airfoil{k,1}};
                       break
                   end
                end
           %%%%%%%%%%%%%%%%%%%%  
           end
        end
    end
      
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - References -                             %%
function [aircraft]=references(CPACSgeo,aircraft)

	aircraft.ref = CPACSgeo.ref;
    [aircraft]=refGen(aircraft); 
    
    % Set an Refpoint on 25% meanChord
    aircraft.wings.ref_point(1,1) = aircraft.ref.mac_pos(1,1)+aircraft.ref.C_mac(1,1)/4;
    aircraft.wings.ref_point(1,2) = 0;
    aircraft.wings.ref_point(1,3) = 0;    
    aircraft.wings.CG=aircraft.wings.ref_point;
    
    % Reference Point From CPACS
    aircraft.wings.ref_point_CPACS = CPACSgeo.ref.point;

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - Fuselage -                               %%
% 
function [aircraft]=fuselage(CPACSgeo,aircraft)

	aircraft.fuselage.d = CPACSgeo.fuselages.component{1,1}.diameter;
    aircraft.fuselage.l = CPACSgeo.fuselages.component{1,1}.length;
    aircraft.fuselage.frames = CPACSgeo.fuselages.component{1,1}.sectionDef.airfoil;

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - Engine -                                 %%
% 
function [aircraft]=engine(CPACSgeo,aircraft)

    if ~isempty(CPACSgeo.engine)
        try aircraft.engines.name = CPACSgeo.engine.name;end
        try aircraft.engines.pos  = CPACSgeo.engine.pos; end
        try aircraft.engines.sym  = CPACSgeo.engine.sym; end
        try aircraft.engines.T_0  = CPACSgeo.engine.T_0; end
    else
        aircraft.engines={};
    end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - Landingear -                             %%
% 
function [aircraft]=lg(CPACSgeo,aircraft)

	aircraft.lg = CPACSgeo.lg;

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - Weight -                                 %%
% 
function [aircraft]=weight(CPACSgeo,aircraft)

	aircraft.weight = CPACSgeo.weight;

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - Center of Gravity -                      %%
% 
function [aircraft]=CG(CPACSgeo,aircraft)

    if isfield(CPACSgeo,'CG')
        aircraft.CG = CPACSgeo.CG;
    end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                            - Inertial -                               %%
% Inertial
function [aircraft]=inertial(CPACSgeo,aircraft)

    if isfield(CPACSgeo,'J')
        aircraft.J = CPACSgeo.J;
    end

end%function 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - Analysis -                              %%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - Load Case -                             %%
function [analysis]=loadCase(CPACSgeo,analysis)

    if isfield(CPACSgeo,'loadCase')
        analysis.loadCase=CPACSgeo.loadCase;
    else
        analysis.loadCase={};
    end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - State -                                 %%
function [analysis]=state(CPACSgeo,analysis)    
    
    analysis=CPACSgeo.analysis;
   
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                             - results -                               %%
function [analysis]=results(CPACSgeo,analysis)
    
    analysis.results=CPACSgeo.results;     
   
end%function
%%                                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
