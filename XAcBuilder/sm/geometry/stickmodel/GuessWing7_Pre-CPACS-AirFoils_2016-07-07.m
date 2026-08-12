%GuessWing
function GuessWing7(wingID,component,mir)
%clear all, close all,clc
global TechGeoModel Guess AcBuilderNameW supmob AcBuilderTechImp%wingID
global CID      GID    MID    EID             PID            SID 
global cord2rID gridID mat1ID cbarID caero1ID pbarID paeroID set1ID intgrID spline1ID

global MyDihedralFlag % Aggiunto
% global FlagDihAnh % Aggiunto

%addpath('NastanWriter');
%addpath('GuessWriter');

% %str='..\Technology\D150_Wing1.mat';
% %str='..\Technology\D150_BoxWing_Wing1.mat';
% %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_TechGeoModel.mat';
% str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150 for CPACS 1.3_TechGeoModel.mat';
% load(str)
% wingID  = 1;
% figure(1), hold on, axis equal
%symm(1)= 1; symm(2)=1; symm(3)= 1; FileOpt='w';
%% 0.Inizializating
    for kkkk=1
    if mir
        if TechGeoModel.iWing{wingID}.symmetry~=0
            supmob = 'l'; % LEFT SIDE
            if     strcmp(TechGeoModel.iWing{wingID}.symmetry,'x-z-plane'), symm(1)= 1; symm(2)=-1; symm(3)= 1; 
            elseif strcmp(TechGeoModel.iWing{wingID}.symmetry,'y-z-plane'), symm(1)=-1; symm(2)= 1; symm(3)= 1; 
            elseif strcmp(TechGeoModel.iWing{wingID}.symmetry,'x-y-plane'), symm(1)= 1; symm(2)= 1; symm(3)=-1; 
            end 
            FileOpt='a';
            
            %wingID, component
            Guess.iWing{wingID}.Symm=1;
            mat1ID=0;
            gridID=length(Guess.iWing{wingID}.GRID);        
            pbarID=length(Guess.iWing{wingID}.PBAR);    
            cbarID=length(Guess.iWing{wingID}.CBAR);
            set1ID=length(Guess.iWing{wingID}.SET1);
            %cord2rIDlength(Guess.iWing{wingID}.);
            rbe0ID=length(Guess.iWing{wingID}.RBE0); % ****** ERA COMMENTATO ********
            wingID
            caero1ID=length(Guess.iWing{wingID}.CAERO1)
            paeroID  =1;
            spline1ID=length(Guess.iWing{wingID}.SPLINE1);
            aelinkID=0;
            %caerobID =length(Guess.iWing{wingID}.CAEROB);
            
            CID=1000*component+500; 
            GID=1000*component+500; 
            MID=1000*component; 
            EID=1000*component+500; EIDaero=EID+100; 
            PID=1000*component+500; 
            SID=1000*component+500;
        end      
    else
        supmob = 'r' % RIGHT SIDE
        symm(1)= 1; symm(2)=1; symm(3)= 1; 
        FileOpt='w';
        Guess.iWing{wingID}.Symm=0;
        mat1ID  = 0;
        gridID  = 0;        
        pbarID  = 0;    
        cbarID  = 0;
        set1ID  = 0;
        cord2rID= 0;
        rbe0ID=0;

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
   
    BeamPoint.xBeam=symm(1)*TechGeoModel.iWing{wingID}.beamModel.Grid.xBeam;
    BeamPoint.yBeam=symm(2)*TechGeoModel.iWing{wingID}.beamModel.Grid.yBeam;
    BeamPoint.zBeam=symm(3)*TechGeoModel.iWing{wingID}.beamModel.Grid.zBeam;
    
    %{
    pntFwSpar(:,1)=symm(1).*TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{ 1 }.xSP0(:,1);
    pntFwSpar(:,2)=symm(2).*TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{ 1 }.xSP0(:,2);
    pntFwSpar(:,3)=symm(3).*TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{ 1 }.xSP0(:,3);
    
    pntAfSpar(:,1)=symm(1).*TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{end}.xSP0(:,1);
    pntAfSpar(:,2)=symm(2).*TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{end}.xSP0(:,2);
    pntAfSpar(:,3)=symm(3).*TechGeoModel.iWing{wingID}.Geometry.Strucuture.Spar.iSpar{end}.xSP0(:,3);
    %}
    
    % **********************************************
    pntFwSpar(:,1)=symm(1).*TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar{ 1 }.xSP0(:,1);
    pntFwSpar(:,2)=symm(2).*TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar{ 1 }.xSP0(:,2);
    pntFwSpar(:,3)=symm(3).*TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar{ 1 }.xSP0(:,3);
    
    pntAfSpar(:,1)=symm(1).*TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar{end}.xSP0(:,1);
    pntAfSpar(:,2)=symm(2).*TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar{end}.xSP0(:,2);
    pntAfSpar(:,3)=symm(3).*TechGeoModel.iWing{wingID}.Geometry.Structure.Spar.iSpar{end}.xSP0(:,3);
    % ***********************************************
    
    TechGeoModel
    aeroPanel=TechGeoModel.iWing{wingID}.aeroPanel;
    
    for k=1:length(aeroPanel.SectWing)
        aeroPanel.SectWing{k}.X(:,1)=symm(1).*aeroPanel.SectWing{k}.X(:,1);
        aeroPanel.SectWing{k}.X(:,2)=symm(2).*aeroPanel.SectWing{k}.X(:,2);
        aeroPanel.SectWing{k}.X(:,3)=symm(3).*aeroPanel.SectWing{k}.X(:,3);
        try
            DimTED=size(TechGeoModel.iWing{wingID}.aeroPanel.SectTED);           
            for j=1:DimTED(2)                 
                if ~isempty(TechGeoModel.iWing{wingID}.aeroPanel.SectTED{k,j})                 
                    aeroPanel.SectTED{k,j}.X(:,1)=symm(1).*aeroPanel.SectTED{k,j}.X(:,1);
                    aeroPanel.SectTED{k,j}.X(:,2)=symm(2).*aeroPanel.SectTED{k,j}.X(:,2);
                    aeroPanel.SectTED{k,j}.X(:,3)=symm(3).*aeroPanel.SectTED{k,j}.X(:,3);                
                end
            end
        end
    end
    

      
    %Global number
    Npos=length(TechGeoModel.iWing{wingID}.Geometry.sectID(:,1));
    end
%% 1.Beam model
    for kkkk=1
    fid= fopen(['Guess_Struct_wing',num2str(wingID),'.dat'],FileOpt);
        
    % 1.1.Material
        for kk=1
            MID=MID+1;
            mat1ID=mat1ID+1; 
            MID2mat1IDs(MID)=mat1ID;
            if mir==0
                % Aggiunto Switch per dati Materiale in arrivo da AcBuilder
           switch AcBuilderNameW{wingID}
            case 'Wing1'
            MAT1.MID = MID;
            MAT1.E   =  AcBuilderTechImp.EWing1;%7.1e10;
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
            
            case 'WingMK'
            MAT1.MID = MID;
            MAT1.E   =  AcBuilderTechImp.EWingMK;%7.1e10;
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
            
            case 'H_Tail'
            MAT1.MID = MID;
            MAT1.E   =  AcBuilderTechImp.EHT;%7.1e10;
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
            
            case 'V_Tail'
            MAT1.MID = MID;
            MAT1.E   =  AcBuilderTechImp.EVT;%7.1e10;
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
            
            case 'Canard'
            MAT1.MID = MID;
            MAT1.E   =  AcBuilderTechImp.ECan;%7.1e10;
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
            
               otherwise
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
           end
            
            
            Guess.iWing{wingID}.MAT1(mat1ID)=MAT1;
            %Guess.iWing{wingID}.mat1IDs=[Guess.iWing{wingID}.mat1IDs matID];
            fprintf(fid,['$Material for wing ',num2str(wingID),'\n']);
            MAT1writer(fid,MAT1);
            end
        end      
        %BeamPoint=TechGeoModel.iWing{wingID}.beamModel.Grid;
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
%         [v_max iv_max]=max(abs(BeamPVect.pntP))
%         [dv idvmax]=max(v_max-abs(BeamPVect.pntP(1,:)))
%         BeamPVect.t( 1 ,:)=[0 0 0]; BeamPVect.t( 1 ,idvmax)=1%*symm(idvmax);
%         BeamPVect.t(end,:)=[0 0 0]; BeamPVect.t(end,idvmax)=1%*symm(idvmax);
        BeamPVect.t( 1 ,1)=0;
        BeamPVect.t(end,1)=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FwSparPVect=posVectFun(1,1,pntFwSpar,[0 0 0]');
        AfSparPVect=posVectFun(1,1,pntAfSpar,[0 0 0]');
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
            if j==length(FwSparPVect.pnt0(:,1)), j=j-1; end
            if j<=0, j=1; end
            [C,t]=myIntersectLinePlane(FwSparPVect.pnt0(j,:)',FwSparPVect.pnt0(j+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',1); %1
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
            if h>=length(AfSparPVect.pnt0(:,1)); h=h-1; end
            [C,t]=myIntersectLinePlane(AfSparPVect.pnt0(h,:)',AfSparPVect.pnt0(h+1,:)',BeamPVect.pnt0(i,:)',BeamPVect.t(i,:)',1); %1
            AfSparPnt(i,:)=C';
        %Width Structure Box    
            Width(i)=norm(AfSparPnt(i,:)' -FwSparPnt(i,:)');
            Height(i)=Width(i)/4;
            w_struct(i,:)=(AfSparPnt(i,:)'-FwSparPnt(i,:)')'/norm(AfSparPnt(i,:)'-FwSparPnt(i,:)');
        end         
    % 1.4.Weight control
        Mass=1000; toll=1e-3; if TechGeoModel.iWing{wingID}.symmetry~=0, Mass=Mass/2; end
        M=0; iter=1;
        t=0.002; 
        while iter<100            
            for i=1:Ngrid-1
                a=(Width(i)  + Width(i+1))/2;
                b=(Height(i)  +Height(i+1))/2;
                Vi(i)=(a*b-(a-2*t)*(b-2*t))*BeamPVect.li(i+1);
                mi(i)=Vi(i)*Guess.iWing{wingID}.MAT1(1).RHO;
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
        %M,iter
        disp(['Mass achieved ',num2str(M),' kg, in ',num2str(iter),' iteration']);
        figure(1)       
    % 1.5.Bar model function
        bar_modelFun(fid,wingID,XBeam,Width,Height,t,w_struct,BeamPVect)
% 1.6.Interface Grids
% ***************** ERA COMMENTATO ***************************************
        %GID=GIDint+200
         Ngrid=length(XBeam);
         for i=1:Ngrid 
             GID=GID+1; gridID=gridID+1;
   
             GRID.ID   = GID;
             GRID.CP   = 0;%coordID;
             GRID.Xi(1)= FwSparPnt(i,1);
             GRID.Xi(2)= FwSparPnt(i,2);
             GRID.Xi(3)= FwSparPnt(i,3);
             GRID.CD   = 0;%coordID;
 
             Guess.iWing{wingID}.GRID(gridID)=GRID;
             Guess.iWing{wingID}.GID2gridIDs(GID)=gridID;
  
             plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',3)
             
             
             GID=GID+1; gridID=gridID+1;
             
             GRID.ID   = GID;
             GRID.CP   = 0;%coordID;
             GRID.Xi(1)= AfSparPnt(i,1);
             GRID.Xi(2)= AfSparPnt(i,2);
             GRID.Xi(3)= AfSparPnt(i,3);
             GRID.CD   = 0;%coordID;
 
             Guess.iWing{wingID}.GRID(gridID)=GRID;
             Guess.iWing{wingID}.GID2gridIDs(GID)=gridID;
  
             plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',1)
             
                         rbe0ID=rbe0ID+1;
             EIDint=EIDint+1;
             RBE0.ID    = EIDint;
             RBE0.GM= EIDint;
             RBE0.GSi= [GID-2:GID];
             Guess.iWing{wingID}.RBE0(rbe0ID)=RBE0;
              %Guess.iWing{wingID}.EID2eIDs(EID)=rbe0ID;
             RBE0writerG(fid,Guess.iWing{wingID}.RBE0(rbe0ID))
 %             for ind=1:2                                
 %                 plot3([Guess.iWing{wingID}.GRID(Guess.iWing{wingID}.RBE0(rbe0ID).ID-component*1000).Xi(1) Guess.iWing{wingID}.GRID(Guess.iWing{wingID}.RBE0(rbe0ID).GSi(ind)-component*1000).Xi(1)],...
 %                       [Guess.iWing{wingID}.GRID(Guess.iWing{wingID}.RBE0(rbe0ID).ID-component*1000).Xi(2) Guess.iWing{wingID}.GRID(Guess.iWing{wingID}.RBE0(rbe0ID).GSi(ind)-component*1000).Xi(2)],...
 %                       [Guess.iWing{wingID}.GRID(Guess.iWing{wingID}.RBE0(rbe0ID).ID-component*1000).Xi(3) Guess.iWing{wingID}.GRID(Guess.iWing{wingID}.RBE0(rbe0ID).GSi(ind)-component*1000).Xi(3)],'g')
 %             end
         end
% ************************************************************************    
    % 1.7.Grid writing
        fprintf(fid,'$Wing Grid\n');
        for i=1:length(Guess.iWing{wingID}.GRID)
            GRIDwriter(fid,Guess.iWing{wingID}.GRID(i));
        end   
       
    fclose(fid);
    end 
%% 2.Aerodynamic Mesh Generator
% ********************************* ERA COMMENTATA ************************
     for kkkk=1
     EID=EIDaero; SID=EIDaero;
     fid= fopen(['Guess_AeroPan_wing',num2str(wingID),'.dat'],FileOpt);
     
     fprintf(fid,'$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
     if strcmp(FileOpt,'w'), fprintf(fid,'Wing %d \n',wingID); else, fprintf(fid,'Symmetry of Wing %d \n',wingID); end
     for i=1:Npos
         IDSect4ABox = i;
         % ************** Check Diedro Aggiunto **********************
         disp('Diedro in TechGeoMOd')
         %save('g:\teststruct.mat','TechGeoModel')
         if (TechGeoModel.iWing{1,wingID}.Geometry.dihedral(1,i)<0)
             MyDihedralFlag = -1;
         else
             MyDihedralFlag =  1;
         end
         % *************** Fine Check Diedro **************************
         
     %Central Wing Aerodynamic Boxes
         fprintf(fid,'$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
 %         fprintf(fid,'%s\n',['$Aero Panel section ',num2str(i)]);
         fprintf(fid,'%s\n',['$Section ',num2str(i)]);
         AeroBoxFun(fid,wingID,aeroPanel.SectWing{i},0,IDSect4ABox,aeroPanel);        
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
         GridInBoxIDs=findSetInDomain(wingID,aeroPanel.SectWing{i},Guess.iWing{wingID}.GridIDs_WingBeam,0); %solo sulla beam
         figure(1)%back to main figure 
 
         SID=EID; 
         SET1.SID=SID; 
         SET1.IDs= GridInBoxIDs;  
 
         set1ID=set1ID+1;
         Guess.iWing{wingID}.SET1(set1ID)=SET1;
         Guess.iWing{wingID}.SID2set1IDs(EID)=set1ID;
         %fprintf(fid,'$Set of Interface Aero-Struct Grids \n'); 
             SET1writer(fid,SET1);         
     %TED Aerodynamic Boxes
         try            
             DimTED=size(TechGeoModel.iWing{wingID}.aeroPanel.SectTED); 
             NTEDbox=0;
             for j=1:DimTED(2)                 
                 if ~isempty(TechGeoModel.iWing{wingID}.aeroPanel.SectTED{i,j}) 
                     if mir==0, NTEDbox=NTEDbox+1; end
                     fprintf(fid,'$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
 %                     fprintf(fid,'%s\n',['$Aero Panel section ',num2str(i),', TED box Section ',num2str(j)]);  
                     fprintf(fid,'%s\n',['$Section ',num2str(i),', TED box Section ',num2str(j)]);
                     
                     try
                         aeroPanel.SectTED{i,j}.name;
                         if strcmp(aeroPanel.SectTED{i,j}.name,'Fix'), Flag=0;  else Flag=1;  end                        
                     catch
                         Flag=0;
                     end
                     
                     if mir, aeroPanel.SectTED{i,j}.name=['S',char(aeroPanel.SectTED{i,j}.name)]; end
                     
                     AeroBoxFun(fid,wingID,aeroPanel.SectTED{i,j},Flag);
                                                                 
                     SID=EID; set1ID=set1ID+1; 
                     SET1.SID=SID;
                     SET1.IDs= GridInBoxIDs;  
 
                     set1ID=caero1ID;
                     Guess.iWing{wingID}.SET1(set1ID)=SET1;
                     Guess.iWing{wingID}.SID2set1IDs(EID)=set1ID;
                     %fprintf(fid,'$Set of Interface Aero-Struct Grids \n'); 
                         SET1writer(fid,SET1);     
                         
                     if mir && Flag 
                         aelinkID=aelinkID+1;
                         AELINK.ID    =EID-500;
                         AELINK.LABEL1=Guess.iWing{wingID}.CAERO1(EID-500-100-component*1000        ).NAM;
                         AELINK.LABEL2=Guess.iWing{wingID}.CAERO1(EID-500-100-component*1000+NTEDbox).NAM;
                         if strcmpi(AELINK.LABEL1,'Aileron')
                             AELINK.C1=1;
                         else
                             AELINK.C1=-1;
                         end
                         %AELINK;
                         Guess.iWing{wingID}.AELINK(aelinkID)=AELINK;
                             AELINKwriter(fid,AELINK);
                     end
                end
             end
         catch
             disp(['$No TED devices on ',num2str(wingID),' at section',num2str(i)])
         end                                 
     end
     fclose(fid); 
     end
% ***********************************************************************
%% 3.Save Data
% ************************** ERA COMMENTATO ******************************
     save('Guess.mat','Guess')
% ************************************************************************     
end
%% Structure model generator
function bar_modelFun(fid,wingID,XBeam,Width,Height,Thick,w_struct,BeamPVect)
global Guess %wingID %TechGeoModel  wingID
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

        Guess.iWing{wingID}.GRID(gridID)=GRID;
        Guess.iWing{wingID}.GID2gridIDs(GID)=gridID;
%            Guess.iWing{wingID}.gridStructIDs=[Guess.iWing{wingID}.gridStructIDs gridID];
        %fprintf(fid,'$Grid Wing\n');
        %GRIDwriter(fid,GRID(gridID));

        plot3(GRID.Xi(1),GRID.Xi(2),GRID.Xi(3),'rd','MarkerSize',3)
    end
 
    %1.2.Bar Property & Element
    for i=1:Ngrid-1
        %Property
        PID=PID+1;
        pbarID=pbarID+1;
        Guess.iWing{wingID}.PID2pbarIDs(PID)=pbarID;
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

        Guess.iWing{wingID}.PBAR(pbarID)=PBAR;
            PBARwriter(fid,PBAR);

    %1.3.Cbar element
        EID=EID+1;
        cbarID=cbarID+1;
        Guess.iWing{wingID}.EID2cbarIDs(EID)=cbarID;

        CBAR.EID   = EID; 
        CBAR.PID   = PID; 
        CBAR.GA    = GridIDs_WingBeam(i);
        CBAR.GB    = GridIDs_WingBeam(i+1);

        CBAR.u     = BeamPVect.t(i,:);
        CBAR.v     = -cross(CBAR.u,w_struct(i,:)')/norm(cross(CBAR.u,w_struct(i,:)'));
        CBAR.Xi(1) = CBAR.v(1);
        CBAR.Xi(2) = CBAR.v(2);
        CBAR.Xi(3) = CBAR.v(3);

        Guess.iWing{wingID}.CBAR(cbarID)=CBAR;
        % fprintf(fid,'$Wing''s cbar elem \n'); 
            CBARwriter(fid,CBAR);

        CBAREIDs_WingBeam(i)=EID;
    end

    %1.4.Save Grids in a Set
        SID=SID+1;
        set1ID=set1ID+1;
        Guess.iWing{wingID}.SID2set1IDs(SID)=set1ID;

        SET1.SID=SID; 
        SET1.IDs=GridIDs_WingBeam; Guess.iWing{wingID}.GridIDs_WingBeam=GridIDs_WingBeam;

        Guess.iWing{wingID}.SET1(set1ID)=SET1;
        %Guess.iWing{wingID}.set1IDs=[Guess.iWing{wingID}.set1IDs setID];
        fprintf(fid,'$Set Grid Wing\n'); 
%%%        SET1writer(fid,SET1(set1ID));   
        SET1writer(fid,SET1);
    %1.5.Save CBAR IDs in a SET1
        SID=SID+1;
        set1ID=set1ID+1;
        Guess.iWing{wingID}.SID2set1IDs(SID)=set1ID;

        SET1.SID=SID; 
        SET1.IDs=CBAREIDs_WingBeam;

        Guess.iWing{wingID}.SET1(set1ID)=SET1;
        %Guess.iWing{wingID}.set1IDs=[Guess.iWing{wingID}.set1IDs setID];
        fprintf(fid,'$Wing''s Wing CBAR elem IDs \n'); 
            SET1writer(fid,SET1);         
    
end
%% Aerodynamic Box Generator
function AeroBoxFun(fid,wingID,ABoxSect,FlagMovSurf,IDSect4ABoxTransf,AcPanImp)
global Guess
global CID      GID    MID    EID             PID            SID 
global cord2rID gridID mat1ID cbarID caero1ID pbarID paeroID set1ID intgrID spline1ID
global FlagDihAnh % Aggiunto
global MyDihedralFlag AcBuilderNameW AcBuilderTechImp supmob% Aggiunto
ABoxSect % Aggiunto
    rad=pi/180;    
    %CAERO1       
        caero1ID=caero1ID+1; EID=EID+1; %SID=EID+1;
        CAERO1.EID    = EID;
               
        CAERO1.CP     = 0; 
        CAERO1.NY     = AcPanImp.ny(IDSect4ABoxTransf);%length(ABoxSect.Aefact_span)-1;
        CAERO1.NX     = AcPanImp.nx(IDSect4ABoxTransf);%length(ABoxSect.Aefact_chord)-1;
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
        SWP1        = atan((v14(1)+0.25*v43(1)-0.25*v12(1))/lenghtYZ )/rad                                        % NO Dihedral < 0
        SWP2        = atan( ( (ABoxSect.X(4,1)+0.25*v43(1)) - (ABoxSect.X(1,1)+0.25*v12(1)) ) / lenghtYZ )/rad    % OK Dihedral > 0
        SWP3        = atan( ( (ABoxSect.X(4,1)+0.25*v43(1)) - (ABoxSect.X(1,1)+0.25*v12(1)) ) / abs(v14(2)) )/rad % NO Errore
        SWP4        = atan( ( (ABoxSect.X(4,1))             - (ABoxSect.X(1,1)) )             / abs(v14(2)) )/rad % NO Errore
        SWP5        = atan( ( (ABoxSect.X(4,1))             - (ABoxSect.X(1,1)) )             / lenghtYZ    )/rad
        SWP6        = asin( ( (ABoxSect.X(4,1)+0.25*v43(1)) - (ABoxSect.X(1,1)+0.25*v12(1)) ) / lenghtYZ )   /rad % NO Dihedra < 0
        SWP7        = asin(   (ABoxSect.X(4,1)              -  ABoxSect.X(1,1))               / lenghtYZ )   /rad
        CAERO1.SWP  = SWP2; % era SWP7
        
        CAERO1.DIH  = acos( v14(2)/lenghtYZ )/rad % ** +/- Per dihedral/anhedral
        disp('### Angolo DIEDRO')       % *************
        v14(2)                          % *************
        % *************** Aggiunto ********************
        %if (FlagDihAnh(wingID,fid)<0)
        %    KDihAnh = -1
        %else
        %    KDihAnh =  1
        %end
        % *********************************************
        
        % *********************************************
        if abs(CAERO1.DIH) == 90
            CAERO1.DIH  = acos( v14(2)/lenghtYZ )/rad
        else
            CAERO1.DIH  = MyDihedralFlag * acos( v14(2)/lenghtYZ )/rad %**-
        end
        % *********************************************
        
        if CAERO1.DIH<90                                 % ** 90 
            disp('ANHEDRAL')
            CAERO1.TW1  = acos( v12(1)/norm(v12))/rad; % ** +
            CAERO1.TW2  = acos( v43(1)/norm(v43))/rad; % ** +
            %CAERO1.DIH  = -acos( v14(2)/lenghtYZ )/rad; % ** Aggiunto
        else
            disp('DIHEDRAL')
            CAERO1.TW1  = -acos( v12(1)/norm(v12))/rad;
            CAERO1.TW2  = -acos( v43(1)/norm(v43))/rad;
            %CAERO1.DIH  = acos( v14(2)/lenghtYZ )/rad; % ** Aggiunto
        end
        
        
        
        if FlagMovSurf
            CAERO1.FLP  = FlagMovSurf;
            CAERO1.FC(1)= 1;%0.2;
            CAERO1.FC(2)= 1;%0.2;
            CAERO1.FNX  = length(ABoxSect.Aefact_chord)-1;
            
%             NAM=char(CAERO1.NAM)
%             if length(NAM)>8, NAM=NAM(1:8), end
            NAM=char(ABoxSect.name);
            if length(NAM)>8, NAM=NAM(1:8); end
            CAERO1.NAM  = NAM;              ABoxSect.name; %aeroPanel.SectTED{i,j}.name;
        else
            % Inizializzazione CARD CAERO1
            CAERO1.FLP  = [];
            CAERO1.FC   = [];            
            CAERO1.FNX  = [];
            CAERO1.NAM  = [];
        %end
        
        % ****************************************************
        AcBuilderNameW{wingID}
        IDSect4ABoxTransf
        %supmob = 'r';
        % ************************
        AddSplineK=0;
        switch AcBuilderNameW{wingID}
            
            case 'Wing1'
            
            if AcBuilderTechImp.MobSurfWing1(1) == 1 &&  IDSect4ABoxTransf<3  
            CAERO1.FLP  = 1;
            CAERO1.FC(1)= AcBuilderTechImp.MobSurfWing1(IDSect4ABoxTransf*2);%0.2;
            CAERO1.FC(2)= AcBuilderTechImp.MobSurfWing1(1+IDSect4ABoxTransf*2);%0.2;
            %CAERO1.FNX  = 5;%length(ABoxSect.Aefact_chord)-1;
            CAERO1.FNX  = AcBuilderTechImp.Wing1A(3+IDSect4ABoxTransf);
            CAERO1.NAM  = strcat('flW1',mat2str(IDSect4ABoxTransf),supmob);
            AddSplineK = CAERO1.NY * CAERO1.FNX
            end
            
            if AcBuilderTechImp.MobSurfWing1(6) == 1 &&  IDSect4ABoxTransf>2 % MAX Section  
            CAERO1.FLP  = 1;
            CAERO1.FC(1)= AcBuilderTechImp.MobSurfWing1(1+IDSect4ABoxTransf*2);%0.2;
            CAERO1.FC(2)= AcBuilderTechImp.MobSurfWing1(1+IDSect4ABoxTransf*2);%0.2;
            %CAERO1.FNX  = 3;
            CAERO1.FNX  = AcBuilderTechImp.Wing1A(3+IDSect4ABoxTransf);
            CAERO1.NAM  = strcat('aiW1',mat2str(IDSect4ABoxTransf),supmob);
            AddSplineK = CAERO1.NY * CAERO1.FNX
            end
            
            case 'Wing2'
            %component = 6 
            
            case 'H_Tail'
            if AcBuilderTechImp.MobSurfHT(1) == 1 &&  IDSect4ABoxTransf<3  
            CAERO1.FLP  = 1;
            CAERO1.FC(1)= AcBuilderTechImp.MobSurfHT(2);%0.2;
            CAERO1.FC(2)= AcBuilderTechImp.MobSurfHT(2);%0.2;
            if IDSect4ABoxTransf == 1
                JKID = 3;
            else
                JKID = 4;
            end
            CAERO1.FNX  = AcBuilderTechImp.HTailA(JKID+IDSect4ABoxTransf);
            %CAERO1.FNX  = 5;%length(ABoxSect.Aefact_chord)-1;
            CAERO1.NAM  = strcat('elHT',mat2str(IDSect4ABoxTransf),supmob);
            AddSplineK = CAERO1.NY * CAERO1.FNX
            end
            
            case 'V_Tail'
            if AcBuilderTechImp.MobSurfVT(1) == 1 &&  IDSect4ABoxTransf<3  
            CAERO1.FLP  = 1;
            CAERO1.FC(1)= AcBuilderTechImp.MobSurfVT(2);%0.2;
            CAERO1.FC(2)= AcBuilderTechImp.MobSurfVT(2);%0.2;
            if IDSect4ABoxTransf == 1
                JKID = 3;
            else
                JKID = 4;
            end
            CAERO1.FNX  = AcBuilderTechImp.VTailA(JKID+IDSect4ABoxTransf);
            %CAERO1.FNX  = 5;%length(ABoxSect.Aefact_chord)-1;
            CAERO1.NAM  = strcat('ruVT',mat2str(IDSect4ABoxTransf),supmob);
            AddSplineK = CAERO1.NY * CAERO1.FNX
            end 
            
            case 'Canard'
            if AcBuilderTechImp.MobSurfCN(1) == 1 &&  IDSect4ABoxTransf<3  
            CAERO1.FLP  = 1;
            CAERO1.FC(1)= AcBuilderTechImp.MobSurfCN(2);%0.2;
            CAERO1.FC(2)= AcBuilderTechImp.MobSurfCN(2);%0.2;
            if IDSect4ABoxTransf == 1
                JKID = 3;
            else
                JKID = 4;
            end
            CAERO1.FNX  = AcBuilderTechImp.CanardA(JKID+IDSect4ABoxTransf);%5;%length(ABoxSect.Aefact_chord)-1;
            CAERO1.NAM  = strcat('elCN',mat2str(IDSect4ABoxTransf),supmob);
            AddSplineK = CAERO1.NY * CAERO1.FNX
            end
            
            case 'WingMK'
            if AcBuilderTechImp.MobSurfWingMK(1) == 1 &&  IDSect4ABoxTransf<11  
            CAERO1.FLP  = 1;
            CAERO1.FC(1)= AcBuilderTechImp.MobSurfWingMK(IDSect4ABoxTransf*2);%0.2;
            CAERO1.FC(2)= AcBuilderTechImp.MobSurfWingMK(1+IDSect4ABoxTransf*2);%0.2;
            CAERO1.FNX  = AcBuilderTechImp.WingMKA(11+IDSect4ABoxTransf);%5;%length(ABoxSect.Aefact_chord)-1;
            CAERO1.NAM  = strcat('flMK',mat2str(IDSect4ABoxTransf),supmob);
            AddSplineK = CAERO1.NY * CAERO1.FNX
            % Interruzione Flap
            if CAERO1.FC(1) == 0.0 || CAERO1.FC(2) == 0
               CAERO1.FLP  = 0;
               AddSplineK = 0;
            end
            end
            
            if AcBuilderTechImp.MobSurfWingMK(22) == 1 &&  IDSect4ABoxTransf>10  
            CAERO1.FLP  = 1;
            CAERO1.FC(1)= AcBuilderTechImp.MobSurfWingMK(1+IDSect4ABoxTransf*2);%0.2;
            CAERO1.FC(2)= AcBuilderTechImp.MobSurfWingMK(1+IDSect4ABoxTransf*2);%0.2;
            CAERO1.FNX  = AcBuilderTechImp.WingMKA(11+IDSect4ABoxTransf);%5;%length(ABoxSect.Aefact_chord)-1;
            CAERO1.NAM  = strcat('aiMK',mat2str(IDSect4ABoxTransf),supmob);
            AddSplineK = CAERO1.NY * CAERO1.FNX
            end
            
            case 'WingLet1'
            %component = 8
            case 'WingLet2' % Non implementato !!!
            %component = 9
            case 'WingLetMK'
            %component = 10
            otherwise
            %component=component+1;    
        end
        % ************************
        % ****************************************************
        end
        
        %Define Number of Aero Box in CAERO1 (NB each of them must have an EID unique!!!) 
        Nbox=(length(ABoxSect.Aefact_span)-1)*(length(ABoxSect.Aefact_chord)-1)-1;
        
        Nbox =  AcPanImp.ny(IDSect4ABoxTransf) * AcPanImp.nx(IDSect4ABoxTransf)-1 % Aggiunto
        
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
        Guess.iWing{wingID}.CAERO1(caero1ID)=CAERO1; 
        
        Guess.iWing{wingID}.EID2caero1IDs(EID)=caero1ID;
        %Guess.iWing{wingID}.caero1IDs=[Guess.iWing{wingID}.caero1IDs elemID];
        %fprintf(fid,'$Aerodynamic Box\n');            
            %CAERO1writerG(fid,CAERO1,FlagMovSurf);
            CAERO1writerG(fid,CAERO1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SPLINE1 Define surface spline                
        SPLINE1.EID  =EID;
        SPLINE1.CAERO=CAERO1.EID;
        SPLINE1.BOX1 =CAERO1.Boxes(1);
        SPLINE1.BOX2 =AddSplineK+CAERO1.Boxes(2);
        SPLINE1.SETG =EID; %SID
    %Save data & write Card
        spline1ID=caero1ID;
        Guess.iWing{wingID}.SPLINE1(spline1ID)=SPLINE1;
        Guess.iWing{wingID}.EID2spline1IDs(EID)=spline1ID;
        %Guess.iWing{wingID}.spline1IDs=[Guess.iWing{wingID}.spline1IDs elemID];
        %fprintf(fid,'$Spline interface Aerodynamic - Structure\n');    
            SPLINE1writer(fid,SPLINE1); 
end
