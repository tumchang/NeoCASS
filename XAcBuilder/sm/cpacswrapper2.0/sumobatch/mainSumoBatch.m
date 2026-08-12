function [errorCase]=mainSumoBatch(option,CPACSgeo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   mainSumoBatch                                                         %
%                                                                         %
%   Generate a Sumo Input and run sumo in normal or batch mode or         %   
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-11-01 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
initialize
disp('Run Sumo: Gernerate Mesh')

%% Settings

% Output Type
% outType = iges,dwfs,edge,cgns,tau
if ~isfield(option,'outType')
    option.outType='';
end

% Sumo location
cd ..
EDGEstandalloneDir=pwd;
cd('SumoBatch')
% Sumo vision Numers:
%     1_9_17
%     2_1_1
%     2_1_2 --> Boxwing possible
%     2_2_2 --> Mesh settings possible
%     2_4_1 
%     2_5_2 --> With New Batchmode function
sumoDir=[option.sumo.exeDir,'2_5_2'];
%option.sumo.exeDir

% Path Setiings
acName=option.projectName;

% Edge input folder location
edgeInputFolderDir=[option.projectPath,'\CFD\Input\'];

try
    if nargin == 0
        load('BWB.mat')
        warning('No input, use an example input')
    end
end

%% Initialise New struct
NewS={};

% Generate a Temp Name
timeCodeNum=clock;
timeCode='';
for i=1:5
    timeCode=[timeCode,num2str(timeCodeNum(1,i))];
end
acNameTemp=[acName,timeCode];

%% Incude wing(s)

for i=1:size(CPACSgeo.wings.component,1)
    wingNum=i;
    [NewS] = inclWing(NewS,wingNum,CPACSgeo,option);
end

%% Incude ContSurf(s)
% 
% for i=1:size(CPACSgeo.wings.component,1)    
%     if isfield(CPACSgeo.wings.component{i,1},'controlSurfaces') 
%         wingNum=i;
%         [NewS] = inclContSurf(NewS,CPACSgeo,wingNum);
%         disp('Add Control')
%     end
% end

%% Incude Fuselage

if isfield(CPACSgeo,'fuselages')
    [NewS] = inclFus(NewS,CPACSgeo);
    disp('Add Fuselage')
end

%% Include Engines

% if isfield(aircraft,'engine')
%     [NewS] = inclEngine(NewS,aircraft,wingNum);
%     disp('Add Engine')
% end

%% Write .xms (input fiele for sumo)

struct2smx(NewS,[acNameTemp,'.smx'])
disp('write.xms')
pause(3)

%% Start Sumo

if option.sumo.auto==0;
    
    disp([edgeInputFolderDir,acName])
    system([sumoDir,'\','dwfsumo.exe ',acNameTemp,'.smx']);    
    option.sumo.viewOutput=0;
    
    input('If you had copyed all files to EDGE Input Dir Press Enter')
      
else

    delete('sumoLog')
    diary('sumoLog')   
    diary on
    if isempty(option.outType)
        system([sumoDir,'\','dwfsumo.exe -batch ',acNameTemp,'.smx']);
        diary off   
        %% If there Comes an Erromessage
        DELIMITER = ';';
        HEADERLINES = 500;
        rawData1 = importdata('sumoLog', DELIMITER, HEADERLINES);
        errorCase=0;
        for i=1:size(rawData1,1)
            if ~isempty(strfind(rawData1{i,1},'cannot find valid node file header')) ||  ~isempty(strfind(rawData1{i,1},'Constraint insertion failed'))    
                errorCase=1;
                break
            end
        end

        % List of output file typs
        fileTyps={'.smx','.bmsh','.aboc','.1.face','.1.node','.igs','.msh','.smesh','.1.ele'};
        if errorCase==0;


            % Wait Fort Results
            fprintf('Wait for results .')
            while 1
                dirNames=dir;
                existFile=[];
                for i=1:size(dirNames,1)
                    names{i,1}=dirNames(i,1).name;
                    existFile(i,1)=~isempty(strfind(names{i,1},[acNameTemp,'.aboc']));
                    existFile(i,2)=~isempty(strfind(names{i,1},[acNameTemp,'.bmsh']));     
                end

                if sum(existFile(:,1))==1&&sum(existFile(:,2))==1
                    break
                end
                fprintf('.')
                pause(1)
            end
            fprintf('\n')

            % List Generated Files
            for i=1:size(fileTyps,2)
                disp(['Generate: ',acNameTemp,fileTyps{1,i}])        
            end
            disp(' ')

            % Move and Copy files to Edge input folder
            for i=[1,2,3]
                movefile([acNameTemp,fileTyps{1,i}],[edgeInputFolderDir,acName,fileTyps{1,i}])
                disp(['Movefile: ',edgeInputFolderDir,acName,fileTyps{1,i}])   
            end
            for i=[7]
                copyfile([acNameTemp,fileTyps{1,i}],[edgeInputFolderDir,acName,fileTyps{1,i}])
                disp(['Copyfile: ',edgeInputFolderDir,acName,fileTyps{1,i}])   
            end
            disp(' ')

            % Delete Files
            for i=[2:6,8,9]
                delete([acNameTemp,fileTyps{1,i}])
                disp(['delete',acNameTemp,fileTyps{1,i}])
            end      

            %% View Sumo Mesh
            option.sumo.viewOutput=1;
            if option.sumo.viewOutput==1
                system([sumoDir,'\dwfscope.exe ',acNameTemp,'.msh&'])
            else
                clc
                delete([acNameTemp,'.msh'])
            end
        else
            movefile([acNameTemp,fileTyps{1,1}],[edgeInputFolderDir,acName,fileTyps{1,1}])
            disp(['Movefile: ',edgeInputFolderDir,acName,fileTyps{1,1}]) 
        end
    else   
        % Run sumo in Batchmode
        % Batch mode usage instructions: (sice version 2_5_2)
        % 
        % Usage: sumo -batch [options] aircraft.smx
        % 
        % Options:
        % -output=iges,dwfs,edge,cgns,tau 
        %         Generate output files for the 
        %         named formats. Will not start mesh generation unless at least
        %         one mesh format (dwfs,edge,tau,cgns) is named.
        %         Default is -output=iges,dwfs,edge -tetgen-options=flags 
        %         Call tetgen as in 'tetgen -flags model.smesh' when generating 
        %         a volume mesh.The default is -tetgen-options=pq1.4V
        % 
        % Examples:
        % dwfsumo -batch -output=iges aircraft.smx
        %         Convert geometry of aircraft.smx to IGES and exit. Will not 
        %         generate any mesh.
        % dwfsumo -batch -output=cgns,edge -tetgen-options=pq1.16VY aircraft.smx
        %         First, generate a surface mesh (not written) for aircraft.smx,
        %         then produce a volume mesh by calling
        %         tetgen -pq1.16VY aircraft.smesh
        %         on it, then convert the tetgen output to CGNS and EDGE files
        
        if isempty(option.tetgenSettins)
            disp(['Run Sumo with following options: outputFile = ',option.outType,', ',acNameTemp,'.smx'])
            system([sumoDir,'\','dwfsumo.exe -batch -output=',option.outType,' ',acNameTemp,'.smx']);
        else
            disp(['Run Sumo with following options: outputFile = ',option.outType,', tetgen options = ',option.tetgenSettins,', ',acNameTemp,'.smx'])
            system([sumoDir,'\','dwfsumo.exe -batch -output=',option.outType,' -tetgen-options=',option.tetgenSettins,' ',acNameTemp,'.smx']);
        end
        disp('Wait...')
        pause(3)
        fileTyps={'.cgns'};
        for i=1:size(fileTyps,2)
            movefile([acNameTemp,fileTyps{1,i}],[edgeInputFolderDir,acName,fileTyps{1,i}])
                    disp(['Movefile: ',edgeInputFolderDir,acName,fileTyps{1,i}]) 
        end
        
        errorCase=0;
    end
    diary off
end


