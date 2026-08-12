function [aircraft,analysis,CPACSgeo,CPACS_XML]=runCPACSWrapper(file,wingPosVec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Run the CPACS Wrapper                                                  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-08-01 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select Fiel
tic
if nargin==0;
    
    % Cooose CPACS Version 
    version=questdlg('Chose CPACS version','CPACS version','CPACS 2.0','Older than 2.0','default') ;
    
    homeAdress=pwd;
    cd ..\..
    if strcmp(version,'CPACS 2.0')
        cd('CPACS\workspace20')
        cpacsVersion='2.0';
    else
        cd('CPACS\workspace')
        cpacsVersion='1.6';
    end
    d = dir;
    str = {d.name};

    n=0;
    for i=1:length(str)
        if ~isempty(findstr(str{1,i},'.xml'))
            if isempty(strmatch(str{1,i},'.'))
                n=n+1;
                strc{n,1}=str{1,i};
            end
        end
    end

    [s,v] = listdlg('PromptString','Select a file:',...
                    'SelectionMode','single',...
                    'ListString',strc);
    xmlAdress=pwd;
    cd ..\..            
    cd('Matlab\CPACSWrapper')


    
%% Run Wrapper

    file=strcat(xmlAdress,'','\',strc{s,1});
    [CPACSgeo,CPACS_XML]=cpacsWrapper(file);
    [aircraft,analysis]=tornadoWrapper(CPACSgeo,CPACS_XML);
    cd(homeAdress)

else
    if nargin<2
        wingPosVec=[];
    end
    [CPACSgeo,CPACS_XML]   = cpacsWrapper(file);
    [aircraft,analysis] = tornadoWrapper(CPACSgeo,CPACS_XML,wingPosVec);
    
end
disp(['Wrappping time: ',num2str(toc), ' s'])


