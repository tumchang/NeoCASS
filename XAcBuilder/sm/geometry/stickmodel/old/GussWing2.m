%NastranWing
function NastranWing
close all, clear all, clc
global TechGeoModel Nastran elemID paeroID coordID intgrID setID

%clear all, close all,clc
addpath('NastanWriter');

str='..\Technology\D150_Wing1.mat';
%str='..\Technology\D150_BoxWing_Wing1.mat';
load(str)
wingID  = 1;
figure(1), hold on, axis equal
%% 0.Inizializating
    %0.1.inizializating Nastran's IDs   
        elemID  = 0; 
        paeroID = 1;
        coordID = 0;
        aesurfID= 0;
        intgrID = 1;

        setID   = 0;

        gridID  = 0;
        coordID = 0;
        propID  = 0;
    %0.2.inizializating Nastran's IDs structs
    %struct
        Nastran.mat1IDs   =[];
        Nastran.gridIDs   =[];
        Nastran.set1IDs   =[];
        Nastran.pbeamIDs  =[];
        Nastran.cbeamIDs  =[];
        Nastran.rbe2IDs   =[];
    %Aero
        Nastran.coordIDs  =[];
        Nastran.aefactIDs =[];
        Nastran.caero1IDs =[];
        Nastran.spline1IDs=[];
        Nastran.aelistIDs =[];
        Nastran.aesurfIDs =[];

    Npos=length(TechGeoModel.iWing{wingID}.Geometry.sectID(:,1));

%% 1.Beam Wing Model
    fid= fopen('Struct_Wing.dat','w');
    for kkk=1
    BeamPoint=TechGeoModel.iWing{1}.beamModel.Grid;
    Npoint=length(BeamPoint.xBeam);
    %1.1.Material
        for kk=1
        matID=1;
        MAT1.MID = matID;
        MAT1.E   = 7.1e10;
        MAT1.G   = '';
        MAT1.NU  = 0.33;
        MAT1.RHO = 2.810e-6;
        MAT1.A   = '';
        MAT1.TREF= '';
        MAT1.GE  = '';
        MAT1.ST  = '';
        MAT1.SC  = '';
        MAT1.SS  = '';
        MAT1.MCSID='';
        Nastran.MAT1(matID)=MAT1;
        Nastran.mat1IDs=[Nastran.mat1IDs matID];
        fprintf(fid,['$Material for wing ',num2str(wingID),'\n']);
        MAT1writer(fid,MAT1);
        end     
    %1.2.Genernerate Leading & Trailing Edge
        for i=1:Npos
        % XWingLE(2*i-1:2*i,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([1 4],:);
            % XWingTE(2*i-1:2*i,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([2 3],:);
            XWingLE(i:i+1,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([1 4],:);
            XWingTE(i:i+1,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([2 3],:);
            try
                DimTED=size(TechGeoModel.iWing{wingID}.aeroPanel.SectTED);
                for j=1:DimTED(2)
                    XTED(i).XTedLE(1:4,:,j)= TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j}.X;
                    
                                   %TechGeoModel.iWing{wingID}.aeroPanel.SectTed{i}.X([1 4],:);
                end
            catch
                disp(['$No TED devices on ',num2str(wingID),' at section',num2str(i)])
            end                                 
        end    
    %1.3.Merge points with same components 
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
    %1.4.Grid
        fprintf(fid,'$Grid for wing\n');
        for i=1:Ngrid    
            
            gridID=gridID+1;
            GridIDs_WingBeam(i)=gridID; %save Grid's IDs

            GRID.ID   = gridID;
            GRID.CP   = 0;%coordID;
            GRID.Xi(1)= XBeam(i,1);
            GRID.Xi(2)= XBeam(i,2);
            GRID.Xi(3)= XBeam(i,3);
            GRID.CD   = 0;%coordID;
            
            Nastran.GRID(gridID)=GRID;
            Nastran.gridIDs=[Nastran.gridIDs gridID];
            %fprintf(fid,'$Grid Wing\n');
            %GRIDwriter(fid,GRID(gridID));

            plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rs')
        end
        %1.4.1.Save Grids in a Set
            setID=setID+1; 
            SET1(setID).SID=setID; 
            SET1(setID).IDs=GridIDs_WingBeam;
            
            Nastran.SET1(setID)=SET1;
            Nastran.set1IDs=[Nastran.set1IDs setID];
            fprintf(fid,'$Set Grid Wing\n'); 
            SET1writer(fid,SET1(setID));
    %1.5.Beam elem
        %1.5.1.Generation of geometrical info for Beam elem
            BeamPVect  =posVectFun(1,1,XBeam,[0 0 0]');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            BeamPVect.t(end,:)=[0 1 0];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            FwSparPVect=posVectFun(1,1,TechGeoModel.iWing{1}.Geometry.Strucuture.Spar.iSpar{ 1 }.xSP0,[0 0 0]');
            AfSparPVect=posVectFun(1,1,TechGeoModel.iWing{1}.Geometry.Strucuture.Spar.iSpar{end}.xSP0,[0 0 0]');
            j=1; h=1;
            for i=1:Ngrid
            %Forward Spar point
                t=1.5;
                while j<length(FwSparPVect.pnt0(:,1)) && t>1
                    j;
                    [C,t]=myIntersectLinePlane(FwSparPVect.pnt0(j,:)',FwSparPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                    if t>1 && j<length(FwSparPVect.pnt0(:,1))
                        j=j+1;
                    elseif t<0 && j<length(FwSparPVect.pnt0(:,1))
                        j=j-1;
                    end
                end
                if j==length(FwSparPVect.pnt0(:,1)), j=j-1; end
                [C,t]=myIntersectLinePlane(FwSparPVect.pnt0(j,:)',FwSparPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
                FwSparPnt(i,:)=C';
            %After Spar point

                t=1.5;
                while h<length(FwSparPVect.pnt0(:,1)) && t>1
                    h;
                    [C,t]=myIntersectLinePlane(AfSparPVect.pnt0(h,:)',AfSparPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
                    if t>1 && h<length(FwSparPVect.pnt0(:,1))
                        h=h+1;
                    elseif h<length(AfSparPVect.pnt0(:,1))
                    end
                end
                [C,t]=myIntersectLinePlane(AfSparPVect.pnt0(h,:)',AfSparPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
                AfSparPnt(i,:)=C';
            %Width Structure Box    
                Width(i)=norm(AfSparPnt(i,:)'-FwSparPnt(i,:)');
                w_struct(i,:)=(AfSparPnt(i,:)'-FwSparPnt(i,:)')'/norm(AfSparPnt(i,:)'-FwSparPnt(i,:)');
            end            
        %1.5.2.Beam Property & Element
            for i=1:Ngrid-1
                %Property
                propID=propID+1;
                %propID=1;
                a=Width(i);
                b=Width(i)/4;
                t1=0.002;
                t2=0.002;
                PBEAM.PID = propID;
                PBEAM.MID = matID;
                PBEAM.A   = a*b-(a-2*t2)*(b-2*t1); 
                PBEAM.I1  = a^3*b/12-(a-2*t2)^3*(b-2*t1)/12; 
                PBEAM.I2  = a*b^3/12-(a-2*t2)*(b-2*t1)^3/12;  
                PBEAM.I12 = 0; 
                PBEAM.J   = (PBEAM.I1+PBEAM.I2)/2;
                PBEAM.NSM = 0; 
                PBEAM.C1  = a/2; 
                PBEAM.C2  = b/2; 
                PBEAM.D1  =-a/2; 
                PBEAM.D2  = b/2; 
                PBEAM.E1  =-a/2; 
                PBEAM.E2  =-b/2; 
                PBEAM.F1  = a/2; 
                PBEAM.F2  =-b/2;
                
                Nastran.PBEAM(propID)=PBEAM;
                Nastran.pbeamIDs=[Nastran.pbeamIDs propID];
                PBEAM_BOX(fid,propID,matID,[Width(i)/4 Width(i+1)/4]',[0.002 0.002]',[Width(i) Width(i+1)]',[0.002 0.002]',[0 0])                
            %C beam element
                elemID=elemID+1;
                CbeamIDs(i)=elemID;
                CBEAM.EID   = elemID; 
                CBEAM.PID   = propID; 
                CBEAM.GA    = GridIDs_WingBeam(i);
                CBEAM.GB    = GridIDs_WingBeam(i+1);
                
                CBEAM.u     = BeamPVect.t(i,:);
                CBEAM.v     = -cross(CBEAM.u,w_struct(i,:)')/norm(cross(CBEAM.u,w_struct(i,:)'));
                CBEAM.Xi(1) = CBEAM.v(1);
                CBEAM.Xi(2) = CBEAM.v(2);
                CBEAM.Xi(3) = CBEAM.v(3);
                
                Nastran.CBEAM(elemID)=CBEAM;
                Nastran.cbeamIDs=[Nastran.cbeamIDs elemID];
                % fprintf(fid,'$Wing''s CBEAM elem \n'); 
                    CBEAMwriter(fid,CBEAM);
                
                CBEAMIDs_WingBeam(i)=elemID;
            end
        %1.5.1.Save CBEAM IDs in a SET1
            setID=setID+1;
            SET1.SID=setID; 
            SET1.IDs=CBEAMIDs_WingBeam;
            
            Nastran.SET1(setID)=SET1;
            Nastran.set1IDs=[Nastran.set1IDs setID];
            fprintf(fid,'$Wing''s Wing CBEAM elem IDs \n'); 
                SET1writer(fid,SET1);         
    end
%% 2.Aero-Struct Grids Interfaces 
    for kk=1
    WingLEPVect=posVectFun(1,1,XWingLE,[0 0 0]');
    WingTEPVect=posVectFun(1,1,XWingTE,[0 0 0]');
    j=1; h=1;
    for i=1:Ngrid
    %Leading Edge Points
        t=1.5;
        while j<length(WingLEPVect.pnt0(:,1)) && t>1
            j;
            [C,t]=myIntersectLinePlane(WingLEPVect.pnt0(j,:)',WingLEPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
            if t>1 && j<length(WingLEPVect.pnt0(:,1))
                j=j+1;
            elseif t<0 && j<length(WingLEPVect.pnt0(:,1))
                j=j-1;
            end
        end
        if j==length(WingLEPVect.pnt0(:,1)), j=j-1; end
        [C,t]=myIntersectLinePlane(WingLEPVect.pnt0(j,:)',WingLEPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
        WingLEPnt(i,:)=C';
        
        gridID=gridID+1;
        GridIDs_RBE2int(i,1)=gridID; %save Grid's IDs

        GRID.ID   = gridID;
        GRID.CP   = 0;%coordID;
        GRID.Xi(1)= WingLEPnt(i,1);
        GRID.Xi(2)= WingLEPnt(i,2);
        GRID.Xi(3)= WingLEPnt(i,3);
        GRID.CD   = 0;%coordID;
        
        Nastran.GRID(gridID)=GRID;
        Nastran.gridIDs=[Nastran.gridIDs gridID];        
        % GRIDwriter(fid,GRID(gridID));        
    %Trailing Edge Points
        t=1.5;
        while h<length(WingTEPVect.pnt0(:,1)) && t>1
            h;
            [C,t]=myIntersectLinePlane(WingTEPVect.pnt0(h,:)',WingTEPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0);
            if t>1 && h<length(WingTEPVect.pnt0(:,1))
                h=h+1;
            elseif h<length(WingTEPVect.pnt0(:,1))
            end
        end
        [C,t]=myIntersectLinePlane(WingTEPVect.pnt0(h,:)',WingTEPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',0); %1
        WingTEPnt(i,:)=C';
        
        gridID=gridID+1;
        GridIDs_RBE2int(i,2)=gridID; %save Grid's IDs

        GRID.ID   = gridID;
        GRID.CP   = 0;%coordID;
        GRID.Xi(1)= WingTEPnt(i,1);
        GRID.Xi(2)= WingTEPnt(i,2);
        GRID.Xi(3)= WingTEPnt(i,3);
        GRID.CD   = 0;%coordID;
        
        Nastran.GRID(gridID)=GRID;
        Nastran.gridIDs=[Nastran.gridIDs gridID];         
        % GRIDwriter(fid,GRID(gridID));
        
        elemID=elemID+1;
        RBE2.EID=elemID;
        RBE2.GN=GridIDs_WingBeam(i);
        RBE2.CM=123456;
        RBE2.GMi=GridIDs_RBE2int(i,:);
        
        Nastran.RBE2(elemID)=RBE2;
        Nastran.rbe2IDs=[Nastran.rbe2IDs elemID];        
            RBE2writer(fid,RBE2)    
    end    
    %2.2.1.Save interface GRID IDs in a SET1
        GridIDs_wingInter=[GridIDs_WingBeam sort(reshape(GridIDs_RBE2int,1,2*length(GridIDs_RBE2int(:,1))))];
        setID=setID+1;
        SET1.SID=setID; 
        SET1.IDs= GridIDs_wingInter;  Nastran.GridIDs_wingInter=GridIDs_wingInter;
        
        Nastran.SET1(setID)=SET1;
        Nastran.set1IDs=[Nastran.set1IDs setID];
        fprintf(fid,'$Wing''s Interface Grid IDs \n'); 
            SET1writer(fid,SET1);
      
    % Grid writing
        fprintf(fid,'$Wing Grid\n');
        for i=1:length(Nastran.GRID)
            GRIDwriter(fid,Nastran.GRID(i));
        end
    end     
    fclose(fid);
%% 3.Aerodynamic Mesh Generator
    fid= fopen('AeroPan_Wing.dat','w');
    fprintf(fid,'%8s%8d\n','PAERO1  ',1);
    for i=1:Npos
        fprintf(fid,'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n');
    %Central Wing Aerodynamic Boxes
        fprintf(fid,'%s\n',['$Aero Panel section',num2str(i)]);
        AeroBoxFun(fid,TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i});
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %SET1 interface struct grids
        GridInBoxIDs=findSetInDomain(TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i},Nastran.GridIDs_wingInter);
        figure(1)%back to main figure 
        %setID=setID+1;

        SET1.SID=setID; 
        SET1.IDs= GridInBoxIDs;  

        Nastran.SET1(setID)=SET1;
        Nastran.set1IDs=[Nastran.set1IDs setID];
        fprintf(fid,'$Set of Interface Aero-Struct Grids \n'); 
            SET1writer(fid,SET1);    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %SPLINE1 Define surface spline
%         elemID=elemID+Nbox+1;  
%         SPLINE1.EID  =elemID;
%         SPLINE1.CAERO=CAERO1.EID;
%         SPLINE1.BOX1 =CAERO1.Boxes(1);
%         SPLINE1.BOX2 =CAERO1.Boxes(2);
%         SPLINE1.SETG =setID;
%     %Save data & write Card
%         Nastran.SPLINE1(elemID)=SPLINE1;
%         Nastran.spline1IDs=[Nastran.spline1IDs elemID];
%         fprintf(fid,'$Spline interface Aerodynamic - Structure\n');    
%             SPLINE1writer(fid,SPLINE1); 

    fprintf(fid,'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n');     
    %TED Aerodynamic Boxes
        try
            DimTED=size(TechGeoModel.iWing{wingID}.aeroPanel.SectTED);
            for j=1:DimTED(2)                
                if ~isempty(TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j})
                    fprintf(fid,'%s\n',['$Aero Panel section ',num2str(i),', TED box Section ',num2str(j)]);
                    AeroBoxFun(fid,TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j});
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%                     %SET1 interface struct grids
%                     GridInBoxIDs=findSetInDomain(TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i},Nastran.GridIDs_wingInter);
%                     figure(1)%back to main figure 
%                     %setID=setID+1;
% 
%                     SET1.SID=setID; 
%                     SET1.IDs= GridInBoxIDs;  
% 
%                     Nastran.SET1(setID)=SET1;
%                     Nastran.set1IDs=[Nastran.set1IDs setID];
%                     fprintf(fid,'$Set of Interface Aero-Struct Grids \n'); 
%                     SET1writer(fid,SET1);    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %if 
                        %CORD2R
                        coordID=coordID+1;
                        %AELIST
                        caero1_AelistID = Nastran.caero1IDs(end);
                         
                        setID=setID+1;
                        AELIST.SID=setID;
                        AELIST.Ei=[Nastran.CAERO1(caero1_AelistID).Boxes(1):Nastran.CAERO1(caero1_AelistID).Boxes(end)];
                         
                        Nastran.AELIST(setID)=AELIST;
                        Nastran.aelistIDs=[Nastran.aelistIDs setID];
                        fprintf(fid,'$Set of AeroBox for control surface \n'); 
                            AELISTwriter(fid,AELIST);
                         
                        %AESURF
                        aesurfID=aesurfID+1;
                        AESURF.ID=aesurfID;
                        AESURF.LABEL='Flap';
                        AESURF.CID1 =coordID;
                        AESURF.ALID1=setID;
                         
                        Nastran.AESURF(aesurfID)=AESURF;
                        Nastran.aesurfIDs=[Nastran.aesurfIDs aesurfID];
                        fprintf(fid,'$Aerodynamic Control surface \n'); 
                            AESURFwriter(fid,AESURF);
                         
                     
                    fprintf(fid,'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n');
                end
            end
        catch
            disp(['$No TED devices on ',num2str(wingID),' at section',num2str(i)])
        end                                 
    end
    fclose(fid); 
%% 4.Save Data    
    save('GRID_wing.mat','GRID')
    save('SET_gridInterface.mat','GridIDs_wingInter')
    save('Nastran.mat','Nastran')
     
end    
%% Aerodynamic Box Generator
function AeroBoxFun(fid,ABoxSect)
global Nastran elemID paeroID coordID intgrID setID
%     ABoxSect=TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %COORD2R
        coordID=coordID+1;

        e1=          (ABoxSect.X(2,:)'-ABoxSect.X(1,:)')/norm(ABoxSect.X(2,:)'-ABoxSect.X(1,:)');
        e3=     cross(ABoxSect.X(2,:)'-ABoxSect.X(1,:)',      ABoxSect.X(4,:)'-ABoxSect.X(1,:)')/...
           norm(cross(ABoxSect.X(2,:)'-ABoxSect.X(1,:)',      ABoxSect.X(4,:)'-ABoxSect.X(1,:)'));
        e2=-cross(e1,e3)/norm(cross(e1,e3));

        cos_e=[e1,e2,e3];

        A=ABoxSect.X(1,:)';    B=A+e3;     C=B+e1;

        plot3(A(1),A(2),A(3),'or',B(1),B(2),B(3),'og',C(1),C(2),C(3),'ok')

        CORD2R.CID = coordID;
        CORD2R.RID = 0;
        CORD2R.Ai  = A;
        CORD2R.Bi  = B;
        CORD2R.Ci  = C;
    %Save data & write Card
        Nastran.CORD2R(coordID)=CORD2R;
        Nastran.coordIDs=[Nastran.coordIDs coordID];
        fprintf(fid,'$Coordinates System for Aerodynamic Box\n');
            CORD2Rwriter(fid,CORD2R);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %AEFACT LSPAN
        setID=setID+1;
        AEFACT.SID = setID;
        AEFACT.Di  = ABoxSect.Aefact_span;
    %Save data & write Card
        Nastran.AEFACT(setID)=AEFACT;
        Nastran.aefactIDs=[Nastran.aefactIDs setID];
        fprintf(fid,'$Aerodynamic Box eta division\n');        
            AEFACTwriter(fid,AEFACT);
    
    %AEFACT LCHORD
        setID=setID+1;
        AEFACT.SID = setID;
        AEFACT.Di  = ABoxSect.Aefact_chord;
    %Save data & write Card
        Nastran.AEFACT(setID)=AEFACT;
        Nastran.aefactIDs=[Nastran.aefactIDs setID];
        fprintf(fid,'$Aerodynamic Box xsi division\n');
            AEFACTwriter(fid,AEFACT);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CAERO1
        elemID=elemID+1;
        CAERO1.EID    = elemID;
        CAERO1.PID    = paeroID;
        CAERO1.CP     = coordID;   
        CAERO1.LSPAN  = setID-1;
        CAERO1.LCHORD = setID;
        CAERO1.IGID   = intgrID;
        % CAERO1.X1     = ABoxSect.X(1,1);
        % CAERO1.Y1     = ABoxSect.X(1,2);
        % CAERO1.Z1     = ABoxSect.X(1,3);
        % CAERO1.X12    = ABoxSect.X(2,1)-ABoxSect.X(1,1);
        % CAERO1.X4     = ABoxSect.X(4,1);
        % CAERO1.Y4     = ABoxSect.X(4,2);
        % CAERO1.Z4     = ABoxSect.X(4,3);
        % CAERO1.X43    = ABoxSect.X(3,1)-ABoxSect.X(4,1);
        CAERO1.X1     = 0;
        CAERO1.Y1     = 0;
        CAERO1.Z1     = 0;
        CAERO1.X12    = norm(ABoxSect.X(2,:)'-ABoxSect.X(1,:)');

        X4e=cos_e'*(ABoxSect.X(4,:)'-ABoxSect.X(1,:)');

        CAERO1.X4     = X4e(1);
        CAERO1.Y4     = X4e(2);
        CAERO1.Z4     = X4e(3);    
        CAERO1.X43    = norm(ABoxSect.X(3,:)'-ABoxSect.X(4,:)');
        %Define Number of Aero Box in CAERO1 (NB each of them must have an EID unique!!!) 
        Nbox=(length(ABoxSect.Aefact_span)-1)*(length(ABoxSect.Aefact_chord)-1)-1;
        CAERO1.Boxes  = [elemID elemID+Nbox];   

    %Verify plot
        X=[ABoxSect.X(1,1) ABoxSect.X(2,1);...
           ABoxSect.X(4,1) ABoxSect.X(3,1)];
        Y=[ABoxSect.X(1,2) ABoxSect.X(2,2);...
           ABoxSect.X(4,2) ABoxSect.X(3,2)];
        Z=[ABoxSect.X(1,3) ABoxSect.X(2,3);...
           ABoxSect.X(4,3) ABoxSect.X(3,3)];
         surf(X,Y,Z)
    %Save data & write Card
        Nastran.CAERO1(elemID)=CAERO1; 
        Nastran.caero1IDs=[Nastran.caero1IDs elemID];
        fprintf(fid,'$Aerodynamic Box\n');
            CAERO1writer(fid,CAERO1);
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     %SET1 interface struct grids
%         GridInBoxIDs=findSetInDomain(ABoxSect,Nastran.GridIDs_wingInter);
%     
         setID=setID+1;
%     
%         SET1.SID=setID; 
%         SET1.IDs= GridInBoxIDs;  
%         
%         Nastran.SET1(setID)=SET1;
%         Nastran.set1IDs=[Nastran.set1IDs setID];
%         fprintf(fid,'$Set of Interface Aero-Struct Grids \n'); 
%             SET1writer(fid,SET1);    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SPLINE1 Define surface spline
        elemID=elemID+Nbox+1;  
        SPLINE1.EID  =elemID;
        SPLINE1.CAERO=CAERO1.EID;
        SPLINE1.BOX1 =CAERO1.Boxes(1);
        SPLINE1.BOX2 =CAERO1.Boxes(2);
        SPLINE1.SETG =setID;
    %Save data & write Card
        Nastran.SPLINE1(elemID)=SPLINE1;
        Nastran.spline1IDs=[Nastran.spline1IDs elemID];
        fprintf(fid,'$Spline interface Aerodynamic - Structure\n');    
            SPLINE1writer(fid,SPLINE1); 
end
    
    
    