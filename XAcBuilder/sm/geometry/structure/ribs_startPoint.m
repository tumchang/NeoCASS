function [X_rib_start, Y_rib_start, Z_rib_start] = ribs_startPoint(Spars_Segment, rib_cellk, compseg_start, compseg_etas, compseg_length, ribs_etaStarti, LE_points)
% Calculates the y and z coordinates of each rib starting point

coord_x_LE_points =  LE_points(:,1);
coord_y_LE_points =  LE_points(:,2);
coord_z_LE_points =  LE_points(:,3);

if strcmp(rib_cellk.rib_start,'leadingEdge')==1
    
    idx_smaller = find(compseg_etas < ribs_etaStarti);
    if isempty(idx_smaller)
        t = 1;
    else
        t = idx_smaller(end);
    end
    
    t_next = compseg_start + t+1 - 1 ;
    t_currt = compseg_start + t - 1;
    
    if t == length(compseg_etas)
        X_rib_start = coord_x_LE_points(t_currt);
        Y_rib_start = coord_y_LE_points(t_currt);
        Z_rib_start = coord_z_LE_points(t_currt);
    else
        delta = abs((ribs_etaStarti- compseg_etas(t))*compseg_length);        
        alpha = atan( abs( (coord_z_LE_points(t_next)-coord_z_LE_points(t_currt))/(coord_y_LE_points(t_next)-coord_y_LE_points(t_currt)) ) );
        X_rib_start =  (coord_x_LE_points(t_next)-coord_x_LE_points(t_currt)) * (ribs_etaStarti - compseg_etas(t,1)) / (compseg_etas(t+1) - compseg_etas(t)) + coord_x_LE_points(t_currt);
        
        Y_sign_LE = sign( LE_points(t_next,2)- LE_points(t_currt,2));
        Z_sign_LE = sign( LE_points(t_next,3)- LE_points(t_currt,3));
        Y_rib_start = coord_y_LE_points(t_currt) + delta*cos(alpha) * Y_sign_LE;
        Z_rib_start = coord_z_LE_points(t_currt) + delta*sin(alpha) * Z_sign_LE;
    end
 
else
    
    %    switch id
    %        case 'VerticalWing'         % Error in the xml file : it should be VTP instead of HTP for vertical tail
    %            u = 1;
    %        case 'HorizontalWing'
    num_segments = length(Spars_Segment);
    for i = 1: num_segments
        spar_segmentsUID{i} = Spars_Segment{i}.uID;
    end
    try
        u = find(strcmp(spar_segmentsUID, rib_cellk.rib_start));
    catch
        errordlg('This rib starts at a spar segment whose uID is not listed in the available spar segments')
    end
    %    end
    
    idx_smaller = find(Spars_Segment{u}.eta < ribs_etaStarti);
    if isempty(idx_smaller)
        t = 1;
    else
        t = idx_smaller(end);
    end
    
    if t== length(Spars_Segment{u}.eta)
        X_rib_start  = Spars_Segment{u}.middle(t,1);
        Y_rib_start  = Spars_Segment{u}.middle(t,2);
        Z_rib_start  = Spars_Segment{u}.middle(t,3);
        
    else
        delta = abs((ribs_etaStarti- Spars_Segment{u}.eta(t))*compseg_length);        %   Spars_Segment{u}.eta_total_real
        alpha = atan(abs((Spars_Segment{u}.middle(t+1,3) - Spars_Segment{u}.middle(t,3))/(Spars_Segment{u}.middle(t+1,2)-Spars_Segment{u}.middle(t,2))));
        X_rib_start  = ( Spars_Segment{u}.middle(t+1,1) - Spars_Segment{u}.middle(t,1) ) * (ribs_etaStarti - Spars_Segment{u}.eta(t))/(Spars_Segment{u}.eta(t+1) - Spars_Segment{u}.eta(t)) + Spars_Segment{u}.middle(t,1);
        Y_sign = sign( Spars_Segment{u}.middle(t+1,2) - Spars_Segment{u}.middle(t,2) );
        Z_sign = sign( Spars_Segment{u}.middle(t+1,3) - Spars_Segment{u}.middle(t,3) );
        Y_rib_start  = Spars_Segment{u}.middle(t,2) + delta*cos(alpha)*Y_sign;
        Z_rib_start  = Spars_Segment{u}.middle(t,3) + delta*sin(alpha)*Z_sign;
    end
    
    
end


end