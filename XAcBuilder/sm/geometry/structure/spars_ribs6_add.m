function [Spar_segments, rib_cell, Wings, sparsRibs_geo] = spars_ribs6_add(sparsRibs_struct)

% load sparsRibs_struct_boxwing.mat
%-------------------------------------------------------------------------%
wingSectionDef = sparsRibs_struct.wingSectionDef;                              % ~~ wing_geo.sectionDef
compseg_start = sparsRibs_struct.compSegStart;
compseg_etas = sparsRibs_struct.compSegEtas;
compseg_length = sparsRibs_struct.compSegLength;
[sparsRibs_geo] = sparsRibs_struct2geo(sparsRibs_struct);

[TE_points, LE_points] = get_LE_TE_points(wingSectionDef, compseg_start, compseg_etas);

[Spar_segments] = get_sparProfiles(sparsRibs_geo, wingSectionDef,  compseg_start, compseg_etas, compseg_length, LE_points, TE_points);

%***********************************
% figure()
% for k=1:length(Spar_segments)
% plot3(Spar_segments{k}.inf(:,1), Spar_segments{k}.inf(:,2), Spar_segments{k}.inf(:,3), 'b+')
% axis equal
% hold on
% plot3(Spar_segments{k}.sup(:,1), Spar_segments{k}.sup(:,2), Spar_segments{k}.sup(:,3), 'b+')
% hold on
% plot3(Spar_segments{k}.middle(:,1), Spar_segments{k}.middle(:,2), Spar_segments{k}.middle(:,3), 'm.')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% end
%***********************************


% Ribs Calculation ----------------------------------------
[rib_cell] = get_ribProfiles(sparsRibs_geo, wingSectionDef, Spar_segments, compseg_start, compseg_etas, compseg_length, TE_points, LE_points);

%***********************************
 
% for k = 1:length(rib_cell)
%     
%     front_rib_sup = cell2mat(rib_cell{k}.front_rib_sup);
%     front_rib_inf = cell2mat(rib_cell{k}.front_rib_inf);
%     rear_rib_sup = cell2mat(rib_cell{k}.rear_rib_sup);
%     rear_rib_inf = cell2mat(rib_cell{k}.rear_rib_inf);
%     
%     plot3(front_rib_sup(:,1), front_rib_sup(:,2), front_rib_sup(:,3), 'r*')
%     hold on
%     plot3(front_rib_inf(:,1), front_rib_inf(:,2), front_rib_inf(:,3), 'b*')
%     hold on
%     plot3(rear_rib_sup(:,1), rear_rib_sup(:,2), rear_rib_sup(:,3), 'm*')
%     hold on
%     plot3(rear_rib_inf(:,1), rear_rib_inf(:,2), rear_rib_inf(:,3), 'g*')
%     hold on
%     axis equal
%     xlabel('X')
%     ylabel('Y')
%     zlabel('Z')
% end
 

Wings = update_wing_struct(sparsRibs_geo, Spar_segments, rib_cell);
end

function [TE_points,LE_points] = get_LE_TE_points(wingSectionDef, compseg_start, compseg_etas)

num_compseg =  length(compseg_etas);            % 4*1; here!
LE_points = zeros(num_compseg,3);

for u = 1:num_compseg
    LE_points(u,:) = wingSectionDef.point{compseg_start + u - 1}';
end

%Search the TE coordinates for each section of each wing
TE_points = zeros(num_compseg,3);

for j = 1: num_compseg
    [XXX, indice_x_max] = max(wingSectionDef.airfoil{j}(:,1));
    TE_points(j,:) = wingSectionDef.airfoil{j}(indice_x_max,:);
end

% figure()
% plot3(LE_points(:,1), LE_points(:,2),LE_points(:,3),'ro');
% hold on
% plot3(TE_points(:,1), TE_points(:,2),TE_points(:,3),'go');

end

function [Spars_Segment] = get_sparProfiles(sparsRibs_geo, wingSectionDef,  compseg_start, compseg_etas, compseg_length, LE_points, TE_points)
%% -----------------Input preparation-----------------
numSparPosition = length(sparsRibs_geo.spars.positions.uIDs);
spars_eta = sparsRibs_geo.spars.positions.eta;
spars_xsi = sparsRibs_geo.spars.positions.xsi;

numSparSegment = length(sparsRibs_geo.spars.segments.uIDs);
Spars_Segment = cell(numSparSegment,1);

new_numSparPosition = 0;
for numSeg = 1:numSparSegment
    Spars_Segment{numSeg}.uIDs = sparsRibs_geo.spars.segments.uIDs;
    Spar_points_number = length(sparsRibs_geo.spars.segments.positions{1,numSeg});
    
    Spars_Segment{numSeg}.uID = sparsRibs_geo.spars.segments.uIDs{numSeg};
    
    segments_eta = zeros(1,Spar_points_number);
    segments_ksi = zeros(1,Spar_points_number);
    
    for t=1:Spar_points_number
        for u = 1:numSparPosition
            if strcmp(sparsRibs_geo.spars.positions.uIDs{1,u}, sparsRibs_geo.spars.segments.positions{1,numSeg}{1,t}) == 1
                segments_eta(t) = spars_eta(u);
                segments_ksi(t) = spars_xsi(u);
            end
        end
    end
    
%     %------------Add componentSegment elements that are crossed by
%     %------------the spars
%     k = 0;
%     k_next = 0;
%     for i = 1: Spar_points_number - 1
%         
%         segments_eta_new(i + k_next) = segments_eta(i);
%         segments_ksi_new(i + k_next) = segments_ksi(i);
%         
%         for j = 1: length(compseg_etas)
%             checked_ele = compseg_etas(j);
%             if  ( checked_ele - segments_eta(i) ) * ( checked_ele - segments_eta(i+1) ) < 0  && abs(checked_ele - segments_eta(i) ) > 0.01
%                 k = k + 1;
%                 
%                 segments_eta_new(i + k) = compseg_etas(j);
%                 segments_ksi_new(i + k) = segments_ksi(i);
%                 k_next = k;
%             end
%         end
%     end
%     segments_eta_new(end+1) = segments_eta(end);
%     segments_ksi_new(end+1) = segments_ksi(end);
    
%     Spars_Segment{numSeg}.eta = segments_eta_new;
%     Spars_Segment{numSeg}.xsi = segments_ksi_new;
    Spars_Segment{numSeg}.eta = segments_eta;
    Spars_Segment{numSeg}.xsi = segments_ksi;
    
    new_numSparPosition = new_numSparPosition + length(segments_eta);
    
%     segments_eta_new = [];
%     segments_ksi_new = [];
end

%% ---------------------------------------------------

for numSeg = 1:numSparSegment
    %---------------- number of points for each spar ---------------%
    Spar_points_number = length(Spars_Segment{numSeg}.eta);
    Spars_Segment{numSeg}.middle = zeros(Spar_points_number,3);
    Spars_Segment{numSeg}.inf = zeros(Spar_points_number,3);
    Spars_Segment{numSeg}.sup = zeros(Spar_points_number,3);
    
    for t_sparPos =1:Spar_points_number
        idx_smaller = find(compseg_etas <= Spars_Segment{numSeg}.eta(t_sparPos));
        if isempty(idx_smaller)
            t_nearEle = 1;
        else
            t_nearEle = idx_smaller(end);
        end
        
        t_next = compseg_start + t_nearEle+1 - 1 ;
        t_currt = compseg_start + t_nearEle - 1;
        
        if compseg_etas(t_nearEle) == Spars_Segment{numSeg}.eta(t_sparPos)
            X_spar_LE = LE_points( t_currt,1) ;
            Y_spar_LE = LE_points( t_currt,2) ;
            Z_spar_LE = LE_points( t_currt,3) ;
            
            X_spar_TE = TE_points( t_currt,1) ;
            Y_spar_TE = TE_points( t_currt,2) ;
            Z_spar_TE = TE_points( t_currt,3) ;
            
        else
            delta = (Spars_Segment{numSeg}.eta(t_sparPos) - compseg_etas(t_nearEle))*compseg_length;
            alpha_LE = atan( abs( LE_points(t_next,3) - LE_points(t_currt,3) ) / abs( LE_points(t_next,2) - LE_points(t_currt,2) ) );
            alpha_TE = atan( abs( TE_points(t_next,3) - TE_points(t_currt,3))/abs(TE_points(t_next,2)-TE_points(t_currt,2)));
            
            Y_sign_LE = sign( LE_points(t_next,2)- LE_points(t_currt,2));
            Z_sign_LE = sign( LE_points(t_next,3)- LE_points(t_currt,3));
            Y_sign_TE = sign( TE_points(t_next,2)- TE_points(t_currt,2));
            Z_sign_TE = sign( TE_points(t_next,3)- TE_points(t_currt,3));
            
            X_spar_LE = abs(LE_points(t_next,1)-LE_points(t_currt,1))*abs(Spars_Segment{numSeg}.eta(t_sparPos)-compseg_etas(t_nearEle))/abs(compseg_etas(t_nearEle+1) -...
                compseg_etas(t_nearEle)) + LE_points(t_currt,1);
            Y_spar_LE = LE_points( t_currt,2) + delta*cos(alpha_LE) * Y_sign_LE;
            Z_spar_LE = LE_points( t_currt,3) + delta*sin(alpha_LE) * Z_sign_LE;
            
            X_spar_TE = (abs(TE_points(t_next,1)-TE_points(t_currt,1))*abs(Spars_Segment{numSeg}.eta(t_sparPos)-compseg_etas(t_nearEle)))/abs(compseg_etas(t_nearEle+1) - compseg_etas(t_nearEle)) + TE_points(t_currt,1);
            Y_spar_TE = TE_points( t_currt,2) + delta*cos(alpha_TE) * Y_sign_TE;
            Z_spar_TE = TE_points( t_currt,3) + delta*sin(alpha_TE) * Z_sign_TE;
            
        end
        
        Spars_Segment{numSeg}.sparPos_LEs(t_sparPos,:) = [X_spar_LE, Y_spar_LE, Z_spar_LE];
        Spars_Segment{numSeg}.sparPos_TEs(t_sparPos,:) = [X_spar_TE, Y_spar_TE, Z_spar_TE];
        
        %----------------------------
        delta_x = X_spar_TE - X_spar_LE;
        delta_y = Y_spar_TE - Y_spar_LE;
        delta_z = Z_spar_TE - Z_spar_LE;
        
        X_spar = X_spar_LE + Spars_Segment{numSeg}.xsi(t_sparPos) * delta_x;
        Y_spar = Y_spar_LE + Spars_Segment{numSeg}.xsi(t_sparPos) * delta_y;
        Z_spar = Z_spar_LE + Spars_Segment{numSeg}.xsi(t_sparPos) * delta_z;
        
        Spars_Segment{numSeg}.middle(t_sparPos,:) = [X_spar, Y_spar, Z_spar];
        
%         figure(20)
%                 hold on
%                 plot3(X_spar_LE, Y_spar_LE, Z_spar_LE, 'ro');
%                 axis equal
%                 hold on
%                 plot3(X_spar_TE, Y_spar_TE, Z_spar_TE, 'ro');
%                 hold on
%                 plot3(X_spar, Y_spar, Z_spar, 'kv')
%         hold on
        
        %------------------------------------------------------------------
        %% ----above Calculate spar_LE, spar_TE, spar points-----
        %   ----below Calculate Spar profiles and sup and inf -------%
        %------===========================================================        
        
        airfoil_wingSec = wingSectionDef.relAirfoil{t_currt, 1};
        forePoint = [X_spar_LE, Y_spar_LE, Z_spar_LE];        

        if compseg_etas(t_nearEle) == Spars_Segment{numSeg}.eta(t_sparPos)
            spars_profile = wingSectionDef.airfoil{t_currt, 1};
        else             % the orientation of the interpolated spar profiles between elements need to be interpolated as the orientation between the two
            
            scale_coeff = ( X_spar_TE -  X_spar_LE)/(TE_points(t_currt, 1) - LE_points( t_currt, 1));
            eyeMat=eye(3);
            scaleMat=[eyeMat(1,:)*scale_coeff;eyeMat(2,:)*scale_coeff;eyeMat(3,:)*scale_coeff];

            axis_next = wingSectionDef.coorsSys{t_next};    
            axis_currt = wingSectionDef.coorsSys{t_currt};  
            
            R_n2c = axis_next / axis_currt;
            r3_z = -atand(R_n2c(1,2)/R_n2c(1,1));
            r2_y = asind(R_n2c(1,3));
            r1_x = -atand(R_n2c(2,3)/R_n2c(3,3));
             
            
            angle_portion = ( Spars_Segment{numSeg}.eta(t_sparPos) - compseg_etas(t_nearEle) )/(compseg_etas(t_nearEle+1) - compseg_etas(t_nearEle));
            
            sparEta_r1_x = angle_portion * r1_x;
            sparEta_r2_y = angle_portion * r2_y;
            sparEta_r3_z = angle_portion * r3_z;
            
            [transMat2] = eulerTrans(sparEta_r1_x,sparEta_r2_y,sparEta_r3_z);
            coorsSys_sparLE = axis_currt * transMat2 * scaleMat;
            spars_profile_lessPnts = [coorsSys_sparLE*airfoil_wingSec']'+[forePoint(1)*ones(size(airfoil_wingSec,1),1),forePoint(2)*ones(size(airfoil_wingSec,1),1),forePoint(3)*ones(size(airfoil_wingSec,1),1)];
            spars_profile = airfoilInterp(spars_profile_lessPnts,299);
        end
        
      
        Spars_Segment{numSeg}.cross_profile{t_sparPos,1} = spars_profile;
        
        rearPoint = [X_spar_TE, Y_spar_TE, Z_spar_TE];
        
        %% find out the cutting plane of the airfoil: connecting forePoint, rearPoint, perpendicular to the airfoil
        % airfoil normal:
        Vector1 = rearPoint - forePoint;
        
        num_points = length(spars_profile);   randPoint = round(num_points/4);
        surfPoint = spars_profile(randPoint,:);
        
        Vector2 = surfPoint - forePoint;
        Normal_sparProfile = cross(Vector1,Vector2);
        Normal_cP = cross(Normal_sparProfile, Vector1);      % cP short for cutting plane
        Normal_cP = Normal_cP./norm(Normal_cP);
        
        n_var = 1/( Normal_cP(1)*forePoint(1) + Normal_cP(2)*forePoint(2) + Normal_cP(3)*forePoint(3) );
        
        % the 3D plane function:  n_var*Normal_cP(1)*x + n_var*Normal_cP(2)*y + n_var*Normal_cP(3)*z = 1
        % Hence, for each spar profile, the points spread on two sides of the planes
        temp_profile = spars_profile.*[n_var*Normal_cP(1).*ones(size(spars_profile,1),1), n_var*Normal_cP(2).*ones(size(spars_profile,1),1), n_var*Normal_cP(3).*ones(size(spars_profile,1),1)]; 
        
        if n_var*Normal_cP(3) > 0            
            idx_up = temp_profile(:,3) >= 1 - ( temp_profile(:,1) + temp_profile(:,2));              
        elseif n_var*Normal_cP(3) < 0
            idx_up = temp_profile(:,3) <= 1 - ( temp_profile(:,1) + temp_profile(:,2));             
        elseif n_var*Normal_cP(3) == 0   % degenerate case
            if n_var*Normal_cP(2) > 0 
                idx_up = temp_profile(:,2) >= 1 - temp_profile(:,1);                 
            elseif n_var*Normal_cP(2) < 0 
                idx_up = temp_profile(:,2) <= 1 - temp_profile(:,1);                 
            end
        end   
        
    %    idx_up = sum(spars_profile.*[n_var*Normal_cP(1).*ones(size(spars_profile,1),1), n_var*Normal_cP(2).*ones(size(spars_profile,1),1), n_var*Normal_cP(3).*ones(size(spars_profile,1),1)],2) >= 1;
        spars_profile_up = spars_profile(idx_up, :);
        spars_profile_low = spars_profile(~idx_up, :);
        
        Spars_Segment{numSeg}.cross_profile_inf{t_sparPos,1} = spars_profile_low;
        Spars_Segment{numSeg}.cross_profile_sup{t_sparPos,1} = spars_profile_up;
        
        
%         figure(102)
%         hold on
%         plot3(spars_profile(:,1), spars_profile(:,2), spars_profile(:,3), 'b+')
%         hold on
%         plot3(spars_profile_up(:,1), spars_profile_up(:,2), spars_profile_up(:,3), 'ro')
%         hold on
%         plot3(spars_profile_low(:,1), spars_profile_low(:,2), spars_profile_low(:,3), 'k*')
%         hold on
        
        
        [X_spar_up, Y_spar_up, Z_spar_up] = dist_profile_sparPoint(spars_profile_up, X_spar, Y_spar, Z_spar);
        [X_spar_low, Y_spar_low, Z_spar_low] = dist_profile_sparPoint(spars_profile_low, X_spar, Y_spar, Z_spar);
        Spars_Segment{numSeg}.inf(t_sparPos,:) = [X_spar_low, Y_spar_low, Z_spar_low];
        Spars_Segment{numSeg}.sup(t_sparPos,:) = [X_spar_up, Y_spar_up, Z_spar_up];
%                 hold on
%                 plot3(X_spar_up, Y_spar_up, Z_spar_up, 'k*', X_spar_low, Y_spar_low, Z_spar_low, 'k*');
        
        
    end
end

for j = 1:numSparSegment
    for k = 1:size(Spars_Segment{j}.inf,1)
        Spars_Segment{j}.inf_new(k,:) = Spars_Segment{j}.inf(size(Spars_Segment{j}.inf,1)+1 - k ,:);
    end
end

% Create each definitiv final spar profile by arranging the points
for j = 1:numSparSegment
    Spars_Segment{j}.Spar_final_structure = vertcat(Spars_Segment{j}.sup,Spars_Segment{j}.inf_new, Spars_Segment{j}.sup(1,:));
end

end

function [rib_cell] = get_ribProfiles(sparsRibs_geo, wingSectionDef, Spars_Segment, compseg_start, compseg_etas, compseg_length, TE_points, LE_points)
% Creates for each spar a structure containing points coordinates of this spar

% Creates for each ribs group a structure containing those points
ribs_etaStart = sparsRibs_geo.ribsDefinitions.etaStart;
ribs_etaEnd = sparsRibs_geo.ribsDefinitions.etaEnd;
ribs_numOfRibs = sparsRibs_geo.ribsDefinitions.numberOfRibs;
ribs_rotz = sparsRibs_geo.ribsDefinitions.rotz;

ribsDefinition_number = length(sparsRibs_geo.ribsDefinitions.uIDs);

rib_cell = cell(ribsDefinition_number,1);

for k = 1:ribsDefinition_number
    rib_cell{k}.rib_name = sparsRibs_geo.ribsDefinitions.uIDs{1,k};
    rib_cell{k}.rib_start = sparsRibs_geo.ribsDefinitions.ribStart{1,k};
    rib_cell{k}.rib_end = sparsRibs_geo.ribsDefinitions.ribEnd{1,k};
    rib_cell{k}.rib_reference  = sparsRibs_geo.ribsDefinitions.ribReference{1,k};
    rib_cell{k}.rib_rotationReference = sparsRibs_geo.ribsDefinitions.ribRotationReference{1,k};
end

% ------------- Line 945 - 1083 ---------------------------%
% Calculates the y and z, and X coordinates of each rib ending point
Y_rib_start = zeros(ribsDefinition_number,1);
Z_rib_start = zeros(ribsDefinition_number,1);
X_rib_start = zeros(ribsDefinition_number,1);

Y_rib_end = zeros(ribsDefinition_number,1);
Z_rib_end = zeros(ribsDefinition_number,1);
X_rib_end = zeros(ribsDefinition_number,1);


for k = 1:ribsDefinition_number
    dist_ribj = [];
    
    [X_rib_start(k), Y_rib_start(k), Z_rib_start(k)] = ribs_startPoint(Spars_Segment, rib_cell{k}, compseg_start, compseg_etas, compseg_length, ribs_etaStart(k), LE_points);
    [X_rib_end(k), Y_rib_end(k), Z_rib_end(k)] = ribs_startPoint(Spars_Segment, rib_cell{k}, compseg_start, compseg_etas, compseg_length, ribs_etaEnd(k), TE_points);
    
    %     plot3(X_rib_start(k), Y_rib_start(k), Z_rib_start(k),'ro',X_rib_end(k), Y_rib_end(k), Z_rib_end(k),'bo');
    %     axis equal
    
    [rib_cell{k}.X_front_rib, rib_cell{k}.Y_front_rib, rib_cell{k}.Z_front_rib] = get_XYZ_front_rib_add(compseg_etas, rib_cell{k}, Spars_Segment, ribs_numOfRibs(k), ...
        ribs_etaStart(k), ribs_etaEnd(k), X_rib_start(k), Y_rib_start(k), Z_rib_start(k), X_rib_end(k), Y_rib_end(k), Z_rib_end(k), LE_points);
    rib_cell{k}.ribs_number_cell = ribs_numOfRibs(k);
    
    eta_ribs = zeros(ribs_numOfRibs(k)-1, 1);
    if ribs_numOfRibs(k) == 1
        if k == 1
            dist_ribj = sqrt( (rib_cell{k}.Y_front_rib - Y_rib_start(k))^2 + (rib_cell{k}.Z_front_rib - Z_rib_start(k))^2 );
            eta_ribs = dist_ribj/compseg_length;
            %   rib_cell{k}.eta_ribs =  [0; eta_ribs];
        else
            dist_ribj = sqrt( (rib_cell{k}.Y_front_rib - rib_cell{k-1}.Y_front_rib(end))^2 + (rib_cell{k}.Z_front_rib - rib_cell{k-1}.Z_front_rib(end))^2 );
            eta_ribs = dist_ribj/compseg_length;
            %       rib_cell{k}.eta_ribs = eta_ribs + rib_cell{k-1}.eta_ribs(end);
        end
    else
        
        for u = 1:ribs_numOfRibs(k)
            if u == 1
                if k == 1
                    dist_ribj(u) = sqrt( (rib_cell{k}.Y_front_rib(u) - Y_rib_start(k))^2 + (rib_cell{k}.Z_front_rib(u) - Z_rib_start(k))^2 );
                    eta_ribs(u) = sum(dist_ribj)/compseg_length;
                else
                    dist_ribj(u) = sqrt( (rib_cell{k}.Y_front_rib(u) - rib_cell{k-1}.Y_front_rib(end))^2 + (rib_cell{k}.Z_front_rib(u) - rib_cell{k-1}.Z_front_rib(end))^2 );
                    eta_ribs(u) = sum(dist_ribj)/compseg_length;
                end
            else
                dist_ribj(u) = sqrt( (rib_cell{k}.Y_front_rib(u) - rib_cell{k}.Y_front_rib(u-1))^2 + (rib_cell{k}.Z_front_rib(u) - rib_cell{k}.Z_front_rib(u-1))^2 );
                eta_ribs(u) = sum(dist_ribj)/compseg_length;
            end
        end
        
    end
    if k == 1
        rib_cell{k}.eta_ribs =  eta_ribs;
    else
        rib_cell{k}.eta_ribs = eta_ribs + rib_cell{k-1}.eta_ribs(end);
    end
end

% Calculates the x y and z coordinates of the leading edge of each rib position
for j = 1:ribsDefinition_number
    [rib_cell{j}.X_rib_TE, rib_cell{j}.Y_rib_TE, rib_cell{j}.Z_rib_TE] = ribs_XYZ_LE_TE(rib_cell{j}, compseg_start, compseg_etas, compseg_length, TE_points);
    [rib_cell{j}.X_rib_LE, rib_cell{j}.Y_rib_LE, rib_cell{j}.Z_rib_LE] = ribs_XYZ_LE_TE(rib_cell{j}, compseg_start, compseg_etas, compseg_length, LE_points);
%     hold on
%     plot3(rib_cell{j}.X_rib_TE, rib_cell{j}.Y_rib_TE, rib_cell{j}.Z_rib_TE, 'bv')
%     hold on
%     plot3(rib_cell{j}.X_rib_LE, rib_cell{j}.Y_rib_LE, rib_cell{j}.Z_rib_LE, 'bv')
%     hold on
%     plot3(X_rib_start(k), Y_rib_start(k), Z_rib_start(k),'cD',X_rib_end(k), Y_rib_end(k), Z_rib_end(k),'cD');
%     hold on
end

for j = 1:ribsDefinition_number
    [rib_cell{j}.ribs_profile] = get_ribsProfiles2(wingSectionDef, Spars_Segment, rib_cell{j}, compseg_start, compseg_etas, ribs_rotz(j));
end

%-------------------- Line 1449 - 1475 No change   -----------------%

for j = 1:ribsDefinition_number
    
    for k = 1:rib_cell{j}.ribs_number_cell
        %Search the LE coordinates for each profile of each rib
        rib_cell{j}.rib_LE_point{k}=[];
        [XXX, indice_x_min] = min(rib_cell{j}.ribs_profile{k}(:,1));
        rib_cell{j}.rib_LE_point{k}(1,1) = rib_cell{j}.ribs_profile{k}(indice_x_min,1);
        rib_cell{j}.rib_LE_point{k}(1,2) = rib_cell{j}.ribs_profile{k}(indice_x_min,2);
        rib_cell{j}.rib_LE_point{k}(1,3) = rib_cell{j}.ribs_profile{k}(indice_x_min,3);
        
        %Search the TE coordinates for each profile of each rib
        rib_cell{j}.rib_TE_point{k}=[];
        [XXX, indice_x_max] = max(rib_cell{j}.ribs_profile{k}(:,1));
        rib_cell{j}.rib_TE_point{k}(1,1) = rib_cell{j}.ribs_profile{k}(indice_x_max,1);
        rib_cell{j}.rib_TE_point{k}(1,2) = rib_cell{j}.ribs_profile{k}(indice_x_max,2);
        rib_cell{j}.rib_TE_point{k}(1,3) = rib_cell{j}.ribs_profile{k}(indice_x_max,3);
    end
end

%% ---- To solve the intersections between the rearSpar and each rib profiles

for j = 1:ribsDefinition_number
    [rib_cell{j}.X_rear_rib, rib_cell{j}.Y_rear_rib, rib_cell{j}.Z_rear_rib] = get_XYZ_rear_rib(sparsRibs_geo, rib_cell{j}, compseg_etas, TE_points, Spars_Segment);
end

for j = 1:ribsDefinition_number
    [rib_cell{j}] = get_ribs_upper_lower_Profiles2(rib_cell{j});
end

end


function  Wings = update_wing_struct(sparsRibs_geo, Spar, rib_cell)
%% Addon Wings structure, for further use of fuel tank drawing!

Spars_number = length(sparsRibs_geo.spars.segments.uIDs);
ribsDefinition_number = length(sparsRibs_geo.ribsDefinitions.uIDs);

for j = 1:ribsDefinition_number
    for k = 1:rib_cell{j}.ribs_number_cell
        idx_inbetwn = rib_cell{j}.ribs_profile_sup{k}(:,1) >= rib_cell{j}.X_front_rib(k) & rib_cell{j}.ribs_profile_sup{k}(:,1) <= rib_cell{j}.X_rear_rib(k);
        rib_cell{j}.ribs_profile_final_sup{k} = rib_cell{j}.ribs_profile_sup{k}(idx_inbetwn, :);
        
        idx_inbetwn2 = rib_cell{j}.ribs_profile_inf{k}(:,1) >= rib_cell{j}.X_front_rib(k) & rib_cell{j}.ribs_profile_inf{k}(:,1) <= rib_cell{j}.X_rear_rib(k);
        rib_cell{j}.ribs_profile_final_inf{k} = rib_cell{j}.ribs_profile_inf{k}(idx_inbetwn2, :);
    end
end

% Create each definitiv final rib profile by adding the front sup rib, the front rib inf , the rear rib sup, the rear rib inf to the sup and inf rib final profile

for j = 1:ribsDefinition_number
    
    for k = 1:rib_cell{j}.ribs_number_cell
        rib_cell{j}.ribs_profile_final{k} = vertcat(rib_cell{j}.rear_rib_sup{k},...
            rib_cell{j}.ribs_profile_final_sup{k},...
            rib_cell{j}.front_rib_sup{k},...
            rib_cell{j}.front_rib_inf{k},...
            rib_cell{j}.ribs_profile_final_inf{k},...
            rib_cell{j}.rear_rib_inf{k},...
            rib_cell{j}.rear_rib_sup{k});
        
        rib_cell{j}.ribs_profile_sup_final{k} = vertcat(rib_cell{j}.rear_rib_sup{k},...
            rib_cell{j}.ribs_profile_final_sup{k},...
            rib_cell{j}.front_rib_sup{k});
        
        rib_cell{j}.ribs_profile_inf_final{k} = vertcat(rib_cell{j}.front_rib_inf{k},...
            rib_cell{j}.ribs_profile_final_inf{k},...
            rib_cell{j}.rear_rib_inf{k});
    end
    
end

%% Places each rib and spar structure within its corresponding wing cell
size_spars_x = 0;
size_spars_y = 0;
size_spars_z = 0;

size_ribs_x = 0;
size_ribs_y = 0;
size_ribs_z = 0;

for j = 1:Spars_number
    Wings.Spars{j}.Spars_name = Spar{j}.uIDs;
    Wings.Spars{j}.Spars_uID = Spar{j}.uIDs;
    Wings.Spars{j}.Spars_profile = Spar{j}.Spar_final_structure;
    Wings.Spars{j}.Spars_profile_sup = Spar{j}.sup;
    Wings.Spars{j}.Spars_profile_inf = Spar{j}.inf;
    Wings.Spars{j}.Spars_middle = Spar{j}.middle;
    
    Wings.Spars{j}.Spars_cross_profile = Spar{j}.cross_profile;
    Wings.Spars{j}.Spars_cross_profile_sup = Spar{j}.cross_profile_sup;
    Wings.Spars{j}.Spars_cross_profile_inf = Spar{j}.cross_profile_inf;
   
    size_spars_x = max(size_spars_x, size(Wings.Spars{j}.Spars_profile(1:end-1,1)));
    size_spars_y = max(size_spars_y, size(Wings.Spars{j}.Spars_profile(1:end-1,2)));
    size_spars_z = max(size_spars_z, size(Wings.Spars{j}.Spars_profile(1:end-1,3)));
end

for j = 1:ribsDefinition_number
    for k=1:rib_cell{j}.ribs_number_cell
        Wings.Ribs{j}.Ribs_name = rib_cell{j}.rib_name;
        Wings.Ribs{j}.Ribs_profile{k} = rib_cell{j}.ribs_profile_final{k};
        Wings.Ribs{j}.Ribs_profile_inf{k} = rib_cell{j}.ribs_profile_inf_final{k};
        Wings.Ribs{j}.Ribs_profile_sup{k} = rib_cell{j}.ribs_profile_sup_final{k};
        
        size_ribs_x = max(size_ribs_x, size(Wings.Ribs{j}.Ribs_profile{k}(1:end-1,1)));
        size_ribs_y = max(size_ribs_y, size(Wings.Ribs{j}.Ribs_profile{k}(1:end-1,2)));
        size_ribs_z = max(size_ribs_z, size(Wings.Ribs{j}.Ribs_profile{k}(1:end-1,3)));
    end
end

end
