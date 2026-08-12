save('StoreFileWS.mat')
%clear all
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