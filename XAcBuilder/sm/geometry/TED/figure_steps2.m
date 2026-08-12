function [] = figure_steps2(iTED_localStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Modify, remove and add steps for trailing edge devices                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Pierre Saquet                                         %
% LastModified:     2012-01-02                                            %
% LastModifiedBy:   PS                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear global steps_struct
clear global stage_steps_struct

global handles_steps  historic_step_string  step_number   
global steps_struct stage_steps_struct final_iTEDstruct

iTED_localStruct.change = 0; 
steps_struct = iTED_localStruct;                 % used to visualize every potential modification
stage_steps_struct = iTED_localStruct;             % here stage_steps_struct ~~ final_element_struct in figure_section2
final_iTEDstruct = iTED_localStruct; 

step_number = 1;   

numOfSteps = length(steps_struct.path{1,1}.steps{1,1}.step);
historic_step_string = strcat('number of steps:', numOfSteps);

%% Figure
figure_steps.fh = figure('units','normalized',...
    'position',[0.1 0.2 0.7 0.7],...
    'menubar','none',...
    'Color',[.2 .2 .3],...
    'numbertitle','off',...
    'name','Modify steps',...
    'renderer', 'OpenGL',...
    'Tag','figure_steps',...
    'resize','off');            % 'WindowStyle', 'modal',...

figure_steps.colpb = [0.9255, 0.9137, 0.8471]; % Default Color of buttons

%% Panels
% Panel Drawing
figure_steps.up(1)= uipanel('Parent',figure_steps.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.0 0.7 0.9],...
                    'backgroundcolor', [1.0 1.0 1.0],...
                    'tag','Drawing');
                
% Panel parameters
figure_steps.up(2)= uipanel('Parent',figure_steps.fh ,'Title','Parameters',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.2 0.3 0.8],...
                    'tag','parameters');
                
% Panel steps modification
figure_steps.up(3)= uipanel('Parent',figure_steps.fh ,'Title','Modify/Remove/Add steps',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.9 0.7 0.1],...
                    'tag','steps_modification');
                
% Panel button
figure_steps.up(4)= uipanel('Parent',figure_steps.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.0 0.3 0.2],...
                    'tag','button');
                
%% Panel Drawing
% axes 1
figure_steps.axes(1) = axes('Parent', figure_steps.up(1),...
                    'units','normalized',...
                    'Visible', 'off',...
                    'OuterPosition',[0.0 0.0 1.0 1.0],...
                    'tag', 'axes_1');
                
%% uicontrol panel button
% Push button Select
figure_steps.pb(1) = uicontrol('style','push',...
                    'parent', figure_steps.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.5 0.8 0.45],...
                    'backg',figure_steps.colpb,...
                    'tag','Select',...
                    'string','Save All Actions','callback',{@Select});
                
% Push button Cancel
figure_steps.pb(2) = uicontrol('style','push',...
                    'parent', figure_steps.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.05 0.8 0.45],...
                    'backg',figure_steps.colpb,...
                    'tag','Cancel',...
                    'string','Cancel','callback',{@Cancel});

%% uicontrol panel steps modification

popupmenu_string ='';
for i=1 : numOfSteps
    step_name = strcat('step_', num2str(i));
    popupmenu_string = char(popupmenu_string, step_name);
end

popupmenu_string = popupmenu_string(2:end,:);

figure_steps.label(1) = uicontrol('Style', 'text',...                         % label
                'Parent', figure_steps.up(3),...
                'units','normalized',...
                'Position',[0.0 0.3 0.18 0.4],...
                'Tag','label',...
                'String', 'select a step');


figure_steps.popupmenu(1) = uicontrol('Style', 'popupmenu',...                % Pop-up menu Select a section
                            'Parent', figure_steps.up(3),...
                            'units','normalized',...
                            'Position',[0.18 0.3 0.15 0.4],...
                            'tag', 'select_a_step',...
                            'backg',figure_steps.colpb,...
                            'String', popupmenu_string,...
                            'Value', 1,...
                            'callback', {@select_a_step});
                        
% Push button Modify step
figure_steps.pb(3) = uicontrol('style','push',...
                    'parent', figure_steps.up(3),...
                    'units','normalized',...
                    'position',[0.4 0.1 0.2 0.8],...
                    'backg',figure_steps.colpb,...
                    'tag','Modify_step',...
                    'string','Confirm Modify Step','callback',{@Confirm_Modify_step});
                
% Push button Remove step
figure_steps.pb(4) = uicontrol('style','push',...
                    'parent', figure_steps.up(3),...
                    'units','normalized',...
                    'position',[0.6 0.1 0.2 0.8],...
                    'backg',figure_steps.colpb,...
                    'tag','Remove_step',...
                    'string','Confirm Remove Step','callback',{@Confirm_Remove_step});
                
% Push button Add step
figure_steps.pb(5) = uicontrol('style','push',...
                    'parent', figure_steps.up(3),...
                    'units','normalized',...
                    'position',[0.8 0.1 0.2 0.8],...
                    'backg',figure_steps.colpb,...
                    'tag','Add_step',...
                    'string','Confirm Add Step','callback',{@Confirm_Add_step});
                        
handles_steps = guihandles(gcf);
guidata(gcf, handles_steps);
                
%% uicontrol panel parameters

numStep = get(handles_steps.select_a_step, 'Value');

% Table parameters

try   TEDstepOuterHingeTranslationX  = str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.x{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationX  = str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT); end

try   TEDstepOuterHingeTranslationY  = str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.y{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationY  = str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT); end 

try   TEDstepOuterHingeTranslationZ  = str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.z{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationZ  = str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT); end

    parameters_data = [
      { 'rel deflection', 'deg.', str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.relDeflection{1,1}.CONTENT)};
      { 'inner hinge x', '',  str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT)};
      { 'inner hinge y', '',  str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT)};
      { 'inner hinge z', '',  str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT)};
      { 'outer hinge x', '',  TEDstepOuterHingeTranslationX};
      { 'outer hinge y', '',  TEDstepOuterHingeTranslationY};
      { 'outer hinge z', '',  TEDstepOuterHingeTranslationZ};
      { 'hinge line rotation', 'deg.', str2num(steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.hingeLineRotation{1,1}.CONTENT)};
      { 'inner hingeXsi', '', str2num(steps_struct.path{1,1}.innerHingePoint{1,1}.hingeXsi{1,1}.CONTENT)};
      { 'inner hingeRelHeight', '', str2num(steps_struct.path{1,1}.innerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT)};
      { 'outer hingeXsi', '', str2num(steps_struct.path{1,1}.outerHingePoint{1,1}.hingeXsi{1,1}.CONTENT)};
      { 'outer hingeRelHeight', '', str2num(steps_struct.path{1,1}.outerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT)};
   ];                             
                          
% create the parameters table for this section
figure_steps.table_parameters = uitable('Parent', handles_steps.parameters,...
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
handles_steps.table_parameters = h;

% adapt width columns of the tables
set(handles_steps.table_parameters, 'Units', 'pixels');
parameters_position = get(handles_steps.table_parameters, 'Position');
set(handles_steps.table_parameters, 'ColumnWidth', {floor(parameters_position(3)*0.65),floor(parameters_position(3)*0.1),floor(parameters_position(3)*0.2)});
set(handles_steps.table_parameters, 'Units', 'normalized');

% draw steps
Draw_steps(steps_struct)

end

%% functions callback corresponding to tables
function [] = table_parameters(varargin)
global handles_steps steps_struct  stage_steps_struct

steps_struct = stage_steps_struct; 

event = varargin{2};
numStep = get(handles_steps.select_a_step, 'Value');                         % get the step value
parameters_data = get(handles_steps.table_parameters, 'Data');               % get the parameters data

switch event.Indices(1)
    case 1                    % rel deflection
        parameters_data(1,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.relDeflection{1,1}.CONTENT = num2str(event.NewData);
    case 2                    % inner hinge x
        parameters_data(2,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT = num2str(event.NewData);
    case 3                    % inner hinge y
        parameters_data(3,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT = num2str(event.NewData);
    case 4                    % inner hinge z
        parameters_data(4,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT = num2str(event.NewData);
    case 5                    % outer hinge x
        parameters_data(5,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.x{1,1}.CONTENT = num2str(event.NewData);
    case 6                    % outer hinge y
        parameters_data(6,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.y{1,1}.CONTENT = num2str(event.NewData);
    case 7                    % outer hinge z
        parameters_data(7,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.z{1,1}.CONTENT = num2str(event.NewData);
    case 8                    % hinge line rotation
        parameters_data(8,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.hingeLineRotation{1,1}.CONTENT = num2str(event.NewData);
    case 9                    % inner hingeRelChord
        parameters_data(9,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.innerHingePoint{1,1}.hingeXsi{1,1}.CONTENT = num2str(event.NewData);
    case 10                   % inner hingeRelHeight
        parameters_data(10,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.innerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT = num2str(event.NewData);
    case 11                   % outer hingeRelChord
        parameters_data(11,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.outerHingePoint{1,1}.hingeXsi{1,1}.CONTENT = num2str(event.NewData);
    case 12                   % outer hingeRelHeight
        parameters_data(12,3) = num2cell(event.NewData);
        steps_struct.path{1,1}.outerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT = num2str(event.NewData);
end

set(handles_steps.table_parameters, 'Data', parameters_data);                

Draw_steps(steps_struct)

end

function [] = Draw_steps(iTED_struct)

global handles_steps

cla                                                                          % deletes from the current axes all graphics objects
numStep = get(handles_steps.select_a_step, 'Value');                         % get the step value

[iTED_foils, iTED_geo] = matrix_controlSurf_4(iTED_struct);       
 
for m=1:length(iTED_foils.Basic)                   % re-organize coorinates matrices

    % default step
    X_control_surface(:,m) = iTED_foils.Basic{1,m}(:,1);
    Y_control_surface(:,m) = iTED_foils.Basic{1,m}(:,2);
    Z_control_surface(:,m) = iTED_foils.Basic{1,m}(:,3);
    
    % others steps
    X_control_surface_step(:,m) = iTED_foils.Deflected.steps{1,numStep}.airfoils{1,m}(:,1);
    Y_control_surface_step(:,m) = iTED_foils.Deflected.steps{1,numStep}.airfoils{1,m}(:,2);
    Z_control_surface_step(:,m) = iTED_foils.Deflected.steps{1,numStep}.airfoils{1,m}(:,3);

end

plot3(handles_steps.axes_1, X_control_surface, Y_control_surface, Z_control_surface, 'b')                  % plot the default step
hold(handles_steps.axes_1, 'on')                                                                           % wait for drawing
plot3(handles_steps.axes_1, X_control_surface_step, Y_control_surface_step, Z_control_surface_step, 'r')
hold(handles_steps.axes_1, 'off')                                                                          % stop waiting for drawing

%----------- Figure Settings ------------
set(get(handles_steps.axes_1, 'xlabel'),'String','X')    % axes titles
set(get(handles_steps.axes_1, 'ylabel'),'String','Y')
set(get(handles_steps.axes_1, 'zlabel'),'String','Z')

set(handles_steps.axes_1, 'DataAspectRatio',[1 1 1]);    % aspect ratio
grid(handles_steps.axes_1, 'on')                         % grid on
rotate3d(handles_steps.axes_1, 'on')                     % permits rotation

end

%% functions callback corresponding to buttons
function [] = Select(varargin)

global handles_steps stage_steps_struct historic_step_string   final_iTEDstruct

final_iTEDstruct = stage_steps_struct;

msgbox(historic_step_string, 'informations');                                % visualize the modifications history
close(handles_steps.figure_steps)                                            % close the window 
end

function [] = Cancel (varargin)

global handles_steps

message = strcat('Do you really want to close this window and loose all the modifications ? ');
choice = questdlg(message, 'Cancel', 'Yes', 'No', 'No');

switch choice
    case 'Yes'                                  % close the  window       
        close(handles_steps.figure_steps)        
    case 'No'
        return;
end

end

function [] = Confirm_Modify_step(varargin)

global handles_steps stage_steps_struct steps_struct historic_step_string

step_value = get(handles_steps.select_a_step, 'Value');                                % get the step value

message = strcat('Do you want to modify the step ', num2str(step_value), ' ?');        % create a question box
choice = questdlg(message, 'Modify function', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        historic_step_string = char(char(historic_step_string),strcat('modify step', num2str(step_value))); 
        steps_struct.change = steps_struct.change + 1; 
        stage_steps_struct =  steps_struct;        
    case 'No'
        return
end
   
end

function [] = Confirm_Remove_step(varargin)

global handles_steps steps_struct stage_steps_struct historic_step_string step_number

step_value = get(handles_steps.select_a_step, 'Value');

message = strcat('Do you want to remove the step ', num2str(step_value), ' ?');
choice = questdlg(message, 'Remove function', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        
    case 'No'
        return;
end

steps_struct.path{1,1}.steps{1,1}.step(step_value) = [];

steps_struct.change = steps_struct.change + 1; 
stage_steps_struct = steps_struct;

% new length of steps
popupmenu_string ='';
for i=1:length(stage_steps_struct.path{1,1}.steps{1,1}.step)
    popupmenu_string = char(char(popupmenu_string),strcat('step_', num2str(i)));
end
popupmenu_string = popupmenu_string(2:end,:);

set(handles_steps.select_a_step, 'String', popupmenu_string);

if step_value ~=1
    step_value = step_value - 1;
    set(handles_steps.select_a_step, 'Value', step_value);
end

step_number = step_value;
adjust_tables(stage_steps_struct, step_value)                 % visualize the right table corresponding to the selected step

historic_step_string = char(char(historic_step_string),strcat('remove step', num2str(step_value)));

numOfSteps = length(stage_steps_struct.path{1,1}.steps{1,1}.step);
historic_step_string = char(char(historic_step_string),strcat('number of steps:', num2str(numOfSteps)));


Draw_steps(stage_steps_struct)                                % draw steps

end

function [] = Confirm_Add_step(varargin)

global stage_steps_struct handles_steps historic_step_string    steps_struct  % step_number

numOfSteps = length(stage_steps_struct.path{1,1}.steps{1,1}.step);
step_value = numOfSteps + 1;
numStep = step_value; 
message = strcat('Do you want to add a step (step_', num2str(step_value), ')?');
choice = questdlg(message, 'Add function', 'Yes', 'No', 'No');


switch choice
    case 'Yes'
        
        steps_struct.path{1,1}.steps{1,1}.step{1,step_value}.relDeflection{1,1}.CONTENT = num2str(0);
        
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT = num2str(0);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT = num2str(0);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT = num2str(0);        
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.x{1,1}.CONTENT = num2str(0);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.y{1,1}.CONTENT = num2str(0);
        steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.z{1,1}.CONTENT = num2str(0);
        
        steps_struct.path{1,1}.steps{1,1}.step{1,step_value}.hingeLineRotation{1,1}.CONTENT = num2str(0);
  
        steps_struct.change = steps_struct.change + 1; 
        stage_steps_struct = steps_struct;
        popupmenu_string ='';                                            % new length of steps
        for i=1 : step_value
            popupmenu_string = char(popupmenu_string, strcat('step_', num2str(i)));
        end
        popupmenu_string = popupmenu_string(2:end,:);
        
        historic_step_string = char(char(historic_step_string),strcat('add step', num2str(step_value)));
        historic_step_string = char(char(historic_step_string),strcat('number of steps:', num2str(step_value)));

        set(handles_steps.select_a_step, 'String', popupmenu_string);
        set(handles_steps.select_a_step, 'Value', step_value)
        
        
        adjust_tables(stage_steps_struct, step_value)                     % visualize the right table corresponding to the selected step
        
        Draw_steps(stage_steps_struct)
        
    case 'No'
        return
end

end

%% function callback corresponding to popup menus
function [] = select_a_step(varargin)

global handles_steps steps_struct stage_steps_struct  step_number

steps_struct = stage_steps_struct;
numStep = step_number; 

step_value = get(handles_steps.select_a_step, 'Value');                     % get the step value
step_number = step_value;

try   TEDstepOuterHingeTranslationX  = str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.x{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationX  = str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT); end

try   TEDstepOuterHingeTranslationY  = str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.y{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationY  = str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT); end

try   TEDstepOuterHingeTranslationZ  = str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.outerHingeTranslation{1,1}.z{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationZ  = str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT); end

parameters_data = [
    { 'rel deflection', 'deg.', str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.relDeflection{1,1}.CONTENT)};
    { 'inner hinge x', '',  str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.x{1,1}.CONTENT)};
    { 'inner hinge y', '',  str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.y{1,1}.CONTENT)};
    { 'inner hinge z', '',  str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.innerHingeTranslation{1,1}.z{1,1}.CONTENT)};
    { 'outer hinge x', '',  TEDstepOuterHingeTranslationX};
    { 'outer hinge y', '',  TEDstepOuterHingeTranslationY};
    { 'outer hinge z', '',  TEDstepOuterHingeTranslationZ};
    { 'hinge line rotation', 'deg.', str2num(stage_steps_struct.path{1,1}.steps{1,1}.step{1,numStep}.hingeLineRotation{1,1}.CONTENT)};
    { 'inner hingeXsi', '', str2num(stage_steps_struct.path{1,1}.innerHingePoint{1,1}.hingeXsi{1,1}.CONTENT)};
    { 'inner hingeRelHeight', '', str2num(stage_steps_struct.path{1,1}.innerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT)};
    { 'outer hingeXsi', '', str2num(stage_steps_struct.path{1,1}.outerHingePoint{1,1}.hingeXsi{1,1}.CONTENT)};
    { 'outer hingeRelHeight', '', str2num(stage_steps_struct.path{1,1}.outerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT)};
    ];

set(handles_steps.table_parameters, 'Data', parameters_data);

Draw_steps(stage_steps_struct)

end

function [] = adjust_tables(local_struct, step_value)

global handles_steps

try   TEDstepOuterHingeTranslationX  = str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.outerHingeTranslation{1,1}.x{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationX  = str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.innerHingeTranslation{1,1}.x{1,1}.CONTENT); end

try   TEDstepOuterHingeTranslationY  = str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.outerHingeTranslation{1,1}.y{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationY  = str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.innerHingeTranslation{1,1}.y{1,1}.CONTENT); end

try   TEDstepOuterHingeTranslationZ  = str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.outerHingeTranslation{1,1}.z{1,1}.CONTENT);
catch TEDstepOuterHingeTranslationZ  = str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.innerHingeTranslation{1,1}.z{1,1}.CONTENT); end

parameters_data = [
    { 'rel deflection', 'deg.', str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.relDeflection{1,1}.CONTENT)};
    { 'inner hinge x', '',  str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.innerHingeTranslation{1,1}.x{1,1}.CONTENT)};
    { 'inner hinge y', '',  str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.innerHingeTranslation{1,1}.y{1,1}.CONTENT)};
    { 'inner hinge z', '',  str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.innerHingeTranslation{1,1}.z{1,1}.CONTENT)};
    { 'outer hinge x', '',  TEDstepOuterHingeTranslationX};
    { 'outer hinge y', '',  TEDstepOuterHingeTranslationY};
    { 'outer hinge z', '',  TEDstepOuterHingeTranslationZ};
    { 'hinge line rotation', 'deg.', str2num(local_struct.path{1,1}.steps{1,1}.step{1,step_value}.hingeLineRotation{1,1}.CONTENT)};
    { 'inner hingeXsi', '', str2num(local_struct.path{1,1}.innerHingePoint{1,1}.hingeXsi{1,1}.CONTENT)};
    { 'inner hingeRelHeight', '', str2num(local_struct.path{1,1}.innerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT)};
    { 'outer hingeXsi', '', str2num(local_struct.path{1,1}.outerHingePoint{1,1}.hingeXsi{1,1}.CONTENT)};
    { 'outer hingeRelHeight', '', str2num(local_struct.path{1,1}.outerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT)};
    ];


% adjust table parameters
set(handles_steps.table_parameters, 'Data', parameters_data);

end