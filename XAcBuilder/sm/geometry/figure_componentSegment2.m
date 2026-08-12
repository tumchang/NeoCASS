function [] = figure_componentSegment2(wing_structure, compSeg_struct, idx_compSeg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
%                                                                         %
% Author:           Pierre Saquet                                         %
% LastModified:     2013-04-15                                            %
% LastModifiedBy:   Pengfei MENG                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear global CS_struct

global handles_cs  CS_struct  final_CS_struct
global wingCS_geo  

CS_struct = compSeg_struct;
final_CS_struct = compSeg_struct;
wingCS_geo = [];
[wingCS_geo]=readwings_localStruct(wingCS_geo, wing_structure);

%% Figure
figure_componentSegment.fh = figure('units','normalized',...
    'position',[0.1 0.2 0.5 0.7],...
    'menubar','none',...
    'Color',[.2 .2 .3],...
    'numbertitle','off',...
    'name','Add component segment',...
    'renderer', 'OpenGL',...
    'Tag','figure_componentSegment',...
    'resize','off');   %  'WindowStyle', 'modal',...

figure_componentSegment.colpb = [0.9255, 0.9137, 0.8471]; % Default Color of buttons

%% Panels
% Panel Drawing
figure_componentSegment.up(1)= uipanel('Parent',figure_componentSegment.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.1 1.0 0.8],...
                    'backgroundcolor', [1.0 1.0 1.0],...
                    'tag','Drawing');
                
% Panel button
figure_componentSegment.up(2)= uipanel('Parent',figure_componentSegment.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.0 1.0 0.1],...
                    'tag','button');
                
% Panel segments selection
figure_componentSegment.up(3)= uipanel('Parent',figure_componentSegment.fh ,'Title','segments selection',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.9 1.0 0.1],...
                    'tag','segments_selection');
                
%% Panel Drawing
% axes 1
figure_componentSegment.axes(1) = axes('Parent', figure_componentSegment.up(1),...
                    'units','normalized',...
                    'Visible', 'off',...
                    'OuterPosition',[0.0 0.0 1.0 1.0],...
                    'tag', 'axes_1');
                
%% uicontrol panel button
numSections = length(wing_structure.sections{1,1}.section);
for i=1:numSections 
    element_uIDs{i} = wing_structure.sections{1,1}.section{1,i}.elements{1,1}.element{1,1}.ATTRIBUTE.uID;
end

% Push button Select
figure_componentSegment.pb(1) = uicontrol('style','push',...
                    'parent', figure_componentSegment.up(2),...
                    'units','normalized',...
                    'position',[0.1 0.2 0.35 0.6],...
                    'backg',figure_componentSegment.colpb,...
                    'tag','Select',...
                    'string','Save','callback',{@Select,idx_compSeg, element_uIDs});
                
% Push button Cancel
figure_componentSegment.pb(2) = uicontrol('style','push',...
                    'parent', figure_componentSegment.up(2),...
                    'units','normalized',...
                    'position',[0.55 0.2 0.35 0.6],...
                    'backg',figure_componentSegment.colpb,...
                    'tag','Cancel',...
                    'string','Cancel','callback',{@Cancel});
                
%% uicontrol panel segments selection

% Pop-up menu Select the first element
figure_componentSegment.label(1) = uicontrol('Style', 'text',...
                'Parent', figure_componentSegment.up(3),...
                'units','normalized',...
                'Position',[0.0 0.3 0.15 0.4],...
                'Tag','label',...
                'String', 'first element');
figure_componentSegment.popupmenu(1) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_componentSegment.up(3),...
                            'units','normalized',...
                            'Position',[0.15 0.3 0.35 0.4],...
                            'tag', 'select_first_element',...
                            'backg',figure_componentSegment.colpb,...
                            'String', element_uIDs(1:end-1),...
                            'Value', 1,...
                            'callback', {@select_first_element, element_uIDs});
handles_cs = guihandles(gcf);
guidata(gcf, handles_cs);

first_value = get(handles_cs.select_first_element, 'Value');

% Pop-up menu Select the last element
figure_componentSegment.label(2) = uicontrol('Style', 'text',...
                'Parent', figure_componentSegment.up(3),...
                'units','normalized',...
                'Position',[0.5 0.3 0.15 0.4],...
                'Tag','label_2',...
                'String', 'last element');            
figure_componentSegment.popupmenu(2) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_componentSegment.up(3),...
                            'units','normalized',...
                            'Position',[0.65 0.3 0.35 0.4],...
                            'tag', 'select_last_element',...
                            'backg',figure_componentSegment.colpb,...
                            'String', element_uIDs(first_value+1:end),...
                            'Value', 1,...
                            'callback', {@select_last_element});
                
h = findobj('tag','select_last_element');
handles_cs.select_last_element = h;

last_value = first_value + get(handles_cs.select_last_element, 'Value');

Draw_componentSegment(first_value, last_value)

end

function [] = Draw_componentSegment(first_value, last_value)
global handles_cs  wingCS_geo

cla(handles_cs.axes_1)
XYZ_all_airfoils = wingCS_geo.sectionDef.airfoil;

for i=1:length(XYZ_all_airfoils)
    
    if i == first_value || i == last_value
        colr = 'r';
    else
        colr = 'b';
    end
    
    plot3(handles_cs.axes_1, XYZ_all_airfoils{i,1}(:,1), XYZ_all_airfoils{i,1}(:,2), XYZ_all_airfoils{i,1}(:,3),colr)
    hold(handles_cs.axes_1, 'on')     
    
end

% stop waiting for drawing
hold(handles_cs.axes_1, 'off')

%--------------- Set axes_1 figure settings ----------------
set(get(handles_cs.axes_1, 'xlabel'),'String','X')
set(get(handles_cs.axes_1, 'ylabel'),'String','Y')
set(get(handles_cs.axes_1, 'zlabel'),'String','Z')

set(handles_cs.axes_1, 'DataAspectRatio',[1 1 1]);
grid(handles_cs.axes_1, 'on')
rotate3d(handles_cs.axes_1, 'on')

end

%% functions callback corresponding to buttons
function [] = Select(varargin)
global  handles_cs CS_struct final_CS_struct

idx_compSeg = varargin{3};
element_uIDs = varargin{4}; 

first_strings = get(handles_cs.select_first_element, 'String');
first_index = get(handles_cs.select_first_element, 'Value');
first_elementUID = first_strings{first_index};

last_strings = get(handles_cs.select_last_element, 'String');
last_indexx = get(handles_cs.select_last_element, 'Value');
last_elementUID = last_strings{last_indexx};
last_index = first_index + get(handles_cs.select_last_element, 'Value');

if idx_compSeg ~=1                            % If one or more certain component segment already exist; 
    number_of_CS = length(CS_struct);
    
    for i=1:number_of_CS
        CS_first_elementUID = CS_struct{1,i}.fromElementUID{1,1}.CONTENT;
        CS_last_elementUID = CS_struct{1,i}.toElementUID{1,1}.CONTENT;

        CS_first_value = find(strcmp(element_uIDs, CS_first_elementUID));  
        CS_last_value = find(strcmp(element_uIDs, CS_last_elementUID)); 

        if first_index >= CS_first_value  &&   first_index  <= CS_last_value    %CS_first_value   CS_last_value    first_value   last_value ??
            message = char('2 component segments are crossing each other', 'impossible to create this component segment');
            errordlg(message);
            return
        end

        if last_index >= CS_first_value  &&  last_index <= CS_last_value
            message = char('2 component segments are crossing each other', 'impossible to create this component segment');
            errordlg(message);
            return
        end
    end

else                                           % If idx_compSeg = 1, no compseg exists before; 
    disp('since no component segment exist, a new segment will be created')
end

% create an inputdlg
prompt = {'Enter the UID:','Enter the name:'};
dlg_title = 'Added Component Segment''s UID and name';
num_lines = 1;
def = {'',''};
options.Resize='on';
options.WindowStyle='normal';
answer = inputdlg(prompt, dlg_title, num_lines, def, options);

if isempty(answer{1})
    errordlg('the UID can''t be empty');
    return
end

CS_struct{1,idx_compSeg}.ATTRIBUTE.uID = answer{1};
CS_struct{1,idx_compSeg}.name{1,1}.CONTENT = answer{2};
CS_struct{1,idx_compSeg}.fromElementUID{1,1}.CONTENT = first_elementUID;
CS_struct{1,idx_compSeg}.toElementUID{1,1}.CONTENT = last_elementUID;

final_CS_struct = CS_struct;

close(handles_cs.figure_componentSegment)

end

function [] = Cancel (varargin)

global handles_cs

% create a question box
message = strcat('Do you really want to close this window and loose all the modifications ? ');
choice = questdlg(message, 'Cancel', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        % close the window
        close(handles_cs.figure_componentSegment)
        
    case 'No'
        return;
end

end

%% functions callback corresponding to popup-menus
function [] = select_first_element(varargin)
global handles_cs   

element_uIDs = varargin{3};

first_value = get(handles_cs.select_first_element, 'Value');
            
set(handles_cs.select_last_element, 'String', element_uIDs(first_value+1 : end));
set(handles_cs.select_last_element, 'Value', 1);

last_value = first_value + get(handles_cs.select_last_element, 'Value');

Draw_componentSegment(first_value, last_value)

end

function [] = select_last_element(varargin)
global handles_cs

first_value = get(handles_cs.select_first_element, 'Value');
last_value = first_value + get(handles_cs.select_last_element, 'Value');

Draw_componentSegment(first_value, last_value)

end