function [] = figure_spars_and_ribs3(spaRib_struct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Modify, remove and add spars and ribs                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Pierre Saquet                                         %
% LastModified:     2013-03-21                                            %
% LastModifiedBy:   Pengfei Meng                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%                                                                         %
%   - add a function to delete a whole spar                               %
%   - improve the whole module: some problems are still unsolved          % 
%   - sometimes the function crashes for no reason                        %
%   - add restrictions for the possibilities of modifications because     %
%     ribs depend a lot in the spar geometry                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sr ~ SparsRibs for short
clear global srStruct
clear global stage_srStruct
%clear global final_srStruct

global handles_sr srStruct stage_srStruct final_srStruct 
global spars_or_ribs_number spar_number spar_position_number   rib_number 
global spar_position_add_number  rib_add_number 

spaRib_struct.change = 0; 
srStruct = spaRib_struct;                    % used to visualize every potential modification
stage_srStruct = spaRib_struct;              % used to record the real modifications at each stage
final_srStruct = spaRib_struct; 

% if isfield(handles_sr, 'axes_1')
%     cla(handles_sr.axes_1)
% end
%% Figure
figure_spars_and_ribs.fh = figure('units','normalized',...
    'position',[0.1 0.2 0.6 0.7],...
    'menubar','none',...
    'Color',[.2 .2 .3],...
    'numbertitle','off',...
    'name','Modify SparsRibs',...
    'renderer', 'OpenGL',...
    'Tag','figure_spars_and_ribs',...
    'resize','off');     %  'WindowStyle', 'modal',...

figure_spars_and_ribs.colpb = [0.9255, 0.9137, 0.8471]; % Default Color of buttons

%% Panels
% Panel Drawing
figure_spars_and_ribs.up(1)= uipanel('Parent',figure_spars_and_ribs.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.0 0.7 0.8],...
                    'backgroundcolor', [1.0 1.0 1.0],...
                    'tag','Drawing');
                
% Panel parameters
figure_spars_and_ribs.up(2)= uipanel('Parent',figure_spars_and_ribs.fh ,'Title','parameters',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.2 0.3 0.8],...
                    'tag','parameters');
                
% Panel spars and ribs modification
figure_spars_and_ribs.up(3)= uipanel('Parent',figure_spars_and_ribs.fh ,'Title','Modify spars and ribs',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.8 0.7 0.1],...
                    'tag','spars_and_ribs_modification');
                
% Panel button
figure_spars_and_ribs.up(4)= uipanel('Parent',figure_spars_and_ribs.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.0 0.3 0.2],...
                    'tag','button');
                
% Panel Modes
figure_spars_and_ribs.up(5)= uipanel('Parent',figure_spars_and_ribs.fh ,'Title','Modes',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.9 0.7 0.1],...
                    'tag','modes');

%% panel Drawing
% axes 1
figure_spars_and_ribs.axes(1) = axes('Parent', figure_spars_and_ribs.up(1),...
                    'units','normalized',...
                    'Visible', 'off',...
                    'OuterPosition',[0.0 0.0 1.0 1.0],...
                    'tag', 'axes_1');
                
%% uicontrol panel Modes
% Checkbox Modify spars and ribs
figure_spars_and_ribs.cb(1) = uicontrol('style','checkbox',...
                    'parent', figure_spars_and_ribs.up(5),...
                    'units','normalized',...
                    'position',[0.1 0.0 0.2 1.0],...
                    'tag','mode_modify',...
                    'Value',1,...
                    'string','Modify SparsRibs','callback',{@mode_modify});
 
% Checkbox Remove spars and ribs
figure_spars_and_ribs.cb(2) = uicontrol('style','checkbox',...
                    'parent', figure_spars_and_ribs.up(5),...
                    'units','normalized',...
                    'position',[0.4 0.0 0.2 1.0],...
                    'tag','mode_remove',...
                    'Value',0,...
                    'string','Remove SparsRibs','callback',{@mode_remove});                             
% Checkbox Add sections
figure_spars_and_ribs.cb(3) = uicontrol('style','checkbox',...
                    'parent', figure_spars_and_ribs.up(5),...
                    'units','normalized',...
                    'position',[0.7 0.0 0.2 1.0],...
                    'tag','mode_add',...
                    'Value',0,...
                    'string','Add SparsRibs','callback',{@mode_add});

%% uicontrol panel spars and ribs modification
% label
figure_spars_and_ribs.label(1) = uicontrol('Style', 'text',...
                'Parent', figure_spars_and_ribs.up(3),...
                'units','normalized',...
                'Position',[0.0 0.3 0.18 0.4],...
                'Tag','label',...
                'String', 'select spars/ribs');

% Pop-up menu Select spars/ribs
figure_spars_and_ribs.popupmenu(1) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_spars_and_ribs.up(3),...
                            'units','normalized',...
                            'Position',[0.18 0.3 0.12 0.4],...
                            'tag', 'select_spars_or_ribs',...
                            'backg',figure_spars_and_ribs.colpb,...
                            'String', {'Spars'; 'Ribs';},...
                            'Value', 1,...
                            'callback', {@select_spars_or_ribs});
                        
spars_or_ribs_number = 1;
 
[sparsRibsgeo] = sparsRibs_struct2geo(spaRib_struct);
% Pop-up menu : list of spar segments
spars_geo = sparsRibsgeo.spars;                                            % get the spars structure                        
sparSegments_string = spars_geo.segments.uIDs; 
                        
figure_spars_and_ribs.popupmenu(2) = uicontrol('Style', 'popupmenu',...     % Pop-up menu Select a spar
                            'Parent', figure_spars_and_ribs.up(3),...
                            'units','normalized',...
                            'Position',[0.31 0.3 0.15 0.4],...
                            'tag', 'select_a_spar',...
                            'backg',figure_spars_and_ribs.colpb,...
                            'String', sparSegments_string,...
                            'Value', 1,...
                            'callback', {@select_a_spar});

spar_number = 1;

% Pop-up menu : list of spar positions for the selected spar segment              
num_sparPositions = length(spars_geo.segments.positions{1,1});

sparSegment1_string = spars_geo.segments.positions{1};    
figure_spars_and_ribs.popupmenu(4) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_spars_and_ribs.up(3),...
                            'units','normalized',...
                            'Position',[0.47 0.3 0.17 0.4],...
                            'tag', 'select_a_spar_position',...
                            'backg',figure_spars_and_ribs.colpb,...
                            'String', sparSegment1_string,...
                            'Value', 1,...
                            'callback', {@select_a_spar_position});
                        
spar_position_number = 1;


%% list of Ribs 
ribs_geo = sparsRibsgeo.ribsDefinitions;                        
number_of_ribs_definition = length(ribs_geo.uIDs);

ribSegments_string = ribs_geo.uIDs;
figure_spars_and_ribs.popupmenu(3) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_spars_and_ribs.up(3),...
                            'units','normalized',...
                            'Position',[0.35 0.3 0.2 0.4],...
                            'tag', 'select_a_rib',...
                            'backg',figure_spars_and_ribs.colpb,...
                            'String', ribSegments_string,...
                            'Value', 1,...
                            'Visible', 'off',...
                            'callback', {@select_a_rib});
                        
rib_number = 1;

%% Add spars and ribs 
%----------------------------------
%----------------------------------
% Pop-up menu Select a spar position to add
sparSegment1_string_add = cell(1,num_sparPositions+1);
for i=1:num_sparPositions+1
    if i == 1
        add_string = strcat('before ',sparSegment1_string{1});
    elseif i == num_sparPositions+1
        add_string = strcat('after ',sparSegment1_string{end});
    else
        add_string = strcat('between', sparSegment1_string{i-1}, ' and ', sparSegment1_string{i});
    end
    sparSegment1_string_add{i} = add_string;
end
                        
% Pop-up menu Select a spar position for add mode
figure_spars_and_ribs.popupmenu(8) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_spars_and_ribs.up(3),...
                            'units','normalized',...
                            'Position',[0.47 0.3 0.17 0.4],...    %[0.46 0.3 0.17 0.4]
                            'tag', 'select_a_spar_position_add',...
                            'backg',figure_spars_and_ribs.colpb,...
                            'String', sparSegment1_string_add ,...
                            'Value', 1,...
                            'Visible', 'off',...
                            'callback', {@select_a_spar_position_add});
                        
spar_position_add_number = 1;

%-----------------------------------------------------             
% Pop-up menu Select a Rib Position to add

ribSegments_string_add = cell(1,number_of_ribs_definition+1);
for i=1:number_of_ribs_definition+1
    if i == 1      
        add_string = strcat('before ',ribSegments_string{1});
    elseif i == number_of_ribs_definition+1     
        add_string = strcat('after ',ribSegments_string{end});
    else
        add_string = strcat('between ', ribSegments_string{i-1}, ' and ', ribSegments_string{i});
    end
    ribSegments_string_add{i} = add_string;
end
                        
% Pop-up menu Select a rib
figure_spars_and_ribs.popupmenu(7) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_spars_and_ribs.up(3),...
                            'units','normalized',...
                            'Position',[0.35 0.3 0.2 0.4],...
                            'tag', 'select_a_rib_add',...
                            'backg',figure_spars_and_ribs.colpb,...
                            'String', ribSegments_string_add,...
                            'Value', 1,...
                            'Visible', 'off',...
                            'callback', {@select_a_rib_add});
                        
rib_add_number = 1;

%----------//**************\\-------------//****************\\-----------                        
% Push button Modify spars
figure_spars_and_ribs.pb(3) = uicontrol('style','push',...
                    'parent', figure_spars_and_ribs.up(3),...
                    'units','normalized',...
                    'position',[0.75 0.1 0.25 0.8],...
                    'backg',figure_spars_and_ribs.colpb,...
                    'tag','Confirm_Modify_spars',...
                    'string','Confirm Modify Spars','callback',{@Confirm_Modify_spars});
 
% Push button Modify Ribs            
figure_spars_and_ribs.pb(6) = uicontrol('style','push',...
                    'parent', figure_spars_and_ribs.up(3),...
                    'units','normalized',...
                    'position',[0.75 0.1 0.25 0.8],...
                    'backg',figure_spars_and_ribs.colpb,...
                    'tag','Confirm_Modify_ribs',...
                    'Visible','off',...
                    'string','Confirm Modify Ribs','callback',{@Confirm_Modify_ribs});
                
                
% Push button Remove spars/ribs
figure_spars_and_ribs.pb(4) = uicontrol('style','push',...
                    'parent', figure_spars_and_ribs.up(3),...
                    'units','normalized',...
                    'position',[0.75 0.1 0.25 0.8],...
                    'backg',figure_spars_and_ribs.colpb,...
                    'tag','Confirm_Remove',...
                    'Visible', 'off',...
                    'string','Confirm Remove spars/ribs','callback',{@Confirm_Remove});
                
% Push button Add spars/ribs
figure_spars_and_ribs.pb(5) = uicontrol('style','push',...
                    'parent', figure_spars_and_ribs.up(3),...
                    'units','normalized',...
                    'position',[0.75 0.1 0.25 0.8],...
                    'backg',figure_spars_and_ribs.colpb,...
                    'tag','Confirm_Add',...
                    'Visible', 'off',...
                    'string','Confirm Add spars/ribs','callback',{@Confirm_Add});

%% uicontrol panel button
% Push button Select
figure_spars_and_ribs.pb(1) = uicontrol('style','push',...
                    'parent', figure_spars_and_ribs.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.5 0.8 0.45],...
                    'backg',figure_spars_and_ribs.colpb,...
                    'tag','Select',...
                    'string','Save All Actions','callback',{@Select});
                
% Push button Cancel
figure_spars_and_ribs.pb(2) = uicontrol('style','push',...
                    'parent', figure_spars_and_ribs.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.05 0.8 0.45],...
                    'backg',figure_spars_and_ribs.colpb,...
                    'tag','Cancel',...
                    'string','Cancel','callback',{@Cancel});
                
handles_sr = guihandles(gcf);
guidata(gcf, handles_sr);

%% uicontrol panel parameters

displayed_sparPosUID = sparSegment1_string{1};
ith_sparPos = find(strcmp(displayed_sparPosUID, spars_geo.positions.uIDs), 1); 

parameters_spars_data = [
    { 'eta', '0-1', spars_geo.positions.eta(ith_sparPos)};
    { 'xsi', '0-1', spars_geo.positions.xsi(ith_sparPos)};
    ];

% create the spars parameters table
figure_spars_and_ribs.table_spars_parameters = uitable('Parent', handles_sr.parameters,...
                            'units','normalized',...
                            'Position',[0.0 0.0 1.0 1.0],...
                            'ColumnName',{'Parameter','Unit','Value'},...
                            'ColumnEditable',[false,false,true],...
                            'ColumnFormat',{'char','char','numeric'},...
                            'RowName',[],...
                            'Data', parameters_spars_data,...
                            'tag', 'table_spars_parameters',...
                            'CellEditCallback',{@table_spars_parameters});
                       
% create handle for this table
h = findobj('tag','table_spars_parameters');
handles_sr.table_spars_parameters = h;

% adapt width columns of the tables
set(handles_sr.table_spars_parameters, 'Units', 'pixels');
parameters_position = get(handles_sr.table_spars_parameters, 'Position');
set(handles_sr.table_spars_parameters, 'ColumnWidth', {floor(parameters_position(3)*0.55),floor(parameters_position(3)*0.15),floor(parameters_position(3)*0.25)});
set(handles_sr.table_spars_parameters, 'Units', 'normalized');
                        
%------------------------------------------------------------------------
% Table ribs parameters
displayed_ribUID = ribSegments_string{1};
ith_ribPos = find(strcmp(displayed_ribUID, ribs_geo.uIDs), 1); 

parameters_ribs_data = [
    { 'rib reference', '', ribs_geo.ribReference{ith_ribPos}};
    { 'eta start', '0-1', ribs_geo.etaStart(ith_ribPos)};
    { 'eta end', '0-1', ribs_geo.etaEnd(ith_ribPos)};
    { 'rib start', '', ribs_geo.ribStart{ith_ribPos}};
    { 'rib end', '', ribs_geo.ribEnd{ith_ribPos}};
    { 'rib rotation reference', '', ribs_geo.ribRotationReference{ith_ribPos}};
    { 'rib rotation x', '', ribs_geo.rotx(ith_ribPos)};
    { 'rib rotation z', '', ribs_geo.rotz(ith_ribPos)};
    { 'number of ribs', '', ribs_geo.numberOfRibs(ith_ribPos)};
    ];

figure_spars_and_ribs.table_ribs_parameters = uitable('Parent', handles_sr.parameters,...
                            'units','normalized',...
                            'Position',[0.0 0.0 1.0 1.0],...
                            'ColumnName',{'Parameter','Unit','Value'},...
                            'ColumnEditable',[false,false,true],...
                            'ColumnFormat',{'char','char','numeric'},...
                            'RowName',[],...
                            'Data', parameters_ribs_data,...
                            'tag', 'table_ribs_parameters',...
                            'Visible', 'off',...
                            'CellSelectionCallback',{@selection_ribs},...
                            'CellEditCallback',{@table_ribs_parameters});
                       
% create handle for this table
h = findobj('tag','table_ribs_parameters');
handles_sr.table_ribs_parameters = h;

% adapt width columns of the tables
set(handles_sr.table_ribs_parameters, 'Units', 'pixels');
parameters_position = get(handles_sr.table_ribs_parameters, 'Position');
set(handles_sr.table_ribs_parameters, 'ColumnWidth', {floor(parameters_position(3)*0.55),floor(parameters_position(3)*0.15),floor(parameters_position(3)*0.25)});
set(handles_sr.table_ribs_parameters, 'Units', 'normalized');

% draw spars and ribs
addMode_index = 0; 
Draw_spars_and_ribs_all(spaRib_struct, addMode_index)

msgbox('Please press the ''Confirm Modify/Add/Remove'' button in order to save the changes made at each step.In the end, press the.''Save All Actions'' to save all the changes made','Attention Please', 'warn','modal');

end

function Draw_spars_and_ribs_all(sparsRibs_struct, addMode_index)
global handles_sr 
global spars_or_ribs_number spar_number spar_position_number   rib_number 
global spar_position_add_number  rib_add_number 

cam_pos_1 = get(handles_sr.axes_1, 'CameraPosition');            % current camera position
cla

[Spar_segments, rib_cell, Wings, sparsRibs_geo] = spars_ribs6_add(sparsRibs_struct);
[vertices_ribs, facets_ribs, vertices_spars, facets_spars] = sparRibs2triangles(Spar_segments, rib_cell, 0);

%----------------Draw----------------
if spars_or_ribs_number == 1          % spars_selected
    spar_color = 'g';
    rib_color = 'k';
elseif spars_or_ribs_number == 2      % ribs_selected
    spar_color = 'k';
    rib_color = 'g';  
end

axes(handles_sr.axes_1)
patch('Vertices', vertices_spars, 'Faces', facets_spars,'EdgeColor',spar_color,'FaceColor', 'none');
hold on
patch('Vertices', vertices_ribs, 'Faces', facets_ribs,'EdgeColor',rib_color, 'FaceColor', 'none');
hold on

        
if spars_or_ribs_number == 1          % spars_selected
    
    if addMode_index == 0
        spar_position_highlighted = spar_position_number;
    elseif addMode_index == 1
        spar_position_highlighted = spar_position_add_number;
    end
    
   [vertices_spar_red, facets_spar_red, vertices_sparPosition_cyan] = spar_highlighted(Spar_segments,  spar_number, spar_position_highlighted);
   
    axes(handles_sr.axes_1)
    patch('Vertices', vertices_spar_red, 'Faces', facets_spar_red,'EdgeColor','r', 'FaceColor', 'none')
    hold on
    line('XData',vertices_sparPosition_cyan(:,1),'YData',vertices_sparPosition_cyan(:,2),'ZData',vertices_sparPosition_cyan(:,3), 'Color','c','LineWidth',2);
    hold on
    
 elseif spars_or_ribs_number == 2      % ribs_selected
     if addMode_index == 0
         rib_index = rib_number;
     elseif addMode_index == 1
         rib_index = rib_add_number;
     end
     
   [vertices_rib_red, facets_rib_red] = rib_highlighted(rib_cell, rib_index);
    axes(handles_sr.axes_1)
    patch('Vertices', vertices_rib_red, 'Faces', facets_rib_red,'EdgeColor','r', 'FaceColor', 'none')
    hold on
end

%------------Other Settings--------------
set(get(handles_sr.axes_1, 'xlabel'),'String','X')
set(get(handles_sr.axes_1, 'ylabel'),'String','Y')
set(get(handles_sr.axes_1, 'zlabel'),'String','Z')

set(handles_sr.axes_1, 'DataAspectRatio',[1 1 1]);

set(handles_sr.axes_1, 'CameraPosition', cam_pos_1);
grid(handles_sr.axes_1, 'on')
rotate3d(handles_sr.axes_1, 'on')
        
end

function [vertices_spar_red, facets_spar_red, vertices_sparPosition_cyan] = spar_highlighted(Spar_segments,  spar_number, spar_position_number)
%---------------selected spar in red-------------------%
num_sparPosition = length(Spar_segments{spar_number}.cross_profile);

vertices_spar_red = zeros(num_sparPosition*2,3);
facets_spar_red = zeros(num_sparPosition - 1, 4);
i = 1;
m = 0;

for j = 1:num_sparPosition
    vertices_spar_red(i:i+1, :) = [Spar_segments{spar_number}.sup(j,:);
        Spar_segments{spar_number}.inf(j,:)];
    
    if j > 1
        m = m+1;
        facets_spar_red(m,:) = [i-2, i-1, i+1, i];       
    end
    
    %------------------selected sparPosition in Cyan-------------%
    if j == spar_position_number
        vertices_sparPosition_cyan = vertices_spar_red(i:i+1, :);
    end
    
    i = i + 2;
end
%--------------------------------------------------------%
%--------------------------------------------------------%
end

function [vertices_rib_red, facets_rib_red] = rib_highlighted(rib_cell, rib_number)
    num_ribCell = rib_cell{rib_number}.ribs_number_cell; 

    vertices_rib_red = cell(num_ribCell,1);
    facets_rib_red = zeros(num_ribCell, 4);
        i = 0;
        for k = 1: rib_cell{rib_number}.ribs_number_cell
            i = i+1;
            vertices_rib_red{i,1} = [rib_cell{rib_number}.front_rib_sup{k};
                rib_cell{rib_number}.front_rib_inf{k};
                rib_cell{rib_number}.rear_rib_inf{k};
                rib_cell{rib_number}.rear_rib_sup{k}];
            
            facets_rib_red(k,:) = [(i-1)*4 + 1, (i-1)*4 + 2, (i-1)*4 + 3, (i-1)*4 + 4];
        end
    
    vertices_rib_red = cell2mat(vertices_rib_red);
    
end

function [] = table_spars_parameters(varargin)
global handles_sr srStruct  
global spar_number   spar_position_number  spar_position_add_number

event = varargin{2};

if get(handles_sr.mode_add, 'Value')        % if add_mode is on
   sparPos_index = spar_position_add_number; 
else
   sparPos_index = spar_position_number;
end

%%% get the name of the spar position
list_spar_positions = get(handles_sr.select_a_spar_position, 'String');
displayed_sparPosUID = list_spar_positions{sparPos_index};

%--------------------------------------------------
[sparsRibsgeo] = sparsRibs_struct2geo(srStruct); 
%--------------------------------------------------

spar_position = find(strcmp(sparsRibsgeo.spars.positions.uIDs, displayed_sparPosUID));

if sparPos_index == 1
    next_sparPosUID = list_spar_positions{sparPos_index+1};
    next_sparPos = strcmp(sparsRibsgeo.spars.positions.uIDs, next_sparPosUID);
    next_eta = sparsRibsgeo.spars.positions.eta(next_sparPos);
    
    lower_limit = 0;
    upper_limit = next_eta;
elseif sparPos_index == length(list_spar_positions)
    prev_sparPosUID = list_spar_positions{sparPos_index-1};
    prev_sparPos = strcmp(sparsRibsgeo.spars.positions.uIDs, prev_sparPosUID);
    prev_eta = sparsRibsgeo.spars.positions.eta(prev_sparPos);
    
    lower_limit = prev_eta;
    upper_limit = 1;
else
    prev_sparPosUID = list_spar_positions{sparPos_index-1};
    prev_sparPos = strcmp(sparsRibsgeo.spars.positions.uIDs, prev_sparPosUID);
    prev_eta = sparsRibsgeo.spars.positions.eta(prev_sparPos);
    next_sparPosUID = list_spar_positions{sparPos_index+1};
    next_sparPos = strcmp(sparsRibsgeo.spars.positions.uIDs, next_sparPosUID);
    next_eta = sparsRibsgeo.spars.positions.eta(next_sparPos);
    
    lower_limit = prev_eta;
    upper_limit = next_eta;
end

spars_parameters_data = get(handles_sr.table_spars_parameters, 'Data');     % get the spars_parameters_data
if event.Indices(1) == 1                                                               % if eta in the spar_parameter table being changed...
    eta = event.NewData;
    
    if eta < lower_limit
        errordlg('input value too small');
        adjust_tables(srStruct, handles_sr);
        return;
    elseif eta > upper_limit
        errordlg('input value too big');
        adjust_tables(srStruct, handles_sr);
        return;
    end
    
    spars_parameters_data(1,3) = num2cell(eta);
    srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{1, spar_position}.eta{1,1}.CONTENT = num2str(eta);
end

if event.Indices(1) == 2
    xsi = event.NewData;
    if xsi < 0
        xsi = 0;
    elseif xsi > 1
        xsi = 1;
    end
    spars_parameters_data(2,3) = num2cell(xsi);
    srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{1, spar_position}.xsi{1,1}.CONTENT = num2str(xsi);
end

set(handles_sr.table_spars_parameters, 'Data', spars_parameters_data);

if get(handles_sr.mode_add, 'Value')  
    addMode = 1;
else
    addMode = 0;
end

Draw_spars_and_ribs_all(srStruct, addMode)
end

function [] = table_ribs_parameters(varargin)
global handles_sr srStruct  rib_number  rib_add_number

event = varargin{2};
ribs_parameters_data = get(handles_sr.table_ribs_parameters, 'Data');    % get the ribs parameters data

if get(handles_sr.mode_add, 'Value')        % if add_mode is on
   rib_index = rib_add_number; 
else
   rib_index = rib_number;  
end
    
switch event.Indices(1)                  
    case 2                              % eta start
        eta_start = event.NewData;
        if eta_start < 0
            eta_start = 0;
        elseif eta_start > 1
            eta_start = 1;
        end
        ribs_parameters_data(2,3) = num2cell(eta_start);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{rib_index}.ribsPositioning{1,1}.etaStart{1,1}.CONTENT = num2str(eta_start); 
        
    case 3                              % eta end
        eta_end = event.NewData;
        if eta_end < 0
            eta_end = 0;
        elseif eta_end > 1
            eta_end = 1;
        end
        ribs_parameters_data(3,3) = num2cell(eta_end);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{rib_index}.ribsPositioning{1,1}.etaEnd{1,1}.CONTENT = num2str(eta_end); 

    case 7                             % rib rotation x
        ribs_parameters_data(7,3) = num2cell(event.NewData);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{rib_index}.ribsPositioning{1,1}.ribRotation{1,1}.x{1,1}.CONTENT = num2str(event.NewData); 
    case 8                             % rib rotation z
        ribs_parameters_data(8,3) = num2cell(event.NewData);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{rib_index}.ribsPositioning{1,1}.ribRotation{1,1}.z{1,1}.CONTENT = num2str(event.NewData); 
    case 9                             % number of ribs
        ribs_parameters_data(9,3) = num2cell(event.NewData);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{rib_index}.ribsPositioning{1,1}.numberOfRibs{1,1}.CONTENT = num2str(event.NewData); 
end

set(handles_sr.table_ribs_parameters, 'Data', ribs_parameters_data);

if get(handles_sr.mode_add, 'Value')  
    addMode = 1;
else
    addMode = 0;
end

Draw_spars_and_ribs_all(srStruct,addMode)

end

function [] = selection_ribs(varargin)
global handles_sr srStruct rib_number  rib_add_number

event = varargin{2};
ribs_parameters_data = get(handles_sr.table_ribs_parameters, 'Data');

if numel(event.Indices)== 0
    return;
end

if get(handles_sr.mode_add, 'Value')        % if add_mode is on
   rib_index = rib_add_number; 
else
   rib_index = rib_number;  
end

num_sparSeg = length(srStruct.spars{1,1}.sparSegments{1,1}.sparSegment);
sparSegment_uIDs = cell(1,num_sparSeg); 
for i = 1 : num_sparSeg 
    sparSegment_uIDs{i} = srStruct.spars{1,1}.sparSegments{1,1}.sparSegment{1,i}.ATTRIBUTE.uID; 
end 

switch event.Indices(1)
    case 1             % rib reference        
        LETE_string ={'leadingEdge','trailingEdge'};
        ref_bounders = [LETE_string, sparSegment_uIDs]; 
        [selection,ok] = listdlg('ListString',ref_bounders,...
            'InitialValue',[],'ListSize',[300,100],'PromptString',...
            'Choose the rib reference','Name','rib reference',...
            'SelectionMode','Single','CancelString','Exit');
        if ok == 0
            return
        end
        ribs_parameters_data(1,3) = ref_bounders(selection);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{1,rib_index}.ribsPositioning{1,1}.ribReference{1,1}.CONTENT = ref_bounders{selection};
        
    case 4            % rib start
        LE_string ={'leadingEdge';};
        ref_bounders = [LE_string, sparSegment_uIDs]; 
        [selection,ok] = listdlg('ListString',ref_bounders,...
            'InitialValue',[],'ListSize',[300,100],'PromptString',...
            'Choose the rib start','Name','rib start',...
            'SelectionMode','Single','CancelString','Exit');
        if ok == 0
            return
        end
        ribs_parameters_data(4,3) = ref_bounders(selection);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{1,rib_index}.ribsPositioning{1,1}.ribStart{1,1}.CONTENT = ref_bounders{selection};
        
    case 5             % rib end
        TE_string ={'trailingEdge';};
        ref_bounders = [TE_string, sparSegment_uIDs]; 
        [selection,ok] = listdlg('ListString',ref_bounders,...
            'InitialValue',[],'ListSize',[300,100],'PromptString',...
            'Choose the rib end','Name','rib end',...
            'SelectionMode','Single','CancelString','Exit');       
        if ok == 0
            return
        end        
        ribs_parameters_data(5,3) = ref_bounders(selection);
         srStruct.ribsDefinitions{1,1}.ribsDefinition{1,rib_index}.ribsPositioning{1,1}.ribEnd{1,1}.CONTENT = ref_bounders{selection};
         
    case 6         % rib rotation referrence
        rot_string ={'globalY', 'leadingEdge','trailingEdge'};
        rot_ref =  [rot_string, sparSegment_uIDs]; 
        [selection,ok] = listdlg('ListString',rot_ref,...
            'InitialValue',[],'ListSize',[300,100],'PromptString',...
            'Choose the rib end','Name','rib end',...
            'SelectionMode','Single','CancelString','Exit');       
        if ok == 0
            return
        end
        ribs_parameters_data(6,3) =  rot_ref(selection);
        srStruct.ribsDefinitions{1,1}.ribsDefinition{1,rib_index}.ribsPositioning{1,1}.ribRotation{1,1}.ribRotationReference{1,1}.CONTENT = rot_ref{selection};
        
    otherwise
        return
end

set(handles_sr.table_ribs_parameters, 'Data', ribs_parameters_data);
Draw_spars_and_ribs_all(srStruct, 0)
end

%% functions callback corresponding to buttons
function [] = Select(varargin)
global handles_sr stage_srStruct  final_srStruct

final_srStruct = stage_srStruct;
close(handles_sr.figure_spars_and_ribs)
end

function [] = Cancel (varargin)
global handles_sr

message = strcat('Do you really want to close this window and lose all the modifications ? ');
choice = questdlg(message, 'Cancel', 'Yes', 'No', 'No');

switch choice
    case 'Yes'        
        close(handles_sr.figure_spars_and_ribs)
        
    case 'No'
        return;
end
end

function [] = Confirm_Modify_spars(varargin)
global handles_sr srStruct stage_srStruct 
global spars_or_ribs_number  spar_position_number 

if spars_or_ribs_number == 1      % spars
    list_spar_positions = get(handles_sr.select_a_spar_position, 'String');
    spar_position = list_spar_positions{spar_position_number};    
    % create a question box
    message = strcat('Do you want to modify the spar position: ', spar_position, ' ?');
    choice = questdlg(message, 'Modify function', 'Yes', 'No', 'No');
    switch choice
        case 'Yes'     
            srStruct.change = srStruct.change + 1; 
            stage_srStruct = srStruct;
        case 'No'
            return
    end
end
end

function [] = Confirm_Modify_ribs(varargin)
global handles_sr srStruct stage_srStruct  
global  rib_number spars_or_ribs_number

if spars_or_ribs_number == 2    % ribs
    list_ribs_definitions = get(handles_sr.select_a_rib, 'String');
    ribs_definition = list_ribs_definitions{rib_number};
    % create a question box
    message = strcat('Do you want to modify the section ', ribs_definition, ' ?');
    choice = questdlg(message, 'Modify function', 'Yes', 'No', 'No');
    
    switch choice
        case 'Yes'
            srStruct.change = srStruct.change + 1; 
            stage_srStruct = srStruct;
        case 'No'
            return
    end
end
end

function [] = Confirm_Remove(varargin)
global handles_sr stage_srStruct srStruct
global spars_or_ribs_number spar_number spar_position_number   rib_number  
global rib_add_number  spar_position_add_number

switch spars_or_ribs_number
    case  1                  % spars
        spar_position_string = get(handles_sr.select_a_spar_position, 'String');
        spar_position_name = spar_position_string{spar_position_number};
        
        message = strcat('Do you want to remove the spar position', spar_position_name, ' ?');
        choice = questdlg(message, 'Remove function', 'Yes', 'No', 'No');
        switch choice
            case 'Yes'
          
                %--------------------------------------------------
                [sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
                %--------------------------------------------------                
                local_spar_position = strcmp(sparsRibsgeo.spars.positions.uIDs, spar_position_name);
                srStruct.spars{1,1}.sparPositions{1,1}.sparPosition(local_spar_position) = []; 
                
                local_positionSeg = strcmp(sparsRibsgeo.spars.segments.positions{spar_number}, spar_position_name);
                srStruct.spars{1,1}.sparSegments{1,1}.sparSegment{spar_number}.sparPositionUIDs{1,1}.sparPositionUID(local_positionSeg)=[]; 
               
                %--------------------------------------------------
                [sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
                %--------------------------------------------------      
                
                new_sparPositions_string = sparsRibsgeo.spars.segments.positions{spar_number};
                set(handles_sr.select_a_spar_position, 'String', new_sparPositions_string);
                set(handles_sr.select_a_spar_position, 'Value', 1);             
                spar_position_number = 1;
                
                num_sparPositions = length(new_sparPositions_string);
                sparPositions_string_add = cell(1,num_sparPositions+1);
                for i=1:num_sparPositions+1
                    if i == 1
                        add_string = strcat('before ',new_sparPositions_string{1});
                    elseif i == num_sparPositions+1
                        add_string = strcat('after ',new_sparPositions_string{end});
                    else
                        add_string = strcat('between', new_sparPositions_string{i-1}, ' and ', new_sparPositions_string{i});
                    end
                    sparPositions_string_add{i} = add_string;
                end
                set(handles_sr.select_a_spar_position_add, 'String', sparPositions_string_add);
               
                set(handles_sr.select_a_spar_position_add, 'Value', 1);
                spar_position_add_number = 1; 

                adjust_tables(srStruct, handles_sr)
                Draw_spars_and_ribs_all(srStruct, 0)
                
                srStruct.change = srStruct.change + 1; 
                stage_srStruct = srStruct;
            case 'No'
                return;
        end
    case 2                    % ribs
        rib_string = get(handles_sr.select_a_rib, 'String');
        rib_name = rib_string{rib_number};
        
        message = strcat('Do you want to remove the spar ', rib_name, ' ?');
        choice = questdlg(message, 'Remove function', 'Yes', 'No', 'No');
        switch choice
            case 'Yes'                  
                
                srStruct.ribsDefinitions{1,1}.ribsDefinition(rib_number) = []; 
                %--------------------------------------------------
                [sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
                %--------------------------------------------------      
                
                new_ribSegments_string = sparsRibsgeo.ribsDefinitions.uIDs;
                number_of_ribs = length(new_ribSegments_string);
                
                ribSegments_string_add = cell(1, number_of_ribs + 1);
                
                for i = 1 : number_of_ribs + 1
                    if i == 1
                        add_string = strcat('before ',new_ribSegments_string{1});
                    elseif i == number_of_ribs + 1
                        add_string = strcat('after ',new_ribSegments_string{end});
                    else
                        add_string = strcat('between ', new_ribSegments_string{i-1}, ' and ', new_ribSegments_string{i});
                    end
                    ribSegments_string_add{i} = add_string;
                end
                
                set(handles_sr.select_a_rib, 'String', new_ribSegments_string);
                if rib_number == number_of_ribs + 1
                    rib_number = rib_number - 1; 
                end                
                set(handles_sr.select_a_rib, 'Value', rib_number);
                 
                %------------------------
                
                set(handles_sr.select_a_rib_add, 'String', ribSegments_string_add);
%                 set(handles_sr.select_a_rib_add, 'Value', 1);
%                 rib_add_number = 1;
                
                adjust_tables(srStruct, handles_sr, rib_number)
                Draw_spars_and_ribs_all(srStruct, 0)
                
                srStruct.change = srStruct.change + 1; 
                stage_srStruct = srStruct;
            case 'No'
                return;
        end
end

end

function [] = Confirm_Add(varargin)
global handles_sr  srStruct stage_srStruct
global spars_or_ribs_number spar_number rib_add_number spar_position_add_number

switch spars_or_ribs_number
    case 1
        add_sparsPos_strings = get(handles_sr.select_a_spar_position_add, 'String');
        add_sparPos = add_sparsPos_strings{spar_position_add_number};       
        message = strcat('Do you want to add a spar position between ', add_sparPos,' ?');
        choice = questdlg(message, 'Add function', 'Yes', 'No', 'No');
        
        switch choice
            case 'Yes'                
                srStruct.change = srStruct.change + 1; 
                stage_srStruct = srStruct;               
                %--------------------------------------------------
                [sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
                %--------------------------------------------------   
                
                sparPositions_string = sparsRibsgeo.spars.segments.positions{spar_number}; 
                set(handles_sr.select_a_spar_position, 'String', sparPositions_string);
                
                num_sparPositions = length(sparPositions_string);
                sparPositions_string_add = cell(1,num_sparPositions+1);
                for i=1:num_sparPositions+1
                    if i == 1
                        add_string = strcat('before ',sparPositions_string{1});
                    elseif i == num_sparPositions+1
                        add_string = strcat('after ',sparPositions_string{end});
                    else
                        add_string = strcat('between', sparPositions_string{i-1}, ' and ', sparPositions_string{i});
                    end
                    sparPositions_string_add{i} = add_string;
                end
                set(handles_sr.select_a_spar_position_add, 'String', sparPositions_string_add);
                
            case 'No'
                return
        end
        
    case 2       
        rib_definition_string = get(handles_sr.select_a_rib_add, 'String');
        added_rib = rib_definition_string{rib_add_number};
        message = strcat('Do you want to add a rib definition between ', added_rib,' ?');
        choice = questdlg(message, 'Add function', 'Yes', 'No', 'No');
        
        switch choice
            case 'Yes'
                srStruct.change = srStruct.change + 1;
                stage_srStruct = srStruct;
                
                %--------------------------------------------------
                [sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
                %--------------------------------------------------  
                
                ribSegments_string = sparsRibsgeo.ribsDefinitions.uIDs;
                set(handles_sr.select_a_rib, 'String',  ribSegments_string);
                
                number_of_ribs_definition = length(ribSegments_string);
                ribs_string_add = cell(1,number_of_ribs_definition + 1);
                for i = 1 : number_of_ribs_definition+1
                    if i == 1
                        add_string = strcat('before ',ribSegments_string{1});
                    elseif i == number_of_ribs_definition + 1
                        add_string = strcat('after ',ribSegments_string{end});
                    else
                        add_string = strcat('between', ribSegments_string{i-1}, ' and ', ribSegments_string{i});
                    end
                    ribs_string_add{i} = add_string;
                end
                
                set(handles_sr.select_a_rib_add, 'String',  ribs_string_add);
                
            case 'No'
                return
        end
        
end

end

%% functions callback corresponding to checkboxes
function [] = mode_modify(varargin)
global handles_sr stage_srStruct srStruct
global spars_or_ribs_number  rib_number

srStruct = stage_srStruct;

set(handles_sr.mode_modify, 'Value',1);
set(handles_sr.mode_add, 'Value',0);
set(handles_sr.mode_remove, 'Value',0);

set(handles_sr.Confirm_Remove, 'Visible', 'off');
set(handles_sr.Confirm_Add, 'Visible', 'off');

%-----------------------------
set(handles_sr.select_a_rib_add, 'Visible', 'off');
set(handles_sr.select_a_spar_position_add, 'Visible', 'off');
%----------------------------

if spars_or_ribs_number == 1
    set(handles_sr.Confirm_Modify_spars, 'Visible', 'on');
    set(handles_sr.select_a_spar_position, 'Visible', 'on');
    set(handles_sr.select_a_rib, 'Visible', 'off');
    adjust_tables(srStruct, handles_sr)  
elseif spars_or_ribs_number ==2
    set(handles_sr.Confirm_Modify_ribs, 'Visible', 'on');
    set(handles_sr.select_a_rib, 'Visible', 'on');
    set(handles_sr.select_a_spar_position, 'Visible', 'off');
    adjust_tables(srStruct, handles_sr, rib_number)  
end
set(handles_sr.spars_and_ribs_modification, 'Title', 'Modify spars and ribs');

end

function [] = mode_remove(varargin)
global handles_sr stage_srStruct srStruct
global spars_or_ribs_number 

srStruct = stage_srStruct;

set(handles_sr.mode_modify, 'Value',0);
set(handles_sr.mode_add, 'Value',0);
set(handles_sr.mode_remove, 'Value',1);

set(handles_sr.Confirm_Modify_spars, 'Visible', 'off');
set(handles_sr.Confirm_Modify_ribs, 'Visible', 'off');
set(handles_sr.Confirm_Remove, 'Visible', 'on');
set(handles_sr.Confirm_Add, 'Visible', 'off');

%--------------------
set(handles_sr.select_a_rib_add, 'Visible', 'off');
set(handles_sr.select_a_spar_position_add, 'Visible', 'off');
%--------------------

if spars_or_ribs_number == 1
    set(handles_sr.select_a_spar_position, 'Visible', 'on');
    set(handles_sr.select_a_rib, 'Visible', 'off');
elseif spars_or_ribs_number ==2
    set(handles_sr.select_a_rib, 'Visible', 'on');
    set(handles_sr.select_a_spar_position, 'Visible', 'off');
end
set(handles_sr.spars_and_ribs_modification, 'Title', 'Remove spars and ribs');

set(handles_sr.table_spars_parameters, 'Visible', 'off');
set(handles_sr.table_ribs_parameters, 'Visible', 'off');

end

function [] = mode_add(varargin)
global handles_sr stage_srStruct srStruct 
global spars_or_ribs_number  rib_number

srStruct = stage_srStruct;

set(handles_sr.mode_modify, 'Value',0);
set(handles_sr.mode_add, 'Value',1);
set(handles_sr.mode_remove, 'Value',0);

set(handles_sr.Confirm_Modify_spars, 'Visible', 'off');
set(handles_sr.Confirm_Modify_ribs, 'Visible', 'off');
set(handles_sr.Confirm_Remove, 'Visible', 'off');
set(handles_sr.Confirm_Add, 'Visible', 'on');

%---------------------------
set(handles_sr.select_a_rib, 'Visible', 'off');
set(handles_sr.select_a_spar_position, 'Visible', 'off');
%---------------------------

if spars_or_ribs_number == 1
    set(handles_sr.select_a_spar_position_add, 'Visible', 'on');
    set(handles_sr.select_a_rib_add, 'Visible', 'off');
    adjust_tables(srStruct, handles_sr)
elseif spars_or_ribs_number == 2
    set(handles_sr.select_a_rib_add, 'Visible', 'on');
    set(handles_sr.select_a_spar_position_add, 'Visible', 'off');
    adjust_tables(srStruct, handles_sr, rib_number)  
end

set(handles_sr.spars_and_ribs_modification, 'Title', 'Add spars and ribs');

end

%% function callback corresponding to popup menus
function [] = select_spars_or_ribs(varargin)
global handles_sr srStruct stage_srStruct
global spars_or_ribs_number     % spar_number  spar_position_number
global rib_number   % rib_add_number 

srStruct = stage_srStruct;
spars_or_ribs_number  = get(handles_sr.select_spars_or_ribs, 'Value');

mode_add_value = get(handles_sr.mode_add, 'Value');

if spars_or_ribs_number == 1          % spars    
    set(handles_sr.select_a_spar, 'Visible', 'on');
    if mode_add_value == 1
        set(handles_sr.select_a_spar_position_add, 'Visible', 'on');
        set(handles_sr.select_a_spar_position, 'Visible', 'off');
    else
        set(handles_sr.select_a_spar_position_add, 'Visible', 'off');
        set(handles_sr.select_a_spar_position, 'Visible', 'on');   
        set(handles_sr.Confirm_Modify_spars, 'Visible', 'on');
        set(handles_sr.Confirm_Modify_ribs, 'Visible', 'off');
    end
    set(handles_sr.select_a_rib, 'Visible', 'off');
    set(handles_sr.select_a_rib_add, 'Visible', 'off');
    
    adjust_tables(srStruct, handles_sr)       
    
elseif spars_or_ribs_number == 2            % ribs
    set(handles_sr.select_a_spar, 'Visible', 'off');
    set(handles_sr.select_a_spar_position, 'Visible', 'off');
    set(handles_sr.select_a_spar_position_add, 'Visible', 'off');
    if mode_add_value == 1
        set(handles_sr.select_a_rib_add, 'Visible', 'on');
        set(handles_sr.select_a_rib, 'Visible', 'off');
        
    else
        set(handles_sr.select_a_rib_add, 'Visible', 'off');
        set(handles_sr.select_a_rib, 'Visible', 'on');
        set(handles_sr.Confirm_Modify_spars, 'Visible', 'off');
        set(handles_sr.Confirm_Modify_ribs, 'Visible', 'on');
    end
    adjust_tables(srStruct, handles_sr, rib_number)
end

 Draw_spars_and_ribs_all(srStruct, 0)
 
end

function [] = select_a_spar(varargin)
global handles_sr srStruct stage_srStruct 
global spar_number     spar_position_number  spar_position_add_number

srStruct = stage_srStruct;
spar_number = get(handles_sr.select_a_spar, 'Value');

%--------------------------------------------------
[sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
%--------------------------------------------------
sparSegment_positions = sparsRibsgeo.spars.segments.positions{spar_number};
set(handles_sr.select_a_spar_position, 'String', sparSegment_positions);
set(handles_sr.select_a_spar_position, 'Value', 1);
spar_position_number = 1; 
%--------------------------------------------------
num_sparPositions = length(sparSegment_positions);
sparPositions_string_add = cell(1,num_sparPositions+1);
for i=1:num_sparPositions+1
    if i == 1
        add_string = strcat('before ',sparSegment_positions{1});
    elseif i == num_sparPositions+1
        add_string = strcat('after ',sparSegment_positions{end});
    else
        add_string = strcat('between', sparSegment_positions{i-1}, ' and ', sparSegment_positions{i});
    end
    sparPositions_string_add {i} = add_string;
end
set(handles_sr.select_a_spar_position_add, 'String',  sparPositions_string_add );
set(handles_sr.select_a_spar_position_add, 'Value', 1);
spar_position_add_number = 1; 
%-------------------------------------------------------

Draw_spars_and_ribs_all(srStruct, 0)
adjust_tables(srStruct, handles_sr)

end

function [] = select_a_rib(varargin)
global handles_sr 
global srStruct stage_srStruct 
global rib_number

srStruct = stage_srStruct;
rib_number = get(handles_sr.select_a_rib, 'Value');

Draw_spars_and_ribs_all(srStruct, 0)
adjust_tables(srStruct, handles_sr, rib_number);
end

function [] = select_a_spar_position(varargin)

global handles_sr 
global srStruct stage_srStruct 
global spar_position_number

srStruct = stage_srStruct;
spar_position_number = get(handles_sr.select_a_spar_position, 'Value');         

adjust_tables(srStruct, handles_sr);
Draw_spars_and_ribs_all(srStruct, 0)

end

function [] = select_a_rib_add(varargin)
global handles_sr srStruct stage_srStruct rib_add_number

srStruct = stage_srStruct;
rib_add_number = get(handles_sr.select_a_rib_add, 'Value');

%----------------------
add_spars_and_ribs(2)
adjust_tables(srStruct, handles_sr, rib_add_number)
%----------------------

Draw_spars_and_ribs_all(srStruct, 1)

end

function [] = select_a_spar_position_add(varargin)
global handles_sr srStruct stage_srStruct spar_position_add_number  spar_number

srStruct = stage_srStruct;
spar_position_add_number = get(handles_sr.select_a_spar_position_add, 'Value');

%-----------------------
add_spars_and_ribs(1)      % a new sparPosition was added to the end of sparPositions; therefore its eta xsi should be displayed;

%--------------------------------------------------
[sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
%--------------------------------------------------

newsparPositions_string = sparsRibsgeo.spars.segments.positions{spar_number};
set(handles_sr.select_a_spar_position, 'String', newsparPositions_string);

adjust_tables(srStruct, handles_sr)
%-----------------------

Draw_spars_and_ribs_all(srStruct, 1)

end

%% others functions
function [] = adjust_tables(srStruct, handles_sr, varargin)      
switch nargin
    case 2
        if get(handles_sr.mode_add, 'Value')        % if add_mode is on
            value = get(handles_sr.select_a_spar_position_add, 'Value');
            list_spar_positions = get(handles_sr.select_a_spar_position, 'String');
            spar_position = list_spar_positions{value};
        else
            value = get(handles_sr.select_a_spar_position, 'Value');
            list_spar_positions = get(handles_sr.select_a_spar_position, 'String');
            spar_position = list_spar_positions{value};
        end 
        %--------------------------------------------------
        [sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
        %--------------------------------------------------
        
        local_spar_position = find(strcmp(sparsRibsgeo.spars.positions.uIDs, spar_position));
        parameters_spars_data = [
            { 'eta', '0-1', sparsRibsgeo.spars.positions.eta(local_spar_position)};
            { 'xsi', '0-1', sparsRibsgeo.spars.positions.xsi(local_spar_position)};
            ];
        set(handles_sr.table_spars_parameters, 'Data', parameters_spars_data);

        if get(handles_sr.mode_remove, 'Value')
            set(handles_sr.table_spars_parameters, 'Visible', 'off');
            set(handles_sr.table_ribs_parameters, 'Visible', 'off');
        else
            set(handles_sr.table_spars_parameters, 'Visible', 'on');
            set(handles_sr.table_ribs_parameters, 'Visible', 'off');
        end
        
    case 3
        rib_number = varargin{1};
        %--------------------------------------------------
        [sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
        %--------------------------------------------------
        parameters_ribs_data = [
            { 'rib reference', '', sparsRibsgeo.ribsDefinitions.ribReference{rib_number}};
            { 'eta start', '0-1', sparsRibsgeo.ribsDefinitions.etaStart(rib_number)};
            { 'eta end', '0-1', sparsRibsgeo.ribsDefinitions.etaEnd(rib_number)};
            { 'rib start', '', sparsRibsgeo.ribsDefinitions.ribStart{rib_number}};
            { 'rib end', '', sparsRibsgeo.ribsDefinitions.ribEnd{rib_number}};
            { 'rib rotation reference', '', sparsRibsgeo.ribsDefinitions.ribRotationReference{rib_number}};
            { 'rib rotation x', '', sparsRibsgeo.ribsDefinitions.rotx(rib_number)};
            { 'rib rotation z', '', sparsRibsgeo.ribsDefinitions.rotz(rib_number)};
            { 'number of ribs', '', sparsRibsgeo.ribsDefinitions.numberOfRibs(rib_number)};
            ];
        
        set(handles_sr.table_ribs_parameters, 'Data', parameters_ribs_data);
        
        if get(handles_sr.mode_remove, 'Value')
            set(handles_sr.table_spars_parameters, 'Visible', 'off');
            set(handles_sr.table_ribs_parameters, 'Visible', 'off');
        else
            set(handles_sr.table_spars_parameters, 'Visible', 'off');
            set(handles_sr.table_ribs_parameters, 'Visible', 'on');
        end
        
end

end

function [] = add_spars_and_ribs(spar_or_rib_index)
global srStruct                                    % handles_sr
global spar_number rib_add_number spar_position_add_number

%--------------------------------------------------
[sparsRibsgeo] = sparsRibs_struct2geo(srStruct);
%--------------------------------------------------

switch spar_or_rib_index
    case 1                             % new spar position        
        prompt = {'Enter uID for the added Spar Position:'};
        dlg_title = 'Input';
        num_lines = 1;
        def = {'test_spar_pos'};
        added_uID = inputdlg(prompt,dlg_title,num_lines,def);
   
        if ~isempty(added_uID )
            spar_refIdx = length(srStruct.spars{1,1}.sparPositions{1,1}.sparPosition);
            srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{spar_refIdx+1}.ATTRIBUTE.uID = added_uID{1};
 
            if spar_position_add_number == 1
                srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{spar_refIdx+1}.eta{1,1}.CONTENT = num2str(0) ;
                
                next_pos_uID = sparsRibsgeo.spars.segments.positions{spar_number}{1};               
                next_pos_index = strcmp(sparsRibsgeo.spars.positions.uIDs, next_pos_uID);
                srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{spar_refIdx+1}.xsi{1,1}.CONTENT = num2str(sparsRibsgeo.spars.positions.xsi(next_pos_index));
                
            elseif spar_position_add_number == (length(sparsRibsgeo.spars.segments.positions{spar_number}) + 1)
                srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{spar_refIdx+1}.eta{1,1}.CONTENT = num2str(1) ;
                
                next_pos_uID = sparsRibsgeo.spars.segments.positions{spar_number}{end};               
                next_pos_index = strcmp(sparsRibsgeo.spars.positions.uIDs, next_pos_uID);
                srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{spar_refIdx+1}.xsi{1,1}.CONTENT = num2str(sparsRibsgeo.spars.positions.xsi(next_pos_index));
                
            else 
                previous_pos_uID = sparsRibsgeo.spars.segments.positions{spar_number}{spar_position_add_number-1};               
                previous_pos_index = strcmp(sparsRibsgeo.spars.positions.uIDs, previous_pos_uID);
                
                next_pos_uID = sparsRibsgeo.spars.segments.positions{spar_number}{spar_position_add_number};               
                next_pos_index = strcmp(sparsRibsgeo.spars.positions.uIDs, next_pos_uID);
                
                srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{spar_refIdx+1}.eta{1,1}.CONTENT  = num2str((sparsRibsgeo.spars.positions.eta(previous_pos_index) + sparsRibsgeo.spars.positions.eta(next_pos_index))/2);
                srStruct.spars{1,1}.sparPositions{1,1}.sparPosition{spar_refIdx+1}.xsi{1,1}.CONTENT = num2str(sparsRibsgeo.spars.positions.xsi(previous_pos_index));
            end
            
            %------ Update the sparSegment Positions -------
            segment_positions = srStruct.spars{1,1}.sparSegments{1,1}.sparSegment{1,spar_number}.sparPositionUIDs{1,1}.sparPositionUID; 
            num_segPositions = length( segment_positions ); 
            new_length = num_segPositions + 1; 
            temp_sparSegment_positions = cell(1, new_length); 
            
            if spar_position_add_number ~= 1
               temp_sparSegment_positions(1 : spar_position_add_number - 1) = segment_positions(1 : spar_position_add_number - 1);
            end
            
            if spar_position_add_number ~= new_length
                temp_sparSegment_positions(spar_position_add_number + 1 : end) = segment_positions(spar_position_add_number : end);
            end
            temp_sparSegment_positions{1,spar_position_add_number}.CONTENT = added_uID{1}; 
            
            
            srStruct.spars{1,1}.sparSegments{1,1}.sparSegment{1,spar_number}.sparPositionUIDs{1,1}.sparPositionUID = temp_sparSegment_positions; 

        end
       
    case 2                                % new rib definition
        prompt = {'Enter uID for the added Ribs:'};
        dlg_title = 'Input';
        num_lines = 1;
        def = {'test_rib_uID'};
        added_uID = inputdlg(prompt,dlg_title,num_lines,def);

        if rib_add_number == 1
            ref_index = 1;
            added_etaStart = 0.001;
            added_etaEnd = sparsRibsgeo.ribsDefinitions.etaStart(ref_index)-0.001;
            
        elseif rib_add_number == length(sparsRibsgeo.ribsDefinitions.uIDs) + 1
            ref_index = length(sparsRibsgeo.ribsDefinitions.uIDs);
            added_etaStart = sparsRibsgeo.ribsDefinitions.etaEnd(ref_index) + 0.001;
            added_etaEnd = 0.999; 
        else
            ref_index = rib_add_number - 1;
            added_etaStart = sparsRibsgeo.ribsDefinitions.etaEnd(ref_index) + 0.001;
            added_etaEnd =  sparsRibsgeo.ribsDefinitions.etaStart(ref_index+1) - 0.001;
        end
        
        added_uID = added_uID{1};
        added_ribReference = sparsRibsgeo.ribsDefinitions.ribReference{ref_index};
        added_ribStart = sparsRibsgeo.ribsDefinitions.ribStart{ref_index};
        added_ribEnd = sparsRibsgeo.ribsDefinitions.ribEnd{ref_index};
        added_numberOfRibs = 2;
        added_ribCrossingBehavior = 'end';
        added_ribRotationReference = sparsRibsgeo.ribsDefinitions.ribRotationReference{ref_index};
        added_rotz = 90;
        added_rotx = 90;
        added_ribCrossSection = srStruct.ribsDefinitions{1,1}.ribsDefinition{1,ref_index}.ribCrossSection; 
        
        num_ribs = length(sparsRibsgeo.ribsDefinitions.uIDs);
        added_new_length = num_ribs + 1;
        
        temp_ribsDefinition = cell(1, added_new_length);
        
        if rib_add_number ~= 1
            temp_ribsDefinition(1 : rib_add_number-1) = srStruct.ribsDefinitions{1,1}.ribsDefinition(1 : rib_add_number-1);
        end
        
        if rib_add_number ~= added_new_length
            temp_ribsDefinition(rib_add_number+1 : end) = srStruct.ribsDefinitions{1,1}.ribsDefinition(rib_add_number : end);
        end
        
        
        temp_ribsDefinition{rib_add_number}.ATTRIBUTE.uID = added_uID;
        temp_ribsDefinition{rib_add_number}.name{1,1}.CONTENT = added_uID;
        temp_ribsDefinition{rib_add_number}.description{1,1}.CONTENT = 'ribs added by the user';
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.ribReference{1,1}.CONTENT = added_ribReference;
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.etaStart{1,1}.CONTENT = num2str(added_etaStart);
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.etaEnd{1,1}.CONTENT = num2str(added_etaEnd);
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.ribStart{1,1}.CONTENT = added_ribStart;
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.ribEnd{1,1}.CONTENT = added_ribEnd;
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.numberOfRibs{1,1}.CONTENT = num2str(added_numberOfRibs);
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.ribCrossingBehaviour{1,1}.CONTENT = added_ribCrossingBehavior;
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.ribRotation{1,1}.ribRotationReference{1,1}.CONTENT = added_ribRotationReference;
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.ribRotation{1,1}.z{1,1}.CONTENT = num2str(added_rotz);
        temp_ribsDefinition{rib_add_number}.ribsPositioning{1,1}.ribRotation{1,1}.x{1,1}.CONTENT = num2str(added_rotx);
        temp_ribsDefinition{rib_add_number}.ribCrossSection = added_ribCrossSection; 
        
        srStruct.ribsDefinitions{1,1}.ribsDefinition = temp_ribsDefinition;
   %    a = 1; 
end

end