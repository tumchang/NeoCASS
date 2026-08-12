function [vertices_ribs, facets_ribs, vertices_spars, facets_spars] = sparRibs2triangles(Spar_segments, rib_cell, local_symmetry)
% Creates vertices matrices containing x,y and z coordinates of
% every rib plane -- superior rib points and inferior rib points

%% create rib vertices, facets for each rib plane, to be used by patch
i = 0;
num_total_ribPlane = 0;

for j = 1:length(rib_cell)
    num_total_ribPlane = num_total_ribPlane + rib_cell{j}.ribs_number_cell;
end

rib_plane_vertices = cell(num_total_ribPlane,1);
facets_ribs_half = zeros(num_total_ribPlane, 4);


for j = 1:length(rib_cell)
    for k = 1: rib_cell{j}.ribs_number_cell
        i = i+1;
        rib_plane_vertices{i,1} = [rib_cell{j}.front_rib_sup{k};
            rib_cell{j}.front_rib_inf{k};
            rib_cell{j}.rear_rib_inf{k};
            rib_cell{j}.rear_rib_sup{k}];
    end
end

vertices_ribs_half = cell2mat(rib_plane_vertices);

switch local_symmetry
    case 0
        vertices_ribs = vertices_ribs_half;
        
    case 1   % x-z plane
        b_neg = [ones(size(vertices_ribs_half,1),1), -ones(size(vertices_ribs_half,1),1), ones(size(vertices_ribs_half,1),1)];
        vertices_ribs_other_half = vertices_ribs_half.*b_neg;
        vertices_ribs = [vertices_ribs_half;
            vertices_ribs_other_half];
        
    case 2   % x-y-plane
        b_neg = [ones(size(vertices_ribs_half,1),1), ones(size(vertices_ribs_half,1),1), -ones(size(vertices_ribs_half,1),1)];
        vertices_ribs_other_half = vertices_ribs_half.*b_neg;
        vertices_ribs = [vertices_ribs_half;
            vertices_ribs_other_half];
        
    case 3   % y-z plane
        b_neg = [-ones(size(vertices_ribs_half,1),1), ones(size(vertices_ribs_half,1),1), ones(size(vertices_ribs_half,1),1)];
        vertices_ribs_other_half = vertices_ribs_half.*b_neg;
        vertices_ribs = [vertices_ribs_half;
            vertices_ribs_other_half];
end


for i = 1: num_total_ribPlane
    facets_ribs_half(i,:) = [(i-1)*4 + 1, (i-1)*4 + 2, (i-1)*4 + 3, (i-1)*4 + 4];
end

facets_ribs_other_half =  facets_ribs_half + num_total_ribPlane*4;

switch local_symmetry
    case 0
        facets_ribs = facets_ribs_half;
    case {1,2,3}
        facets_ribs = [facets_ribs_half;
            facets_ribs_other_half];
end


%% create Spar vertices, facets for each spar plane, to be used by patch
Spars_number = length(Spar_segments);            

sparPosition_number = 0; 
for i = 1: Spars_number
   sparPosition_number = sparPosition_number + length(Spar_segments{i}.cross_profile); 
end

vertices_spars_half = zeros(sparPosition_number*2,3);
facets_spars_half = zeros(sparPosition_number - 2, 4);
i = 1;
m = 1;
for k = 1:Spars_number
    Spar_points_number = length(Spar_segments{k}.cross_profile);             % 3 // 5      %number of points for each spar
        
    for j = 1:Spar_points_number
        
        vertices_spars_half(i:i+1, :) = [Spar_segments{k}.sup(j,:);
            Spar_segments{k}.inf(j,:)];
        
        if j > 1 && j <= Spar_points_number
            facets_spars_half(m,:) = [i-2, i-1, i+1, i];
            m = m+1;
        end
        i = i + 2;
    end
    
end


switch local_symmetry
    case 0
        vertices_spars = vertices_spars_half;
    case 1
        bs_neg = [ones(size(vertices_spars_half,1),1), -ones(size(vertices_spars_half,1),1), ones(size(vertices_spars_half,1),1)];
        vertices_spars_other_half = vertices_spars_half.*bs_neg;
        vertices_spars = [vertices_spars_half;
            vertices_spars_other_half];
    case 2
        bs_neg = [ones(size(vertices_spars_half,1),1), ones(size(vertices_spars_half,1),1), -ones(size(vertices_spars_half,1),1)];
        vertices_spars_other_half = vertices_spars_half.*bs_neg;
        vertices_spars = [vertices_spars_half;
            vertices_spars_other_half];
    case 3
        bs_neg = [-ones(size(vertices_spars_half,1),1), ones(size(vertices_spars_half,1),1), ones(size(vertices_spars_half,1),1)];
        vertices_spars_other_half = vertices_spars_half.*bs_neg;
        vertices_spars = [vertices_spars_half;
            vertices_spars_other_half];
end

switch  local_symmetry
    case 0
        facets_spars =facets_spars_half;
    case {1,2,3}
        facets_spars_other_half = facets_spars_half + size(vertices_spars_half,1);
        facets_spars = [facets_spars_half;
            facets_spars_other_half];
end

end