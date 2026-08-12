function [ribs_profile] = get_ribsProfiles2(wingSectionDef, Spars_Segment, rib_cellj, compseg_start, compseg_etas, ribs_rotz)

% ------------ Further calculate Rib profiles --------------%
% Calculates the scale coefficient for each rib profile and generates those rib profiles by copying the previous kink profile

for num_rib = 1:rib_cellj.ribs_number_cell
    
    idx_smaller = find(compseg_etas <= rib_cellj.eta_ribs(num_rib));
    if isempty(idx_smaller)
        t_nearEle = 1;
    else
        t_nearEle = idx_smaller(end);
    end
    
    t_currt = compseg_start + t_nearEle - 1;
    airfoil_basic = wingSectionDef.relAirfoil{t_currt, 1};                   % 0 -> 1
    % which localCoordSys
    [coorsSys_ribLE, ref_point] = localCoordSys(Spars_Segment, rib_cellj, ribs_rotz, num_rib);

    ribs_profile_lessPnts = [coorsSys_ribLE*airfoil_basic']'+[ref_point(1)*ones(size(airfoil_basic,1),1),ref_point(2)*ones(size(airfoil_basic,1),1),ref_point(3)*ones(size(airfoil_basic,1),1)];    
    ribs_profile{num_rib} = airfoilInterp(ribs_profile_lessPnts,299);
     
%     hold on
%     plot3(ribs_profile{num_rib}(:,1), ribs_profile{num_rib}(:,2), ribs_profile{num_rib}(:,3),'k.');
%     hold on
end
end

function  [coordSys, ref_point] = localCoordSys(Spars_Segment, rib_cellj, ribs_rotz, num_rib)
%---------------------Apply rotation------------------%
%----So far the calculated rib profiles are parallel to the wingSection
%----airfoils before them; Next is to apply the rotation to the ribs ---

num_segments = length(Spars_Segment);
for i = 1: num_segments
    spar_segmentsUID{i} = Spars_Segment{i}.uID;
end

switch rib_cellj.rib_rotationReference    % calculate the angle between rib_profile's plane and ribrotationReferences
    case 'globalY'
        x_axis = [1; 0; 0]; 
        y_axis = [0; 1; 0];
        z_axis = [0; 0; 1];  
        
        theta_z = ribs_rotz - 90;
        Rz_rotate = [cosd(theta_z), -sind(theta_z), 0; sind(theta_z), cosd(theta_z), 0; 0, 0, 1];
        
        scale_coeff = (rib_cellj.X_rib_TE(num_rib) -  rib_cellj.X_rib_LE(num_rib));   
        eyeMat=eye(3);
        scaleMat=[eyeMat(1,:)*scale_coeff;eyeMat(2,:)*scale_coeff;eyeMat(3,:)*scale_coeff];
  
        coordSys = [x_axis, y_axis, z_axis] * Rz_rotate * scaleMat;
        
        ref_point = [rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib)];
        
        
         
    case 'eta-axis'      % first calculate the angle between eta-axis and ribs_profile, ==: angle between globalX-Z plane axis and Normal_ribProfile
        if num_rib == 1
            LE_vector = [rib_cellj.X_rib_LE(num_rib+1) - rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib+1) - rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib+1)-rib_cellj.Z_rib_LE(num_rib)];
        else
            LE_vector = [rib_cellj.X_rib_LE(num_rib) - rib_cellj.X_rib_LE(num_rib-1), rib_cellj.Y_rib_LE(num_rib) - rib_cellj.Y_rib_LE(num_rib-1), rib_cellj.Z_rib_LE(num_rib)-rib_cellj.Z_rib_LE(num_rib-1)];
        end
        
        x_axis = [1; 0; 0];
        y_axis = [0; LE_vector(2); LE_vector(3)];
        z_axis = [0; -LE_vector(3); LE_vector(2)];
        
        theta_z = 90-ribs_rotz;
        Rz_rotate = [cosd(theta_z), -sind(theta_z), 0; sind(theta_z), cosd(theta_z), 0; 0, 0, 1];
        
        scale_coeff = (rib_cellj.X_rib_TE(num_rib) -  rib_cellj.X_rib_LE(num_rib));   
        eyeMat=eye(3);
        scaleMat=[eyeMat(1,:)*scale_coeff;eyeMat(2,:)*scale_coeff;eyeMat(3,:)*scale_coeff];
  
        coordSys = [x_axis, y_axis, z_axis] * Rz_rotate * scaleMat;
        
        ref_point = [rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib)];
        
    case 'leadingEdge'    % first calculate the angle between leadingEdge and ribs_profile, ==: angle between
        if num_rib == 1
            LE_vector = [rib_cellj.X_rib_LE(num_rib+1) - rib_cellj.X_rib_LE(num_rib); rib_cellj.Y_rib_LE(num_rib+1) - rib_cellj.Y_rib_LE(num_rib); rib_cellj.Z_rib_LE(num_rib+1)-rib_cellj.Z_rib_LE(num_rib)];
        else
            LE_vector = [rib_cellj.X_rib_LE(num_rib) - rib_cellj.X_rib_LE(num_rib-1); rib_cellj.Y_rib_LE(num_rib) - rib_cellj.Y_rib_LE(num_rib-1); rib_cellj.Z_rib_LE(num_rib)-rib_cellj.Z_rib_LE(num_rib-1)];
        end
        
        chord_vector = [rib_cellj.X_rib_TE(num_rib); rib_cellj.Y_rib_TE(num_rib); rib_cellj.Z_rib_TE(num_rib)] - [rib_cellj.X_rib_LE(num_rib); rib_cellj.Y_rib_LE(num_rib); rib_cellj.Z_rib_LE(num_rib)];
        
        z_axis = cross(chord_vector, LE_vector);
        z_axis = z_axis./norm(z_axis);
        
        y_axis = LE_vector./norm(LE_vector);
        x_axis = cross(y_axis, z_axis);
        
        theta_z = 90-ribs_rotz;
        Rz_rotate = [cosd(theta_z), -sind(theta_z), 0; sind(theta_z), cosd(theta_z), 0; 0, 0, 1];
        
        scale_coeff = (rib_cellj.X_rib_TE(num_rib) -  rib_cellj.X_rib_LE(num_rib));    
        eyeMat=eye(3);
        scaleMat=[eyeMat(1,:)*scale_coeff;eyeMat(2,:)*scale_coeff;eyeMat(3,:)*scale_coeff];
        coordSys = [x_axis, y_axis, z_axis] * Rz_rotate * scaleMat;
        
        ref_point = [rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib)];
        
    case 'trailingEdge'   % first calculate the angle between trailingEdge and ribs_profile
        if num_rib == 1
            TE_vector = [rib_cellj.X_rib_TE(num_rib+1) - rib_cellj.X_rib_TE(num_rib); rib_cellj.Y_rib_TE(num_rib+1) - rib_cellj.Y_rib_TE(num_rib); rib_cellj.Z_rib_TE(num_rib+1)-rib_cellj.Z_rib_TE(num_rib)];
        else
            TE_vector = [rib_cellj.X_rib_TE(num_rib) - rib_cellj.X_rib_TE(num_rib-1); rib_cellj.Y_rib_TE(num_rib) - rib_cellj.Y_rib_TE(num_rib-1); rib_cellj.Z_rib_TE(num_rib)-rib_cellj.Z_rib_TE(num_rib-1)];
        end
        
        chord_vector = [rib_cellj.X_rib_TE(num_rib); rib_cellj.Y_rib_TE(num_rib); rib_cellj.Z_rib_TE(num_rib)] - [rib_cellj.X_rib_LE(num_rib); rib_cellj.Y_rib_LE(num_rib); rib_cellj.Z_rib_LE(num_rib)];
        
        z_axis = cross(chord_vector, TE_vector);
        z_axis = z_axis./norm(z_axis);
        
        y_axis = TE_vector./norm(TE_vector);
        x_axis = cross(y_axis, z_axis);
        
        theta_z = 90-ribs_rotz;
        Rz_rotate = [cosd(theta_z), -sind(theta_z), 0; sind(theta_z), cosd(theta_z), 0; 0, 0, 1];
        
        scale_coeff = (rib_cellj.X_rib_TE(num_rib) -  rib_cellj.X_rib_LE(num_rib));   
        eyeMat=eye(3);
        scaleMat=[eyeMat(1,:)*scale_coeff;eyeMat(2,:)*scale_coeff;eyeMat(3,:)*scale_coeff];
        coordSys = [x_axis, y_axis, z_axis] * Rz_rotate * scaleMat;
        
        ref_point = [rib_cellj.X_rib_TE(num_rib), rib_cellj.Y_rib_TE(num_rib), rib_cellj.Z_rib_TE(num_rib)];
        
    case spar_segmentsUID  % find out the fronSpar or the rearSpar
        u_whichSpar = find(strcmp(spar_segmentsUID, 'frontSpar')); % rib_cellj.rib_rotationReference
        idx_smaller = find(Spars_Segment{u_whichSpar}.eta <= rib_cellj.eta_ribs(num_rib));
        if isempty(idx_smaller)
            t_sparPos = 1;
        else
            t_sparPos = idx_smaller(end);
        end
        
        if t_sparPos == length(Spars_Segment{u_whichSpar}.eta)
            spar_vector = Spars_Segment{u_whichSpar}.middle(t_sparPos,:) - Spars_Segment{u_whichSpar}.middle(t_sparPos-1,:);
        else
            spar_vector = Spars_Segment{u_whichSpar}.middle(t_sparPos+1,:) - Spars_Segment{u_whichSpar}.middle(t_sparPos,:);
        end        
        
        x_axis = Spars_Segment{u_whichSpar}.sparPos_TEs(t_sparPos, :) - Spars_Segment{u_whichSpar}.sparPos_LEs(t_sparPos, :);
        x_axis = x_axis'./norm(x_axis);        
        y_axis = spar_vector'./norm(spar_vector);
        z_axis = cross(x_axis, y_axis);
        
        theta_z = 90-ribs_rotz;
        Rz_rotate = [cosd(theta_z), -sind(theta_z), 0; sind(theta_z), cosd(theta_z), 0; 0, 0, 1];
        
        scale_coeff = (rib_cellj.X_rib_TE(num_rib) -  rib_cellj.X_rib_LE(num_rib));  
        eyeMat=eye(3);
        scaleMat=[eyeMat(1,:)*scale_coeff;eyeMat(2,:)*scale_coeff;eyeMat(3,:)*scale_coeff];
        coordSys = [x_axis, y_axis, z_axis] * Rz_rotate * scaleMat;
        
        ref_point = [rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib)];
end

end
