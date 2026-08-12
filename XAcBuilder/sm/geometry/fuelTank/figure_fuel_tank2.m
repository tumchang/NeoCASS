function [] = figure_fuel_tank2(sparsRibs_struct, FTs_structure, idx_FT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Add new fuel tank for wing components                                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Pierre Saquet                                         %
% LastModified:     2013-04-21                                            %
% LastModifiedBy:   Pengfei Meng                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%                                                                         %
%  - add the possibility to add a fuel tank with 3 borders and the root   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear global FT_struct
global handles_FT   FTs_struct   final_FTs_struct   

% FTs_structure.change = 0; 
FTs_struct = FTs_structure;
final_FTs_struct = FTs_structure;

%% Figure
figure_fuel_tank.fh = figure('units','normalized',...
    'position',[0.1 0.2 0.5 0.7],...
    'menubar','none',...
    'Color',[.2 .2 .3],...
    'numbertitle','off',...
    'name','Add fuel tank',...
    'renderer', 'OpenGL',...
    'Tag','figure_fuel_tank',...
    'resize','off');     %  'WindowStyle', 'modal',...

figure_fuel_tank.colpb = [0.9255, 0.9137, 0.8471]; % Default Color of buttons

%% Panels
% Panel Drawing
figure_fuel_tank.up(1)= uipanel('Parent',figure_fuel_tank.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.1 1.0 0.7],...
                    'backgroundcolor', [1.0 1.0 1.0],...
                    'tag','Drawing');
                
% Panel button
figure_fuel_tank.up(2)= uipanel('Parent',figure_fuel_tank.fh ,'Title','',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.0 1.0 0.1],...
                    'tag','button');
                
% Panel spar borders selection
figure_fuel_tank.up(3)= uipanel('Parent',figure_fuel_tank.fh ,'Title','spar borders selection',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.9 1.0 0.1],...
                    'tag','spar_borders_selection');
                
% Panel rib borders selection
figure_fuel_tank.up(4)= uipanel('Parent',figure_fuel_tank.fh ,'Title','rib borders selection',...
                    'units','normalized',...
                    'BorderWidth', 2.0, ...
                    'position',[0.0 0.8 1.0 0.1],...
                    'tag','rib_borders_selection');
                
%% Panel Drawing
% axes 1
figure_fuel_tank.axes(1) = axes('Parent', figure_fuel_tank.up(1),...
                    'units','normalized',...
                    'Visible', 'off',...
                    'OuterPosition',[0.0 0.0 1.0 1.0],...
                    'tag', 'axes_1');
                
%% uicontrol panel button
% Push button Select
figure_fuel_tank.pb(1) = uicontrol('style','push',...
                    'parent', figure_fuel_tank.up(2),...
                    'units','normalized',...
                    'position',[0.1 0.2 0.35 0.6],...
                    'backg',figure_fuel_tank.colpb,...
                    'tag','Select',...
                    'string','Save','callback',{@Select, idx_FT});
                
% Push button Cancel
figure_fuel_tank.pb(2) = uicontrol('style','push',...
                    'parent', figure_fuel_tank.up(2),...
                    'units','normalized',...
                    'position',[0.55 0.2 0.35 0.6],...
                    'backg',figure_fuel_tank.colpb,...
                    'tag','Cancel',...
                    'string','Cancel','callback', @Cancel);
                
%% uicontrol panel spar borders selection

%--------------------First Spar Border-----------------------
[sparsRibs_geo] = sparsRibs_struct2geo(sparsRibs_struct);
    
sparSeg_uIDs = sparsRibs_geo.spars.segments.uIDs; 

% label
figure_fuel_tank.label(1) = uicontrol('Style', 'text',...
                'Parent', figure_fuel_tank.up(3),...
                'units','normalized',...
                'Position',[0.0 0.3 0.15 0.4],...
                'Tag','label',...
                'String', '1st border');

% Pop-up menu Select the first spar border
figure_fuel_tank.popupmenu(1) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_fuel_tank.up(3),...
                            'units','normalized',...
                            'Position',[0.15 0.3 0.35 0.4],...
                            'tag', 'select_first_spar_border',...
                            'backg',figure_fuel_tank.colpb,...
                            'String', sparSeg_uIDs(1 : end-1),...
                            'Value', 1,...
                            'callback', @select_first_spar_border);                       
handles_FT = guihandles(gcf);
guidata(gcf, handles_FT);

%--------------------Second Spar Border-----------------------
value = get(handles_FT.select_first_spar_border, 'Value');   

% label
figure_fuel_tank.label(2) = uicontrol('Style', 'text',...
                'Parent', figure_fuel_tank.up(3),...
                'units','normalized',...
                'Position',[0.5 0.3 0.15 0.4],...
                'Tag','label_2',...
                'String', '2nd border');
            
% Pop-up menu Select the last spar border
figure_fuel_tank.popupmenu(2) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_fuel_tank.up(3),...
                            'units','normalized',...
                            'Position',[0.65 0.3 0.35 0.4],...
                            'tag', 'select_last_spar_border',...
                            'backg',figure_fuel_tank.colpb,...
                            'String', sparSeg_uIDs(value+1 : end),...
                            'Value', 1,...
                            'callback', @select_last_spar_border);
                
h = findobj('tag','select_last_spar_border');
handles_FT.select_last_spar_border = h;

%% uicontrol panel rib borders selection

% num_ribsDef = length(sparsRibs_geo.ribsDefinitions.uIDs);
ribs_uIDs = sparsRibs_geo.ribsDefinitions.uIDs; 

%% ----------First Ribs Border--------------
figure_fuel_tank.label(3) = uicontrol('Style', 'text',...
                'Parent', figure_fuel_tank.up(4),...
                'units','normalized',...
                'Position',[0.0 0.3 0.15 0.4],...
                'Tag','label_3',...
                'String', '3rd border');

% Pop-up menu Select the first rib border
figure_fuel_tank.popupmenu(3) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_fuel_tank.up(4),...
                            'units','normalized',...
                            'Position',[0.15 0.5 0.35 0.5],...
                            'tag', 'select_first_rib_border',...
                            'backg',figure_fuel_tank.colpb,...
                            'String', ribs_uIDs,...
                            'Value', 1,...
                            'callback', @select_first_rib_border);

h = findobj('tag','select_first_rib_border');
handles_FT.select_first_rib_border = h;

value = get(handles_FT.select_first_rib_border, 'Value');              % value = 1; 
max_numRibs1 = sparsRibs_geo.ribsDefinitions.numberOfRibs(value); 
max_numRibs_string = num2cell([1: max_numRibs1]');

figure_fuel_tank.popupmenu(4) = uicontrol('Style', 'popupmenu',...         % Pop-up menu Select the rib number for the first border
                            'Parent', figure_fuel_tank.up(4),...
                            'units','normalized',...
                            'Position',[0.15 0.0 0.35 0.5],...
                            'tag', 'select_first_rib_number',...
                            'backg',figure_fuel_tank.colpb,...
                            'String', max_numRibs_string,...
                            'Value', 1,...
                            'callback', {@select_first_rib_number});

h = findobj('tag','select_first_rib_number');
handles_FT.select_first_rib_number = h;
                        
%% ---------Second Ribs Border--------------

% Pop-up menu Select the last rib border
if max_numRibs1 == 1
    last_ribstrings = ribs_uIDs(value+1 : end);
else
    last_ribstrings = ribs_uIDs(value : end);
end


figure_fuel_tank.label(4) = uicontrol('Style', 'text',...
                'Parent', figure_fuel_tank.up(4),...
                'units','normalized',...
                'Position',[0.5 0.3 0.15 0.4],...
                'Tag','label_4',...
                'String', '4th border');
figure_fuel_tank.popupmenu(5) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_fuel_tank.up(4),...
                            'units','normalized',...
                            'Position',[0.65 0.5 0.35 0.5],...
                            'tag', 'select_last_rib_border',...
                            'backg',figure_fuel_tank.colpb,...
                            'String', last_ribstrings,...
                            'Value', 1,...
                            'callback', @select_last_rib_border);
                        
h = findobj('tag','select_last_rib_border');
handles_FT.select_last_rib_border = h;
               
% Pop-up menu Select the last rib border number
value = get(handles_FT.select_last_rib_border, 'Value');
list_string = get(handles_FT.select_last_rib_border, 'String');
rib_definition_name_2 = list_string{value};
    
idx_ribs = strcmp(ribs_uIDs, rib_definition_name_2); 
max_numRibs2 = sparsRibs_geo.ribsDefinitions.numberOfRibs(idx_ribs); 

if max_numRibs1 == 1
    max_numRibs_string2 = num2cell([1: max_numRibs2]');
else
    max_numRibs_string2 = num2cell([2: max_numRibs2]');
end

figure_fuel_tank.popupmenu(6) = uicontrol('Style', 'popupmenu',...
                            'Parent', figure_fuel_tank.up(4),...
                            'units','normalized',...
                            'Position',[0.65 0.0 0.35 0.5],...
                            'tag', 'select_last_rib_number',...
                            'backg',figure_fuel_tank.colpb,...
                            'String', max_numRibs_string2,...
                            'Value', 1,...
                            'callback', @select_last_rib_number);

h = findobj('tag','select_last_rib_number');
handles_FT.select_last_rib_number = h;

Draw_spars_ribs(FTs_struct, 1, sparsRibs_struct)

end

function [] = Draw_spars_ribs(FTs_struct, init, varargin)
%----Plus draw fuel tanks that already exists-------------

global handles_FT   ah_sparboard  ah_riboard
global sparsRibs_geo  vertices_ribs  facets_ribs  vertices_spars  facets_spars

cam_pos_1 = get(handles_FT.axes_1, 'CameraPosition');

%------------Spars and Ribs Display----------
axes(handles_FT.axes_1)
if init == 1
    sparsRibs_struct = varargin{1}; 
    [Spar_segments, rib_cell, Wings, sparsRibs_geo] = spars_ribs6(sparsRibs_struct);
    [vertices_ribs, facets_ribs, vertices_spars, facets_spars] = sparRibs2triangles(Spar_segments, rib_cell, 0);
    
    
    patch('Vertices', vertices_spars, 'Faces', facets_spars,'EdgeColor','g','FaceColor', 'none');
    hold on
    patch('Vertices', vertices_ribs, 'Faces', facets_ribs,'EdgeColor','g', 'FaceColor', 'none');
    hold on
    %-------------Fuel Tanks that already exist------------
    if ~isempty(FTs_struct)
        numFTs = length(FTs_struct);
        for i = 1: numFTs
            iFT_struct = FTs_struct{i};
            iFT_struct.Wings = Wings;
            [FT_rib_vertices, FT_faces] = fuel_tanks2(iFT_struct,  0);
            
            patch('Vertices', FT_rib_vertices, 'Faces', FT_faces,'EdgeColor','b','FaceColor', 'none', 'LineWidth',2);
            hold on
        end
        
    end
    
    set(get(handles_FT.axes_1, 'xlabel'),'String','X')
    set(get(handles_FT.axes_1, 'ylabel'),'String','Y')
    set(get(handles_FT.axes_1, 'zlabel'),'String','Z')
    
    set(handles_FT.axes_1, 'DataAspectRatio',[1 1 1]);
    set(handles_FT.axes_1, 'CameraPosition', cam_pos_1);
    
    grid(handles_FT.axes_1, 'on')
    rotate3d(handles_FT.axes_1, 'on')
end    
    
    %--------------Highlight the new possible created FT-------------
    %----------------Get the spar borders---------------
    spars1_value = get(handles_FT.select_first_spar_border, 'Value');
    spars1_list = get(handles_FT.select_first_spar_border, 'String');
    first_spar = spars1_list{spars1_value};
    
    spars2_value = get(handles_FT.select_last_spar_border, 'Value');
    spars2_list = get(handles_FT.select_last_spar_border, 'String');
    last_spar = spars2_list{spars2_value};
    
    sparSegs_uIDs = sparsRibs_geo.spars.segments.uIDs; 
    spar1_loc = find(strcmp(sparSegs_uIDs, first_spar)); 
    spar2_loc = find(strcmp(sparSegs_uIDs, last_spar));
    
    nodx = 0; 
    u = 0; 
    sparSegs_verts = cell(length(sparSegs_uIDs), 1); 
    for j = 1: size(facets_spars, 2)-1
       temp_idx = intersect(facets_spars(j,:), facets_spars(j+1,:));  
       if isempty(temp_idx)
           u = u + 1; 
           sparSegs_verts{u} = facets_spars(nodx+1:j,:);
           nodx = j;
       end       
    end
    sparSegs_verts{end} = facets_spars(nodx+1:end,:);    
   
    %----------Get the ribs borders, plus the rib_number--------
    % get the first rib name
    ribs1_value = get(handles_FT.select_first_rib_border, 'Value');
    ribs1_list = get(handles_FT.select_first_rib_border, 'String');
    ribs1_name =  ribs1_list{ribs1_value};
    ribs1_numbervalue = get(handles_FT.select_first_rib_number, 'Value');
    ribs1_numberlist = get(handles_FT.select_first_rib_number, 'String');
    ribs1_number = str2num(ribs1_numberlist{ribs1_numbervalue});
    
    % get the last rib name
    ribs2_value = get(handles_FT.select_last_rib_border, 'Value');
    ribs2_list = get(handles_FT.select_last_rib_border, 'String');
    ribs2_name =  ribs2_list{ribs2_value};
    ribs2_numbervalue = get(handles_FT.select_last_rib_number, 'Value');
    ribs2_numberlist = get(handles_FT.select_last_rib_number, 'String');
    ribs2_number = str2num(ribs2_numberlist{ribs2_numbervalue});
    
    ribs_uIDs = sparsRibs_geo.ribsDefinitions.uIDs;
    
    ribs1_loc = find(strcmp(ribs_uIDs, ribs1_name));
    if ribs1_loc == 1
        ribs1_idx = ribs1_number;
    else
        ribs1_idx = sum(sparsRibs_geo.ribsDefinitions.numberOfRibs(1 : ribs1_loc-1)) + ribs1_number;
    end
    
    ribs2_loc = find(strcmp(ribs_uIDs, ribs2_name));
    if ribs2_loc == 1
        ribs2_idx = ribs2_number;
    else
        ribs2_idx = sum(sparsRibs_geo.ribsDefinitions.numberOfRibs(1 : ribs2_loc-1)) + ribs2_number;
    end
    
   
try 
    delete(ah_sparboard);
    delete(ah_riboard);
end

spars_newboard_facets = cell2mat(sparSegs_verts([spar1_loc,spar2_loc]));   
axes(handles_FT.axes_1) 
ah_sparboard = patch('Vertices', vertices_spars, 'Faces', spars_newboard_facets,'EdgeColor','r','FaceColor', 'none', 'LineWidth',2);
hold on

ribs_newboard_facets = facets_ribs([ribs1_idx, ribs2_idx], :);
axes(handles_FT.axes_1) 
ah_riboard = patch('Vertices', vertices_ribs, 'Faces', ribs_newboard_facets,'EdgeColor','r','FaceColor', 'none', 'LineWidth',2);
hold on
end



%% functions callback corresponding to buttons
function [] = Select(varargin)
global handles_FT   FTs_struct  final_FTs_struct  sparsRibs_geo

idx_FT = varargin{3};
spars_uIDs = sparsRibs_geo.spars.segments.uIDs; 
ribs_uIDs = sparsRibs_geo.ribsDefinitions.uIDs;

%---------------Spars-----------------------
spars1_value = get(handles_FT.select_first_spar_border, 'Value');
spars1_list = get(handles_FT.select_first_spar_border, 'String');
spar1_uID = spars1_list{spars1_value};

spars2_value = get(handles_FT.select_last_spar_border, 'Value');
spars2_list = get(handles_FT.select_last_spar_border, 'String');
spar2_uID = spars2_list{spars2_value};

%-----------------Ribs-----------------
ribs1_value = get(handles_FT.select_first_rib_border, 'Value');
ribs1_list = get(handles_FT.select_first_rib_border, 'String');
ribs1_name =  ribs1_list{ribs1_value};
ribs1_numbervalue = get(handles_FT.select_first_rib_number, 'Value');
ribs1_numberlist = get(handles_FT.select_first_rib_number, 'String');
ribs1_number = str2num(ribs1_numberlist{ribs1_numbervalue});

% get the last rib name
ribs2_value = get(handles_FT.select_last_rib_border, 'Value');
ribs2_list = get(handles_FT.select_last_rib_border, 'String');
ribs2_name =  ribs2_list{ribs2_value};
ribs2_numbervalue = get(handles_FT.select_last_rib_number, 'Value');
ribs2_numberlist = get(handles_FT.select_last_rib_number, 'String');
ribs2_number = str2num(ribs2_numberlist{ribs2_numbervalue});
    
%------See to that the new FT doesn't intersect with existing FTs------
%------The attempted new FT's ribs index ----------
    ribs1_loc = find(strcmp(ribs_uIDs, ribs1_name));
    if ribs1_loc == 1
        ribs1_idx = ribs1_number;
    else
        ribs1_idx = sum(sparsRibs_geo.ribsDefinitions.numberOfRibs(1 : ribs1_loc-1)) + ribs1_number;
    end
    
    ribs2_loc = find(strcmp(ribs_uIDs, ribs2_name));
    if ribs2_loc == 1
        ribs2_idx = ribs2_number;
    else
        ribs2_idx = sum(sparsRibs_geo.ribsDefinitions.numberOfRibs(1 : ribs2_loc-1)) + ribs2_number;
    end
    %-------The ribs index of the existing FuelTanks----------
    num_FTs = length(FTs_struct);
    for i = 1: num_FTs
        iFT_struct = FTs_struct{1,i};
        exist_ribs1_uID = iFT_struct.geometry{1,1}.border{1,2}.ribDefinitionUID{1,1}.CONTENT;
        exist_ribs1_num = str2num(iFT_struct.geometry{1,1}.border{1,2}.ribNumber{1,1}.CONTENT);
        
        exist_ribs1_loc = find(strcmp(ribs_uIDs, exist_ribs1_uID));
        if exist_ribs1_loc == 1
            exist_ribs1_idx = exist_ribs1_num;
        else
            exist_ribs1_idx = sum(sparsRibs_geo.ribsDefinitions.numberOfRibs(1 : exist_ribs1_loc-1)) + exist_ribs1_num;
        end
 
        try
            exist_ribs2_uID = iFT_struct.geometry{1,1}.border{1,4}.ribDefinitionUID{1,1}.CONTENT;
            exist_ribs2_num = str2num(iFT_struct.geometry{1,1}.border{1,4}.ribNumber{1,1}.CONTENT);
            
            exist_ribs2_loc = find(strcmp(ribs_uIDs, exist_ribs2_uID));
            if exist_ribs2_loc == 1
                exist_ribs2_idx = exist_ribs2_num;
            else
                exist_ribs2_idx = sum(sparsRibs_geo.ribsDefinitions.numberOfRibs(1 : exist_ribs2_loc-1)) + exist_ribs2_num;
            end
        catch
             exist_ribs2_idx = 1; 
        end
        
        if (ribs1_idx - exist_ribs1_idx)*(ribs1_idx - exist_ribs2_idx) <= 0          
            message = char('The attempted new fuel tank crosses one existing fuel tank', 'impossible to create this new one');
            errordlg(message);
            return
        end
        
        if (ribs2_idx - exist_ribs1_idx)*(ribs2_idx - exist_ribs2_idx) <= 0        
            message = char('The attempted new fuel tank crosses one existing fuel tank', 'impossible to create this new one');
            errordlg(message);
            return
        end
    end

    
%-------------Construct the new FuelTank----------
prompt = {'Enter the UID:'};
dlg_title = 'UID of fuel tank (without space)';
num_lines = 1;
def = {''};
answer = inputdlg(prompt, dlg_title, num_lines, def);

if isempty(answer{1})
    errordlg('the UID can''t be empty'); 
    return
end

FTs_struct{1,idx_FT}.ATTRIBUTE.uID = answer{1};
FTs_struct{1,idx_FT}.geometry{1,1}.border{1,1}.sparUID{1,1}.CONTENT = spar1_uID ;
FTs_struct{1,idx_FT}.geometry{1,1}.border{1,2}.ribDefinitionUID{1,1}.CONTENT = ribs1_name;
FTs_struct{1,idx_FT}.geometry{1,1}.border{1,2}.ribNumber{1,1}.CONTENT = num2str(ribs1_number);
FTs_struct{1,idx_FT}.geometry{1,1}.border{1,3}.sparUID{1,1}.CONTENT = spar2_uID;
FTs_struct{1,idx_FT}.geometry{1,1}.border{1,4}.ribDefinitionUID{1,1}.CONTENT = ribs2_name;
FTs_struct{1,idx_FT}.geometry{1,1}.border{1,4}.ribNumber{1,1}.CONTENT = num2str(ribs2_number);

% FTs_struct.change = FTs_struct.change + 1; 
final_FTs_struct = FTs_struct; 

pause(.1)
close(handles_FT.figure_fuel_tank)

end

function [] = Cancel (varargin)
global handles_FT

message = strcat('Do you really want to close this window and loose all the modifications ? ');
choice = questdlg(message, 'Cancel', 'Yes', 'No', 'No');

switch choice
    case 'Yes'
        close(handles_FT.figure_fuel_tank)
        
    case 'No'
        return;
end

end

%% functions callback corresponding to popup-menus
function [] = select_first_spar_border(varargin)
global handles_FT   sparsRibs_geo   FTs_struct

sparSeg_uIDs = sparsRibs_geo.spars.segments.uIDs; 

spar1_value = get(handles_FT.select_first_spar_border, 'Value');
                      
set(handles_FT.select_last_spar_border, 'String', sparSeg_uIDs(spar1_value+1:end));
set(handles_FT.select_last_spar_border, 'Value', 1);

Draw_spars_ribs(FTs_struct, 0)

end

function [] = select_last_spar_border(varargin)
global FTs_struct

Draw_spars_ribs(FTs_struct, 0)
end

function [] = select_first_rib_border(varargin)
global handles_FT   sparsRibs_geo  FTs_struct

ribs_uIDs = sparsRibs_geo.ribsDefinitions.uIDs; 

ribs1_value = get(handles_FT.select_first_rib_border, 'Value');
max_numRibs1 = sparsRibs_geo.ribsDefinitions.numberOfRibs(ribs1_value); 
max_numRibs_string1 = num2cell([1: max_numRibs1]');

set(handles_FT.select_first_rib_number, 'String', max_numRibs_string1);
set(handles_FT.select_first_rib_number, 'Value', 1);


% set the list string for the last rib border
if max_numRibs1 == 1
    set(handles_FT.select_last_rib_border, 'String', ribs_uIDs(ribs1_value+1 : end));
    max_numRibs2 = sparsRibs_geo.ribsDefinitions.numberOfRibs(ribs1_value + 1); 
    max_numRibs_string2 = num2cell([1: max_numRibs2]');
else
    set(handles_FT.select_last_rib_border, 'String', ribs_uIDs(ribs1_value : end));  
    max_numRibs2 = sparsRibs_geo.ribsDefinitions.numberOfRibs(ribs1_value); 
    max_numRibs_string2 = num2cell([2: max_numRibs2]');
end

set(handles_FT.select_last_rib_number, 'String', max_numRibs_string2);
set(handles_FT.select_last_rib_number, 'Value', 1);

% 
% % ribs2_value = get(handles_FT.select_last_rib_border, 'Value');
% % ribs2_list = get(handles_FT.select_last_rib_border, 'String');
% 
% 
% ribs2_idx = strcmp(ribs_uIDs, ribs2_name); 
% max_numRibs2 = sparsRibs_geo.ribsDefinitions.numberOfRibs(ribs2_idx); 
% max_numRibs_string2 = num2cell([1: max_numRibs2]');


Draw_spars_ribs(FTs_struct, 0)
end

function [] = select_last_rib_border(varargin)
global handles_FT  sparsRibs_geo  FTs_struct
ribs_uIDs = sparsRibs_geo.ribsDefinitions.uIDs; 

ribs2_value = get(handles_FT.select_last_rib_border, 'Value');
ribs2_list = get(handles_FT.select_last_rib_border, 'String');
ribs2_name = ribs2_list{ribs2_value};

ribs2_idx = strcmp(ribs_uIDs, ribs2_name); 
max_numRibs2 = sparsRibs_geo.ribsDefinitions.numberOfRibs(ribs2_idx); 
max_numRibs_string2 = num2cell([1: max_numRibs2]');
set(handles_FT.select_last_rib_number, 'String', max_numRibs_string2);
set(handles_FT.select_last_rib_number, 'Value', 1);

Draw_spars_ribs(FTs_struct, 0)

end

function [] = select_first_rib_number(varargin)
global handles_FT  FTs_struct  sparsRibs_geo

% ribs_uIDs = sparsRibs_geo.ribsDefinitions.uIDs; 

ribs1_value = get(handles_FT.select_first_rib_border, 'Value');
max_numRibs1 = sparsRibs_geo.ribsDefinitions.numberOfRibs(ribs1_value); 

if max_numRibs1 ~= 1
    ribs1_numbervalue = get(handles_FT.select_first_rib_number, 'Value');
    ribs1_numberlist = get(handles_FT.select_first_rib_number, 'String');
    ribs1_number = str2num(ribs1_numberlist{ribs1_numbervalue});
    
    max_numRibs_string2 = num2cell([ribs1_number + 1: max_numRibs1]');
     
    set(handles_FT.select_last_rib_number, 'String', max_numRibs_string2);
end

Draw_spars_ribs(FTs_struct, 0)

end

function [] = select_last_rib_number(varargin)
global FTs_struct

Draw_spars_ribs(FTs_struct, 0)

end