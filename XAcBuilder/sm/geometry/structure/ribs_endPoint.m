function [X_rib_end, Y_rib_end, Z_rib_end] = ribs_endPoint(Spars_Segment, rib_cellk, compseg_start, compseg_etas, compseg_length, ribs_etaEndk, LE_points)

coord_x_LE_points =  LE_points(:,1);
coord_y_LE_points =  LE_points(:,2);
coord_z_LE_points =  LE_points(:,3);


if strcmp(rib_cellk.rib_end,'trailingEdge') == 1  % ribreference seems to be useless because in any case the rib ending point must be on the same line than the rib starting point
    
    idx_smaller = find(compseg_etas < ribs_etaEndk);    
    if isempty(idx_smaller)
        t = 1;
    else
        t = idx_smaller(end);
    end
    
    t_next = compseg_start + t+1 - 1 ;
    t_currt = compseg_start + t - 1;
    
    if t == length(compseg_etas)
        delta = 0;
        alpha = 0;
        X_rib_end = coord_x_LE_points( t_currt );
        Y_sign = 1;
        Z_sign = 1;
    else
        delta = abs((ribs_etaEndk- compseg_etas(t))*compseg_length);
        alpha = atan(abs((coord_z_LE_points(t_next)-coord_z_LE_points(t_currt))/(coord_y_LE_points(t_next)-coord_y_LE_points(t_currt))));
        X_rib_end = (coord_x_LE_points(t_next)-coord_x_LE_points(t_currt)) * (ribs_etaEndk - compseg_etas(t)) / (compseg_etas(t_next) - compseg_etas(t_currt)) + coord_x_LE_points(t_currt);
        Y_sign = sign( LE_points(t_next,2)- LE_points(t_currt,2));
        Z_sign = sign( LE_points(t_next,3)- LE_points(t_currt,3));
    end
    
    Y_rib_end = coord_y_LE_points(t_currt) + delta*cos(alpha) * Y_sign;
    Z_rib_end = coord_z_LE_points(t_currt) + delta*sin(alpha) * Z_sign;
    
else
  %  switch id
%        case 'VerticalWing'         % Error in the xml file : it should be VTP instead of HTP for vertical tail
 %           u = 1;
 %       case 'HorizontalWing'
            num_segments = length(Spars_Segment);
            for i = 1: num_segments
                spar_segmentsUID{i} = Spars_Segment{i}.uID;
            end
            
            try
                u = find(strcmp(spar_segmentsUID, rib_cellk.rib_start));
            catch
                disp('This rib ends at a spar segment whose uID is not listed in the available spar segments')
            end
%    end
    
    %-----------------------------------------------
    idx_smaller = find(Spars_Segment{u}.eta < ribs_etaEndk);
    
    if isempty(idx_smaller)
        t = 1;
    else
        t = idx_smaller(end);
    end
    
    if  t == length(Spars_Segment{u}.eta)
        delta = 0;
        alpha = 0;
        Y_sign = 1; 
        Z_sign = 1; 
    else
        delta = (ribs_etaEndk - Spars_Segment{u}.eta(t)) * compseg_length;
        alpha = atan(abs(Spars_Segment{u}.middle(t+1,3)-Spars_Segment{u}.middle(t,3))/abs(Spars_Segment{u}.middle(t+1,2)-Spars_Segment{u}.middle(t,2)));
        Y_sign = sign( Spars_Segment{u}.middle(t+1,2) - Spars_Segment{u}.middle(t,2) );
        Z_sign = sign( Spars_Segment{u}.middle(t+1,3) - Spars_Segment{u}.middle(t,3) );
    end
    
    Y_rib_end = Spars_Segment{u}.middle(t,2) + delta*cos(alpha) * Y_sign;
    Z_rib_end = Spars_Segment{u}.middle(t,3) + delta*sin(alpha) * Z_sign;
    %-----------------------------------------
    %         idx_smaller = find(Spars_Segment{u}.eta <= ribs_etaEndk);
    %         t = idx_smaller(end);
    
    t =size(Spars_Segment{u}.eta,1);
    
    while Spars_Segment{u}.eta(t,1) > ribs_etaEndk
        t = t-1;
    end
    
    if  t == length(Spars_Segment{u}.eta)
        X_rib_end = Spars_Segment{u}.middle(t,1);
    else
        X_rib_end = ((Spars_Segment{u}.middle(t+1,1)-Spars_Segment{u}.middle(t,1))*(ribs_etaEndk - Spars_Segment{u}.eta(t)))/(Spars_Segment{u}.eta(t+1) - Spars_Segment{u}.eta(t)) + Spars_Segment{u}.middle(t,1);
    end
    %---------------------------------------------
end

end

