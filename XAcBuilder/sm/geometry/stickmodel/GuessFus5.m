%GuessWing
function GuessFus5(fusID,component,mir)

global TechGeoModel Guess %wingID
global CID      GID    MID    EID                      PID            SID 
global cord2rID gridID mat1ID cbarID caero1ID caerobID pbarID paeroID set1ID intgrID spline1ID  

% close all, clear all, clc
% addpath('NastanWriter');
% addpath('GuessWriter');
% %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_TechGeoModel.mat';
% %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150 for CPACS 1.3_TechGeoModel.mat';
% str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_BracedWing_TechGeoModel.mat';
% figure(1), hold on, axis equal
% load(str)
% %load('..\Guess.mat')
% fusID  = 2; mir=0; component=2;
%  
% 0.Inizializating
    for kkkk=1
    %Global number
    Npos=length(TechGeoModel.iFus{fusID}.Geometry.sectID(:,1));
    
    if mir        
        if TechGeoModel.iFus{fusID}.symmetry~=0    
            if     strcmp(TechGeoModel.iFus{fusID}.symmetry,'x-z-plane'), symm(1)= 1; symm(2)=-1; symm(3)= 1; 
            elseif strcmp(TechGeoModel.iFus{fusID}.symmetry,'y-z-plane'), symm(1)=-1; symm(2)= 1; symm(3)= 1; 
            elseif strcmp(TechGeoModel.iFus{fusID}.symmetry,'x-y-plane'), symm(1)= 1; symm(2)= 1; symm(3)=-1;                                 
            end               
            FileOpt='a';
            mat1ID=0;
            Guess.iFus{fusID}.Symm=1;
            gridID=length(Guess.iFus{fusID}.GRID);        
            pbarID=length(Guess.iFus{fusID}.PBAR);    
            cbarID=length(Guess.iFus{fusID}.CBAR);
            set1ID=length(Guess.iFus{fusID}.SET1);
            %cord2rIDlength(Guess.iFus{fusID}.);
            rbe0ID=length(Guess.iFus{fusID}.RBE0);

            %caero1ID=length(Guess.iFus{fusID}.GRID);
            paeroID  =1;
            %spline1ID=length(Guess.iFus{fusID}.SPLINE1);
            caerobID =length(Guess.iFus{fusID}.CAEROB);
            
            CID=1000*component+500; 
            GID=1000*component+500; 
            MID=1000*component; 
            EID=1000*component+500; EIDaero=EID+100; 
            PID=1000*component+500; 
            SID=1000*component+500;                        
        end
    else        
        symm(1)= 1; symm(2)=1; symm(3)= 1; 
        FileOpt='w';
        Guess.iFus{fusID}.Symm=0;
        mat1ID  = 0;
        gridID  = 0;        
        pbarID  = 0;    
        cbarID  = 0;
        set1ID  = 0;
        cord2rID= 0;
        rbe0ID  = 0;

        caero1ID= 0;
        paeroID = 1;
        spline1ID=0;
        caerobID= 0;
        CID=1000*component; 
        GID=1000*component; 
        MID=1000*component; 
        EID=1000*component; EIDaero=EID+100; 
        PID=1000*component; 
        SID=1000*component;
    end
    GIDint=GID+200;
    EIDint=EID;
    
    BeamPoint.xBeam=symm(1)*TechGeoModel.iFus{fusID}.beamModel.xBeam;
    BeamPoint.yBeam=symm(2)*TechGeoModel.iFus{fusID}.beamModel.yBeam;
    BeamPoint.zBeam=symm(3)*TechGeoModel.iFus{fusID}.beamModel.zBeam;
    
    for i=1:Npos            
        % Extraction of fuselage profile
        [~, ival]=max(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,3));   for j=1:3, upperFus(i,j) =symm(j)*TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,j); end                                    
        [~, ival]=min(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,3));   for j=1:3, lowerFus(i,j) =symm(j)*TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,j); end
        [~, ival]=max(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,2));   for j=1:3, side_FusR(i,j)=symm(j)*TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,j); end
        [~, ival]=min(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,2));   for j=1:3, side_FusL(i,j)=symm(j)*TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,j); end
    end
    end         
%% 1.Beam model
    fid= fopen(['Guess_Struct_fus',num2str(fusID),'.dat'],FileOpt);
    for kkkk=1    
    % 1.1.Material
        for kk=1
            mat1ID=mat1ID+1;   
            MID=MID+1;
            MID2mat1IDs(MID)=mat1ID;
            if mir==0
            

            MAT1.MID = MID;
            MAT1.E   = 7.1e10;
            MAT1.G   = '';
            MAT1.NU  = 0.33;
            MAT1.RHO = 2810;
            MAT1.A   = '';
            MAT1.TREF= '';
            MAT1.GE  = '';
            MAT1.ST  = '';
            MAT1.SC  = '';
            MAT1.SS  = '';
            MAT1.MCSID='';
            Guess.iFus{fusID}.MAT1(mat1ID)=MAT1;
            %Guess.iFus{fusID}.mat1IDs=[Guess.iFus{fusID}.mat1IDs matID];
            fprintf(fid,['$Material for wing ',num2str(fusID),'\n']);
            MAT1writer(fid,MAT1);
            end
        end 
%BeamPoint=TechGeoModel.iFus{fusID}.beamModel;%.Grid;      
        Npoint=length(BeamPoint.xBeam);
    % 1.2.Merge points with same components 
        h=0;
        for i=1:Npoint
            if i==1
                h=h+1;
                XBeam(h,:)=[BeamPoint.xBeam(i) BeamPoint.yBeam(i) BeamPoint.zBeam(i)];    
            elseif BeamPoint.xBeam(i)~=XBeam(h,1) || BeamPoint.yBeam(i)~=XBeam(h,2) || BeamPoint.zBeam(i)~=XBeam(h,3)
                h=h+1;
                XBeam(h,:)=[BeamPoint.xBeam(i) BeamPoint.yBeam(i) BeamPoint.zBeam(i)];
            end
        end
        Ngrid=length(XBeam);    
    % 1.3.Generation of geometrical info for Beam elem
        BeamPVect  =posVectFun(1,1,XBeam,[0 0 0]');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        BeamPVect.t(end,:)=[1 0 0];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         for i=1:Npos
%              
%             %Extraction of fuselage profile
%             [~, ival]=max(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,3));   upperFus(i,:) =TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:); 
%             [~, ival]=min(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,3));   lowerFus(i,:) =TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:);
%             [~, ival]=max(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,2));   side_FusR(i,:)=TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:);
%             [~, ival]=min(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,2));   side_FusL(i,:)=TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:);
%         end
          UpperFus =posVectFun(1,1,upperFus,[0 0 0]');   
          LowerFus =posVectFun(1,1,lowerFus,[0 0 0]');   
          Side_FusR=posVectFun(1,1,side_FusR,[0 0 0]');  
          Side_FusL=posVectFun(1,1,side_FusL,[0 0 0]');  
          UpperFus.pnt0
        j=1; jj=1; h=1; hh=1; 
        for i=1:Ngrid
        %Upper Fus point
            t=1.5;
            while j<length(UpperFus.pnt0(:,1)) && t>1              
                j
                
                if j<1  % *************
                    j=1; % *************
                end     % *************
                
                [C,t]=myIntersectLinePlane(UpperFus.pnt0(j,:)',UpperFus.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && j<length(UpperFus.pnt0(:,1))
                    j=j+1;
                elseif t<0 && j<length(UpperFus.pnt0(:,1))
                    j=j-1;
                end
            end
            UpperFus.pnt0
            if j==length(UpperFus.pnt0(:,1)), j=j-1; end
            
            i                                            % Aggiunto
            UpperFusoliera=UpperFus.pnt0                 % Aggiunto
            
            if j<1 % *********
               j=1; % *********
            end    % *********
            
            [C,t]=myIntersectLinePlane(UpperFus.pnt0(j,:)',UpperFus.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
            UpperFusPnt(i,:)=C';
        %Lower Fus point
            t=1.5;
            while jj<length(LowerFus.pnt0(:,1)) && t>1
                jj;
                [C,t]=myIntersectLinePlane(LowerFus.pnt0(jj,:)',LowerFus.pnt0(jj+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && jj<length(LowerFus.pnt0(:,1))
                    jj=jj+1;
                elseif t<0 && jj<length(LowerFus.pnt0(:,1))
                    jj=jj-1;
                end
            end
            jj;
            if jj==length(LowerFus.pnt0(:,1)), jj=jj-1; 
            elseif jj==0, jj=1; 
            end
            [C,t]=myIntersectLinePlane(LowerFus.pnt0(jj,:)',LowerFus.pnt0(jj+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
            LowerFusPnt(i,:)=C';    
            
        %Right side Fuselage point
            t=1.5;
            while h<length(Side_FusR.pnt0(:,1)) && t>1
                h;
                
                if h<1 % *********
                  h=1; % *********
                end    % *********
                
                [C,t]=myIntersectLinePlane(Side_FusR.pnt0(h,:)',Side_FusR.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && h<length(Side_FusR.pnt0(:,1))
                    h=h+1;
                elseif t<0 && h<length(Side_FusR.pnt0(:,1))
                    h=h-1;
                end
            end
            if h>=length(Side_FusR.pnt0(:,1)), h=length(Side_FusR.pnt0(:,1))-1; end
            
            FusolieraLaterale=Side_FusR.pnt0 % Aggiunto
            
                if h<1 % *********
                  h=1; % *********
                end    % *********
            
            [C,t]=myIntersectLinePlane(Side_FusR.pnt0(h,:)',Side_FusR.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
            RSidePnt(i,:)=C';
        %Left side Fuselage point
            t=1.5;
            while hh<length(Side_FusL.pnt0(:,1)) && t>1
                hh;
                [C,t]=myIntersectLinePlane(Side_FusL.pnt0(hh,:)',Side_FusL.pnt0(hh+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && hh<length(Side_FusL.pnt0(:,1))
                    hh=hh+1;
                elseif t<0 && hh<length(Side_FusL.pnt0(:,1))
                    hh=hh-1;
                end
            end
            if hh>=length(Side_FusR.pnt0(:,1)), hh=length(Side_FusR.pnt0(:,1))-1; end
            [C,t]=myIntersectLinePlane(Side_FusL.pnt0(hh,:)',Side_FusL.pnt0(hh+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
            LSidePnt(i,:)=C';    
        %Width Structure Box    
            Width(i)=norm(RSidePnt(i,:)' -LSidePnt(i,:)');            
            Height(i)=norm(UpperFusPnt(i,:)' -LowerFusPnt(i,:)');
            if norm(UpperFusPnt(i,:)'-LowerFusPnt(i,:)')>0.01
                w_struct(i,:)=(UpperFusPnt(i,:)'-LowerFusPnt(i,:)')'/norm(UpperFusPnt(i,:)'-LowerFusPnt(i,:)');
            else
                w_struct(i,:)=[1 0 0];
            end
            meanR(i)=(Width(i)+Height(i))/4;
        end   

    % 1.4.Weight control
        Mass=1000; toll=1e-3;
        M=0; iter=1;
        t=0.002; 
        while iter<100            
            for i=1:Ngrid-1
                a=(Width(i)  + Width(i+1))/2;
                b=(Height(i)  +Height(i+1))/2;
                Vi(i)=(a*b-(a-2*t)*(b-2*t))*BeamPVect.li(i+1);
                mi(i)=Vi(i)*Guess.iFus{fusID}.MAT1(1).RHO;
            end
            V=sum(Vi);
            M=sum(mi); 
%             figure(10),hold on
%             plot(iter,M,'o')
            if iter==1
                t=Mass/M*t;                
            else
                if M<Mass-toll || M>Mass+toll                   
                    t=t*(1+(Mass-M)/Mass);
                elseif M>=Mass-toll && M<Mass+toll
                    break
                end
            end
            iter=iter+1;           
        end
        %M,t,iter, 
        disp(['Mass achieved ',num2str(M),' kg, in ',num2str(iter),' iteration']);
        figure(1)       
    % 1.5.Bar model function
        bar_modelFun(fid,fusID,XBeam,Width,Height,t,w_struct,BeamPVect)         
    % 1.6.Interface Grids
        %GID=GIDint+200
        Ngrid=length(XBeam);
        for i=1:Ngrid 
            GID=GID+1; gridID=gridID+1;
            %GridIDs_WingBeamInt(i)=GID; %save bar's Grid IDs

            GRID.ID   = GID;
            GRID.CP   = 0;%coordID;
            GRID.Xi(1)= LSidePnt(i,1);
            GRID.Xi(2)= LSidePnt(i,2);
            GRID.Xi(3)= LSidePnt(i,3);
            GRID.CD   = 0;%coordID;

            Guess.iFus{fusID}.GRID(gridID)=GRID;
            Guess.iFus{fusID}.GID2gridIDs(GID)=gridID;
 
            plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',3)
            %%%
            GID=GID+1; gridID=gridID+1;
            %GridIDs_WingBeamInt(i)=GID; %save bar's Grid IDs

            GRID.ID   = GID;
            GRID.CP   = 0;%coordID;
            GRID.Xi(1)= RSidePnt(i,1);
            GRID.Xi(2)= RSidePnt(i,2);
            GRID.Xi(3)= RSidePnt(i,3);
            GRID.CD   = 0;%coordID;

            Guess.iFus{fusID}.GRID(gridID)=GRID;
            Guess.iFus{fusID}.GID2gridIDs(GID)=gridID;
 
            plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',3)
            %%%
            GID=GID+1; gridID=gridID+1;
            %GridIDs_WingBeamInt(i)=GID; %save bar's Grid IDs

            GRID.ID   = GID;
            GRID.CP   = 0;%coordID;
            GRID.Xi(1)= UpperFusPnt(i,1);
            GRID.Xi(2)= UpperFusPnt(i,2);
            GRID.Xi(3)= UpperFusPnt(i,3);
            GRID.CD   = 0;%coordID;

            Guess.iFus{fusID}.GRID(gridID)=GRID;
            Guess.iFus{fusID}.GID2gridIDs(GID)=gridID;
 
            plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',3)
            %%%
            GID=GID+1; gridID=gridID+1;
            %GridIDs_WingBeamInt(i)=GID; %save bar's Grid IDs

            GRID.ID   = GID;
            GRID.CP   = 0;%coordID;
            GRID.Xi(1)= LowerFusPnt(i,1);
            GRID.Xi(2)= LowerFusPnt(i,2);
            GRID.Xi(3)= LowerFusPnt(i,3);
            GRID.CD   = 0;%coordID;

            Guess.iFus{fusID}.GRID(gridID)=GRID;
            Guess.iFus{fusID}.GID2gridIDs(GID)=gridID;
 
            plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',1)
            %%%
            rbe0ID=rbe0ID+1;
            EIDint=EIDint+1;%-(component*1000+mir*500);
            RBE0.ID    = EIDint;
            RBE0.GM= EIDint;
            RBE0.GSi= [GID-3:GID];
            Guess.iFus{fusID}.RBE0(rbe0ID)=RBE0;
%             %Guess.iFus{fusID}.EID2eIDs(EID)=rbe0ID;
                 RBE0writerG(fid,Guess.iFus{fusID}.RBE0(rbe0ID))
%             for ind=1:4
%                 %eID=EIDint-(component*1000+mir*500);
%                 rbe0ID
%                 plot3([Guess.iFus{fusID}.GRID(Guess.iFus{fusID}.RBE0(rbe0ID).ID-component*1000).Xi(1) Guess.iFus{fusID}.GRID(Guess.iFus{fusID}.RBE0(rbe0ID).GSi(ind)-component*1000).Xi(1)],...
%                       [Guess.iFus{fusID}.GRID(Guess.iFus{fusID}.RBE0(rbe0ID).ID-component*1000).Xi(2) Guess.iFus{fusID}.GRID(Guess.iFus{fusID}.RBE0(rbe0ID).GSi(ind)-component*1000).Xi(2)],...
%                       [Guess.iFus{fusID}.GRID(Guess.iFus{fusID}.RBE0(rbe0ID).ID-component*1000).Xi(3) Guess.iFus{fusID}.GRID(Guess.iFus{fusID}.RBE0(rbe0ID).GSi(ind)-component*1000).Xi(3)],'g')
%             end
        end
    % 1.6.Grid Beam writing 
        fprintf(fid,'$Wing Grid\n');
        for i=1:length(Guess.iFus{fusID}.GRID)
            GRIDwriter(fid,Guess.iFus{fusID}.GRID(i));
        end     
    fclose(fid);
%% 2.Aerodynamic Mesh Generator
    EID=EIDaero; SID=EIDaero;
    fid= fopen(['Guess_AeroPan_fus',num2str(fusID),'.dat'],FileOpt);
    for kkkk=1
        %     fprintf(fid,'%8s%8d\n','PAERO1  ',1);
        fprintf(fid,'$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n'); 
        for i=1:Npos
         meanY_i(i)=(side_FusR(i,2)+ side_FusL(i,2))./2;
         meanZ_i(i)=(upperFus(i,3) + lowerFus(i,3))./2;
         %meanR_i

        end
        meanY=mean(meanY_i);
        meanZ=mean(meanZ_i);
        CID=CID+1; cord2rID=cord2rID+1;
        CORD2R.CID = CID;
        CORD2R.RID = 0;
        CORD2R.Ai  = [upperFus(1,1)  ,meanY,meanZ  ];
        CORD2R.Bi  = [upperFus(1,1)  ,meanY,meanZ+1];
        CORD2R.Ci  = [upperFus(1,1)+1,meanY,meanZ+1];
        %Save data & write Card
        Guess.iFus{fusID}.CORD2R(cord2rID)=CORD2R;
        Guess.iFus{fusID}.CID2cord2rIDs(CID)=cord2rID;
        fprintf(fid,'$Coordinates System for Aerodynamic Body\n');
            CORD2Rwriter(fid,CORD2R);

        EID=1;  caerobID=caerobID+1;    
        CAEROB.ID=fusID+mir*(50+fusID); 
        CAEROB.OX=CORD2R.Ai(1);
        CAEROB.OY=CORD2R.Ai(2);
        CAEROB.OZ=CORD2R.Ai(3);
        CAEROB.CID=CID;
        CAEROB.LEN=upperFus(end,1)-upperFus(1,1);
        CAEROB.NP=Ngrid;
        for i=1:Ngrid
            CAEROB.ISETxsi(i)=(XBeam(i)-XBeam(1))/CAEROB.LEN;
            CAEROB.ISET_R(i)=meanR(i);
        end
        Guess.iFus{fusID}.CAEROB(caerobID)=CAEROB;
        Guess.iFus{fusID}.EID2caerobIDs(EID)=caerobID;
        fprintf(fid,'$Aerodynamic Body\n');
            CAEROBwriterG(fid,CAEROB);
            
%         EID=EIDaero; SID=EIDaero;    
%         SPLINE1.EID  =EID;
%         SPLINE1.CAERO=CAERO1.EID;
%         SPLINE1.BOX1 =CAERO1.Boxes(1);
%         SPLINE1.BOX2 =CAERO1.Boxes(2);
%         SPLINE1.SETG =EID; %SID
%     %Save data & write Card
%         spline1ID=caero1ID;
%         Guess.iWing{wingID}.SPLINE1(spline1ID)=SPLINE1;
%         Guess.iWing{wingID}.EID2spline1IDs(EID)=spline1ID;
%         %Guess.iWing{wingID}.spline1IDs=[Guess.iWing{wingID}.spline1IDs elemID];
%         fprintf(fid,'$Spline interface Aerodynamic - Structure\n');    
%             SPLINE1writer(fid,SPLINE1); 
    end
    fclose(fid); 
%% 3.Save Data    
    %save('Guess.mat','Guess')
     
    end
end
%% Structure model generator
function bar_modelFun(fid,fusID,XBeam,Width,Height,Thick,w_struct,BeamPVect)
global Guess %TechGeoModel  fusID
global CID      GID    MID    EID             PID            SID 
global cord2rID gridID mat1ID cbarID caero1ID pbarID paeroID set1ID intgrID spline1ID
%% 1.Beam Wing Model
    %1.1.Grid
    %fprintf(fid,'$Grid for wing\n');
    Ngrid=length(XBeam);
    for i=1:Ngrid    
        GID=GID+1; gridID=gridID+1;
        GridIDs_WingBeam(i)=GID; %save bar's Grid IDs

        GRID.ID   = GID;
        GRID.CP   = 0;%coordID;
        GRID.Xi(1)= XBeam(i,1);
        GRID.Xi(2)= XBeam(i,2);
        GRID.Xi(3)= XBeam(i,3);
        GRID.CD   = 0;%coordID;

        Guess.iFus{fusID}.GRID(gridID)=GRID;
        Guess.iFus{fusID}.GID2gridIDs(GID)=gridID;
%            Guess.iFus{fusID}.gridStructIDs=[Guess.iFus{fusID}.gridStructIDs gridID];
        %fprintf(fid,'$Grid Wing\n');
        %GRIDwriter(fid,GRID(gridID));

        plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',3)
    end
 
    %1.2.Bar Property & Element
    for i=1:Ngrid-1
        %Property
        PID=PID+1;
        pbarID=pbarID+1;
        Guess.iFus{fusID}.PID2pbarIDs(PID)=pbarID;
        %propID=1;
        a=(Width(i) +Width(i+1))/2;
        b=(Height(i)+Height(i+1))/2;
        t1=Thick;
        t2=Thick;
        PBAR.PID = PID;                                              
        PBAR.MID = MID;                               
        PBAR.A   = a*b-(a-2*t2)*(b-2*t1);               
        PBAR.I1  = a*b^3/12-(a-2*t2)*(b-2*t1)^3/12;     
        PBAR.I2  = a^3*b/12-(a-2*t2)^3*(b-2*t1)/12;     
        PBAR.I12 = 0;                                   
        PBAR.J   = (PBAR.I1+PBAR.I2)/2;               
        PBAR.NSM = 0;                                   
%         PBAR.C1  = b/2;                              
%         PBAR.C2  = a/2;                                 
%         PBAR.D1  =-b/2;                                 
%         PBAR.D2  = a/2;                                 
%         PBAR.E1  =-b/2;                                 
%         PBAR.E2  =-a/2;                                 
%         PBAR.F1  = b/2;                                 
%         PBAR.F2  =-a/2;  
        PBAR.C1  = b/2;                              
        PBAR.C2  =  0 ;                                 
        PBAR.D1  =  0 ;                                 
        PBAR.D2  = a/2;                                 
        PBAR.E1  =-b/2;                                 
        PBAR.E2  =  0 ;                                 
        PBAR.F1  =  0 ;                                 
        PBAR.F2  =-a/2; 

        Guess.iFus{fusID}.PBAR(pbarID)=PBAR;
            PBARwriter(fid,PBAR);

    %1.3.Cbar element
        EID=EID+1;
        cbarID=cbarID+1;
        Guess.iFus{fusID}.EID2cbarIDs(EID)=cbarID;

        CBAR.EID   = EID; 
        CBAR.PID   = PID; 
        CBAR.GA    = GridIDs_WingBeam(i);
        CBAR.GB    = GridIDs_WingBeam(i+1);

        CBAR.u     = BeamPVect.t(i,:);
        CBAR.v     = -cross(CBAR.u,w_struct(i,:)')/norm(cross(CBAR.u,w_struct(i,:)'));
        CBAR.Xi(1) = CBAR.v(1);
        CBAR.Xi(2) = CBAR.v(2);
        CBAR.Xi(3) = CBAR.v(3);

        Guess.iFus{fusID}.CBAR(cbarID)=CBAR;
        % fprintf(fid,'$Wing''s cbar elem \n'); 
            CBARwriter(fid,CBAR);

        CBAREIDs_WingBeam(i)=EID;
    end

    %1.4.Save Grids in a Set
        SID=SID+1;
        set1ID=set1ID+1;
        Guess.iFus{fusID}.SID2set1IDs(SID)=set1ID;

        SET1.SID=SID; 
        SET1.IDs=GridIDs_WingBeam; 
        Guess.iFus{fusID}.GridIDs_WingBeam=GridIDs_WingBeam;

        Guess.iFus{fusID}.SET1(set1ID)=SET1;
        %Guess.iFus{fusID}.set1IDs=[Guess.iFus{fusID}.set1IDs setID];
        fprintf(fid,'$Set Grid Wing\n'); 
        
%%%%%%  SET1writer(fid,SET1(set1ID));    
        SET1writer(fid,SET1); 
    %1.5.Save CBAR IDs in a SET1
        SID=SID+1;
        set1ID=set1ID+1;
        Guess.iFus{fusID}.SID2set1IDs(SID)=set1ID;

        SET1.SID=SID; 
        SET1.IDs=CBAREIDs_WingBeam;

        Guess.iFus{fusID}.SET1(set1ID)=SET1;
        %Guess.iFus{fusID}.set1IDs=[Guess.iFus{fusID}.set1IDs setID];
        fprintf(fid,'$Wing''s Wing CBAR elem IDs \n'); 
            SET1writer(fid,SET1);         
    
end
