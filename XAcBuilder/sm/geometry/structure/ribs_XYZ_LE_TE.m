function [X_rib_TE, Y_rib_TE, Z_rib_TE] = ribs_XYZ_LE_TE(rib_cellj, compseg_start, compseg_etas, compseg_length, TE_points)

% Calculates the x y and z coordinates of the trailing edge of each rib position
 
coord_x_TE_points = TE_points(:,1);
coord_y_TE_points = TE_points(:,2);
coord_z_TE_points = TE_points(:,3);

for k = 1:rib_cellj.ribs_number_cell
    
    % t =length(compseg_etas);
    %     while compseg_etas(t) > rib_cellj.eta_ribs(k)
    %         t = t-1;
    %     end
    idx_smaller = find(compseg_etas <= rib_cellj.eta_ribs(k));
    if isempty(idx_smaller)
        t = 1;
    else
        t = idx_smaller(end);
    end
    
    t_next = compseg_start + t+1 - 1 ;
    t_currt = compseg_start + t - 1;
    
    if compseg_etas(t) == rib_cellj.eta_ribs(k);
        X_rib_TE(k,1) = coord_x_TE_points(t_currt);
        Y_rib_TE(k,1) = coord_y_TE_points(t_currt);
        Z_rib_TE(k,1) = coord_z_TE_points(t_currt);
        
    else
        delta = (rib_cellj.eta_ribs(k)- compseg_etas(t))*compseg_length;
        alpha = atan(abs(coord_z_TE_points( t_next)-coord_z_TE_points(t_currt))/abs(coord_y_TE_points(t_next)-coord_y_TE_points(t_currt)));
        X_rib_TE(k,1) =  (coord_x_TE_points( t_next)-coord_x_TE_points(t_currt) ) * (rib_cellj.eta_ribs(k)-compseg_etas(t)) / (compseg_etas(t+1) - compseg_etas(t)) + coord_x_TE_points(t_currt);
        Y_sign = sign( coord_y_TE_points(t_next) - coord_y_TE_points( t_currt) ) ;
        Z_sign = sign( coord_z_TE_points(t_next) - coord_z_TE_points( t_currt) ) ;
        Y_rib_TE(k,1) = coord_y_TE_points(t_currt) + delta*cos(alpha) * Y_sign;
        Z_rib_TE(k,1) = coord_z_TE_points(t_currt) + delta*sin(alpha) * Z_sign;
    end
end
end