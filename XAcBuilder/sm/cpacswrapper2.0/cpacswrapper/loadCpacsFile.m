function [CPACS_XML] = loadCpacsFile(file)

initialize
homeAdress=pwd;
%% Check Input
if nargin==0;

    homeAdress=pwd;
    cd .. 
    cd('Projects')
    d = dir;
    str = {d.name};

    n=0;
    for i=1:length(str)
        if ~isempty(findstr(str{1,i},'.xml'))
            n=n+1;
            strc{n,1}=str{1,i};
        end
    end

    [s,v] = listdlg('PromptString','Select a file:',...
                    'SelectionMode','single',...
                    'ListString',strc);
    xmlAdress=pwd;
            
    cd('..\CPACSWrapper2.0\CPACSWrapper\lib')

    file=strcat(xmlAdress,'','\',strc{s,1});
    
end    
%% Load CPACS file

disp('Load CPACS file ... ')
which xml2struct.m
[cpacs] = xml2struct(file);
CPACS_XML=cpacs.cpacs{1,1};
cd(homeAdress)

