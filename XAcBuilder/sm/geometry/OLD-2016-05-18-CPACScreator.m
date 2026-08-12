function CPACScreator
global main_figure handles
%clear all
clc
path_settings


% ------------- Choose Model, run cpacsWrapper-------------%
disp('Reading .xml into matlab structure, please wait 40 seconds maybe...')

%[CPACS_XML] = loadCpacsFile; % Riga commentata per escludere funzione

% Parte Aggiunta ******************
%[cpacs] = xml2struct('G:\99 - Z DepEnv\CPACCrORIG2\CPACCrORIG2\CPACCrORIG\cpacscreator_v1.4\projects\CPACS_20_D150.xml');
%[cpacs] = xml2struct('G:\300-Matlab_2012_2014\NeoCASS_Latest_Version_patched\XAcBuilder\AcBSMDir\AcBExpCPACS4StickModel.xml');
%
%cd('..\..')
%which('acb_advStickModelFun.m')
[cpacs] = xml2structN(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\AcBExpCPACS4StickModel.xml'));

CPACS_XML=cpacs.cpacs{1,1};

% ***********************************
[CPACSgeo, CPACS_XML] = cpacsWrapper_CPACScreator(path,CPACS_XML);

% save('../Projects/structBraced.mat','CPACS_XML')
% save('../Projects/structBracedgeo.mat','CPACSgeo')
%-----------------------------------------------------------%
% load ('../Projects/structBraced.mat')       % structBraced
% load ('../Projects/structBracedgeo.mat')
% load ('../Projects/D150.mat')       
% load ('../Projects/D150geo.mat')

%------------------------------------------

%setup_GUI_panel
%return

load_structure(CPACSgeo,CPACS_XML)
%load('G:\300-Matlab_2012_2014\NeoCASS_Latest_Version_patched\XAcBuilder\AcBSMDir\AcBuilderTechImpVar.mat') % Aggiunto per test
%strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\AcBSMDir\AcBuilderTechImpVar.mat')
%load(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\AcBSMDir\AcBuilderTechImpVar.mat'))
%return
Technology_Fun(1,CPACS_XML); % Aggiunto per richiamo menu technology

%main_figure.fh = figure('Visible','off'); 
%h = get(gca,'Children');
%h = get(gca,'Default');
%set(h,'visible','off');
%set(handles.fhmain_figure.name = 'off'

% ******************* AGGIUNTO *************
% Grafica; % per grafica
% ******************************************

%(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\AcBSMDir\AcBuilderTechImpVar.mat'))
%F:\Roby\AcBuilder Project Home\Parte 2 - StickModel\2015-04-03 - NeoCASS\NeoCASS_Latest_Version_patched\XAcBuilder\sm\geometry\stickmodel
pathSM = (strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\sm\geometry\stickmodel\'));
cd(pathSM);
disp('Stick Model - Final Step')
GuessStick_Fun

% ********************************************
%{
fidSTICK = fopen('Guess_Model.dat','wt');
  fidRBE2 = fopen('Guess_joints.dat');
  tline = fgets(fidRBE2);
  fprintf(fid,[tline,'\n\n']);
  while ischar(tline)
    % disp(tline)
    fprintf(fid,[tline,'\n\n']);
    tline = fgets(fid);
  end
  fclose(fidRBE2);
 fclose(fidSTICK);
% *********************************************
%}

disp('Stick Model COMPLETED in \XAcBuilder\AcBSMDir\Guess_Model.dat')
pathSM = (strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\AcBSMDir\'));
cd(pathSM);
end

function path_settings

str1 = ['..' filesep 'CPACSWrapper2.0' filesep 'CPACSWrapper'];
str2 = ['..' filesep 'CPACSWrapper2.0' filesep 'CPACSWrapper' filesep 'lib'];
addpath( str1 );
addpath( str2 );
%disp('add CPACSWrapper')

addpath('TED');
addpath('structure')
addpath('fuelTank')
addpath('engine')
addpath('Technology')

opengl software

end

function setup_GUI_panel
global main_figure handles
%% Figure
fH = findobj('Type', 'figure', 'Tag', 'figure');
if ishandle(fH)
    close(fH);
end

main_figure.col   =   [0.9255, 0.9137, 0.8471]; % Default Color of push buttons
defaultBackground = get(0,'defaultUicontrolBackgroundColor');

%set(main_figure, 'visible', 'off'); % Aggiunto per invisibilità finestra principale

main_figure.fh = figure('units','normalized',...
    'position',[0.05 0.1 0.9 0.8],...
    'menubar','none',...
    'Color',defaultBackground,...    %[.2 .2 .3]
    'numbertitle','off',...
    'name','Technology View',...
    'tag','figure',...
    'resize','on',...
    'Visible','off',... % ********** aggiunto
    'NextPlot','add', 'renderer',' openGL');   %'openGL'); painters  zbuffer   


%% Panel
% Panel View
main_figure.up(1)= uipanel('Parent',main_figure.fh ,'Title','View',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.9 0.3 0.1],...
    'tag','View','Clipping','on');

% Panel Components
main_figure.up(2)= uipanel('Parent',main_figure.fh ,'Title','Components',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.6 0.15 0.3],...
    'tag','Components','Clipping','on');

% Panel Parameters
main_figure.up(3) = uipanel('Parent', main_figure.fh ,'Title','Parameters',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.0 0.3 0.5],...
    'tag','Parameters','Clipping','on');

% Panel Sub-Components
main_figure.up(4)= uipanel('Parent',main_figure.fh ,'Title','Sub-Components',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.15 0.6 0.15 0.3],...
    'tag','Sub_Components','Clipping','on');

% Panel Actions
main_figure.up(5)= uipanel('Parent',main_figure.fh ,'Title','Components Actions',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.5 0.3 0.1],...
    'tag','Actions','Clipping','on');

% The axes figure, for 3D model
main_figure.up(6) = uipanel('Parent',main_figure.fh,...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'Position',[0.3 0 0.7 1.0],...
    'tag','panel_for_axes',...
    'Clipping','on');

%% ------------- Panel settings for Technology ---------------
main_figure.up(7)= uipanel('Parent',main_figure.fh ,'Title','MyTechnology',...
    'units','normalized',...
    'BorderWidth', 2.0,...
    'position',[0.0 0.6 0.3 0.3],...
    'Visible','off',...
    'tag','Technology',...
    'Clipping','on');

main_figure.up(8)= uipanel('Parent',main_figure.fh ,'Title','Parameters',...
    'units','normalized',...
    'BorderWidth', 2.0,...
    'position',[0.0 0.0 0.3 0.6],...
    'Visible','off',...
    'tag','tech_parameters');

main_figure.lb(10) =  uicontrol('style','listbox',...
    'parent', main_figure.up(7),...
    'units','normalized',...
    'position',[0.0 0.0 1.0 1.0],...
    'tag','tech_listbox',...
    'BackgroundColor',[0.8 0.8 1], ...
    'Visible','off',...
    'Callback',{@set_ListboxVisibilities_Technology});

main_figure.lb(11) =  uitable('parent', main_figure.up(8),...
    'units','normalized',...
    'position',[0.0 0.0 1.0 1.0],...
    'ColumnName',{'Parameter','Unit','Value'},...
    'ColumnEditable',[false,false,true],...
    'ColumnFormat',{'char','char','numeric'},...
    'RowName',[],...
    'Visible','off',...
    'tag','tech_parameters_table',...
    'CellEditCallback',{@techParameter_edit});
%% ------------- Panel settings for Weight & Ballance ---------------
main_figure.up(12)= uipanel('Parent',main_figure.fh ,'Title','Parameters W&B',...
    'units','normalized',...
    'BorderWidth', 2.0,...
    'position',[0.0 0.0 0.3 0.9],...
    'Visible','off',...
    'tag','WB_parameters');
main_figure.lb(13) =  uitable('parent', main_figure.up(12),...
    'units','normalized',...
    'position',[0.0 0.0 1.0 1.0],...
    'ColumnName',  {'Component','x cog\n [m]','y cog\n [m]','z cog\n [m]','mass\n [kg]'},...
    'ColumnEditable',[    false,         true,         true,         true,         true],...
    'ColumnFormat',{     'char',    'numeric',    'numeric',    'numeric',    'numeric'},...
    'RowName',[],...
    'Visible','off',...
    'tag','WB_parameters_table');%,...
    %'CellEditCallback',{@WBParameter_edit});
%% uicontrol Panel Components
% Listboxes
% Components listbox
main_figure.lb(1) =  uicontrol('style','listbox',...
    'parent', main_figure.up(2),...
    'units','normalized',...
    'position',[0.0 0.0 1.0 1.0],...
    'tag','listbox',...
    'Callback',{@set_ListboxVisibilities_Components},...
    'BackgroundColor',[0.8 0.8 1]);

%% uicontrol Panel Actions
% Push Button Select
main_figure.pb(9) = uicontrol('style','push',...
    'parent', main_figure.up(5),...
    'units','normalized',...
    'position',[0.05 0.2 0.3 0.6],...
    'backg',main_figure.col,...
    'tag','Select',...
    'string','Show / Hide','callback',{@select_comps});

% Push Button Add
main_figure.pb(10) = uicontrol('style','push',...
    'parent', main_figure.up(5),...
    'units','normalized',...
    'position',[0.4 0.2 0.25 0.6],...
    'backg',main_figure.col,...
    'tag','Add',...
    'string','Add','callback',{@add_comps});

% Push Button Remove
main_figure.pb(11) = uicontrol('style','push',...
    'parent', main_figure.up(5),...
    'units','normalized',...
    'position',[0.7 0.2 0.25 0.6],...
    'backg',main_figure.col,...
    'tag','Remove',...
    'string','Remove','callback',{@remove_comps});

% Push Button Select SubComp
main_figure.pb(12) = uicontrol('style','push',...
    'parent', main_figure.up(5),...
    'units','normalized',...
    'position',[0.05 0.2 0.3 0.6],...
    'backg',main_figure.col,...
    'tag','Select_SubComp',...
    'Visible', 'off',...
    'string','Show / Hide','callback',{@select_subcomps});

% Push Button Add SubComp
main_figure.pb(13) = uicontrol('style','push',...
    'parent', main_figure.up(5),...
    'units','normalized',...
    'position',[0.4 0.2 0.25 0.6],...
    'backg',main_figure.col,...
    'tag','Add_SubComp',...
    'Visible', 'off',...
    'string','Add','callback',{@add_subcomps});

% Push Button Remove SubComp
main_figure.pb(14) = uicontrol('style','push',...
    'parent', main_figure.up(5),...
    'units','normalized',...
    'position',[0.7 0.2 0.25 0.6],...
    'backg',main_figure.col,...
    'tag','Remove_SubComp',...
    'Visible', 'off',...
    'string','Remove','callback',{@remove_subcomps});

%% uicontrol Panel View
% Push Button Reset
main_figure.pb(1) = uicontrol('style','push',...
    'parent', main_figure.up(1),...
    'units','normalized',...
    'position',[0.001 0.1 0.249 0.8],...
    'backg',main_figure.col,...
    'tag','Reset',...
    'string','Reset','callback',{@view_reset});

% Push Button Side
main_figure.pb(2) = uicontrol('style','push',...
    'parent', main_figure.up(1),...
    'units','normalized',...
    'position',[0.25 0.1 0.249 0.8],...
    'backg',main_figure.col,...
    'tag','Side',...
    'string','Side','callback',{@view_side});

% Push Button Front
main_figure.pb(3) = uicontrol('style','push',...
    'parent', main_figure.up(1),...
    'units','normalized',...
    'position',[0.5 0.1 0.249 0.8],...
    'backg',main_figure.col,...
    'tag','Front',...
    'string','Front','callback',{@view_front});

% Push Button Top
main_figure.pb(4) = uicontrol('style','push',...
    'parent', main_figure.up(1),...
    'units','normalized',...
    'position',[0.75 0.1 0.249 0.8],...
    'backg',main_figure.col,...
    'tag','Top',...
    'string','Top','callback',{@view_top});

%% uicontrol Panel Parameter
% button modify sections
main_figure.pb(5) = uicontrol('style','push',...
    'parent', main_figure.up(3),...
    'units','normalized',...
    'position',[0.2 0.05 0.6 0.12],...
    'backg',main_figure.col,...
    'tag','modify_sections',...
    'string','Modify sections','callback',{@modify_sections});   % Modify other parameters - component

% button modify engine
main_figure.pb(6) = uicontrol('style','push',...
    'parent', main_figure.up(3),...
    'units','normalized',...
    'position',[0.2 0.05 0.6 0.12],...
    'backg',main_figure.col,...
    'Visible', 'off',...
    'tag','modify_engine',...
    'string','Modify engine','callback',{@modify_engine});


% button modify steps
main_figure.pb(7) = uicontrol('style','push',...
    'parent', main_figure.up(3),...
    'units','normalized',...
    'position',[0.2 0.05 0.6 0.12],...
    'backg',main_figure.col,...
    'Visible', 'off',...
    'tag','modify_steps',...
    'string','Modify steps','callback',{@modify_steps});

% button modify spars and SparOrRib
main_figure.pb(8) = uicontrol('style','push',...
    'parent', main_figure.up(3),...
    'units','normalized',...
    'position',[0.2 0.05 0.6 0.12],...
    'backg',main_figure.col,...
    'Visible', 'off',...
    'tag','modify_spars_and_ribs',...
    'string','Modify spars/ribs','callback',{@modify_spars_and_ribs});

%% uicontrol Panel for axes
main_figure.renderer = axes('Parent', main_figure.up(6),...
    'units','normalized',...
    'OuterPosition',[0.0 0.0 1.0 1.0],...
    'NextPlot','replace',...
    'tag','axes3d');

main_figure.technology = axes('Parent', main_figure.up(6),...
    'units','normalized',...
    'OuterPosition',[0.0 0.0 1.0 1.0],...
    'NextPlot','replace',...
    'tag','axes3d_technology',...
    'Visible','off');

%% Menus Options
% Menu Project
menu_Project = uimenu(main_figure.fh,'Label','Project');
uimenu(menu_Project,'Label','Load CPACS models','tag','menu_load_cpacs','callback',{@load_CPACS});
uimenu(menu_Project,'Label','Save as CPACS models','tag','menu_saveto_cpacs','callback',{@saveto_CPACS});
uimenu(menu_Project,'Label','Import Sumo models','tag','menu_import_sumo','callback',{@import_sumo});
uimenu(menu_Project,'Label','Save as Sumo models','tag','menu_saveto_sumo','callback',{@saveto_sumo});
% uimenu(menu_Project,'Label','Import matlab models','tag','menu_import_mat','callback',{@import_mat});
% uimenu(menu_Project,'Label','Save as matlab models','tag','menu_saveto_mat','callback',{@saveto_mat});

menu_View = uimenu(main_figure.fh,'Label','View');
uimenu(menu_View,'Label','Background Color','tag','menu_backgroundcolor','callback',{@axes_color});
uimenu(menu_View,'Label','Components Color','tag','menu_componentcolor','callback',{@axes_localcolor});
uimenu(menu_View,'Label','Components Transparency','tag','menu_transparency','callback',{@axes_localAlpha});
% face_light = uimenu(menu_View,'Label','FaceLighting','tag','menu_lightmode','callback',{@axes_lighting_mode});
% face_alpha = uimenu(menu_View,'Label','FaceAlpha','tag','menu_alphamode');
% face_color = uimenu(menu_View,'Label','FaceColor','tag','menu_colormode');

%   Generate a Sumo Input and run sumo in normal or batch mode or
menu_ceasiom = uimenu(main_figure.fh,'Label','CEASIOM');
uimenu(menu_ceasiom,'Label','Generate Sumo Mesh','tag','menu_sumoInp', 'callback', @ceasiom_sumoMesh);      %,'callback',{@ceasiom_sumoGUI}
%uimenu(menu_ceasiom,'Label','Weight and Balance','tag','menu_sumoBatch', 'callback', @ceasiom_WB);          % ,'callback',{@ceasiom_sumoBatch}
uimenu(menu_ceasiom,'Label','Load AMB','tag','menu_AMB','callback', @ceasiom_AMB);
% uimenu(menu_ceasiom,'Label','Run Tornado','tag','menu_tornado','Separator','on','callback',{@ceasiom_tornado});
% uimenu(menu_ceasiom,'Label','Run Edge','tag','menu_edge','Separator','on','callback',{@ceasiom_edge});

% Generate the Technology menu inherited from the old ACbuilder
menu_technology = uimenu(main_figure.fh,'Label','Technology');
uimenu(menu_technology,'Label','Technology',           'tag','menu_technology','callback',{@tech_technology});                 %'callback',{@tech_technology}
uimenu(menu_technology,'Label','Import Technology XML','tag','menu_importTechXml');  %,'callback',{@tech_importXML}
%uimenu(menu_technology,'Label','Export Neocass model', 'tag','Export_Neocass_model','callback');%,{@Tech2Neocass});
% ************************************* Aggiunto **************************
uimenu(menu_technology,'Label','Stick Model',           'tag','menu_stickmodel','callback',{@tech_stickmodelR});
% *************************************************************************
% Generate the Weight & Ballance  
menu_weightBallance=uimenu(main_figure.fh,'Label','W&B','Enable','on');
uimenu(menu_weightBallance,'Label','Center of gravity','tag','Cog'  ,'callback',{@WB_WeightAndBallance_Cog});
%uimenu(menu_weightBallance,'Label','Modify Cog'       ,'tag','M_Cog','callback',{@WB_WeightAndBallance_MCog});

% Create the handles for the GUI elements
handles = guihandles(gcf);
guidata(gcf,handles);

%-------------------- Other extra settings -------------------%
set(0,'Showhidden','on')
set(main_figure.fh,'Toolbar','figure');
ch = get(gcf,'children');
UT = get(ch(1),'children');     % 'Type','uipushtool')

delete(UT([2,3,4,5,6,13,14,15,16]))

ch = get(gcf,'children');
UT = get(ch(1),'children');
tth = uipushtool(ch(1),'CData',rand(20,20,3),...
    'TooltipString','Background Color',...
    'ClickedCallback',{@axes_color});

%{
%% Set right click uicontext menu for the GUI objects
% % Define a context menu; it is not attached to anything
% hcmenu = uicontextmenu;
%
% % Define the context menu items and install their callbacks
% item1 = uimenu(hcmenu, 'Label', 'Color', 'tag','rkcolor','Callback', @axes_localcolor);
% item2 = uimenu(hcmenu, 'Label', 'Transparency', 'tag','rktranp','Callback', @axes_localAlpha);
%
% % Locate line objects
% hlines = findall(handles.axes3d,'Type','patch');
% % Attach the context menu to each line
% for line = 1:length(hlines)
%     set(hlines(line),'UIContextMenu',hcmenu)   %   ,'Callback',@axes_localcolor)
% end
% uimenu(face_light,'Label','none', 'Callback', ['set(findobj(gca,''Type'',''patch''),''FaceLighting'', ''none'')']);                    % @axes_facelight1);
% uimenu(face_light,'Label','flat', 'Callback',['set(findobj(gca,''Type'',''patch''),''FaceLighting'', ''flat'')']);                     % @axes_facelight2);
% uimenu(face_light,'Label','gouraud', 'Callback',['set(findobj(gca,''Type'',''patch''),''FaceLighting'', ''gouraud'')']);               % @axes_facelight3);
% uimenu(face_light,'Label','phong', 'Callback',['set(findobj(gca,''Type'',''patch''),''FaceLighting'', ''phong'')']);                   % @axes_facelight4);
% %{
% uimenu(face_alpha,'Label','scalar','Callback',['set(findobj(gca,''Type'',''patch''),''FaceAlpha'', 1)']);
% uimenu(face_alpha,'Label','flat','Callback',['set(findobj(gca,''Type'',''patch''),''FaceAlpha'', ''flat'')']);
% uimenu(face_alpha,'Label','interp','Callback',['set(findobj(gca,''Type'',''patch''),''FaceAlpha'', ''interp'')']);
%
% uimenu(face_color,'Label','ColorSpec','Callback',['set(findobj(gca,''Type'',''patch''),''FaceColor'', 1)']);
% uimenu(face_color,'Label','none','Callback',['set(findobj(gca,''Type'',''patch''),''FaceColor'', ''none'')']);
% uimenu(face_color,'Label','flat','Callback',['set(findobj(gca,''Type'',''patch''),''FaceColor'', ''flat'')']);
% uimenu(face_color,'Label','interp','Callback',['set(findobj(gca,''Type'',''patch''),''FaceColor'', ''interp'')']);
% %}
% handles = guihandles(gcf);
% guidata(gcf,handles);
    %}
end

function [] = load_structure(CPACSgeo,acb_struct)
%% fuselages

try
    number_of_fuselages = length(CPACSgeo.fuselages.component);
    
    for i=1:number_of_fuselages
        
        fuselage_struct = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage{1,i};  % Transformation info not carried by CPACSgeo, ergo fus_structure needed
        fuselage_CPACSgeo = CPACSgeo.fuselages.component{i,1};
        
        fuselage_struct.type = 'fuselages';
        fuselage_struct.profiles = acb_struct.vehicles{1,1}.profiles{1,1}.fuselageProfiles{1,1}.fuselageProfile;
        
        %updateTable_comps(fuselage_struct)  % per grafica
        %Draw_Components(fuselage_CPACSgeo); % per grafica
        
    end
catch
    disp('No fuselage')
end

%% wings

%try
number_of_wings = length(CPACSgeo.wings.component);

for i= 1:number_of_wings
    
    wing_struct = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing{1,i};
    wing_geo = CPACSgeo.wings.component{i,1};
   
    wing_struct.profiles = acb_struct.vehicles{1,1}.profiles{1,1}.wingAirfoils{1,1}.wingAirfoil;
    wing_struct.reference = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference;
    wing_struct.type = 'wings';
    
    % updateTable_comps(wing_struct) % per grafica
    
    % Draw_Components(wing_geo);     % per grafica
    load_Wing_Subcomponents(wing_geo, wing_struct)
end

% catch
%     disp('No wings')
% end

%% engines, CPACSgeo is no longer very useful, acb_struct is used instead

try
    number_of_engines = length(acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine);
    
    for i=1:number_of_engines
        
        engine_struct = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine{1,i};
        
        engine_struct.lib = acb_struct.vehicles{1,1}.engines{1,1}.engine;
        engine_struct.type = 'engines';
        engine_struct.symmetry = 1;
        
        engine_struct.uID = engine_struct.ATTRIBUTE.uID;
        
        updateTable_comps(engine_struct)
        Draw_Components(engine_struct);
    end
    
catch
    disp('No engines')
end

% pylons
%load_pylon(structure)

end

function [] = updateTable_comps(fus_struct)
% 1) read .xml structure data - component name, parameters table
% 2) display Fuselage - Parameters table
% 3) display sub_component listbox (fuselage doesn't have subcomponents now)

global handles component_name comps_struct   sub_component_name  subcomps_struct

%% Step 1)
uID_name = fus_struct.ATTRIBUTE.uID;            % fus_geo.uID
table_name = strcat('component_', uID_name);
listbox_name = strcat('listbox_', uID_name);

%---------------------------------------------%
if isempty(component_name)
    idx = 1;
else
    idx = length(component_name)+1;
end
component_name{idx} = uID_name;
comps_struct{idx} = fus_struct;
sub_component_name{idx} = [];
subcomps_struct{idx} = [];
%---------------------------------------------%

set(handles.listbox, 'String', component_name);                               % set string and value of the listbox
set(handles.listbox, 'Value', idx);
%% Step 2)

try
    symmetry_value = fus_struct.ATTRIBUTE.symmetry;
catch
    symmetry_value = 'no symmetry';
end

fuselage_data = [
    { 'translation x', 'm', str2double(fus_struct.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT)};
    { 'translation y', 'm', str2double(fus_struct.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT)}
    { 'translation z', 'm', str2double(fus_struct.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT)};
    { 'scalling x', '0-', str2double(fus_struct.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT)};
    { 'scalling y', '0-', str2double(fus_struct.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT)};
    { 'scalling z', '0-', str2double(fus_struct.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT)};
    { 'rotation x', 'deg.', str2double(fus_struct.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)};
    { 'rotation y', 'deg.', str2double(fus_struct.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)};
    { 'rotation z', 'deg.', str2double(fus_struct.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)};
    { 'symmetry', '', symmetry_value};
    ];

main_figure.utemp = uitable('Parent', handles.Parameters,...      % create the parameters table for this fuselage component   % main_figure.utemp(counter(1))
    'units','normalized',...
    'Position',[0.0 0.3 1.0 0.7],...
    'ColumnName',{'Parameter','Unit','Value'},...
    'ColumnEditable',[false,false,true],...
    'ColumnFormat',{'char','char','numeric'},...
    'RowName',[],...
    'Data', fuselage_data,...
    'tag',table_name,...
    'CellSelectionCallback',{@compTable_selection},...
    'CellEditCallback',{@compTable_edit});

% create handle for this table
h = findobj('tag',table_name);
handles.(table_name) = h;

% adapt width columns of the tables
set(handles.(table_name), 'Units', 'pixels');
parameters_position = get(handles.(table_name), 'Position');
set(handles.(table_name), 'ColumnWidth', {floor(parameters_position(3)*0.6),floor(parameters_position(3)*0.15),floor(parameters_position(3)*0.2)});
set(handles.(table_name), 'Units', 'normalized');


%% Step 3)

% Sub-Components listbox
main_figure.lb =  uicontrol('style','listbox',...              % main_figure.lb(1 + counter(1))
    'parent', handles.Sub_Components,...
    'units','normalized',...
    'position',[0.0 0.0 1.0 1.0],...
    'tag',listbox_name,...
    'Callback',{@set_ListboxVisibilities_SubComponents},...
    'BackgroundColor',[0.8 0.8 1]);

% create handle for this listbox
h = findobj('tag',listbox_name);
handles.(listbox_name) = h;

end

function load_Wing_Subcomponents(wing_geo, wing_struct)
% for the moment: Control Surfaces - TrailingEdgeDevices
%                 Spars and Ribs _ & Fuel Tanks
% controlSurfaces/trailingEdgeDevices

% -------Wing properties----------
local_symmetry = wing_geo.symmetry;
uID_comp = wing_geo.uID;
%----------------------------------

try
    numOfcompSeg = length(wing_geo.componentSegment);
catch
    numOfcompSeg = 0;
    disp('No component segment for this wing')
end

for compSegNum = 1:numOfcompSeg
    
    compSeg_struct = wing_struct.componentSegments{1,1}.componentSegment{1,compSegNum};
    
    compSeg_geo = wing_geo.componentSegment{compSegNum,1};
    uID_compSeg =  compSeg_geo.uID;
    
    [compseg_start, compseg_etas, compseg_length] = read_compSeg(compSeg_geo, wing_geo);
    
    %----------------------wing_TrailingEdgeDevices------------------%
    try
        numOfTED = length(compSeg_struct.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice);
    catch
        numOfTED = 0;
        disp('No Trailing Edge Devices for this Wing')
    end
    for tedNum=1:numOfTED
        
        iTED_struct = compSeg_struct.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,tedNum};
      
        uID_subComp = iTED_struct.ATTRIBUTE.uID;
        uID_sub_id = strcat(uID_comp, '_', uID_compSeg, '_', uID_subComp);
        %---------------------------------------------
        iTED_struct.wingSectionDef = wing_geo.sectionDef;
        
        iTED_struct.uID_compSeg = uID_compSeg;
        iTED_struct.compsegCount = compSegNum;
        iTED_struct.compSegStart = compseg_start;
        iTED_struct.compSegEtas = compseg_etas;
        
        iTED_struct.type = 'wing_TED';
        iTED_struct.symmetry = local_symmetry;
        iTED_struct.localCount = tedNum;
        %---------------------------------
        [iTED_foils, iTED_geo] = matrix_controlSurf_4(iTED_struct);
        iTED_struct.foils = iTED_foils;
        
        updateTable_subcomps(iTED_geo, iTED_struct, uID_comp, uID_subComp, uID_sub_id);
        %----------------------------------------------
        
        [vertices_TED, triags_TED] = TEDfoil2triangles(iTED_foils.Basic,  local_symmetry);
        Draw_SubComponents(vertices_TED, triags_TED, uID_sub_id, 'wing_TED')
    end
    
    %------------- spars and ribs ------------%
    try
        sparsRibs_struct = compSeg_struct.structure{1,1};
        uID_sub_id = strcat(uID_comp, '_', uID_compSeg, '_', 'sparsRibs');    % here sparsRibs was taken for uID_subcomp, because spars and ribs were shown together!
        sparsRibs_struct.wingSectionDef = wing_geo.sectionDef;
        
        sparsRibs_struct.uID_compSeg = uID_compSeg;
        sparsRibs_struct.compsegCount = compSegNum;
        sparsRibs_struct.compSegStart = compseg_start;
        sparsRibs_struct.compSegEtas = compseg_etas;
        sparsRibs_struct.compSegLength = compseg_length;
        
        sparsRibs_struct.symmetry = local_symmetry;
        sparsRibs_struct.type = 'sparsRibs';
        %--------------------------------------------------
        [Spar_segments, rib_cell, Wings, sparsRibs_geo] = spars_ribs6(sparsRibs_struct);
        updateTable_subcomps(sparsRibs_geo, sparsRibs_struct, uID_comp, 'sparsRibs', uID_sub_id);
        
        [vertices_ribs, facets_ribs, vertices_spars, facets_spars] = sparRibs2triangles(Spar_segments, rib_cell, local_symmetry);
        
        Draw_SubComponents(vertices_ribs, facets_ribs, uID_sub_id, 'ribs')
        Draw_SubComponents(vertices_spars, facets_spars, uID_sub_id, 'spars')
        
    catch
        disp('No structure for this Wing')
    end
 
    %---------------------Fuel Tanks------------------------%
    try
        wingFTs_struct = compSeg_struct.wingFuelTanks{1,1}.wingFuelTank;
        numFuelTank = length(wingFTs_struct);
    catch
        numFuelTank = 0;
        disp('No Fuel Tank for this Wing')
    end
    
    for FTNum = 1: numFuelTank
        wingFT_struct = wingFTs_struct{1,FTNum};
        uID_subComp = wingFT_struct.ATTRIBUTE.uID;
        uID_sub_id = strcat(uID_comp, '_', uID_compSeg, '_sparsRibs_', uID_subComp);
        %----------------------------------------------------
        wingFT_struct.uID_compSeg = uID_compSeg;
        wingFT_struct.Wings = Wings;
        wingFT_struct.sparsRibs = sparsRibs_geo;         % for fuel tanks table modification!
        wingFT_struct.type = 'wingFuelTanks';
        wingFT_struct.symmetry = local_symmetry;
        wingFT_struct.localCount = FTNum;
        wingFT_struct.compsegCount = compSegNum;
        %----------------------------------------------------
        updateTable_subcomps(wingFT_struct, wingFT_struct, uID_comp, uID_subComp, uID_sub_id)
        
        [FT_rib_vertices, FT_faces] = fuel_tanks2(wingFT_struct,  local_symmetry);
        Draw_SubComponents(FT_rib_vertices, FT_faces, uID_sub_id, 'wingFuelTanks')
    end
end

end

function [compseg_start, compseg_etas, compseg_length] = read_compSeg(compSeg_geo, wing_geo)
% take out the startElement and endElement number in this componentSegment
% calculate the eta values for the sections in this componentSegment

compSeg_fromElementUID = compSeg_geo.fromElementUID{1,1}.CONTENT;
compSeg_toElementUID = compSeg_geo.toElementUID{1,1}.CONTENT;

num_elementUIDs = length(wing_geo.sectionDef.sectionElementUIDs);
elementUIDs = cell(num_elementUIDs,1); 

for u = 1 : num_elementUIDs
    elementUIDs(u) = wing_geo.sectionDef.sectionElementUIDs{u,1}.elementUID;    
end

compseg_start = find(strcmp(elementUIDs, compSeg_fromElementUID));
compseg_end = find(strcmp(elementUIDs, compSeg_toElementUID)); 

numEles_compSeg =  compseg_end - compseg_start + 1;
localSpans = [0; wing_geo.localSpan];
compseg_pieceLength = zeros(1,numEles_compSeg);
compseg_etas =  zeros(1,numEles_compSeg);

for u = 2 : numEles_compSeg
    compseg_pieceLength(u) = localSpans(compseg_start + u - 1);
end

compseg_length = sum(compseg_pieceLength);

for u = 1: numEles_compSeg
    compseg_etas(u) = sum(compseg_pieceLength(1:u))/compseg_length;
end

end

function updateTable_subcomps(iTED_geo, iTED_struct, uID_comp, uID_subComp, uID_sub_id)
% 1) read .xml - wing structure, TED structure, name, data_table
% 2) display Wing_TED - Parameters table
% 4) set visibilities of different components for the GUI panel and render

global handles   sub_component_name   subcomps_struct

%% Step 1)
list_index = get(handles.listbox, 'Value');
listbox_name = strcat('listbox_', uID_comp);
table_name = strcat('component_', uID_sub_id);                             % used for the table handles

if isempty(sub_component_name{list_index})
    idx = 1;
else
    idx = length(sub_component_name{list_index}) + 1;
end

sub_component_name{list_index}{idx} = uID_subComp;
set(handles.(listbox_name), 'String', sub_component_name{list_index});
set(handles.(listbox_name), 'Value', idx);
%---------------------------------------------
ith_subComp = length(sub_component_name{list_index});
subcomps_struct{list_index}{ith_subComp} = iTED_struct;                                 % here TED_geo is also possible, depends on later....
%---------------------------------------------

if isfield(handles, table_name)
    try delete(handles.(table_name)); end
end
% set(handles.(listbox_name), 'Value', ith_subComp);
%% Step 2)
switch iTED_struct.type
    case 'wing_TED'
        trailing_edge_data = [
            { 'inner etaLE', '0-1', iTED_geo.etaLE(1)};
            { 'inner etaTE', '0-1', iTED_geo.etaTE(1)}
            { 'inner xsiLE', '0-1', iTED_geo.xsiLE(1)};
            { 'inner relHeightLE', '0-1', iTED_geo.relHeightLE(1)};
            { 'inner xsiUpperSkin', '0-1', iTED_geo.xsiUpperSkin(1)};
            { 'inner xsiLowerSkin', '0-1', iTED_geo.xsiLowerSkin(1)};
            { 'outer etaLE', '0-1', iTED_geo.etaLE(2)};
            { 'outer etaTE', '0-1', iTED_geo.etaTE(2)}
            { 'outer xsiLE', '0-1', iTED_geo.xsiLE(2)};
            { 'outer relHeightLE', '0-1', iTED_geo.relHeightLE(2)};
            { 'outer xsiUpperSkin', '0-1', iTED_geo.xsiUpperSkin(2)};
            { 'outer xsiLowerSkin', '0-1', iTED_geo.xsiLowerSkin(2)};
            { 'step', '', 'default'}
            ];
        main_figure.utemp_SubComp1 = uitable('Parent', handles.Parameters,...    % create the parameters table for this wing sub-component     (counter_SubComp(list_index,1))
            'units','normalized',...
            'Position',[0.0 0.25 1.0 0.75],...
            'ColumnName',{'Parameter','Unit','Value'},...
            'ColumnEditable',[false,false,true],...
            'ColumnFormat',{'char','char','numeric'},...
            'RowName',[],...
            'Data', trailing_edge_data,...
            'tag', table_name,...
            'CellSelectionCallback',{@TEDtable_selection},...
            'CellEditCallback',{@TEDtable_edit});
        
    case 'sparsRibs'
        spars_and_ribs_data = [
            % not implemented yet
            ];
        main_figure.utemp_SubComp2= uitable('Parent', handles.Parameters,...
            'units','normalized',...
            'Position',[0.0 0.3 1.0 0.7],...
            'ColumnName',{'Parameter','Unit','Value'},...
            'ColumnEditable',[false,false,true],...
            'ColumnFormat',{'char','char','numeric'},...
            'RowName',[],...
            'Data', spars_and_ribs_data,...
            'tag', table_name,...
            'CellEditCallback',{@table_spars_and_ribs});
    
    case 'wingFuelTanks'
        % number of borders
        wingFT_struct = iTED_geo;
        number_of_borders = length(wingFT_struct.geometry{1,1}.border);
        
        j = 1;
        for i=1:number_of_borders
            if isfield(wingFT_struct.geometry{1,1}.border{1,i},'sparUID')
                fuel_tanks_data(j,:) = {'Border', 'spar uID', wingFT_struct.geometry{1,1}.border{1,i}.sparUID{1,1}.CONTENT};
                j = j + 1;
            elseif isfield(wingFT_struct.geometry{1,1}.border{1,i},'ribDefinitionUID')
                fuel_tanks_data(j,:) = {'Border', 'rib uID', wingFT_struct.geometry{1,1}.border{1,i}.ribDefinitionUID{1,1}.CONTENT};
                j = j + 1;
                fuel_tanks_data(j,:) = {'rib number', '1-', wingFT_struct.geometry{1,1}.border{1,i}.ribNumber{1,1}.CONTENT};
                j = j + 1;
            end
        end
        
        main_figure.utemp_SubComp3 = uitable('Parent', handles.Parameters,...
            'units','normalized',...
            'Position',[0.0 0.3 1.0 0.7],...
            'ColumnName',{'Parameter','Unit','Value'},...
            'ColumnEditable',[false,false,true],...
            'ColumnFormat',{'char','char','numeric'},...
            'RowName',[],...
            'Data', fuel_tanks_data,...
            'tag', table_name,...
            'CellSelectionCallBack',{@selection_fuel_tanks});
end

h = findobj('tag',table_name);                                                  % create handle for this table
handles.(table_name) = h;

% adapt width columns of the tables
set(handles.(table_name), 'Units', 'pixels');
parameters_position = get(handles.(table_name), 'Position');
set(handles.(table_name), 'ColumnWidth', {floor(parameters_position(3)*0.6),floor(parameters_position(3)*0.15),floor(parameters_position(3)*0.2)});
set(handles.(table_name), 'Units', 'normalized');

end

function XYZ_component = engine_parameters_2_coordinates(engine_struct)

engine_UID = engine_struct.ATTRIBUTE.uID;     % get the engine UID: 4CM036    A3204CM036
size_engine_type = length(engine_struct.lib);

% fing the engine corresponding to the engine UID
for i=1:size_engine_type
    UID = engine_struct.lib{1,i}.ATTRIBUTE.uID;      % 4CM036
    if strcmp(engine_UID, UID) == 1
        engine_type_number = i;
    end
end
engine_type_structure = engine_struct.lib{1,engine_type_number};
engine_transformation = engine_struct.transformation{1,1};

[X_engine, Y_engine, Z_engine] = matrix_engine_cpacs(engine_type_structure, engine_transformation);

size_X_engine = size(X_engine);
XYZ_component = cell(size_X_engine(2),1);
for i = 1:size_X_engine(2)
    XYZ_component{i,1} = [X_engine(:,i),Y_engine(:,i),Z_engine(:,i);
        X_engine(1,i),Y_engine(1,i),Z_engine(1,i)];
end

end

function set_ListboxVisibilities_Components(varargin)
% Select the Component, display the right parameters and listbox contents on the GUI figure
% Step 0: Get the current component name and number; set parameters panel title£»
% Step 1: Set all the component parameters table invisible
% Step 2: Set visible the sub-component listbox corresponding to this component
% Step 3: Set Component Actions & Modify Sections Visibility

global  handles  comps_struct                                                         % element_type

% Step 0
comps_string = get(handles.listbox, 'String');
comp_index = get(handles.listbox, 'Value');

if isempty(comps_string)
    return
end

uID_comp = comps_string{comp_index};
table_name = strcat('component_', uID_comp);
listbox_name = strcat('listbox_', uID_comp);

set(handles.Parameters, 'Title', strcat('Parameters-', uID_comp));

% Step 1
ah_lb = findobj(gcf,'-regexp','Tag','listbox_');
if ~isempty(ah_lb)
    set(ah_lb, 'Visible', 'off')
end
set(handles.(listbox_name), 'Visible', 'on');

ah = findobj(gcf,'-regexp', 'Tag','component_');
if ~isempty(ah)
    set(ah, 'Visible', 'off')
end
set(handles.(table_name), 'Visible', 'on');

%-------------------------------------------
localStruct = comps_struct{comp_index};
component_type = localStruct.type;
%-------------------------------------------

% Step 3
set(handles.Actions, 'Title', 'Components Actions');

set(handles.Select, 'Visible', 'on');
set(handles.Add, 'Visible', 'on');
set(handles.Remove, 'Visible', 'on');

set(handles.Select_SubComp, 'Visible', 'off');
set(handles.Add_SubComp, 'Visible', 'off');
set(handles.Remove_SubComp, 'Visible', 'off');

set(handles.modify_steps, 'Visible', 'off');
set(handles.modify_spars_and_ribs, 'Visible', 'off');

switch component_type
    case {'fuselages','wings'}       % fuselage
        set(handles.modify_sections, 'Visible', 'on');
        set(handles.modify_engine, 'Visible', 'off');
        
    case 'engines'           % engines
        set(handles.modify_sections, 'Visible', 'off');
        set(handles.modify_engine, 'Visible', 'on');
end

end

function set_ListboxVisibilities_SubComponents(varargin)
% Select the SubComponent, display the corresponding parameters and listbox contents on the GUI figure
% Step 0: Set all the component parameters table invisible
% Step 1: Get the current component, subcomponent's name and number; set parameters panel title£»
% Step 2: Set visible the sub-component listbox corresponding to this component
% Step 3: Set Component Actions & Modify Sections Visibility

global  handles  subcomps_struct

% Step 0
comp_strings = get(handles.listbox, 'String');
comp_index = get(handles.listbox, 'Value');
uID_comp = comp_strings{comp_index};
listbox_name = strcat('listbox_', uID_comp);

subcomp_strings = get(handles.(listbox_name), 'String');

if isempty(subcomp_strings)
    set(handles.Actions, 'Title', 'Sub-Components Actions');
    
    set(handles.Select, 'Visible', 'off');
    set(handles.Add, 'Visible', 'off');
    set(handles.Remove, 'Visible', 'off');
    
    % set visible buttons corresponding to sub-component
    set(handles.Select_SubComp, 'Visible', 'on');
    set(handles.Add_SubComp, 'Visible', 'on');
    set(handles.Remove_SubComp, 'Visible', 'on');
    
    % set invisible objects relatives to components
    set(handles.modify_sections, 'Visible', 'off');
    set(handles.modify_engine, 'Visible', 'off');
    set(handles.modify_steps, 'Visible', 'off');
    set(handles.modify_spars_and_ribs, 'Visible', 'off');
    
    ah = findobj(gcf,'-regexp','Tag','component_');
    if ~isempty(ah)
        set(ah, 'Visible', 'off')
    end
    
else
    subcomp_index =  get(handles.(listbox_name), 'Value');
    uID_subcomp = subcomp_strings{subcomp_index};
    
    % Step 1
    ah = findobj(gcf,'-regexp','Tag','component_');
    if ~isempty(ah)
        set(ah, 'Visible', 'off')
    end
    
    set( findobj(gcf,'-regexp','Tag',uID_subcomp, '-not',{'-regexp','Tag',[uID_subcomp '_']}, '-and', {'-regexp','Tag','component_'}), 'Visible', 'on');
    set(handles.Parameters, 'Title', strcat('Parameters-', uID_subcomp));    % Component_Segment_Name!!!  set panel Parameters title
    
    %-----------------------------------------------------------
    subcomp_Geo =subcomps_struct{comp_index}{subcomp_index};
    subcomp_type = subcomp_Geo.type;
    %-----------------------------------------------------------
    
    % Step 2
    set(handles.Actions, 'Title', 'Sub-Components Actions');
    
    set(handles.Select, 'Visible', 'off');
    set(handles.Add, 'Visible', 'off');
    set(handles.Remove, 'Visible', 'off');
    
    % set visible buttons corresponding to sub-component
    set(handles.Select_SubComp, 'Visible', 'on');
    set(handles.Add_SubComp, 'Visible', 'on');
    set(handles.Remove_SubComp, 'Visible', 'on');
    
    % set invisible objects relatives to components
    set(handles.modify_sections, 'Visible', 'off');
    set(handles.modify_engine, 'Visible', 'off');
    
    % Step 3
    
    switch subcomp_type
        case 'wing_TED'      % trailing edge devices
            set(handles.modify_steps, 'Visible', 'on');
            set(handles.modify_spars_and_ribs, 'Visible', 'off');
            
        case 'sparsRibs'      % spars and ribs
            set(handles.modify_steps, 'Visible', 'off');
            set(handles.modify_spars_and_ribs, 'Visible', 'on');
            
        case 'fuelTanks'      % fuel tanks
            set(handles.modify_steps, 'Visible', 'off');
            set(handles.modify_spars_and_ribs, 'Visible', 'off');
    end
    
end


end

function Draw_Components(geo)
global handles main_figure

uID_comp = geo.uID;
local_symmetry = geo.symmetry;
component_type = geo.type;

switch component_type
    case {'fuselages','wings'}                      % geo is part of CPACSgeo
        XYZ_component = geo.sectionDef.airfoil;
    case 'engines'                                 % here geo is engine_struct
        engine_struct = geo;
        XYZ_component = engine_parameters_2_coordinates(engine_struct);
end

[vertices_Component, facets_Component] = patch_triangles2(XYZ_component, local_symmetry, component_type);

%------Colors, and others-------

switch component_type
    case 'fuselages'
        faceColr = [0,0.75,0.75];            %  'b'  [0.2314 0.4431 0.3373]; 
    case 'wings'
        faceColr = [0,0.5,0];        %  'g'  [0.4000 1.0000 0.4000];
    case 'engines'
        faceColr = [0.7490,0.7490,0];   %  [1 1 0];
end


% figure()
% plot3(vertices_Component(:,1),vertices_Component(:,2),vertices_Component(:,3),'b.')
% axis equal
% hold on
% hold all
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
%

axes(handles.axes3d)
main_figure.(uID_comp) = patch('Vertices', vertices_Component, 'Faces', facets_Component,'EdgeColor','none','FaceColor',  faceColr,...      %
    'Tag',uID_comp,  'FaceLighting','phong');

view(handles.axes3d, 3) 
light('Position',[1 1 1],'Style','infinite') 
material  metal                            %metal %  shiny   %dull
lighting gouraud                             %phong    % gouraud   %phong;  flat
alpha('opaque');   

set(findobj(gca,'type','patch'),'AmbientStrength', 0.4,'DiffuseStrength',0.1,...
    'SpecularColorReflectance',0.1,'SpecularExponent',30, 'SpecularStrength',0.2);

axis square
axis equal
axis vis3d    
axis off
hold all
hold on

h = findobj('Tag',uID_comp);
handles.(uID_comp) = h;

end

function Draw_SubComponents(vertices_SubComponent, facets_SubComponent, uID_sub_id, SubComponent_type)
global main_figure handles

switch SubComponent_type    
    case 'wing_TED'
        colorspec={'r','m','k'};
        axes(main_figure.renderer)
        main_figure.(uID_sub_id) = ...
            patch('Vertices', vertices_SubComponent, 'Faces', facets_SubComponent,'EdgeColor','none',...
            'FaceColor', colorspec{1}, 'Tag',uID_sub_id);
        
        h = findobj('Tag',uID_sub_id);
        handles.(uID_sub_id) = h;        
    case 'spars'
        spars = [uID_sub_id '_spars'];
        axes(main_figure.renderer)
        main_figure.(spars) = ...
            patch('Vertices',   vertices_SubComponent , 'Faces',   facets_SubComponent ,'FaceColor','b','EdgeColor','none','Tag',spars);
        
        h = findobj('Tag',spars);
        guidata(gcf,h);        
    case 'ribs'
        axes(main_figure.renderer)
        ribs = [uID_sub_id '_ribs'];
        main_figure.(ribs) = ...
            patch('Vertices',  vertices_SubComponent , 'Faces', facets_SubComponent ,'FaceColor','r','EdgeColor','none','Tag',ribs);
        h = findobj('Tag',ribs);
        guidata(gcf,h);        
    case 'wingFuelTanks'
        axes(main_figure.renderer)
        main_figure.(uID_sub_id) = ...
            patch('Vertices',  vertices_SubComponent, 'Faces', facets_SubComponent,'FaceColor','k','Tag',uID_sub_id,'FaceAlpha', 1);
        
end

set(findobj(gca,'type','patch'),'AmbientStrength', 0.4,'DiffuseStrength',0.1,...
    'SpecularColorReflectance',0.1,'SpecularExponent',30, 'SpecularStrength',0.2);

end

function [] = select_comps(varargin)

global  handles

% get the component number
list_string = get(handles.listbox, 'String');
list_index = get(handles.listbox, 'Value');
uID_name = list_string{list_index};

current_state = get(findobj(gca,'tag',uID_name), 'visible');

if strcmp(current_state, 'on')
    set(handles.(uID_name),'visible','off');
elseif strcmp(current_state, 'off')
    set(handles.(uID_name) ,'visible','on');
end

end

function [] = remove_comps(varargin)
% Several things happen when a component is removed
% 1) update component listbox, component parameters, subcomponent listbox
% 2) delete the patch object handle (graphic update)
% 1) identify the component being removed
% 2)
%    delete the removed component's sturcture content from acb_struct

global handles component_name   sub_component_name  comps_struct    subcomps_struct

% 1)
list_string = get(handles.listbox, 'String');
list_index = get(handles.listbox, 'Value');

uID_comp = list_string{list_index};
listbox_name = strcat('listbox_', uID_comp);

comps_struct(list_index) = [];
subcomps_struct(list_index) = [];
% 2)
%{
switch local_element_type
    case 1                                   % fuselages
    %     counters_minusDown('fuselage',list_index);
        fuselage_structure = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage;      % get the fuselage structure __ before "remove" action
        fuselage_structure(local_counter) = [];
        acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage = fuselage_structure;      % re-organize the structure after "remove"
        
    case 2                                  % wings
        counters_minusDown('wing',list_index);
        wing_structure = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing;             % get the wing structure __ before "remove" action
        wing_structure(local_counter) = [];                                                              % re-organize the structure after "remove"
        acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing = wing_structure;    % change the part corresponding to the engine into the main global structure
        
    case 3                                  % engines
        counters_minusDown('engine',list_index);
        engine_structure = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine;      % get the engine structure
        engine_structure(local_counter) = [];
        acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine = engine_structure;
end
%}

% 3)
component_name(list_index) = [];
set(handles.listbox, 'String', component_name);
if list_index > 1
    set(handles.listbox, 'Value', list_index-1);
end

sub_component_name{list_index} = [];
set(handles.(listbox_name), 'String', sub_component_name{list_index});


ah_ThisComp = findobj(gcf,'-regexp','Tag',uID_comp);
if ~isempty(ah_ThisComp)
    delete(ah_ThisComp)
end

end

function [] = add_comps(varargin)

ListString = char({ 'Fuselage'; 'Wing'; 'Engine nacelle';});                      % list of the component available for building the aircraft
[selection,ok] = listdlg('ListString',ListString,...
    'InitialValue',[],'ListSize',[300,100],'PromptString',...
    'Choose the component type to add','Name','components',...
    'SelectionMode','Single','CancelString','Exit');
if ok==0
    return     % Closes
end

%--------------------------------------------
foldernow=['..' filesep '..' filesep 'Projects' filesep];                         % choose the xml file
[FileName,PathName]=uigetfile('*.xml','Choose the component template',foldernow);
if FileName==0
    return
end
disp('Reading .xml into matlab structure, please wait...')
workfolder = strcat(PathName,FileName);
xml_struct = xml2struct(workfolder);        % convert xml file to matlab structure
CPACS_XML = xml_struct.cpacs{1,1};
%--------------------------------------------

switch selection
    case 1      % Fuselage
        component_structure = CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage;          % get the fuselage structure
    case 2      % Wing
        component_structure = CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing;                  % get the wing structure
    case 3      % Engine
        component_structure = CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine;
end

NoOfSelectedComponents = length(component_structure);

list_component_name = '';                                                       % name list for those fuselages
for i=1:NoOfSelectedComponents
    SelectedComponent_name = component_structure{1,i}.ATTRIBUTE.uID;
    list_component_name = char(char(list_component_name), char(SelectedComponent_name));
    list_component_name = cellstr(list_component_name);
end
list_component_name = list_component_name(2:end);

[selection_component,ok_component] = listdlg('ListString',list_component_name,...               % choose one component from the list of this type component
    'InitialValue',[],'ListSize',[300,100],'PromptString',...
    'Choose from','Name','component',...
    'SelectionMode','Single','CancelString','Exit');
if ok_component==0
    return                          % Close
end
%---------------------------------------------------------
pause(.1)

CompGeo = [];
disp('Reading .xml component into matlab structure, please wait...')
switch selection                                                             % load_fuselage(fus_geo,fus_struct)
    case 1                                                                   % Fuselage
        fuselage_struct = component_structure{1,selection_component};
        fuselage_struct.profiles = CPACS_XML.vehicles{1,1}.profiles{1,1}.fuselageProfiles{1,1}.fuselageProfile;
        fuselage_struct.type = 'fuselages';
        
        [CompGeo]=readfuselage_localStruct(CompGeo, fuselage_struct);
        updateTable_comps(fuselage_struct)
        Draw_Components(CompGeo);
        
    case 2                                                                   % Wing
        wing_struct = component_structure{1,selection_component};
        wing_struct.profiles = CPACS_XML.vehicles{1,1}.profiles{1,1}.wingAirfoils{1,1}.wingAirfoil;
        wing_struct.reference=CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference;
        wing_struct.type = 'wings';
        
        [CompGeo]=readwings_localStruct(CompGeo, wing_struct);
        updateTable_comps(wing_struct)
        Draw_Components(CompGeo);
        load_Wing_Subcomponents(CompGeo, wing_struct)
        
    case 3                                                                  % Engine
        engine_struct = component_structure{1,selection_component};
        engine_struct.lib = CPACS_XML.vehicles{1,1}.engines{1,1}.engine;
        engine_struct.type = 'engines';
        engine_struct.symmetry = 1;
        engine_struct.uID = engine_struct.ATTRIBUTE.uID;
        
        updateTable_comps(engine_struct)
        Draw_Components(engine_struct);
end
end

function [] = select_subcomps(varargin)
global  handles

list_string = get(handles.listbox, 'String');                               % get the component name
list_index = get(handles.listbox, 'Value');                                 % get the component number
uID_name = list_string{list_index};
listbox_name = strcat('listbox_', uID_name);

list_string_SubComp = get(handles.(listbox_name), 'String');              % get the sub-component name
list_index_SubComp = get(handles.(listbox_name), 'Value');                % get the sub-component number

if size(list_string_SubComp,1) == 1
    uID_sub_name = list_string_SubComp(list_index_SubComp,:);
else
    uID_sub_name = list_string_SubComp{list_index_SubComp};
end

h = findobj(gca,'-regexp','Tag',uID_name,'-and','-regexp','Tag', uID_sub_name);
current_state = get(h,'visible');

if strcmp(current_state, 'on')
    set(h,'visible','off')
elseif strcmp(current_state, 'off')
    set(h,'visible','on')
end

end

function [] = remove_subcomps(varargin)
% Several things happen when a SubComponent is removed
% 3) delete the subcomponent's parameters
% 4) delete the patch object handle (graphic update)

global  handles  sub_component_name  subcomps_struct  comps_struct
% 1)
comps_string = get(handles.listbox, 'String');                              % get the component name
comp_index = get(handles.listbox, 'Value');                                 % get the component number
uID_comp = comps_string{comp_index};
listbox_name = strcat('listbox_', uID_comp);

subcomps_string = get(handles.(listbox_name), 'String');                    % get the sub-component name
subcomp_index = get(handles.(listbox_name), 'Value');                       % get the sub-component number
uID_subcomp = subcomps_string{subcomp_index};

comp_struct = comps_struct{comp_index};
subcomp_geo = subcomps_struct{comp_index}{subcomp_index};

ListString = char({ 'Component segment'; 'Sub-Component selected';});         % choose to remove component segment or sub-component
[selection,ok] = listdlg('ListString',ListString,...
    'InitialValue',[],'ListSize',[300,100],'PromptString',...
    'Component segment or Sub-Component','Name','Remove function',...
    'SelectionMode','Single','CancelString','Exit');
if ok==0
    return
end

uID_compSeg = subcomp_geo.uID_compSeg;
compSegs_struct = comp_struct.componentSegments{1,1}.componentSegment;
number_of_CS = length(compSegs_struct);

for i = 1:number_of_CS
    CS_name = compSegs_struct{1,i}.ATTRIBUTE.uID;
    if strcmp(CS_name, uID_compSeg)
        idx_compseg = i;
    end
end

switch selection
    case 1                                                                    % remove component segment
        message = ['All the sub-components belonging to this component segment-' uID_compSeg '-will be removed'];
        choice = questdlg(message, 'Remove function', 'Ok', 'Cancel', 'Cancel');
        if strcmp(choice,'Cancel') == 1
            return               % close
        end
        
        j = 0;
        for i = 1: length(sub_component_name{comp_index})
            uID_sub_ith = sub_component_name{comp_index}{i};
            
            ah = findobj(gca,'-regexp','Tag',uID_sub_ith,'-and','-regexp','Tag',uID_comp);
            ah_tag = get(ah,'Tag');
            
            if ~isempty(strfind(ah_tag,  uID_compSeg))
                j = j+1;
                idx_sub_compseg(j) = i;
            end
        end
        sub_component_name{comp_index}(idx_sub_compseg) = [];
        subcomps_struct{comp_index}(idx_sub_compseg) = [];
        
        set(handles.(listbox_name), 'String', sub_component_name{comp_index});
        set(handles.(listbox_name), 'Value', 1);
        delete(findobj(gcf,'-regexp','Tag', uID_comp,'-and','-regexp','Tag',  uID_compSeg))
        
        %------Delete the component segment from Wing_structure as well----
        comp_struct.componentSegments{1,1}.componentSegment(idx_compseg) = [];
        comps_struct{comp_index} = comp_struct;
        %------------------------------------------------------------------
        
    case 2
        switch subcomp_geo.type
            case 'sparsRibs'        %------------If sparsRibs was selected to remove---------------
                message = 'The fuel tanks associated with this set of spars an ribs will be removed as well';
                choice = questdlg(message, 'Remove function', 'Ok', 'Cancel', 'Cancel');
                if strcmp(choice,'Cancel') == 1
                    return                                                         % close
                end
                
                j = 0;
                for i = 1: length(sub_component_name{comp_index})
                    uID_sub_ith = sub_component_name{comp_index}{i};
                    
                    ah = findobj(gca,'-regexp','Tag',uID_sub_ith,'-and','-regexp','Tag',uID_comp);
                    ah_tag = get(ah,'Tag');
                    
                    if ~isempty(strfind(ah_tag,  uID_subcomp))
                        j = j+1;
                        idx_sub_sparrib(j) = i;
                    end
                end
                sub_component_name{comp_index}(idx_sub_sparrib) = [];
                subcomps_struct{comp_index}(idx_sub_sparrib) = [];
                
                comp_struct.componentSegments{1,1}.componentSegment{1,idx_compseg}.structure(1) = [];
                comp_struct.componentSegments{1,1}.componentSegment{1,idx_compseg}.wingFuelTanks{1,1}.wingFuelTank = [];
                comps_struct{comp_index} = comp_struct;
                
            case 'wing_TED'
                TEDs_struct = comp_struct.componentSegments{1,1}.componentSegment{1,idx_compseg}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice;
                numTEDs = length(TEDs_struct);
                
                for j = 1: numTEDs
                    iTED_uID =  TEDs_struct{1,j}.ATTRIBUTE.uID;
                    if strcmp(iTED_uID, uID_subcomp)
                        comp_struct.componentSegments{1,1}.componentSegment{1,idx_compseg}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice(j) = [];
                    end
                end
                
                sub_component_name{comp_index}(subcomp_index) = [];
                subcomps_struct{comp_index}(subcomp_index) = [];
                comps_struct{comp_index} = comp_struct;
                
            case 'wingFuelTanks'
                FTs_struct = comp_struct.componentSegments{1,1}.componentSegment{1,idx_compseg}.wingFuelTanks{1,1}.wingFuelTank;
                numFTs = length(FTs_struct);
                
                for j = 1:numFTs
                    iFT_uID = FTs_struct{1,j}.ATTRIBUTE.uID;
                    if strcmp(iFT_uID, uID_subcomp);
                        comp_struct.componentSegments{1,1}.componentSegment{1,idx_compseg}.wingFuelTanks{1,1}.wingFuelTank(j) = [];
                    end
                end
                
                sub_component_name{comp_index}(subcomp_index) = [];
                subcomps_struct{comp_index}(subcomp_index) = [];
                comps_struct{comp_index} = comp_struct;
        end
        
        set(handles.(listbox_name), 'String', sub_component_name{comp_index});
        set(handles.(listbox_name), 'Value', 1);
        delete(findobj(gcf,'-regexp','Tag', uID_comp,'-and','-regexp','Tag',  uID_subcomp))
end
end

function [] = add_subcomps(varargin)
global handles handles_TED handles_cs handles_sr handles_FT
global comps_struct  final_CS_struct final_TEDs_struct  final_srStruct   final_FTs_struct
global subcomps_struct

comps_string = get(handles.listbox, 'String');
if isempty(comps_string)
    warndlg('A major component need to exist onto which a new subcomponent can be added', 'Warning');
    return
end

comp_index = get(handles.listbox, 'Value');
uID_comp = comps_string{comp_index};

wing_struct = comps_struct{comp_index};
local_comp_type = wing_struct.type;

switch local_comp_type
    case 'wings'                                                                 % for wings:
        ListString = char({ 'Component segment'; 'Sub-component';});             % Add a new component segment or a sub-component
        [pre_selection,pre_ok] = listdlg('ListString',ListString,...
            'InitialValue',[],'ListSize',[300,100],'PromptString',...
            'Component segment or Sub-Component','Name','Add Function',...
            'SelectionMode','Single','CancelString','Exit');
        if pre_ok == 0
            return                                                               % Close
        end
        
        if pre_selection == 1                    % new component segment is to be added
            
            if isfield(wing_struct,'componentSegments')
                compSegs_struct = wing_struct.componentSegments{1,1}.componentSegment;
                number_of_CS = length(compSegs_struct);
            else
                compSegs_struct = [];
                number_of_CS = 0;
            end
            
            figure_componentSegment2(wing_struct, compSegs_struct, number_of_CS + 1);     % call function figure_TED.m
            uiwait(handles_cs.figure_componentSegment)                                                    % wait for the close of the window
            
            wing_struct.componentSegments{1,1}.componentSegment = final_CS_struct;
            comps_struct{comp_index} = wing_struct;
            
        elseif pre_selection == 2               % a new sub-component is to be added
            
            %----------Choose onto which Component Segment to add--------
            try
                number_of_CS = length(wing_struct.componentSegments{1,1}.componentSegment);      % get the number of componentSegment for this wing component
            catch
                warndlg('no component segment exists onto which a subcomponent can be added, create a component segment first', 'Warning');
                return
            end
            
            if isempty(wing_struct.componentSegments{1,1}.componentSegment)
                warndlg('no component segment exists onto which a subcomponent can be added, create a component segment first', 'Warning');
                return
            end
            
            for i=1:number_of_CS
                CS_name{i} = wing_struct.componentSegments{1,1}.componentSegment{1,i}.ATTRIBUTE.uID;
            end
            
            [selection_CS,ok_CS] = listdlg('ListString',CS_name,...
                'InitialValue',[],'ListSize',[300,100],'PromptString',...
                'Choose onto which component segment to add','Name','component segments',...
                'SelectionMode','Single','CancelString','Exit');
            if ok_CS==0
                return
            end
            
            %-------Preparation: for later subcomponent creation-------
            CS_structure = wing_struct.componentSegments{1,1}.componentSegment{1,selection_CS};
            uID_compSeg = CS_structure.ATTRIBUTE.uID;
            
            wingAD_geo = [];
            [wingAD_geo]=readwings_localStruct(wingAD_geo, wing_struct);
            local_symmetry = wingAD_geo.symmetry;
            
            compSeg_geo = wingAD_geo.componentSegment{selection_CS,1};
            %  uID_compSeg =  compSeg_geo.uID;
            
            [compseg_start, compseg_etas, compseg_length] = read_compSeg(compSeg_geo, wingAD_geo);
            
            %----------Choose the type of subcomponent to add--------
            ListString = char({ 'Trailing Edge'; 'Spars and ribs';'Fuel tank'});                                % list of the sub-components available for the component selected
            [selection_type,ok] = listdlg('ListString',ListString,...
                'InitialValue',[],'ListSize',[300,100],'PromptString',...
                'Choose the sub-component type','Name','sub-components',...
                'SelectionMode','Single','CancelString','Exit');
            if ok==0
                return
            end
            
            %---------Treat differently: to add TED, sparsRibs, fuelTanks
            switch selection_type
                case 1                  % Trailing Edge
                    
                    if isfield(CS_structure, 'controlSurfaces')
                        TEDs_structure = CS_structure.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice;  % get the trailing edge devices structure
                        number_of_TED = length(TEDs_structure);
                    else
                        TEDs_structure = [];
                        number_of_TED = 0;
                    end
                    
                    figure_TED2(wingAD_geo, TEDs_structure, number_of_TED + 1, compseg_start, compseg_etas);
                    uiwait(handles_TED.figure_TED)
                    
                    if length(final_TEDs_struct) > length(TEDs_structure)
                        CS_structure.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice = final_TEDs_struct;
                        wing_struct.componentSegments{1,1}.componentSegment{1,selection_CS} = CS_structure;
                        comps_struct{comp_index} = wing_struct;
                        
                        %-------------For displaying this added TED------------
                        added_iTED_struct = final_TEDs_struct{1, number_of_TED + 1};
                        uID_subComp = added_iTED_struct.ATTRIBUTE.uID;
                        uID_sub_id = strcat(uID_comp, '_', uID_compSeg, '_', uID_subComp);
                        %---------------------------------------------
                        added_iTED_struct.wingSectionDef = wingAD_geo.sectionDef;
                        
                        added_iTED_struct.uID_compSeg = uID_compSeg;
                        added_iTED_struct.compsegCount = selection_CS;
                        added_iTED_struct.compSegStart = compseg_start;
                        added_iTED_struct.compSegEtas = compseg_etas;
                        
                        added_iTED_struct.type = 'wing_TED';
                        added_iTED_struct.symmetry = local_symmetry;
                        added_iTED_struct.localCount = number_of_TED + 1;
                        %---------------------------------
                        [iTED_foils, iTED_geo] = matrix_controlSurf_4(added_iTED_struct);
                        added_iTED_struct.foils = iTED_foils;
                        
                        updateTable_subcomps(iTED_geo, added_iTED_struct, uID_comp, uID_subComp, uID_sub_id);
                        %----------------------------------------------
                        
                        [vertices_TED, triags_TED] = TEDfoil2triangles(iTED_foils.Basic,  local_symmetry);
                        Draw_SubComponents(vertices_TED, triags_TED, uID_sub_id, 'wing_TED')
                    end
                case 2                   % Spars and ribs
                    if isfield(CS_structure, 'structure')  && ~isempty(CS_structure.structure)
                        errordlg('impossible to define more than 1 set of spars defintions for 1 component segment')
                        return
                    else
                        sparsRibs_struct = [];
                    end
                    %---------------------------------------------                 
                    sparsRibs_struct.wingSectionDef = wingAD_geo.sectionDef;
                    sparsRibs_struct.uID_compSeg = uID_compSeg;
                    sparsRibs_struct.compsegCount = selection_CS;
                    sparsRibs_struct.compSegStart = compseg_start;
                    sparsRibs_struct.compSegEtas = compseg_etas;
                    sparsRibs_struct.compSegLength = compseg_length;
        
                    sparsRibs_struct.symmetry = local_symmetry;
                    sparsRibs_struct.type = 'sparsRibs';
                      
                    [sparsRibs_struct] = build_sparsRibs_skeleton(sparsRibs_struct);
                    %----------------------------------------------
                    figure_spars_and_ribs3(sparsRibs_struct);
                    uiwait(handles_sr.figure_spars_and_ribs)
                    
                    if final_srStruct.change > 0
                        CS_structure.structure{1,1} = final_srStruct;
                        wing_struct.componentSegments{1,1}.componentSegment{1,selection_CS} = CS_structure;
                        comps_struct{comp_index} = wing_struct;
                        
                        %------------For displaying this added Spars and Ribs
                        uID_sub_id = strcat(uID_comp, '_', uID_compSeg, '_', 'sparsRibs');
                        %--------------------------------------------------

                        [Spar_segments, rib_cell, Wings, sparsRibs_geo] = spars_ribs6(final_srStruct);
                        updateTable_subcomps(sparsRibs_geo, final_srStruct, uID_comp, 'sparsRibs', uID_sub_id);
                        
                        [vertices_ribs, facets_ribs, vertices_spars, facets_spars] = sparRibs2triangles(Spar_segments, rib_cell, local_symmetry);
                        Draw_SubComponents(vertices_ribs, facets_ribs, uID_sub_id, 'ribs')
                        Draw_SubComponents(vertices_spars, facets_spars, uID_sub_id, 'spars')
                    end
                    
                case 3                        % fuel tank
                    
                    if isempty(CS_structure.structure)                     % check if there is spars and ribs for this component segment
                        errordlg('no spars an ribs found for adding fuel tank');
                        return
                    else                   % find out the spars_ribs_struct
                        for j = 1: length(subcomps_struct{comp_index})
                            jth_subcomp = subcomps_struct{comp_index}{j};
                            if strcmp(jth_subcomp.type, 'sparsRibs')
                                sparsRibs_struct = jth_subcomp;
                                [Spar_segments, rib_cell, Wings, sparsRibs_geo] = spars_ribs6(sparsRibs_struct);
                            end
                        end
                    end
                    
                    try
                        fuel_tank_structure = CS_structure.wingFuelTanks{1,1}.wingFuelTank;        % get the fuel tank structure
                        num_fuelTanks = length(fuel_tank_structure);
                    catch
                        fuel_tank_structure = [];
                        num_fuelTanks = 0;
                    end
                    
                    figure_fuel_tank2(sparsRibs_struct, fuel_tank_structure, num_fuelTanks + 1);
                    uiwait(handles_FT.figure_fuel_tank)
                    
                    if length(final_FTs_struct) > length(fuel_tank_structure)
                        CS_structure.wingFuelTanks{1,1}.wingFuelTank = final_FTs_struct;
                        wing_struct.componentSegments{1,1}.componentSegment{1,selection_CS} = CS_structure;
                        comps_struct{comp_index} = wing_struct;
                        
                        %----------For displaying this added Fuel Tank---
                        added_iFT_struct =  final_FTs_struct{1, num_fuelTanks + 1};
                        uID_subComp = added_iFT_struct.ATTRIBUTE.uID;
                        uID_sub_id = strcat(uID_comp, '_', uID_compSeg, '_sparsRibs_', uID_subComp);
                        %----------------------------------------------------
                        added_iFT_struct.uID_compSeg = uID_compSeg;
                        added_iFT_struct.Wings = Wings;
                        added_iFT_struct.sparsRibs = sparsRibs_geo;         % for fuel tanks table modification!
                        added_iFT_struct.type = 'wingFuelTanks';
                        added_iFT_struct.symmetry = local_symmetry;
                        added_iFT_struct.localCount = num_fuelTanks + 1;
                        added_iFT_struct.compsegCount = selection_CS;
                        %----------------------------------------------------
                        updateTable_subcomps(added_iFT_struct, added_iFT_struct, uID_comp, uID_subComp, uID_sub_id)
                        
                        [FT_rib_vertices, FT_faces] = fuel_tanks2(added_iFT_struct,  local_symmetry);
                        Draw_SubComponents(FT_rib_vertices, FT_faces, uID_sub_id, 'wingFuelTanks')
                    end
            end
            
        end
        
    otherwise
        disp('So far only wings have subcomponents; fuselage and engine don''t');
end

end

function [] = compTable_selection(varargin)

global handles  comps_struct

event = varargin{2};

list_string = get(handles.listbox, 'String');
list_index = get(handles.listbox, 'Value');
uID_name = list_string{list_index};
table_name = strcat('component_', uID_name);

compTrans_data = get(handles.(table_name), 'Data');

%-------------------------------------------------------
comp_localStruct = comps_struct{list_index};

if isfield(comp_localStruct.ATTRIBUTE,'symmetry')      % here fus_struct was used, since CPACSgeo only has two status: symmetry 1 or nosymmetry 0, not x-z, x-y, or y-z plane
    switch comp_localStruct.ATTRIBUTE.symmetry
        case 'no symmetry'
            symmetry_value=0;
        case 'x-z-plane'
            symmetry_value=1;
        case 'x-y-plane'
            symmetry_value=2;
        case 'y-z-plane'
            symmetry_value=3;
    end
else
    comp_localStruct.ATTRIBUTE.symmetry ='no symmetry';
    symmetry_value=0;
end
%-----------------------------------------------------

if numel(event.Indices)== 0                                                 % avoid a bug after the close of the window
    return;
end

if event.Indices(1) == 10                                                   % symmetry
    popupmenu_string = {'no symmetry';'x-z-plane';'x-y-plane';'y-z-plane' };
    [selection,ok] = listdlg('ListString',popupmenu_string,...
        'InitialValue',(symmetry_value+1),'ListSize',[300,100],'PromptString',...
        'Choose the symmetry','Name','symmetry',...
        'SelectionMode','Single','CancelString','Exit');
    if ok == 0
        return
    end
    
    symmetry_value =  selection;
    
    compTrans_data(10,3) = cellstr(popupmenu_string(symmetry_value,:));
    comp_localStruct.ATTRIBUTE.symmetry = cellstr(popupmenu_string(symmetry_value,:));
    
    set(handles.(table_name), 'Data', compTrans_data);
    %-------------------------------------------------------
    comp_localStruct.ATTRIBUTE.symmetry = char(compTrans_data(10,3));
    comps_struct{list_index} = comp_localStruct;
    %-------------------------------------------------------
    ah_ThisComp = findobj(gca,'-regexp','Tag',uID_name);
    if ~isempty(ah_ThisComp)
        delete(ah_ThisComp)
    end
    %-----------------------------------------------------
    
    CompGeo = [];
    switch comp_localStruct.type
        case 'fuselages'
            [CompGeo]=readfuselage_localStruct(CompGeo, comp_localStruct);
            Draw_Components(CompGeo);
            
        case 'wings'
            [CompGeo]=readwings_localStruct(CompGeo, comp_localStruct);
            
            Draw_Components(CompGeo);
            
            load_Wing_Subcomponents(CompGeo, comp_localStruct)
            
        case 'engines'
            comp_localStruct.symmetry = selection-1;
            Draw_Components(comp_localStruct);
    end
    
    
end

end

function [] = compTable_edit(varargin)

global handles  comps_struct  sub_component_name

event = varargin{2};

list_string = get(handles.listbox, 'String');
list_index = get(handles.listbox, 'Value');
uID_name = list_string{list_index};
table_name = strcat('component_', uID_name);
listbox_name = strcat('listbox_', uID_name);

compTrans_data = get(handles.(table_name), 'Data');

%--------------------------------------------------
comp_localStruct = comps_struct{list_index};
%--------------------------------------------------

if numel(event.Indices)== 0                                                 % avoid a bug after the close of the window
    return;
end

switch event.Indices(1)
    case 1                 % translation x
        compTrans_data(1,3) = num2cell(event.NewData);
        comp_localStruct.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(1,3)));
    case 2                 % translation y
        compTrans_data(2,3) = num2cell(event.NewData);
        comp_localStruct.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(2,3)));
    case 3                 % translation z
        compTrans_data(3,3) = num2cell(event.NewData);
        comp_localStruct.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(3,3)));
    case 4                 % scaling x
        scaling_x = event.NewData;
        if scaling_x < 0
            scaling_x = 0;
        end
        compTrans_data(4,3) = num2cell(scaling_x);
        comp_localStruct.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(4,3)));
    case 5                % scaling y
        scaling_y = event.NewData;
        if scaling_y < 0
            scaling_y = 0;
        end
        compTrans_data(5,3) = num2cell(scaling_y);
        comp_localStruct.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(5,3)));
    case 6             % scaling z
        scaling_z = event.NewData;
        if scaling_z < 0
            scaling_z = 0;
        end
        compTrans_data(6,3) = num2cell(scaling_z);
        comp_localStruct.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(6,3)));
    case 7    % rotation x
        rotation_x = event.NewData;
        if rotation_x < - 180
            rotation_x = -180;
        elseif rotation_x > 180
            rotation_x = 180;
        end
        compTrans_data(7,3) = num2cell(rotation_x);
        comp_localStruct.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(7,3)));
    case 8    % rotation y
        rotation_y = event.NewData;
        if rotation_y < - 180
            rotation_y = -180;
        elseif rotation_y > 180
            rotation_y = 180;
        end
        compTrans_data(8,3) = num2cell(rotation_y);
        comp_localStruct.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(8,3)));
    case 9    % rotation z
        rotation_z = event.NewData;
        if rotation_z < - 180
            rotation_z = -180;
        elseif rotation_z > 180
            rotation_z = 180;
        end
        compTrans_data(9,3) = num2cell(rotation_z);
        comp_localStruct.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(compTrans_data(9,3)));
end

% load adjusted data in the table
set(handles.(table_name), 'Data', compTrans_data);
comps_struct{list_index} = comp_localStruct;
%----------------------------------------------------
ah_ThisComp = findobj(gca,'-regexp','Tag',uID_name);
if ~isempty(ah_ThisComp)
    delete(ah_ThisComp)
end

sub_component_name{list_index} = [];
set(handles.(listbox_name), 'String', sub_component_name{list_index});
%-----------------------------------------------------

CompGeo = [];
switch comp_localStruct.type
    case 'fuselages'
        [CompGeo]=readfuselage_localStruct(CompGeo, comp_localStruct);
        Draw_Components(CompGeo);
    case 'wings'
        [CompGeo]=readwings_localStruct(CompGeo, comp_localStruct);
        Draw_Components(CompGeo);
        
        load_Wing_Subcomponents(CompGeo, comp_localStruct)
        
    case 'engines'
        Draw_Components(comp_localStruct)
end

end

function [] = TEDtable_selection(varargin)

global handles  subcomps_struct

event = varargin{2};
if numel(event.Indices)== 0     % avoid a bug after the close of the window
    return;
end

comps_string = get(handles.listbox, 'String');
comp_index = get(handles.listbox, 'Value');
uID_comp = comps_string{comp_index};
listbox_name = strcat('listbox_', uID_comp);

subcomps_string = get(handles.(listbox_name), 'String');
subcomp_index = get(handles.(listbox_name), 'Value');
uID_subcomp = subcomps_string{subcomp_index};

h = findobj('-regexp','Tag','component_', '-and', '-regexp','Tag',uID_subcomp);
table_name = get(h,'Tag');
TED_data = get(h, 'Data');

%------------------------------------------------
subcomp_localStruct = subcomps_struct{comp_index}{subcomp_index};
%------------------------------------------------

try
    numOfSteps = length(subcomp_localStruct.path{1,1}.steps{1,1}.step);
catch
    return
end

if event.Indices(1) == 13
    
    popup_string = {'default'};                                                % set the string for the popup-menu step
    for k=1: numOfSteps
        step_name = strcat('step_',num2str(k));
        popup_string = char(char(popup_string),step_name);
    end
    
    %--------to remember last step choice----------
    try TED_data(13,3);
        initV = find(strcmp(popup_string, TED_data(13,3))); 
    catch
        initV = 1; 
    end
    %----------------------------------------------
    [selection,ok] = listdlg('ListString',popup_string,...
        'InitialValue', initV, 'ListSize',[300,100],'PromptString',...
        'Choose the step','Name','Step',...
        'SelectionMode','Single','CancelString','Exit');
    
    if ok == 0
        return
    end
    
    local_symmetry = subcomp_localStruct.symmetry;
    TED_data(13,3) = cellstr(popup_string(selection,:));
    set(handles.(table_name), 'Data', TED_data);
    
    %---------------------------------------------------
    ah_ThisComp = findobj(gca,'-regexp', 'Tag', uID_subcomp);
    uID_sub_id = get(ah_ThisComp,  'Tag');
    
    if ~isempty(ah_ThisComp)
        delete(ah_ThisComp)
    end
    %----------------------------------------------------
    
    if selection == 1
        iTED_foils_basic = subcomp_localStruct.foils.Basic;
        [vertices_TED, triags_TED] = TEDfoil2triangles(iTED_foils_basic,  local_symmetry);
        Draw_SubComponents(vertices_TED, triags_TED, uID_sub_id, 'wing_TED')
        
    else
        iTED_foils_step = subcomp_localStruct.foils.Deflected.steps{1,selection-1}.airfoils;
        [vertices_TED, triags_TED] = TEDfoil2triangles(iTED_foils_step,  local_symmetry);
        Draw_SubComponents(vertices_TED, triags_TED, uID_sub_id, 'wing_TED')
        
    end
    
end
end

function [] = TEDtable_edit(varargin)
global handles  subcomps_struct  comps_struct

event = varargin{2};

if numel(event.Indices)== 0     % avoid a bug after the close of the window
    return;
end

% Step 1
comp_strings = get(handles.listbox, 'String');                               % get the component name
comp_index = get(handles.listbox, 'Value');                                 % get the component number
uID_comp = comp_strings{comp_index};
listbox_name = strcat('listbox_', uID_comp);
%------------------------------
comp_localStruct = comps_struct{comp_index};
%------------------------------

subcomps_string = get(handles.(listbox_name), 'String');
subcomp_index = get(handles.(listbox_name), 'Value');                % get the sub-component number
uID_subcomp = subcomps_string{subcomp_index};

h = findobj('-regexp','Tag','component_', '-and', '-regexp','Tag',uID_subcomp);
table_name = get(h,'Tag');
TED_data = get(h, 'Data');

%------------------------------------------%
subcomp_localStruct = subcomps_struct{comp_index}{subcomp_index};
tedNum = subcomp_localStruct.localCount;
compSegNum = subcomp_localStruct.compsegCount;
%------------------------------------------%

switch event.Indices(1)
    case {1,2}                   % inner etaLE
        inner_etaLE = event.NewData;
        if inner_etaLE < 0
            inner_etaLE = 0;
        elseif inner_etaLE > 1
            inner_etaLE = 1;
        end
        TED_data(1,3) = num2cell(inner_etaLE);
        subcomp_localStruct.outerShape{1,1}.innerBorder{1,1}.etaLE{1,1}.CONTENT = num2str(inner_etaLE);
        
        inner_etaTE = inner_etaLE;
        TED_data(2,3) = num2cell(inner_etaTE);
        subcomp_localStruct.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT = num2str(inner_etaTE);
        
        %  case 2                   % inner etaTE
        %         inner_etaTE = event.NewData;
        %         if inner_etaTE < 0
        %             inner_etaTE = 0;
        %         elseif inner_etaTE > 1
        %             inner_etaTE = 1;
        %         end
        %         TED_data(2,3) = num2cell(inner_etaTE);
        %         subcomp_localStruct.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT = num2str(inner_etaTE);
        
    case 3                   % inner xsiLE
        inner_xsiLE = event.NewData;
        if inner_xsiLE < 0
            inner_xsiLE = 0;
        elseif inner_xsiLE > 1
            inner_xsiLE = 1;
        end
        TED_data(3,3) = num2cell(inner_xsiLE);
        subcomp_localStruct.outerShape{1,1}.innerBorder{1,1}.xsiLE{1,1}.CONTENT = num2str(inner_xsiLE);
        
    case 4                  % inner relHeightLE
        inner_relZLE = event.NewData;
        if inner_relZLE < 0
            inner_relZLE = 0;
        elseif inner_relZLE > 1
            inner_relZLE = 1;
        end
        TED_data(4,3) = num2cell(inner_relZLE);
        subcomp_localStruct.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT = num2str(inner_relZLE);
        
    case 5                  % inner xsiUpperSkin
        inner_relChordUpperSkin = event.NewData;
        if inner_relChordUpperSkin < 0
            inner_relChordUpperSkin = 0;
        elseif inner_relChordUpperSkin > 1
            inner_relChordUpperSkin = 1;
        end
        TED_data(5,3) = num2cell(inner_relChordUpperSkin);
        subcomp_localStruct.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT = num2str(inner_relChordUpperSkin);
        
    case 6                   % inner xsiLowerSkin
        inner_relChordLowerSkin = event.NewData;
        if inner_relChordLowerSkin < 0
            inner_relChordLowerSkin = 0;
        elseif inner_relChordLowerSkin > 1
            inner_relChordLowerSkin = 1;
        end
        TED_data(6,3) = num2cell(inner_relChordLowerSkin);
        subcomp_localStruct.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT = num2str(inner_relChordLowerSkin);
        
    case {7,8}                 % outer etaLE
        outer_etaLE = event.NewData;
        if outer_etaLE < 0
            outer_etaLE = 0;
        elseif outer_etaLE > 1
            outer_etaLE = 1;
        end
        TED_data(7,3) = num2cell(outer_etaLE);
        subcomp_localStruct.outerShape{1,1}.outerBorder{1,1}.etaLE{1,1}.CONTENT = num2str(outer_etaLE);
        
        outer_etaTE = outer_etaLE;
        TED_data(8,3) = num2cell(outer_etaTE);
        subcomp_localStruct.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT = num2str(outer_etaTE);
        
        %     case 8                % outer etaTE
        %         outer_etaTE = event.NewData;
        %         if outer_etaTE < 0
        %             outer_etaTE = 0;
        %         elseif outer_etaTE > 1
        %             outer_etaTE = 1;
        %         end
        %         TED_data(8,3) = num2cell(outer_etaTE);
        %         subcomp_localStruct.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT = num2str(outer_etaTE);
        
    case 9              % outer xsiLE
        outer_xsiLE = event.NewData;
        if outer_xsiLE < 0
            outer_xsiLE = 0;
        elseif outer_xsiLE > 1
            outer_xsiLE = 1;
        end
        TED_data(9,3) = num2cell(outer_xsiLE);
        subcomp_localStruct.outerShape{1,1}.outerBorder{1,1}.xsiLE{1,1}.CONTENT = num2str(outer_xsiLE);
        
    case 10             % outer relHeightLE
        outer_relZLE = event.NewData;
        if outer_relZLE < 0
            outer_relZLE = 0;
        elseif outer_relZLE > 1
            outer_relZLE = 1;
        end
        TED_data(10,3) = num2cell(outer_relZLE);
        subcomp_localStruct.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT = num2str(outer_relZLE);
        
    case 11             % outer xsiUpperSkin
        outer_relChordUpperSkin = event.NewData;
        if outer_relChordUpperSkin < 0
            outer_relChordUpperSkin = 0;
        elseif outer_relChordUpperSkin > 1
            outer_relChordUpperSkin = 1;
        end
        TED_data(11,3) = num2cell(outer_relChordUpperSkin);
        subcomp_localStruct.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT = num2str(outer_relChordUpperSkin);
        
    case 12                % outer xsiLowerSkin
        outer_relChordLowerSkin = event.NewData;
        if outer_relChordLowerSkin < 0
            outer_relChordLowerSkin = 0;
        elseif outer_relChordLowerSkin > 1
            outer_relChordLowerSkin = 1;
        end
        TED_data(12,3) = num2cell(outer_relChordLowerSkin);
        subcomp_localStruct.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT = num2str(outer_relChordLowerSkin);
end

TED_data(13,3) = {'default'};
set(handles.(table_name), 'Data', TED_data);           % load adjusted data in the table
%-----------------------------------
ah_ThisComp = findobj(gca,'-regexp', 'Tag',uID_subcomp);
uID_sub_id = get(ah_ThisComp,  'Tag');

if ~isempty(ah_ThisComp)
    delete(ah_ThisComp)
end
%-----------------------------------

local_symmetry = subcomp_localStruct.symmetry;

[iTED_foils, iTED_geo] = matrix_controlSurf_4(subcomp_localStruct);
subcomp_localStruct.foils = iTED_foils;

[vertices_TED, triags_TED] = TEDfoil2triangles(iTED_foils.Basic,  local_symmetry);
Draw_SubComponents(vertices_TED, triags_TED, uID_sub_id, 'wing_TED')
%-----------------------------------------
subcomps_struct{comp_index}{subcomp_index}= subcomp_localStruct;
comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,tedNum} = subcomp_localStruct;
comps_struct{comp_index} = comp_localStruct;

end

function [] = selection_fuel_tanks(varargin)
global handles  subcomps_struct comps_struct

event = varargin{2};
if numel(event.Indices)== 0
    return;
end
%------------------------------
comps_string = get(handles.listbox, 'String');
comp_index = get(handles.listbox, 'Value');
uID_comp = comps_string{comp_index};
listbox_name = strcat('listbox_', uID_comp);

subcomps_string = get(handles.(listbox_name), 'String');
subcomp_index = get(handles.(listbox_name), 'Value');
uID_subcomp = subcomps_string{subcomp_index};

comp_localStruct = comps_struct{comp_index};
wingFT_struct = subcomps_struct{comp_index}{subcomp_index};
sparsRibs_geo = wingFT_struct.sparsRibs;
spars_list = sparsRibs_geo.spars.segments.uIDs;
ribs_list = sparsRibs_geo.ribsDefinitions.uIDs;
local_symmetry = wingFT_struct.symmetry;
FTNum = wingFT_struct.localCount;
compSegNum = wingFT_struct.compsegCount;
%----------------------------------------------

h = findobj('-regexp','Tag','component_', '-and', '-regexp','Tag',uID_subcomp);
table_name = get(h,'Tag');
fuel_tanks_data = get(h, 'Data');
%--------------------------------
switch char(fuel_tanks_data(event.Indices(1),1))
    case 'Border'
        
        if strcmp(char(fuel_tanks_data(event.Indices(1),2)), 'spar uID') == 1
            [selection,ok] = listdlg('ListString',spars_list,...
                'InitialValue', [],'ListSize',[300,100],'PromptString',...
                'Choose the spar','Name','spar',...
                'SelectionMode','Single','CancelString','Exit');
            if ok==0
                return     % close
            end
            for i=1:size(fuel_tanks_data,1)
                if strcmp(char(fuel_tanks_data(i,3)),spars_list{selection}) == 1
                    errordlg('this spar is already used as one border thus cannot be used!');
                    return
                end
            end
            
            fuel_tanks_data(event.Indices(1),3) = spars_list(selection);
            
            index_border = 0;            % find the index border
            for i=1:event.Indices(1)
                if strcmp(char(fuel_tanks_data(i,1)), 'Border') == 1
                    index_border = index_border + 1;
                end
            end
            wingFT_struct.geometry{1,1}.border{1,index_border}.sparUID{1,1}.CONTENT = char(fuel_tanks_data(event.Indices(1),3));
            
        elseif strcmp(char(fuel_tanks_data(event.Indices(1),2)), 'rib uID') == 1
            
            [selection,ok] = listdlg('ListString',ribs_list,...
                'InitialValue', [],'ListSize',[300,100],'PromptString',...
                'Choose the rib definition','Name','rib definition',...
                'SelectionMode','Single','CancelString','Exit');
            if ok==0
                return           % close
            end
            
            for i=1:size(fuel_tanks_data,1)
                if strcmp(char(fuel_tanks_data(i,3)),ribs_list{selection}) == 1
                    
                    index_rib = strcmp(ribs_list, ribs_list{selection});
                    max_number_rib = sparsRibs_geo.ribsDefinitions.numberOfRibs(index_rib);
                    
                    if max_number_rib == 1
                        errordlg('this rib is already used for one border');
                        return
                    end
                    
                end
            end
            
            fuel_tanks_data(event.Indices(1)+1,3) = cellstr('1');
            fuel_tanks_data(event.Indices(1),3) = ribs_list(selection);
            
            index_border = 0;           % find the index border
            for i=1:event.Indices(1)
                if strcmp(char(fuel_tanks_data(i,1)), 'Border') == 1
                    index_border = index_border + 1;
                end
            end
            
            wingFT_struct.geometry{1,1}.border{1,index_border}.ribDefinitionUID{1,1}.CONTENT = char(fuel_tanks_data(event.Indices(1),3));
            wingFT_struct.geometry{1,1}.border{1,index_border}.ribNumber{1,1}.CONTENT = char(fuel_tanks_data(event.Indices(1)+1,3));
            
        end
        
    case 'rib number'
        
        rib_definition_name = char(fuel_tanks_data(event.Indices(1)-1,3));
        index_rib = strcmp(ribs_list,  rib_definition_name);
        max_number_rib = sparsRibs_geo.ribsDefinitions.numberOfRibs(index_rib);
        
        number_string = '';
        for i=1:max_number_rib
            number_string = char(char(number_string), num2str(i));
        end
        number_string = number_string(2:end,:);
        
        [selection,ok] = listdlg('ListString',number_string,...
            'InitialValue', [],'ListSize',[300,100],'PromptString',...
            'Choose the rib number','Name','rib number',...
            'SelectionMode','Single','CancelString','Exit');
        
        if ok==0
            return                       % close
        end
        fuel_tanks_data(event.Indices(1),3) = cellstr(number_string(selection));
        
        index_border = 0;                % find the index border
        for i=1:event.Indices(1)
            if strcmp(char(fuel_tanks_data(i,1)), 'Border') == 1
                index_border = index_border + 1;
            end
        end
        wingFT_struct.geometry{1,1}.border{1,index_border}.ribNumber{1,1}.CONTENT = char(fuel_tanks_data(event.Indices(1),3));
end

set(handles.(table_name), 'Data', fuel_tanks_data);

%-------------------------------------------------
ah_ThisComp = findobj(gca,'-regexp', 'Tag', uID_comp,'-and','-regexp', 'Tag', uID_subcomp);
uID_sub_id = get(ah_ThisComp,  'Tag');
if ~isempty(ah_ThisComp)
    delete(ah_ThisComp)
end

[FT_rib_vertices, FT_faces] = fuel_tanks2(wingFT_struct,  local_symmetry);
Draw_SubComponents(FT_rib_vertices, FT_faces, uID_sub_id, 'wing_fuel_tanks')
%---------------------------------------------------
subcomps_struct{comp_index}{subcomp_index} = wingFT_struct;
comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum}.wingFuelTanks{1,1}.wingFuelTank{1,FTNum} = wingFT_struct;
comps_struct{comp_index} = comp_localStruct;

end

function [] = modify_engine(varargin)

global handles handles_engine  comps_struct  final_engine_struct

list_index = get(handles.listbox, 'Value');
engine_localStruct = comps_struct{list_index};

uID_name = engine_localStruct.ATTRIBUTE.uID;
% engine_UID = engine_localStruct.engineUID{1,1}.CONTENT;

size_engine_type = length(engine_localStruct.lib);

for i=1:size_engine_type                                     % find the engine corresponding to the engine UID
    UID = engine_localStruct.lib{1,i}.ATTRIBUTE.uID;
    if strcmp(uID_name, UID) == 1
        engine_type_number = i;
    end
end

engine_type_structure = engine_localStruct.lib{1,engine_type_number};

%------------------------------------------------------------
figure_engine(engine_type_structure);
uiwait(handles_engine.figure_engine)
%------------------------------------------------------------

if final_engine_struct.change > 0
    engine_localStruct.lib{1,engine_type_number} = final_engine_struct;
    
    %--------------------------------------------------
    ah_ThisComp = findobj(gca,'Tag',uID_name);
    if ~isempty(ah_ThisComp)
        delete(ah_ThisComp)
    end
    
    Draw_Components(engine_localStruct);
    comps_struct{list_index} = engine_localStruct;
end

end

function [] = modify_sections(varargin)

global handles  comps_struct  handles_section   final_struct  sub_component_name

list_string = get(handles.listbox, 'String');
list_index = get(handles.listbox, 'Value');
uID_name = list_string{list_index};

fusORwing_localStruct = comps_struct{list_index};   % element_structure

%------------------------------------------------------------------------

figure_section2(fusORwing_localStruct, fusORwing_localStruct.type );
uiwait(handles_section.figure_section)                % wait for the close of the window

if final_struct.change > 0
    
    new_struct = final_struct ;
    
    %--------------------------------------------------------
    ah_ThisComp = findobj(gca,'-regexp','Tag',uID_name);    % findobj(gca,'Tag',uID_name);
    if ~isempty(ah_ThisComp)
        delete(ah_ThisComp)
    end
    %-----------clear this component's listbox------------
    listbox_name = ['listbox_' uID_name]; 
    sub_component_name{list_index} = [];
    set(handles.(listbox_name), 'String', sub_component_name{list_index})
    %-----------------------------------------------------
    
    compGeo = [];   
    switch new_struct.type
        case 'fuselages'
            [compGeo]=readfuselage_localStruct(compGeo, new_struct);
            Draw_Components(compGeo);            
            
        case 'wings'
            [compGeo]=readwings_localStruct(compGeo, new_struct);
            Draw_Components(compGeo);                        
            load_Wing_Subcomponents(compGeo, new_struct)
    end
    comps_struct{list_index} = new_struct;
end
end

function [] = modify_spars_and_ribs(varargin)
global handles handles_sr  subcomps_struct  comps_struct  final_srStruct  sub_component_name

comps_string = get(handles.listbox, 'String');
comp_index = get(handles.listbox, 'Value');
uID_comp = comps_string{comp_index};
listbox_name = strcat('listbox_', uID_comp);

subcomps_string =  get(handles.(listbox_name), 'String');
subcomp_index = get(handles.(listbox_name), 'Value');
uID_subcomp = subcomps_string{subcomp_index};
%------------------------------------------%

for j_subcomp = 1:length(subcomps_struct{comp_index})
    if strcmp(subcomps_struct{comp_index}{j_subcomp}.type, 'wingFuelTanks')
        %------------------------------------------------------
        choice = questdlg('Modify spars and ribs will invalidate its attached fuel tanks?', ...
            'Attached Fuel Tanks?', ...
            'Continue','Cancel', 'Cancel');
        switch choice
            case 'Continue'
                disp('Continue to modify spars and ribs...')
            case 'Cancel'
                return
        end
        %--------------------------------------------------------
        break
    end
end

comp_localStruct = comps_struct{comp_index};
sparsRibs_localStruct = subcomps_struct{comp_index}{subcomp_index};
local_symmetry = sparsRibs_localStruct.symmetry;
compSegNum = sparsRibs_localStruct.compsegCount;

ah_ThisComp = findobj(gca,'-regexp', 'Tag', uID_comp,'-and','-regexp', 'Tag', uID_subcomp);     % here because "sparsRibs" is the only one uID_sub for all wings;
uID_sub_id_whole = get(ah_ThisComp,  'Tag');   % two: uID_comp_CS_sparsRibs_spars || uID_comp_CS_sparsRibs_ribs

%------------------------------------------%

figure_spars_and_ribs3(sparsRibs_localStruct);
uiwait(handles_sr.figure_spars_and_ribs)

%% If real changes happen to final_srStruct, the following have to be updated

if final_srStruct.change > 0
    [Spar_segments, rib_cell, Wings, sparsRibsgeo] = spars_ribs6(final_srStruct);
    [vertices_ribs, facets_ribs, vertices_spars, facets_spars] = sparRibs2triangles(Spar_segments, rib_cell, local_symmetry);
    
    %--------------------------------------------
    if ~isempty(ah_ThisComp)
        delete(ah_ThisComp)
    end
    %----------------------------------------------
    start_idx = strfind(uID_sub_id_whole,'sparsRibs');
    end_idx = start_idx{1}+8;
    uID_sub_id = uID_sub_id_whole{1}(1: end_idx);
    
    Draw_SubComponents(vertices_ribs, facets_ribs, uID_sub_id, 'ribs')
    Draw_SubComponents(vertices_spars, facets_spars, uID_sub_id, 'spars')
    
    %-------Update Wing Fuel Tanks due to change of Spars and Ribs-------
    %-------Wing_subcomp_listbox: remove fuelTanks
    %-------remove fuelTanks tables parameters-----------
    %-------wing_struct: fuelTanks part delete-----------
    
    subcomps_struct{comp_index}{subcomp_index} = final_srStruct;
    comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum}.structure{1,1}  = final_srStruct;
    
    if isfield(comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum}, 'wingFuelTanks')
        FTs_struct = comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum}.wingFuelTanks{1,1}.wingFuelTank;
        numFuelTank = length(FTs_struct);
        
        for FTNum = 1: numFuelTank
            wingFT_struct = FTs_struct{1,FTNum};
            uID_FT = wingFT_struct.ATTRIBUTE.uID;
            
            idx_FT = strcmp(sub_component_name{comp_index}, uID_FT);
            sub_component_name{comp_index}(idx_FT) = [];
            
            FT_tableTag = findobj(gca,'-regexp', 'Tag', uID_comp, '-and','-regexp', 'Tag', '_sparsRibs_', '-and','-regexp', 'Tag', uID_FT);
            delete(FT_tableTag)
        end
        
        comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum} = rmfield(comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum}, 'wingFuelTanks');
        
        u = 0; 
        for j_subcomp = 1:length(subcomps_struct{comp_index})
            if strcmp(subcomps_struct{comp_index}{j_subcomp}.type, 'wingFuelTanks')
                u = u+1;
                idx_FTstrut(u) = j_subcomp ;                 
            end            
        end
        subcomps_struct{comp_index}(idx_FTstrut) = []; 
        
    end
    
    set(handles.(listbox_name), 'String', sub_component_name{comp_index});
    comps_struct{comp_index} = comp_localStruct;
    
end
end

function [] = modify_steps(varargin)

global handles handles_steps  subcomps_struct  comps_struct  final_iTEDstruct

comps_string = get(handles.listbox, 'String');
comp_index = get(handles.listbox, 'Value');
uID_comp = comps_string{comp_index};
listbox_name = strcat('listbox_', uID_comp);

subcomps_string =  get(handles.(listbox_name), 'String');
subcomp_index = get(handles.(listbox_name), 'Value');
uID_subcomp = subcomps_string{subcomp_index};

h = findobj('-regexp','Tag','component_', '-and', '-regexp','Tag',uID_subcomp);
table_name = get(h,'Tag');
TED_data = get(h, 'Data');

%------------------------------------------%
comp_localStruct = comps_struct{comp_index};
iTED_localStruct = subcomps_struct{comp_index}{subcomp_index};
tedNum = iTED_localStruct.localCount;
compSegNum = iTED_localStruct.compsegCount;
local_symmetry = iTED_localStruct.symmetry;

ah_ThisComp = findobj(gca,'-regexp', 'Tag', uID_comp,'-and','-regexp', 'Tag', uID_subcomp);
uID_sub_id = get(ah_ThisComp,  'Tag');
%------------------------------------------%
try                                % if there's no steps info exist after the move; then there's no step that can be changed.
    numOfSteps = length(iTED_localStruct.path{1,1}.steps{1,1}.step);
catch
    return                                 % if no steps
end

figure_steps2(iTED_localStruct);
uiwait(handles_steps.figure_steps)

if  final_iTEDstruct.change > 0
    
    [iTED_foils, iTED_geo] = matrix_controlSurf_4(final_iTEDstruct);
    final_iTEDstruct.foils = iTED_foils;
    
    iTED_foils_basic = final_iTEDstruct.foils.Basic;
    [vertices_TED, triags_TED] = TEDfoil2triangles(iTED_foils_basic,  local_symmetry);
    
    %---------------------------------------------------
    if ~isempty(ah_ThisComp)
        delete(ah_ThisComp)
    end
    %----------------------------------------------------
    Draw_SubComponents(vertices_TED, triags_TED, uID_sub_id, 'wing_TED')
    
    TED_data(13,3) = {'default'};
    set(handles.(table_name), 'Data', TED_data);
    
    %------------------------------------------%
    subcomps_struct{comp_index}{subcomp_index} = final_iTEDstruct;
    %------------------------------------------%
    comp_localStruct.componentSegments{1,1}.componentSegment{1,compSegNum}.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,tedNum} = final_iTEDstruct;
    comps_struct{comp_index} = comp_localStruct;
end
end

%% Other assisting functions
function [] = tech_stickmodelR(varargin)
disp('menu tech bb')
cd('.\stickmodel')
GuessStick_Fun
end

function [] = tech_technology(varargin)

global handles TechGeoModel %CPACS_struct

%Part visibility
    h = get(gca,'Children');
    set(h,'visible','off');
    set(handles.axes3d_technology,'Visible','off');
% %Fuselage
%       set(handles.D150Fuselage1ID,'Visible','off');
% %Wing
%     set(handles.D150_wing_1ID,'Visible','off'); 
%     set(handles.component_D150_wing_1ID,'Visible','off'); 
%     % Wing TED
%     set(handles.D150_wing_1ID_D150_wing_CS_D150_InnerFlap,'Visible','off');
%     set(handles.D150_wing_1ID_D150_wing_CS_D150_OuterFlap,'Visible','off');

%Panel visibility
    %Hide Project Panel
    set(handles.Components,     'Visible','off');
    set(handles.Sub_Components, 'Visible','off');
    set(handles.Parameters,     'Visible','off');
    set(handles.Actions,        'Visible','off');
    set(handles.axes3d,         'Visible','off');
    try
        set(handles.A3204CM036,     'Visible','on','FaceColor',[.5 .5 .5],'FaceAlpha',0.5);
    end
    %Hide W&B panel 
    set(handles.WB_parameters,'Visible','off');
    %Technology Panel
    set(handles.Technology,     'Visible','on');
    set(handles.tech_parameters,'Visible','on');
    set(handles.tech_listbox,   'Visible','on');
    set(handles.tech_listbox,   'String',  {'Geometry (beam_model)',...
                                            'Geometry (aero_model)',...
                                            'Geometry (spar_location)',...
                                            'Material',...
                                            'Loading',...
                                            'Analysis',...
                                            'Experienced'});   
%Get CPACS struct
    [CPACS_struct] = assemble_compStructs; 
     CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT = 'tempModel';
    [CPACSgeo, CPACS_struct] = cpacsWrapper_CPACScreator(path, CPACS_struct); 
    CPACS_struct
%Generate Technology Geometry 
    TechMode=1;  %Generate whole model
    Technology_Fun(TechMode,CPACS_struct);   
%Goemetry Visibility Option
    %set(handles.Tech.Curve(TechGeoModel.iFus{1}.Geometry.splineID(2:end,1)),'Visible','off');
%Set Tech Graphical Object Hide until from menù User activate them
    %handles
    set(handles.Tech.SparLine,'Visible','off');
    set(handles.Tech.BeamLine,'Visible','off');
    set(handles.Tech.AeroMesh,'Visible','off');
%     handles
%     set(menu_weightBallnce,'Enable','on');
end

function set_ListboxVisibilities_Technology(varargin)
 % Funzione di visualizzazione beam (1) aero (2) spar (3)
 
 
global  handles TechGeoModel
    set(handles.Tech.Surf(:),'EdgeColor'  ,'none','FaceAlpha'  ,0.2,'FaceColor'  ,[.5 .5 .5]);
    val=get(handles.tech_listbox,'value');
    if val ==1
        disp('beam model') % Aggiunto
        set(handles.Tech.BeamLine,'Visible','on');
        set(handles.Tech.AeroMesh,'Visible','off');
        set(handles.Tech.SparLine,'Visible','off');
        set(handles.tech_parameters_table,'Visible'    ,'on',...
                                          'Data'       ,TechGeoModel.beam_data);%,...
                                          %'ColumnWidth','auto');
        set(handles.tech_parameters_table,'ColumnWidth',{200,80 80});                              
    elseif val == 2
        disp('aero model') % Aggiunto
        set(handles.Tech.BeamLine,'Visible','off');
        set(handles.Tech.AeroMesh,'Visible','on'); 
        set(handles.Tech.SparLine,'Visible','off');
        set(handles.tech_parameters_table,'Visible'    ,'on',...
                                          'Data'       ,TechGeoModel.aeroPanel_data);%,...
                                          %'ColumnWidth','auto');
        set(handles.tech_parameters_table,'ColumnWidth',{200,80 80});                             
    elseif val == 3
        disp('spar location') % Aggiunto
        set(handles.Tech.BeamLine,'Visible','off');
        set(handles.Tech.AeroMesh,'Visible','off'); 
        set(handles.Tech.SparLine,'Visible','on');
        
    % *********************** Aggiunto **************************** 
    elseif val == 4 || val == 5 || val == 6 || val == 7
        disp(val) % Aggiunto
        set(handles.Tech.BeamLine,'Visible','off');
        set(handles.Tech.AeroMesh,'Visible','off'); 
        set(handles.Tech.SparLine,'Visible','off');    
     % *************************************************************   
    end
end

function techParameter_edit(varargin)

global  handles TechGeoModel %CPACS_struct
    eventdata=varargin{2};    
    val=get(handles.tech_listbox,'value');    
    if val==1
        string=TechGeoModel.beam_data{eventdata.Indices(1,1),1};
        
        %TechGeoModel.beam_data{eventdata.Indices(1,1),:} % Selezione Riga
        %+ campo
        %pippo = 'abcdefghilmnopqrstuvz'
        %pippo(5)
        
        %Modify Fuselage beam model 
        if strcmp(string(1:6),'n fuse')    
            TechMode=11; % modalità fusoliera
            FusID=str2num(string( 7));
            Technology_Fun(TechMode,FusID ,[]     ,eventdata.NewData);
        %Modify Wing Beam model
        elseif strcmp(string(1:6),'n wing')
            TechMode=21; % modalità wing
            WingID=str2num(string( 7));
            BoardID=str2num(string(14));
            Technology_Fun(TechMode,WingID,BoardID,eventdata.NewData);
        end
    elseif val==2
        string=TechGeoModel.aeroPanel_data{eventdata.Indices(1,1),1};       
        TechMode=22;
        WingID=str2num(string( 5));
        BoardID=str2num(string(12));
        if strcmp(string(14:15),'ny')
            ni=1;
        elseif strcmp(string(14:15),'nx') && strcmp(string(14:18),'nxTED')==0
            ni=2;
        elseif strcmp(string(14:18),'nxTED')
            ni=3;
        end
        Technology_Fun(TechMode,WingID,BoardID,ni,eventdata.NewData); 
    end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function []=WB_WeightAndBallance_Cog(varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MODIFICATIONS:
    %     DATE        VERS    PROGRAMMER       DESCRIPTION
    %     10.10.13     1.4    F.Dinardo        Creation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global handles TechGeoModel 
    
    %Project Panel
    set(handles.Components,     'Visible','off');
    set(handles.Sub_Components, 'Visible','off');
    set(handles.Parameters,     'Visible','off');
    set(handles.Actions,        'Visible','off');
    set(handles.axes3d,         'Visible','off'); 
    %Technology Panel
    set(handles.Technology,     'Visible','off');
    set(handles.tech_parameters,'Visible','off');
    set(handles.tech_listbox,   'Visible','off');
     
    h = get(gca,'Children');
    set(h,'visible','off');
    set(handles.axes3d_technology,'Visible','off');
    
    try
        set(handles.A3204CM036,     'Visible','on','FaceColor',[.5 .5 .5],'FaceAlpha',0.5);
    end
        
    [CPACS_struct] = assemble_compStructs;
    
    msgbox('Running W&B you are creating a TechGeoModel workSpace and converting CPACS into NEOCASS format')    
    uiwait(gcf); 
    
    TechMode=1;  %Generate whole model
    Technology_Fun(TechMode,CPACS_struct); 
    
    set(handles.Tech.Curve(TechGeoModel.iFus{1}.Geometry.splineID(2:end,1)),'Visible','off');
    
    set(handles.Tech.SparLine,'Visible','off');
    set(handles.Tech.BeamLine,'Visible','off');
    set(handles.Tech.AeroMesh,'Visible','off');
 
%    Tech2Neocass               %conversion function
    Tech2Neocass2(CPACS_struct) %conversion function

    set(handles.WB_parameters,'Visible','on');
    set(handles.WB_parameters_table,'Visible'    ,'on',...
                                      'Data'       ,TechGeoModel.COGdata);
    set(handles.WB_parameters_table,'ColumnWidth',{'auto','auto','auto','auto','auto'}); 

    path_settings
end
function [] = view_reset(varargin)
global handles
view(handles.axes3d, 3)
end

function [] = view_side(varargin)
global handles
view(handles.axes3d,[0 0]);
end

function [] = view_front(varargin)
global handles
view(handles.axes3d,[270.0 0.0]); % 270
end

function [] = view_top(varargin)
global handles
view(handles.axes3d,[0.0 90.0]);
end

function [] = axes_color(varargin)
global handles
color = uisetcolor('Pick a color');
if length(color) ~= 3
    color = get(0,'defaultUicontrolBackgroundColor');
end
set(handles.panel_for_axes,'BackgroundColor',color);
end

function [] = axes_localcolor(varargin)

color = uisetcolor('Pick a color');
if length(color) ~= 3
    color = get(0,'defaultUicontrolBackgroundColor');
end
set(gco,'FaceColor',color);
end

function [] = axes_localAlpha(varargin)

objSelected = gco;

figure_slider = dialog('WindowStyle', 'normal', 'Name', 'Change Transparency',...
    'units','normalized','Position', [0.4 0.7 0.2 0.1]);

slider1 = uicontrol('Parent',figure_slider,'Style', 'slider',...
    'units','normalized','Position', [0.1 0.5 0.8 0.3],...
    'Min',0,'Max',1,'Value',0.7,...
    'tag','transparencyslider','Callback',{@axes_localSetAlpha,objSelected});    % ,...

figure_slider_ok = uicontrol('parent', figure_slider,'style','push',...
    'units','normalized', 'position',[0.7 0.1 0.2 0.3],...
    'tag','alpha_ok',...
    'string','OK','Callback',@axes_alpha_ok);
end

function [] = axes_localSetAlpha(varargin)
objSelected = varargin{3};
selected_transp = get(varargin{1},'Value');
set(objSelected,'FaceAlpha',selected_transp);
end

function [] = axes_alpha_ok(varargin)
close(gcf)
end

function [] = axes_lighting_mode(varargin)
% % 'FaceLighting', 'phong',
% light('Position',[10 10 5]);
% %light('Position',[-3 -1 3]);
% %camlight(45,45);
% material shiny;
% % alpha('color');
% % alphamap('rampdown');
% %lighting phong
%
% camlight;

end

function [] = load_CPACS(varargin)
global handles  component_name   comps_struct

string = char('Want to load a new CPACS model?', 'The current project will not be saved');
choice = questdlg(string,'Load CPACS file','Yes','No','No');

switch choice
    case 'Yes'
        %-----------Clear GUI panels------------
        try
            cla(handles.axes3d)
        catch
        end
        
        delete(findobj(gcf,'-regexp','Tag','component_','-or','Tag','listbox_'))        % delete all the tables relatives to components and sub-components
        component_name = [];
        comps_struct = [];
        set(handles.listbox, 'String', component_name);
        
        %-----------load CPACS------------
        
        disp('Reading .xml into matlab structure, please wait 40 seconds roughly...')
        [CPACS_XML] = loadCpacsFile;
        [CPACSgeo, CPACS_XML] = cpacsWrapper_CPACScreator(path,CPACS_XML);
        
        load_structure(CPACSgeo,CPACS_XML)
        
    case 'No'
        return
end

end

function [] = saveto_CPACS(varargin)

[CPACS_struct] = assemble_compStructs;

home = pwd;
cd(['..' filesep 'Projects'])

[FileName, PathName] = uiputfile('*.xml','Export XML');
outFile = strcat(PathName, FileName);

CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT = FileName;
new_struct.cpacs{1,1} = CPACS_struct;

struct2xml(new_struct, outFile)
cd(home)
end

function [] = import_sumo(varargin)
global handles  component_name   comps_struct

string = char('Want to load a new Sumo model?', 'The current project will not be saved');
choice = questdlg(string,'Load Sumo model','Yes','No','No');

switch choice
    case 'Yes'
        %-----------Clear GUI panels------------
        try
            cla(handles.axes3d)
        catch
        end
        
        delete(findobj(gcf,'-regexp','Tag','component_','-or','Tag','listbox_'))        % delete all the tables relatives to components and sub-components
        component_name = [];
        comps_struct = [];
        set(handles.listbox, 'String', component_name);
        
        %-----------load CPACS------------
        homedir = pwd;
        cd(['..' filesep 'Interfaces' filesep 'Sumo2CPACS']);
        
        disp('Reading .smx into CPACS matlab structure, please wait...')
        [cpacs_struct] = sumo2cpacs;
        
        cd(homedir);
        
        [CPACSgeo, CPACS_XML] = cpacsWrapper_CPACScreator(path,cpacs_struct);
        
        load_structure(CPACSgeo,CPACS_XML)
        
        
    case 'No'
        return
end


end

function [] = saveto_sumo(varargin)

[CPACS_struct] = assemble_compStructs; 

CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT = 'tempModel';

[CPACSgeo, CPACS_struct] = cpacsWrapper_CPACScreator(path, CPACS_struct);

%% ------ From CPACS_struct to Sumo struct, then to Sumo XML-----
%-------Copied & reshuffled a bit from mainSumo Batch----
homedir = pwd;
disp('Generating .smx file...')
addpath(['..' filesep 'Interfaces' filesep 'CPACS2Sumo']);
addpath(['..' filesep 'Interfaces' filesep 'CPACS2Sumo' filesep 'lib']);

cd(['..' filesep 'Projects'])
[FileName, PathName] = uiputfile('*.smx','Export *.smx for Sumo');
if isempty(FileName)
    return
end

%----------------------------------------------
option.sumo.auto=0;
option.outType='';
% option.tetgenSettins='pq1.400Ya160.000';

option.sumo.wingMeshDefault='true';
% option.sumo.exeDir='E:\AcBuilder_Matlab_clean\sumo-2.5.2\bin32';
option.sumo.viewOutput=1;

NewS={};
for i=1:size(CPACSgeo.wings.component,1)
    wingNum=i;
    [NewS] = inclWing3(NewS,wingNum,CPACSgeo,option);
end

%{
% % Incude ContSurf(s)
% for i= 1:number_of_wings
%     
%     wing_struct = acb_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing{1,i};
%     wing_geo = CPACSgeo.wings.component{i,1};
%     compSeg_struct = wing_struct.componentSegments{1,1}.componentSegment{1,compSegNum};
%     try
%         numOfTED = length(compSeg_struct.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice);
%     catch
%         numOfTED = 0;
%         disp('No Trailing Edge Devices for this Wing')
%     end
%   %  for tedNum=1:numOfTED
%         
%         iTED_struct = compSeg_struct.controlSurfaces{1,1}.trailingEdgeDevices{1,1}.trailingEdgeDevice{1,tedNum};
%         [iTED_geo] = iTEDstruct2geo(iTED_struct);


for i=1:size(CPACSgeo.wings.component,1)
    if isfield(CPACSgeo.wings.component{i,1},'controlSurfaces')
        wingNum=i;
        
        wing_localStruct = wing_structs{wingNum}; 
        
        
        [NewS] = inclContSurf(NewS,CPACSgeo,wingNum);
        disp('Add Control')
    end
end
%}

% Incude Fuselage
for i = 1:size(CPACSgeo.fuselages.component,1)
% if isfield(CPACSgeo,'fuselages')
    fusNum = i; 
    [NewS] = inclFus(NewS,fusNum, CPACSgeo);
    disp('Add Fuselage')
% end
end
%% Include Engines

% if isfield(aircraft,'engine')
%     [NewS] = inclEngine(NewS,aircraft,wingNum);
%     disp('Add Engine')
% end

%% Write .xms (input fiele for sumo)

struct2smx(NewS,FileName)
disp('write .xms...')
pause(3)

cd(homedir);

end

function [CPACS_struct] = assemble_compStructs(varargin)
global comps_struct  component_name

%--------------Copy assitant info from CPACS_20_D150.xml--------------
load('../Projects/CPACS_20_D150.mat')       % to use the skeleton;
CPACS_struct = struct('header',{{'abc'}},'vehicles',{{'abc'}},'missions',1,'fleets',1,'airports',1,'ATTRIBUTE',1);

CPACS_struct.header = CPACS_XML.header;
% CPACS_struct.missions = acb_struct.missions;
% CPACS_struct.fleets = acb_struct.fleets;
% CPACS_struct.airports = acb_struct.airports;
CPACS_struct.ATTRIBUTE = CPACS_XML.ATTRIBUTE;

%------Assembly the components back / Inverse to load_structure---------

num_Fus = 0;
num_Wing = 0;
num_Engine = 0;


for  comp_index = 1: length(component_name)
    
    comp_localStruct = comps_struct{comp_index};
    
    switch comp_localStruct.type
        case 'fuselages'
            num_Fus = num_Fus + 1;
            
            fus_profiles = comp_localStruct.profiles;
            CPACS_struct.vehicles{1,1}.profiles{1,1}.fuselageProfiles{1,1}.fuselageProfile = fus_profiles;
            
            comp_localStruct = rmfield(comp_localStruct, 'type');
            comp_localStruct = rmfield(comp_localStruct, 'profiles');
            
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage{1,num_Fus} = comp_localStruct;
            
        case 'wings'
            num_Wing = num_Wing + 1;
            
            wing_profiles = comp_localStruct.profiles;
            CPACS_struct.vehicles{1,1}.profiles{1,1}.wingAirfoils{1,1}.wingAirfoil = wing_profiles;
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference = comp_localStruct.reference;
            
            comp_localStruct = rmfield(comp_localStruct, 'type');
            comp_localStruct = rmfield(comp_localStruct, 'profiles');
            
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing{1,num_Wing} = comp_localStruct;
            
        case 'engines'
            num_Engine = num_Engine + 1;
            
            CPACS_struct.vehicles{1,1}.engines{1,1}.engine = comp_localStruct.lib;
            
            comp_localStruct = rmfield(comp_localStruct, 'type');
            comp_localStruct = rmfield(comp_localStruct, 'symmetry');
            comp_localStruct = rmfield(comp_localStruct, 'lib');
            comp_localStruct = rmfield(comp_localStruct, 'uID');
            
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine{1,num_Engine}  = comp_localStruct;
    end
    
end

end

function [] = ceasiom_AMB(varargin)
% global cpacs

[CPACS_struct] = assemble_compStructs;
CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT = 'tempModel';
[CPACSgeo, CPACS_struct] = cpacsWrapper_CPACScreator(path, CPACS_struct);

%------********------Pick the parameters needed for AMB------*******-------

numWings = length(CPACSgeo.wings.component);
compArea = zeros(numWings,1);
compSpan = zeros(numWings,1); 

for i = 1: numWings
   compArea(i) = CPACSgeo.wings.component{i}.compArea; 
   compSpan(i) = CPACSgeo.wings.component{i}.compSpan; 
end

cpacsAMB.ref.wingRefArea = sum(compArea);
cpacsAMB.ref.wingRefSpan = max(compSpan); 
cpacsAMB.ref.bodyLength = CPACSgeo.fuselages.component{1,1}.length; 

%-----***********-----Dummy COGs-----************------
cpacsAMB.ref.COGX = cpacsAMB.ref.bodyLength/2;
cpacsAMB.ref.COGY = 0;
cpacsAMB.ref.COGZ = 0; 
cpacsAMB.ref.MAC14 = 10;                     % 1/4 MAC from Nose
cpacsAMB.ref.mTOM =  735000;                        % CPACSgeo.weight.mTOM; 
cpacsAMB.ref.Ixx = 10;
cpacsAMB.ref.Iyy = 10; 
cpacsAMB.ref.Izz = 10;
cpacsAMB.ref.Ixz = 10;
cpacsAMB.ref.Ixy = 10;
cpacsAMB.ref.Iyz = 10;
cpacsAMB.AMBdataPresent = 1; 

cpacsAMB.CPACSgeo = CPACSgeo;
cpacsAMB.CPACS_XML = CPACS_struct; 
%--------------------State Data-----------------
% cpacsAMB.AMB.state.alphamin=-5; cpacsAMB.AMB.state.alphamax=15; cpacsAMB.AMB.state.Nalpha=2;       
% cpacsAMB.AMB.state.betamin=-6; cpacsAMB.AMB.state.betamax=6; cpacsAMB.AMB.state.Nbeta=2;  
% cpacsAMB.AMB.state.machmin=0.1; cpacsAMB.AMB.state.machmax=0.6; cpacsAMB.AMB.state.Nmach=2;  
% cpacsAMB.AMB.state.elemin=-10; cpacsAMB.AMB.state.elemax=15; cpacsAMB.AMB.state.Nele=2;  
% cpacsAMB.AMB.state.ailmin=-10; cpacsAMB.AMB.state.ailmax=15; cpacsAMB.AMB.state.Nail=2;  
% cpacsAMB.AMB.state.rudmin=-10; cpacsAMB.AMB.state.rudmax=15; cpacsAMB.AMB.state.Nrud=2;  
% cpacsAMB.AMB.state.qmin=-40; cpacsAMB.AMB.state.qmax=40; cpacsAMB.AMB.state.Nq=2;  
% cpacsAMB.AMB.state.pmin=-40; cpacsAMB.AMB.state.pmax=40; cpacsAMB.AMB.state.Np=2;  
% cpacsAMB.AMB.state.rmin=-40; cpacsAMB.AMB.state.rmax=40; cpacsAMB.AMB.state.Nr=2; 
%---------------------------------------------------
cd('..\Aerodynamics\AMB')
ceasiom_AMB2(cpacsAMB)
cd('..\..\Geometry')
end

function [] = import_mat(varargin)
global handles  component_name   comps_struct

string = char('Want to load a previous saved Matlab structure model?', 'The current project will not be saved');
choice = questdlg(string,'Load Matlab Structure model','Yes','No','No');

switch choice
    case 'Yes'
        %-----------Clear GUI panels------------
        try
            cla(handles.axes3d)
        catch
        end
        
        delete(findobj(gcf,'-regexp','Tag','component_','-or','Tag','listbox_'))        % delete all the tables relatives to components and sub-components
        component_name = [];
        comps_struct = [];
        set(handles.listbox, 'String', component_name);
        
        %-----------load CPACS------------
        string2 = char('Please make sure that the imported matlab filename is the same as the variable name');
        choice2 = questdlg(string2,'Load Matlab Structure model','Yes','No','Yes');
        if strcmp(choice2, 'No')
            return
        end
        
        homedir = pwd;
        cd(['..' filesep 'Projects'])
        [FileName, PathName] = uigetfile('*.mat','Import Matlab structure model');
        
        if FileName==0
            return
        end
        [~, name, ~] = fileparts(FileName);
        eval(['load ' name '.mat']);
        eval(['CPACS_XML = ' name ';']);
        cd(homedir);
        
        %------------------------------------
        [CPACSgeo, CPACS_XML] = cpacsWrapper_CPACScreator(path,CPACS_XML);
        
        load_structure(CPACSgeo,CPACS_XML)
        
    case 'No'
        return
end


end

function [] = saveto_mat(varargin)
%--------------Assemble the model in one matlab structure------------
global comps_struct  component_name

%--------------Copy assitant info from CPACS_20_D150.xml--------------
load('../Projects/CPACS_20_D150.mat')       % to use the skeleton;
CPACS_struct = struct('header',{{'abc'}},'vehicles',{{'abc'}},'missions',1,'fleets',1,'airports',1,'ATTRIBUTE',1);

CPACS_struct.header = acb_struct.header;
% CPACS_struct.missions = acb_struct.missions;
% CPACS_struct.fleets = acb_struct.fleets;
% CPACS_struct.airports = acb_struct.airports;
CPACS_struct.ATTRIBUTE = acb_struct.ATTRIBUTE;

%------Assembly the components back / Inverse to load_structure---------

num_Fus = 0;
num_Wing = 0;
num_Engine = 0;


for  comp_index = 1: length(component_name)
    
    comp_localStruct = comps_struct{comp_index};
    
    switch comp_localStruct.type
        case 'fuselages'
            num_Fus = num_Fus + 1;
            
            fus_profiles = comp_localStruct.profiles;
            CPACS_struct.vehicles{1,1}.profiles{1,1}.fuselageProfiles{1,1}.fuselageProfile = fus_profiles;
            
            comp_localStruct = rmfield(comp_localStruct, 'type');
            comp_localStruct = rmfield(comp_localStruct, 'profiles');
            
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.fuselages{1,1}.fuselage{1,num_Fus} = comp_localStruct;
            
        case 'wings'
            num_Wing = num_Wing + 1;
            
            wing_profiles = comp_localStruct.profiles;
            CPACS_struct.vehicles{1,1}.profiles{1,1}.wingAirfoils{1,1}.wingAirfoil = wing_profiles;
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference = comp_localStruct.reference;
            
            comp_localStruct = rmfield(comp_localStruct, 'type');
            comp_localStruct = rmfield(comp_localStruct, 'profiles');
            
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.wings{1,1}.wing{1,num_Wing} = comp_localStruct;
            
        case 'engines'
            num_Engine = num_Engine + 1;
            
            CPACS_struct.vehicles{1,1}.engines{1,1}.engine = comp_localStruct.lib;
            
            comp_localStruct = rmfield(comp_localStruct, 'type');
            comp_localStruct = rmfield(comp_localStruct, 'symmetry');
            comp_localStruct = rmfield(comp_localStruct, 'lib');
            comp_localStruct = rmfield(comp_localStruct, 'uID');
            
            CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine{1,num_Engine}  = comp_localStruct;
    end
    
end

CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT = 'tempname';

%----------------------------------------

save('../Projects/CPACS_struct.mat','CPACS_struct');

end