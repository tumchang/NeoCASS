%close all, clear all, clc
Spar.iSpar{ 1 }.xSP0=TechGeoModel.iWing{1}.Geometry.Strucuture.Spar.iSpar{ 1 }.xSP0
Spar.iSpar{ 2 }.xSP0=TechGeoModel.iWing{1}.Geometry.Strucuture.Spar.iSpar{end}.xSP0



 
figure,hold on,axis equal       
plot3(Spar.iSpar{ 1 }.xSP0(:,1),Spar.iSpar{ 1 }.xSP0(:,2),Spar.iSpar{ 1 }.xSP0(:,3))
plot3(Spar.iSpar{end}.xSP0(:,1),Spar.iSpar{ 1 }.xSP0(:,2),Spar.iSpar{end}.xSP0(:,3))

vers=[1 0 0];
for k=1:2
    for i=1:length(Spar.iSpar{ k }.xSP0(:,1))-1
        
        D=norm(Spar.iSpar{k}.xSP0(i+1,:)'-Spar.iSpar{k}.xSP0(i,:)');
        
        
    end
    for i=1:length(Spar.iSpar{ k }.xSP0(:,1))-1
    v=((Spar.iSpar{k}.xSP0(i+1,:)'-Spar.iSpar{k}.xSP0(i,:)')/D)';
end

       

