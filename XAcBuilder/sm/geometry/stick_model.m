save('StoreFileWS.mat')
%clear all

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


load(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\AcBSMDir\AcBuilderTechImpVar.mat'))
CPACScreator

% *** BACKUP File RBE2 ***
global RadiceNomeFileA;
global RadiceNomeFileB;
%whos
%inmem
% Trasferito in GuessStick_Fun.m

%rng shuffle
%fileorRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\Guess_joints_AcB.dat');
%RadiceNomeFileA = randi([0 100000],1,1);
%RadiceNomeFileB = randi([100000 500000],1,1);
%filedestRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\ID_',mat2str(RadiceNomeFileA+RadiceNomeFileB),'-Guess_joints_AcB.dat');

%movefile(fileorRBE2,filedestRBE2)

%fileorRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\Guess_Model.dat');
%filedestRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\ID_',mat2str(RadiceNomeFileA+RadiceNomeFileB),'-Guess_Model.dat');

%movefile(fileorRBE2,filedestRBE2)

% *** *** *** *** *** ***