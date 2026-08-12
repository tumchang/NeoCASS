function [X_spar_up, Y_spar_up, Z_spar_up] = dist_profile_sparPoint(profile, X_spar, Y_spar, Z_spar)
% Calculates for each spar the distance between this middle
% point of the spar and every other points of the corresponding
% profile upper

   %-------------- Lower ---------------------------%
    % Calculates for each spar the distance between this middle % point of
    % the spar and every other points of the corresponding   % profile inferior

%     switch id
%         case 'VerticalWing'
%            dist_up1 =  [profile(:,1)- X_spar, profile(:,3)- Z_spar, profile(:,2)- Y_spar];
%         case 'HorizontalWing'
             dist_up1 =  [profile(:,1)- X_spar, profile(:,2)- Y_spar, profile(:,3)- Z_spar];
%     end
    
    dist_up2 = dist_up1.^2;
    dist_up3 = sqrt(sum(dist_up2,2));
    
    [val_dist_up3, idx_dist_up3] = min(dist_up3);
    %  val_min_up(1,1) = val_dist_up3;
    X_spar_up = profile(idx_dist_up3,1); 
    Y_spar_up = profile(idx_dist_up3,2);
    Z_spar_up = profile(idx_dist_up3,3);
%{    
%     idx_min_up(1) = idx_dist_up3;
        
%     if idx_dist_up3 == 1           % Gets the nearest point of the upper spar profile
%         idx_min_up(2) = idx_dist_up3+1;
%     else
%         if dist_up3(idx_dist_up3-1,1) <= dist_up3(idx_dist_up3+1,1)
%             % val_min_up(2,1) = dist_up3(idx_dist_up3-1,1);
%             idx_min_up(2) = idx_dist_up3 - 1;
%         elseif dist_up3(idx_dist_up3-1,1) > dist_up3(idx_dist_up3+1,1)
%             idx_min_up(2) = idx_dist_up3 + 1;
%             % val_min_up(2,1) = dist_up3(idx_dist_up3+1,1);
%         end
%     end


%     switch id
%         case 'VerticalWing'
%             % Generates a point at the same x and z positions than the spar
%             % but wich will be the spar lower point ie the point
%             % with its y coordinate positiv
%             dY = abs(profile(idx_min_up(2),2) - profile(idx_min_up(1),2));
%             dx = abs(X_spar- profile(idx_min_up(1),1));
%             dX = abs(profile(idx_min_up(2),1) - profile(idx_min_up(1),1));
%             
%             dy =  dY*dx/dX;
%             
%             Y_spar_up = dy + profile(idx_min_up(1),2);
%             X_spar_up = X_spar;
%             Z_spar_up = Z_spar;
%         case  'HorizontalWing'
%             % Generates a point at the same x and y positions than the spar
%             % but wich will be the spar upper point
%             
%             dZ = abs(profile(idx_min_up(2),3)-profile(idx_min_up(1),3));
%             dx = abs(X_spar- profile(idx_min_up(1),1));
%             dX = abs(profile(idx_min_up(2),1)-profile(idx_min_up(1),1));
%             
%             dz =  dZ*dx/dX;
%             
%             Z_spar_up = dz + profile(idx_min_up(1),3);
%             X_spar_up = X_spar;
%             Y_spar_up = Y_spar;
%     end
%}
end