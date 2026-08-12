close all, clear all, clc
load GRID_wing.mat
load SET_gridInterface.mat, GRIDids=GridIDs_wingInter;

str='..\Technology\D150_Wing1.mat';
%str='..\Technology\D150_BoxWing_Wing1.mat';
load(str)

Xbox=TechGeoModel.iWing{1}.aeroPanel.SectWing{3}.X;
%GRID(gridID).Xi(1)
h=1;
for Gid=GRIDids
    %GRID(Gid).Xi
    if GRID(Gid).Xi(1)>=min(Xbox(:,1)) && GRID(Gid).Xi(1)<=max(Xbox(:,1))
        if GRID(Gid).Xi(2)>=min(Xbox(:,2)) && GRID(Gid).Xi(2)<=max(Xbox(:,2))
            if GRID(Gid).Xi(3)>=min(Xbox(:,3)) && GRID(Gid).Xi(3)<=max(Xbox(:,3))
                Gid_inD(h)=Gid;
                h=h+1;
            else
            end                
        else
        end
    else   
    end
end
    


figure, hold on,axis equal
plot3(Xbox(:,1),Xbox(:,2),Xbox(:,3))
for Gid=GRIDids
    plot3(GRID(Gid).Xi(1),GRID(Gid).Xi(2),GRID(Gid).Xi(3),'ob')
end
for Gid=Gid_inD
    plot3(GRID(Gid).Xi(1),GRID(Gid).Xi(2),GRID(Gid).Xi(3),'or','MarkerFaceColor','r')
end
