function [rib_cellj] = get_ribs_upper_lower_Profiles(rib_cellj)
% As with spar, this part will find rib_profile, rib_profile_sup / inf
% Further the two pair rib_sup & _inf points for each rib plane
% Separates the rib profile points which are superiors to the
% rib middle point from those which are inferior

switch id                              % vertical tail
   
    case  'VerticalWing'        
        for k = 1:rib_cellj.ribs_number_cell
            
            idx_up = rib_cellj.ribs_profile{k}(:,2)  >= 0;
            rib_cellj.ribs_profile_sup{k} = rib_cellj.ribs_profile{k}(idx_up, :);
            rib_cellj.ribs_profile_inf{k} = rib_cellj.ribs_profile{k}(~idx_up, :);
            
            % Generates the superior and inferior front points of each rib
            [rib_cellj.front_rib_sup{k,1}] = dist_profile_point(rib_cellj.ribs_profile_sup{k}, rib_cellj.X_front_rib(k), rib_cellj.Y_front_rib(k), rib_cellj.Z_front_rib(k));
            [rib_cellj.front_rib_inf{k,1}] = dist_profile_point(rib_cellj.ribs_profile_inf{k}, rib_cellj.X_front_rib(k), rib_cellj.Y_front_rib(k), rib_cellj.Z_front_rib(k));
            
            % Generates the superior and inferior rear points of each rib
            [rib_cellj.rear_rib_sup{k,1}] = dist_profile_point(rib_cellj.ribs_profile_sup{k}, rib_cellj.X_rear_rib(k), rib_cellj.Y_rear_rib(k), rib_cellj.Z_rear_rib(k));
            [rib_cellj.rear_rib_inf{k,1}] = dist_profile_point(rib_cellj.ribs_profile_inf{k}, rib_cellj.X_rear_rib(k), rib_cellj.Y_rear_rib(k), rib_cellj.Z_rear_rib(k));          
        end
 
  case 'HorizontalWing'             % horizontal wing
   
            for k = 1:rib_cellj.ribs_number_cell                
                idx_up = rib_cellj.ribs_profile{k}(:,3)  >= rib_cellj.Z_front_rib(k);
                rib_cellj.ribs_profile_sup{k} = rib_cellj.ribs_profile{k}(idx_up, :);
                rib_cellj.ribs_profile_inf{k} = rib_cellj.ribs_profile{k}(~idx_up, :);
                
                a = rib_cellj.ribs_profile_sup{k}(3,1);
                
                [rib_cellj.front_rib_sup{k,1}] = dist_profile_point2(rib_cellj.ribs_profile_sup{k}, rib_cellj.X_front_rib(k), rib_cellj.Y_front_rib(k), rib_cellj.Z_front_rib(k),k);
                [rib_cellj.front_rib_inf{k,1}] = dist_profile_point2(rib_cellj.ribs_profile_inf{k}, rib_cellj.X_front_rib(k), rib_cellj.Y_front_rib(k), rib_cellj.Z_front_rib(k));                
               
                [rib_cellj.rear_rib_sup{k,1}]  = dist_profile_point2(rib_cellj.ribs_profile_sup{k}, rib_cellj.X_rear_rib(k), rib_cellj.Y_rear_rib(k), rib_cellj.Z_rear_rib(k));
                [rib_cellj.rear_rib_inf{k,1}]  = dist_profile_point2(rib_cellj.ribs_profile_inf{k}, rib_cellj.X_rear_rib(k), rib_cellj.Y_rear_rib(k), rib_cellj.Z_rear_rib(k));
            end
end        
end 




function  [mindist] = dist_profile_point(profile, point_x, point_y, point_z)
% Calculates the distance between every points of the rib profile superior and the front rib middle point

dist_up_front1 = [profile(:,1)-point_x, profile(:,3)-point_z, profile(:,2)- point_y];
dist_up_front2 = dist_up_front1.^2;
dist_up_front = sqrt(sum(dist_up_front2,2));

% Gets the 2 nearest points of the superior rib profile from the front rib middle point
[val_distUp, idx_distUp] = min(dist_up_front);
%  val_min_up(1) = val_distUp;
idx_min_up(1) = idx_distUp;

if idx_distUp == 1
    % val_min_up(2) = dist_up_front(idx_distUp+1,1);
    idx_min_up(2) = idx_distUp+1;
elseif idx_distUp == length(dist_up_front)
     idx_min_up(2) = idx_distUp-1;
else
    if dist_up_front(idx_distUp-1,1)<= dist_up_front(idx_distUp+1,1)
        %   val_min_up(2) = dist_up_front(idx_distUp-1,1);
        idx_min_up(2) = idx_distUp-1;
    else
        %  val_min_up(2) = dist_up_front(idx_distUp+1,1);
        idx_min_up(2) = idx_distUp+1;
    end
    
end

% Generates a point at the same x and z positions than the rib middle point but which will be the front rib superior point

dY = abs(profile(idx_min_up(2),2) - profile(idx_min_up(1),2));
dx = abs(point_x - profile(idx_min_up(1),1));
dX = abs(profile(idx_min_up(2),1) - profile(idx_min_up(1),1));

dy =  dY*dx/dX;

Y_front_rib_sup = dy + profile(idx_min_up(1),2);
X_front_rib_sup = point_x;
Z_front_rib_sup = point_z;

mindist = [X_front_rib_sup, Y_front_rib_sup, Z_front_rib_sup];
end

function  [mindist] = dist_profile_point2(profile, point_x, point_y, point_z,k)
% Calculates the distance between every points of the rib profile superior and the front rib middle point

dist_up_front1 = [profile(:,1)-point_x, profile(:,3)-point_z, profile(:,2)- point_y];
dist_up_front2 = dist_up_front1.^2;
dist_up_front = sqrt(sum(dist_up_front2,2));

% Gets the 2 nearest points of the superior rib profile from the front rib middle point
[val_distUp, idx_distUp] = min(dist_up_front);
%  val_min_up(1) = val_distUp;
idx_min_up(1) = idx_distUp;

if idx_distUp == 1
    % val_min_up(2) = dist_up_front(idx_distUp+1,1);
    idx_min_up(2) = idx_distUp+1;
elseif idx_distUp == length(dist_up_front)
    idx_min_up(2) = idx_distUp-1;
else    
    if dist_up_front(idx_distUp-1,1)<= dist_up_front(idx_distUp+1,1)
        %   val_min_up(2) = dist_up_front(idx_distUp-1,1);
        idx_min_up(2) = idx_distUp-1;
    else
        %  val_min_up(2) = dist_up_front(idx_distUp+1,1);
        idx_min_up(2) = idx_distUp+1;
    end
    
end

% Generates a point at the same x and z positions than the rib middle point but which will be the front rib superior point

dZ = abs(profile(idx_min_up(2),3) - profile(idx_min_up(1),3));
dx = abs(point_x - profile(idx_min_up(1),1));
dX = abs(profile(idx_min_up(2),1) - profile(idx_min_up(1),1));

dz =  dZ*dx/dX;

Z_front_rib_sup = dz + profile(idx_min_up(1),3);
X_front_rib_sup = point_x;
Y_front_rib_sup = point_y;

mindist = [X_front_rib_sup, Y_front_rib_sup, Z_front_rib_sup];
end

