function [] = figure_engine(engine_structure)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Modify engine                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Pierre Saquet                                         %
% LastModified:     2013-01-28                                            %
% LastModifiedBy:   Pengfei Meng                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%                                                                         %
%   - decide to add or not all the part of the engines defined in the     %
%   CPACS XML file (casings, fan, ...)                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear global variables used only on this file: figure_engine.m

global handles_engine engine_struct  final_engine_struct 

if ~isempty(engine_struct)
    clear global engine_struct
end

engine_structure.change = 0; 
engine_struct = engine_structure;      % create a global structure engine_struct
final_engine_struct  =  engine_structure; 
%% Figure
figure_engine.fh = figure('units','normalized',...
    'position',[0.1 0.2 0.7 0.7],...
    'menubar','none',...
    'Color',[.2 .2 .3],...
    'numbertitle','off',...
    'name','Modify engine',...
    'renderer', 'OpenGL',...
    'Tag','figure_engine',...
    'WindowStyle', 'modal',...
    'resize','off');

figure_engine.colpb = [0.9255, 0.9137, 0.8471]; % Default Color of buttons

%% Panels
% Panel Drawing
figure_engine.up(1)= uipanel('Parent',figure_engine.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.0 0.7 1.0],...
                    'backgroundcolor', [1.0 1.0 1.0],...
                    'tag','Drawing');
                
% Panel parameters
figure_engine.up(2)= uipanel('Parent',figure_engine.fh ,'Title','Parameters',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.2 0.3 0.8],...
                    'tag','parameters');
                
% Panel button
figure_engine.up(4)= uipanel('Parent',figure_engine.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.0 0.3 0.2],...
                    'tag','button');
                
%% Panel Drawing
% axes 1
figure_engine.axes(1) = axes('Parent', figure_engine.up(1),...
                    'units','normalized',...
                    'Visible', 'off',...
                    'OuterPosition',[0.0 0.0 1.0 1.0],...
                    'tag', 'axes_1');
                
%% uicontrol panel button
% Push button Select
figure_engine.pb(1) = uicontrol('style','push',...
                    'parent', figure_engine.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.5 0.8 0.45],...
                    'backg',figure_engine.colpb,...
                    'tag','Select',...
                    'string','Save','callback',{@Select});
                
% Push button Cancel
figure_engine.pb(2) = uicontrol('style','push',...
                    'parent', figure_engine.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.05 0.8 0.45],...
                    'backg',figure_engine.colpb,...
                    'tag','Cancel',...
                    'string','Cancel','callback',{@Cancel});
                
handles_engine = guihandles(gcf);
guidata(gcf, handles_engine);
                
%% uicontrol panel parameters       
% Table parameters
    parameters_data = [
      { 'x max diameter', 'm', str2double(engine_struct.nacelle{1,1}.maxDiameter{1,1}.x{1,1}.CONTENT)};
      { 'max diameter', 'm', str2double(engine_struct.nacelle{1,1}.maxDiameter{1,1}.y{1,1}.CONTENT)};
      { 'x nozzle cold stream', 'm', str2double(engine_struct.nacelle{1,1}.coldStream{1,1}.x{1,1}.CONTENT)};
      { 'nozzle cold stream inner radius', 'm', str2double(engine_struct.nacelle{1,1}.coldStream{1,1}.innerRadius{1,1}.CONTENT)};
      { 'nozzle cold stream outer radius', 'm', str2double(engine_struct.nacelle{1,1}.coldStream{1,1}.outerRadius{1,1}.CONTENT)};
      { 'x nozzle hot stream', 'm', str2double(engine_struct.nacelle{1,1}.hotStream{1,1}.x{1,1}.CONTENT)};
      { 'nozzle hot stream inner radius', 'm', str2double(engine_struct.nacelle{1,1}.hotStream{1,1}.innerRadius{1,1}.CONTENT)};
      { 'nozzle hot stream outer radius', 'm', str2double(engine_struct.nacelle{1,1}.hotStream{1,1}.outerRadius{1,1}.CONTENT)};
      { 'x inlet', 'm', str2double(engine_struct.nacelle{1,1}.inlet{1,1}.position{1,1}.x{1,1}.CONTENT)};
      { 'inlet radius', 'm', str2double(engine_struct.nacelle{1,1}.inlet{1,1}.radius{1,1}.y{1,1}.CONTENT)};
      { 'inlet nose radius', 'm', str2double(engine_struct.nacelle{1,1}.inlet{1,1}.noseRadius{1,1}.CONTENT)};
      { 'y angle inlet', 'm', str2double(engine_struct.nacelle{1,1}.inlet{1,1}.angle{1,1}.y{1,1}.CONTENT)};
      { 'z angle inlet', 'm', str2double(engine_struct.nacelle{1,1}.inlet{1,1}.angle{1,1}.z{1,1}.CONTENT)};
      { 'x end nacelle', 'm', str2double(engine_struct.nacelle{1,1}.endPos{1,1}.x{1,1}.CONTENT)};
   ];

% create the parameters table for this section
figure_engine.table_parameters = uitable('Parent', handles_engine.parameters,...
                            'units','normalized',...
                            'Position',[0.0 0.0 1.0 1.0],...
                            'ColumnName',{'Parameter','Unit','Value'},...
                            'ColumnEditable',[false,false,true],...
                            'ColumnFormat',{'char','char','numeric'},...
                            'RowName',[],...
                            'Data', parameters_data,...
                            'tag', 'table_parameters',...
                            'CellEditCallback',{@table_parameters});
                       
% create handle for this table
h = findobj('tag','table_parameters');
handles_engine.table_parameters = h;

% adapt width columns of the tables
set(handles_engine.table_parameters, 'Units', 'pixels');
parameters_position = get(handles_engine.table_parameters, 'Position');
set(handles_engine.table_parameters, 'ColumnWidth', {floor(parameters_position(3)*0.65),floor(parameters_position(3)*0.1),floor(parameters_position(3)*0.2)});
set(handles_engine.table_parameters, 'Units', 'normalized');

% draw engine
Draw_engine(engine_struct, 1)

end

%% functions callback corresponding to tables
function [] = table_parameters(varargin)

global handles_engine engine_struct

event = varargin{2};

% get the parameters data
parameters_data = get(handles_engine.table_parameters, 'Data');

% x max diameter
if event.Indices == [1,3]
    parameters_data(1,3) = num2cell(event.NewData);
end

% max diameter
if event.Indices == [2,3]
    parameters_data(2,3) = num2cell(event.NewData);
end

% x nozzle cold stream
if event.Indices == [3,3]
    parameters_data(3,3) = num2cell(event.NewData);
end

% nozzle cold stream inner radius
if event.Indices == [4,3]
    parameters_data(4,3) = num2cell(event.NewData);
end

% nozzle cold stream outer radius
if event.Indices == [5,3]
    parameters_data(5,3) = num2cell(event.NewData);
end

% x nozzle hot stream
if event.Indices == [6,3]
    parameters_data(6,3) = num2cell(event.NewData);
end

% nozzle hot stream inner radius
if event.Indices == [7,3]
    parameters_data(7,3) = num2cell(event.NewData);
end

% nozzle hot stream outer radius
if event.Indices == [8,3]
    parameters_data(8,3) = num2cell(event.NewData);
end

% x inlet
if event.Indices == [9,3]
    parameters_data(9,3) = num2cell(event.NewData);
end

% inlet radius
if event.Indices == [10,3]
    parameters_data(10,3) = num2cell(event.NewData);
end

% inlet nose radius
if event.Indices == [11,3]
    parameters_data(11,3) = num2cell(event.NewData);
end

% inlet angle y
if event.Indices == [12,3]
    parameters_data(12,3) = num2cell(event.NewData);
end

% inlet angle z
if event.Indices == [13,3]
    parameters_data(13,3) = num2cell(event.NewData);
end

% x end position
if event.Indices == [14,3]
    parameters_data(14,3) = num2cell(event.NewData);
end

% load adjusted data in the table
set(handles_engine.table_parameters, 'Data', parameters_data);

% change values in the global structure engine_struct
engine_struct.nacelle{1,1}.maxDiameter{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(parameters_data(1,3)));
engine_struct.nacelle{1,1}.maxDiameter{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(parameters_data(2,3)));
engine_struct.nacelle{1,1}.coldStream{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(parameters_data(3,3)));
engine_struct.nacelle{1,1}.coldStream{1,1}.innerRadius{1,1}.CONTENT = mat2str(cell2mat(parameters_data(4,3)));
engine_struct.nacelle{1,1}.coldStream{1,1}.outerRadius{1,1}.CONTENT = mat2str(cell2mat(parameters_data(5,3)));
engine_struct.nacelle{1,1}.hotStream{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(parameters_data(6,3)));
engine_struct.nacelle{1,1}.hotStream{1,1}.innerRadius{1,1}.CONTENT = mat2str(cell2mat(parameters_data(7,3)));
engine_struct.nacelle{1,1}.hotStream{1,1}.outerRadius{1,1}.CONTENT = mat2str(cell2mat(parameters_data(8,3)));
engine_struct.nacelle{1,1}.inlet{1,1}.position{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(parameters_data(9,3)));
engine_struct.nacelle{1,1}.inlet{1,1}.radius{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(parameters_data(10,3)));
engine_struct.nacelle{1,1}.inlet{1,1}.noseRadius{1,1}.CONTENT = mat2str(cell2mat(parameters_data(11,3)));
engine_struct.nacelle{1,1}.inlet{1,1}.angle{1,1}.y{1,1}.CONTENT = mat2str(cell2mat(parameters_data(12,3)));
engine_struct.nacelle{1,1}.inlet{1,1}.angle{1,1}.z{1,1}.CONTENT = mat2str(cell2mat(parameters_data(13,3)));
engine_struct.nacelle{1,1}.endPos{1,1}.x{1,1}.CONTENT = mat2str(cell2mat(parameters_data(14,3)));

% draw engine
Draw_engine(engine_struct, 0)

end

function [] = Draw_engine(engine_struct, init)

global handles_engine

% current camera position
cam_pos_1 = get(handles_engine.axes_1, 'CameraPosition');

% deletes from the current axes all graphics objects
cla

% calculate X Y Z coordinates matrices by calling matrix_engine_cpacs.m
[X_engine, Y_engine, Z_engine] = matrix_engine_cpacs(engine_struct);

% create surface
surfl(X_engine, Y_engine, Z_engine)

% set axes title
set(get(handles_engine.axes_1, 'xlabel'),'String','X')
set(get(handles_engine.axes_1, 'ylabel'),'String','Y')
set(get(handles_engine.axes_1, 'zlabel'),'String','Z')

% aspect ratio
set(handles_engine.axes_1, 'DataAspectRatio',[1 1 1]);

% camera position for AspectRatio [1 1 1]
cam_pos_AR_1 = get(handles_engine.axes_1, 'CameraPosition');

if init == 1
    % set the camera to the default position
    set(handles_engine.axes_1, 'CameraPosition', cam_pos_AR_1);
else
    % stay in the last position
    set(handles_engine.axes_1, 'CameraPosition', cam_pos_1);
end

% grid on
grid(handles_engine.axes_1, 'on')

% permits rotation
rotate3d(handles_engine.axes_1, 'on')

end

%% functions callback corresponding to buttons
function [] = Select(varargin)
global handles_engine  engine_struct  final_engine_struct

engine_struct.change = engine_struct.change + 1; 
final_engine_struct = engine_struct ; 

close(handles_engine.figure_engine)

end

function [] = Cancel (varargin)

global handles_engine

% create a question box
message = strcat('Do you really want to close this window and loose all the modifications ? ');
choice = questdlg(message, 'Cancel', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        % close the window
        close(handles_engine.figure_engine)
        
    case 'No'
        return;
end

end