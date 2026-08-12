function  [FT_rib_vertices, FT_faces] = fuel_tanks2(wingFuelTank, local_symmetry)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
% load_fuel_tanks(Wings, wing_structure, local_wing, local_componentSegment,  j);
% i: local_wing
% w: local_componentSegment
% j: local_fuelTank

% load wing.mat         % Wings
% load sparRibTest.mat
% i = 1;  w = 1;  j = 3;

% Wings{i}.Fuel_tanks{j} = {};     % define new cell under Wings cell
%}

Wings = wingFuelTank.Wings;

number_fuel_borders = length(wingFuelTank.geometry{1,1}.border);

name_border = cell(1, number_fuel_borders);
rib_corner = cell(2,1);
number_rib = 0;

for s = 1: number_fuel_borders
    % name_border{s} = fieldnames(wingFuelTank.geometry{1,1}.border{s});
    is_rib = strcmp(fieldnames(wingFuelTank.geometry{1,1}.border{s}), 'ribDefinitionUID');
    
    if find(is_rib, 1)
        number_rib = number_rib + 1;
        name_border{number_rib} = fieldnames(wingFuelTank.geometry{1,1}.border{s});
        Rib_number = str2double(wingFuelTank.geometry{1,1}.border{s}.ribNumber{1,1}.CONTENT);
        
        for k = 1: length(Wings.Ribs)
            if strcmp(wingFuelTank.geometry{1,1}.border{1,s}.ribDefinitionUID{1,1}.CONTENT, Wings.Ribs{k}.Ribs_name)
                
                rib_profile_inf = Wings.Ribs{k}.Ribs_profile_inf{Rib_number};
                rib_profile_sup = Wings.Ribs{k}.Ribs_profile_sup{Rib_number};
                
                if rib_profile_inf(1,1) > rib_profile_inf(end,1)
                    rib_profile_inf = flipud(rib_profile_inf);
                end
                
                if rib_profile_sup(1,1) > rib_profile_sup(end,1)
                    rib_profile_sup = flipud(rib_profile_sup);
                end
                
            end
        end
        
        rib_corner{number_rib} = [rib_profile_sup(1,:);
            rib_profile_sup(end,:);
            rib_profile_inf(1,:);
            rib_profile_inf(end,:)];
        
        
    end
end

if number_rib == 1
    name_border{2} = 'addedRootRib';
    
    spar1_profile_inf = Wings.Spars{1}.Spars_profile_inf;
    spar1_profile_sup = Wings.Spars{1}.Spars_profile_sup;
    
    spar2_profile_inf = Wings.Spars{2}.Spars_profile_inf;
    spar2_profile_sup = Wings.Spars{2}.Spars_profile_sup;
    
    if mean(spar1_profile_sup(:,1)) > mean(spar2_profile_sup(:,1))
        
        rib_corner{number_rib+1} = [spar2_profile_sup(1,:);
            spar1_profile_sup(1,:);
            spar2_profile_inf(1,:);
            spar1_profile_inf(1,:);];
        
    else
        
        rib_corner{number_rib+1} = [spar1_profile_sup(1,:);
            spar2_profile_sup(1,:);
            spar1_profile_inf(1,:);
            spar2_profile_inf(1,:);];
    end
end

FT_rib_vertices_half = cell2mat(rib_corner);
FT_faces_half = [3 4 8 7;
    5 1 3 7;
    6 2 4 8];

switch local_symmetry
    case 0
        FT_rib_vertices = FT_rib_vertices_half; 
    case 1
        b_neg = [ones(size(FT_rib_vertices_half,1),1), -ones(size(FT_rib_vertices_half,1),1), ones(size(FT_rib_vertices_half,1),1)];
        FT_rib_vertices_other_half = FT_rib_vertices_half.*b_neg;        
        FT_rib_vertices = [FT_rib_vertices_half;
                          FT_rib_vertices_other_half];
    case 2
        b_neg = [ones(size(FT_rib_vertices_half,1),1), ones(size(FT_rib_vertices_half,1),1), -ones(size(FT_rib_vertices_half,1),1)];
        FT_rib_vertices_other_half = FT_rib_vertices_half.*b_neg;        
        FT_rib_vertices = [FT_rib_vertices_half;
                          FT_rib_vertices_other_half];
    case 3
        b_neg = [-ones(size(FT_rib_vertices_half,1),1), -ones(size(FT_rib_vertices_half,1),1), ones(size(FT_rib_vertices_half,1),1)];
        FT_rib_vertices_other_half = FT_rib_vertices_half.*b_neg;        
        FT_rib_vertices = [FT_rib_vertices_half;
                          FT_rib_vertices_other_half];
        
end

switch local_symmetry
    case 0
        FT_faces = FT_faces_half; 
    case {1,2,3}
        FT_faces_other_half = FT_faces_half + 8;
        FT_faces = [FT_faces_half;
            FT_faces_other_half];
end



     
%  figure()
%  plot3(rib_corner(:,1),rib_corner(:,2),rib_corner(:,3),'b*')
%  axis equal
 
%  patch('Faces',FT_faces,'Vertices',FT_rib_corner,'FaceColor','r');
%  axis equal

end



%{
for s = 1: number_fuel_borders
    name_border{s} = fieldnames(wingFuelTank.geometry{1,1}.border{s});
  %  is_spar = strcmp(name_border{s}, 'sparUID');
    is_rib = strcmp(name_border{s}, 'ribDefinitionUID');
    
    %     if is_spar == 1
    %         for k = 1: length(Wings{i}.Spars)
    %             if strcmp(wingFuelTank.geometry{1,1}.border{1,s}.sparUID{1,1}.CONTENT, Wings{i}.Spars{k}.Spars_uID)
    %                 struct_border{s} = Wings{i}.Spars{k};
    %                 number_spar = number_spar + 1;
    %             end
    %         end
    
    if find(is_rib, 1)
        for k = 1: length(Wings{i}.Ribs)
            if strcmp(wingFuelTank.geometry{1,1}.border{1,s}.ribDefinitionUID{1,1}.CONTENT, Wings{i}.Ribs{k}.Ribs_name)
                number_rib = number_rib + 1;
                Rib_number = str2double(wingFuelTank.geometry{1,1}.border{s}.ribNumber{1,1}.CONTENT);
          %      struct_border{number_rib}.rib_profile = Wings{i}.Ribs{k}.Ribs_profile{Rib_number};
                struct_border{number_rib}.rib_profile_inf = Wings{i}.Ribs{k}.Ribs_profile_inf{Rib_number};
                struct_border{number_rib}.rib_profile_sup = Wings{i}.Ribs{k}.Ribs_profile_sup{Rib_number};                
            end
        end
    end
end

                      % 'number_spar',number_spar,'number_rib',number_rib);

%{  
% is it necessary to reorder the spars and ribs?? to be ensured later...
% Reorders the Tank_spars if necessary in order to have
% always the spar placed the most forward (along x) in first position
% and the spar placed the most backward (along x) in second position

if mean(Tank_spar{1}.Spars_middle(:,1))>mean(Tank_spar{2}.Spars_middle(:,1))
    transferer = Tank_spar{1};
    Tank_spar{1}=Tank_spar{2};
    Tank_spar{2}=transferer;
end
%}
if number_rib == 1   
    name_border{2} = 'addedRootRib';
    %struct_border{2}.rib_profile = Wings{i}.Spars{1}.Spars_profile_sup;
    spar1_sup = [Wings{i}.Spars{1}.Spars_profile_sup(1,:);
                 Wings{i}.Spars{2}.Spars_profile_sup(1,:)]
    
    
    struct_border{2}.rib_profile_inf = Wings{i}.Spars{1}.Spars_profile_inf;
    struct_border{2}.rib_profile_sup = Wings{i}.Spars{1}.Spars_profile_sup;
end
         
% tank_border = struct('id', name_border,'local_struct',struct_border);
 
 tank_sup_4p = [struct_border{1}.rib_profile_sup(1,:);
                struct_border{1}.rib_profile_sup(end,:);               
                Wings{i}.Spars{1}.Spars_profile_sup(1,:);
                Wings{i}.Spars{2}.Spars_profile_sup(1,:);]
 tank_inf_4p = [struct_border{1}.rib_profile_inf(1,:);
                struct_border{1}.rib_profile_inf(end,:);
                Wings{i}.Spars{1}.Spars_profile_inf(1,:);
                Wings{i}.Spars{2}.Spars_profile_inf(1,:)]
 
 faces = [1,2,4,3];
 
 figure()
 patch('Faces',faces,'Vertices',tank_sup_4p,'FaceColor','r');
 axis equal
 hold on
 patch('Faces',faces,'Vertices',tank_inf_4p,'FaceColor','g');
 
 
 
end
 %}
%{
if number_rib == 1
    
    % if there is only one rib defined as fuel tank border,
    % sets a fake inner rib as default by using the point at the origin of each spar wich are a spar border of the fuel tank
    % in order to have a inner fuel tank border
    
    tank_rib_sup{2} = [tank_rib_sup{1}(1,:);tank_rib_sup{1}(size(tank_rib_sup{1},1),:)];
    tank_rib_sup{1} = [Tank_spar{2}.Spars_profile_sup(1,:);Tank_spar{1}.Spars_profile_sup(1,:)];
    
    tank_rib_inf{2} = [tank_rib_inf{1}(1,:);tank_rib_inf{1}(size(tank_rib_inf{1},1),:)];
    tank_rib_inf{1} = [Tank_spar{1}.Spars_profile_inf(1,:);Tank_spar{2}.Spars_profile_inf(1,:)];
    
    tank_rib{2} = [tank_rib{1}(1,:);tank_rib{1}(size(tank_rib{1},1),:)];
    tank_rib{1} = [Tank_spar{1}.Spars_middle(1,:);Tank_spar{2}.Spars_middle(1,:)];
 
    % checks if there is two ribs as fuel tank border
    
elseif border_rib_number == 2
    
    if Wings{i}.Y_spar(:,1)<=0 %Vertical wing
        
        % compares the z_coordinate average of the ribs in order to know which one is the inner and which one is the outer rib border
        
        if mean(tank_rib{2}(:,3))<= mean(tank_rib{1}(:,3))
            
            % places the ribs with the smallest z_coordinate average in first position and the other one in second position
            
            tank_rib_sup_intermediaire{1} = [tank_rib_sup{2}(1,:);tank_rib_sup{2}(size(tank_rib_sup{2},1),:)];
            tank_rib_sup_intermediaire{2} = [tank_rib_sup{1}(1,:);tank_rib_sup{1}(size(tank_rib_sup{1},1),:)];
            
            tank_rib_inf_intermediaire{1} = [tank_rib_inf{2}(1,:);tank_rib_inf{2}(size(tank_rib_inf{2},1),:)];
            tank_rib_inf_intermediaire{2} = [tank_rib_inf{1}(1,:);tank_rib_inf{1}(size(tank_rib_inf{1},1),:)];
            
            tank_rib_sup{1} = tank_rib_sup_intermediaire{1};
            tank_rib_sup{2} = tank_rib_sup_intermediaire{2};
            
            tank_rib_inf{1} = tank_rib_inf_intermediaire{1};
            tank_rib_inf{2} = tank_rib_inf_intermediaire{2};
            
        else
            
            tank_rib_sup{2} = [tank_rib_sup{2}(1,:);tank_rib_sup{2}(size(tank_rib_sup{2},1),:)];
            tank_rib_sup{1} = [tank_rib_sup{1}(1,:);tank_rib_sup{1}(size(tank_rib_sup{1},1),:)];
            
            tank_rib_inf{2} = [tank_rib_inf{2}(1,:);tank_rib_inf{2}(size(tank_rib_inf{2},1),:)];
            tank_rib_inf{1} = [tank_rib_inf{1}(1,:);tank_rib_inf{1}(size(tank_rib_inf{1},1),:)];
            
        end
        
    else % Horizontal wing
        
        % compares the y_coordinate average of the ribs in order to know which one is the inner and which one is the outer rib border
        
        if mean(tank_rib{2}(:,2))<= mean(tank_rib{1}(:,2))
            
            % places the ribs with the smallest y_coordinate average in first position and the other one in second position
            
            tank_rib_sup_intermediaire{1} = [tank_rib_sup{2}(1,:);tank_rib_sup{2}(size(tank_rib_sup{2},1),:)];
            tank_rib_sup_intermediaire{2} = [tank_rib_sup{1}(1,:);tank_rib_sup{1}(size(tank_rib_sup{1},1),:)];
            
            tank_rib_inf_intermediaire{1} = [tank_rib_inf{2}(1,:);tank_rib_inf{2}(size(tank_rib_inf{2},1),:)];
            tank_rib_inf_intermediaire{2} = [tank_rib_inf{1}(1,:);tank_rib_inf{1}(size(tank_rib_inf{1},1),:)];
            
            tank_rib_sup{1} = tank_rib_sup_intermediaire{1};
            tank_rib_sup{2} = tank_rib_sup_intermediaire{2};
            
            tank_rib_inf{1} = tank_rib_inf_intermediaire{1};
            tank_rib_inf{2} = tank_rib_inf_intermediaire{2};
            
        else
            
            tank_rib_sup{2} = [tank_rib_sup{2}(1,:);tank_rib_sup{2}(size(tank_rib_sup{2},1),:)];
            tank_rib_sup{1} = [tank_rib_sup{1}(1,:);tank_rib_sup{1}(size(tank_rib_sup{1},1),:)];
            
            tank_rib_inf{2} = [tank_rib_inf{2}(1,:);tank_rib_inf{2}(size(tank_rib_inf{2},1),:)];
            tank_rib_inf{1} = [tank_rib_inf{1}(1,:);tank_rib_inf{1}(size(tank_rib_inf{1},1),:)];
            
        end
        
    end
    
end

% keeps only the points defining the rib borders sup and
% inf in the structure Wings
if Wings{i}.Y_spar(:,1)<=0 %Vertical wing
    
    Wings{i}.Fuel_tanks{j}.Tank_rib_inf_profiles = tank_rib_inf;
    Wings{i}.Fuel_tanks{j}.Tank_rib_sup_profiles = tank_rib_sup;
    
    % for each spar border, keeps only the points which are
    % between the two rib borders along z
    
    for k=1:border_spar_number
        s=1;
        
        tank_spar_sup{k} = [];
        tank_spar_inf{k} = [];
        for u=1:size(Tank_spar{k}.Spars_middle,1)
            
            
            if (round(tank_rib{1}(k,3))<round(Tank_spar{k}.Spars_middle(u,3)))&&(round(Tank_spar{k}.Spars_middle(u,3))<round(tank_rib{2}(k,3)))
                
                tank_spar_sup{k}(s,:) = Tank_spar{k}.Spars_profile_sup(u,:);
                tank_spar_inf{k}(s,:) = Tank_spar{k}.Spars_profile_inf(u,:);
                s = s+1;
                
            end
        end
    end
    
    % Then it appears 4 cases
    
    if isempty(tank_spar_sup{1})==1&&isempty(tank_spar_sup{2})==1
        final_tank_spar_sup{1} = [];
        final_tank_spar_sup{2} = [];
        % There are no points for both spar borders which are
        % between the two rib borders
        
    elseif isempty(tank_spar_sup{1})~=1&&isempty(tank_spar_sup{2})==1
        
        % There are points left between the two rib borders only
        % for a spar border (the front spar)
        % Gets the superior point on the other spar border (the rear spar) which is at the same z_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_sup{1} = tank_spar_sup{1};
        final_tank_spar_sup{2} = [];
        
        for u=1:size(tank_spar_sup{1},1)
            for s=1:size(Tank_spar{1}.Spars_profile_sup)
                if tank_spar_sup{1}(u,:)==Tank_spar{1}.Spars_profile_sup(s,:)
                    
                    final_tank_spar_sup{2} = [final_tank_spar_sup{2};Tank_spar{1}.other_spar_sup(s,:)];
                end
            end
            
        end
        
        
    elseif isempty(tank_spar_sup{1})==1&&isempty(tank_spar_sup{2})~=1
        
        % There are points left between the two rib borders only
        % for a spar border (the rear spar)
        % Gets the superior point on the other spar border (the front spar) which is at the same z_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_sup{1} = [];
        final_tank_spar_sup{2} = tank_spar_sup{2};
        
        
        for u=1:size(tank_spar_sup{2},1)
            for s=1:size(Tank_spar{2}.Spars_profile_sup)
                if tank_spar_sup{2}(u,:)==Tank_spar{2}.Spars_profile_sup(s,:)
                    
                    final_tank_spar_sup{1} = [final_tank_spar_sup{1};Tank_spar{2}.other_spar_sup(s,:)];
                end
            end
            
        end
        
        
        
        
        
    elseif isempty(tank_spar_sup{1})~=1&&isempty(tank_spar_sup{2})~=1
        
        % There are points left between the two ribs for both
        % spar borders
        % Gets for each spar, the superior point with the same z-coordinate but on the other spar
        % For each spar border, reorders each point from the smallest z_coordinate to the biggest
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_sup{1} = tank_spar_sup{1};
        final_tank_spar_sup{2} = tank_spar_sup{2};
        for k=1:border_spar_number
            if k == 1
                
                for u=1:size(tank_spar_sup{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_sup)
                        if tank_spar_sup{k}(u,:)==Tank_spar{k}.Spars_profile_sup(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_sup(s,3)>= final_tank_spar_sup{2}(:,3)))+1;
                            final_tank_spar_sup{2} = [final_tank_spar_sup{2}(1:d-1,:);Tank_spar{k}.other_spar_sup(s,:);final_tank_spar_sup{2}(d:end,:)];
                        end
                    end
                    
                end
                
                
            elseif k == 2
                
                for u=1:size(tank_spar_sup{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_sup)
                        if tank_spar_sup{k}(u,:)==Tank_spar{k}.Spars_profile_sup(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_sup(s,3)>= final_tank_spar_sup{1}(:,3)))+1;
                            final_tank_spar_sup{1} = [final_tank_spar_sup{1}(1:d-1,:);Tank_spar{k}.other_spar_sup(s,:);final_tank_spar_sup{1}(d:end,:)];
                        end
                    end
                    
                end
                
                
                
                
            end
        end
    end
    
    % Then it appears 4 cases
    
    if isempty(tank_spar_inf{1})==1&&isempty(tank_spar_inf{2})==1
        
        % There are no points for both spar borders which are
        % between the two rib borders along z
        
        final_tank_spar_inf{1} = [];
        final_tank_spar_inf{2} = [];
        
    elseif isempty(tank_spar_inf{1})~=1&&isempty(tank_spar_inf{2})==1
        
        % There are points left between the two rib borders only
        % for a spar border (the front spar)
        % Gets the inferior point on the other spar border (the rear spar) which is at the same z_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_inf{1} = tank_spar_inf{1};
        final_tank_spar_inf{2} = [];
        
        for u=1:size(tank_spar_inf{1},1)
            for s=1:size(Tank_spar{1}.Spars_profile_inf)
                if tank_spar_inf{1}(u,:)==Tank_spar{1}.Spars_profile_inf(s,:)
                    
                    final_tank_spar_inf{2} = [final_tank_spar_inf{2};Tank_spar{1}.other_spar_inf(s,:)];
                end
            end
            
        end
    elseif isempty(tank_spar_inf{1})==1&&isempty(tank_spar_inf{2})~=1
        
        % There are points left between the two rib borders only
        % for a spar border (the rear spar)
        % Gets the inferior point on the other spar border (the front spar) which is at the same z_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_inf{1} = [];
        final_tank_spar_inf{2} = tank_spar_inf{2};
        
        
        for u=1:size(tank_spar_inf{2},1)
            for s=1:size(Tank_spar{2}.Spars_profile_inf)
                if tank_spar_inf{2}(u,:)==Tank_spar{2}.Spars_profile_inf(s,:)
                    
                    final_tank_spar_inf{1} = [final_tank_spar_inf{1};Tank_spar{2}.other_spar_inf(s,:)];
                    
                    
                end
            end
            
        end
        
        
        
        
        
    elseif isempty(tank_spar_inf{1})~=1&&isempty(tank_spar_inf{2})~=1
        
        % There are points left between the two ribs for both
        % spar borders
        % Gets for each spar, the inferior point with the same z-coordinate but on the other spar
        % For each spar border, reorders each point from the smallest z_coordinate to the biggest
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_inf{1} = tank_spar_inf{1};
        final_tank_spar_inf{2} = tank_spar_inf{2};
        for k=1:border_spar_number
            if k == 1
                
                
                
                for u=1:size(tank_spar_inf{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_inf)
                        if tank_spar_inf{k}(u,:)==Tank_spar{k}.Spars_profile_inf(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_inf(s,3)>= final_tank_spar_inf{2}(:,3)))+1;
                            final_tank_spar_inf{2} = [final_tank_spar_inf{2}(1:d-1,:);Tank_spar{k}.other_spar_inf(s,:);final_tank_spar_inf{2}(d:end,:)];
                        end
                    end
                    
                end
                
                
            elseif k == 2
                
                for u=1:size(tank_spar_inf{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_inf)
                        if tank_spar_inf{k}(u,:)==Tank_spar{k}.Spars_profile_inf(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_inf(s,3)>= final_tank_spar_inf{1}(:,3)))+1;
                            final_tank_spar_inf{1} = [final_tank_spar_inf{1}(1:d-1,:);Tank_spar{k}.other_spar_inf(s,:);final_tank_spar_inf{1}(d:end,:)];
                        end
                    end
                    
                end
                
                
                
                
            end
        end
    end
else % Horizontal wing
    Wings{i}.Fuel_tanks{j}.Tank_rib_inf_profiles = tank_rib_inf;
    Wings{i}.Fuel_tanks{j}.Tank_rib_sup_profiles = tank_rib_sup;
    
    % for each spar border, keeps only the points which are
    % between the two rib borders along y
    
    for k=1:border_spar_number
        s=1;
        
        tank_spar_sup{k} = [];
        tank_spar_inf{k} = [];
        for u=1:size(Tank_spar{k}.Spars_middle,1)
            
            
            if (round(tank_rib{1}(k,2))<round(Tank_spar{k}.Spars_middle(u,2)))&&(round(Tank_spar{k}.Spars_middle(u,2))<round(tank_rib{2}(k,2)))
                
                tank_spar_sup{k}(s,:) = Tank_spar{k}.Spars_profile_sup(u,:);
                tank_spar_inf{k}(s,:) = Tank_spar{k}.Spars_profile_inf(u,:);
                s = s+1;
                
            end
        end
    end
    
    % Then it appears 4 cases
    
    if isempty(tank_spar_sup{1})==1&&isempty(tank_spar_sup{2})==1
        final_tank_spar_sup{1} = [];
        final_tank_spar_sup{2} = [];
        % There are no points for both spar borders which are
        % between the two rib borders
        
    elseif isempty(tank_spar_sup{1})~=1&&isempty(tank_spar_sup{2})==1
        
        % There are points left between the two rib borders only
        % for a spar border (the front spar)
        % Gets the superior point on the other spar border (the rear spar) which is at the same y_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_sup{1} = tank_spar_sup{1};
        final_tank_spar_sup{2} = [];
        
        for u=1:size(tank_spar_sup{1},1)
            for s=1:size(Tank_spar{1}.Spars_profile_sup)
                if tank_spar_sup{1}(u,:)==Tank_spar{1}.Spars_profile_sup(s,:)
                    
                    final_tank_spar_sup{2} = [final_tank_spar_sup{2};Tank_spar{1}.other_spar_sup(s,:)];
                end
            end
            
        end
        
        
    elseif isempty(tank_spar_sup{1})==1&&isempty(tank_spar_sup{2})~=1
        
        % There are points left between the two rib borders only
        % for a spar border (the rear spar)
        % Gets the superior point on the other spar border (the front spar) which is at the same y_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_sup{1} = [];
        final_tank_spar_sup{2} = tank_spar_sup{2};
        
        
        for u=1:size(tank_spar_sup{2},1)
            for s=1:size(Tank_spar{2}.Spars_profile_sup)
                if tank_spar_sup{2}(u,:)==Tank_spar{2}.Spars_profile_sup(s,:)
                    
                    final_tank_spar_sup{1} = [final_tank_spar_sup{1};Tank_spar{2}.other_spar_sup(s,:)];
                end
            end
            
        end
        
        
        
        
        
    elseif isempty(tank_spar_sup{1})~=1&&isempty(tank_spar_sup{2})~=1
        
        % There are points left between the two ribs for both
        % spar borders
        % Gets for each spar, the superior point with the same y-coordinate but on the other spar
        % For each spar border, reorders each point from the smallest y_coordinate to the biggest
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_sup{1} = tank_spar_sup{1};
        final_tank_spar_sup{2} = tank_spar_sup{2};
        for k=1:border_spar_number
            if k == 1
                
                for u=1:size(tank_spar_sup{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_sup)
                        if tank_spar_sup{k}(u,:)==Tank_spar{k}.Spars_profile_sup(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_sup(s,2)>= final_tank_spar_sup{2}(:,2)))+1;
                            final_tank_spar_sup{2} = [final_tank_spar_sup{2}(1:d-1,:);Tank_spar{k}.other_spar_sup(s,:);final_tank_spar_sup{2}(d:end,:)];
                        end
                    end
                    
                end
                
                
            elseif k == 2
                
                for u=1:size(tank_spar_sup{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_sup)
                        if tank_spar_sup{k}(u,:)==Tank_spar{k}.Spars_profile_sup(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_sup(s,2)>= final_tank_spar_sup{1}(:,2)))+1;
                            final_tank_spar_sup{1} = [final_tank_spar_sup{1}(1:d-1,:);Tank_spar{k}.other_spar_sup(s,:);final_tank_spar_sup{1}(d:end,:)];
                        end
                    end
                    
                end
                
                
                
                
            end
        end
    end
    
    % Then it appears 4 cases
    
    if isempty(tank_spar_inf{1})==1&&isempty(tank_spar_inf{2})==1
        
        % There are no points for both spar borders which are
        % between the two rib borders along y
        
        final_tank_spar_inf{1} = [];
        final_tank_spar_inf{2} = [];
        
    elseif isempty(tank_spar_inf{1})~=1&&isempty(tank_spar_inf{2})==1
        
        % There are points left between the two rib borders only
        % for a spar border (the front spar)
        % Gets the inferior point on the other spar border (the rear spar) which is at the same y_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_inf{1} = tank_spar_inf{1};
        final_tank_spar_inf{2} = [];
        
        for u=1:size(tank_spar_inf{1},1)
            for s=1:size(Tank_spar{1}.Spars_profile_inf)
                if tank_spar_inf{1}(u,:)==Tank_spar{1}.Spars_profile_inf(s,:)
                    
                    final_tank_spar_inf{2} = [final_tank_spar_inf{2};Tank_spar{1}.other_spar_inf(s,:)];
                end
            end
            
        end
    elseif isempty(tank_spar_inf{1})==1&&isempty(tank_spar_inf{2})~=1
        
        % There are points left between the two rib borders only
        % for a spar border (the rear spar)
        % Gets the inferior point on the other spar border (the front spar) which is at the same y_coordinate
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_inf{1} = [];
        final_tank_spar_inf{2} = tank_spar_inf{2};
        
        
        for u=1:size(tank_spar_inf{2},1)
            for s=1:size(Tank_spar{2}.Spars_profile_inf)
                if tank_spar_inf{2}(u,:)==Tank_spar{2}.Spars_profile_inf(s,:)
                    
                    final_tank_spar_inf{1} = [final_tank_spar_inf{1};Tank_spar{2}.other_spar_inf(s,:)];
                    
                    
                end
            end
            
        end
        
        
        
        
        
    elseif isempty(tank_spar_inf{1})~=1&&isempty(tank_spar_inf{2})~=1
        
        % There are points left between the two ribs for both
        % spar borders
        % Gets for each spar, the inferior point with the same y-coordinate but on the other spar
        % For each spar border, reorders each point from the smallest y_coordinate to the biggest
        %%%%%%%%%%% Note: This is necessary for drawing with java %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        final_tank_spar_inf{1} = tank_spar_inf{1};
        final_tank_spar_inf{2} = tank_spar_inf{2};
        for k=1:border_spar_number
            if k == 1
                
                
                
                for u=1:size(tank_spar_inf{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_inf)
                        if tank_spar_inf{k}(u,:)==Tank_spar{k}.Spars_profile_inf(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_inf(s,2)>= final_tank_spar_inf{2}(:,2)))+1;
                            final_tank_spar_inf{2} = [final_tank_spar_inf{2}(1:d-1,:);Tank_spar{k}.other_spar_inf(s,:);final_tank_spar_inf{2}(d:end,:)];
                        end
                    end
                    
                end
                
                
            elseif k == 2
                
                for u=1:size(tank_spar_inf{k},1)
                    for s=1:size(Tank_spar{k}.Spars_profile_inf)
                        if tank_spar_inf{k}(u,:)==Tank_spar{k}.Spars_profile_inf(s,:)
                            
                            d = max(find(Tank_spar{k}.other_spar_inf(s,2)>= final_tank_spar_inf{1}(:,2)))+1;
                            final_tank_spar_inf{1} = [final_tank_spar_inf{1}(1:d-1,:);Tank_spar{k}.other_spar_inf(s,:);final_tank_spar_inf{1}(d:end,:)];
                        end
                    end
                    
                end
                
                
                
                
            end
        end
    end
end

% Inverse matrices inf and sup of the rear fuel spar border
% in order to have them in a correct order for creating the
% final fuel sup and inf borders

tank_spar_sup{1}=[];
tank_spar_sup{2}=[];
tank_spar_inf{1}=[];
tank_spar_inf{2}=[];

for k=1:size(final_tank_spar_sup{2},1)
    tank_spar_sup{2}(k,:) = final_tank_spar_sup{2}(size(final_tank_spar_sup{2},1)+1-k,:);
end
tank_spar_sup{1} = final_tank_spar_sup{1};

for k=1:size(final_tank_spar_inf{2},1)
    tank_spar_inf{2}(k,:) = final_tank_spar_inf{2}(size(final_tank_spar_inf{2},1)+1-k,:);
end
tank_spar_inf{1} = final_tank_spar_inf{1};

% Places each spar border superior and inferior points in
% the structure Wings

Wings{i}.Fuel_tanks{j}.Tank_spar_inf_profiles = tank_spar_inf;
Wings{i}.Fuel_tanks{j}.Tank_spar_sup_profiles = tank_spar_sup;

%%%%%%%%%%%%%% This is not necessary for the program, only for the visualization with matlab %%%%%%%%%%%%%%

tank_sup = [];
tank_inf = [];
tank_sup = [tank_rib_sup{1}(2,:);tank_spar_sup{1};tank_rib_sup{2}(2,:);tank_rib_sup{2}(1,:);tank_spar_sup{2};tank_rib_sup{1}];
tank_inf = [tank_rib_inf{1}(1,:);tank_spar_inf{1};tank_rib_inf{2};tank_spar_inf{2};tank_rib_inf{1}(2,:);tank_rib_inf{1}(1,:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Places the fuel tank superior and inferior in
% the structure Wings

Wings{i}.Fuel_tanks{j}.Fuel_tank_sup_profile = tank_sup;
Wings{i}.Fuel_tanks{j}.Fuel_tank_inf_profile = tank_inf;

end
%}
