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
elemID  = 0; 
paeroID = 1;
coordID = 0;
intgrID = 1;
 
setID   = 0;

gridID  = 0;
coordID = 0;
propID  = 0;
%inizializating Nastran's IDs structs
Nastran.coordIDs  =[];
Nastran.aefactIDs =[];
Nastran.caero1IDs =[];
Nastran.spline1IDs=[];

Npos=length(TechGeoModel.iWing{wingID}.Geometry.sectID(:,1));

figure, hold on, axis equal
%% 1.Aerodynamic Mesh Generator
    fid= fopen('AeroPan_Wing.dat','w');
    fprintf(fid,'%8s%8d','PAERO1  ',1);
    for i=1:Npos
        fprintf(fid,'%s\n',['$Aero Panel section',num2str(i)]);
        %Central Wing Aerodynamic Boxes
        AeroBoxFun(fid,TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i});
%         XWingLE(2*i-1:2*i,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([1 4],:);
%         XWingTE(2*i-1:2*i,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([2 3],:);
        XWingLE(i:i+1,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([1 4],:);
        XWingTE(i:i+1,:) = TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i}.X([2 3],:);
        %TED Aerodynamic Boxes
        try
            DimTED=size(TechGeoModel.iWing{wingID}.aeroPanel.SectTED);
            for j=1:DimTED(2)
                if ~isempty(TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j})
                    AeroBoxFun(fid,TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j});
                end
            end
        catch
            disp(['$No TED devices on ',num2str(wingID),' at section',num2str(i)])
        end                                 
    end
    fclose(fid);  
%% 2.Beam Wing Model
    fid= fopen('Struct_Wing.dat','w');
    for kkk=1
    BeamPoint=TechGeoModel.iWing{1}.beamModel.Grid;
    Npoint=length(BeamPoint.xBeam);
    %2.1.Material
        for kk=1
        matID=1;
        MAT1(matID).MID = matID;
        MAT1(matID).E   = 7.1e10;
        MAT1(matID).G   = '';
        MAT1(matID).NU  = 0.33;
        MAT1(matID).RHO = 2.810e-6;
        MAT1(matID).A   = '';
        MAT1(matID).TREF= '';
        MAT1(matID).GE  = '';
        MAT1(matID).ST  = '';
        MAT1(matID).SC  = '';
        MAT1(matID).SS  = '';
        MAT1(matID).MCSID='';
        fprintf(fid,'$Material for wing\n');
        MAT1writer(fid,MAT1(matID));
        end        
    %2.2.Merge points with same components 
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
    %2.2.Grid
        fprintf(fid,'$Grid for wing\n');
        for i=1:Ngrid    
            
            gridID=gridID+1;
            GridIDs_WingBeam(i)=gridID; %save Grid's IDs

            GRID(gridID).ID   = gridID;
            GRID(gridID).CP   = 0;%coordID;
            GRID(gridID).Xi(1)= XBeam(i,1);
            GRID(gridID).Xi(2)= XBeam(i,2);
            GRID(gridID).Xi(3)= XBeam(i,3);
            GRID(gridID).CD   = 0;%coordID;
            
            %GRIDwriter(fid,GRID(gridID));

            plot3(GRID(gridID).Xi(1),GRID(gridID).Xi(2),GRID(gridID).Xi(3),'rs')
        end
        %1.2.1.Save Grids in a Set
            setID=setID+1;
            SET1(setID).SID=setID; 
            SET1(setID).IDs=GridIDs_WingBeam;
            fprintf(fid,'$Set Grid Wing\n'); 
            SET1writer(fid,SET1(setID));
    %2.3.Beam elem
        %2.3.1.Generation of geometrical info for Beam elem
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
        %2.3.2.Beam Property & Element
            for i=1:Ngrid-1
                %Property
                propID=propID+1;
                %propID=1;
                a=Width(i);
                b=Width(i)/4;
                t1=0.002;
                t2=0.002;
                PBEAM(propID).PID = propID;
                PBEAM(propID).MID = matID;
                PBEAM(propID).A   = a*b-(a-2*t2)*(b-2*t1); 
                PBEAM(propID).I1  = a^3*b/12-(a-2*t2)^3*(b-2*t1)/12; 
                PBEAM(propID).I2  = a*b^3/12-(a-2*t2)*(b-2*t1)^3/12;  
                PBEAM(propID).I12 = 0; 
                PBEAM(propID).J   = (PBEAM(propID).I1+PBEAM(propID).I2)/2;
                PBEAM(propID).NSM = 0; 
                PBEAM(propID).C1  = a/2; 
                PBEAM(propID).C2  = b/2; 
                PBEAM(propID).D1  =-a/2; 
                PBEAM(propID).D2  = b/2; 
                PBEAM(propID).E1  =-a/2; 
                PBEAM(propID).E2  =-b/2; 
                PBEAM(propID).F1  = a/2; 
                PBEAM(propID).F2  =-b/2;

                PBEAM_BOX(fid,propID,matID,[Width(i)/4 Width(i+1)/4]',[0.002 0.002]',[Width(i) Width(i+1)]',[0.002 0.002]',[0 0])                
            %C beam element
                elemID=elemID+1;
                CbeamIDs(i)=elemID;
                CBEAM(elemID).EID   = elemID; 
                CBEAM(elemID).PID   = propID; 
                CBEAM(elemID).GA    = GridIDs_WingBeam(i);
                CBEAM(elemID).GB    = GridIDs_WingBeam(i+1);
                % CBEAM(elemID).Vect  = GRID(GridIDs_WingBeam(i+1)).Xi(:)-GRID(GridIDs_WingBeam(i)).Xi(:);
                % CBEAM(elemID).L     = norm(CBEAM(elemID).Vect);
                % CBEAM(elemID).u     = CBEAM(elemID).Vect/CBEAM(elemID).L;
                CBEAM(elemID).u     = BeamPVect.t(i,:);
                CBEAM(elemID).v     = cross(CBEAM(elemID).u,w_struct(i,:)')/norm(cross(CBEAM(elemID).u,w_struct(i,:)'));
                CBEAM(elemID).Xi(1) = CBEAM(elemID).v(1);
                CBEAM(elemID).Xi(2) = CBEAM(elemID).v(2);
                CBEAM(elemID).Xi(3) = CBEAM(elemID).v(3);
                % CBEAM(elemID).OFFT  = 
                % CBEAM(elemID).PA    = 
                % CBEAM(elemID).PB    = 
                % CBEAM(elemID).W1A   = 
                % CBEAM(elemID).W2A = 
                % CBEAM(elemID).W3A = 
                % CBEAM(elemID).W1A = 
                % CBEAM(elemID).W1A = 
                % CBEAM(elemID).W1A =  
                CBEAMwriter(fid,CBEAM(elemID));
                
                CBEAMIDs_WingBeam(i)=elemID;
            end
        %2.2.1.Save CBEAM IDs in a SET1
            setID=setID+1;
            SET1(setID).SID=setID; 
            SET1(setID).IDs=CBEAMIDs_WingBeam;
            fprintf(fid,'$Wing''s Wing CBEAM elem IDs \n'); 
            SET1writer(fid,SET1(setID));    
    end
%% 3.Aero-Struct Grids Interfaces 
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

        GRID(gridID).ID   = gridID;
        GRID(gridID).CP   = 0;%coordID;
        GRID(gridID).Xi(1)= WingLEPnt(i,1);
        GRID(gridID).Xi(2)= WingLEPnt(i,2);
        GRID(gridID).Xi(3)= WingLEPnt(i,3);
        GRID(gridID).CD   = 0;%coordID;
        
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

        GRID(gridID).ID   = gridID;
        GRID(gridID).CP   = 0;%coordID;
        GRID(gridID).Xi(1)= WingTEPnt(i,1);
        GRID(gridID).Xi(2)= WingTEPnt(i,2);
        GRID(gridID).Xi(3)= WingTEPnt(i,3);
        GRID(gridID).CD   = 0;%coordID;
        
        % GRIDwriter(fid,GRID(gridID));
        
        elemID=elemID+1;
        RBE2(elemID).EID=elemID;
        RBE2(elemID).GN=GridIDs_WingBeam(i);
        RBE2(elemID).CM=123456;
        RBE2(elemID).GMi=GridIDs_RBE2int(i,:);
        
        RBE2writer(fid,RBE2(elemID))    
    end    
    %3.2.1.Save interface GRID IDs in a SET1
            GridIDs_wingInter=[GridIDs_WingBeam sort(reshape(GridIDs_RBE2int,1,2*length(GridIDs_RBE2int(:,1))))];
            setID=setID+1;
            SET1(setID).SID=setID; 
            SET1(setID).IDs= GridIDs_wingInter;
            fprintf(fid,'$Wing''s Interface Grid IDs \n'); 
            SET1writer(fid,SET1(setID));
      
    % Grid writing
        fprintf(fid,'$Wing Grid\n');
        for i=1:length(GRID)
            GRIDwriter(fid,GRID(i));
        end
    end     
    fclose(fid);
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

        CORD2R(coordID).CID = coordID;
        CORD2R(coordID).RID = 0;
        CORD2R(coordID).Ai  = A;
        CORD2R(coordID).Bi  = B;
        CORD2R(coordID).Ci  = C;
    %Save data & write Card
        Nastran.CORD2R(coordID)=CORD2R(coordID);
        Nastran.coordIDs=[Nastran.coordIDs coordID];
        fprintf(fid,'$Coordinates System for Aerodynamic Box\n');
            CORD2Rwriter(fid,CORD2R(coordID));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %AEFACT LSPAN
        setID=setID+1;
        AEFACT(setID).SID = setID;
        AEFACT(setID).Di  = ABoxSect.Aefact_span;
    %Save data & write Card
        Nastran.AEFACT(setID)=AEFACT(setID);
        Nastran.aefactIDs=[Nastran.aefactIDs setID];
        fprintf(fid,'$Aerodynamic Box eta division\n');        
            AEFACTwriter(fid,AEFACT(setID));
    
    %AEFACT LCHORD
        setID=setID+1;
        AEFACT(setID).SID = setID;
        AEFACT(setID).Di  = ABoxSect.Aefact_chord;
    %Save data & write Card
        Nastran.AEFACT(setID)=AEFACT(setID);
        Nastran.aefactIDs=[Nastran.aefactIDs setID];
        fprintf(fid,'$Aerodynamic Box xsi division\n');
            AEFACTwriter(fid,AEFACT(setID));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CAERO1
        elemID=elemID+1;
        CAERO1(elemID).EID    = elemID;
        CAERO1(elemID).PID    = paeroID;
        CAERO1(elemID).CP     = coordID;   
        CAERO1(elemID).LSPAN  = setID-1;
        CAERO1(elemID).LCHORD = setID;
        CAERO1(elemID).IGID   = intgrID;
        % CAERO1(elemID).X1     = ABoxSect.X(1,1);
        % CAERO1(elemID).Y1     = ABoxSect.X(1,2);
        % CAERO1(elemID).Z1     = ABoxSect.X(1,3);
        % CAERO1(elemID).X12    = ABoxSect.X(2,1)-ABoxSect.X(1,1);
        % CAERO1(elemID).X4     = ABoxSect.X(4,1);
        % CAERO1(elemID).Y4     = ABoxSect.X(4,2);
        % CAERO1(elemID).Z4     = ABoxSect.X(4,3);
        % CAERO1(elemID).X43    = ABoxSect.X(3,1)-ABoxSect.X(4,1);
        CAERO1(elemID).X1     = 0;
        CAERO1(elemID).Y1     = 0;
        CAERO1(elemID).Z1     = 0;
        CAERO1(elemID).X12    = norm(ABoxSect.X(2,:)'-ABoxSect.X(1,:)');

        X4e=cos_e'*(ABoxSect.X(4,:)'-ABoxSect.X(1,:)');

        CAERO1(elemID).X4     = X4e(1);
        CAERO1(elemID).Y4     = X4e(2);
        CAERO1(elemID).Z4     = X4e(3);    
        CAERO1(elemID).X43    = norm(ABoxSect.X(3,:)'-ABoxSect.X(4,:)');
        %Define Number of Aero Box in CAERO1 (NB each of them must have an EID unique!!!) 
        Nbox=(length(ABoxSect.Aefact_span)-1)*(length(ABoxSect.Aefact_chord)-1)-1;
        CAERO1(elemID).Boxes  = [elemID elemID+Nbox];   

    %Verify plot
        X=[ABoxSect.X(1,1) ABoxSect.X(2,1);...
           ABoxSect.X(4,1) ABoxSect.X(3,1)];
        Y=[ABoxSect.X(1,2) ABoxSect.X(2,2);...
           ABoxSect.X(4,2) ABoxSect.X(3,2)];
        Z=[ABoxSect.X(1,3) ABoxSect.X(2,3);...
           ABoxSect.X(4,3) ABoxSect.X(3,3)];
         surf(X,Y,Z)
    %Save data & write Card
        Nastran.CAERO1(elemID)=CAERO1(elemID); 
        Nastran.caero1IDs=[Nastran.caero1IDs elemID];
        fprintf(fid,'$Aerodynamic Box\n');
            CAERO1writer(fid,CAERO1(elemID));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %SPLINE1
        %Define Interference Grids Set
        setID=setID+1;

        %Define surface spline
        elemID=elemID+Nbox+1;  
        SPLINE1(elemID).EID  =elemID;
        SPLINE1(elemID).CAERO=CAERO1(elemID-Nbox-1).EID;
        SPLINE1(elemID).BOX1 =CAERO1(elemID-Nbox-1).Boxes(1);
        SPLINE1(elemID).BOX2 =CAERO1(elemID-Nbox-1).Boxes(2);
        SPLINE1(elemID).SETG =setID;
    %Save data & write Card
        Nastran.SPLINE1(elemID)=SPLINE1(elemID);
        Nastran.spline1IDs=[Nastran.spline1IDs elemID];
        fprintf(fid,'$Spline interface Aerodynamic - Structure\n');    
            SPLINE1writer(fid,SPLINE1(elemID)); 
end
    
    
    