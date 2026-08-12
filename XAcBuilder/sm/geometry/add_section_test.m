function [] = add_section_test(local_element_type)
% add a section into element_struct

global section_number  stage_element_struct  element_struct

% numSecs = length(stage_element_struct.sections{1,1}.section); 
numSecs_added = length(stage_element_struct.sections{1,1}.section) + 1;

%% ----------// Construct the new section block \\-------------%
if section_number == numSecs_added
    relevant_SecName = stage_element_struct.sections{1,1}.section{1,section_number-1}.name{1,1}.CONTENT;
else
    relevant_SecName = stage_element_struct.sections{1,1}.section{1,section_number}.name{1,1}.CONTENT;
end

added_name = [relevant_SecName,'1']; 
%--------------------------------------------

added_section_name = added_name;                                    % strcat(previous_section_name, 'added');
added_section_uID = strcat(added_name,'ID');
added_element_uID = strcat(added_name,'IDElement1');

added_section.name{1,1}.CONTENT = added_section_name;
added_section.ATTRIBUTE.uID = added_section_uID;

added_section.elements{1,1}.element{1,1}.name{1,1}.CONTENT = added_section_name;
added_section.elements{1,1}.element{1,1}.ATTRIBUTE.uID = added_element_uID;

if section_number == numSecs_added
    added_section.transformation{1,1} = stage_element_struct.sections{1,1}.section{1,section_number-1}.transformation{1,1};
    added_section.elements{1,1}.element{1,1}.transformation{1,1} = stage_element_struct.sections{1,1}.section{1,section_number-1}.elements{1,1}.element{1,1}.transformation{1,1};
else
    added_section.transformation{1,1} = stage_element_struct.sections{1,1}.section{1,section_number}.transformation{1,1};
    added_section.elements{1,1}.element{1,1}.transformation{1,1} = stage_element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.transformation{1,1};
end

switch local_element_type                                                    % find the profile corresponding with the section number
    case 'fuselages'
        if section_number == numSecs_added
            added_section.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT = stage_element_struct.sections{1,1}.section{1,section_number-1}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT;
        else
            added_section.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT = stage_element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.profileUID{1,1}.CONTENT;
        end
    case 'wings'
        if section_number == numSecs_added
            added_section.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT = stage_element_struct.sections{1,1}.section{1,section_number-1}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT;
        else
            added_section.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT = stage_element_struct.sections{1,1}.section{1,section_number}.elements{1,1}.element{1,1}.airfoilUID{1,1}.CONTENT;
        end
end


%------ Insert these new blocks into the old_series of blocks ------% 

temp_section = cell(1,numSecs_added);

if section_number ~= 1
    temp_section(1:section_number-1) = stage_element_struct.sections{1,1}.section(1:section_number-1);
end

 temp_section{1,section_number} = added_section; 

if section_number ~= numSecs_added
    temp_section(section_number+1:end) = stage_element_struct.sections{1,1}.section(section_number:end);
end

element_struct.sections{1,1}.section = temp_section; 

%% ----------// Construct the new corresponding positioning block \\------%
if section_number == numSecs_added
    ref_index = section_number-1;
else
    ref_index = section_number;
end
previous_positioning_name = stage_element_struct.positionings{1,1}.positioning{1,ref_index}.name{1,1}.CONTENT;
previous_length = str2double(stage_element_struct.positionings{1,1}.positioning{1,ref_index}.length{1,1}.CONTENT);
previous_sweepangle = stage_element_struct.positionings{1,1}.positioning{1,ref_index}.sweepAngle{1,1}.CONTENT;
previous_dihedralangle = stage_element_struct.positionings{1,1}.positioning{1,ref_index}.dihedralAngle{1,1}.CONTENT;
previous_toSec = stage_element_struct.positionings{1,1}.positioning{1,ref_index}.toSectionUID{1,1}.CONTENT;

if section_number ~= 1
    previous_fromSec = stage_element_struct.positionings{1,1}.positioning{1,ref_index}.fromSectionUID{1,1}.CONTENT;
end

if  section_number == numSecs_added    % only one new positioning is attached to the end    
    %------------------------ Name for the added Positioning ----------------
    added_PosName = [previous_positioning_name,'1']; 
    %---------------------------------------------------------------------------        
    positioning_name = added_PosName;
    
    added_positioning.ATTRIBUTE.uID = strcat(positioning_name,'ID');
    added_positioning.name{1,1}.CONTENT = positioning_name;
    
    added_positioning.length{1,1}.CONTENT = num2str( previous_length/2 );
    added_positioning.sweepAngle{1,1}.CONTENT = previous_sweepangle;
    added_positioning.dihedralAngle{1,1}.CONTENT = previous_dihedralangle;
    
    added_positioning.fromSectionUID{1,1}.CONTENT = previous_toSec;
    added_positioning.toSectionUID{1,1}.CONTENT = added_section_uID;
    
else   %  section_number == 1                % two new positionings replace the previous section_number positioning
    %---------------Name for the two added Positioning------------
    added_PosNames = {[previous_positioning_name,'1'],[previous_positioning_name,'2']}; 
    %-------------------------------------------------------------
    
    positioning_name1 = added_PosNames{1};
    
    added_positioning1.ATTRIBUTE.uID = strcat(positioning_name1,'ID');
    added_positioning1.name{1,1}.CONTENT = positioning_name1;
    
    added_positioning1.length{1,1}.CONTENT = num2str( previous_length/2 );
    added_positioning1.sweepAngle{1,1}.CONTENT = previous_sweepangle;
    added_positioning1.dihedralAngle{1,1}.CONTENT = previous_dihedralangle;
    
    added_positioning1.toSectionUID{1,1}.CONTENT = added_section_uID;
    
    if section_number ~= 1
        added_positioning1.fromSectionUID{1,1}.CONTENT = previous_fromSec;
    end
    %---------------------------------------------------------------%
    positioning_name2 = added_PosNames{2};
    
    added_positioning2.ATTRIBUTE.uID = strcat(positioning_name2,'ID');
    added_positioning2.name{1,1}.CONTENT = positioning_name2;
    
    added_positioning2.length{1,1}.CONTENT = num2str( previous_length/2 );
    added_positioning2.sweepAngle{1,1}.CONTENT = previous_sweepangle;
    added_positioning2.dihedralAngle{1,1}.CONTENT = previous_dihedralangle;
    
    added_positioning2.fromSectionUID{1,1}.CONTENT = added_section_uID;
    added_positioning2.toSectionUID{1,1}.CONTENT = previous_toSec;
    
end

%---- Assign the positioning to element_struct -----%

temp_position = cell(1, numSecs_added);

if  section_number == 1
  temp_position{1,section_number} = added_positioning1;
  temp_position{1,section_number+1} = added_positioning2;
  temp_position(section_number+2:end) = stage_element_struct.positionings{1,1}.positioning(section_number+1:end);
    
elseif  section_number == numSecs_added  
  temp_position(1:section_number-1) = stage_element_struct.positionings{1,1}.positioning(1:section_number-1);
  temp_position{1,section_number} = added_positioning;

else
  temp_position(1:section_number-1) = stage_element_struct.positionings{1,1}.positioning(1:section_number-1);
  temp_position{1,section_number} = added_positioning1;
  temp_position{1,section_number+1} = added_positioning2;
  temp_position(section_number+2:end) = stage_element_struct.positionings{1,1}.positioning(section_number+1:end);   
end

element_struct.positionings{1,1}.positioning = temp_position; 

%% ----------// Construct the new corresponding segment block \\---------%
% Read relevant segment info

if section_number == numSecs_added
    ref_idx = section_number - 2; 
elseif section_number == 1
    ref_idx = section_number; 
else
    ref_idx = section_number-1; 
end

% relevant_segment_uID = stage_element_struct.segments{1,1}.segment{1,ref_idx}.ATTRIBUTE.uID;
relevant_segment_name = stage_element_struct.segments{1,1}.segment{1,ref_idx}.name{1,1}.CONTENT;
relevant_fromElementUID = stage_element_struct.segments{1,1}.segment{1,ref_idx}.fromElementUID{1,1}.CONTENT;
relevant_toElementUID = stage_element_struct.segments{1,1}.segment{1,ref_idx}.toElementUID{1,1}.CONTENT;

if section_number == 1                   % only one segment was added at the beginning
    %-------------------Name for the added Segment-------------------    
    added_SegName = [relevant_segment_name,'1'];
    %-----------------------------------------    
    
    added_segment.name{1,1}.CONTENT = added_SegName;
    added_segment.ATTRIBUTE.uID = added_SegName;
    added_segment.fromElementUID{1,1}.CONTENT = added_element_uID;
    added_segment.toElementUID{1,1}.CONTENT = relevant_fromElementUID;
    
elseif section_number == numSecs_added   % only one segment was added at the end
    %-------------------Name for the added Segment-------------------
    added_SegName = [relevant_segment_name,'1'];
    %-----------------------------------------    
    
    added_segment.name{1,1}.CONTENT = added_SegName;
    added_segment.ATTRIBUTE.uID = added_SegName;
    added_segment.fromElementUID{1,1}.CONTENT = relevant_toElementUID; 
    added_segment.toElementUID{1,1}.CONTENT = added_element_uID;
    
else                                     % two new segments replace the previous old one
    
   %---------------Name for the two added Positioning------------
    added_SegNames = {[relevant_segment_name,'1'], [relevant_segment_name,'2']}; 
    %-------------------------------------------------------------
    added_segment1.name{1,1}.CONTENT = added_SegNames{1};
    added_segment1.ATTRIBUTE.uID = added_SegNames{1};
    added_segment1.fromElementUID{1,1}.CONTENT = relevant_fromElementUID; 
    added_segment1.toElementUID{1,1}.CONTENT = added_element_uID;
      
    added_segment2.name{1,1}.CONTENT = added_SegNames{2};
    added_segment2.ATTRIBUTE.uID = added_SegNames{2};
    added_segment2.fromElementUID{1,1}.CONTENT = added_element_uID; 
    added_segment2.toElementUID{1,1}.CONTENT = relevant_toElementUID; 
    
end


temp_segment = cell(1, numSecs_added-1);
if section_number == 1
     temp_segment{1,section_number} = added_segment;
     temp_segment(section_number+1:end) = stage_element_struct.segments{1,1}.segment(section_number:end);
elseif section_number == numSecs_added   
     temp_segment(1:section_number-2) = stage_element_struct.segments{1,1}.segment(1:section_number-2);
     temp_segment{1,section_number-1} = added_segment;
else
     temp_segment(1:section_number-2) = stage_element_struct.segments{1,1}.segment(1:section_number-2);
     temp_segment{1,section_number-1} = added_segment1;
     temp_segment{1,section_number} = added_segment2;
     temp_segment(section_number+1:end) = stage_element_struct.segments{1,1}.segment(section_number:end);
end

 element_struct.segments{1,1}.segment = temp_segment; 
end

