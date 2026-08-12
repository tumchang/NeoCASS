function [] = figure_TED2(wingAD_geo, TEDs_structure,  idx_TED, startEle_compSeg, etaEles_compSeg)
%(wingAD_geo, TEDs_structure, selection_CS, number_of_TED + 1, startEle_compSeg, etaEles_compSeg);     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Add new trailing edge devices for wings components                    %    
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
clear global TEDs_struct

global handles_TED  TEDs_struct  final_TEDs_struct

TEDs_struct = TEDs_structure;
final_TEDs_struct = TEDs_structure;

%% Figure
figure_TED.fh = figure('units','normalized',...
    'position',[0.1 0.2 0.7 0.7],...
    'menubar','none',...
    'Color',[.2 .2 .3],...
    'numbertitle','off',...
    'name','Add TED',...
    'renderer', 'OpenGL',...
    'Tag','figure_TED',...
    'resize','on');    %  'WindowStyle', 'modal',...

figure_TED.colpb = [0.9255, 0.9137, 0.8471]; % Default Color of buttons

%% Panels
% Panel Drawing
figure_TED.up(1)= uipanel('Parent',figure_TED.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.0 0.7 1.0],...
                    'backgroundcolor', [1.0 1.0 1.0],...
                    'tag','Drawing');
                
% Panel parameters
figure_TED.up(2)= uipanel('Parent',figure_TED.fh ,'Title','Parameters',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.2 0.3 0.8],...
                    'tag','parameters');
                
% Panel button
figure_TED.up(4)= uipanel('Parent',figure_TED.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.7 0.0 0.3 0.2],...
                    'tag','button');
                
%% Panel Drawing
% axes 1
figure_TED.axes(1) = axes('Parent', figure_TED.up(1),...
                    'units','normalized',...
                    'Visible', 'off',...
                    'OuterPosition',[0.0 0.0 1.0 1.0],...
                    'tag', 'axes_1');
                
%% uicontrol panel button
% Push button Select
figure_TED.pb(1) = uicontrol('style','push',...
                    'parent', figure_TED.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.5 0.8 0.45],...
                    'backg',figure_TED.colpb,...
                    'tag','Select',...
                    'string','Save','callback',{@Select, idx_TED});
                
% Push button Cancel
figure_TED.pb(2) = uicontrol('style','push',...
                    'parent', figure_TED.up(4),...
                    'units','normalized',...
                    'position',[0.1 0.05 0.8 0.45],...
                    'backg',figure_TED.colpb,...
                    'tag','Cancel',...
                    'string','Cancel','callback',{@Cancel});
                
handles_TED = guihandles(gcf);
guidata(gcf, handles_TED);
                
%% uicontrol panel parameters       
% Table parameters
	parameters_data = [
        { 'inner etaLE', '0-1', 0.1};
        { 'inner etaTE', '0-1', 0.1};
        { 'inner xsiLE', '0-1', 0.8};
        { 'inner relHeightLE', '0-1', 0.5};
        { 'inner xsiUpperSkin', '0-1', 0.5};
        { 'inner xsiLowerSkin', '0-1', 0.5};
        { 'outer etaLE', '0-1', 0.9};
        { 'outer etaTE', '0-1', 0.9};
        { 'outer xsiLE', '0-1', 0.8};
        { 'outer relHeightLE', '0-1', 0.5};
        { 'outer xsiUpperSkin', '0-1', 0.5};
        { 'outer xsiLowerSkin', '0-1', 0.5};
        { 'step', '', 'default'};
];

% create the parameters table for this section
figure_TED.table_parameters = uitable('Parent', handles_TED.parameters,...
                            'units','normalized',...
                            'Position',[0.0 0.0 1.0 1.0],...
                            'ColumnName',{'Parameter','Unit','Value'},...
                            'ColumnEditable',[false,false,true],...
                            'ColumnFormat',{'char','char','numeric'},...
                            'RowName',[],...
                            'Data', parameters_data,...
                            'tag', 'table_parameters',...
                            'CellEditCallback',{@table_parameters, wingAD_geo, startEle_compSeg, etaEles_compSeg});
                                                                 
% create handle for this table
h = findobj('tag','table_parameters');
handles_TED.table_parameters = h;

% get the parameters data
parameters_data = get(handles_TED.table_parameters, 'Data');

% add the new TED in TEDs_struct
TEDs_struct{1,idx_TED}.outerShape{1,1}.innerBorder{1,1}.etaLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(1,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(2,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.innerBorder{1,1}.xsiLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(3,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(4,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(5,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(6,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.outerBorder{1,1}.etaLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(7,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(8,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.outerBorder{1,1}.xsiLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(9,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(10,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(11,3)));
TEDs_struct{1,idx_TED}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(12,3)));

% TEDs_struct{1,idx_TED}.parentUID{1,1}.CONTENT = wing_struct.componentSegments{1,1}.componentSegment{1,idx_CompSeg}.ATTRIBUTE.uID;

% default values
TEDs_struct{1,idx_TED}.path{1,1}.innerHingePoint{1,1}.hingeXsi{1,1}.CONTENT = 1.0;
TEDs_struct{1,idx_TED}.path{1,1}.innerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT = 0.5;
TEDs_struct{1,idx_TED}.path{1,1}.outerHingePoint{1,1}.hingeXsi{1,1}.CONTENT = 1.0;
TEDs_struct{1,idx_TED}.path{1,1}.outerHingePoint{1,1}.hingeRelHeight{1,1}.CONTENT = 0.5;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.relDeflection{1,1}.CONTENT = 0.0;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.innerHingeTranslation{1,1}.x{1,1}.CONTENT = 0.0;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.innerHingeTranslation{1,1}.y{1,1}.CONTENT = 0.0;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.innerHingeTranslation{1,1}.z{1,1}.CONTENT = 0.0;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.outerHingeTranslation{1,1}.x{1,1}.CONTENT = 0.0;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.outerHingeTranslation{1,1}.y{1,1}.CONTENT = 0.0;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.outerHingeTranslation{1,1}.z{1,1}.CONTENT = 0.0;
TEDs_struct{1,idx_TED}.path{1,1}.steps{1,1}.step{1,1}.hingeLineRotation{1,1}.CONTENT = 0.0;

% adapt width columns of the tables
set(handles_TED.table_parameters, 'Units', 'pixels');
parameters_position = get(handles_TED.table_parameters, 'Position');
set(handles_TED.table_parameters, 'ColumnWidth', {floor(parameters_position(3)*0.65),floor(parameters_position(3)*0.1),floor(parameters_position(3)*0.2)});
set(handles_TED.table_parameters, 'Units', 'normalized');

% draw TED
Draw_TED(wingAD_geo, TEDs_struct, idx_TED, startEle_compSeg, etaEles_compSeg)

end

%% functions callback corresponding to tables
function [] = table_parameters(varargin)
global handles_TED TEDs_struct

event = varargin{2};
wing_geo = varargin{3};
startEle_compSeg = varargin{4};
etaEles_compSeg = varargin{5};

local_TED = length(TEDs_struct);
parameters_data = get(handles_TED.table_parameters, 'Data');

switch event.Indices(1)
    case {1,2}                   % inner etaLE
        inner_etaLE = event.NewData;
        if inner_etaLE < 0
            inner_etaLE = 0;
        elseif inner_etaLE > 1
            inner_etaLE = 1;
        end
        parameters_data(1,3) = num2cell(inner_etaLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.innerBorder{1,1}.etaLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(1,3)));
        
        parameters_data(2,3) = num2cell(inner_etaLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(2,3)));
        
%     case 2                % inner etaTE
%         inner_etaTE = event.NewData;
%         if inner_etaTE < 0
%             inner_etaTE = 0;
%         elseif inner_etaTE > 1
%             inner_etaTE = 1;
%         end
%         parameters_data(2,3) = num2cell(inner_etaTE);
%         TEDs_struct{1,local_TED}.outerShape{1,1}.innerBorder{1,1}.etaTE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(2,3)));
        
    case 3             % inner xsiLE
        inner_xsiLE = event.NewData;
        if inner_xsiLE < 0
            inner_xsiLE = 0;
        elseif inner_xsiLE > 1
            inner_xsiLE = 1;
        end
        parameters_data(3,3) = num2cell(inner_xsiLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.innerBorder{1,1}.xsiLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(3,3)));
        
    case 4             % inner relZLE
        inner_relZLE = event.NewData;
        if inner_relZLE < 0
            inner_relZLE = 0;
        elseif inner_relZLE > 1
            inner_relZLE = 1;
        end
        parameters_data(4,3) = num2cell(inner_relZLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(4,3)));
        
    case 5            % inner relChordLowerSkin
        inner_relChordLowerSkin = event.NewData;
        if inner_relChordLowerSkin < 0
            inner_relChordLowerSkin = 0;
        elseif inner_relChordLowerSkin > 1
            inner_relChordLowerSkin = 1;
        end
        parameters_data(5,3) = num2cell(inner_relChordLowerSkin);
        TEDs_struct{1,local_TED}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(5,3)));
        
    case 6             % inner relChordUpperSkin
        inner_relChordUpperSkin = event.NewData;
        if inner_relChordUpperSkin < 0
            inner_relChordUpperSkin = 0;
        elseif inner_relChordUpperSkin > 1
            inner_relChordUpperSkin = 1;
        end
        parameters_data(6,3) = num2cell(inner_relChordUpperSkin);
        TEDs_struct{1,local_TED}.outerShape{1,1}.innerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(6,3)));
        
    case 7             % outer etaLE
        outer_etaLE = event.NewData;
        if outer_etaLE < 0
            outer_etaLE = 0;
        elseif outer_etaLE > 1
            outer_etaLE = 1;
        end
        parameters_data(7,3) = num2cell(outer_etaLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.outerBorder{1,1}.etaLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(7,3)));
        parameters_data(8,3) = num2cell(outer_etaLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(8,3)));
        
%     case 8            % outer etaTE
%         outer_etaTE = event.NewData;
%         if outer_etaTE < 0
%             outer_etaTE = 0;
%         elseif outer_etaTE > 1
%             outer_etaTE = 1;
%         end
%         parameters_data(8,3) = num2cell(outer_etaTE);
%         TEDs_struct{1,local_TED}.outerShape{1,1}.outerBorder{1,1}.etaTE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(8,3)));
        
    case 9            % outer xsiLE
        outer_xsiLE = event.NewData;
        if outer_xsiLE < 0
            outer_xsiLE = 0;
        elseif outer_xsiLE > 1
            outer_xsiLE = 1;
        end
        parameters_data(9,3) = num2cell(outer_xsiLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.outerBorder{1,1}.xsiLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(9,3)));
        
    case 10            % outer relZLE
        outer_relZLE = event.NewData;
        if outer_relZLE < 0
            outer_relZLE = 0;
        elseif outer_relZLE > 1
            outer_relZLE = 1;
        end
        parameters_data(10,3) = num2cell(outer_relZLE);
        TEDs_struct{1,local_TED}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.relHeightLE{1,1}.CONTENT = mat2str(cell2mat(parameters_data(10,3)));
        
    case 11            % outer relChordUpperSkin
        outer_relChordUpperSkin = event.NewData;
        if outer_relChordUpperSkin < 0
            outer_relChordUpperSkin = 0;
        elseif outer_relChordUpperSkin > 1
            outer_relChordUpperSkin = 1;
        end
        parameters_data(11,3) = num2cell(outer_relChordUpperSkin);
        TEDs_struct{1,local_TED}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiUpperSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(11,3)));
        
    case 12            % outer relChordLowerSkin
        outer_relChordLowerSkin = event.NewData;
        if outer_relChordLowerSkin < 0
            outer_relChordLowerSkin = 0;
        elseif outer_relChordLowerSkin > 1
            outer_relChordLowerSkin = 1;
        end
        parameters_data(12,3) = num2cell(outer_relChordLowerSkin);
        TEDs_struct{1,local_TED}.outerShape{1,1}.outerBorder{1,1}.leadingEdgeShape{1,1}.xsiLowerSkin{1,1}.CONTENT = mat2str(cell2mat(parameters_data(12,3)));
end

set(handles_TED.table_parameters, 'Data', parameters_data);
Draw_TED(wing_geo, TEDs_struct, local_TED, startEle_compSeg, etaEles_compSeg)

end

function [] = Draw_TED(wing_geo, TEDs_struct, idx_TED, startEle_compSeg, etaEles_compSeg)
global handles_TED  
 
%--------------Draw wing sections airfoils / not change----------------
cam_pos_1 = get(handles_TED.axes_1, 'CameraPosition');                  % current camera position
cla(handles_TED.axes_1)
XYZ_all_airfoils = wing_geo.sectionDef.airfoil;

for i=1:length(XYZ_all_airfoils)    
    plot3(handles_TED.axes_1, XYZ_all_airfoils{i,1}(:,1), XYZ_all_airfoils{i,1}(:,2), XYZ_all_airfoils{i,1}(:,3),'g')
    axis equal
    hold(handles_TED.axes_1, 'on')         
end

%--------------Draw TEDs, added TED colored red---------------
[TEDs_Geo] = readControlSurfs_localStruct(TEDs_struct);
numOfTED=length( TEDs_Geo );

axes(handles_TED.axes_1)  
for i = 1 : numOfTED
    iTED_geo = TEDs_Geo{i};
    iTED_geo.wingSectionDef = wing_geo.sectionDef;
    iTED_geo.compSegStart = startEle_compSeg;
    iTED_geo.compSegEtas = etaEles_compSeg;
    [iTED_airfoils_global] = matrix_controlSurf_temp(iTED_geo);

    if i == idx_TED
        colr = 'r';
    else
        colr = 'b';
    end
   
   % for j = 1: length(iTED_airfoils_global)
       plot3(iTED_airfoils_global{1}(:,1), iTED_airfoils_global{1}(:,2), iTED_airfoils_global{1}(:,3), colr)
       hold(handles_TED.axes_1, 'on') 
       plot3(iTED_airfoils_global{end}(:,1), iTED_airfoils_global{end}(:,2), iTED_airfoils_global{end}(:,3), colr)
       hold(handles_TED.axes_1, 'on') 
   % end
end

% stop waiting for drawing
hold(handles_TED.axes_1, 'off')

%-------------------- axes titles ----------------
set(get(handles_TED.axes_1, 'xlabel'),'String','X')
set(get(handles_TED.axes_1, 'ylabel'),'String','Y')
set(get(handles_TED.axes_1, 'zlabel'),'String','Z')

set(handles_TED.axes_1, 'DataAspectRatio',[1 1 1]);
set(handles_TED.axes_1, 'CameraPosition', cam_pos_1);
grid(handles_TED.axes_1, 'on')
rotate3d(handles_TED.axes_1, 'on')

end

%% functions callback corresponding to buttons
function [] = Select(varargin)

global handles_TED TEDs_struct final_TEDs_struct

num_TED = length(TEDs_struct);
[TEDs_Geo] = readControlSurfs_localStruct(TEDs_struct);

added_etaLE_inner = TEDs_Geo{end}.etaLE(1); 
added_etaLE_outer = TEDs_Geo{end}.etaLE(2);

% error if 2 TEDs are crossing each other
if num_TED ~=1                            % If one or more certain component segment already exist;
    for i=1 : num_TED-1
        ith_inner = TEDs_Geo{i}.etaLE(1);
        ith_outer = TEDs_Geo{i}.etaLE(2);
        
        if added_etaLE_inner >= ith_inner && added_etaLE_inner <= ith_outer
            message = char('2 trailing edge devices are crossing each other', 'impossible to create this trailing edge device');
            errordlg(message);
            return
        end
        
        if added_etaLE_outer >= ith_inner && added_etaLE_outer <= ith_outer
            message = char('2 trailing edge devices are crossing each other', 'impossible to create this trailing edge device');
            errordlg(message);
            return
        end
    end
else                                           % If idx_compSeg = 1, no compseg exists before;
    disp('since no component segment exist, a new segment will be created')
end

%-----------------Write the new added TED info------------------
% create an inputdlg
prompt = {'Enter the UID:','Enter the name:', 'Enter the description:'};
dlg_title = 'UID name and description of TED';
num_lines = 1;
def = {'','',''};
answer = inputdlg(prompt, dlg_title, num_lines, def);

if isempty(answer{1})
    % create an errordlg
    errordlg('the UID can''t be empty');
    return
end

% add some informations in the TEDs_struct
TEDs_struct{1,num_TED}.ATTRIBUTE.uID = answer{1};
TEDs_struct{1,num_TED}.name{1,1}.CONTENT = answer{2};
TEDs_struct{1,num_TED}.description{1,1}.CONTENT = answer{3};

%----------------
final_TEDs_struct = TEDs_struct;
%----------------

pause(.1)
close(handles_TED.figure_TED)

end

function [] = Cancel (varargin)

global handles_TED

% create a question box
message = strcat('Do you really want to close this window and loose all the modifications ? ');
choice = questdlg(message, 'Cancel', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        % close the window
        close(handles_TED.figure_TED)
        
    case 'No'
        return;
end

end