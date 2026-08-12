function stick_model_a()
save('StoreFileWS.mat')

% ***** Adattamento Directory acbsmdir >>> AcBSMDir ********************
% Mod Date: 2016-05-18
% !!!!  DropBox modifica il nome della dir in minuscolo !!!!
ElencoDir = dir(strrep(which('acbuilder.m'),'acbuilder.m',''));
dirFlags = [ElencoDir.isdir];
SubFolders = ElencoDir(dirFlags);
for i = 1:length(SubFolders)
    if strcmp(SubFolders(i).name,'acbsmdir')
       movefile(strcat(strrep(which('acbuilder.m'),'acbuilder.m',''),SubFolders(i).name),strcat(strrep(which('acbuilder.m'),'acbuilder.m',''),'AcBSMDirA'));
       movefile(strcat(strrep(which('acbuilder.m'),'acbuilder.m',''),'AcBSMDirA'),strcat(strrep(which('acbuilder.m'),'acbuilder.m',''),'AcBSMDir'));
    end
end
% **********************************************************************

%clear all
load(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\AcBSMDir\AcBuilderTechImpVar.mat'))
CPACScreator

% *** BACKUP File RBE2 ***
global RadiceNomeFileA;
global RadiceNomeFileB;
% **** **** **** **** ****
end
