function jointStick_Fun(component,Nfus,Nwing)
    global Guess
clear all, close all, clc
    Nfus =3;
    Nwing=4;
    component=7;
    load Guess.mat
    addpath('NastanWriter');
    addpath('GuessWriter');
    
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
    
%     gridID_ffM
%     gridID_ffS
%     minDis_ff,
%     
%     gridID_fwM
%     gridID_fwS
%     minDis_fw
%     
%     gridID_wwM
%     gridID_wwS
%     minDis_ww
    % assembly
    gridID_wfM
    grid_M=[gridID_ffM gridID_fwM;...
            gridID_wfM gridID_wwM];
    grid_S=[gridID_ffS gridID_fwS;...
            gridID_wfS gridID_wwS];
    minDis=[minDis_ff  minDis_fw;...
            minDis_wf  minDis_ww]; minDis=minDis+100*eye(component);
        
    [vsort isort]=sort(minDis);
    isort
%     %%%%%%%%%%%%%%%%%%%%
    grid_M
%     for i=1:7,grid_M(:,i)=grid_M(isort(:,i),i); end, 
%     grid_M
%     grid_S
%     for i=1:7,grid_S(:,i)=grid_M(isort(:,i),i); end, 
    grid_S
%     %%%%%%%%%%%%%%%%
    for j=1:component
        joint_jk(j,:)=[j isort(1,j)]; joint_jk(j,:)=sort(joint_jk(j,:));
    end
    joint_jk
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
        jointTable{i,1}=[num2str(i)]; jointTable{i,2}=''; jointTable{i,3}=joint_jk(i,1);  jointTable{i,4}=joint_jk(i,2);
    end
    %T=uitable;
    %set(T,'Data',jointTable);
    
    T=uitable('parent', figure(1),...
    'units','normalized',...
    'position',[0.0 0.0 .6 .4],...
    'ColumnName',{'Joint','Name','Master Comp','Slave Comp'},...
    'ColumnEditable',[false,true,true,true],...
    'ColumnFormat',{'char','char','numeric','numeric'},...
    'RowName',[],...
    'Visible','on',...
    'tag','Joint_Table',...
    'CellEditCallback',{@StickJoint_edit});
    set(T,'Data',jointTable);
    
    
    h = uicontrol('units',   'normalized',...
                  'position',[0.0 0.95 0.3 .3],... 
                  'String','Done',...
                  'Callback','uiresume(gcbf)');
              %'Position',[20 20 200 40],'String','Continue',...
    disp('This will print immediately');
    uiwait(gcf); 
    for i=1:component
        joint_jk(i,1)=jointTable{i,3}; joint_jk(i,2)=jointTable{i,4};
    end
    
    
    joint_jk
    
    EID=0; rbe2ID=0;
    fid= fopen('Guess_joints.dat','w');
        for i=1:component
            EID=EID+1; rbe2ID=rbe2ID+1;
            RBE2.EID=EID;
            grid_M(joint_jk(i,1),i)
            grid_S(joint_jk(i,2),i)
            if joint_jk(i,1)<=Nfus && joint_jk(i,2)<=Nfus
                RBE2.GN =Guess.iFus{joint_jk(i,1)}.GRID(grid_M(joint_jk(i,1),i)).ID;
                RBE2.CM=123456;
                RBE2.GMi=Guess.iFus{joint_jk(i,2)}.GRID(grid_S(joint_jk(i,2),i)).ID;
            elseif joint_jk(i,1)<=Nfus && joint_jk(i,2)>Nfus
                RBE2.GN =Guess.iFus{joint_jk(i,1)}.GRID(grid_M(joint_jk(i,1),i)).ID;
                RBE2.CM=123456;
                RBE2.GMi=Guess.iWing{joint_jk(i,2)-Nfus}.GRID(grid_S(joint_jk(i,2),i)).ID;
            elseif joint_jk(i,1)>Nfus && joint_jk(i,2)<=Nfus
                RBE2.GN =Guess.iWing{joint_jk(i,1)-Nfus}.GRID(grid_M(joint_jk(i,1),i)).ID;
                RBE2.CM=123456;
                RBE2.GMi=Guess.iFus{joint_jk(i,2)}.GRID(grid_S(joint_jk(i,2),i)).ID;
            elseif joint_jk(i,1)>Nfus && joint_jk(i,2)>Nfus      
                RBE2.GN =Guess.iWing{joint_jk(i,1)-Nfus}.GRID(grid_M(joint_jk(i,1),i)).ID;
                RBE2.CM=123456;
                RBE2.GMi=Guess.iWing{joint_jk(i,2)-Nfus}.GRID(grid_S(joint_jk(i,2),i)).ID;
            end
            RBE2
                
                
            Guess.Joints{1}.RBE2(rbe2ID)=RBE2;
            RBE2writer(fid,Guess.Joints{1}.RBE2(rbe2ID))
            
            %RBE2writer(fid,RBE2)
        end    
fclose(fid);
    
end

function StickJoint_edit(varargin)
global jointTable
    eventdata=varargin{2};
    jointTable{eventdata.Indices(1),eventdata.Indices(2)}=eventdata.NewData;
end