%
% acbuilder.m
%
% Author: Martin Lahuta, (c) 2009, VZLU (www.vzlu.cz)
% Developed within SimSAC project, www.simsacdesign.org
% Any usage without an explicit authorization may be persecuted.
%
%
% Modifications:
%	DATE		VERS	PROGRAMMER	DESCRIPTION
%	22.02.10	1.0	M. Lahuta	last update
%	02.08.12		M. Lahuta	corrected 'set' warning
%   07.07.16                    CPACS AirFoils
%
% AcBuilder's startup script
%
function acbuilder(aircraft,acname,acdir)

% optional parameter
%   aircraft - structure with aircraft's data
%   acname - name of an aircraft, default file name
%   acdir - directory used when file selection dialog is open

% initialize JOGL, paths, librarypath etc.
acb_jinit;

global ACB ac defac for_cpacs

% initialize 'defac' structure with default values
acb_initac;

% initialize 'ac' structure
if nargin==0
    ac=defac;
else
    ac=aircraft;
    acb_prepac;
end

% set project's name
if nargin>1
    pn=projname;
else
    pn='untitled';
end

% set working directory
if nargin>2
    cwd=cdir;
else
    cwd=pwd;
end

% ************ MOD 2016-06-15 ************
% ** Info: For CPACS Airfoils ************
% +++ Rev. 2016-06-25 +++
% +++ Rev. 2016-06-28 +++

for_cpacs = 0;

prompt = 'Automatic Airfoils generation for CPACS function? (y/n) [y]:';
richiestaAF_CPACS = input(prompt,'s')
switch richiestaAF_CPACS
    case 'y'
        disp('Reading Airfoils data...')
        for_cpacs = 1;   % ***** User Guide: 1 - ON | 0 - OFF ***********
        if (for_cpacs == 1)
         acb_af_aibs();
        end
    case 'n'
        disp('No Automatic Airfoils generation for CPACS function')
        
    otherwise
        disp('No Automatic Airfoils generation for CPACS function')        
end
% ****************************************

% run AcBuilder
disp('Starting AcBuilder (this can take a while) ...');
if ~isa(ACB,'AcBuilder')
    ACB = AcBuilder;
    afpath = fullfile(fileparts(which('acbuilder')), 'airfoil');
    ACB.setAfPath(afpath);
    ACB.setCwd(cwd);
    ACB.setProjName(pn);
    hbtn=handle(ACB.button, 'CallbackProperties');
    set(hbtn, 'ActionPerformedCallback', @acb_jmcom);
    % load initial values from defac to acbuilder
    ACB.initialize;
    javax.swing.SwingUtilities.invokeLater(ACB);
else
    ACB.setCwd(cwd);
    ACB.setProjName(pn);
    ACB.acbShow;
end
