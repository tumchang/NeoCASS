function [vertices_Component, facets_Component] = patch_triangles2(XYZ_component, local_symmetry, component_type)
% function: to create the vertices and facets matrix to be later used by matlab patch
% XYZ_component: a cell containing the coordinates of points on each sections
% local symmetry: symmetrical information of the component
% triangles were the minimum unit for matlab patch;
% it can handle XYZ_component with different points on each sections
% but some extra efforts are made to find the proper vertices for each
% triangleg

% load Wing_component.mat   % XYZ_component
% local_symmetry = 2;

NoOf_Sections = length(XYZ_component);
NoOfPoints_perSection = zeros(NoOf_Sections,1);
Sum_NoOfPoints = 0;                                              %                                                                     Section 1(n points)  Section 2(m points)   Section 3(k)
Sum_NoOfPoints_Accumulated = zeros(NoOf_Sections,1);             % how many points exist before the current section                    0                    n                    n+m
                                                              
point_id = cell(NoOf_Sections,1);                                % give IDs to all the points for all the sections on the component    1 -> n               n+1 -> n+m            n+m+1 -> n+m+k
point_id_eachSection = cell(NoOf_Sections,1);                    % give IDs to all the points for each section                         1 -> n                1 -> m                1 -> k
X_normed = cell(1, NoOf_Sections);                               % see below line 34 - 43, to find the points on two neighbour sections that are close to each other

for i = 1:NoOf_Sections 
   NoOfPoints_perSection(i) = length(XYZ_component{i,1});
   Sum_NoOfPoints = Sum_NoOfPoints + length(XYZ_component{i,1});
   if i>1
       Sum_NoOfPoints_Accumulated(i) = Sum_NoOfPoints_Accumulated(i-1) + NoOfPoints_perSection(i-1);      
   end
   
   %---------------------------------------%
   point_id{i,1} = (Sum_NoOfPoints_Accumulated(i)+1 : Sum_NoOfPoints)'; 
   point_id_eachSection{i,1} = (1:NoOfPoints_perSection(i))';
   
   %---------------------------------------%
   switch component_type
       case {'fuselages','engines'}                          % fuselages and engines, whose longitudinal axis are parallel with the global x-axis, the z-coordinates of each section are normalized. 
           X_iSec = XYZ_component{i,1}(:,3);                 % potential problems with this assumption: if the fuselage/engine's longitudinal axis is parallel with z-axis, then something wrong will happen 
       case 'wings'                                          % normally, wings airfoils are parallel to the x-axis, either for horizontal wings or vertical wings. if the wing airfoil is parallel to y-z plane,  wrong happen
           X_iSec = XYZ_component{i,1}(:,1);
   end
   
   X_min = min(X_iSec);
   X_max = max(X_iSec);
   X_normed{1,i} = (X_iSec - X_min)./(X_max - X_min); 
   
end

%----------- To build the point_id matrix ------------------% 

switch local_symmetry
    case 0
        trig_id_mat = cell(NoOf_Sections-1, 1);
        NoOfpoint_sec_patch = zeros(NoOf_Sections-1, 1);
    case {1,2,3}
        trig_id_mat = cell(2*(NoOf_Sections-1), 1);
        NoOfpoint_sec_patch = zeros(2*(NoOf_Sections-1), 1);
end

for  i = 1:NoOf_Sections-1 

    curt_i = i;
    next_i = i+1;
    curt_X_normd = X_normed{1,curt_i};
    next_X_normd = X_normed{1,next_i};
    
    if length(curt_X_normd) < length(next_X_normd)                      % compare the number of points on two neighbour sections 
        trig_id_mat{i,1}(:,1) = point_id{i,1};                          % trig_id_mat: each cell element contains sections points of two neighbour sections
        switch component_type
            case {'fuselages','engines'}
                [min_Curt_X, idx_minCurtX] = max(curt_X_normd);         % because fuselages/engines, and wings' global coordinates on each section runs a round,      
                [min_Next_X, idx_minNextX] = max(next_X_normd);         % e.g. for airfoil, trailing edge - upper surf to leading - lower surf to trailing
            case 'wings'                                                % the sectional points need to be divided into two half parts to avoid confusion for later closest neighbour finding
                [min_Curt_X, idx_minCurtX] = min(curt_X_normd);
                [min_Next_X, idx_minNextX] = min(next_X_normd);
        end

        for j = 1:idx_minCurtX                                          % if the second section has more points than the first section, then some points on it will be removed
            firstHalf_next_X = next_X_normd(1:idx_minNextX);            % in this way, each cell element of trig_id_mat contains the same number of points for two neighbour sections
            [C, I] = min(abs(firstHalf_next_X - curt_X_normd(j)));
            trig_id_mat{i,1}(j,2) = point_id{i+1,1}(I);
        end
        
        for j = idx_minCurtX + 1 :  length(curt_X_normd)
            secondHalf_next_X = next_X_normd(idx_minNextX + 1 : end);
            [C,I] = min(abs(secondHalf_next_X - curt_X_normd(j)));
            I = idx_minNextX + I; 
            trig_id_mat{i,1}(j,2) = point_id{i+1,1}(I);            
        end
               
        NoOfpoint_sec_patch(i) = length(curt_X_normd);
        
    elseif length(curt_X_normd) > length(next_X_normd)
        trig_id_mat{i,1}(:,2) = point_id{i+1,1};
 
        switch component_type
            case {'fuselages','engines'}
                [min_Curt_X, idx_minCurtX] = max(curt_X_normd);
                [min_Next_X, idx_minNextX] = max(next_X_normd);
            case 'wings'
                [min_Curt_X, idx_minCurtX] = min(curt_X_normd);
                [min_Next_X, idx_minNextX] = min(next_X_normd);
        end
        
        for j = 1:idx_minNextX
           firstHalf_curt_X = curt_X_normd(1:idx_minCurtX);
           [C,I] = min(abs(firstHalf_curt_X - next_X_normd(j)));
           trig_id_mat{i,1}(j,1) = point_id{i,1}(I);       
        end
        
        for j = idx_minNextX+1 : length(next_X_normd)
           lastHalf_curt_X = curt_X_normd(idx_minCurtX + 1 : end);
           [C,I] = min(abs(lastHalf_curt_X - next_X_normd(j)));
           I = idx_minCurtX + I;
           trig_id_mat{i,1}(j,1) = point_id{i,1}(I);                
        end
        
        NoOfpoint_sec_patch(i) = length(next_X_normd);
    else
       trig_id_mat{i,1}(:,1) = point_id{i,1};
       trig_id_mat{i,1}(:,2) = point_id{i+1,1};   
       NoOfpoint_sec_patch(i) = length(next_X_normd);
    end
end

switch local_symmetry                                                      % to create the other half
    case 0
    case {1,2,3}
   
        for i =  (NoOf_Sections+1) : (2 * NoOf_Sections - 1)
              trig_id_mat{i,1} =  trig_id_mat{ i-NoOf_Sections,1} + Sum_NoOfPoints;
              NoOfpoint_sec_patch(i) = NoOfpoint_sec_patch( i-NoOf_Sections);  
        end
end

%----- vertices_Component & facets_Component & first half values-------% 
switch local_symmetry
    case 0
        vertices_Component = zeros(Sum_NoOfPoints, 3);
        NoOfTriangles = 2 * (sum(NoOfpoint_sec_patch) - NoOf_Sections + 1);
    case {1,2,3}
        vertices_Component = zeros(2 * Sum_NoOfPoints, 3);
        NoOfTriangles = 4 * (sum(NoOfpoint_sec_patch) - NoOf_Sections + 1);
end

facets_Component = zeros( NoOfTriangles, 3);


startidx = 1; 
for ki = 1:NoOf_Sections
    endidx = startidx +  length(XYZ_component{ki,1}) -1;
    vertices_Component(startidx:endidx,:) = XYZ_component{ki,1};
    startidx = endidx+1;
end 
 
trigIndex = 1;
for ki = 1:(NoOf_Sections - 1)     
    for kj = 1:  NoOfpoint_sec_patch(ki)-1 
        p1 = trig_id_mat{ki,1}(kj,1);
        p2 = trig_id_mat{ki,1}(kj+1,1);     
        p3 = trig_id_mat{ki,1}(kj,2); 
        p4 = trig_id_mat{ki,1}(kj+1,2); 
        facets_Component(trigIndex,:) = [p1 p2 p3];                          % attention: the sequence of the two triangular patches is important! otherwise the patch's color impacted by light will look funny
        trigIndex = trigIndex + 1;
        facets_Component(trigIndex,:) = [p2 p4 p3];
        trigIndex = trigIndex + 1; 
    end
end

idx0 = find(facets_Component==0);
facets_Component(idx0:end, :) = [];

%--------------------------------------------------------------%
%---Furtheron is to process Symmetry property, to copy data----%
switch local_symmetry
    case 0  % no symmetry
    case 1  % x-z plane symmetry
        for ki =  (NoOf_Sections+1) : (2 * NoOf_Sections)
            
            endidx = startidx + length(XYZ_component{ki - NoOf_Sections,1}) -1;
            vertices_Component(startidx:endidx,[1,3]) = XYZ_component{ki - NoOf_Sections,1}(:,[1,3]);
            vertices_Component(startidx:endidx,2) = -XYZ_component{ki - NoOf_Sections,1}(:,2);
            startidx = endidx+1;
        end
        
    case 2  % x-y plane symmetry
        for ki =  (NoOf_Sections+1) : (2 * NoOf_Sections)
           
            endidx = startidx + length(XYZ_component{ki - NoOf_Sections,1})-1;
            vertices_Component(startidx:endidx,[1,2]) = XYZ_component{ki - NoOf_Sections,1}(:,[1,2]);
            vertices_Component(startidx:endidx,3) = -XYZ_component{ki - NoOf_Sections,1}(:,3);
             startidx = endidx+1;
        end
        
    case 3  % y-z plane symmetry
        for ki =  (NoOf_Sections+1) : (2 * NoOf_Sections)
       
            endidx = startidx + length(XYZ_component{ki - NoOf_Sections,1})-1;
            vertices_Component(startidx:endidx,[2,3]) = XYZ_component{ki - NoOf_Sections,1}(:,[2,3]);
            vertices_Component(startidx:endidx,1) = -XYZ_component{ki - NoOf_Sections,1}(:,1);
             startidx = endidx+1;
        end
end

switch local_symmetry
    case 0
    case {1,2,3}
        for ki = (NoOf_Sections+1) : (2 * NoOf_Sections - 1)
            for kj = 1:( NoOfpoint_sec_patch(ki-NoOf_Sections)-1 )
                p1 = trig_id_mat{ki,1}(kj,1);
                p2 = trig_id_mat{ki,1}(kj+1,1);
                p3 = trig_id_mat{ki,1}(kj,2);
                p4 = trig_id_mat{ki,1}(kj+1,2);
                facets_Component(trigIndex,:) = [p1 p2 p3];
                trigIndex = trigIndex + 1;
                facets_Component(trigIndex,:) = [p2 p4 p3];
                trigIndex = trigIndex + 1;
            end
        end
end

% figure()
% patch('Vertices', vertices_Component, 'Faces', facets_Component, 'EdgeColor','none',...
%     'FaceColor', 'g','FaceAlpha', 1);
% 
% axis square
% axis equal
% axis vis3d
% axis off
% hold all
% hold on


end