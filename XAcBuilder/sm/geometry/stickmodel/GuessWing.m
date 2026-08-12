%GuessWing
function GuessWing(wingID,component)
%clear all, close all,clc
global TechGeoModel Guess %wingID
global CID      GID    MID    EID             PID            SID 
global cord2rID gridID mat1ID cbarID caero1ID pbarID paeroID set1ID intgrID spline1ID  

CID=1000*component; 
GID=1000*component; 
MID=1000*component; 
EID=1000*component; EIDaero=EID*10; 
PID=1000*component; 
SID=1000*component;

addpath('NastanWriter');
addpath('GuessWriter');

% %str='..\Technology\D150_Wing1.mat';
% %str='..\Technology\D150_BoxWing_Wing1.mat';
% %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_TechGeoModel.mat';
% str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150 for CPACS 1.3_TechGeoModel.mat';
% load(str)
% wingID  = 3;
% figure(1), hold on, axis equal
%% 0.Inizializating
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %Global index
%     CID=100;
%     MID=100;
%     GID=100;        
%     PID=100;
%     EID=100;  EIDaero=EID*10;
%     SID=100;
%                  
%     %global ID 2 card ID
%     Guess.MID2mat1IDs=[]; 
%     Guess.GID2gridIDs=[]; 
%     Guess.SID2set1IDs=[];
%     Guess.PID2pbarIDs=[];
%     Guess.EID2cbarIDs=[];
% 
%     Guess.EID2caero1IDs=[];
%     Guess.EID2spline1IDs=[]; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%Card index
    mat1ID=0;
    gridID=0;        
    pbarID=0;    
    cbarID=0;
    set1ID=0;
    cord2r=0;

    caero1ID=0;
    paeroID =1;
    spline1ID=0;

        
    %Global number
    Npos=length(TechGeoModel.iWing{wingID}.Geometry.sectID(:,1));
    
%% 1.Beam model
    fid= fopen(['Guess_Struct_wing',num2str(wingID),'.dat'],'w');
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
            Guess.MAT1(mat1ID)=MAT1;
            %Guess.mat1IDs=[Guess.mat1IDs matID];
            fprintf(fid,['$Material for wing ',num2str(wingID),'\n']);
            MAT1writer(fid,MAT1);
        end      
        BeamPoint=TechGeoModel.iWing{wingID}.beamModel.Grid;
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
        FwSparPVect=posVectFun(1,1,TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{ 1 }.xSP0,[0 0 0]');
        AfSparPVect=posVectFun(1,1,TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{end}.xSP0,[0 0 0]');
        j=1; h=1;
        for i=1:Ngrid
        %Forward Spar point
            t=1.5;
            while j<length(FwSparPVect.pnt0(:,1)) && t>1                
                [C,t]=myIntersectLinePlane(FwSparPVect.pnt0(j,:)',FwSparPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && j<length(FwSparPVect.pnt0(:,1))
                    j=j+1;
                elseif t<0 && j<length(FwSparPVect.pnt0(:,1))
                    j=j-1;
                end
            end
            j
            if j==length(FwSparPVect.pnt0(:,1)), j=j-1; end
            if j<=0, j=1; end
            [C,t]=myIntersectLinePlane(FwSparPVect.pnt0(j,:)',FwSparPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
            FwSparPnt(i,:)=C';
        %After Spar point

            t=1.5;
            while h<length(FwSparPVect.pnt0(:,1)) && t>1                
                [C,t]=myIntersectLinePlane(AfSparPVect.pnt0(h,:)',AfSparPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                if t>1 && h<length(FwSparPVect.pnt0(:,1))
                    h=h+1;
                elseif h<length(AfSparPVect.pnt0(:,1))
                end
            end
            [C,t]=myIntersectLinePlane(AfSparPVect.pnt0(h,:)',AfSparPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
            AfSparPnt(i,:)=C';
        %Width Structure Box    
            Width(i)=norm(AfSparPnt(i,:)' -FwSparPnt(i,:)');
            Height(i)=Width(i)/4;
            w_struct(i,:)=(AfSparPnt(i,:)'-FwSparPnt(i,:)')'/norm(AfSparPnt(i,:)'-FwSparPnt(i,:)');
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
        M,iter
        figure(1)       
    % 1.5.Bar model function
        bar_modelFun(fid,XBeam,Width,Height,t,w_struct,BeamPVect)
    % 1.6.Grid writing
        fprintf(fid,'$Wing Grid\n');
        for i=1:length(Guess.GRID)
            GRIDwriter(fid,Guess.GRID(i));
        end   
    end
    fclose(fid);
%% 2.Aerodynamic Mesh Generator
    EID=EIDaero; SID=EIDaero;
    fid= fopen(['Guess_AeroPan_wing',num2str(wingID),'.dat'],'w');
    fprintf(fid,'%8s%8d\n','PAERO1  ',1);
    fprintf(fid,'$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n'); 
    for i=1:Npos        
    %Central Wing Aerodynamic Boxes
        fprintf(fid,'%s\n',['$Aero Panel section',num2str(i)]);
        AeroBoxFun(fid,TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i},0);        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
        GridInBoxIDs=findSetInDomain(TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i},Guess.GridIDs_WingBeam); %solo sulla beam
        figure(1)%back to main figure 

        SID=EID; 
        SET1.SID=SID; 
        SET1.IDs= GridInBoxIDs;  

        set1ID=set1ID+1;
        Guess.SET1(set1ID)=SET1;
        Guess.SID2set1IDs(EID)=set1ID;
        fprintf(fid,'$Set of Interface Aero-Struct Grids \n'); 
            SET1writer(fid,SET1);         
    %TED Aerodynamic Boxes
        try            
            DimTED=size(TechGeoModel.iWing{wingID}.aeroPanel.SectTED);            
            for j=1:DimTED(2) 
                %j
                if ~isempty(TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j})
                    
                    fprintf(fid,'%s\n',['$Aero Panel section ',num2str(i),', TED box Section ',num2str(j)]);
                    AeroBoxFun(fid,TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j},1);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %SET1 interface struct grids   
                        %GridInBoxIDs=findSetInDomain(TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i},Guess.GridIDs_wingInter); %grid beam ed RBE2 (X spline1 Nastran)
                        %GridInBoxIDs=findSetInDomain(TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i},Guess.GridIDs_WingBeam); %solo sulla beam
                        %figure(1)%back to main figure 
                        
                        SID=EID; set1ID=set1ID+1; 
                        SET1.SID=SID;
                        SET1.IDs= GridInBoxIDs;  

                        set1ID=caero1ID;
                        Guess.SET1(set1ID)=SET1;
                        Guess.SID2set1IDs(EID)=set1ID;
                        fprintf(fid,'$Set of Interface Aero-Struct Grids \n'); 
                            SET1writer(fid,SET1);    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %if 
                        %CORD2R
%                         cord2rID=cord2rID+1;
                        %AELIST
                        %caero1_AelistID = Guess.caero1IDs(end);
                         
%                         aelistID=aelistID+1; SID=SID+1;
%                         AELIST.SID=setID;
%                         AELIST.Ei=[Guess.CAERO1(caero1_AelistID).Boxes(1):Guess.CAERO1(caero1_AelistID).Boxes(end)];
                         
%                         Guess.AELIST(setID)=AELIST;
%                         Guess.aelistIDs=[Guess.aelistIDs setID];
%                         fprintf(fid,'$Set of AeroBox for control surface \n'); 
%                             AELISTwriter(fid,AELIST);
%                          
%                         %AESURF
%                         aesurfID=aesurfID+1;
%                         AESURF.ID=aesurfID;
%                         AESURF.LABEL='Flap';
%                         AESURF.CID1 =coordID;
%                         AESURF.ALID1=setID;
%                          
%                         Guess.AESURF(aesurfID)=AESURF;
%                         Guess.aesurfIDs=[Guess.aesurfIDs aesurfID];
%                         fprintf(fid,'$Aerodynamic Control surface \n'); 
%                             AESURFwriter(fid,AESURF);
                         
                     
                    fprintf(fid,'$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n'); 
                end
            end
        catch
            disp(['$No TED devices on ',num2str(wingID),' at section',num2str(i)])
        end                                 
    end
    fclose(fid); 
%% 3.Save Data    
    %save('GRID_wing.mat','GRID')
%    save('SET_gridInterface.mat','GridIDs_wingInter')
    save('Guess.mat','Guess')
     
end
%% Structure model generator
function bar_modelFun(fid,XBeam,Width,Height,Thick,w_struct,BeamPVect)
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

        Guess.GRID(gridID)=GRID;
        Guess.GID2gridIDs(GID)=gridID;
%            Guess.gridStructIDs=[Guess.gridStructIDs gridID];
        %fprintf(fid,'$Grid Wing\n');
        %GRIDwriter(fid,GRID(gridID));

        plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rs')
    end
 
    %1.2.Bar Property & Element
    for i=1:Ngrid-1
        %Property
        PID=PID+1;
        pbarID=pbarID+1;
        Guess.PID2pbarIDs(PID)=pbarID;
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
        PBAR.C1  = b/2;                              
        PBAR.C2  = a/2;                                 
        PBAR.D1  =-b/2;                                 
        PBAR.D2  = a/2;                                 
        PBAR.E1  =-b/2;                                 
        PBAR.E2  =-a/2;                                 
        PBAR.F1  = b/2;                                 
        PBAR.F2  =-a/2;  
%                 PBAR.C1  = a/2;                              
%                 PBAR.C2  =  0 ;                                 
%                 PBAR.D1  =  0 ;                                 
%                 PBAR.D2  = b/2;                                 
%                 PBAR.E1  =-a/2;                                 
%                 PBAR.E2  =  0 ;                                 
%                 PBAR.F1  =  0 ;                                 
%                 PBAR.F2  =-b/2; 

        Guess.PBAR(pbarID)=PBAR;
            PBARwriter(fid,PBAR);

    %1.3.Cbar element
        EID=EID+1;
        cbarID=cbarID+1;
        Guess.EID2cbarIDs(EID)=cbarID;

        CBAR.EID   = EID; 
        CBAR.PID   = PID; 
        CBAR.GA    = GridIDs_WingBeam(i);
        CBAR.GB    = GridIDs_WingBeam(i+1);

        CBAR.u     = BeamPVect.t(i,:);
        CBAR.v     = -cross(CBAR.u,w_struct(i,:)')/norm(cross(CBAR.u,w_struct(i,:)'));
        CBAR.Xi(1) = CBAR.v(1);
        CBAR.Xi(2) = CBAR.v(2);
        CBAR.Xi(3) = CBAR.v(3);

        Guess.CBAR(cbarID)=CBAR;
        % fprintf(fid,'$Wing''s cbar elem \n'); 
            CBARwriter(fid,CBAR);

        CBAREIDs_WingBeam(i)=EID;
    end

    %1.4.Save Grids in a Set
        SID=SID+1;
        set1ID=set1ID+1;
        Guess.SID2set1IDs(SID)=set1ID;

        SET1.SID=SID; 
        SET1.IDs=GridIDs_WingBeam; Guess.GridIDs_WingBeam=GridIDs_WingBeam;

        Guess.SET1(set1ID)=SET1;
        %Guess.set1IDs=[Guess.set1IDs setID];
        fprintf(fid,'$Set Grid Wing\n'); 
        SET1writer(fid,SET1(set1ID));    
    %1.5.Save CBAR IDs in a SET1
        SID=SID+1;
        set1ID=set1ID+1;
        Guess.SID2set1IDs(SID)=set1ID;

        SET1.SID=SID; 
        SET1.IDs=CBAREIDs_WingBeam;

        Guess.SET1(set1ID)=SET1;
        %Guess.set1IDs=[Guess.set1IDs setID];
        fprintf(fid,'$Wing''s Wing CBAR elem IDs \n'); 
            SET1writer(fid,SET1);         
    
end
%% Aerodynamic Box Generator
function AeroBoxFun(fid,ABoxSect,FlagMovSurf)
global Guess
global CID      GID    MID    EID             PID            SID 
global cord2rID gridID mat1ID cbarID caero1ID pbarID paeroID set1ID intgrID spline1ID
    rad=pi/180;    
    %CAERO1
        caero1ID=caero1ID+1; EID=EID+1; %SID=EID+1;
        CAERO1.EID    = EID;
               
        CAERO1.CP     = 0; 
        CAERO1.NY     = length(ABoxSect.Aefact_span)-1;
        CAERO1.NX     = length(ABoxSect.Aefact_chord)-1;
        CAERO1.PID    = paeroID;
        CAERO1.IGID   = intgrID;
        CAERO1.RFO    = '0012';
        CAERO1.TFO    = '0012';
        CAERO1.TYP    = 1;
        
        CAERO1.CX     = ABoxSect.X(1,1);
        CAERO1.CY     = ABoxSect.X(1,2);
        CAERO1.CZ     = ABoxSect.X(1,3);
        CAERO1.CHD    = ABoxSect.X(2,1)-ABoxSect.X(1,1);
        
        v14 =ABoxSect.X(4,:)'-ABoxSect.X(1,:)';
        v12 =ABoxSect.X(2,:)'-ABoxSect.X(1,:)';
        v43 =ABoxSect.X(3,:)'-ABoxSect.X(4,:)';
        
        prjYZ=[0 0 0;...
               0 1 0;...
               0 0 1];
        lenghtYZ=norm(prjYZ*v14); 
         
        CAERO1.SPN  = lenghtYZ;
        CAERO1.TPR  = (ABoxSect.X(3,1)-ABoxSect.X(4,1))/(ABoxSect.X(2,1)-ABoxSect.X(1,1));
        CAERO1.SWP  = atan(v14(1)/lenghtYZ )/rad;       
        CAERO1.DIH  = acos(v14(2)/lenghtYZ )/rad;
        CAERO1.TW1  = acos(v12(1)/norm(v12))/rad;
        CAERO1.TW2  = acos(v43(1)/norm(v43))/rad;
        
        CAERO1.FLP  = FlagMovSurf;
        CAERO1.FC   = 0.2;
        CAERO1.FNX  = 6;
        CAERO1.NAM  = 'FlapFix';
        
        
        %Define Number of Aero Box in CAERO1 (NB each of them must have an EID unique!!!) 
        Nbox=(length(ABoxSect.Aefact_span)-1)*(length(ABoxSect.Aefact_chord)-1)-1;
        CAERO1.Boxes  = [1 Nbox+1];   

    %Verify plot
        X=[ABoxSect.X(1,1) ABoxSect.X(2,1);...
           ABoxSect.X(4,1) ABoxSect.X(3,1)];
        Y=[ABoxSect.X(1,2) ABoxSect.X(2,2);...
           ABoxSect.X(4,2) ABoxSect.X(3,2)];
        Z=[ABoxSect.X(1,3) ABoxSect.X(2,3);...
           ABoxSect.X(4,3) ABoxSect.X(3,3)];
         surf(X,Y,Z)
    %Save data & write Card
        Guess.CAERO1(caero1ID)=CAERO1; 
        
        Guess.EID2caero1IDs(EID)=caero1ID;
        %Guess.caero1IDs=[Guess.caero1IDs elemID];
        fprintf(fid,'$Aerodynamic Box\n');
            CAERO1writerG(fid,CAERO1,FlagMovSurf);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SPLINE1 Define surface spline                
        SPLINE1.EID  =EID;
        SPLINE1.CAERO=CAERO1.EID;
        SPLINE1.BOX1 =CAERO1.Boxes(1);
        SPLINE1.BOX2 =CAERO1.Boxes(2);
        SPLINE1.SETG =EID; %SID
    %Save data & write Card
        spline1ID=caero1ID;
        Guess.SPLINE1(spline1ID)=SPLINE1;
        Guess.EID2spline1IDs(EID)=spline1ID;
        %Guess.spline1IDs=[Guess.spline1IDs elemID];
        fprintf(fid,'$Spline interface Aerodynamic - Structure\n');    
            SPLINE1writer(fid,SPLINE1); 
end
%% AeroStructGridsInterface
function AeroStructGridsInterface(fid)
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
%         Guess.GRID(gridID)=GRID;
%         Guess.gridIDs=[Guess.gridIDs gridID];        
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
%         Guess.GRID(gridID)=GRID;
%         Guess.gridIDs=[Guess.gridIDs gridID];         
%         % GRIDwriter(fid,GRID(gridID));
%         
%         elemID=elemID+1;
%         RBE2.EID=elemID;
%         RBE2.GN=GridIDs_WingBeam(i);
%         RBE2.CM=123456;
%         RBE2.GMi=GridIDs_RBE2int(i,:);
%         
%         Guess.RBE2(elemID)=RBE2;
%         Guess.rbe2IDs=[Guess.rbe2IDs elemID];        
%             RBE2writer(fid,RBE2)    
%     end    
%     %2.2.1.Save interface GRID IDs in a SET1
%         GridIDs_wingInter=[GridIDs_WingBeam sort(reshape(GridIDs_RBE2int,1,2*length(GridIDs_RBE2int(:,1))))];
%         setID=setID+1;
%         SET1.SID=setID; 
%         SET1.IDs= GridIDs_wingInter;  Guess.GridIDs_wingInter=GridIDs_wingInter;
%         
%         Guess.SET1(setID)=SET1;
%         Guess.set1IDs=[Guess.set1IDs setID];
%         fprintf(fid,'$Wing''s Interface Grid IDs \n'); 
%             SET1writer(fid,SET1);
% 
end
    
    
    