function jointStick_Fun3(component,Nfus,Nwing)
    global Guess
% clear all, close all, clc
%     Nfus =3;
%     Nwing=4;
%     component=7;
%     load Guess.mat
%     addpath('NastanWriter');
%     addpath('GuessWriter');
    
    fus_count=2;
    for j=1:Nfus
        for k=1:Nfus         
            clear dis disjkk kkmin disjk jjmin
            for jj=1:length(Guess.iFus{j}.GridIDs_WingBeam)                
                for kk=1:length(Guess.iFus{k}.GridIDs_WingBeam)                                        
                    dis(jj,kk)=norm(Guess.iFus{j}.GRID(Guess.iFus{j}.GID2gridIDs(Guess.iFus{j}.GridIDs_WingBeam(jj))).Xi'-...
                                    Guess.iFus{k}.GRID(Guess.iFus{k}.GID2gridIDs(Guess.iFus{k}.GridIDs_WingBeam(kk))).Xi');
                end
                [disjkk(jj) kkmin(jj)]=min(dis(jj,:));
            end
            [disjk jjmin]=min(disjkk);

            gridID_ffM(j,k)=jjmin;
            gridID_ffS(j,k)=kkmin(jjmin);
            minDis_ff(j,k) =disjk;                
        end
        for k=1:Nwing             
            clear dis disjkk kkmin disjk jjmin
            for jj=1:length(Guess.iFus{j}.GridIDs_WingBeam)
                %jj
                for kk=1:length(Guess.iWing{k}.GridIDs_WingBeam)                    
                    %kk
                    dis(jj,kk)=norm(Guess.iFus{j}.GRID( Guess.iFus{j}.GID2gridIDs( Guess.iFus{j}.GridIDs_WingBeam(jj))).Xi'-...
                                    Guess.iWing{k}.GRID(Guess.iWing{k}.GID2gridIDs(Guess.iWing{k}.GridIDs_WingBeam(kk))).Xi');                        
                end
                [disjkk(jj) kkmin(jj)]=min(dis(jj,:));
            end
            [disjk jjmin]=min(disjkk);

            gridID_fwM(j,k)=jjmin;
            gridID_fwS(j,k)=kkmin(jjmin);
            minDis_fw(j,k)    =disjk;                
        end           
    end
    for j=1:Nwing
        for k=1:Nfus            
            clear dis disjkk kkmin disjk jjmin
            for jj=1:length(Guess.iWing{j}.GridIDs_WingBeam)
                for kk=1:length(Guess.iFus{k}.GridIDs_WingBeam)                    
                    dis(jj,kk)=norm(Guess.iWing{j}.GRID(Guess.iWing{j}.GID2gridIDs(Guess.iWing{j}.GridIDs_WingBeam(jj))).Xi'-...
                                    Guess.iFus{k}.GRID(Guess.iFus{k}.GID2gridIDs(Guess.iFus{k}.GridIDs_WingBeam(kk))).Xi');                       
                end
                [disjkk(jj) kkmin(jj)]=min(dis(jj,:));
            end
            [disjk jjmin]=min(disjkk);

            gridID_wfM(j,k)=jjmin;
            gridID_wfS(j,k)=kkmin(jjmin);
            minDis_wf(j,k) =disjk;                
        end
        for k=1:Nwing            
            clear dis disjkk kkmin disjk jjmin
            for jj=1:length(Guess.iWing{j}.GridIDs_WingBeam)
                for kk=1:length(Guess.iWing{k}.GridIDs_WingBeam)                    
                    dis(jj,kk)=norm(Guess.iWing{j}.GRID(Guess.iWing{j}.GID2gridIDs(Guess.iWing{j}.GridIDs_WingBeam(jj))).Xi'-...
                                    Guess.iWing{k}.GRID(Guess.iWing{k}.GID2gridIDs(Guess.iWing{k}.GridIDs_WingBeam(kk))).Xi');                       
                end
                [disjkk(jj) kkmin(jj)]=min(dis(jj,:));
            end
            [disjk jjmin]=min(disjkk);

            gridID_wwM(j,k)=jjmin;
            gridID_wwS(j,k)=kkmin(jjmin);
            minDis_ww(j,k)    =disjk;                
        end
    end   
% Assembly
    grid_M=[gridID_ffM gridID_fwM;...
            gridID_wfM gridID_wwM];
    grid_S=[gridID_ffS gridID_fwS;...
            gridID_wfS gridID_wwS];
    minDis=[minDis_ff  minDis_fw;...
            minDis_wf  minDis_ww]; minDis=minDis+100*eye(component);
%min distance
    [vsort isort]=sort(minDis);
    isort
    grid_M
    grid_S
%component joints (min distance)
    for j=1:component
        joint_jk(j,:)=[j isort(1,j)]; joint_jk(j,:)=sort(joint_jk(j,:));
    end
    joint_jk
%check repetitions    
    for j=2:component
        cont=1;
        for i=1:j-1
            if joint_jk(j,:)==joint_jk(i,:)                    
                cont=cont+1;
                joint_jk(j,:)=[j isort(1+cont,j)]; joint_jk(j,:)=sort(joint_jk(j,:));
            end                      
        end
    end
    joint_jk
    
    global jointTable
    for i=1:component
        jointTable{i,1}=num2str(i); jointTable{i,2}=true; jointTable{i,3}=joint_jk(i,1);  jointTable{i,4}=joint_jk(i,2); jointTable{i,5}=0; 
    end
    %T=uitable;
    %set(T,'Data',jointTable);
%     'units','normalized',...
%     'position',[.0 .0 .5 .4],...
% Joints Table
    T=uitable('parent', figure(1),...    
    'position',[.0 .0 262 162],...
    'ColumnName',    {'Joint',  'Pres.','Master C.','Slave C.','CarryT.'},...
    'ColumnEditable',[  false,     true,       true,      true,     true],...
    'ColumnFormat'  ,{ 'char','logical',  'numeric', 'numeric','numeric'},...
    'ColumnWidth'   ,{40 40, 60, 60, 60},...
    'RowName',[],...
    'Visible','on',...
    'tag','Joint_Table',...
    'CellEditCallback',{@StickJoint_edit});
    set(T,'Data',jointTable);
% Continue Button
    h = uicontrol('position',[.0 162 50 20],... 
                  'String','Continue',...
                  'Callback','uiresume(gcbf)');
              %'Position',[20 20 200 40],'String','Continue',...
    disp('This will print immediately');
    uiwait(gcf);
    disp('Esecuzione ripresa') % <<<<<  ******************************
    for i=1:component
        joint_jk(i,1)=jointTable{i,3}; joint_jk(i,2)=jointTable{i,4};
    end        
    joint_jk
    
    EID=0; rbe2ID=0;
    pathSMDef = (strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'AcBSMDir\'))
    fid= fopen([strcat(pathSMDef,'Guess_joints.dat')],'w');
    %fid= fopen('Guess_joints.dat','w');
        for i=1:component
            
            % **** Aggiunto **********
            if jointTable{i,2}==false
               flag4NO = 0 
            else
               flag4NO = 1
            end
            % ************************
            
            % Generate 2 RBE2 on symmetry components
            if joint_jk(i,1)<=Nfus
                Var=Guess.iFus{joint_jk(i,1)}.Symm;
            else
                Var=Guess.iWing{joint_jk(i,1)-Nfus}.Symm;
            end
            
            if Var %Guess.iFus{joint_jk(i,1)}.Symm
                %1st RBE2
                EID=EID+1; rbe2ID=rbe2ID+1;
                RBE2.EID=EID;                

                if joint_jk(i,1)<=Nfus
                    RBE2.GN =Guess.iFus{joint_jk(i,1)      }.GRID(grid_M(joint_jk(i,1),joint_jk(i,2))).ID;  
                else
                    RBE2.GN =Guess.iWing{joint_jk(i,1)-Nfus}.GRID(grid_M(joint_jk(i,1),joint_jk(i,2))).ID;               
                end
                RBE2.CM=123456;
                if joint_jk(i,2)<=Nfus                
                    RBE2.GMi=Guess.iFus{joint_jk(i,2)      }.GRID(grid_M(joint_jk(i,2),joint_jk(i,1))).ID;                    
                else                      
                    RBE2.GMi=Guess.iWing{joint_jk(i,2)-Nfus}.GRID(grid_M(joint_jk(i,2),joint_jk(i,1))).ID;                    
                end
                RBE2;
   
                Guess.Joints{1}.RBE2(rbe2ID)=RBE2;
                RBE2writer(fid,flag4NO,Guess.Joints{1}.RBE2(rbe2ID)); % ****** Modificato: aggiunto flag4NO
                %2nd RBE2 (the symm one)
                EID=EID+1; rbe2ID=rbe2ID+1;
                RBE2.EID=EID; 
                RBE2.GN =Guess.Joints{1}.RBE2(rbe2ID-1).GN+500;
                RBE2.CM=123456;
                RBE2.GMi=Guess.Joints{1}.RBE2(rbe2ID-1).GMi+500;
                
%                 if joint_jk(i,1)<=Nfus
%                     RBE2.GN =Guess.iFus{joint_jk(i,1)      }.GRID(grid_M(joint_jk(i,1),joint_jk(i,2))+500).ID;  
%                 else
%                     RBE2.GN =Guess.iWing{joint_jk(i,1)-Nfus}.GRID(grid_M(joint_jk(i,1),joint_jk(i,2))+500).ID;               
%                 end
%                 RBE2.CM=123456;
%                 if joint_jk(i,2)<=Nfus                
%                     RBE2.GMi=Guess.iFus{joint_jk(i,2)      }.GRID(grid_M(joint_jk(i,2),joint_jk(i,1))+500).ID;                    
%                 else                      
%                     RBE2.GMi=Guess.iWing{joint_jk(i,2)-Nfus}.GRID(grid_M(joint_jk(i,2),joint_jk(i,1))+500).ID;                    
%                 end
                RBE2;
   
                Guess.Joints{1}.RBE2(rbe2ID)=RBE2;
                RBE2writer(fid,flag4NO,Guess.Joints{1}.RBE2(rbe2ID))  % ******Modificato aggiunto flag4NO
            %one RBE2 on two sym nodes    
            %elseif Guess.iFus{joint_jk(i,1)}.Symm==0
            else
                EID=EID+1; rbe2ID=rbe2ID+1;
                RBE2.EID=EID;
                
                if joint_jk(i,1)<=Nfus
                    RBE2.GN =Guess.iFus{joint_jk(i,1)      }.GRID(grid_M(joint_jk(i,1),joint_jk(i,2))).ID;  
                else
                    RBE2.GN =Guess.iWing{joint_jk(i,1)-Nfus}.GRID(grid_M(joint_jk(i,1),joint_jk(i,2))).ID;               
                end
                RBE2.CM=123456;
                if joint_jk(i,2)<=Nfus                
                    RBE2.GMi=Guess.iFus{joint_jk(i,2)      }.GRID(grid_M(joint_jk(i,2),joint_jk(i,1))).ID;
                    if Guess.iFus{joint_jk(i,2)}.Symm
                        RBE2.GMi(2)=RBE2.GMi(1)+500;
                    end
                else                      
                    RBE2.GMi=Guess.iWing{joint_jk(i,2)-Nfus}.GRID(grid_M(joint_jk(i,2),joint_jk(i,1))).ID;
                    if Guess.iWing{joint_jk(i,2)-Nfus}.Symm
                        RBE2.GMi(2)=RBE2.GMi(1)+500;
                    end
                end
                RBE2;
   
                Guess.Joints{1}.RBE2(rbe2ID)=RBE2;
                RBE2writer(fid,flag4NO,Guess.Joints{1}.RBE2(rbe2ID))  % ***** modificato Aggiunto flag4NO
            
            end
             
        end    
fclose(fid);
    disp ('Joint Stick Function terminata') % <<<< **********************
end

function StickJoint_edit(varargin)
global jointTable
    eventdata=varargin{2}
    jointTable{eventdata.Indices(1),eventdata.Indices(2)}=eventdata.NewData;    
end