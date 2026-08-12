%close all 
clear all 
clc
rad=pi/180;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathTech='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\';
nameTech='D150_xStick_TechGeoModel_r3.mat';

pathStick='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Geometry\StickModel\';
% nameStick='StickModel_D150.mat'; 
nameStick='StickModel.mat';

wingID=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([pathTech,nameTech])
% ABoxTech=TechGeoModel.iWing{wingID}.aeroPanel.SectWing{3};
ABoxTech=TechGeoModel.iWing{wingID}.aeroPanel.SectTED{3,4};

Xt=ABoxTech.X;
for i=1:3
    Xt_mat(1,1,i)=Xt(1,i);
    Xt_mat(1,2,i)=Xt(2,i);
    Xt_mat(2,2,i)=Xt(3,i);
    Xt_mat(2,1,i)=Xt(4,i);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([pathStick,nameStick])
CAERO1=Guess.iWing{wingID}.CAERO1(10);

Xs(1,:)=        [     CAERO1.CX , CAERO1.CY,      CAERO1.CZ];
Xs(2,:)=Xs(1,:)+[     CAERO1.CHD,         0,     -CAERO1.CHD*sin(rad*CAERO1.TW1)];

Xqcr   =Xs(1,:)+[0.25*CAERO1.CHD,                   0, -.25*CAERO1.CHD*sin(rad*CAERO1.TW1)];
Xqct   =Xqcr   +[     CAERO1.SPN*sin(rad*CAERO1.SWP), CAERO1.SPN*cos(rad*CAERO1.DIH), CAERO1.SPN*sin(rad*CAERO1.DIH)];

Xs(4,:)=Xqct   +[-.25*CAERO1.CHD*CAERO1.TPR, 0,  .25*CAERO1.CHD*CAERO1.TPR*sin(rad*CAERO1.TW2)];
Xs(3,:)=Xqct   +[0.75*CAERO1.CHD*CAERO1.TPR, 0, -.75*CAERO1.CHD*CAERO1.TPR*sin(rad*CAERO1.TW2)];
for i=1:3
    Xs_mat(1,1,i)=Xs(1,i);
    Xs_mat(1,2,i)=Xs(2,i);
    Xs_mat(2,2,i)=Xs(3,i);
    Xs_mat(2,1,i)=Xs(4,i);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1),hold on,axis equal
plot3(Xt(:,1),Xt(:,2),Xt(:,3),'o')
surf(Xt_mat(:,:,1),Xt_mat(:,:,2),Xt_mat(:,:,3))

surf(Xs_mat(:,:,1),Xs_mat(:,:,2),Xs_mat(:,:,3))


% wingID=1;
% %aBox=Guess.iWing{1}.=
% 
% 
% %X(1,:)=