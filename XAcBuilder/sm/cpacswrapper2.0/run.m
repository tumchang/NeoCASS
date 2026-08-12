% function [fileLocation,errorCase]=run(projectName,CPACSgeo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   run                                                                   %
%                                                                         %
%   Run Sumo form CPACS                                                  %   
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2012-11-22 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

projectName='test'
%% Dir's

homeDir=pwd;

projectPath=[pwd,'\workespace\',projectName,''];
disp(['projectName: ',projectName])
disp(['projectPath: ',projectPath])

% Save Dir´s
option = {};
%option.matlabPath=matlabPath;
option.homeDir=homeDir;
option.projectPath=projectPath;
option.projectName=projectName;

mkdir([option.projectPath,''])

fileLocation=[option.projectPath,'\CFD\Input\'];
mkdir([fileLocation,''])

option.outType='cgns'
option.tetgenSettins='pq1.400Ya160.000'

%% Wrapper

disp(' ')
disp('------------ Read CPACS --------------')
cd CPACSWrapper
cpacsFile='\ToolInput\toolInput';
[aircraft,analysis,CPACSgeo,CPACS_XML]=runCPACSWrapper([homeDir,cpacsFile],[1,2,3]);
cd(homeDir)
disp(' ')    

%% Rum Sumo

% Meshing Settings
option.sumo.wingMeshDefault='true';

option.sumo.exeDir=['D:\Arbeit\Matlab\SUMOstandAllone\SUMO\bin'];
option.sumo.auto=1;
option.sumo.viewOutput=1;
cd SumoBatch
[errorCase]=mainSumoBatch(option,CPACSgeo);
cd ..

