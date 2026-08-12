function [element_struct] = add_section_confirmed(section_number, stage_element_struct, element_struct)
% now the user has confirmed to add the section; 
% here make the user to input the added section, positionings, segments names
% and store the input names into element_struct  
numSecs_added = length(stage_element_struct.sections{1,1}.section) + 1;

%% ----------// Construct the new section block \\-------------%
prompt = {'Enter the Name for the added Section (no space inbetween, for short the section name is taken as the element name also )'};
dlg_title = 'Input';
num_lines = 1;
def = {'addedSec_1'};
added_name = inputdlg(prompt,dlg_title,num_lines, def);

for i = 1:length(stage_element_struct.sections{1,1}.section)
   curtI_name = stage_element_struct.sections{1,1}.section{1,i}.name{1,1}.CONTENT; 
   if strcmp(curtI_name, added_name{1})
       warndlg('the name already existed, change a different name!')
       return
   end
end

%--------------------------------------------
added_section_name = added_name{1};                                    % strcat(previous_section_name, 'added');
added_section_uID = strcat(added_name{1},'ID');
added_element_uID = strcat(added_name{1},'IDElement1');

element_struct.sections{1,1}.section{1,section_number}.name{1,1}.CONTENT = added_section_name;
element_struct.sections{1,1}.section{1,section_number}.ATTRIBUTE.uID = added_section_uID;
element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.name{1,1}.CONTENT = added_section_name;
element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.ATTRIBUTE.uID = added_element_uID;
 
%% ----------// Construct the new corresponding positioning block \\------%
if  section_number == numSecs_added    % only one new positioning is attached to the end    
    %------------------------ Name for the added Positioning ----------------
    prompt = {'Enter the Name for the added Positioning (no space inbetween)'};
    dlg_title = 'Input';
    num_lines = 1;
    def = {'addedPos_1'};    
    options.Resize='on';
    options.WindowStyle='normal';
    added_PosName = inputdlg(prompt,dlg_title,num_lines, def, options);
    
    for i = 1:length(stage_element_struct.positionings{1,1}.positioning)
        curtI_name = stage_element_struct.positionings{1,1}.positioning{1,i}.name{1,1}.CONTENT;
        if strcmp(curtI_name, added_PosName{1})
            warndlg('the name already existed, change a different name for the Positioning!')
            return
        end
    end
    %---------------------------------------------------------------------------        
    positioning_name = added_PosName{1};
    
    element_struct.positionings{1,1}.positioning{1,section_number}.ATTRIBUTE.uID = strcat(positioning_name,'ID');
    element_struct.positionings{1,1}.positioning{1,section_number}.name{1,1}.CONTENT = positioning_name;
    element_struct.positionings{1,1}.positioning{1,section_number}.toSectionUID{1,1}.CONTENT = added_section_uID;
    
else   %  section_number == 1                % two new positionings replace the previous section_number positioning
    %---------------Name for the two added Positioning------------
    prompt = {'Name for added Positioning 1:','Name for added Positioning 2:'};
    dlg_title = 'Input';
    num_lines = 1;
    def = {'addedPos_1','addedPos_2'};
    options.Resize='on';
    options.WindowStyle='normal';
    added_PosNames = inputdlg(prompt,dlg_title,num_lines,def, options);
    
    for i = 1:length(stage_element_struct.positionings{1,1}.positioning)
        curtI_name = stage_element_struct.positionings{1,1}.positioning{1,i}.name{1,1}.CONTENT;
        if strcmp(curtI_name, added_PosNames{1}) 
            warndlg('The first name already existed, change a different name for the Positioning!')
            return
        end
        
        if  strcmp(curtI_name, added_PosNames{2})
            warndlg('The second name already existed, change a different name for the Positioning!')
            return
        end
    end
    %-------------------------------------------------------------    
    positioning_name1 = added_PosNames{1};    
    element_struct.positionings{1,1}.positioning{1,section_number}.ATTRIBUTE.uID = strcat(positioning_name1,'ID');
    element_struct.positionings{1,1}.positioning{1,section_number}.name{1,1}.CONTENT = positioning_name1;    
    element_struct.positionings{1,1}.positioning{1,section_number}.toSectionUID{1,1}.CONTENT = added_section_uID;
    %---------------------------------------------------------------%
    positioning_name2 = added_PosNames{2};    
    element_struct.positionings{1,1}.positioning{1,section_number+1}.ATTRIBUTE.uID = strcat(positioning_name2,'ID');
    element_struct.positionings{1,1}.positioning{1,section_number+1}.name{1,1}.CONTENT = positioning_name2; 
    element_struct.positionings{1,1}.positioning{1,section_number+1}.fromSectionUID{1,1}.CONTENT = added_section_uID;
    
end

%% ----------// Construct the new corresponding segment block \\---------%
% Read relevant segment info
if section_number == 1                   % only one segment was added at the beginning
    %-------------------Name for the added Segment-------------------
    prompt = {'Enter the Name for the added Segment (no space inbetween, name and uID taken as the same)'};
    dlg_title = 'Input';
    num_lines = 1;
    def = {'addedSeg_1'};    
    options.Resize='on';
    options.WindowStyle='normal';
    added_SegName = inputdlg(prompt,dlg_title,num_lines, def, options);
    
    for i = 1:length(stage_element_struct.segments{1,1}.segment)
        curtI_name = stage_element_struct.segments{1,1}.segment{1,i}.name{1,1}.CONTENT;
        if strcmp(curtI_name, added_SegName{1})
            warndlg('the name already existed, change a different name for the Segment!')
            return
        end
    end
    %-----------------------------------------    
    
    element_struct.segments{1,1}.segment{1,section_number}.name{1,1}.CONTENT = added_SegName{1};
    element_struct.segments{1,1}.segment{1,section_number}.ATTRIBUTE.uID = added_SegName{1};
    element_struct.segments{1,1}.segment{1,section_number}.fromElementUID{1,1}.CONTENT = added_element_uID;
    
elseif section_number == numSecs_added   % only one segment was added at the end
    %-------------------Name for the added Segment-------------------
    prompt = {'Enter the Name for the added Segment (no space inbetween, name and uID taken as the same)'};
    dlg_title = 'Input';
    num_lines = 1;
    def = {'addedSeg_1'};    
    options.Resize='on';
    options.WindowStyle='normal';
    added_SegName = inputdlg(prompt,dlg_title,num_lines, def, options);
    
    for i = 1:length(stage_element_struct.segments{1,1}.segment)
        curtI_name = stage_element_struct.segments{1,1}.segment{1,i}.name{1,1}.CONTENT;
        if strcmp(curtI_name, added_SegName{1})
            warndlg('the name already existed, change a different name for the Segment!')
            return
        end
    end
    %-----------------------------------------        
    element_struct.segments{1,1}.segment{1,section_number-1}.name{1,1}.CONTENT = added_SegName{1};
    element_struct.segments{1,1}.segment{1,section_number-1}.ATTRIBUTE.uID = added_SegName{1};
    element_struct.segments{1,1}.segment{1,section_number-1}.toElementUID{1,1}.CONTENT = added_element_uID;
    
else                                     % two new segments replace the previous old one
    
   %---------------Name for the two added Positioning------------
    prompt = {'Name for added Segment 1:','Name for added Segment 2:'};
    dlg_title = 'Input';
    num_lines = 1;
    def = {'addedSeg_1','addedSeg_2'};
    options.Resize='on';
    options.WindowStyle='normal';
    added_SegNames = inputdlg(prompt,dlg_title,num_lines,def, options);
    
    for i = 1:length(stage_element_struct.segments{1,1}.segment)
        curtI_name = stage_element_struct.segments{1,1}.segment{1,i}.name{1,1}.CONTENT;
        if strcmp(curtI_name, added_SegNames{1}) 
            warndlg('The first name already existed, change a different name for added Segment1!')
            return
        end
        
        if  strcmp(curtI_name, added_SegNames{2})
            warndlg('The second name already existed, change a different name for added Segment2')
            return
        end
    end
    %-------------------------------------------------------------
    
    element_struct.segments{1,1}.segment{1,section_number-1}.name{1,1}.CONTENT = added_SegNames{1};
    element_struct.segments{1,1}.segment{1,section_number-1}.ATTRIBUTE.uID = added_SegNames{1};
    element_struct.segments{1,1}.segment{1,section_number-1}.toElementUID{1,1}.CONTENT = added_element_uID;
      
    element_struct.segments{1,1}.segment{1,section_number}.name{1,1}.CONTENT = added_SegNames{2};
    element_struct.segments{1,1}.segment{1,section_number}.ATTRIBUTE.uID = added_SegNames{2};
    element_struct.segments{1,1}.segment{1,section_number}.fromElementUID{1,1}.CONTENT = added_element_uID; 
   
end
end

