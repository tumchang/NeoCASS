function [X_rib_start, Y_rib_start, Z_rib_start] = ribs_startPoint(Spars_Segment, rib_cellk, sum_eta, ribs_etaStarti, id, LE_points)
% Calculates the y and z coordinates of each rib starting point

coord_x_LE_points =  LE_points(:,1);
coord_y_LE_points =  LE_points(:,2);
coord_z_LE_points =  LE_points(:,3);


if strcmp(rib_cellk.rib_start,'leadingEdge')==1
    
    idx_smaller = find(sum_eta < ribs_etaStarti);
    if isempty(idx_smaller)
        t = 1;
    else
        t = idx_smaller(end);
    end
    
    if t == size(sum_eta,1)
        delta = 0;
        alpha = 0;
        X_rib_start = coord_x_LE_points(t,1);
    else
        delta = abs((ribs_etaStarti- sum_eta(t,1))*eta_total);
        alpha = atan(abs((coord_z_LE_points(t+1,1)-coord_z_LE_points(t,1))/(coord_y_LE_points(t+1,1)-coord_y_LE_points(t,1))));
        X_rib_start = (abs(coord_x_LE_points(t+1,1)-coord_x_LE_points(t,1))*abs(ribs_etaStarti - sum_eta(t,1)))/abs(sum_eta(t+1,1) - sum_eta(t,1)) + coord_x_LE_points(t,1);
    end
    
    Y_rib_start = coord_y_LE_points(t,1) + delta*cos(alpha);
    Z_rib_start = coord_z_LE_points(t,1) + delta*sin(alpha);
    
else
    
    switch id
        case 'VerticalWing'         % Error in the xml file : it should be VTP instead of HTP for vertical tail
            u = 1;
        case 'HorizontalWing'
            num_segments = length(Spars_Segment);
            for i = 1: num_segments
                spar_segmentsUID{i} = Spars_Segment{i}.uID;
            end
            try
                u = find(strcmp(spar_segmentsUID, rib_cellk.rib_start));
            catch
                disp('This rib starts at a spar segment whose uID is not listed in the available spar segments')
            end
    end
    
    idx_smaller = find(Spars_Segment{u}.eta < ribs_etaStarti);
    if isempty(idx_smaller)
        t = 1;
    else
        t = idx_smaller(end);
    end
    
    if t== size(Spars_Segment{u}.eta,1)
        delta = 0;
        alpha = 0;
        X_rib_start  = Spars_Segment{u}.middle(t,1);
    else
        delta = abs((ribs_etaStarti- Spars_Segment{u}.eta(t,1))*Spars_Segment{u}.eta_total_real);
        alpha = atan(abs((Spars_Segment{u}.middle(t+1,3)-Spars_Segment{u}.middle(t,3))/(Spars_Segment{u}.middle(t+1,2)-Spars_Segment{u}.middle(t,2))));
        X_rib_start  = abs(((Spars_Segment{u}.middle(t+1,1)-Spars_Segment{u}.middle(t,1))*(ribs_etaStarti-Spars_Segment{u}.eta(t,1)))/(Spars_Segment{u}.eta(t+1,1) - Spars_Segment{u}.eta(t,1)) + Spars_Segment{u}.middle(t,1));
    end
    
    Y_rib_start  = Spars_Segment{u}.middle(t,2) + delta*cos(alpha);
    Z_rib_start  = Spars_Segment{u}.middle(t,3) + delta*sin(alpha);
end


end