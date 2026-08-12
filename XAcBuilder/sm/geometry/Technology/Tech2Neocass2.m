%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tech2Neocass
% Convert TechGeoModel in NEOCASS.mat, then in NEOCASS.xml 
%
%   INPUT 
%       TechGeoModel.mat
%
%   OUTPUT 
%       NOECASS.mat
%       NEOCASS.xml
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     10.10.13     1.3    F.Dinardo        Creation
%     18.11.13     1.4    F.Dinardo        Modification to savePath
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Tech2Neocass2(ac)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%D150_TechGeoModel
% close all, clear all, clc
% Path1='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\';
% load([Path1,'D150_TechGeoModel.mat']);
% figure(1),hold on,axis equal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % [FileTech,PathTech] = uigetfile('-mat','Get TechGeoModel.mat'); 
% % load([PathTech,FileTech]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global TechGeoModel handles

rad=pi/180;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fuselage
% function NEOCASSfus(iFus)
for k=1
%         global ac NEOCASS
%5.NEOCASS covertion
            fusID=1;
            %symmetry=  TechGeoModel.iWing{wingID}.symmetry;
            %Area     = TechGeoModel.iWing{wingID}.Reference.Area;
            %semiSpan = TechGeoModel.iWing{wingID}.Reference.Span;
            prof_fus = TechGeoModel.iFus{fusID}.Geometry.prof_fus;      
            lenght   = TechGeoModel.iFus{fusID}.Geometry.lenght;
            sweep    = TechGeoModel.iFus{fusID}.Geometry.sweep;
            dihedral = TechGeoModel.iFus{fusID}.Geometry.dihedral;
            %span     = TechGeoModel.iWing{wingID}.Geometry.span;
            
            for i=1:length(prof_fus)
                [~, ival]=max(prof_fus(i).pnt_pos(:,3));   upperFus(i,:)=prof_fus(i).pnt_pos(ival,:);
                [~, ival]=min(prof_fus(i).pnt_pos(:,3));   lowerFus(i,:)=prof_fus(i).pnt_pos(ival,:);
                [~, ival]=max(prof_fus(i).pnt_pos(:,2));   side_Fus(i,:)=prof_fus(i).pnt_pos(ival,:); 
            end
        % plot verify %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            plot3(upperFus(:,1), upperFus(:,2),upperFus(:,3))
            plot3(lowerFus(:,1), lowerFus(:,2),lowerFus(:,3))
            plot3(side_Fus(:,1), side_Fus(:,2),side_Fus(:,3))
            plot3(side_Fus(:,1),-side_Fus(:,2),side_Fus(:,3))
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            iNose  =0;
            iCentre=1;
            iTail  =0;
            for i=1:length(prof_fus)              
                Dv(i)=upperFus(i,3)-lowerFus(i,3);
                Dh(i)=2*side_Fus(i,2);
                Dm(i)=(Dv(i)+Dh(i))/2;
                if i>1
                    dDm(i-1)=(Dm(i)-Dm(i-1))/(upperFus(i,1)-upperFus(i-1,1));
                    if i>2
                        if iNose==0   && iCentre==1 && dDm(i-1)<=5e-4                             
                            iNose=i-1; iCentre=0;
                        elseif iNose~=0 && iCentre==0 && dDm(i-1)<0 
                            iCentre=i;
                        end
                    end
                end
                
            end
            iTail=length(prof_fus);
    % Model
%             omega_nose                           (15.0)      [deg] cockpit angle x-z plane                 	fig A2 
%             phi_nose                             (10.439)    [deg] nose mean line angle x-z plane          	fig A2 
%             Forefuse_X_sect_vertical_diameter    (3.95)      [m]   vertical diameter                       	fig A1
%             Forefuse_X_sect_horizontal_diameter  (3.95)      [m]   horizontal diameter                     	fig A1
%             epsilon_nose                         (1.13389)   [0--]  nose length to diameter ratio           	fig A2
%             Forefuse_Xs_distortion_coefficient   (0.5)	   [m]   distortion coefficient                  	fig A1
%             Nose_length                          (defac.Fuselage.Forefuse_X_sect_vertical_diameter*defac.Fuselage.epsilon_nose) 
%             fraction_fore                        (0.5)       [0-1] forward length divided by centre length   fig A3
%             shift_fore                           (0.0)       [m]   vertical shift of the forward centre fus fig A3 
%             omega_tail                           (10.0)      [deg] tail angle x-z plane                    fig A2
%             phi_tail                             (6.311)     [deg] tail mean line angle x-z plane          fig A2
%             Aftfuse_X_sect_vertical_diameter     (3.95)      [m]   vertical diameter                       fig A1
%             Aftfuse_X_sect_horizontal_diameter   (3.95)      [m]   horizontal diameter                     fig A1
%             Aftfuse_Xs_distortion_coefficient    (0.5)       [m]   distortion coefficient                  fig A1
%             epsilon_tail                         (3.0356)    [0--] tail length to diameter ratio           fig A2
%             Tail_length                          (defac.Fuselage.Aftfuse_X_sect_vertical_diameter*defac.Fuselage.epsilon_tail)
%             Total_fuselage_length                (44.51)     [m]   total fuselage length, in metres 
            pOmegaNose =polyfit(upperFus(1:iNose,1),upperFus(1:iNose,3),1);
            ppOmegaNose=polyval(pOmegaNose,[0 10]);
              plot3([0 10],[0 0],ppOmegaNose,'r')
            NEOCASS.Fuselage.omega_nose                                   =atan(pOmegaNose(1))/rad;

            pPhiNose =polyfit(side_Fus(1:iNose,1),side_Fus(1:iNose,3),1);
            ppPhiNose=polyval(pPhiNose,[0 10]);
            plot3([0 10],[0 0],ppPhiNose,'r')
            NEOCASS.Fuselage.present                                      =1;
            NEOCASS.Fuselage.phi_nose                                     =atan(pPhiNose(1))/rad;

            NEOCASS.Fuselage.Forefuse_X_sect_vertical_diameter            =upperFus(iNose,3)-lowerFus(iNose,3);            
            NEOCASS.Fuselage.Forefuse_X_sect_horizontal_diameter          =2*abs(side_Fus(iNose,2));            
            NEOCASS.Fuselage.epsilon_nose                                 =upperFus(iNose,1)/NEOCASS.Fuselage.Forefuse_X_sect_vertical_diameter;               
            NEOCASS.Fuselage.Forefuse_Xs_distortion_coefficient=0.5;             
            NEOCASS.Fuselage.Nose_length                                  =NEOCASS.Fuselage.Forefuse_X_sect_vertical_diameter * NEOCASS.Fuselage.epsilon_nose;             
            NEOCASS.Fuselage.fraction_fore                                =0.5;                                                                                                                                                                                                                                                      
            NEOCASS.Fuselage.shift_fore                                   =0.0;

            pOmegaTail =polyfit(lowerFus(iCentre:end,1),lowerFus(iCentre:end,3),1);
            ppOmegaTail =polyval(pOmegaTail,lowerFus(iCentre:end,1));
            plot3(lowerFus(iCentre:end,1),zeros(length(lowerFus(iCentre:end,1)),1),ppOmegaTail,'r')
            NEOCASS.Fuselage.omega_tail                                   =atan(pOmegaTail(1))/rad;

            pPhiTail    =polyfit(side_Fus(iCentre:end,1),side_Fus(iCentre:end,3),1);
            ppPhiTail   =polyval(pPhiTail,side_Fus(iCentre:end,1));
            plot3(side_Fus(iCentre:end,1),zeros(length(side_Fus(iCentre:end,1)),1),ppPhiTail,'r')
            NEOCASS.Fuselage.phi_tail                                     =atan(pPhiTail(1))/rad;                                                                                                                                                                                                                                            

            NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter             =upperFus(iCentre,3)-lowerFus(iCentre,3);             
            NEOCASS.Fuselage.Aftfuse_X_sect_horizontal_diameter           =2*abs(side_Fus(iCentre,2));              
            NEOCASS.Fuselage.Aftfuse_Xs_distortion_coefficient            =0.5;            
            NEOCASS.Fuselage.epsilon_tail                                 =(upperFus(end,1)-upperFus(iCentre,1))/NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter;               
            NEOCASS.Fuselage.Tail_length                                  =NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter*NEOCASS.Fuselage.epsilon_tail;               
            NEOCASS.Fuselage.Total_fuselage_length                        =upperFus(end,1)-upperFus(1,1);
            
            NEOCASS.Fuselage.a0_fore                                      =NEOCASS.Fuselage.Forefuse_X_sect_vertical_diameter/2;
            NEOCASS.Fuselage.a1_fore                                      =0;
            NEOCASS.Fuselage.b1_fore                                      =0;
            
            NEOCASS.Fuselage.a0_aft                                       =NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter/2;
            NEOCASS.Fuselage.a1_aft                                       =0;
            NEOCASS.Fuselage.b1_aft                                       =0;
            
            NEOCASS.Fuselage.x                                            =0;
            NEOCASS.Fuselage.y                                            =0;
            NEOCASS.Fuselage.z                                            =0;     
    % Geometry     
        % beam_model
            % nfuse                          (10)    [] n° beam elements 
                NEOCASS.user_input.geometry.beam_model.nfuse=round(2*NEOCASS.Fuselage.Total_fuselage_length);
        % aero_panel
        % spar_location
    % Material_property      
        % fus                                                                     
            % kcon            (4)                    Flag     structural concept    
            % fts             (403222950)            [Pa]     tensile strength      
            % fcs             (372205800)            [Pa]     shear strength        
            % es              (73751890000)          [Pa]     Young's moduls shell  
            % ef              (73751890000)          [Pa]     Young's moduls frame  
            % ds              (2795.7174)            [kg/m^3] material density shell
            % df              (2795.7174)            [kg/m^3] material density frame
                NEOCASS.user_input.material_property.fus.kcon=4         ;    
                NEOCASS.user_input.material_property.fus.fts =403222950  ;		
                NEOCASS.user_input.material_property.fus.fcs =372205800  ;		
                NEOCASS.user_input.material_property.fus.es  =73751890000;		
                NEOCASS.user_input.material_property.fus.ef  =73751890000;   
                NEOCASS.user_input.material_property.fus.ds  =2795.7174 ;		
                NEOCASS.user_input.material_property.fus.df  =2795.7174  ; 
% global NEOCASS
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Aerofoils
for z=1:length(TechGeoModel.iWing)
for aaaa=1    
    disp(['WingID ' num2str(z)] )
    %iWing=TechGeoModel.iWing;
        wingID   = z;
        symmetry = TechGeoModel.iWing{wingID}.symmetry;
        Area     = TechGeoModel.iWing{wingID}.Reference.Area;
        semiSpan = TechGeoModel.iWing{wingID}.Reference.Span;
        prof_wing= TechGeoModel.iWing{wingID}.Geometry.prof_wing;
        sectID   = TechGeoModel.iWing{wingID}.Geometry.sectID;
        lenght   = TechGeoModel.iWing{wingID}.Geometry.lenght;
        sweep    = TechGeoModel.iWing{wingID}.Geometry.sweep;
        dihedral = TechGeoModel.iWing{wingID}.Geometry.dihedral;
        span     = TechGeoModel.iWing{wingID}.Geometry.span;
        try             
            etaFL_A  = TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_A;
            xsiFL_A  = TechGeoModel.iWing{wingID}.Geometry.TED.xsiLE_A;        
            etaFL_B  = TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_B;
            xsiFL_B  = TechGeoModel.iWing{wingID}.Geometry.TED.etaLE_B;
            
        catch
            etaFL_A  = TechGeoModel.iWing{wingID}.Geometry.etaSect(1:end-1);
            xsiFL_A  = .2*ones(1,length(TechGeoModel.iWing{wingID}.Geometry.etaSect)-1);        
            etaFL_B  = TechGeoModel.iWing{wingID}.Geometry.etaSect(2:end);
            xsiFL_B  = .2*ones(1,length(TechGeoModel.iWing{wingID}.Geometry.etaSect)-1);
            
            NSEC=length(TechGeoModel.iWing{wingID}.Geometry.etaSect);
            if wingID==1 && NSEC<4
                %if NSEC==3
                    etaFL_A(end+1)=0.7, etaFL_A=sort(etaFL_A)
                    xsiFL_A(end+1)=0.2; xsiFL_A=sort(xsiFL_A);
                    etaFL_B(end+1)=0.7, etaFL_B=sort(etaFL_B)
                    xsiFL_B(end+1)=0.2; xsiFL_B=sort(xsiFL_B); 
%                 elseif NSEC==2
%                     etaFL_A(end+1:end+2)=[0.3 0.7]; etaFL_A=sort(etaFL_A);
%                     xsiFL_A(end+1:end+2)=[0.2 0.2]; xsiFL_A=sort(xsiFL_A);
%                     etaFL_B(end+1:end+2)=[0.7 1.0]; etaFL_B=sort(etaFL_B);
%                     xsiFL_B(end+1:end+2)=[0.2 0.2]; xsiFL_B=sort(xsiFL_B);
%                 end
            end            
        end
        yFL_A    = etaFL_A*semiSpan;
        yFL_B    = etaFL_B*semiSpan;
            
        
        board_node    =[TechGeoModel.iWing{wingID}.beamModel.nodeSect];
        board_nxPan   =[TechGeoModel.iWing{wingID}.aeroPanel.nx];                       
        board_nxTEDPan=[TechGeoModel.iWing{wingID}.aeroPanel.nxTED];
        board_nyPan   =[TechGeoModel.iWing{wingID}.aeroPanel.ny];
        
    %verifico la direzione di estensione
        [~, ydir]=max(prof_wing(end).pnt_pos(1,:)'-prof_wing(1).pnt_pos(1,:)');
        if ydir==2
            zdir=3;
        elseif ydir==3
            zdir=2;
        end
            
    
    %Inserisco le sezioni relative alle superfici di comando
    % se queste nn sono già presenti
        Npos  =length(sectID(:,1));
        Nsec=length(prof_wing);
        if wingID==1
        j=1;
        ysectA=mean(prof_wing(j).pnt_pos(:,ydir)); 
        for i=1:length(yFL_B)
            if yFL_B(i)>( NEOCASS.Fuselage.Forefuse_X_sect_horizontal_diameter+NEOCASS.Fuselage.Aftfuse_X_sect_horizontal_diameter)/4                                                  
                while ysectA<yFL_B(i) && j<=Npos-1
                    j=j+1;
                    ysectA=mean(prof_wing(sectID(j,1)).pnt_pos(:,ydir));
                end
%                 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                 if j==1, j=2; end               
%                 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                ysectB=mean(prof_wing(sectID(j,2)).pnt_pos(:,ydir));
                if abs(yFL_B(i)-ysectB)>semiSpan*0.10 && abs(yFL_B(i)-ysectA)>semiSpan*0.10                        
                    disp(['Isert a section for Control surface: ' num2str(j)] )
                    y=yFL_B(i);                                                        
                    t=(y-ysectA)/(ysectB-ysectA);
                    prof_wing(Nsec+1).pnt_pos=profileInterpolation(prof_wing(sectID(j,1)).pnt_pos,prof_wing(sectID(j,2)).pnt_pos,t);
                    prof_wing(Nsec+1).iLE    =prof_wing(j).iLE;
                    prof_wing(Nsec+1).chord  =prof_wing(Nsec+1).pnt_pos(1,1)-prof_wing(Nsec+1).pnt_pos(prof_wing(1).iLE,1);
                    sectID_tmp=[sectID(j-1,2)          max(max(sectID))+1;...
                                max(max(sectID))+1   sectID(j,2)    ];
                    sectID=[sectID(1:j-1,:); sectID_tmp; sectID(j+1:end,:)];
                    if j==Npos
                        board_node    =[board_node(1:j-1)     round(board_node(j)*(y-ysectA)/(ysectB-ysectA))  round(board_node(j)*(ysectB-y)/(ysectB-ysectA))];
                        board_nxPan   =[board_nxPan(1:j-1)    board_nxPan(j)                                   board_nxPan(j)]; 
                        board_nxTEDPan=[board_nxTEDPan(1:j-1) board_nxTEDPan(j)                                board_nxTEDPan(j)];
                        board_nyPan   =[board_nyPan(1:j-1)    round(board_nyPan(j)*(y-ysectA)/(ysectB-ysectA)) round(board_nyPan(j)*(ysectB-y)/(ysectB-ysectA))];
%                     else    
                    end
                    Npos  =length(sectID(:,1));
                    Nsec=length(prof_wing);
                end
            end  
            
        end
        end
    %inserisco una sezione centrale se sono solo 2 (htail & vtail)
        if length(sectID(:,1))==1
            disp(['Isert a section for achieve min number of them: 3'])
            t=0.5;
            prof_wing(Nsec+1).pnt_pos=profileInterpolation(prof_wing(sectID(1,1)).pnt_pos,prof_wing(sectID(1,2)).pnt_pos,t);
            prof_wing(Nsec+1).iLE    =prof_wing(1).iLE;
            prof_wing(Nsec+1).chord  =prof_wing(Nsec+1).pnt_pos(1,1)-prof_wing(Nsec+1).pnt_pos(prof_wing(1).iLE,1);
            sectID_tmp=[sectID(1,1) Nsec+1     ;...
                        Nsec+1      sectID(1,2)];
            sectID=sectID_tmp;
            Npos  =length(sectID(:,1));
            
            board_node    =[round(board_node/2) round(board_node/2)];
            board_nxPan   =[board_nxPan  board_nxPan ]; 
            board_nxTEDPan=[board_nxTEDPan board_nxTEDPan];
            board_nyPan   =[round(board_nyPan/2) round(board_nyPan/2)];
        end    
    
            
    %Elimino la seconda sezione se questa sta all'interno della fusoliera
    %nel caso di Wing1
        if wingID==1
            disp('Erase wing section carrythru ')
            if mean(prof_wing(sectID(1,2)).pnt_pos(:,ydir))<( NEOCASS.Fuselage.Forefuse_X_sect_horizontal_diameter+NEOCASS.Fuselage.Aftfuse_X_sect_horizontal_diameter)/4;
                Nsec=length(prof_wing);
                y=0;
                t=(y-mean(prof_wing(sectID(2,1)).pnt_pos(:,ydir)))/(mean(prof_wing(sectID(2,2)).pnt_pos(:,ydir))-mean(prof_wing(sectID(2,1)).pnt_pos(:,ydir)));
                prof_wing(Nsec+1).pnt_pos=profileInterpolation(prof_wing(sectID(2,1)).pnt_pos,prof_wing(sectID(2,2)).pnt_pos,t);
                prof_wing(Nsec+1).iLE    =prof_wing(2).iLE;
                prof_wing(Nsec+1).chord  =prof_wing(Nsec+1).pnt_pos(1,1)-prof_wing(Nsec+1).pnt_pos(prof_wing(1).iLE,1);
                sectID=sectID(2:end,:);
                sectID(1,1)=Nsec+1;
                
                board_node    =[sum(board_node(1:2)) board_node(3:end)];
                board_nxPan   =[board_nxPan(2:end) ]; 
                board_nxTEDPan=[board_nxTEDPan(2:end)];
                board_nyPan   =[sum(board_nyPan(1:2)) board_nyPan(3:end)];
                
                Npos  =length(sectID(:,1));
            end
        
        end

    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %riduco in linea sectID -> sectIDL
    %NB: è ok se tutte le sezioni si corrono dietro
        clear  sect_tmp sectIDL xLE xTE vLE vTE cosLE cosTE isortLE isortTE sectID_Neocass area sweep sweep_25chord sweep_50chord taper imac
        j=1;    
        for i=1:Npos
            if i==1
                sectIDL( j )=sectID(1,1);
                sectIDL(j+1)=sectID(1,2);
                j=j+2;                   
            else
                if sectID(i,1)==sectID(i-1,2)
                    sectIDL( j )=sectID(i,2);
                    j=j+1;
                end
            end
        end  %,sectIDL
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
    %riduco il numero delle sezioni a...
        if wingID==1
            NSECT=4;
        elseif wingID==2
            NSECT=3;
        elseif z==3
            wingID=3;
        end
        
        % Npos  =length(TechGeoModel.iWing{wingID}.Geometry.sectID(:,1));     
        Npos =length(sectID);   
        for i=1:Npos   
            xLE(sectID(i,1),:)= prof_wing(sectID(i,1)).pnt_pos(prof_wing(sectID(i,1)).iLE,:);
            xTE(sectID(i,1),:)=(prof_wing(sectID(i,1)).pnt_pos( 1 ,:)+...
                                prof_wing(sectID(i,1)).pnt_pos(end,:))/2;

            xLE(sectID(i,2),:)= prof_wing(sectID(i,2)).pnt_pos(prof_wing(sectID(i,1)).iLE,:);
            xTE(sectID(i,2),:)=(prof_wing(sectID(i,2)).pnt_pos( 1 ,:)+...
                                prof_wing(sectID(i,2)).pnt_pos(end,:))/2;

            vLE(i,:)=(xLE(sectID(i,2),:)'-xLE(sectID(i,1),:)')';  vLE(i,:)=vLE(i,:)/norm(vLE(i,:));
            vTE(i,:)=(xTE(sectID(i,2),:)'-xTE(sectID(i,1),:)')';  vTE(i,:)=vTE(i,:)/norm(vTE(i,:));                               
        end
        for i=1:Npos+1
            if i==1 || i==Npos+1
                cosLE(i)=0;
                cosTE(i)=0;
            else                   
                cosLE(i)=vLE(i-1,:)*vLE(i,:)';
                cosTE(i)=vTE(i-1,:)*vTE(i,:)';
            end
        end
        [~,isortLE]=sort(cosLE);
        [~,isortTE]=sort(cosTE);
        k=1;h=1; 
        for i=1:NSECT
            if isortLE(h)==isortTE(k) 
                sect_tmp(i)=isortLE(h); 
                h=h+1; 
                k=k+1; 
            elseif isortLE(h)~=isortTE(k)
                if cosLE(isortLE(h))<cosTE(isortTE(k))
                    %1
                    sect_tmp(i)=isortLE(h);
                    h=h+1;
                else
                    %2
                    sect_tmp(i)=isortTE(k);
                    k=k+1;    
                end
            end
        end
        sect_tmp=sort(sect_tmp);
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        sect_tmp=sectIDL(sect_tmp);
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        for i=1:NSECT-1
            sectID_Neocass(i,1:2)=[sect_tmp(i) sect_tmp(i+1)];
        end                       
    % plot verifica %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:length(prof_wing)
            plot3(prof_wing(i).pnt_pos(:,1),prof_wing(i).pnt_pos(:,2),prof_wing(i).pnt_pos(:,3),'g','linewidth',2)
        end
        %Cpacs
%         for i=1:Npos
%             %chord plot
%             handles.NeocassPlot.CPACS()=plot3(  [xLE(sectID(i,1),1) xTE(sectID(i,1),1)],...
%                                         [xLE(sectID(i,1),2) xTE(sectID(i,1),2)],...
%                                         [xLE(sectID(i,1),3) xTE(sectID(i,1),3)]);
% 
%             handles.NeocassPlot=plot3(  [xLE(sectID(i,2),1) xTE(sectID(i,2),1)],...
%                                         [xLE(sectID(i,2),2) xTE(sectID(i,2),2)],...
%                                         [xLE(sectID(i,2),3) xTE(sectID(i,2),3)]); 
%             %Leading & Trailing edge 
%             handles.NeocassPlot=plot3(  [xLE(sectID(i,1),1) xLE(sectID(i,2),1)],...
%                                         [xLE(sectID(i,1),2) xLE(sectID(i,2),2)],...
%                                         [xLE(sectID(i,1),3) xLE(sectID(i,2),3)],'b','linewidth',1);
%             handles.NeocassPlot=plot3(  [xTE(sectID(i,1),1) xTE(sectID(i,2),1)],...
%                                         [xTE(sectID(i,1),2) xTE(sectID(i,2),2)],...
%                                         [xTE(sectID(i,1),3) xTE(sectID(i,2),3)],'b','linewidth',1);  
%         end 
        %_Neocass
        for i=1:NSECT-1
            %chord plot
            handles.NeocassPlot=plot3(  [xLE(sectID_Neocass(i,1),1) xTE(sectID_Neocass(i,1),1)],...
                                        [xLE(sectID_Neocass(i,1),2) xTE(sectID_Neocass(i,1),2)],...
                                        [xLE(sectID_Neocass(i,1),3) xTE(sectID_Neocass(i,1),3)]);

            handles.NeocassPlot=plot3(  [xLE(sectID_Neocass(i,2),1) xTE(sectID_Neocass(i,2),1)],...
                                        [xLE(sectID_Neocass(i,2),2) xTE(sectID_Neocass(i,2),2)],...
                                        [xLE(sectID_Neocass(i,2),3) xTE(sectID_Neocass(i,2),3)],'r','linewidth',2); 
            %Leading & Trailing edge 
            handles.NeocassPlot=plot3(  [xLE(sectID_Neocass(i,1),1) xLE(sectID_Neocass(i,2),1)],...
                                        [xLE(sectID_Neocass(i,1),2) xLE(sectID_Neocass(i,2),2)],...
                                        [xLE(sectID_Neocass(i,1),3) xLE(sectID_Neocass(i,2),3)],'r','linewidth',2);
            handles.NeocassPlot=plot3(  [xTE(sectID_Neocass(i,1),1) xTE(sectID_Neocass(i,2),1)],...
                                        [xTE(sectID_Neocass(i,1),2) xTE(sectID_Neocass(i,2),2)],...
                                        [xTE(sectID_Neocass(i,1),3) xTE(sectID_Neocass(i,2),3)],'r','linewidth',2);  
        end 
    % costruisco i vettori di dati x Neocass
        for i=1:NSECT
            chord(i)=prof_wing(sect_tmp(i)).chord;
            profileName{i}=prof_wing(sect_tmp(i)).sectName;
            incidence(i)=-atan((xTE(sect_tmp(i),3)-xLE(sect_tmp(i),3))/...
                               (xTE(sect_tmp(i),1)-xLE(sect_tmp(i),1)))/rad;                
        end
        clear span
        for i=1:NSECT-1
            sweep(i)         = atan((xLE(sectID_Neocass(i,2),1)-xLE(sectID_Neocass(i,1),1))/(xLE(sectID_Neocass(i,2),ydir)-xLE(sectID_Neocass(i,1),ydir)))/rad;                

                x2= xLE(sectID_Neocass(i,2),1)+0.25*(xTE(sectID_Neocass(i,2),1)-xLE(sectID_Neocass(i,2),1));
                x1= xLE(sectID_Neocass(i,1),1)+0.25*(xTE(sectID_Neocass(i,1),1)-xLE(sectID_Neocass(i,1),1));
                dx= x2-x1;
                y2= xLE(sectID_Neocass(i,2),ydir);
                y1= xLE(sectID_Neocass(i,1),ydir);
                dy= y2-y1;
            sweep_25chord(i) = atan(dx/dy)/rad;

                x2= xLE(sectID_Neocass(i,2),1)+0.50*(xTE(sectID_Neocass(i,2),1)-xLE(sectID_Neocass(i,2),1));
                x1= xLE(sectID_Neocass(i,1),1)+0.50*(xTE(sectID_Neocass(i,1),1)-xLE(sectID_Neocass(i,1),1));
                dx= x2-x1;
                y2= xLE(sectID_Neocass(i,2),ydir);
                y1= xLE(sectID_Neocass(i,1),ydir);
                dy= y2-y1;
            sweep_50chord(i) = atan(dx/dy)/rad;

            dihedral(i)= atan((xLE(sectID_Neocass(i,2),zdir)-xLE(sectID_Neocass(i,1),zdir))/(xLE(sectID_Neocass(i,2),ydir)-xLE(sectID_Neocass(i,1),ydir)))/rad;
            span(i)    =       xLE(sectID_Neocass(i,2),ydir)-xLE(sectID_Neocass(i,1),ydir);

            taper(i)   = chord(i+1)/chord(1);

            area(i)    = (chord(i+1)+chord(i))/2*span(i);
        end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
if wingID==1
%% Main wing
% function NEOCASSWing1(iWing)
for k=1
%       global ac NEOCASS                        
       %NEOCASS.Reference
            if strcmp( TechGeoModel.iWing{wingID}.symmetry,'x-z-plane'), Mirror=2;
            else                                                         Mirror=1;
            end    
            %refernce wing ->Wing1
            
       %NEOCASS.Wing1.     
            NEOCASS.Wing1.present      = 1; 
            NEOCASS.Wing1.symmetry     = symmetry;                  
            NEOCASS.Wing1.area         = Area*Mirror;
            NEOCASS.Wing1.Span         = semiSpan*Mirror;
            NEOCASS.Wing1.AR           =(NEOCASS.Wing1.Span)^2/NEOCASS.Wing1.area ;
        %spanwise    
            NEOCASS.Wing1.spanwise_kink1 = sum(span(1:1))/semiSpan;
            NEOCASS.Wing1.spanwise_kink2 = sum(span(1:2))/semiSpan;
        %taper
            NEOCASS.Wing1.taper_kink1    = chord(2)/chord(1);
            NEOCASS.Wing1.taper_kink2    = chord(3)/chord(1);       
            NEOCASS.Wing1.taper_tip      = chord(4)/chord(1);
        %incidence     
            NEOCASS.Wing1.root_incidence  = incidence(1);        
            NEOCASS.Wing1.kink1_incidence = incidence(2);        
            NEOCASS.Wing1.kink2_incidence = incidence(3);        
            NEOCASS.Wing1.tip_incidence   = incidence(4);
        %sweep
            NEOCASS.Wing1.LE_sweep_inboard  = sweep(1);        
            NEOCASS.Wing1.LE_sweep_midboard = sweep(2);
            NEOCASS.Wing1.LE_sweep_outboard = sweep(3);
        %sweep 1/4chord
            NEOCASS.Wing1.quarter_chord_sweep_inboard  = sweep_25chord(1);
            NEOCASS.Wing1.quarter_chord_sweep_midboard = sweep_25chord(2);
            NEOCASS.Wing1.quarter_chord_sweep_outboard = sweep_25chord(3);
            
            NEOCASS.Wing1.Reference_quarter_chord_sweep = sweep_25chord*area'/Area;
        %dihedral    
            NEOCASS.Wing1.dihedral_inboard  = dihedral(1);
            NEOCASS.Wing1.dihedral_midboard = dihedral(2);
            NEOCASS.Wing1.dihedral_outboard = dihedral(3);
        %airfoilName
%             NEOCASS.Wing1.airfoilRoot       = profileName{1};  
%             NEOCASS.Wing1.airfoilKink1      = profileName{2};
%             NEOCASS.Wing1.airfoilKink2      = profileName{3};
%             NEOCASS.Wing1.airfoilTip        = profileName{4};
            NEOCASS.Wing1.airfoilRoot       = '0012.dat';  
            NEOCASS.Wing1.airfoilKink1      = '0012.dat';
            NEOCASS.Wing1.airfoilKink2      = '0012.dat';
            NEOCASS.Wing1.airfoilTip        = '0012.dat';
        %thickness
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % 	thickness_root                       (0.12)      []    %chord thickness
        % 	thickness_kink1                      (0.12)      []    ...
        % 	thickness_kink2                      (0.12)      []    ...
        % 	thickness_tip                        (0.12)      []    ...
            NEOCASS.Wing1.thickness_root=0.12;                
            NEOCASS.Wing1.thickness_kink1=0.12;
            NEOCASS.Wing1.thickness_kink2=0.12;
            NEOCASS.Wing1.thickness_tip=0.12;
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        %configuration
            NEOCASS.Wing1.configuration=0;
        % winglet
        %     present                            (1)         Flag  
            NEOCASS.Wing1.winglet.present=0;
                
        %     Span                               (1.5)       [%]   winglet span divided by wing tip chord                                                                                                                                                                                                                                       
        %     taper_ratio                        (0.6)       [0-1] taper ratio respect wing tip chord                                                                                                                                                                                                                                 
        %     LE_sweep                           (40.0)      [deg] Leading Edge sweep angle                                                                                                                                                                                                                                    
        %     Cant_angle                         (40.0)      [deg] Cant angle                             fig A8                                                                                                                                                                                                                                              
        %     root_incidence                     (5.0)       [deg] incidence angle arround Leading Edge                                                                                                                                                                                                                              
        %     tip_incidence                      (5.0)       [deg] ...   
                NEOCASS.Wing1.winglet.Span=1.5;
        % flap
            if ~isempty(etaFL_B)
                NEOCASS.Wing1.flap.present=1; 
                j=1; while etaFL_B(j)<0.7, j=j+1;  end
                if j==2                           
                    NEOCASS.Wing1.flap.root_chord =1- xsiFL_A(1);                                                                                                                                                                                                                                           
%                     NEOCASS.Wing1.flap.kink1_chord=(xsiFL_B(1)+xsiFL_A(2))/2;  
                    NEOCASS.Wing1.flap.kink1_chord=1- xsiFL_A(2); 
                    NEOCASS.Wing1.flap.kink2_chord=1- xsiFL_B(2);
                end               
            else
                NEOCASS.Wing1.flap.present=0;
            end
        % aileron
            if j==2 && length(etaFL_A)==3
                NEOCASS.Wing1.aileron.present=1;
                NEOCASS.Wing1.aileron.chord  = 1-(xsiFL_A(3)+xsiFL_B(3))/2;
                NEOCASS.Wing1.aileron.Span   = 0.8; 
%                 NEOCASS.Wing1.aileron.Span        =(etaFL_B(3)-etaFL_A(3));  
                if etaFL_A(3)==xLE(sectID_Neocass(3,1),2)
                    NEOCASS.Wing1.aileron.position = 0;
                else
                    NEOCASS.Wing1.aileron.position = 1;
                end
                NEOCASS.Wing1.aileron.limit_deflection_up=+20;
                NEOCASS.Wing1.aileron.limit_deflection_down=-20;
            else
                NEOCASS.Wing1.aileron.present=0;
            end
%         % slat                                 
%         %     present                            (1)         Flag 
                    NEOCASS.Wing1.slat.present=0;
%         %     chord                              (0.1)       [0-1] % local chord from Leading Edge                                                                                                                                                                                                                                          
%         %     root_position                      (0.1)       [0-1] inboard  distance divided by semispan  fig A10                                                                                                                                                                                                                                  
%         %     tip_position                       (0.1)       [0-1] outboard distance divided by semispan  fig A10                                                                                                                                                                                                                                   
%         % fairing
%         %     present                            (1)         Flag 
                    NEOCASS.Wing1.fairing.present=0;
%         %     Forward_chord_fraction             (50.0)      [%]   % root chord, fore super-elipsoid x-semi axis                                                                                                                                                                                                                      
%         %     Aft_chord_fraction                 (50.0)      [%]   % root chord, aft  super-elipsoid x-semi axis                                                                                                                                                                                                                          
%         %     flushness                          (10.0)      [%]   % root chord, width super-elipsoid y-semi axis                                                                                                                                                                                                                                  
%         % placement                            (0.14)      fusva % Fuselage vert diameter,wing root pos fig A4
        %!!!!!! da modificare !!!!!!!!!!!!!!!!!    
            NEOCASS.Wing1.placement  = abs(NEOCASS.Fuselage.Forefuse_X_sect_vertical_diameter/2-abs(prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3)))/NEOCASS.Fuselage.Forefuse_X_sect_vertical_diameter;
        % apex_locale                          (0.3275)    fusin % Fuselage length, wing root LE        fig A5
            NEOCASS.Wing1.apex_locale= prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1)/NEOCASS.Fuselage.Total_fuselage_length;
        
            NEOCASS.Wing1.Span_matrix_partition_in_mid_outboard=span';
            NEOCASS.Wing1.longitudinal_location                =prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1);
            NEOCASS.Wing1.vertical_location                    =prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3);

            NEOCASS.Wing1.x                                    = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1);
            NEOCASS.Wing1.y                                    = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,2);
            NEOCASS.Wing1.z                                    = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3);

            NEOCASS.Wing1.Weighted_taper_ratio                 = taper  *  area'/Area;
        
        %?????????????????????????
            NEOCASS.Wing1.Original_estimated_fuse_wing_chrd=chord(1);
        %????????????????????????????
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Geometry
            % beam_model
                % nwing_inboard                  (5)     [] n° beam elements
                % nwing_midboard                 (5)     [] ...
                % nwing_outboard                 (5)     [] ...
                % nwing_carryth                  (2)     [] n° beam elements carrythrou sector
                    NEOCASS.user_input.geometry.beam_model.nwing_inboard =board_node(1);
                    NEOCASS.user_input.geometry.beam_model.nwing_midboard=board_node(2);
                    NEOCASS.user_input.geometry.beam_model.nwing_outboard=board_node(3);
                    NEOCASS.user_input.geometry.beam_model.nwing_carryth =2;
            % aero_panel
                % nx
                    % wing_inboard                (4)      [] n° aero panels wind direction
                    % wing_midboard               (4)      [] ...
                    % wing_outboard               (4)      [] ...                    
                        NEOCASS.user_input.geometry.aero_panel.nx.wing_inboard =board_nxPan(1);
                        NEOCASS.user_input.geometry.aero_panel.nx.wing_midboard=board_nxPan(2); 
                        NEOCASS.user_input.geometry.aero_panel.nx.wing_outboard=board_nxPan(3);
                    % sup_control.wing_inboard    (3)      [] ...
                    % sup_control.wing_midboard   (3)      [] ...
                    % sup_control.wing_outboard   (3)      [] ...
                        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.wing_inboard =board_nxTEDPan(1);
                        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.wing_midboard=board_nxTEDPan(2);
                        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.wing_outboard=board_nxTEDPan(3);
                % ny
                    % wing_inboard                (4)      [] n° aero panels span direction
                    % wing_midboard               (4)      [] ...
                    % wing_outboard               (4)      [] ...                    
                        NEOCASS.user_input.geometry.aero_panel.ny.wing_inboard =board_nyPan(1);
                        NEOCASS.user_input.geometry.aero_panel.ny.wing_midboard=board_nyPan(2); 
                        NEOCASS.user_input.geometry.aero_panel.ny.wing_outboard=board_nyPan(3);
            %spar_location
                % Wing1                                  
                % Fore_W2_spar_loc_root     (0.2)      [%]  ...
                % Aft_W2_spar_loc_root      (0.8)      [%]  ...
                % Fore_W2_spar_loc_kink1    (0.2)      [%]  ...
                % Aft_W2_spar_loc_kink1     (0.8)      [%]  ...
                % Fore_W2_spar_loc_kink2    (0.2)      [%]  ...
                % Aft_W2_spar_loc_kink2     (0.8)      [%]  ...
                % Fore_W2_spar_loc_tip      (0.2)      [%]  ...
                % Aft_W2_spar_loc_tip       (0.8)      [%]  ...
                    NEOCASS.user_input.geometry.spar_location.Wing1.Fore_W2_spar_loc_root =0.2;
                    NEOCASS.user_input.geometry.spar_location.Wing1.Aft_W2_spar_loc_root  =0.6;
                    NEOCASS.user_input.geometry.spar_location.Wing1.Fore_W2_spar_loc_kink1=0.2;
                    NEOCASS.user_input.geometry.spar_location.Wing1.Aft_W2_spar_loc_kink1 =0.6;
                    NEOCASS.user_input.geometry.spar_location.Wing1.Fore_W2_spar_loc_kink2=0.2;
                    NEOCASS.user_input.geometry.spar_location.Wing1.Aft_W2_spar_loc_kink2 =0.6;
                    NEOCASS.user_input.geometry.spar_location.Wing1.Fore_W2_spar_loc_tip  =0.2;
                    NEOCASS.user_input.geometry.spar_location.Wing1.Aft_W2_spar_loc_tip   =0.6;
        % Material_property                                                               
            % wing                                                                          
            % kcon            (2)                    Flag     structural concept          
            % esw             (73751890000)          [Pa]     Young's moduls              
            % dsw             (2795.7174)            [kg/m^3] material density            
            % fcsw            (1.370588235294E8)     [Pa]     shear strength 		          
            % spitch          (0)                    [m]      distance between stringers  
            % rpitch          (0.0)                  []       distance between ribs       
            % msl             (0.0)                  [Pa]     tensile strength 
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                          
            NEOCASS.user_input.material_property.wing.kcon  = 2; 
            NEOCASS.user_input.material_property.wing.esw   = 73751890000;   
            NEOCASS.user_input.material_property.wing.dsw   = 2795.7174;  
            NEOCASS.user_input.material_property.wing.fcsw  = 1.370588235294E8;  
            NEOCASS.user_input.material_property.wing.spitch= 0;  
            NEOCASS.user_input.material_property.wing.rpitch= 0.0;  
            NEOCASS.user_input.material_property.wing.msl   = 0.0; 
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
end
%% Refernce Wing
for k=1
    NEOCASS.Reference_wing.convention          = 1;
    NEOCASS.Reference_wing.taper_ratio         = taper*area'/Area;
    NEOCASS.Reference_wing.planform_AR         = NEOCASS.Wing1.AR;
    NEOCASS.Reference_wing.Weighted_area       = NEOCASS.Wing1.area; 
    NEOCASS.Reference_wing.LE_sweep            = sweep        *area'/Area;
    NEOCASS.Reference_wing.Quarter_chord_sweep = sweep_25chord*area'/Area;
    NEOCASS.Reference_wing.Half_chord_sweep    = sweep_50chord*area'/Area;
    NEOCASS.Reference_wing.MAC                 = TechGeoModel.iWing{wingID}.Reference.mac;
    NEOCASS.Reference_wing.relative_apex       = 0.25;
    NEOCASS.Reference_wing.Orig_root_chrd_at_ac_CL = 16.986460366815;
    NEOCASS.Reference_wing.non_dim_MAC_y_bar   = 0.39952755736574;
    NEOCASS.Reference_wing.Weighted_aspect_ratio= NEOCASS.Wing1.AR;
    NEOCASS.Reference_wing.mean_thickness  =mean([NEOCASS.Wing1.thickness_root;...                
                                                  NEOCASS.Wing1.thickness_kink1;...
                                                  NEOCASS.Wing1.thickness_kink2;...
                                                  NEOCASS.Wing1.thickness_tip]);
    NEOCASS.Reference_wing.Wing_area_for_weight_balance_analysis=NEOCASS.Wing1.area;

end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if wingID==2
%% Horizontal_tail
% function NEOCASShTail(iWing)
for k=1                                                
        %NEOCASS.Horizontal_tail.
        %reference
            if strcmp( TechGeoModel.iWing{wingID}.symmetry,'x-z-plane'), Mirror=2;
            else                                                         Mirror=1;
            end      
            NEOCASS.Horizontal_tail.symmetry        =symmetry;
            NEOCASS.Horizontal_tail.present         =1;       
            NEOCASS.Horizontal_tail.area            =Area*Mirror;
            NEOCASS.Horizontal_tail.Span            =semiSpan*Mirror;
            NEOCASS.Horizontal_tail.AR              =(semiSpan)^2/Area;
        %spanwise    
            NEOCASS.Horizontal_tail.spanwise_kink =sum(span(1:1))/semiSpan;           
        %taper
            NEOCASS.Horizontal_tail.taper_kink    =   chord(2)/chord(1);                   
            NEOCASS.Horizontal_tail.taper_tip     =   chord(3)/chord(1);
            
            NEOCASS.Horizontal_tail.Weighted_taper_ratio          =     taper  *  area'/Area;
        % incidence                       
            NEOCASS.Horizontal_tail.root_incidence   = incidence(1);
            NEOCASS.Horizontal_tail.kink_incidence   = incidence(2);
            NEOCASS.Horizontal_tail.tip_incidence    = incidence(3);
        % sweep            
            NEOCASS.Horizontal_tail.LE_sweep_inboard = sweep(1);                 
            NEOCASS.Horizontal_tail.LE_sweep_outboard= sweep(2);
        % sweep 1/4chord
            NEOCASS.Horizontal_tail.quarter_chord_sweep_inboard = sweep_25chord(1);
            NEOCASS.Horizontal_tail.quarter_chord_sweep_outboard= sweep_25chord(2);
        % dihedral    
            NEOCASS.Horizontal_tail.dihedral_inboard = dihedral(1);
            NEOCASS.Horizontal_tail.dihedral_outboard= dihedral(2);
        % profile name
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%             NEOCASS.Horizontal_tail.airfoilRoot      = profileName{1};  
%             NEOCASS.Horizontal_tail.airfoilKink      = profileName{1};
%             NEOCASS.Horizontal_tail.airfoilTip       = profileName{1}; 
            NEOCASS.Horizontal_tail.airfoilRoot      = '0012.dat';  
            NEOCASS.Horizontal_tail.airfoilKink      = '0012.dat';
            NEOCASS.Horizontal_tail.airfoilTip       = '0012.dat'; 
        
        % thickness_root                       (0.12)      []    %chord thickness
        % thickness_kink                       (0.12)      []    ...
        % thickness_tip                        (0.12)      []    ... 
            NEOCASS.Horizontal_tail.thickness_root=0.12;        
            NEOCASS.Horizontal_tail.thickness_kink=0.12;        
            NEOCASS.Horizontal_tail.thickness_tip =0.12;
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
        % empennage_layout                     (0)         Flag  0)position independent from Vtail,1)T-tail 
            NEOCASS.Horizontal_tail.empennage_layout = 0;                    
        % Elevator      
        if ~isempty(etaFL_A)                                          
                NEOCASS.Horizontal_tail.Elevator.present              = 1;
                NEOCASS.Horizontal_tail.Elevator.chord                = 1-(mean(xsiFL_A)+mean(xsiFL_B))/2;
                NEOCASS.Horizontal_tail.Elevator.Span                 = max(etaFL_B);
                NEOCASS.Horizontal_tail.Elevator.limit_deflection_up  = +20;
                NEOCASS.Horizontal_tail.Elevator.limit_deflection_down= -20;
            % limit_tailplane_deflection_up        (0.0)       [deg] 
                NEOCASS.Horizontal_tail.limit_tailplane_deflection_up  = 0;
            % limit_tailplane_deflection_down      (0.0)       [deg]  
                NEOCASS.Horizontal_tail.limit_tailplane_deflection_down =0;
        end  
        % placement
            % vertical_locale                      (0.2633)    fusva %Fuselage vert diameter, wing root pos                                                                                                                                                                                        
            % apex_locale                          (0.8908)    fusin %Fuselage length, wing root LE 
            NEOCASS.Horizontal_tail.vertical_locale       = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3)/NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter;
            NEOCASS.Horizontal_tail.apex_locale           = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1)/NEOCASS.Fuselage.Total_fuselage_length;
        
            NEOCASS.Horizontal_tail.longitudinal_location = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1);
            NEOCASS.Horizontal_tail.vertical_location     = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3);
            
            NEOCASS.Horizontal_tail.x                     = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1);
            NEOCASS.Horizontal_tail.y                     = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,2);
            NEOCASS.Horizontal_tail.z                     = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3);
        % reference param
            NEOCASS.Horizontal_tail.reference_wing_quarter_chord_sweep=sweep_25chord*area'/Area;
            NEOCASS.Horizontal_tail.reference_wing_half_chord_sweep   =sweep_50chord*area'/Area;           
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            NEOCASS.Horizontal_tail.Moment_arm_to_HT=1000;
            NEOCASS.Horizontal_tail.reference_wing_Y_bar_non_dim=0.2;
            NEOCASS.Horizontal_tail.reference_wing_mean.thickness=0.12;
            NEOCASS.Horizontal_tail.Span_matrix_partition_in_mid_outboard=[span,span(end)]';
            NEOCASS.Horizontal_tail.original_root_chord=chord(1);
            NEOCASS.Horizontal_tail.reference_wing_area=Area;
            NEOCASS.Horizontal_tail.reference_wing_taper_ratio=taper(1);
            NEOCASS.Horizontal_tail.reference_wing_LE_chord_sweep=sweep(1);
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Geometry
            % beam_model
                    NEOCASS.user_input.geometry.beam_model.nhtail_inboard =board_node(1);
                    NEOCASS.user_input.geometry.beam_model.nhtail_outboard=board_node(2);
                    NEOCASS.user_input.geometry.beam_model.nhtail_carryth =2;  
            % aero_panel
                % nx
                        NEOCASS.user_input.geometry.aero_panel.nx.hori_inboard =board_nxPan(1); 
                        NEOCASS.user_input.geometry.aero_panel.nx.hori_outboard=board_nxPan(2);
                    % sup_control
                        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.hori_inboard =board_nxTEDPan(1);
                        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.hori_outboard=board_nxTEDPan(2);
                % ny            
                        NEOCASS.user_input.geometry.aero_panel.ny.hori_inboard =board_nyPan(1); 
                        NEOCASS.user_input.geometry.aero_panel.ny.hori_outboard=board_nyPan(2);
            %spar_location            
                    NEOCASS.user_input.geometry.spar_location.Horizontal_tail.Fore_HT_spar_loc_root=0.15;
                    NEOCASS.user_input.geometry.spar_location.Horizontal_tail.Aft_HT_spar_loc_root =0.65;
                    NEOCASS.user_input.geometry.spar_location.Horizontal_tail.Fore_HT_spar_loc_kink=0.15;
                    NEOCASS.user_input.geometry.spar_location.Horizontal_tail.Aft_HT_spar_loc_kink =0.65;
                    NEOCASS.user_input.geometry.spar_location.Horizontal_tail.Fore_HT_spar_loc_tip =0.15;
                    NEOCASS.user_input.geometry.spar_location.Horizontal_tail.Aft_HT_spar_loc_tip  =0.65;
                    
        % Material_property                                                               
            % htail                                                                          
                % kcon            (2)                    Flag     structural concept          
                % esw             (73751890000)          [Pa]     Young's moduls              
                % dsw             (2795.7174)            [kg/m^3] material density            
                % fcsw            (1.370588235294E8)     [Pa]     shear strength 		          
                % spitch          (0)                    [m]      distance between stringers  
                % rpitch          (0.0)                  []       distance between ribs       
                % msl             (0.0)                  [Pa]     tensile strength 
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    NEOCASS.user_input.material_property.htail.kcon  =2                  ;   
                    NEOCASS.user_input.material_property.htail.esw   =73751890000        ;   
                    NEOCASS.user_input.material_property.htail.dsw   =2795.7174          ;   
                    NEOCASS.user_input.material_property.htail.fcsw  =1.370588235294E8   ;   
                    NEOCASS.user_input.material_property.htail.spitch=0                  ;   
                    NEOCASS.user_input.material_property.htail.rpitch=0.0                ;   
                    NEOCASS.user_input.material_property.htail.msl   =0.0                ;
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if wingID==3
%% Vertical_tail    
% function NEOCASSvTail(iWing)
for k=1              
%NEOCASS.Vertical_tail.
    % reference
        if strcmp( TechGeoModel.iWing{wingID}.symmetry,'x-z-plane'), Mirror=2;
        else                                                         Mirror=1;
        end  
    % general param     
        NEOCASS.Vertical_tail.symmetry     =symmetry;
        NEOCASS.Vertical_tail.present      =1;       
        NEOCASS.Vertical_tail.area         =Area*Mirror;
        NEOCASS.Vertical_tail.Span         =semiSpan*Mirror;
        NEOCASS.Vertical_tail.AR           =(semiSpan)^2/Area;
    % spanwise    
        NEOCASS.Vertical_tail.spanwise_kink=sum(span(1:1))/semiSpan;          
    % taper
        NEOCASS.Vertical_tail.taper_kink=chord(2)/chord(1);                   
        NEOCASS.Vertical_tail.taper_tip  =chord(3)/chord(1);
    % incidence
        NEOCASS.Vertical_tail.root_incidence=incidence(1);           
        NEOCASS.Vertical_tail.kink_incidence=incidence(2);            
        NEOCASS.Vertical_tail.tip_incidence =incidence(3);
    % sweep    
        NEOCASS.Vertical_tail.LE_sweep_inboard =sweep(1) ;                 
        NEOCASS.Vertical_tail.LE_sweep_outboard=sweep(2);
    % sweep 1/4chord
        NEOCASS.Vertical_tail.quarter_chord_sweep_inboard = sweep_25chord(1);
        NEOCASS.Vertical_tail.quarter_chord_sweep_outboard= sweep_25chord(2);            
    % dihedral    
        NEOCASS.Vertical_tail.dihedral_inboard =dihedral(1);
        NEOCASS.Vertical_tail.dihedral_outboard=dihedral(2);
    % profileName
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%         NEOCASS.Vertical_tail.airfoilRoot      =profileName{1};  
%         NEOCASS.Vertical_tail.airfoilKink      =profileName{1};
%         NEOCASS.Vertical_tail.airfoilTip       =profileName{1}; 
        NEOCASS.Vertical_tail.airfoilRoot      = '0012';  
        NEOCASS.Vertical_tail.airfoilKink      = '0012';
        NEOCASS.Vertical_tail.airfoilTip       = '0012'; 
    % thickness
    
        % thickness_root                       (0.12)      []    %chord thickness
        % thickness_kink                       (0.12)      []    ...
        % thickness_tip                        (0.12)      []    ... 
        NEOCASS.Vertical_tail.thickness_root=0.12;        
        NEOCASS.Vertical_tail.thickness_kink =0.12;        
        NEOCASS.Vertical_tail.thickness_tip=0.12;
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     if ~isempty(etaFL_A)
        % Rudder        
            NEOCASS.Vertical_tail.Rudder.present    =1;
            NEOCASS.Vertical_tail.Rudder.chord      = 1-(mean(xsiFL_A)+mean(xsiFL_B))/2;
            NEOCASS.Vertical_tail.Rudder.Span       = max(etaFL_B);  
            NEOCASS.Vertical_tail.Rudder.limit_deflection= +20;           
        % Twin_tail                            (0)         Flag  0)No
        %                                                        1)Yes  
            NEOCASS.Vertical_tail.Twin_tail=0;
            NEOCASS.Vertical_tail.Twin_tail_span=0;  
%             % Twin_tail_span                       (0.5)       wspn  % wing semi-span     
     end
    % placement
        % vertical_locale                      (0.4368)    fusva %fuselage vert diameter, wing root pos fig A4                                                                                                                                                                                                                              
        % apex_locale                          (0.815)     fusin %fuselage length, wing root LE         fig A5     
        NEOCASS.Vertical_tail.vertical_locale                = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3)/NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter;
        NEOCASS.Vertical_tail.apex_locale                    = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1)/NEOCASS.Fuselage.Total_fuselage_length;
        
        NEOCASS.Vertical_tail.longitudinal_location          = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1);
        NEOCASS.Vertical_tail.vertical_location              = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3);
        NEOCASS.Vertical_tail.x                              = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,1);
        NEOCASS.Vertical_tail.y                              = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,2);
        NEOCASS.Vertical_tail.z                              = prof_wing(sectID_Neocass(1,1)).pnt_pos(prof_wing(sectID_Neocass(1,1)).iLE,3);
        
    % reference param
        NEOCASS.Vertical_tail.reference_wing_area            = Area;
        NEOCASS.Vertical_tail.reference_wing_taper_ratio     = taper * area'/Area;
        NEOCASS.Vertical_tail.reference_wing_LE_sweep        = sweep        *area'/Area;
        NEOCASS.Vertical_tail.reference_wing_quarter_chord_sweep= sweep_25chord*area'/Area;
        NEOCASS.Vertical_tail.reference_wing_Half_chord_sweep= sweep_50chord*area'/Area;
        NEOCASS.Vertical_tail.reference_wing_MAC             = TechGeoModel.iWing{wingID}.Reference.mac;        
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!      
        NEOCASS.Vertical_tail.reference_wing_mean_thickness  = 0.12;
        NEOCASS.Vertical_tail.original_root_chord            = chord(1);   
        NEOCASS.Vertical_tail.reference_Y_bar_non_dim        = 1000;          
        NEOCASS.Vertical_tail.Moment_arm_to_VT               = 1000;                 
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            %NEOCASS.Vertical_tail.Moment_arm_to_HT=1000;
            %NEOCASS.Vertical_tail.reference_wing_Y_bar_non_dim=0.2;
            %NEOCASS.Vertical_tail.reference_wing_mean.thickness=0.12;
            NEOCASS.Vertical_tail.Span_matrix_partition_in_mid_outboard=[span,span(end)]';
            NEOCASS.Vertical_tail.original_root_chord=chord(1);
            NEOCASS.Vertical_tail.reference_wing_area=Area;
            NEOCASS.Vertical_tail.reference_wing_taper_ratio=taper(1);
            NEOCASS.Vertical_tail.reference_wing_LE_chord_sweep=sweep(1);
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Geometry
    % beam_model
        % nvtail_inboard                 (5)     [] ...                                                                                                                                 
        % nvtail_outboard                (5)     [] ...
            NEOCASS.user_input.geometry.beam_model.nvtail_inboard =board_node(1);
            NEOCASS.user_input.geometry.beam_model.nvtail_outboard=board_node(2);
    % aero_panel 
        % nx
            % vert_inboard                (4)      [] n° aero panels wind direction            
            % vert_outboard               (4)      [] ...                   
                NEOCASS.user_input.geometry.aero_panel.nx.vert_inboard =board_nxPan(1); 
                NEOCASS.user_input.geometry.aero_panel.nx.vert_outboard=board_nxPan(2);
            % sup_control.vert_inboard    (3)      [] ...
            % sup_control.vert_outboard   (3)      [] ...       
                NEOCASS.user_input.geometry.aero_panel.nx.sup_control.vert_inboard =board_nxTEDPan(1);
                NEOCASS.user_input.geometry.aero_panel.nx.sup_control.vert_outboard=board_nxTEDPan(2);
        % ny
            % vert_inboard                (4)      [] n° aero panels span direction
            % vert_outboard               (4)      [] ...                    
                NEOCASS.user_input.geometry.aero_panel.ny.vert_inboard =board_nyPan(1); 
                NEOCASS.user_input.geometry.aero_panel.ny.vert_outboard=board_nyPan(2);
    %spar_location
        % Fore_VT_spar_loc_root     (0.15)     [%] spar position % chord 
        % Aft_VT_spar_loc_root      (0.65)     [%]  ...                  
        % Fore_VT_spar_loc_kink     (0.15)     [%]  ...                  
        % Aft_VT_spar_loc_kink      (0.65)     [%]  ...                  
        % Fore_VT_spar_loc_tip      (0.15)     [%]  ...                  
        % Aft_VT_spar_loc_tip       (0.65)     [%]  ...                  
            NEOCASS.user_input.geometry.spar_location.Vertical_tail.Fore_VT_spar_loc_root=0.15;
            NEOCASS.user_input.geometry.spar_location.Vertical_tail.Aft_VT_spar_loc_root =0.65;
            NEOCASS.user_input.geometry.spar_location.Vertical_tail.Fore_VT_spar_loc_kink=0.15;
            NEOCASS.user_input.geometry.spar_location.Vertical_tail.Aft_VT_spar_loc_kink =0.65;
            NEOCASS.user_input.geometry.spar_location.Vertical_tail.Fore_VT_spar_loc_tip =0.15;
            NEOCASS.user_input.geometry.spar_location.Vertical_tail.Aft_VT_spar_loc_tip  =0.65;
% Material_property                                                               
    % vtail                                                                          
        % kcon            (2)                    Flag     structural concept          
        % esw             (73751890000)          [Pa]     Young's moduls              
        % dsw             (2795.7174)            [kg/m^3] material density            
        % fcsw            (1.370588235294E8)     [Pa]     shear strength 		          
        % spitch          (0)                    [m]      distance between stringers  
        % rpitch          (0.0)                  []       distance between ribs       
        % msl             (0.0)                  [Pa]     tensile strength 
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            NEOCASS.user_input.material_property.vtail.kcon  =2                  ; 
            NEOCASS.user_input.material_property.vtail.esw   =73751890000        ; 
            NEOCASS.user_input.material_property.vtail.dsw   =2795.7174          ; 
            NEOCASS.user_input.material_property.vtail.fcsw  =1.370588235294E8   ; 
            NEOCASS.user_input.material_property.vtail.spitch=0                  ; 
            NEOCASS.user_input.material_property.vtail.rpitch=0.0                ; 
            NEOCASS.user_input.material_property.vtail.msl   =0.0                ; 
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Canard
for k=1
   NEOCASS.Canard.present=0; 
   % Geometry
    % beam_model
%      NEOCASS.user_input.geometry.beam_model.nhtail_inboard =board_node(1);
%      NEOCASS.user_input.geometry.beam_model.nhtail_outboard=board_node(2);
%      NEOCASS.user_input.geometry.beam_model.nhtail_carryth =2;  
    % aero_panel
     % nx
      NEOCASS.user_input.geometry.aero_panel.nx.hori_inboard =4; 
      NEOCASS.user_input.geometry.aero_panel.nx.hori_outboard=4;
      % sup_control
       NEOCASS.user_input.geometry.aero_panel.nx.sup_control.hori_inboard =3;
       NEOCASS.user_input.geometry.aero_panel.nx.sup_control.hori_outboard=3;
     % ny            
      NEOCASS.user_input.geometry.aero_panel.ny.hori_inboard =4; 
      NEOCASS.user_input.geometry.aero_panel.ny.hori_outboard=4;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wing2
for k=1
   NEOCASS.Wing2.present=0; 
    NEOCASS.Wing2.configuration=0;
    NEOCASS.Wing2.placement=0;
    NEOCASS.Wing2.area=0;
    NEOCASS.Wing2.Weighted_reference_aspect_ratio=0;
    NEOCASS.Wing2.Weighted_reference_wing_area=0;
    NEOCASS.Wing2.Weighted_taper_ratio=0;
    NEOCASS.Wing2.Reference_quarter_chord_sweep=0;
    NEOCASS.Wing2.Wing_mean_thickness=0;
    
   %geometry
    %aero_panel
     % nx
      % wing2_inboard                (4)      [] n° aero panels wind direction
      % wing2_midboard               (4)      [] ...
      % wing2_outboard               (4)      [] ...                    
        NEOCASS.user_input.geometry.aero_panel.nx.wing2_inboard =4;
        NEOCASS.user_input.geometry.aero_panel.nx.wing2_midboard=4; 
        NEOCASS.user_input.geometry.aero_panel.nx.wing2_outboard=4;
      % sup_control.wing_inboard    (3)      [] ...
      % sup_control.wing_midboard   (3)      [] ...
      % sup_control.wing_outboard   (3)      [] ...
        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.wing2_inboard =3;
        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.wing2_midboard=3;
        NEOCASS.user_input.geometry.aero_panel.nx.sup_control.wing2_outboard=3;
      % ny
       % wing_inboard                (4)      [] n° aero panels span direction
       % wing_midboard               (4)      [] ...
       % wing_outboard               (4)      [] ...                    
        NEOCASS.user_input.geometry.aero_panel.ny.wing2_inboard =4;
        NEOCASS.user_input.geometry.aero_panel.ny.wing2_midboard=4; 
        NEOCASS.user_input.geometry.aero_panel.ny.wing2_outboard=4;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Engines1                                                                                                                                   
for k=1
    try
        for kk=1
        engineModel=ac.vehicles{1}.aircraft{1}.model{1}.engines{1}.engine{1}       
        engineUID  =engineModel.engineUID{1}.CONTENT
        transform  =engineModel.transformation{1}
        try
            symmetry=engineModel.ATTRIBUTE.symmetry
            Mirror=2;
        catch
            symmetry=0
            Mirror=1;
        end
        symmetry


        ac.vehicles{1}.engines{1}.engine{1}.ATTRIBUTE.uID
        j=1;
        while strcmp(engineUID,ac.vehicles{1}.engines{1}.engine{j}.ATTRIBUTE.uID)==0
            j=j+1;
        end
        engine=ac.vehicles{1}.engines{1}.engine{j}

        %NeoCASS translation
        NEOCASS.Engines1.present=1;
        NEOCASS.Engines1.Number_of_engines=2;
% 	Layout_and_config                    (0)         Flag 0)near wing                                                                        
% 	                                                      1)on-wing nacelle                                                                  
% 	                                                      2)on-wing integrated with udercarriage                                             
% 	                                                      3)aft-fuselage                                                                     
% 	                                                      4)straight duct                                                                    
% 	                                                      5)S-duct 
        NEOCASS.Engines1.Layout_and_config=0;
% 	Propulsion_type                      (0)         Flag 0)turbofan                                                                         
% 	                                                      1)turboprop tractor                                                                
% 	                                                      2)turboprop pusher                                                                 
% 	                                                      3)propfan 
        NEOCASS.Engines1.Propulsion_type=0;
% 	Nacelle_body_type                    (1)         Flag 0)short-ducted nacelle                                                             
% 	                                                      1)long-ducted nacelle                                                              
        NEOCASS.Engines1.Nacelle_body_type=1;
% 	symmetry                             (1)         Flag                                                                                    
        NEOCASS.Engines1.symmetry=1;
% 	fineness_ratio                       (2.3921)    >0    nacelle length divided by nac. max diameter                                       
        NEOCASS.Engines1.fineness_ratio=2.3921;
        
        NEOCASS.Engines1.d_max=str2num(engine.global{1}.dFan{1}.CONTENT)
% 	toe_in                               (0.0)       [deg] nacelle tow-in angle                   fig A13                                    
        NEOCASS.Engines1.toe_in=0;
% 	pitch                                (0.0)       [deg] nacelle pitch angle                    fig A14                                    
        NEOCASS.Engines1.pitch=0;
% 	Thrust_to_weight_ratio               (0.0)       []                                                                                      
        NEOCASS.Engines1.Thrust_to_weight_ratio=0;
% 	Propeller_diameter                   (1.98)      [m]   propeller diameter                                                                
        NEOCASS.Engines1.Propeller_diameter=1.98;
                                                                                   
        NEOCASS.Engines1.Max_thrust                   =str2num(engine.global{1}.thrust00{1}.CONTENT)/1000;                                                                                      
        NEOCASS.Engines1.Bypass_ratio_to_emulate      =str2num(engine.global{1}.bpr00{1}.CONTENT); 
        
        % 	Thrust_reverser_effectivness         (0)         []
        NEOCASS.Engines1.Thrust_reverser_effectivness =.0;                                                                 
        NEOCASS.Engines1.Fan_cowl_length_ratio        =70;         
        NEOCASS.Engines1.Nacelle_length_array         = 3 * NEOCASS.Engines1.d_max;
        
        NEOCASS.Engines1.Nacelle1.longitudinal_location= str2num(engineModel.transformation{1}.translation{1}.x{1}.CONTENT)       
        NEOCASS.Engines1.Nacelle1.lateral_location     = str2num(engineModel.transformation{1}.translation{1}.y{1}.CONTENT);
        NEOCASS.Engines1.Nacelle1.vertical_location    = str2num(engineModel.transformation{1}.translation{1}.z{1}.CONTENT);
                                                                          
        NEOCASS.Engines1.Y_locale                      = NEOCASS.Engines1.Nacelle1.lateral_location     /NEOCASS.Wing1.Span*2;                                    
        NEOCASS.Engines1.X_locale                      = NEOCASS.Engines1.Nacelle1.longitudinal_location/NEOCASS.Fuselage.Total_fuselage_length;                                    
        NEOCASS.Engines1.Z_locale                      = NEOCASS.Engines1.Nacelle1.vertical_location    /NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter;
        
        TechGeoModel.iEngine{1}.dryMass   =str2num(engine.global{1}.dryMass{1}.CONTENT);
        TechGeoModel.iEngine{1}.Tmax      =str2num(engine.global{1}.thrust00{1}.CONTENT);
        TechGeoModel.iEngine{1}.dFan      =str2num(engine.global{1}.dFan{1}.CONTENT);
        TechGeoModel.iEngine{1}.FPR       =str2num(engine.global{1}.fpr00{1}.CONTENT);
        TechGeoModel.iEngine{1}.BPR       =str2num(engine.global{1}.bpr00{1}.CONTENT);
        TechGeoModel.iEngine{1}.OPR       =str2num(engine.global{1}.opr00{1}.CONTENT);
        TechGeoModel.iEngine{1}.X(1)      =str2num(engineModel.transformation{1}.translation{1}.x{1}.CONTENT);
        TechGeoModel.iEngine{1}.X(2)      =str2num(engineModel.transformation{1}.translation{1}.y{1}.CONTENT);
        TechGeoModel.iEngine{1}.X(3)      =str2num(engineModel.transformation{1}.translation{1}.z{1}.CONTENT);
        TechGeoModel.iEngine{1}.coGXloc(1)=str2num(engine.global{1}.coG{1}.x{1}.CONTENT);
        TechGeoModel.iEngine{1}.coGXloc(2)=str2num(engine.global{1}.coG{1}.y{1}.CONTENT);
        TechGeoModel.iEngine{1}.coGXloc(3)=str2num(engine.global{1}.coG{1}.z{1}.CONTENT);

%         %nacelle
%         ac.vehicles{1}.engines{1}.engine{2}.nacelle{1}.inlet{1}.position{1}.x{1}.CONTENT
%         ac.vehicles{1}.engines{1}.engine{2}.nacelle{1}.endPos{1}.x{1}.CONTENT
        disp('Generation of engine1 made by conversion')
        end
    catch 
        disp('Generation of engine1 made by default!')
        for kk=1
% 	present                              (1)         Flag 
        NEOCASS.Engines1.present=1;
%   Number_of_engines    
        NEOCASS.Engines1.Number_of_engines=2;
% 	Layout_and_config                    (0)         Flag 0)near wing                                                                        
% 	                                                      1)on-wing nacelle                                                                  
% 	                                                      2)on-wing integrated with udercarriage                                             
% 	                                                      3)aft-fuselage                                                                     
% 	                                                      4)straight duct                                                                    
% 	                                                      5)S-duct 
        NEOCASS.Engines1.Layout_and_config=0;
% 	Propulsion_type                      (0)         Flag 0)turbofan                                                                         
% 	                                                      1)turboprop tractor                                                                
% 	                                                      2)turboprop pusher                                                                 
% 	                                                      3)propfan 
        NEOCASS.Engines1.Propulsion_type=0;
% 	Nacelle_body_type                    (1)         Flag 0)short-ducted nacelle                                                             
% 	                                                      1)long-ducted nacelle                                                              
        NEOCASS.Engines1.Nacelle_body_type=1;
% 	symmetry                             (1)         Flag                                                                                    
        NEOCASS.Engines1.symmetry=1;
% 	Y_locale                             (0.39472)   wspn  % wing half span                                                                  
        NEOCASS.Engines1.Y_locale=0.39472;
% 	X_locale                             (0.3188)    fusin % fuselage vert diameter,wing root pos fig A4                                     
        NEOCASS.Engines1.X_locale=0.3188;
% 	Z_locale                             (0.0)       fusva % fuselage length, wing root LE        fig A5                                     
        NEOCASS.Engines1.Z_locale=0.0;
% 	fineness_ratio                       (2.3921)    >0    nacelle length divided by nac. max diameter                                       
        NEOCASS.Engines1.fineness_ratio=2.3921;
% 	d_max                                (2.3578)    [m]   nacelle max diameter                                                              
        NEOCASS.Engines1.d_max=2.3578;
% 	toe_in                               (0.0)       [deg] nacelle tow-in angle                   fig A13                                    
        NEOCASS.Engines1.toe_in=0;
% 	pitch                                (0.0)       [deg] nacelle pitch angle                    fig A14                                    
        NEOCASS.Engines1.pitch=0;
% 	Thrust_to_weight_ratio               (0.0)       []                                                                                      
        NEOCASS.Engines1.Thrust_to_weight_ratio=0;
% 	Propeller_diameter                   (1.98)      [m]   propeller diameter                                                                
        NEOCASS.Engines1.Propeller_diameter=1.98;
% 	Max_thrust                           (150.0)     [kN]                                                                                    
        NEOCASS.Engines1.Max_thrust=150;
% 	Bypass_ratio_to_emulate              (10.0)      []                                                                                      
        NEOCASS.Engines1.Bypass_ratio_to_emulate=10;
% 	Thrust_reverser_effectivness         (0)         []                                                                                      
        NEOCASS.Engines1.Thrust_reverser_effectivness =0;
% 	Fan_cowl_length_ratio                (70)        []    % nacelle length                                                                  
        NEOCASS.Engines1.Fan_cowl_length_ratio =70; 
%add        
        NEOCASS.Engines1.Nacelle_length_array= 3 * NEOCASS.Engines1.d_max;
        
        NEOCASS.Engines1.Nacelle1.longitudinal_location= 12;
        NEOCASS.Engines1.Nacelle1.vertical_location    =-2;
        NEOCASS.Engines1.Nacelle1.lateral_location     = 6;   
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Engines2
for k=1
% 	present                              (1)         Flag 
        NEOCASS.Engines2.present=0;
%   Number_of_engines    
        NEOCASS.Engines2.Number_of_engines=0;
% 	Layout_and_config                    (0)         Flag 0)near wing                                                                        
% 	                                                      1)on-wing nacelle                                                                  
% 	                                                      2)on-wing integrated with udercarriage                                             
% 	                                                      3)aft-fuselage                                                                     
% 	                                                      4)straight duct                                                                    
% 	                                                      5)S-duct 
        NEOCASS.Engines2.Layout_and_config=0;
% 	Propulsion_type                      (0)         Flag 0)turbofan                                                                         
% 	                                                      1)turboprop tractor                                                                
% 	                                                      2)turboprop pusher                                                                 
% 	                                                      3)propfan 
        NEOCASS.Engines2.Propulsion_type=0;
% 	Nacelle_body_type                    (1)         Flag 0)short-ducted nacelle                                                             
% 	                                                      1)long-ducted nacelle                                                              
        NEOCASS.Engines2.Nacelle_body_type=1;
% 	symmetry                             (1)         Flag                                                                                    
        NEOCASS.Engines2.symmetry=1;
% 	Y_locale                             (0.39472)   wspn  % wing half span                                                                  
        NEOCASS.Engines2.Y_locale=0.39472;
% 	X_locale                             (0.3188)    fusin % fuselage vert diameter,wing root pos fig A4                                     
        NEOCASS.Engines2.X_locale=0.3188;
% 	Z_locale                             (0.0)       fusva % fuselage length, wing root LE        fig A5                                     
        NEOCASS.Engines2.Z_locale=0.0;
% 	fineness_ratio                       (2.3921)    >0    nacelle length divided by nac. max diameter                                       
        NEOCASS.Engines2.fineness_ratio=2.3921;
% 	d_max                                (2.3578)    [m]   nacelle max diameter                                                              
        NEOCASS.Engines2.d_max=2.3578;
% 	toe_in                               (0.0)       [deg] nacelle tow-in angle                   fig A13                                    
        NEOCASS.Engines2.toe_in=0;
% 	pitch                                (0.0)       [deg] nacelle pitch angle                    fig A14                                    
        NEOCASS.Engines2.pitch=0;
% 	Thrust_to_weight_ratio               (0.0)       []                                                                                      
        NEOCASS.Engines2.Thrust_to_weight_ratio=0;
% 	Propeller_diameter                   (1.98)      [m]   propeller diameter                                                                
        NEOCASS.Engines2.Propeller_diameter=1.98;
% 	Max_thrust                           (150.0)     [kN]                                                                                    
        NEOCASS.Engines2.Max_thrust=150;
% 	Bypass_ratio_to_emulate              (10.0)      []                                                                                      
        NEOCASS.Engines2.Bypass_ratio_to_emulate=10;
% 	Thrust_reverser_effectivness         (0)         []                                                                                      
        NEOCASS.Engines2.Thrust_reverser_effectivness =0;
% 	Fan_cowl_length_ratio                (70)        []    % nacelle length                                                                  
        NEOCASS.Engines2.Fan_cowl_length_ratio =70; 
%add        
        NEOCASS.Engines2.Nacelle_length_array= 3 * NEOCASS.Engines1.d_max;
        
        NEOCASS.Engines2.Nacelle1.longitudinal_location= 12;
        NEOCASS.Engines2.Nacelle1.vertical_location    =-2;
        NEOCASS.Engines2.Nacelle1.lateral_location     = 6;
        
        NEOCASS.Engines2.Nacelle3.longitudinal_location= 12;
        NEOCASS.Engines2.Nacelle3.vertical_location    =-2;
        NEOCASS.Engines2.Nacelle3.lateral_location     = 6;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tailbooms
for k=1
    NEOCASS.Tailbooms.present=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% Fuel
for k=1
    %Maximum_fuel_in_wings                             [kg]
    NEOCASS.Fuel.Maximum_fuel_in_wings                = 10000;             
    %Maximum_fuel_in_auxiliary                         [kg]
    NEOCASS.Fuel.Maximum_fuel_in_auxiliary            =  2000;             
    %Maximum_fuel_in_central_wingbox                   [kg]
    NEOCASS.Fuel.Maximum_fuel_in_central_wingbox      =  4000;
    %Maximum_fuel_weight                               [kg]
    NEOCASS.Fuel.Maximum_fuel_weight                  = NEOCASS.Fuel.Maximum_fuel_in_wings + NEOCASS.Fuel.Maximum_fuel_in_auxiliary + NEOCASS.Fuel.Maximum_fuel_in_central_wingbox;           
    %Fuel_to_MTOW_at_maximum_payload                   [kg]
    NEOCASS.Fuel.Fuel_to_MTOW_at_maximum_payload      = 0.7 * NEOCASS.Fuel.Maximum_fuel_weight;             
	%Outboard_fuel_tank_span              (0.7)        [0-1] % wing semi-span 
    NEOCASS.Fuel.Outboard_fuel_tank_span              = 0.7;
	%Wing_fuel_tank_cutout_opt            (0.0)        Flag  0)continuos wing fuel tank
	%                                                        1)discontinuos wing fuel tank      fig A15  
    NEOCASS.Fuel.Wing_fuel_tank_cutout_opt            = 0.0;                                                        
	%Unusable_fuel_option                 (44.3)       [kg]
    NEOCASS.Fuel.Unusable_fuel_option                 = 44.3;
	%Assumed_fuel_density                 (0.809)      [%]   fuel_desity[kg/m^3]/1000 
    NEOCASS.Fuel.Assumed_fuel_density                 = 0.809; 
	%Incr_weight_for_wing_tanks           (0.0)        [%] 
    NEOCASS.Fuel.Incr_weight_for_wing_tanks           = 0.0;
	%Centre_tank_portion_used             (85.25)      [0-1] % wing semi-span
    NEOCASS.Fuel.Centre_tank_portion_used             = 85.25;
	%Increment_for_centre_tank            (0.0)        [%]
    NEOCASS.Fuel.Increment_for_centre_tank            = 0.0;
	%Fore_fairing_tank_length             (0.5)        [0-1] % fairing fore length
    NEOCASS.Fuel.Fore_fairing_tank_length             = 0.5;
	%Aft_fairing_tank_length              (0.5)        [0-1] % fairing aft length 
    NEOCASS.Fuel.Aft_fairing_tank_length              = 0.5;
	%Aft_fuse_bladder_length              (0.0)        [m]   length
    NEOCASS.Fuel.Aft_fuse_bladder_length              = 0.0;
	%Increment_for_aux_tanks              (0.0)        [%]  
    NEOCASS.Fuel.Increment_for_aux_tanks              = 0.0;
	%Aux_wing_spar_loc_root               (0.0)        [%]  
    NEOCASS.Fuel.Aux_wing_spar_loc_root               = 0.0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%% fuel
for k=1
    NEOCASS.fuel.Fore_wing_spar_loc_root   = 0.20;                 
    NEOCASS.fuel.Fore_wing_spar_loc_kik1   = 0.20;                 
    NEOCASS.fuel.Fore_wing_spar_loc_kin2   = 0.20;                 
    NEOCASS.fuel.Fore_wing_spar_loc_tip    = 0.20;                 
    NEOCASS.fuel.Aux_wing_spar_loc_root    = 0;                   
    NEOCASS.fuel.Aft_wing_spar_loc_root    = 0.6;                
    NEOCASS.fuel.Aft_wing_spar_loc_kin1    = 0.6;                
    NEOCASS.fuel.Aft_wing_spar_loc_kin2    = 0.6;                
    NEOCASS.fuel.Aft_wing_spar_loc_tip     = 0.6;                
    NEOCASS.fuel.Wing_fuel_tank_cutout_opt = 0;                   
    NEOCASS.fuel.Outboard_fuel_tank_span   = 0.7;                 
    NEOCASS.fuel.Unusable_fuel_option      = 44.309;              
    NEOCASS.fuel.Assumed_fuel_density      = 0.809;               
    NEOCASS.fuel.Incr_weight_for_wing_tanks= 0;                   
    NEOCASS.fuel.Centre_tank_portion_used  = 85.25;               
    NEOCASS.fuel.Increment_for_centre_tank = 0;                   
    NEOCASS.fuel.Fore_fairing_tank_length  = 0;                   
    NEOCASS.fuel.Aft_fairing_tank_length   = 0;                   
    NEOCASS.fuel.Aft_fuse_bladder_length   = 0;                   
    NEOCASS.fuel.Increment_for_aux_tanks   = 0;                   
    NEOCASS.fuel.max_weight_wing           = 138212.23452408;     
    NEOCASS.fuel.max_vol_wing              = 170843.30596302;     
    NEOCASS.fuel.max_weight_cent_wing_box  = 56836.921960506;     
    NEOCASS.fuel.max_vol_cent_wing_box     = 70255.774982084;     
    NEOCASS.fuel.max_weight_aux            = 0;                   
    NEOCASS.fuel.max_vol_aux               = 0;                   
    NEOCASS.fuel.box_ea_loc_root           = 0.4;                 
    NEOCASS.fuel.box_ea_loc_kink1          = 0.4;                 
    NEOCASS.fuel.box_ea_loc_kink2          = 0.4;                 
    NEOCASS.fuel.box_ea_loc_tip            = 0.4;                 
    NEOCASS.fuel.box_semispan_root         = 0.20;                
    NEOCASS.fuel.box_semispan_kink1        = 0.20;                
    NEOCASS.fuel.box_semispan_kink2        = 0.20;                
    NEOCASS.fuel.box_semispan_tip          = 0.20;                
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Baggage
for k=1
    %installation_type                    (0)          Flag  0)aft
	NEOCASS.Baggage.installation_type =0; 
	%gross_volume                         (0.5*defac.Fuselage.Total_fuselage_length*0.4*defac.Fuselage.Aftfuse_X_sect_vertical_diameter*0.6*defac.Fuselage.Aftfuse_X_sect_horizontal_diameter)                                                                                                                                                       1)under floor                                                                                                                                                                                                                                   
	NEOCASS.Baggage.gross_volume =         0.5*NEOCASS.Fuselage.Total_fuselage_length*0.4*NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter*0.6*NEOCASS.Fuselage.Aftfuse_X_sect_horizontal_diameter;                                                                                              
	%Baggage_combined_length              (0.5*defac.Fuselage.Total_fuselage_length)       
    NEOCASS.Baggage.Baggage_combined_length=0.5*NEOCASS.Fuselage.Total_fuselage_length;
    %Baggage_apex_per_fuselgt            (0.2)        [%]   % fuselage length
	NEOCASS.Baggage.Baggage_apex_per_fuselgt=0.2;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cabin
for k=1
	%Cabin_length_to_aft_cab              (defac.Fuselage.Total_fuselage_length-defac.Fuselage.Forefuse_Xs_distortion_coefficient*defac.Fuselage.Forefuse_X_sect_vertical_diameter-defac.Fuselage.Aftfuse_Xs_distortion_coefficient*defac.Fuselage.Aftfuse_X_sect_vertical_diameter)
	NEOCASS.cabin.Cabin_length_to_aft_cab= NEOCASS.Fuselage.Total_fuselage_length-NEOCASS.Fuselage.Forefuse_Xs_distortion_coefficient*NEOCASS.Fuselage.Forefuse_X_sect_vertical_diameter-NEOCASS.Fuselage.Aftfuse_Xs_distortion_coefficient*NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter;
    %Cabin_max_internal_height            (defac.Fuselage.Aftfuse_X_sect_vertical_diameter*0.6)   
    NEOCASS.cabin.Cabin_max_internal_height=NEOCASS.Fuselage.Aftfuse_X_sect_vertical_diameter*0.6;    
    %Cabin_max_internal_width             (defac.Fuselage.Aftfuse_X_sect_horizontal_diameter)
	NEOCASS.cabin.Cabin_max_internal_width=NEOCASS.Fuselage.Aftfuse_X_sect_horizontal_diameter; 
    %Cabin_floor_width                    (defac.Fuselage.Aftfuse_X_sect_horizontal_diameter) 
	NEOCASS.cabin.Cabin_floor_width=       NEOCASS.Fuselage.Aftfuse_X_sect_horizontal_diameter;
    %Cabin_volume                         (0.0)        [m^3] if zero will be automatically computed 
	NEOCASS.cabin.Cabin_volume  =          0.0; 
    %Cabin_attendant_number               (4)       
	NEOCASS.cabin.Cabin_attendant_number=  4;
    %Flight_crew_number                   (2)
	NEOCASS.cabin.Flight_crew_number =     2;  
    %Passenger_accomodation               (120)        []    n° of passengers
	NEOCASS.cabin.Passenger_accomodation = 120;  
    %Seats_abreast_in_fuselage            (6)          []    n° seats per row  
	NEOCASS.cabin.Seats_abreast_in_fuselage=6; 
    %Seat_pitch                           (0)           
	NEOCASS.cabin.Seat_pitch =             0;
    %Maximum_cabin_altitude               (8000.0)     [m]  (0)                                                                                                                                                                                                                                                    
	NEOCASS.cabin.Maximum_cabin_altitude = 8000.0; 
    %Max_pressure_differential            (0.0)        [Pa]
	NEOCASS.cabin.Max_pressure_differential=0.0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% miscellaneous
for k=1
	%Design_classification                (0)          Flag  <2 commercial transportation
	%                                                        =2 small business jet
	%                                                        >2 large business jet        
    NEOCASS.miscellaneous.Design_classification                = 0;         
	%Target_operating_ceiling             (350)        [FL]  ceiling in Flight Level( 1 FL = 100 ft)
    NEOCASS.miscellaneous.Target_operating_ceiling             = 350;
    %Spoiler_effectivity                  (100.0)      [%] 
	NEOCASS.miscellaneous.Spoiler_effectivity                  = 100.0;                                                                                                                                     
	%Undercarriage_layout                 (0)          [1--] >1 additional correction due to an on-wing nacelle undercarriage integration 
    NEOCASS.miscellaneous.Undercarriage_layout                 = 0;
	%main_landing_gear_on_fuselage        (0)          [%]
    NEOCASS.miscellaneous.main_landing_gear_on_fuselage        = 0; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% weight_balance   
for kkk=1  
    NEOCASS.weight_balance.flight_envelope_prediction.VD_Flight_envelope_dive=  200;
    %!!! NB COG B747 Neocass !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %      1     2    3        4         5         6         7         8      9 10 11 12 13 14 15 16    17         18        19       20    21      22       23       24       25     26 27    28  29     30                                                                                                         
    vCOG=[26.861 0   34.543   34.129    15.919    14.861    15.599    18.740  0  0  0  0  0  0  0  0    15.919     14.919    14.842    0    14.339   6.803   14.339   14.339   14.176  0 14.590 0  15.240  0,...
           0     0    0        0         0         0         6.166    12.470  0  0  0  0  0  0  0  0     0          0         0        0     0       0        0        0        0      0  0     0   0      0,...
          -1.708 0    1.348    3.971    -0.711    -1.708    -2.226    -1.878  0  0  0  0  0  0  0  0    -0.711     -1.153     0        0     0      -1.077   -1.077   -1.077    0.971  0 -1.085 0  -1.241  0,...
       52195.904 0 3575.962 1828.736 27891.904 15269.861 13313.640 13313.640  0  0  0  0  0  0  0  0 44985.779 115000     46000        0 22000     255      750    41004.988 4099.64   0  0     0   0      0,...
       zeros(1,1680)];
%     j=1; k=1; h=1;
%     for i=1:length(vCOG)
%         COG(j,h,k)=vCOG(i);
%         j=j+j;
%         if i==k*30
%             j=j+1;
%             k=1;
%             if j==4
%                 j=1;
%                 h=h+1;
%             end
%         end
%     end
    COG = reshape(vCOG, 30, 4, 15);
    NEOCASS.weight_balance.COG=COG; 
    
    NEOCASS.weight_balance.Imat = [20151738.964201 0                0               ;...
                                   0               31230658.249463  0               ;...
                                   0               0                48635443.067567];                     
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% loading
for k=1
    %normal_load_factor(2.5)                  []       normal load factor
    NEOCASS.user_input.loading.normal_load_factor=2.5; 
  %weight_fraction
    %cman            (0.97)                 []       % MTOW at maneuver
    NEOCASS.user_input.loading.weight_fraction.cman=0.97; 
    %cbum            (1)                    []       % MTOW at bum
    NEOCASS.user_input.loading.weight_fraction.cbum=1; 
    %clan            (0.791)                []       % MTOW at landing
    NEOCASS.user_input.loading.weight_fraction.clan =0.791;
  %aero_data 
    % Cn_dr           (-0.078155)            [rad^-1] aerodynamics derivatives
    NEOCASS.user_input.loading.aero_data.Cn_dr=-0.078155; 
    % Cl_dr           (0.011382)             [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.Cl_dr= 0.011382; 
    % Cn_dw           (0.0063635)            [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.Cn_dw= 0.0063635; 
    % Cl_dw           (0.046133)             [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.Cl_dw= 0.046133; 
    % Cn_b            (0.22218)              [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.Cn_b = 0.22218; 
    % Cl_b            (-0.17438)             [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.Cl_b = -0.17438; 
    % CY_b            (-1.0524)              [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.CY_b = -1.0524;   
    % CY_dr           (0.12054)              [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.CY_dr= 0.12054; 
    % CY_dw           (0)                    [rad^-1] ...
    NEOCASS.user_input.loading.aero_data.CY_dw =0;
    % L_alpha_s       (5972060.4843)         [N/rad]  Htail load due to alpha=1 [deg]
    NEOCASS.user_input.loading.aero_data.L_alpha_s=5972060.4843;  
    % M_alpha_s       (-25698772.5085)       [Nm/rad] Htail pitch moment due to alpha=1 [deg]
    NEOCASS.user_input.loading.aero_data.M_alpha_s=-25698772.5085;                                 
    % L_delta_e       (3669520.6164)         [N/rad]  Htail load due to delta_equilibrator=1 [deg]
    NEOCASS.user_input.loading.aero_data.L_delta_e=3669520.6164;
    % M_delta_e       (-19160023.6673)       [Nm/rad] Htail pitch moment due to delta_equilibrator=1 [deg] 
    NEOCASS.user_input.loading.aero_data.M_delta_e=-19160023.6673; 
    % L_alpha_sc      (5972060.4843)         [N/rad]  Canard load due to alpha=1 [deg]    
    NEOCASS.user_input.loading.aero_data.L_alpha_sc=5972060.4843; 
    % M_alpha_sc      (-25698772.5085)       [Nm/rad] Canard pitch moment due to alpha=1 [deg] 
    NEOCASS.user_input.loading.aero_data.M_alpha_sc=-25698772.5085; 
    % L_delta_ec      (3669520.6164)         [N/rad]  Canard load due to delta_equilibrator=1 [deg]  
    NEOCASS.user_input.loading.aero_data.L_delta_ec=3669520.6164; 
    % M_delta_ec      (-19160023.6673)       [Nm/rad] Canard pitch moment due to delta_equilibrator=1 [deg] 
    NEOCASS.user_input.loading.aero_data.M_delta_ec=-19160023.6673;
    % Lc              (7.9286e-10)           [N]      Htail load due to unit built-in chamber
    NEOCASS.user_input.loading.aero_data.Lc=7.9286e-10; 
    % Mc              (-4.6829e-09)          [Nm]     Htail pitch moment due to unit built-in chamber
    NEOCASS.user_input.loading.aero_data.Mc =-4.6829e-09; 
    % dM_025dalpha    (-498083357.4341)      []       Pitch Moment arround 25% mac
    NEOCASS.user_input.loading.aero_data.dM_025dalpha =-498083357.4341;
    % CL              (0.41968)              []       Lift coefficient 
    NEOCASS.user_input.loading.aero_data.CL=0.41968; 
    % CY_alpha        (3.4991)               [rad^-1] Side slip
    NEOCASS.user_input.loading.aero_data.CY_alpha=3.4991;
  %maximum deflection
    NEOCASS.user_input.loading.maximum_deflection.Rudder_limit_deflection        = 20;         
    NEOCASS.user_input.loading.maximum_deflection.Elevator_limit_deflection_up   = 20;     
    NEOCASS.user_input.loading.maximum_deflection.Elevator_limit_deflection_down =-20;  
    NEOCASS.user_input.loading.maximum_deflection.limit_tailplane_deflection_up  = 20;
    NEOCASS.user_input.loading.maximum_deflection.limit_tailplane_deflection_down=-20;
    NEOCASS.user_input.loading.maximum_deflection.CElevator_limit_deflection_up  = 20;
    NEOCASS.user_input.loading.maximum_deflection.CElevator_limit_deflection_down=-20;
    NEOCASS.user_input.loading.maximum_deflection.limit_canard_deflection_up     = 20;
    NEOCASS.user_input.loading.maximum_deflection.limit_canard_deflection_down   =-20;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% analysis_setup
for k=1
  %lift_distribution  
    %lift_distribution      (1)               Flag
    NEOCASS.user_input.analysis_setup.lift_distribution=1;
  %optimization 
    %optimization_smonoq    (0)               Flag
    NEOCASS.user_input.analysis_setup.optimization_smonoq=0; 
  %pressure_stabilization  
    %pressure_stabilization (0)               Flag
    NEOCASS.user_input.analysis_setup.pressure_stabilization=0; 
  %regression                               
    %analf                ('linear')        Type
    NEOCASS.user_input.analysis_setup.regression.analf='linear'; 
    %analw                ('linear')        Type
    NEOCASS.user_input.analysis_setup.regression.analw='linear';
    %analh                ('linear')        Type
    NEOCASS.user_input.analysis_setup.regression.analh='linear'; 
    %analc                ('linear')        Type
    NEOCASS.user_input.analysis_setup.regression.analc='linear';
    %analv                ('linear')        Type
    NEOCASS.user_input.analysis_setup.regression.analv='linear';
    %analw2               ('linear')        Type
    NEOCASS.user_input.analysis_setup.regression.analw2='linear';
  %beam_model                               
    %fuse                 (1)               Flag
    NEOCASS.user_input.analysis_setup.beam_model.fuse=1;
    %winr                 (1)               Flag
    NEOCASS.user_input.analysis_setup.beam_model.winr=1;
    %win2r                (1)               Flag
    NEOCASS.user_input.analysis_setup.beam_model.win2r=1;
    %vert                 (1)               Flag
    NEOCASS.user_input.analysis_setup.beam_model.vert=1;
    %horr                 (1)               Flag
    NEOCASS.user_input.analysis_setup.beam_model.horr=1;
    %canr                 (1)               Flag
    NEOCASS.user_input.analysis_setup.beam_model.canr=1;
    %symmXZ               (1)               Flag
    NEOCASS.user_input.analysis_setup.beam_model.symmXZ=1;
  %vlm_calculation 
    %htail                (1)               Flag
    NEOCASS.user_input.analysis_setup.vlm_calculation.htail=1; 
    %canard               (1)               Flag
    NEOCASS.user_input.analysis_setup.vlm_calculation.canard =1;
    %vtail                (1)               Flag
    NEOCASS.user_input.analysis_setup.vlm_calculation.vtail=1;
    %torsion_stiffness                        
    %wing                 (1)               Flag
    NEOCASS.user_input.analysis_setup.torsion_stiffness.wing=1;
    %vtail                (1)               Flag
    NEOCASS.user_input.analysis_setup.torsion_stiffness.vtail=1;
    %htail                (1)               Flag
    NEOCASS.user_input.analysis_setup.torsion_stiffness.htail=1;
    %canard               (1)               Flag
    NEOCASS.user_input.analysis_setup.torsion_stiffness.canard=1; 
    %wing2                (1)               Flag
    NEOCASS.user_input.analysis_setup.torsion_stiffness.wing2=1;
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% experienced_user_input  
for k=1
    % geometry                                 
    % guess                                  
    % wing                                 
    % inboard     (30)                   [] n° of nodes section
    NEOCASS.experienced_user_input.geometry.guess.wing.inboard  = 30;
    % midboard    (30)                   [] ...
    NEOCASS.experienced_user_input.geometry.guess.wing.midboard = 30;  
    % outboard    (30)                   [] ...
    NEOCASS.experienced_user_input.geometry.guess.wing.outboard = 30; 
    % wing2                                
    % inboard     (30)                   [] n° of nodes section
    NEOCASS.experienced_user_input.geometry.guess.wing2.inboard = 30; 
    % midboard    (30)                   [] ...   
    NEOCASS.experienced_user_input.geometry.guess.wing2.midboard= 30;
    % outboard    (30)                   [] ... 
    NEOCASS.experienced_user_input.geometry.guess.wing2.outboard= 30; 
    % fus           (50)    
    NEOCASS.experienced_user_input.geometry.guess.fus           = 50; 
    % vert                                 
    % inboard     (15)                   [] n° of nodes section
    NEOCASS.experienced_user_input.geometry.guess.vert.inboard  = 15;  
    % outboard    (15)                   [] ...
    NEOCASS.experienced_user_input.geometry.guess.vert.outboard = 15; 
    % hori                                 
    % outboard    (30)                   [] n° of nodes section
    NEOCASS.experienced_user_input.geometry.guess.hori.outboard = 30; 
    % inboard     (30)                   [] ...   
    NEOCASS.experienced_user_input.geometry.guess.hori.inboard  = 30;  
    % canard                               
    % outboard    (30)                   [] n° of nodes section
    NEOCASS.experienced_user_input.geometry.guess.canard.outboard= 30; 
    % inboard     (30)                   [] ... 
    NEOCASS.experienced_user_input.geometry.guess.canard.inboard = 30;   
% experienced_user_input                     
% material_property                        
    % wing                                   
    % tmgw           (0.000508)            [m] min thickness gage
    NEOCASS.experienced_user_input.material_property.wing.tmgw= 0.000508;  
    % effw           (0.656)               []  buckling efficiency web
    NEOCASS.experienced_user_input.material_property.wing.effw =0.656;
    % effc           (1.03)                []  buckling efficiency cover
    NEOCASS.experienced_user_input.material_property.wing.effc= 1.03;
    % cf             (6.25e-05)            []  Shanley's const for frame bending
    NEOCASS.experienced_user_input.material_property.wing.cf  = 6.25e-05;
    % fus                                        
    % ckf            (5.24)                []  frame stiffness coeff
    NEOCASS.experienced_user_input.material_property.fus.ckf = 5.24;
    % ec             (2.36)                []  power in apprx eq for buckling stability
    NEOCASS.experienced_user_input.material_property.fus.ec  = 2.36;
    % kgc            (0.368)               []  buckling coeff. for stiffer
    NEOCASS.experienced_user_input.material_property.fus.kgc = 0.368;
    % kgw            (0.505)               []  buckling coeff.
    NEOCASS.experienced_user_input.material_property.fus.kgw = 0.505;
    % tmg            (0.001397)            [m] min thickness gage
    NEOCASS.experienced_user_input.material_property.fus.tmg = 0.001397; 
    % vtail                                     
    % tmgw           (5.08e-05)            [m] min thickness gage
    NEOCASS.experienced_user_input.material_property.vtail.tmgw = 5.08e-05; 
    % htail                                      
    % tmgw           (0.000508)            [m] min thickness gage
    NEOCASS.experienced_user_input.material_property.htail.tmgw = 0.000508;
    % wing2                                      
    % tmgw           (0.000508)            [m] min thickness gage
    NEOCASS.experienced_user_input.material_property.wing2.tmgw = 0.000508; 
    % canard                                     
    % tmgw           (0.000508)            [m] min thickness gage
    NEOCASS.experienced_user_input.material_property.canard.tmgw= 0.000508;

% experienced_user_input
% loading
    % aero_data
    % q            (12349.846)    [Pa]   dynamic pressure
    NEOCASS.experienced_user_input.loading.aero_data.q =12349.846;
    % aero_data
    % V            (250.236)      [m/s]  speed
    NEOCASS.experienced_user_input.loading.aero_data.V =250.236;
    % flexibility
    % dalphas_dnz  (0)            []     flexibility due to nz
    NEOCASS.experienced_user_input.loading.flexibility.dalphas_dnz=0;
    % dalphas_dLt  (0)            []     flexibility due to Lt
    NEOCASS.experienced_user_input.loading.flexibility.dalphas_dLt   =0;
    % dalphas_dMt  (0)            []     flexibility due to Mt
    NEOCASS.experienced_user_input.loading.flexibility.dalphas_dMt =0;
    % dalphac_dnz  (0)            []     flexibility due to nz
    NEOCASS.experienced_user_input.loading.flexibility.dalphac_dnz =0;
    % dalphac_dLc  (0)            []     flexibility due to Lc
    NEOCASS.experienced_user_input.loading.flexibility.dalphac_dLc =0;
    % dalphac_dMc  (0)            []     flexibility due to Mc
    NEOCASS.experienced_user_input.loading.flexibility.dalphac_dMc =0;

    NEOCASS.experienced_user_input.analysis_setup.BESTFIT=1;            
    NEOCASS.experienced_user_input.analysis_setup.iload  =3; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ventral_fin
    NEOCASS.Ventral_fin=[]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% Wetted_areas
    NEOCASS.Wetted_areas=[];   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% flight_envelope_prediction
    NEOCASS.flight_envelope_prediction=[]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% stability
    NEOCASS.stability=[]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% Fairing1
    NEOCASS.Fairing1=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% Fairing2    
    NEOCASS.Fairing2=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% Sponson
    NEOCASS.Sponson=[];  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% designation    
    NEOCASS.designation=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% wing    
    NEOCASS.wing=[];                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Wetted_areas
for k=1
    NEOCASS.Wetted_areas.increment_fuselage_fairing=0;              
    NEOCASS.Wetted_areas.increment_wings           =0;              
    NEOCASS.Wetted_areas.increment_winglet         =0;              
    NEOCASS.Wetted_areas.increment_Vertical_tail   =0;              
    NEOCASS.Wetted_areas.increment_pylons          =0;              
    NEOCASS.Wetted_areas.increment_powerplant      =0;              
    NEOCASS.Wetted_areas.increment_Horizontal_tail =0;              
    NEOCASS.Wetted_areas.anciliary_final           =0;              
    NEOCASS.Wetted_areas.Total_wetted_area         =2330.3551220046;
    NEOCASS.Wetted_areas.Fuselage_fairing          =0;                %979.14316543689;
    NEOCASS.Wetted_areas.Wings                     =745.04073274565;
    NEOCASS.Wetted_areas.Winglet                   =0;              
    NEOCASS.Wetted_areas.Vertical_tail             =146.87054350459;
    NEOCASS.Wetted_areas.Dorsal_fin                =0;              
    NEOCASS.Wetted_areas.Horizontal_tail           =248.48839215365;
    NEOCASS.Wetted_areas.Pylons                    =32.010572434478;
    NEOCASS.Wetted_areas.Powerplant                =178.80171572939;
    NEOCASS.Wetted_areas.Canard                    =0;              
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NBBBBBBBBBBB
NEOCASS.Wetted_areas.Total_wetted_area=100;
NEOCASS.Fuselage.X_sect_chord_at_fuse_wing=4;
NEOCASS.Wing1.thickness_coefs_matrix=[ 1    1     1    1 ;...
                                       0.12 0.12 0.12 0.12];
NEOCASS.Fairing1.Forward_chord_fraction=0.5;
NEOCASS.Fairing1.Aft_chord_fraction=0.5;
NEOCASS.Fairing1.flushness=0.5;
 
NEOCASS.weight_balance.Ramp_increment=0;
NEOCASS.weight_balance.Weight_cont_allow_perc_of_MEW=.90;
NEOCASS.weight_balance.Manufacturer_weights_tolerance=0.05;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Convert *.mat 2 *.xml NEOCASS like and save
    % save current Path
        CpacsPath=cd     
    % NeocassPath       
        try 
            %Any run after the first
            fid=fopen(strcat(CpacsPath,'\NeocassPath.dat'),'r');            
            line=fgets(fid); NeocassPath=sscanf(line,'%s'); 
            fclose(fid); 
            cd(NeocassPath)
            %check if it's the right folder
            a=0; exist([NeocassPath,'\set_neocass_path.m'])
            while a==0
                if exist([NeocassPath,'\set_neocass_path.m'])==2
                    set_neocass_path
                    a=1;
                else
                    NeocassPath = uigetdir(NeocassPath,'Previous path is wrong or doesn''t exist anymore, find Neocass directory'); 
                    cd(NeocassPath)
                end
            end
            fid=fopen(strcat(CpacsPath,'\NeocassPath.dat'),'w');
            fprintf(fid,'%s',NeocassPath);
            fclose(fid);
                
        catch
            %At first run 
            NeocassPath = uigetdir(CpacsPath,'Find Neocass directory');            
            cd(NeocassPath)
            %check if it's the right folder
            a=0; exist([NeocassPath,'\set_neocass_path.m']);
            while a==0
                if exist([NeocassPath,'\set_neocass_path.m'])==2
                    %1
                    set_neocass_path
                    a=1;
                else
                    %2
                    NeocassPath = uigetdir(NeocassPath,'Previous path is wrong or doesn''t exist anymore, find Neocass directory'); 
                    cd(NeocassPath)
                end
            end
            fid=fopen(strcat(CpacsPath,'\NeocassPath.dat'),'w');
            fprintf(fid,'%s',NeocassPath);
            fclose(fid);        
        end
    % save Neocass.mat 
        [File,Path] = uiputfile('*.mat','Save WorkSpce NEOCASS, NB: save in Neocass\Example''s directory a dedicated Folder: ',[NeocassPath,'\prova']);       
        %Path='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\NeoCASS_Latest_Version_Patched\Examples\D150';
        %File='D150.mat';
        save(strcat(Path,File),'NEOCASS','-mat') 
    % Neocass 
        %addpath(NeocassPath)
        %set_neocass_path
        %which -all set_neocass_version %s=which('set_neocass_version','-all')  %if s>1 -->warning
        add_param = wb_struct_init();
%       input = mergestruct2(neocass_xmlwrapper(fname), add_param, handles.wb.flag);
        input = mergestruct2(NEOCASS, add_param, true);
        output=weight_xml(input); NEOCASS=output;
        save(strcat(Path,File),'NEOCASS','-mat') 
        neocass_xmlunwrapper([Path,File(1:end-4) '.xml'],output)
            
        
        cd(CpacsPath)
        
%% Add CoG to TechGeoModel
    %Wing1
    if NEOCASS.weight_balance.COG( 1, 4 ,1)~=0;
        TechGeoModel.iWing{1}.WB.mass =NEOCASS.weight_balance.COG( 1, 4 ,1);
        TechGeoModel.iWing{1}.WB.p_cm =NEOCASS.weight_balance.COG( 1,1:3,1);
    end
    %Wing2
    if NEOCASS.weight_balance.COG( 2, 4 ,1)~=0;
        TechGeoModel.iWing{5}.WB.mass =NEOCASS.weight_balance.COG( 2, 4 ,1);
        TechGeoModel.iWing{5}.WB.p_cm =NEOCASS.weight_balance.COG( 2,1:3,1);
    end
    %HorizontalTail
    if NEOCASS.weight_balance.COG( 3, 4 ,1)~=0;
        TechGeoModel.iWing{2}.WB.mass =NEOCASS.weight_balance.COG( 3, 4 ,1);
        TechGeoModel.iWing{2}.WB.p_cm =NEOCASS.weight_balance.COG( 3,1:3,1);
    end
    %VerticalTail
    if NEOCASS.weight_balance.COG( 4, 4 ,1)~=0;
        TechGeoModel.iWing{3}.WB.mass =NEOCASS.weight_balance.COG( 4, 4 ,1);
        TechGeoModel.iWing{3}.WB.p_cm =NEOCASS.weight_balance.COG( 4,1:3,1);
    end
    %Canard
    if NEOCASS.weight_balance.COG(11, 4 ,1)~=0;
        TechGeoModel.iWing{4}.WB.mass =NEOCASS.weight_balance.COG(11, 4 ,1);
        TechGeoModel.iWing{4}.WB.p_cm =NEOCASS.weight_balance.COG(11,1:3,1);
    end
    %VerticalTail2
    if NEOCASS.weight_balance.COG(10, 4 ,1)~=0;
        TechGeoModel.iWing{7}.WB.mass =NEOCASS.weight_balance.COG(10, 4 ,1);
        TechGeoModel.iWing{7}.WB.p_cm =NEOCASS.weight_balance.COG(10,1:3,1); 
    end
        
        
    %Fuselage
    if NEOCASS.weight_balance.COG( 5, 4 ,1)~=0;
        TechGeoModel.iFus{1}.WB.mass   =NEOCASS.weight_balance.COG( 5, 4 ,1);
        TechGeoModel.iFus{1}.WB.p_cm   =NEOCASS.weight_balance.COG( 5,1:3,1);
    end
    %TailBooms
    if NEOCASS.weight_balance.COG(12, 4 ,1)~=0;
        TechGeoModel.iFus{2}.WB.mass   =NEOCASS.weight_balance.COG(12, 4 ,1);
        TechGeoModel.iFus{2}.WB.p_cm   =NEOCASS.weight_balance.COG(12,1:3,1); 
    end        
    %AuxLangingGear
    if NEOCASS.weight_balance.COG( 9, 4 ,1)~=0;
        TechGeoModel.iLGear{1}.WB.mass =NEOCASS.weight_balance.COG(9, 4 ,1);
        TechGeoModel.iLGear{1}.WB.p_cm =NEOCASS.weight_balance.COG(9,1:3,1);
    end
    %MainLangingGear
    if NEOCASS.weight_balance.COG( 6, 4 ,1)~=0;
        TechGeoModel.iLGear{2}.WB.mass =NEOCASS.weight_balance.COG(6, 4 ,1);
        TechGeoModel.iLGear{2}.WB.p_cm =NEOCASS.weight_balance.COG(6,1:3,1);
    end
                   
    %Engine1
    if NEOCASS.weight_balance.COG( 7, 4 ,1)~=0;
        TechGeoModel.iEngine{1}.WB.mass=NEOCASS.weight_balance.COG(7, 4 ,1);
        TechGeoModel.iEngine{1}.WB.p_cm=NEOCASS.weight_balance.COG(7,1:3,1);
    end
    %Engine2
    if NEOCASS.weight_balance.COG( 8, 4 ,1)~=0;
        TechGeoModel.iEngine{2}.WB.mass=NEOCASS.weight_balance.COG(8, 4 ,1);
        TechGeoModel.iEngine{2}.WB.p_cm=NEOCASS.weight_balance.COG(8,1:3,1);
    end
    
    strCOG={'Wing1';...
           'Wing2';...
           'HTail';...
           'VTail';...
           'Fuselage';...
           'LGear';...
           'Engine1';...
           'Engine2';...
           'auxLGear';...
           'VT2';...
           'Canard';...
           'TailBooms';...
           '';...
           '';...
           '';...
           '';...
           'System';...
           'WingTanks';...
           'CentreWingTanks';...
           'auxTank';...
           'Interior';...
           'Pilots';...
           'Crew';...
           'Passengers';...
           'Baggage';...
           '';...
           'CG_at_MTOW_wrt_nose';...
           '';...
           'CG_at_MEW_wrt_nose';...
           ' '};
        
    for i=1:30     
        TechGeoModel.COGdata{i,1}=strCOG{i}; 
        TechGeoModel.COGdata{i,2}=NEOCASS.weight_balance.COG( i, 1 ,1); 
        TechGeoModel.COGdata{i,3}=NEOCASS.weight_balance.COG( i, 2 ,1); 
        TechGeoModel.COGdata{i,4}=NEOCASS.weight_balance.COG( i, 3 ,1); 
        TechGeoModel.COGdata{i,5}=NEOCASS.weight_balance.COG( i, 4 ,1); 
    end
    %TechGeoModel
           
    hold on
    for i=[1:12,17:25]        
        if NEOCASS.weight_balance.COG( i,4,1)~=0 && NEOCASS.weight_balance.COG( i, 1 ,1)<1.5*NEOCASS.Fuselage.Total_fuselage_length    
 
        handles.Tech.WB{i}=plot3(NEOCASS.weight_balance.COG( i, 1 ,1),...
                                 NEOCASS.weight_balance.COG( i, 2 ,1),...
                                 NEOCASS.weight_balance.COG( i, 3 ,1),...
                                 'o',...
                                 'MarkerSize',NEOCASS.weight_balance.COG( i,4,1)/1000,...
                                 'MarkerEdgeColor','k',...
                                 'MarkerFaceColor','b');
        else 
                disp(['Probable miscalculation in Cog position of component: ',num2str(i),' ',strCOG{i}])
                             
        end
        
    end
    
%     axis([0 1.5*NEOCASS.Fuselage.Total_fuselage_length,...
%           .75*NEOCASS.Fuselage.Total_fuselage_length .75*NEOCASS.Fuselage.Total_fuselage_length,...
%           .75*NEOCASS.Fuselage.Total_fuselage_length .75*NEOCASS.Fuselage.Total_fuselage_length])
end
        
    
    













