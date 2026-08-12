function  [sparsRibs_struct] = build_sparsRibs_skeleton(sparsRibs_struct)
% set default values for spars and ribs

wingSectionDef = sparsRibs_struct.wingSectionDef;  
number_of_sections = length(wingSectionDef.point);     

compseg_etas = sparsRibs_struct.compSegEtas;


% front spar
sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,1}.ATTRIBUTE.uID = 'frontSpar';
sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,1}.name{1,1}.CONTENT = 'frontSpar';
sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,1}.description{1,1}.CONTENT = 'frontSpar';

% rear spar
sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,2}.ATTRIBUTE.uID = 'rearSpar';
sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,2}.name{1,1}.CONTENT = 'rearSpar';
sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,2}.description{1,1}.CONTENT = 'rearSpar';

 
for i=1:number_of_sections
    
    % front spar
    sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,1}.sparPositionUIDs{1,1}.sparPositionUID{1,i}.CONTENT = strcat('FS_P',num2str(i));
    sparsRibs_struct.spars{1,1}.sparPositions{1,1}.sparPosition{1,i}.ATTRIBUTE.uID = strcat('FS_P',num2str(i));
    sparsRibs_struct.spars{1,1}.sparPositions{1,1}.sparPosition{1,i}.eta{1,1}.CONTENT = num2str(compseg_etas(i));
    sparsRibs_struct.spars{1,1}.sparPositions{1,1}.sparPosition{1,i}.xsi{1,1}.CONTENT = '0.1';
    
    % rear spar
    sparsRibs_struct.spars{1,1}.sparSegments{1,1}.sparSegment{1,2}.sparPositionUIDs{1,1}.sparPositionUID{1,i}.CONTENT = strcat('RS_P',num2str(i));
    sparsRibs_struct.spars{1,1}.sparPositions{1,1}.sparPosition{1,i + number_of_sections}.ATTRIBUTE.uID = strcat('RS_P',num2str(i));
    sparsRibs_struct.spars{1,1}.sparPositions{1,1}.sparPosition{1,i + number_of_sections}.eta{1,1}.CONTENT = num2str(compseg_etas(i));
    sparsRibs_struct.spars{1,1}.sparPositions{1,1}.sparPosition{1,i + number_of_sections}.xsi{1,1}.CONTENT = '0.6';
end

% ribs
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ATTRIBUTE.uID = 'rib_1';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.name{1,1}.CONTENT = 'rib_1';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.description{1,1}.CONTENT = 'rib_1';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.ribReference{1,1}.CONTENT = 'frontSpar';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.etaStart{1,1}.CONTENT = '0.01';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.etaEnd{1,1}.CONTENT = '0.08';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.ribStart{1,1}.CONTENT = 'frontSpar';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.ribEnd{1,1}.CONTENT = 'rearSpar';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.numberOfRibs{1,1}.CONTENT = '2';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.ribCrossingBehaviour{1,1}.CONTENT = 'end';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.ribRotation{1,1}.ribRotationReference{1,1}.CONTENT = 'globalY';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.ribRotation{1,1}.x{1,1}.CONTENT = '90';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribsPositioning{1,1}.ribRotation{1,1}.z{1,1}.CONTENT = '90';

% not used but copy from usual parameters
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribCrossSection{1,1}.material{1,1}.materialUID{1,1}.CONTENT = 'aluminium 2024';
sparsRibs_struct.ribsDefinitions{1,1}.ribsDefinition{1,1}.ribCrossSection{1,1}.material{1,1}.thickness{1,1}.CONTENT = '0.003';

end