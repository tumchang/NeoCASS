%GuessWing
function GuessFus2(fusID,component)

global TechGeoModel Guess %wingID
global CID      GID    MID    EID                      PID            SID 
global cord2rID gridID mat1ID cbarID caero1ID caerobID pbarID paeroID set1ID intgrID spline1ID  

CID=1000*component; 
GID=1000*component; 
MID=1000*component; 
EID=1000*component; EIDaero=EID*10; 
PID=1000*component; 
SID=1000*component;
figure(1), hold on, axis equal

% close all, clear all, clc
%addpath('NastanWriter');
%addpath('GuessWriter');
% str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_TechGeoModel.mat';
% %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150 for CPACS 1.3_TechGeoModel.mat';
% 
% load(str)
% fusID  = 1;
 
%% 0.Inizializating        
    %Global index
%     CID=100;
%     MID=100;
%     GID=100;        
%     PID=100;
%     EID=100;  EIDaero=EID*10;
%     SID=100;
    
    %Card index
    mat1ID=0;
    gridID=0;        
    pbarID=0;    
    cbarID=0;
    set1ID=0;
    cord2rID=0;

    caero1ID=0;
    paeroID =1;
    spline1ID=0;
    caerobID=0;
%         
%         
%     %global ID 2 card ID
%     Guess.iFus{fusID}.MID2mat1IDs=[]; 
%     Guess.iFus{fusID}.GID2gridIDs=[]; 
%     Guess.iFus{fusID}.SID2set1IDs=[];
%     Guess.iFus{fusID}.PID2pbarIDs=[];
%     Guess.iFus{fusID}.EID2cbarIDs=[];
% 
%     Guess.iFus{fusID}.EID2caero1IDs=[];
%     Guess.iFus{fusID}.EID2spline1IDs=[];
%     Guess.iFus{fusID}.EID2caerobIDs=[];
        
    %Global number
    Npos=length(TechGeoModel.iFus{fusID}.Geometry.sectID(:,1));
    
%% 1.Beam model
    fid= fopen(['Guess_Struct_fus',num2str(fusID),'.dat'],'w');
    for kkkk=1    
    % 1.1.Material
        for kk=1
            mat1ID=mat1ID+1;   
            MID=MID+1;
            MID2mat1IDs(MID)=mat1ID;

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
        BeamPoint=TechGeoModel.iFus{fusID}.beamModel;%.Grid;
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
        BeamPVect.t(end,:)=[0 1 0];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:Npos
             
            %Extraction of fuselage profile
            [~, ival]=max(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,3));   upperFus(i,:) =TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:); 
            [~, ival]=min(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,3));   lowerFus(i,:) =TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:);
            [~, ival]=max(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,2));   side_FusR(i,:)=TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:);
            [~, ival]=min(TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(:,2));   side_FusL(i,:)=TechGeoModel.iFus{fusID}.Geometry.prof_fus(i).pnt_pos(ival,:);
        end
          UpperFus =posVectFun(1,1,upperFus,[0 0 0]');   
          LowerFus =posVectFun(1,1,lowerFus,[0 0 0]');   
          Side_FusR=posVectFun(1,1,side_FusR,[0 0 0]');  
          Side_FusL=posVectFun(1,1,side_FusL,[0 0 0]');  
          
        j=1; jj=1; h=1; hh=1; 
        for i=1:Ngrid
        %Upper Fus point
            t=1.5;
            while j<length(UpperFus.pnt0(:,1)) && t>1
                j;
                [C,t]=myIntersectLinePlane(UpperFus.pnt0(j,:)',UpperFus.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && j<length(UpperFus.pnt0(:,1))
                    j=j+1;
                elseif t<0 && j<length(UpperFus.pnt0(:,1))
                    j=j-1;
                end
            end
            if j==length(UpperFus.pnt0(:,1)), j=j-1; end
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
            if jj==length(LowerFus.pnt0(:,1)), jj=jj-1; end
            [C,t]=myIntersectLinePlane(LowerFus.pnt0(jj,:)',LowerFus.pnt0(jj+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
            LowerFusPnt(i,:)=C';    
            
        %Right side Fuselage point
            t=1.5;
            while h<length(Side_FusR.pnt0(:,1)) && t>1
                h;
                [C,t]=myIntersectLinePlane(Side_FusR.pnt0(h,:)',Side_FusR.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && h<length(Side_FusR.pnt0(:,1))
                    h=h+1;
                elseif t<0 && h<length(Side_FusR.pnt0(:,1))
                    h=h-1;
                end
            end
            if h>=length(Side_FusR.pnt0(:,1)), h=length(Side_FusR.pnt0(:,1))-1, end
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
            if hh>=length(Side_FusR.pnt0(:,1)), hh=length(Side_FusR.pnt0(:,1))-1, end
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
                mi(i)=Vi(i)*MAT1.RHO;
            end
            V=sum(Vi);
            M=sum(mi); 
            figure(10),hold on
            plot(iter,M,'o')
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
        M,t,iter, figure(1)       
    % 1.5.Bar model function
        bar_modelFun(fid,fusID,XBeam,Width,Height,t,w_struct,BeamPVect)
    % 1.6.Grid writing
        fprintf(fid,'$Wing Grid\n');
        for i=1:length(Guess.iFus{fusID}.GRID)
            GRIDwriter(fid,Guess.iFus{fusID}.GRID(i));
        end   
    end
    fclose(fid);
%% 2.Aerodynamic Mesh Generator
    EID=EIDaero; SID=EIDaero;
    fid= fopen(['Guess_AeroPan_fus',num2str(fusID),'.dat'],'w');
    for kkkk=1
        %     fprintf(fid,'%8s%8d\n','PAERO1  ',1);
        fprintf(fid,'$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n'); 
        for i=1:Npos
         meanY_i(i)=(side_FusR(i,2)+side_FusL(i,2))./2;
         meanZ_i(i)=(upperFus(i,3)+lowerFus(i,3))./2;
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
        CAEROB.ID=1; 
        CAEROB.OX=CORD2R.Ai(1);
        CAEROB.OY=CORD2R.Ai(2);
        CAEROB.OZ=CORD2R.Ai(3);
        CAEROB.CID=CID;
        CAEROB.LEN=upperFus(end,1)-upperFus(1,1);
        CAEROB.NP=Ngrid
        for i=1:Ngrid
            CAEROB.ISETxsi(i)=XBeam(i)/CAEROB.LEN;
            CAEROB.ISET_R(i)=meanR(i);
        end
        Guess.iFus{fusID}.CAEROB(caerobID)=CAEROB;
        Guess.iFus{fusID}.EID2caerobIDs(EID)=caerobID;
        fprintf(fid,'$Aerodynamic Body\n');
            CAEROBwriterG(fid,CAEROB);
        end
    fclose(fid); 
%% 3.Save Data    
    save('Guess.mat','Guess')
     
end
%% Structure model generator
function bar_modelFun(fid,fusID,XBeam,Width,Height,Thick,w_struct,BeamPVect)
global Guess %TechGeoModel  wingID
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

        plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rs')
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
        SET1.IDs=GridIDs_WingBeam; Guess.iFus{fusID}.GridIDs_WingBeam=GridIDs_WingBeam;

        Guess.iFus{fusID}.SET1(set1ID)=SET1;
        %Guess.iFus{fusID}.set1IDs=[Guess.iFus{fusID}.set1IDs setID];
        fprintf(fid,'$Set Grid Wing\n'); 
        SET1writer(fid,SET1(set1ID));    
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
%% AeroStructGridsInterface
function AeroStructGridsInterface(fid,fusID)
% %% 2.Aero-Struct Grids Interfaces 
%     for kk=1
            %1.2.Genernerate Leading & Trailing Edge
%         for i=1:Npos
%         % XWingLE(2*i-1:2*i,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([1 4],:);
%             % XWingTE(2*i-1:2*i,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([2 3],:);
%             XWingLE(i:i+1,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([1 4],:);
%             XWingTE(i:i+1,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([2 3],:);
%             try
%                 DimTED=size(TechGeoModel.iWing{wingID}.aeroPanel.SectTED);
%                 for j=1:DimTED(2)
%                     XTED(i).XTedLE(1:4,:,j)= TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j}.X;
%                     
%                                    %TechGeoModel.iWing{wingID}.aeroPanel.SectTed{i}.X([1 4],:);
%                 end
%             catch
%                 disp(['$No TED devices on ',num2str(wingID),' at section',num2str(i)])
%             end                                 
%         end    

%     WingLEPVect=posVectFun(1,1,XWingLE,[0 0 0]');
%     WingTEPVect=posVectFun(1,1,XWingTE,[0 0 0]');
%     j=1; h=1;
%     for i=1:Ngrid
%     %Leading Edge Points
%         t=1.5;
%         while j<length(WingLEPVect.pnt0(:,1)) && t>1
%             j;
%             [C,t]=myIntersectLinePlane(WingLEPVect.pnt0(j,:)',WingLEPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
%             if t>1 && j<length(WingLEPVect.pnt0(:,1))
%                 j=j+1;
%             elseif t<0 && j<length(WingLEPVect.pnt0(:,1))
%                 j=j-1;
%             end
%         end
%         if j==length(WingLEPVect.pnt0(:,1)), j=j-1; end
%         [C,t]=myIntersectLinePlane(WingLEPVect.pnt0(j,:)',WingLEPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
%         WingLEPnt(i,:)=C';
%         
%         gridID=gridID+1;
%         GridIDs_RBE2int(i,1)=gridID; %save Grid's IDs
% 
%         GRID.ID   = gridID;
%         GRID.CP   = 0;%coordID;
%         GRID.Xi(1)= WingLEPnt(i,1);
%         GRID.Xi(2)= WingLEPnt(i,2);
%         GRID.Xi(3)= WingLEPnt(i,3);
%         GRID.CD   = 0;%coordID;
%         
%         Guess.iFus{fusID}.GRID(gridID)=GRID;
%         Guess.iFus{fusID}.gridIDs=[Guess.iFus{fusID}.gridIDs gridID];        
%         % GRIDwriter(fid,GRID(gridID));        
%     %Trailing Edge Points
%         t=1.5;
%         while h<length(WingTEPVect.pnt0(:,1)) && t>1
%             h;
%             [C,t]=myIntersectLinePlane(WingTEPVect.pnt0(h,:)',WingTEPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
%             if t>1 && h<length(WingTEPVect.pnt0(:,1))
%                 h=h+1;
%             elseif h<length(WingTEPVect.pnt0(:,1))
%             end
%         end
%         [C,t]=myIntersectLinePlane(WingTEPVect.pnt0(h,:)',WingTEPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
%         WingTEPnt(i,:)=C';
%         
%         gridID=gridID+1;
%         GridIDs_RBE2int(i,2)=gridID; %save Grid's IDs
% 
%         GRID.ID   = gridID;
%         GRID.CP   = 0;%coordID;
%         GRID.Xi(1)= WingTEPnt(i,1);
%         GRID.Xi(2)= WingTEPnt(i,2);
%         GRID.Xi(3)= WingTEPnt(i,3);
%         GRID.CD   = 0;%coordID;
%         
%         Guess.iFus{fusID}.GRID(gridID)=GRID;
%         Guess.iFus{fusID}.gridIDs=[Guess.iFus{fusID}.gridIDs gridID];         
%         % GRIDwriter(fid,GRID(gridID));
%         
%         elemID=elemID+1;
%         RBE2.EID=elemID;
%         RBE2.GN=GridIDs_WingBeam(i);
%         RBE2.CM=123456;
%         RBE2.GMi=GridIDs_RBE2int(i,:);
%         
%         Guess.iFus{fusID}.RBE2(elemID)=RBE2;
%         Guess.iFus{fusID}.rbe2IDs=[Guess.iFus{fusID}.rbe2IDs elemID];        
%             RBE2writer(fid,RBE2)    
%     end    
%     %2.2.1.Save interface GRID IDs in a SET1
%         GridIDs_wingInter=[GridIDs_WingBeam sort(reshape(GridIDs_RBE2int,1,2*length(GridIDs_RBE2int(:,1))))];
%         setID=setID+1;
%         SET1.SID=setID; 
%         SET1.IDs= GridIDs_wingInter;  Guess.iFus{fusID}.GridIDs_wingInter=GridIDs_wingInter;
%         
%         Guess.iFus{fusID}.SET1(setID)=SET1;
%         Guess.iFus{fusID}.set1IDs=[Guess.iFus{fusID}.set1IDs setID];
%         fprintf(fid,'$Wing''s Interface Grid IDs \n'); 
%             SET1writer(fid,SET1);
% 
end
    
    
    