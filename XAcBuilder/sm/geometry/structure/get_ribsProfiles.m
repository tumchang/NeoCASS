function [rib_cellj] = get_ribsProfiles(wingSectionDef, Spars_Segment, rib_cellj, compseg_start, compseg_etas, TE_points, LE_points, ribs_rotz)

% ------------ Further calculate Rib profiles --------------%
% Calculates the scale coefficient for each rib profile and generates those rib profiles by copying the previous kink profile

for k = 1:rib_cellj.ribs_number_cell
    
    idx_smaller = find(compseg_etas <= rib_cellj.eta_ribs(k));
    if isempty(idx_smaller)
        t_nearEle = 1;
    else
        t_nearEle = idx_smaller(end);
    end
    
    t_next = compseg_start + t_nearEle+1 - 1 ;
    t_currt = compseg_start + t_nearEle - 1;
    
    rib_cellj.scale_coeff(k) = (rib_cellj.X_rib_TE(k) -  rib_cellj.X_rib_LE(k))/(TE_points( t_currt,1) - LE_points( t_currt,1));
    
    airfoil_wingSec = wingSectionDef.relAirfoil{t_currt, 1};                   % 0 -> 1
    forePoint = [rib_cellj.X_rib_LE(k), rib_cellj.Y_rib_LE(k), rib_cellj.Z_rib_LE(k)];
    
    % forePoint = [rib_cellj.X_front_rib(k), rib_cellj.Y_front_rib(k), rib_cellj.Z_front_rib(k)];
    % coorsSys_wingSec = wingSectionDef.coorsSys{t_currt};
    
    if compseg_etas(t_nearEle) == rib_cellj.eta_ribs(k)
                eyeMat=eye(3);
                scaleMat=[eyeMat(1,:)*rib_cellj.scale_coeff(k); eyeMat(2,:)*rib_cellj.scale_coeff(k); eyeMat(3,:)*rib_cellj.scale_coeff(k)];
                coorsSys_ribLE = coorsSys_wingSec*scaleMat;
%         ribs_profile{k} = wingSectionDef.airfoil{t_currt, 1};
        
    else
        % disp('cd')
        scale_coeff = (rib_cellj.X_rib_TE(k) -  rib_cellj.X_rib_LE(k));   %/(TE_points(t_currt,1) - LE_points(t_currt,1));
        eyeMat=eye(3);
        scaleMat=[eyeMat(1,:)*scale_coeff;eyeMat(2,:)*scale_coeff;eyeMat(3,:)*scale_coeff];
       
        axis_next = wingSectionDef.coorsSys{t_next};
        axis_currt = wingSectionDef.coorsSys{t_currt};
        
        R_n2c = axis_next / axis_currt;
        r3_z = -atand(R_n2c(1,2)/R_n2c(1,1));
        r2_y = asind(R_n2c(1,3));
        r1_x = -atand(R_n2c(2,3)/R_n2c(3,3));
 
        angle_portion = ( rib_cellj.eta_ribs(k) - compseg_etas(t_nearEle) )/(compseg_etas(t_nearEle+1) - compseg_etas(t_nearEle));

        ribEta_r1_x = angle_portion * r1_x;
        ribEta_r2_y = angle_portion * r2_y;
        ribEta_r3_z = angle_portion * r3_z;
        
        [transMat2] = eulerTrans(ribEta_r1_x,ribEta_r2_y,ribEta_r3_z);
        coorsSys_ribLE = axis_currt * transMat2 * scaleMat;
      
   end
    ribs_profile{k} = [coorsSys_ribLE*airfoil_wingSec']'+[forePoint(1)*ones(size(airfoil_wingSec,1),1),forePoint(2)*ones(size(airfoil_wingSec,1),1),forePoint(3)*ones(size(airfoil_wingSec,1),1)];
    
    hold on
    plot3(ribs_profile{k}(:,1), ribs_profile{k}(:,2), ribs_profile{k}(:,3),'k.');
    hold on
end


%---------------------Apply rotation------------------%
%----So far the calculated rib profiles are parallel to the wingSection
%----airfoils before them; Next is to apply the rotation to the ribs ---
%----

num_segments = length(Spars_Segment);
for i = 1: num_segments
    spar_segmentsUID{i} = Spars_Segment{i}.uID;
end

for num_rib = 1:rib_cellj.ribs_number_cell   % for each rib profile, find out its normal vector
    rib_profile = ribs_profile{num_rib};
    
    forePoint = [rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib)];
    rearPoint = [rib_cellj.X_rib_TE(num_rib), rib_cellj.Y_rib_TE(num_rib), rib_cellj.Z_rib_TE(num_rib)];
    
    Vector1 = rearPoint - forePoint;
    
    num_points = length(rib_profile);   randPoint = round(num_points/4);
    surfPoint = rib_profile(randPoint,:);
    
    Vector2 = surfPoint - forePoint;
    Normal_ribProfile = cross(Vector1,Vector2);
    Normal_ribProfile = Normal_ribProfile./norm(Normal_ribProfile);
    Normal_rP = [Normal_ribProfile(1), abs(Normal_ribProfile(2)), Normal_ribProfile(3)];
    switch rib_cellj.rib_rotationReference    % calculate the angle between rib_profile's plane and ribrotationReferences
        case 'eta-axis'      % first calculate the angle between eta-axis and ribs_profile, ==: angle between globalX-Z plane axis and Normal_ribProfile
            theta = atan(Normal_rP(2)/Normal_rP(1));    % atan(Normal_rP(2)/sqrt( Normal_rP(1)^2 + Normal_rP(3)^2));
            ref_vector = [0,1,0];
            ref_point = [rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib)];
            
        case 'leadingEdge'    % first calculate the angle between leadingEdge and ribs_profile, ==: angle between
            if num_rib == 1
                LE_vector = [rib_cellj.X_rib_LE(num_rib+1) - rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib+1) - rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib+1)-rib_cellj.Z_rib_LE(num_rib)];
            else
                LE_vector = [rib_cellj.X_rib_LE(num_rib) - rib_cellj.X_rib_LE(num_rib-1), rib_cellj.Y_rib_LE(num_rib) - rib_cellj.Y_rib_LE(num_rib-1), rib_cellj.Z_rib_LE(num_rib)-rib_cellj.Z_rib_LE(num_rib-1)];
            end
            theta = pi/2 - acos(dot(LE_vector(1:2), Normal_rP(1:2))/(norm(LE_vector(1:2))*norm(Normal_rP(1:2))));   % mod(atan2(Normal_rP(2) - LE_vector(2), Normal_rP(1) - LE_vector(1)),2*pi)*180/pi;
            ref_vector = LE_vector;
            ref_point = [rib_cellj.X_rib_LE(num_rib), rib_cellj.Y_rib_LE(num_rib), rib_cellj.Z_rib_LE(num_rib)];
            
        case 'trailingEdge'   % first calculate the angle between trailingEdge and ribs_profile
            if num_rib == 1
                TE_vector = [rib_cellj.X_rib_TE(num_rib+1) - rib_cellj.X_rib_TE(num_rib), rib_cellj.Y_rib_TE(num_rib+1) - rib_cellj.Y_rib_TE(num_rib), rib_cellj.Z_rib_TE(num_rib+1)-rib_cellj.Z_rib_TE(num_rib)];
            else
                TE_vector = [rib_cellj.X_rib_TE(num_rib) - rib_cellj.X_rib_TE(num_rib-1), rib_cellj.Y_rib_TE(num_rib) - rib_cellj.Y_rib_TE(num_rib-1), rib_cellj.Z_rib_TE(num_rib)-rib_cellj.Z_rib_TE(num_rib-1)];
            end
            theta = pi/2 - acos(dot(TE_vector(1:2), Normal_rP(1:2))/(norm(TE_vector(1:2))*norm(Normal_rP(1:2))));
            ref_vector = TE_vector;
            ref_point = [rib_cellj.X_rib_TE(num_rib), rib_cellj.Y_rib_TE(num_rib), rib_cellj.Z_rib_TE(num_rib)];
            
        case spar_segmentsUID  % find out the fronSpar or the rearSpar
            u_whichSpar = find(strcmp(spar_segmentsUID, rib_cellj.rib_rotationReference)); % 
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
            
            theta = pi/2 - acos(dot(spar_vector(1:2), Normal_rP(1:2))/(norm(spar_vector(1:2))*norm(Normal_rP(1:2))));
            ref_vector = spar_vector;
            ref_point = Spars_Segment{u_whichSpar}.middle(t_sparPos,:);
    end
    %  then rotate how much more needed, according to "ribs_rotz" angle,
    %  w.r.t ref_vector
    
    delta_theta = ribs_rotz/180*pi - theta;
    
    if delta_theta == 0
        rib_cellj.ribs_profile{num_rib} = rib_profile;
    else
        rela_ribProfile = rib_profile - [ref_point(1).*ones(size(rib_profile,1),1), ref_point(2).*ones(size(rib_profile,1),1), ref_point(3).*ones(size(rib_profile,1),1)];
        Rz_rotate = [cos(delta_theta), -sin(delta_theta), 0; sin(delta_theta), cos(delta_theta), 0; 0, 0, 1];
        
        new_rela_ribProfile = (Rz_rotate * rela_ribProfile')';
        
        new_ribProfile = new_rela_ribProfile + [ref_point(1).*ones(size(rib_profile,1),1), ref_point(2).*ones(size(rib_profile,1),1), ref_point(3).*ones(size(rib_profile,1),1)];
        rib_cellj.ribs_profile{num_rib} = new_ribProfile;
    end
    
    hold on
    plot3(rib_cellj.ribs_profile{num_rib}(:,1), rib_cellj.ribs_profile{num_rib}(:,2), rib_cellj.ribs_profile{num_rib}(:,3),'g.');
    hold on
    
end

%{
% for k = 1:rib_cellj.ribs_number_cell
%
%     % Places the profile of the rib at the global origin
%     rib_cellj.ribs_profile{k}(:,1) = rib_cellj.ribs_profile{k}(:,1) - abs(rib_cellj.X_front_rib(k));
%     rib_cellj.ribs_profile{k}(:,2) = rib_cellj.ribs_profile{k}(:,2) - abs(rib_cellj.Y_front_rib(k));
%
%     if rib_cellj.Z_front_rib(k) > 0
%         rib_cellj.ribs_profile{k}(:,3) = rib_cellj.ribs_profile{k}(:,3) - abs(rib_cellj.Z_front_rib(k));
%     else
%         rib_cellj.ribs_profile{k}(:,3) = rib_cellj.ribs_profile{k}(:,3) + abs(rib_cellj.Z_front_rib(k));
%     end
%
%     % There might be an error in the xml file about
%     % the angle of rotation. It should either 90?or 0? but not both of them in the same xml file
%
% %     angle_z = ribs_rotx - ribs_rotz;
%     switch id
%         case 'VerticalWing'
%             Rz = [cos(-angle_z) 0  sin(-angle_z); 0 1 0; -sin(-angle_z) 0 cos(-angle_z)]; %Rotation around y global axis
%         case 'HorizontalWing'
%             Rz = [cos(angle_z) -sin(angle_z) 0; sin(angle_z) cos(angle_z) 0; 0 0 1]; %Rotation around z global axis
%     end
%     for t=1:size(rib_cellj.ribs_profile{k},1)
%         rib_cellj.ribs_profile{k}(t,:) = rib_cellj.ribs_profile{k}(t,:)*Rz;
%     end
%     % Places the profile of the rib at the rib position
%     rib_cellj.ribs_profile{k}(:,1) = rib_cellj.ribs_profile{k}(:,1) + abs(rib_cellj.X_front_rib(k,1));
%     rib_cellj.ribs_profile{k}(:,2) = rib_cellj.ribs_profile{k}(:,2) + abs(rib_cellj.Y_front_rib(k,1));
%
%     if rib_cellj.Z_front_rib(k,1) > 0
%         rib_cellj.ribs_profile{k}(:,3) = rib_cellj.ribs_profile{k}(:,3) + abs(rib_cellj.Z_front_rib(k,1));
%     else
%         rib_cellj.ribs_profile{k}(:,3) = rib_cellj.ribs_profile{k}(:,3) - abs(rib_cellj.Z_front_rib(k,1));
%     end
%
%
%     hold on
%     plot3(rib_cellj.ribs_profile{k}(:,1),rib_cellj.ribs_profile{k}(:,2),rib_cellj.ribs_profile{k}(:,3),'b+');
%     hold on
%
% end
%
% ribs_profile = rib_cellj.ribs_profile;
%}
end
