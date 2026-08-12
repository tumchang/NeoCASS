function [rib_cellj] = get_ribs_upper_lower_Profiles2(rib_cellj)
% As with spar, this part will find rib_profile, rib_profile_sup / inf
% Further the two pair rib_sup & _inf points for each rib plane
% Separates the rib profile points which are superiors to the
% rib middle point from those which are inferior

for k = 1:rib_cellj.ribs_number_cell
    
    rib_profile = rib_cellj.ribs_profile{k};
    
    rib_LE_point =  rib_cellj.rib_LE_point{k};
    rib_TE_point =  rib_cellj.rib_TE_point{k};
    
    Vector1 = rib_TE_point - rib_LE_point;
    
    num_points = length(rib_cellj.ribs_profile{k});   randPoint = round(num_points/4);
    surfPoint = rib_profile(randPoint,:);
    
    Vector2 = surfPoint -  rib_LE_point;
    Normal_ribProfile = cross(Vector1,Vector2);
    Normal_rP = cross(Normal_ribProfile, Vector1);      % cP short for cutting plane
    Normal_rP = Normal_rP./norm(Normal_rP);
    
    n_var = 1/( Normal_rP(1)*rib_LE_point(1) + Normal_rP(2)*rib_LE_point(2) + Normal_rP(3)*rib_LE_point(3) );
    temp_profile = rib_profile.*[n_var*Normal_rP(1).*ones(size(rib_profile,1),1), n_var*Normal_rP(2).*ones(size(rib_profile,1),1), n_var*Normal_rP(3).*ones(size(rib_profile,1),1)];
    
    if n_var*Normal_rP(3) > 0
        idx_up = temp_profile(:,3) >= 1 - ( temp_profile(:,1) + temp_profile(:,2));
    elseif n_var*Normal_rP(3) < 0
        idx_up = temp_profile(:,3) <= 1 - ( temp_profile(:,1) + temp_profile(:,2));
    elseif n_var*Normal_rP(3) == 0   % degenerate case
        if n_var*Normal_rP(2) > 0
            idx_up = temp_profile(:,2) >= 1 - temp_profile(:,1);
        elseif n_var*Normal_rP(2) < 0
            idx_up = temp_profile(:,2) <= 1 - temp_profile(:,1);
        end
    end

    rib_cellj.ribs_profile_sup{k} = rib_cellj.ribs_profile{k}(idx_up, :);
    rib_cellj.ribs_profile_inf{k} = rib_cellj.ribs_profile{k}(~idx_up, :);
  
    
    % Generates the superior and inferior front points of each rib
    [rib_cellj.front_rib_sup{k,1}] = dist_profile_point(rib_cellj.ribs_profile_sup{k}, rib_cellj.X_front_rib(k), rib_cellj.Y_front_rib(k), rib_cellj.Z_front_rib(k));
    [rib_cellj.front_rib_inf{k,1}] = dist_profile_point(rib_cellj.ribs_profile_inf{k}, rib_cellj.X_front_rib(k), rib_cellj.Y_front_rib(k), rib_cellj.Z_front_rib(k));
    
    % Generates the superior and inferior rear points of each rib
    [rib_cellj.rear_rib_sup{k,1}] = dist_profile_point(rib_cellj.ribs_profile_sup{k}, rib_cellj.X_rear_rib(k), rib_cellj.Y_rear_rib(k), rib_cellj.Z_rear_rib(k));
    [rib_cellj.rear_rib_inf{k,1}] = dist_profile_point(rib_cellj.ribs_profile_inf{k}, rib_cellj.X_rear_rib(k), rib_cellj.Y_rear_rib(k), rib_cellj.Z_rear_rib(k));
end

end

function  [mindist] = dist_profile_point(profile, point_x, point_y, point_z)

dist_up_front1 = [profile(:,1)-point_x, profile(:,3)-point_z, profile(:,2)- point_y];
dist_up_front2 = dist_up_front1.^2;
dist_up_front = sqrt(sum(dist_up_front2,2));

[val_distUp, idx_distUp] = min(dist_up_front);
X_front_rib_sup = profile(idx_distUp,1);
Y_front_rib_sup = profile(idx_distUp,2);
Z_front_rib_sup = profile(idx_distUp,3);
mindist = [X_front_rib_sup, Y_front_rib_sup, Z_front_rib_sup];
end
