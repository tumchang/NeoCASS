function jointStick_Fun2(component,Nfus,Nwing)
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
        
    [vsort isort]=sort(minDis);
    isort
    grid_M
    grid_S
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
% Joints Table
    T=uitable('parent', figure(1),...
    'units','normalized',...
    'position',[.0 .0 .6 .4],...
    'ColumnName',{'Joint','Name','Master Comp','Slave Comp'},...
    'ColumnEditable',[false,true,true,true],...
    'ColumnFormat',{'char','char','numeric','numeric'},...
    'RowName',[],...
    'Visible','on',...
    'tag','Joint_Table',...
    'CellEditCallback',{@StickJoint_edit});
    set(T,'Data',jointTable);
% Continue Button
    h = uicontrol('units',   'normalized',...
                  'position',[.0 .4 .3 .1],... 
                  'String','Continue',...
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
            joint_jk(i,:)
            grid_M(joint_jk(i,1),joint_jk(i,2))
            grid_S(joint_jk(i,1),joint_jk(i,2)) 
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
            RBE2
   
            Guess.Joints{1}.RBE2(rbe2ID)=RBE2;
            RBE2writer(fid,Guess.Joints{1}.RBE2(rbe2ID))            
        end    
fclose(fid);
    
end

function StickJoint_edit(varargin)
global jointTable
    eventdata=varargin{2};
    jointTable{eventdata.Indices(1),eventdata.Indices(2)}=eventdata.NewData;
end