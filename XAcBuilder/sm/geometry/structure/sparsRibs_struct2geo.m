function  [sparsRibsgeo] = sparsRibs_struct2geo(sparsRibs_Struct)

%--------------RibsDefinition---------------%
ribs_struct = sparsRibs_Struct.ribsDefinitions{1,1}.ribsDefinition; 
numRibsDefinition = length(ribs_struct); 

ribs_uID = cell(1,numRibsDefinition);
ribs_ribReference = cell(1,numRibsDefinition);
ribs_etaStart = ones(1,numRibsDefinition)*NaN;
ribs_etaEnd = ones(1,numRibsDefinition)*NaN;
ribs_ribStart = cell(1,numRibsDefinition);
ribs_ribEnd =  cell(1,numRibsDefinition);
ribs_numberOfRibs = ones(1,numRibsDefinition)*NaN;
ribs_CrossingBehavior = cell(1,numRibsDefinition);
ribs_ribRotationReference = cell(1,numRibsDefinition);
ribs_rotz = ones(1,numRibsDefinition)*NaN;
ribs_rotx = ones(1,numRibsDefinition)*NaN;

for num_Ribs = 1:numRibsDefinition
   ribs_uID{1,num_Ribs} = ribs_struct{1,num_Ribs}.ATTRIBUTE.uID;
   ribs_ribReference{1,num_Ribs} = ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.ribReference{1,1}.CONTENT; 
   ribs_etaStart(1,num_Ribs) = str2double(ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.etaStart{1,1}.CONTENT); 
   ribs_etaEnd(1,num_Ribs) = str2double(ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.etaEnd{1,1}.CONTENT); 
   ribs_ribStart{1,num_Ribs} = ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.ribStart{1,1}.CONTENT;
   ribs_ribEnd{1,num_Ribs} = ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.ribEnd{1,1}.CONTENT;
   ribs_numberOfRibs(1,num_Ribs) = str2double(ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.numberOfRibs{1,1}.CONTENT);
   ribs_CrossingBehavior{1,num_Ribs} = ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.ribCrossingBehaviour{1,1}.CONTENT;
   try 
       ribs_ribRotationReference{1,num_Ribs} = ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.ribRotation{1,1}.ribRotationReference{1,1}.CONTENT;  
   catch
       ribs_ribRotationReference{1,num_Ribs} = 'eta-axis';  
   end
   
   ribs_rotz(1,num_Ribs) = str2double(ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.ribRotation{1,1}.z{1,1}.CONTENT);
   
   try 
       ribs_rotx(1,num_Ribs) = str2double(ribs_struct{1,num_Ribs}.ribsPositioning{1,1}.ribRotation{1,1}.x{1,1}.CONTENT);
   catch
       ribs_rotx(1,num_Ribs) = ribs_rotz(1,num_Ribs);  
   end
   
%--------------SparsPosition----------------%
spars_struct = sparsRibs_Struct.spars{1,1}.sparPositions{1,1}.sparPosition; 
numSparPosition = length(spars_struct);

spars_uID = cell(1,numSparPosition);
spars_eta = ones(1,numSparPosition)*NaN;
spars_xsi = ones(1,numSparPosition)*NaN;

for i = 1:numSparPosition 
spars_uID{1,i} = spars_struct{1,i}.ATTRIBUTE.uID;
spars_eta(1,i) = str2double(spars_struct{1,i}.eta{1,1}.CONTENT);
spars_xsi(1,i) = str2double(spars_struct{1,i}.xsi{1,1}.CONTENT);
end

%--------------SparSegment----------------%
spars_segment = sparsRibs_Struct.spars{1,1}.sparSegments{1,1}.sparSegment; 
numSparSegment = length(spars_segment); 

spars_segmentuID = cell(1, numSparSegment);
spars_segmentPositions = cell(1, numSparSegment);

for i = 1: numSparSegment
   spars_segmentuID{1,i} = spars_segment{1,i}.ATTRIBUTE.uID;
   
   spars_segment_positions = spars_segment{1,i}.sparPositionUIDs{1,1}.sparPositionUID;
   
   numSegPosition = length(spars_segment_positions);
   segPositnsUID = cell(1,numSegPosition);
   
   for j = 1: numSegPosition
     segPositnsUID{1,j} = spars_segment_positions{1,j}.CONTENT;    
   end
   
   spars_segmentPositions{1,i} = segPositnsUID; 
end

sparsRibsgeo.ribsDefinitions.uIDs = ribs_uID;
sparsRibsgeo.ribsDefinitions.ribReference = ribs_ribReference;
sparsRibsgeo.ribsDefinitions.etaStart = ribs_etaStart;
sparsRibsgeo.ribsDefinitions.etaEnd = ribs_etaEnd;
sparsRibsgeo.ribsDefinitions.ribStart = ribs_ribStart;
sparsRibsgeo.ribsDefinitions.ribEnd = ribs_ribEnd;
sparsRibsgeo.ribsDefinitions.numberOfRibs = ribs_numberOfRibs;
sparsRibsgeo.ribsDefinitions.ribCrossingBehavior = ribs_CrossingBehavior;
sparsRibsgeo.ribsDefinitions.ribRotationReference = ribs_ribRotationReference;
sparsRibsgeo.ribsDefinitions.rotz = ribs_rotz;
sparsRibsgeo.ribsDefinitions.rotx = ribs_rotx;

sparsRibsgeo.spars.positions.uIDs = spars_uID;
sparsRibsgeo.spars.positions.eta = spars_eta;
sparsRibsgeo.spars.positions.xsi = spars_xsi;
sparsRibsgeo.spars.segments.uIDs = spars_segmentuID;
sparsRibsgeo.spars.segments.positions = spars_segmentPositions; 

end
end