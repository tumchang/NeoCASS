function figure_section2(initial_comp_struct, component_type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Modify, remove or add new sections for fuselages and wings components %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Pierre Saquet           ty                            %
% LastModified:     2013-01-28                                            %
% LastModifiedBy:   Pengfei Meng                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear global element_struct
clear global stage_element_struct
clear global section_number

global stage_element_struct   element_struct   final_struct
global historic_section_string  section_number
global handles_section

initial_comp_struct.change = 0; 
element_struct = initial_comp_struct;          % used to visualize every potential modification during the process
stage_element_struct = initial_comp_struct;    % used as the final structure to hold the real modifications made each step
final_struct = initial_comp_struct;            % final_struct is the regional global variable shared with the main function 
                                               % only when the Save All Actions button was clicked, will final_struct

section_number = 1;                            % default value, from the first section!
historic_section_string = strcat('Initial number of sections:', num2str(length(element_struct.sections{1,1}.section)));  % Record all the modifications made

%% Figure
%====*****====****====****====****====****====****====****====****====****====****====
%== Set Initial Panels on the Figure, and define the callbacks

figure_section.fh = figure('units','normalized',...
    'position',[0.1 0.2 0.6 0.7],...
    'menubar','none',...
    'Color',[.2 .2 .3],...
    'numbertitle','off',...
    'name','Modify sections',...
    'renderer', 'OpenGL',...
    'Tag','figure_section',...
    'resize','on');      %   'WindowStyle', 'modal',...

figure_section.colpb = [0.9255, 0.9137, 0.8471]; % Default Color of buttons

%% Panels
% Panel Drawing
figure_section.up(1)= uipanel('Parent',figure_section.fh ,'Title','',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.0 0.7 0.8],...
    'backgroundcolor', [1.0 1.0 1.0],...
    'tag','Drawing');

% Panel section
figure_section.up(2)= uipanel('Parent',figure_section.fh ,'Title','Section',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.7 0.6 0.3 0.32],...
    'tag','section');

% Panel element
figure_section.up(3)= uipanel('Parent',figure_section.fh ,'Title','Element',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.7 0.2 0.3 0.4],...
    'tag','element');

% Panel button
figure_section.up(4)= uipanel('Parent',figure_section.fh ,'Title','',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.7 0.0 0.3 0.2],...
    'tag','button');

% Panel Section modification
figure_section.up(5)= uipanel('Parent',figure_section.fh ,'Title','Modify sections',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.8 0.7 0.1],...
    'tag','Section_modification');

% Panel Drawing 2
figure_section.up(6)= uipanel('Parent',figure_section.fh ,'Title','',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.0 0.7 0.8],...
    'backgroundcolor', [1.0 1.0 1.0],...
    'Visible','off',...
    'tag','Drawing2');

% Panel View
figure_section.up(7)= uipanel('Parent',figure_section.fh ,'Title','View',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.7 0.92 0.3 0.08],...
    'tag','View');

% Panel Modes
figure_section.up(8)= uipanel('Parent',figure_section.fh ,'Title','Modes',...
    'units','normalized',...
    'BorderWidth', 2.0, ...
    'position',[0.0 0.9 0.7 0.1],...
    'tag','modes');

%% panel Drawing
% axes 1
figure_section.axes(1) = axes('Parent', figure_section.up(1),...
    'units','normalized',...
    'Visible', 'off',...
    'OuterPosition',[0.0 0.0 1.0 1.0],...
    'tag', 'axes_1');

%% pamel Drawing 2
% axes 2
figure_section.axes(2) = axes('Parent', figure_section.up(6),...
    'units','normalized',...
    'Visible', 'off',...
    'OuterPosition',[0.0 0.0 1.0 1.0],...
    'tag', 'axes_2');

%% uicontrol panel View
% Checkbox All sections
figure_section.cb(1) = uicontrol('style','checkbox',...
    'parent', figure_section.up(7),...
    'units','normalized',...
    'position',[0.0 0.0 0.4 1.0],...
    'tag','all_sections',...
    'Value',1,...
    'string','All sections','callback',{@View_all_sections});

% Checkbox Selected section
figure_section.cb(2) = uicontrol('style','checkbox',...
    'parent', figure_section.up(7),...
    'units','normalized',...
    'position',[0.4 0.0 0.6 1.0],...
    'tag','selected_section',...
    'Value',0,...
    'string','Selected section','callback',{@View_selected_section});

%% uicontrol panel Modes
% Checkbox Modify sections
figure_section.cb(3) = uicontrol('style','checkbox',...
    'parent', figure_section.up(8),...
    'units','normalized',...
    'position',[0.1 0.0 0.2 1.0],...
    'tag','cb_modify_sections',...
    'Value',1,...
    'string','Modify sections','callback',{@Mode_modify_sections, component_type});

% Checkbox Add sections
figure_section.cb(4) = uicontrol('style','checkbox',...
    'parent', figure_section.up(8),...
    'units','normalized',...
    'position',[0.4 0.0 0.2 1.0],...
    'tag','cb_add_sections',...
    'Value',0,...
    'string','Add sections','callback',{@Mode_add_sections, component_type});

% Checkbox Remove sections
figure_section.cb(5) = uicontrol('style','checkbox',...
    'parent', figure_section.up(8),...
    'units','normalized',...
    'position',[0.7 0.0 0.2 1.0],...
    'tag','cb_remove_sections',...
    'Value',0,...
    'string','Remove sections','callback',{@Mode_remove_sections, component_type});


%% ------------- %% ------------ %% --------------- %% 
% Data for section 1, initial default section chosen

%-----------------------------------------------------------%
% section id, from 1 -> number of sections, under select a section droplist
popupmenu_string = num2cell([1: length(element_struct.sections{1,1}.section)]');

% Popupmenu_string when modidy or remove sections
figure_section.label(1) = uicontrol('Style', 'text',...            % label
    'Parent', figure_section.up(5),...
    'units','normalized',...
    'Position',[0.0 0.3 0.18 0.4],...
    'Tag','label',...
    'String', 'select a section');

figure_section.popupmenu(1) = uicontrol('Style', 'popupmenu',...   % Pop-up menu Select a section
    'Parent', figure_section.up(5),...
    'units','normalized',...
    'Position',[0.18 0.3 0.12 0.4],...
    'tag', 'select_a_section',...
    'backg',figure_section.colpb,...
    'String', popupmenu_string,...
    'Value', 1,...
    'callback', {@select_a_section, component_type});

%----------------------------------------------------------------------
% Popupmenu_string when add sections
popupmenu_string ='';      % Between sections
for i=0:length(element_struct.sections{1,1}.section)
    if i == 0
        popupmenu_string = char(popupmenu_string, 'first');
    elseif i == length(element_struct.sections{1,1}.section)
        popupmenu_string = char(popupmenu_string, 'last');
    else
        popupmenu_string = char(popupmenu_string, strcat(num2str(i),'-', num2str(i+1)));
    end
end
popupmenu_string = popupmenu_string(2:end,:);

figure_section.popupmenu(2) = uicontrol('Style', 'popupmenu',...           % Pop-up menu Between sections
    'Parent', figure_section.up(5),...
    'units','normalized',...
    'Position',[0.18 0.3 0.12 0.4],...
    'tag', 'between_sections',...
    'backg',figure_section.colpb,...
    'String', popupmenu_string,...
    'Value', 1,...
    'Visible','off',...
    'callback', {@between_sections, component_type});
%----------------------------------------------------------------------
% Choose a profile popupmenu
switch component_type
    case 'fuselages'        
        profile_UID = element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT;
    case 'wings'           
        profile_UID = element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT;
end

list_profiles = element_struct.profiles;      % the structure containing all the fuselage/wing profiles

% the list of all the available profile names in this fuselage/wing profile structure;
profile_name = '';
for i=1:length(list_profiles)
    profile_name = char(profile_name, list_profiles{1,i}.ATTRIBUTE.uID);
    if strcmp(list_profiles{1,i}.ATTRIBUTE.uID, profile_UID) == 1
        profile_number = i;                    % profile number -- the ith cooresponds to section number's UID
    end
end
profile_name = profile_name(2:end,:);

%-------------------%%%------------------%
figure_section.label(2) = uicontrol('Style', 'text',...
    'Parent', figure_section.up(5),...
    'units','normalized',...
    'Position',[0.32 0.3 0.18 0.4],...
    'Tag','label_profile',...
    'String', 'choose a profile');

% Pop-up menu Choose a profile
figure_section.popupmenu(3) = uicontrol('Style', 'popupmenu',...
    'Parent', figure_section.up(5),...
    'units','normalized',...
    'Position',[0.5 0.3 0.2 0.4],...
    'tag', 'choose_a_profile',...
    'backg',figure_section.colpb,...
    'String', profile_name,...
    'Value', profile_number,...                     % initial profile corresponding to the ith section
    'callback', {@choose_a_profile, component_type, section_number});
%--------------------------------------------------------------------------
% Push button Confirm Modify section
figure_section.pb(3) = uicontrol('style','push',...
    'parent', figure_section.up(5),...
    'units','normalized',...
    'position',[0.72 0.2 0.26 0.6],...
    'backg',figure_section.colpb,...
    'tag','Modify_section',...
    'string','Confirm Modify This Section','callback',{@Confirm_Modify_section, section_number});

% Push button Confirm Remove section
figure_section.pb(4) = uicontrol('style','push',...
    'parent', figure_section.up(5),...
    'units','normalized',...
    'position',[0.72 0.2 0.26 0.6],...
    'backg',figure_section.colpb,...
    'tag','Remove_section',...
    'Visible', 'off',...
    'string','Confirm Remove This Section','callback',{@Confirm_Remove_section, component_type});

% Push button Confirm Add section
figure_section.pb(5) = uicontrol('style','push',...
    'parent', figure_section.up(5),...
    'units','normalized',...
    'position',[0.72 0.2 0.26 0.6],...
    'backg',figure_section.colpb,...
    'tag','Add_section',...
    'Visible', 'off',...
    'string','Confirm Add This Section','callback',{@Confirm_Add_section, component_type});

%% uicontrol panel button
% Push button Select
figure_section.pb(1) = uicontrol('style','push',...
    'parent', figure_section.up(4),...
    'units','normalized',...
    'position',[0.2 0.55 0.6 0.3],...
    'backg',figure_section.colpb,...
    'tag','Select',...
    'string','Save All Actions','callback',{@Select, component_type});

% Push button Cancel
figure_section.pb(2) = uicontrol('style','push',...
    'parent', figure_section.up(4),...
    'units','normalized',...
    'position',[0.2 0.15 0.6 0.3],...
    'backg',figure_section.colpb,...
    'tag','Cancel',...
    'string','Cancel All Actions','callback',{@Cancel});

handles_section = guihandles(gcf);
guidata(gcf, handles_section);

%% uicontrol panel section
% Table section
section_data = [
    { 'translation x', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT)};
    { 'translation y', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT)}
    { 'translation z', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT)};
    { 'scalling x', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT)};
    { 'scalling y', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT)};
    { 'scalling z', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT)};
    { 'rotation x', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)};
    { 'rotation y', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)};
    { 'rotation z', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)};
    ];

% create the parameters table for this section
figure_section.table_section = uitable('Parent', handles_section.section,...
    'units','normalized',...
    'Position',[0.0 0.0 1.0 1.0],...
    'ColumnName',{'Parameter','Unit','Value'},...
    'ColumnEditable',[false,false,true],...
    'ColumnFormat',{'char','char','numeric'},...
    'RowName',[],...
    'Data', section_data,...
    'tag', 'table_section',...
    'CellEditCallback',{@table_section, component_type});

% create handle for this table
h = findobj('tag','table_section');
handles_section.table_section = h;

% adapt width columns of the tables
set(handles_section.table_section, 'Units', 'pixels');
parameters_position = get(handles_section.table_section, 'Position');
set(handles_section.table_section, 'ColumnWidth', {floor(parameters_position(3)*0.6),floor(parameters_position(3)*0.15),floor(parameters_position(3)*0.2)});
set(handles_section.table_section, 'Units', 'normalized');

%% uicontrol panel element
% Table element
% if str2num(element_struct.cpacsVersion)<2
%     element_data = [
%         { 'translation x', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT)};
%         { 'translation y', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT)}
%         { 'translation z', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT)};
%         { 'scalling x', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT)};
%         { 'scalling y', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT)};
%         { 'scalling z', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT)};
%         { 'rotation x', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)};
%         { 'rotation y', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)};
%         { 'rotation z', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)};
%         { 'length', 'm', str2double(element_struct.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT)};
%         { 'sweep angle', 'deg.', str2double(element_struct.positionings{1,1}.positioning{1,section_number}.sweepangle{1,1}.CONTENT)};
%         { 'dihedral angle', 'deg.', str2double(element_struct.positionings{1,1}.positioning{1,section_number}.dihedralangle{1,1}.CONTENT)};
%         ];
% else
    element_data = [
        { 'translation x', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT)};
        { 'translation y', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT)}
        { 'translation z', 'm', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT)};
        { 'scalling x', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT)};
        { 'scalling y', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT)};
        { 'scalling z', '0-', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT)};
        { 'rotation x', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)};
        { 'rotation y', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)};
        { 'rotation z', 'deg.', str2double(element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)};
        { 'length', 'm', str2double(element_struct.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT)};
        { 'sweep angle', 'deg.', str2double(element_struct.positionings{1,1}.positioning{1,section_number}.sweepAngle{1,1}.CONTENT)};
        { 'dihedral angle', 'deg.', str2double(element_struct.positionings{1,1}.positioning{1,section_number}.dihedralAngle{1,1}.CONTENT)};
        ];
% end

% create the parameters table for this element
figure_section.table_element = uitable('Parent', handles_section.element,...
    'units','normalized',...
    'Position',[0.0 0.0 1.0 1.0],...
    'ColumnName',{'Parameter','Unit','Value'},...
    'ColumnEditable',[false,false,true],...
    'ColumnFormat',{'char','char','numeric'},...
    'RowName',[],...
    'Data', element_data,...
    'tag', 'table_element',...
    'CellEditCallback',{@table_element,component_type} );

% create handle for this table
h = findobj('tag','table_element');
handles_section.table_element = h;

% adapt width columns of the tables
set(handles_section.table_element, 'Units', 'pixels');
parameters_position = get(handles_section.table_element, 'Position');
set(handles_section.table_element, 'ColumnWidth', {floor(parameters_position(3)*0.6),floor(parameters_position(3)*0.15),floor(parameters_position(3)*0.2)});
set(handles_section.table_element, 'Units', 'normalized');

% draw section
Draw_allsection(element_struct, component_type, 0, 1)

%====*****====****====****====****====****====****====****====****====****====****====

msgbox('Please press the ''Confirm Modify/Add/Remove This Section'' button in order to save the changes made at each step.In the end, press the ''Save All Actions'' to save all the changes made','Attention Please', 'warn','modal');

end

%% functions callback corresponding to tables
function [] = table_section(varargin)
%--- Main Usage: user change table content  
%--- Update element_structure
%--- Draw_allsection: cpacsWrapper geo, draw all sections in blue 
%--- Color the selected section

global element_struct handles_section  section_number   % counter_section  

event = varargin{2};
local_element_type = varargin{3};

section_data = get(handles_section.table_section, 'Data');                  % get the section data

switch event.Indices(1)
    case 1          % translation x
        section_data(1,3) = num2cell(event.NewData);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(section_data(1,3)));
    case 2          % translation y
        section_data(2,3) = num2cell(event.NewData);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(section_data(2,3)));
    case 3          % translation z
        section_data(3,3) = num2cell(event.NewData);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(section_data(3,3)));
    case 4          % scaling x
        scaling_x = event.NewData;
        if scaling_x < 0
            scaling_x = 0;
        end
        section_data(4,3) = num2cell(scaling_x);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(section_data(4,3)));
    case 5         % scaling y
        scaling_y = event.NewData;
        if scaling_y < 0
            scaling_y = 0;
        end
        section_data(5,3) = num2cell(scaling_y);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(section_data(5,3)));
    case 6        % scaling z
        scaling_z = event.NewData;
        if scaling_z < 0
            scaling_z = 0;
        end
        section_data(6,3) = num2cell(scaling_z);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(section_data(6,3)));
    case 7        % rotation x
        rotation_x = event.NewData;
        if rotation_x < - 180
            rotation_x = -180;
        elseif rotation_x > 180
            rotation_x = 180;
        end
        section_data(7,3) = num2cell(rotation_x);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(section_data(7,3)));
    case 8       % rotation y
        rotation_y = event.NewData;
        if rotation_y < - 180
            rotation_y = -180;
        elseif rotation_y > 180
            rotation_y = 180;
        end
        section_data(8,3) = num2cell(rotation_y);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(section_data(8,3)));
    case 9      % rotation z
        rotation_z = event.NewData;
        if rotation_z < - 180
            rotation_z = -180;
        elseif rotation_z > 180
            rotation_z = 180;
        end
        section_data(9,3) = num2cell(rotation_z);
        element_struct.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(section_data(9,3)));
end

set(handles_section.table_section, 'Data', section_data);                                        % load adjusted data in the table
Draw_allsection(element_struct,local_element_type, 0, 0);       % draw section
Draw_changeSectionColor(section_number);

end

function [] = table_element(varargin)
%--- Main Usage: user change table_element content  
%--- Update element_structure
%--- Draw_allsection: cpacsWrapper geo, draw all sections in blue 
%--- Color the selected section

global element_struct  section_number   handles_section  % counter_section 

event = varargin{2};
local_element_type = varargin{3};

% get the element data
element_data = get(handles_section.table_element, 'Data');

switch event.Indices(1)
    case 1        % translation x
        element_data(1,3) = num2cell(event.NewData);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(element_data(1,3)));
    case 2        % translation y
        element_data(2,3) = num2cell(event.NewData);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(element_data(2,3)));
    case 3        % translation z
        element_data(3,3) = num2cell(event.NewData);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(element_data(3,3)));
    case 4        % scaling x
        scaling_x = event.NewData;
        if scaling_x < 0
            scaling_x = 0;
        end
        element_data(4,3) = num2cell(scaling_x);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(element_data(4,3)));
    case 5        % scaling y
        scaling_y = event.NewData;
        if scaling_y < 0
            scaling_y = 0;
        end
        element_data(5,3) = num2cell(scaling_y);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(element_data(5,3)));
    case 6       % scaling z
        scaling_z = event.NewData;
        if scaling_z < 0
            scaling_z = 0;
        end
        element_data(6,3) = num2cell(scaling_z);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(element_data(6,3)));
    case 7      % rotation x
        rotation_x = event.NewData;
        if rotation_x < - 180
            rotation_x = -180;
        elseif rotation_x > 180
            rotation_x = 180;
        end
        element_data(7,3) = num2cell(rotation_x);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(element_data(7,3)));
    case 8      % rotation y
        rotation_y = event.NewData;
        if rotation_y < - 180
            rotation_y = -180;
        elseif rotation_y > 180
            rotation_y = 180;
        end
        element_data(8,3) = num2cell(rotation_y);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(element_data(8,3)));
    case 9     % rotation z
        rotation_z = event.NewData;
        if rotation_z < - 180
            rotation_z = -180;
        elseif rotation_z > 180
            rotation_z = 180;
        end
        element_data(9,3) = num2cell(rotation_z);
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(element_data(9,3)));
    
    case 10     % length
        length = event.NewData;
        if length < 0
            length = 0;
        end
        element_data(10,3) = num2cell(length);
        element_struct.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT = mat2str(cell2mat(element_data(10,3)));
        
    case 11     % sweep angle
        sweep_angle = event.NewData;
        if sweep_angle < - 90
            sweep_angle = - 90;
        elseif sweep_angle > 90
            sweep_angle = 90;
        end
        element_data(11,3) = num2cell(sweep_angle);
        element_struct.positionings{1,1}.positioning{1,section_number}.sweepAngle{1,1}.CONTENT = mat2str(cell2mat(element_data(11,3)));

    case 12    % dihedral angle
        dihedral_angle = event.NewData;
        if dihedral_angle < - 90
            dihedral_angle = - 90;
        elseif dihedral_angle > 90
            dihedral_angle = 90;
        end
        element_data(12,3) = num2cell(dihedral_angle);
        element_struct.positionings{1,1}.positioning{1,section_number}.dihedralAngle{1,1}.CONTENT = mat2str(cell2mat(element_data(12,3)));
end

set(handles_section.table_element, 'Data', element_data);                   % load adjusted data in the table

%--------------------------------------------------------
Draw_allsection(element_struct, local_element_type, 0, 0)
Draw_changeSectionColor(section_number);
end

function [] = Draw_allsection(element_struct, local_element_type, remove_index, init)

global local_coordinates_struct  handles_section

cam_pos_1 = get(handles_section.axes_1, 'CameraPosition');                  % current camera position
cam_pos_2 = get(handles_section.axes_2, 'CameraPosition');

cla(handles_section.axes_1);                                                % deletes from the current axes all graphics objects

%----------------------------------------------------------------%

local_coordinates_struct = {};
switch local_element_type
    case 'fuselages'
        [local_coordinates_struct]=readfuselage_localStruct(local_coordinates_struct,element_struct);
    case 'wings'
        [local_coordinates_struct]=readwings_localStruct(local_coordinates_struct, element_struct);
end

% draw all the sections
XYZ_all_airfoils = local_coordinates_struct.sectionDef.airfoil;         % get all the coordinates needed for drawing sections
size_all_airfoils = length(XYZ_all_airfoils);                          % get the number of sections

for i=1:size_all_airfoils
    plot3(handles_section.axes_1, XYZ_all_airfoils{i,1}(:,1), XYZ_all_airfoils{i,1}(:,2), XYZ_all_airfoils{i,1}(:,3),'b')
    hold(handles_section.axes_1, 'on')                                                                                      % wait before drawing
end

%-------------------Set axes_1 figure settings------------------%
% axes titles
set(get(handles_section.axes_1, 'xlabel'),'String','X')
set(get(handles_section.axes_1, 'ylabel'),'String','Y')
set(get(handles_section.axes_1, 'zlabel'),'String','Z')

set(handles_section.axes_1, 'DataAspectRatio',[1 1 1]);
cam_pos_AR_1 = get(handles_section.axes_1, 'CameraPosition');               % camera position for AspectRatio [1 1 1]

if init == 1                % set the camera to the default position
    set(handles_section.axes_1, 'CameraPosition', cam_pos_AR_1);
else                        % stay in the last position
    set(handles_section.axes_1, 'CameraPosition', cam_pos_1);
end

grid(handles_section.axes_1, 'on')


%-------------------Set axes_2 figure settings------------------%
% axes titles
set(get(handles_section.axes_2, 'xlabel'),'String','X')
set(get(handles_section.axes_2, 'ylabel'),'String','Y')
set(get(handles_section.axes_2, 'zlabel'),'String','Z')

set(handles_section.axes_2, 'DataAspectRatio',[1 1 1]);
cam_pos_AR_2 = get(handles_section.axes_2, 'CameraPosition');

if init == 1                % set the camera to the default position
    set(handles_section.axes_2, 'CameraPosition', cam_pos_AR_2);
else                        % stay in the last position
    set(handles_section.axes_2, 'CameraPosition', cam_pos_2);
end

grid(handles_section.axes_2, 'on')

if strcmp(get(handles_section.Drawing, 'Visible'), 'on') == 1
    rotate3d(handles_section.axes_1, 'on')
elseif strcmp(get(handles_section.Drawing2, 'Visible'), 'on') == 1
    rotate3d(handles_section.axes_2, 'on')
end

if isfield(handles_section, 'before_1')
    handles_section = rmfield(handles_section, 'before_1');
end

if isfield(handles_section, 'after_1')
   handles_section = rmfield(handles_section, 'after_1'); 
end

if isfield(handles_section, 'red_1')
   handles_section = rmfield(handles_section, 'red_1');
end
%-----------------------------------------------------------------%
%{
% draw only the airfoil before the selected one, green colored!
if section_number ~= 1
    XYZ_airfoil = local_coordinates_struct.sectionDef.airfoil{section_number - 1,1};   % the
    plot3(handles_section.axes_1,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g')
    hold(handles_section.axes_1, 'on')
    plot3(handles_section.axes_2,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g')
    hold(handles_section.axes_2, 'on')
end

% draw only the airfoil after the selected one, green colored!
if section_number ~= size_all_airfoils
    XYZ_airfoil = local_coordinates_struct.sectionDef.airfoil{section_number + 1,1};
    plot3(handles_section.axes_1,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g')
    hold(handles_section.axes_1, 'on')
    plot3(handles_section.axes_2,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g')
    hold(handles_section.axes_2, 'on')
end

%% draw only the selected section
% if remove_index == 1       % why does this part mean??
%     if section_number == number_of_sections                                 % if remove the last section
%         figure_name = element_struct.sections{1,1}.section{1,section_number}.name{1,1}.CONTENT;
%         set(handles_section.figure_section, 'name', figure_name)
%     end
% end

XYZ_airfoil = local_coordinates_struct.sectionDef.airfoil{section_number,1};

plot3(handles_section.axes_1,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'r')
hold(handles_section.axes_1, 'off')

% axes titles

%-------------------------------------------------------------------------
% plot on axes 2 and figure settings

plot3(handles_section.axes_2,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'r')
hold(handles_section.axes_2, 'off')


%}

end

function [] = Draw_changeSectionColor(section_number)
global  handles_section  local_coordinates_struct

if isfield(handles_section, 'before_1')
   set(handles_section.before_1, 'color','b');    
end

if isfield(handles_section, 'after_1')
   set(handles_section.after_1, 'color','b'); 
end

if isfield(handles_section, 'red_1')
   set(handles_section.red_1, 'color','b');
end

XYZ_all_airfoils = local_coordinates_struct.sectionDef.airfoil;         % get all the coordinates needed for drawing sections
size_all_airfoils = length(XYZ_all_airfoils); 

%-----------highlight the section being selected in red!-----------------
XYZ_airfoil = local_coordinates_struct.sectionDef.airfoil{section_number,1};
handles_section.red_1 = plot3(handles_section.axes_1,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'r');
hold(handles_section.axes_1, 'on')
handles_section.red_2 = plot3(handles_section.axes_2,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'r');
hold(handles_section.axes_2, 'off')
%------------------------------------------------------------------------

% draw only the airfoil before the selected one, green colored!
if section_number ~= 1
    XYZ_airfoil = local_coordinates_struct.sectionDef.airfoil{section_number - 1,1};   % the
    handles_section.before_1 = plot3(handles_section.axes_1,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g');
    hold(handles_section.axes_1, 'on')
    
    handles_section.before_2 = plot3(handles_section.axes_2,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g');
    hold(handles_section.axes_2, 'on')
end

% draw only the airfoil after the selected one, green colored!
if section_number ~= size_all_airfoils
    XYZ_airfoil = local_coordinates_struct.sectionDef.airfoil{section_number + 1,1};
    handles_section.after_1 = plot3(handles_section.axes_1,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g');
    hold(handles_section.axes_1, 'on')
    handles_section.after_2 = plot3(handles_section.axes_2,XYZ_airfoil(:,1),XYZ_airfoil(:,2),XYZ_airfoil(:,3),'g');
    hold(handles_section.axes_2, 'on')
end
end

%% functions callback corresponding to buttons
function [] = Select(varargin)

global handles_section  historic_section_string   stage_element_struct  final_struct 
h = msgbox(historic_section_string, 'informations');     % visualize the modifications history

close(handles_section.figure_section)
close(h)
final_struct = stage_element_struct; 
end

function [] = Cancel (varargin)

global handles_section  final_struct

% create a question box
message = strcat('Do you really want to close this window and lose all the modifications ? ');
choice = questdlg(message, 'Cancel', 'Yes', 'No', 'No');

switch choice
    case 'Yes'        % close the window
        close(handles_section.figure_section);
        final_struct.change = 0; 
    case 'No'
        return;
end

end

function [] = Confirm_Modify_section(varargin)

global  stage_element_struct   historic_section_string  element_struct   % counter_section

section_number = varargin{3};

message = strcat('Do you want to modify the section ', num2str(section_number), ' ?');        % create a question box
choice = questdlg(message, 'Modify function', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        historic_section_string = char(char(historic_section_string),strcat('modify section', num2str(section_number)));
        
        element_struct.change = element_struct.change + 1; 
        stage_element_struct = element_struct;
        
    case 'No'
       return
end

end

function [] = Confirm_Remove_section(varargin)
global element_struct section_number handles_section stage_element_struct historic_section_string

local_element_type = varargin{3};

number_of_sections = length(element_struct.sections{1,1}.section);          % get the current number of sections

if number_of_sections <= 2     % create a warning dialog box
    message = 'Impossible to remove a section when there is just 2 sections left';
    warndlg(message, 'Remove Function Error', 'modal');
    return;
else                           % create a question box
    message = strcat('Do you want to remove the section ', num2str(section_number), ' ?');
    choice = questdlg(message, 'Remove function', 'Yes', 'No', 'No');
end

switch choice
    case 'Yes'
        
    case 'No'
        return;
end

%------------------------------------------------------------------
% update structure's content of sections, positionings, & segments

if section_number == 1        
    element_struct.sections{1,1}.section(section_number) = [];
    element_struct.positionings{1,1}.positioning(section_number) = [];
    element_struct.segments{1,1}.segment(section_number) = []; 
    
    element_struct.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT = '0';
    element_struct.positionings{1,1}.positioning{1,section_number}.sweepAngle{1,1}.CONTENT = '0';
    element_struct.positionings{1,1}.positioning{1,section_number}.dihedralAngle{1,1}.CONTENT = '0';
    element_struct.positionings{1,1}.positioning{1,section_number} = rmfield(element_struct.positionings{1,1}.positioning{1,section_number}, 'fromSectionUID');
    
    ref_sec = section_number; 
elseif section_number == number_of_sections
    element_struct.sections{1,1}.section(section_number) = [];
    element_struct.positionings{1,1}.positioning(section_number) = [];
    element_struct.segments{1,1}.segment(section_number-1) = []; 
    ref_sec = section_number - 1; 
    
else    
    pos_length = str2double(element_struct.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT) + ...
        str2double(element_struct.positionings{1,1}.positioning{1,section_number + 1}.length{1,1}.CONTENT);
    
    element_struct.sections{1,1}.section(section_number) = [];
    element_struct.positionings{1,1}.positioning(section_number) = [];
    element_struct.segments{1,1}.segment(section_number-1) = [];
 %   element_struct.segments{1,1}.segment(section_number) = [];
         
    element_struct.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT = num2str(pos_length);
    element_struct.positionings{1,1}.positioning{1,section_number}.fromSectionUID{1,1}.CONTENT = element_struct.sections{1,1}.section{1,section_number-1}.ATTRIBUTE.uID;
    
    element_struct.segments{1,1}.segment{1,section_number-1}.fromElementUID{1,1}.CONTENT = element_struct.sections{1,1}.section{1,section_number-1}.elements{1,1}.element{1,1}.ATTRIBUTE.uID;  
    ref_sec  = section_number; 
end


%-----------------------------------------------------------------
% new section id drop list
popupmenu_string = num2cell([1:length(element_struct.sections{1,1}.section)]');

% set the new possiblity for select a section
set(handles_section.select_a_section, 'Value',  ref_sec)                       % length(element_struct.sections{1,1}.section)
set(handles_section.select_a_section, 'String', popupmenu_string);
% section_number = length(element_struct.sections{1,1}.section); 
%-----------------------------------------------------------------
% Between sections
popupmenu_string ='';
for i=0:length(element_struct.sections{1,1}.section)
    if i == 0
        popupmenu_string = char(popupmenu_string, 'first');
    elseif i == length(element_struct.sections{1,1}.section)
        popupmenu_string = char(popupmenu_string, 'last');
    else
        popupmenu_string = char(popupmenu_string, strcat(num2str(i),'-', num2str(i+1)));
    end
end
popupmenu_string = popupmenu_string(2:end,:);

set(handles_section.between_sections, 'String', popupmenu_string);
%----------------------------------------------------------------
% set section_number to 1

section_number = ref_sec; 

adjust_tables(element_struct, section_number, handles_section);             % visualize the right table corresponding to the selected section

element_struct.change = element_struct.change + 1; 
stage_element_struct = element_struct;

historic_section_string = char(char(historic_section_string),strcat('remove section', num2str(section_number)));
historic_section_string = char(char(historic_section_string),strcat('number of sections:', num2str(length(element_struct.sections{1,1}.section))));

Draw_allsection(element_struct, local_element_type, 1, 0)

end

function [] = Confirm_Add_section(varargin)
% Here is what happens when the user is sure to add the section and the
% button Confirm_Add_this_Section is clicked

global element_struct stage_element_struct section_number handles_section historic_section_string  % counter_section 

local_element_type = varargin{3};

% create a question box
message = strcat('Do you want to save the added section between section ', num2str(section_number - 1), ' and section ', num2str(section_number),' ?');
choice = questdlg(message, 'Add function', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        [element_struct] = add_section_confirmed(section_number, stage_element_struct, element_struct);     % For the added section, one new name for the added section, one/two new names for the added positionings        
        %-------------------------------------------------------                                            % one/two new names for the added segments will need to be input from the users and stored.                 
        element_struct.change = element_struct.change + 1; 
        stage_element_struct = element_struct;
        %--------------------------------------------------------
        historic_section_string = char(char(historic_section_string),strcat('add section', num2str(section_number)));
        historic_section_string = char(char(historic_section_string),strcat('number of sections:', num2str(length(stage_element_struct.sections{1,1}.section))));
        
        %----------%-----------%------------%------------%--------%---------%------
        % Select a Section, updated with the newly added section
        popupmenu_string = num2cell([1:length(stage_element_struct.sections{1,1}.section)]');               % update the select_a_section droplist
        
        % set the new possiblity for select a section
        set(handles_section.select_a_section, 'String', popupmenu_string);
        %-----------------------------------------------%
        % Between sections, updated with the newly added section
        popupmenu_string ='';
        for i=0:length(stage_element_struct.sections{1,1}.section)
            if i == 0
                popupmenu_string = char(popupmenu_string, 'first');
            elseif i == length(stage_element_struct.sections{1,1}.section)
                popupmenu_string = char(popupmenu_string, 'last');
            else
                popupmenu_string = char(popupmenu_string, strcat(num2str(i),'-', num2str(i+1)));
            end
        end
        popupmenu_string = popupmenu_string(2:end,:);
        set(handles_section.between_sections, 'String', popupmenu_string);                                 % update the between_sections droplist    
        
        %--------------------------------------------------
        switch local_element_type               % find the profile corresponding with the section number
            case 'fuselages'
                profile_UID = stage_element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT;
            case 'wings'
                profile_UID = stage_element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT;
        end
        
        list_profiles = stage_element_struct.profiles;                                                    % get the list of all the fuselage profiles
        size_list_profiles = size(list_profiles);                                                         % get the size of this list
        
        for i=1:size_list_profiles(2)                                                                     % find the name (UID) in all the profiles name to access the profile coordinates
            if strcmp(list_profiles{1,i}.ATTRIBUTE.uID, profile_UID) == 1
                profile_number = i;
            end
        end        
        set(handles_section.choose_a_profile, 'Value', profile_number);                                   % set the profile used
        %-------------------------------------------------------------------
        
        Draw_allsection(stage_element_struct,local_element_type, 0, 0)                                    % draw section
        Draw_changeSectionColor(section_number);
        
    case 'No'
      return
end

end

%% functions callback corresponding to checkboxes
function [] = View_all_sections(varargin)

global handles_section

% update the check boxes
set(handles_section.all_sections, 'Value', 1);
set(handles_section.selected_section, 'Value', 0);

% set visibility to the right drawing panel
set(handles_section.Drawing, 'Visible', 'on')
set(handles_section.Drawing2, 'Visible', 'off')

% permits rotation
rotate3d(handles_section.axes_1, 'on')

end

function [] = View_selected_section(varargin)

global handles_section

% update the check boxes
set(handles_section.all_sections, 'Value', 0);
set(handles_section.selected_section, 'Value', 1);

% set visibility to the right drawing panel
set(handles_section.Drawing, 'Visible', 'off')
set(handles_section.Drawing2, 'Visible', 'on')

% permits rotation
rotate3d(handles_section.axes_2, 'on')

end

function [] = Mode_modify_sections(varargin)

global handles_section  stage_element_struct  element_struct  

element_struct = stage_element_struct;

set(handles_section.cb_modify_sections, 'Value',1);
set(handles_section.cb_add_sections, 'Value',0);                            % update the check boxes
set(handles_section.cb_remove_sections, 'Value',0);   

set(handles_section.select_a_section, 'Visible', 'on');                     % set visibility to objects corresponding with the check box
set(handles_section.between_sections, 'Visible', 'off');

set(handles_section.Modify_section, 'Visible', 'on');
set(handles_section.Remove_section, 'Visible', 'off');
set(handles_section.Add_section, 'Visible', 'off');

set(handles_section.table_section, 'Visible', 'on');
set(handles_section.table_element, 'Visible', 'on');

set(handles_section.Section_modification, 'Title', 'Modify sections');

end

function [] = Mode_add_sections(varargin)

global handles_section element_struct stage_element_struct

element_struct = stage_element_struct;

set(handles_section.cb_add_sections, 'Value',1);                             % update the check boxes
set(handles_section.cb_modify_sections, 'Value',0);
set(handles_section.cb_remove_sections, 'Value',0);  

set(handles_section.select_a_section, 'Visible', 'off');                     % set visibility to objects corresponding with the check box
set(handles_section.between_sections, 'Visible', 'on');
set(handles_section.Modify_section, 'Visible', 'off');
set(handles_section.Remove_section, 'Visible', 'off');
set(handles_section.Add_section, 'Visible', 'on');

set(handles_section.table_section, 'Visible', 'on');
set(handles_section.table_element, 'Visible', 'on');

set(handles_section.Section_modification, 'Title', 'Add sections');

end

function [] = Mode_remove_sections(varargin)
global handles_section element_struct stage_element_struct

element_struct = stage_element_struct;

set(handles_section.cb_remove_sections, 'Value',1);  
set(handles_section.cb_add_sections, 'Value',0);
set(handles_section.cb_modify_sections, 'Value',0);

set(handles_section.select_a_section, 'Visible', 'on');
set(handles_section.between_sections, 'Visible', 'off');
set(handles_section.Modify_section, 'Visible', 'off');
set(handles_section.Remove_section, 'Visible', 'on');
set(handles_section.Add_section, 'Visible', 'off');

set(handles_section.table_section, 'Visible', 'off');
set(handles_section.table_element, 'Visible', 'off');

set(handles_section.Section_modification, 'Title', 'Remove sections');

end


%% functions callback corresponding to popups-menu

function [] = select_a_section(varargin)

%--- Main Uage: change the global variable "section_number"
%--- Correspondingly: profile change
%--- Table_section & Table_element change
%--- in GUI axes, the selected section red color, its two neighbours blue

global handles_section section_number element_struct                        %stage_element_struct   % counter_section

local_element_type = varargin{3};

%%-------------------------------%%-----------------------------%%
section_number = get(handles_section.select_a_section, 'Value');            
%%-------------------------------%%-----------------------------%%

adjust_tables(element_struct, section_number, handles_section)        % visualize the right table corresponding to the selected section

switch  local_element_type                   % find the profile corresponding with the section number
    case 'fuselages'                          % get the name (UID) of the profile selected
        profile_UID = element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT;
    case 'wings'                              % get the name (UID) of the profile selected
        profile_UID = element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT;
end

list_profiles = element_struct.profiles;          % get the list of all the fuselage profiles
size_list_profiles = size(list_profiles);         % get the size of this list

for i=1:size_list_profiles(2)                     % find the name (UID) in all the profiles name to access the profile coordinates
    if strcmp(list_profiles{1,i}.ATTRIBUTE.uID, profile_UID) == 1
        profile_number = i;
    end
end

set(handles_section.choose_a_profile, 'Value', profile_number);

%%--------------------------------%%-----------------------------%%
% Draw_section(element_struct, local_element_type, 0, 0, handles_section, section_number);
Draw_changeSectionColor(section_number)
end

function [] = choose_a_profile(varargin)
%--- Main Usage: change the profile of the selected section identified by "section_number"
%--- "element_struct" updated
%--- Call Draw_allsections: cpacsWrapper -> geo, draw all sections in blue
%--- Change the selected section color

global element_struct  handles_section section_number

local_element_type = varargin{3};

% get the name of the chosen section
section_value = get(handles_section.choose_a_profile, 'Value');
section_string = get(handles_section.choose_a_profile, 'String');
section_name = section_string(section_value,:);
section_name = strtok(section_name);
%--------------------------------------------

switch local_element_type
    case 'fuselages'
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT = section_name;
    case 'wings'
        element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT = section_name;
end

% draw section
Draw_allsection(element_struct,local_element_type, 0, 0)
Draw_changeSectionColor(section_number);
end

function [] = between_sections(varargin)
% first a dummy section was added to element_struct, via add_section_test(local_element_type); 
% then the user may change the parameters for the section and element on
% the panel; or discard this attempt and select another location to add, by
% selecting from between_sections
% when the user is satisfied with the shape and location of the
% added section, the Confirm to Add button should be clicked, see 
% Confirm_Add_section subfunction

global element_struct section_number handles_section      
local_element_type = varargin{3};

section_number = get(handles_section.between_sections, 'Value');

%----------------------------------------
add_section_test(local_element_type)                                              % create new field in the structure for adding a new section
adjust_tables(element_struct, section_number, handles_section)                    % visualize the right table corresponding for the added section; wherence the user may change the parameters
%---------------------------------------

switch local_element_type                                                    % find the profile corresponding with the section number
    case 'fuselages'                                                          % get the name (UID) of the profile selected
        profile_UID = element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT;       
    case 'wings'                                                              % get the name (UID) of the profile selected
        profile_UID = element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT;
end

list_profiles = element_struct.profiles;                                     % get the list of all the fuselage profiles
size_list_profiles = size(list_profiles);                                    % get the size of this list

for i=1:size_list_profiles(2)                                                % find the name (UID) in all the profiles name to access the profile coordinates
    if strcmp(list_profiles{1,i}.ATTRIBUTE.uID, profile_UID) == 1
        profile_number = i;
    end
end

set(handles_section.choose_a_profile, 'Value', profile_number);              % set the profile used

Draw_allsection(element_struct,local_element_type, 0, 0);       % draw section
Draw_changeSectionColor(section_number);

end

%% other functions

function [] = adjust_tables(structure, section_number, handles_section)

% global handles_section

% Table section
section_data = [
    { 'translation x', 'm', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT)};
    { 'translation y', 'm', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT)}
    { 'translation z', 'm', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT)};
    { 'scalling x', '0-', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT)};
    { 'scalling y', '0-', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT)};
    { 'scalling z', '0-', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT)};
    { 'rotation x', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)};
    { 'rotation y', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)};
    { 'rotation z', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)};
    ];

% adjust table section
set(handles_section.table_section, 'Data', section_data);

% Table element
%if str2num(structure.cpacsVersion) < 2
%     element_data = [
%         { 'translation x', 'm', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT)};
%         { 'translation y', 'm', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT)}
%         { 'translation z', 'm', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT)};
%         { 'scalling x', '0-', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT)};
%         { 'scalling y', '0-', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT)};
%         { 'scalling z', '0-', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT)};
%         { 'rotation x', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)};
%         { 'rotation y', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)};
%         { 'rotation z', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)};
%         { 'length', 'm', str2double(structure.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT)};
%         { 'sweep angle', 'deg.', str2double(structure.positionings{1,1}.positioning{1,section_number}.sweepangle{1,1}.CONTENT)};
%         { 'dihedral angle', 'deg.', str2double(structure.positionings{1,1}.positioning{1,section_number}.dihedralangle{1,1}.CONTENT)};
%         ];
% else
    element_data = [
        { 'translation x', 'm', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT)};
        { 'translation y', 'm', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT)}
        { 'translation z', 'm', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT)};
        { 'scalling x', '0-', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT)};
        { 'scalling y', '0-', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT)};
        { 'scalling z', '0-', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT)};
        { 'rotation x', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)};
        { 'rotation y', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)};
        { 'rotation z', 'deg.', str2double(structure.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)};
        { 'length', 'm', str2double(structure.positionings{1,1}.positioning{1,section_number}.length{1,1}.CONTENT)};
        { 'sweep angle', 'deg.', str2double(structure.positionings{1,1}.positioning{1,section_number}.sweepAngle{1,1}.CONTENT)};
        { 'dihedral angle', 'deg.', str2double(structure.positionings{1,1}.positioning{1,section_number}.dihedralAngle{1,1}.CONTENT)};
        ];
% end
set(handles_section.table_element, 'Data', element_data);

end
