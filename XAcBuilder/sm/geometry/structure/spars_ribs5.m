function [Spar_segments, rib_cell, Wings, sparsRibs_geo] = spars_ribs6(sparsRibs_struct)
% load CPACSgeo.mat
% load acb_struct.mat
% 
% wing_geo = CPACSgeo.wings.component{1,1};
% sparsRibs_geo = wing_geo.componentSegment{1,1}.structure;
% sparsRibs_geo.wingSectionDef = wing_geo.sectionDef;

%-------------------------------------------------------------------------%
wingSectionDef = sparsRibs_struct.wingSectionDef;                              % ~~ wing_geo.sectionDef
compseg_start = sparsRibs_struct.compSegStart;
compseg_etas = sparsRibs_struct.compSegEtas;
compseg_length = sparsRibs_struct.compSegLength;
[sparsRibs_geo] = sparsRibs_struct2geo(sparsRibs_struct);

[TE_points, LE_points] = get_LE_TE_points(wingSectionDef, compseg_start, compseg_etas);

[Spar_segments,Y_spar] = get_sparProfiles(sparsRibs_geo, wingSectionDef,  compseg_etas, compseg_length, LE_points, TE_points);

%***********************************
%{
% figure()
% for k=1:length(Spar_segments)
% plot3(Spar_segments{k}.inf(:,1), Spar_segments{k}.inf(:,2), Spar_segments{k}.inf(:,3), 'ro')
% axis equal
% hold on
% plot3(Spar_segments{k}.sup(:,1), Spar_segments{k}.sup(:,2), Spar_segments{k}.sup(:,3), 'b*')
% hold on
% % plot3(Spar_segments{k}.middle(:,1), Spar_segments{k}.middle(:,2), Spar_segments{k}.middle(:,3), 'k*')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% end
%***********************************
%}

% Ribs Calculation ----------------------------------------
[rib_cell,X_front_rib, Y_front_rib, Z_front_rib] = calc_ribProfiles(sparsRibs_geo, wingSectionDef, Spar_segments, Y_spar, compseg_etas, compseg_length, TE_points, LE_points);
 
%*********************************** 
%{
for k = 1:length(rib_cell)
    
    front_rib_sup = cell2mat(rib_cell{k}.front_rib_sup); 
    front_rib_inf = cell2mat(rib_cell{k}.front_rib_inf);
    rear_rib_sup = cell2mat(rib_cell{k}.rear_rib_sup);
    rear_rib_inf = cell2mat(rib_cell{k}.rear_rib_inf);
    
    plot3(front_rib_sup(:,1), front_rib_sup(:,2), front_rib_sup(:,3), 'r*')
    hold on
    plot3(front_rib_inf(:,1), front_rib_inf(:,2), front_rib_inf(:,3), 'b*')
    hold on
    plot3(rear_rib_sup(:,1), rear_rib_sup(:,2), rear_rib_sup(:,3), 'm*')
    hold on
    plot3(rear_rib_inf(:,1), rear_rib_inf(:,2), rear_rib_inf(:,3), 'g*')
    hold on
    axis equal
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
end
%}

Wings = update_wing_struct(sparsRibs_geo, Spar_segments, rib_cell, Y_front_rib, Y_spar);
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

function [Spars_Segment,Y_spar] = get_sparProfiles(sparsRibs_geo, wingSectionDef,  compseg_etas, compseg_length, LE_points, TE_points)

coord_x_TE_points = TE_points(:,1);
coord_y_TE_points = TE_points(:,2);
coord_z_TE_points = TE_points(:,3);

coord_x_LE_points =  LE_points(:,1);
coord_y_LE_points =  LE_points(:,2);
coord_z_LE_points =  LE_points(:,3);

numSparPosition = length(sparsRibs_geo.spars.positions.uIDs);
spars_eta = sparsRibs_geo.spars.positions.eta;
spars_xsi = sparsRibs_geo.spars.positions.xsi;

X_spar_LE = zeros(numSparPosition,1);
Y_spar_LE = zeros(numSparPosition,1);
Z_spar_LE = zeros(numSparPosition,1);


for k = 1:numSparPosition
    idx_smaller_than_sparsK = find(compseg_etas < spars_eta(k));   
    
    if isempty(idx_smaller_than_sparsK)
        t = 1;
    else
        t = idx_smaller_than_sparsK(end);
    end
    
    if t == length(compseg_etas);
        delta = 0;
        alpha = 0;
        X_spar_LE(k,1) = coord_x_LE_points(t,1);
        
    else
        delta = (spars_eta(k) - compseg_etas(t))*compseg_length;
        alpha = atan( abs( LE_points(t+1,3) - LE_points(t,3) ) / abs( LE_points(t+1,2) - LE_points(t,2) ) );
        X_spar_LE(k,1) = abs(coord_x_LE_points(t+1,1)-coord_x_LE_points(t,1))*abs(spars_eta(k)-compseg_etas(t))/abs(compseg_etas(t+1) - compseg_etas(t)) + coord_x_LE_points(t,1);
    end
    
    Y_spar_LE(k,1) = LE_points(t,2) + delta*cos(alpha) * sign( LE_points(t+1,2)- LE_points(t,2));
    Z_spar_LE(k,1) = LE_points(t,3) + delta*sin(alpha) * sign( LE_points(t+1,3)- LE_points(t,3));
    
end

% Calculates the x y and z coordinates of the trailing edge of each spar position

X_spar_TE = zeros(numSparPosition,1);
Y_spar_TE = zeros(numSparPosition,1);
Z_spar_TE = zeros(numSparPosition,1);

for k = 1:numSparPosition
    
    idx_smaller_than_sparsTE = find(compseg_etas < spars_eta(k));
    
    if isempty(idx_smaller_than_sparsTE)
        t = 1;
    else
        t = idx_smaller_than_sparsTE(end);
    end
    
    if t == length(compseg_etas)
        X_spar_TE(k,1) = coord_x_TE_points(t,1);
        delta = 0;
        alpha = 0;
        
    else
        
        delta = ( spars_eta(k)- compseg_etas(t))*compseg_length;
        alpha = atan( abs(coord_z_TE_points(t+1,1)-coord_z_TE_points(t,1))/abs(coord_y_TE_points(t+1,1)-coord_y_TE_points(t,1)));
        X_spar_TE(k,1) = (abs(TE_points(t+1,1)-TE_points(t,1))*abs(spars_eta(k)-compseg_etas(t)))/abs(compseg_etas(t+1) - compseg_etas(t)) + TE_points(t,1);
        
    end
    
    Y_spar_TE(k,1) = coord_y_TE_points(t,1) + delta*cos(alpha) * sign( TE_points(t+1,2)- TE_points(t,2));
    Z_spar_TE(k,1) = coord_z_TE_points(t,1) + delta*sin(alpha) * sign( TE_points(t+1,3)- TE_points(t,3));
end

delta_x = zeros(numSparPosition,1);
delta_y = zeros(numSparPosition,1);
delta_z = zeros(numSparPosition,1);

xsi_real_tot = zeros(numSparPosition,1);
xsi_spars_real = zeros(numSparPosition,1);

X_spar = zeros(numSparPosition,1);
Y_spar = zeros(numSparPosition,1);
Z_spar = zeros(numSparPosition,1);

for k = 1:numSparPosition
    
    delta_x(k,1) = X_spar_TE(k,1)- X_spar_LE(k,1);
    delta_y(k,1) = Y_spar_TE(k,1)- Y_spar_LE(k,1);
    delta_z(k,1) = Z_spar_TE(k,1)- Z_spar_LE(k,1);
    
    xsi_real_tot(k,1) = sqrt( delta_x(k,1)^2 + delta_y(k,1)^2 + delta_z(k,1)^2 );
    xsi_spars_real(k,1) = spars_xsi(k)* xsi_real_tot(k,1);
    
    X_spar(k,1) = X_spar_LE(k,1)+ xsi_spars_real(k,1)*delta_x(k,1)/xsi_real_tot(k,1);
    Y_spar(k,1) = Y_spar_LE(k,1)+ xsi_spars_real(k,1)*delta_y(k,1)/xsi_real_tot(k,1);
    Z_spar(k,1) = Z_spar_LE(k,1)+ xsi_spars_real(k,1)*delta_z(k,1)/xsi_real_tot(k,1);
    
end

% figure()
% plot3(X_spar_LE, Y_spar_LE, Z_spar_LE, 'b+');
% axis equal
% hold on
% plot3(X_spar_TE, Y_spar_TE, Z_spar_TE, 'ro');
% hold on
% plot3(X_spar, Y_spar, Z_spar, 'kv')


%% ----- Calculate Spar profiles and sup and inf -------%
scale_coeff = zeros(numSparPosition,1);
x_rel = zeros(numSparPosition,1);
y_rel = zeros(numSparPosition,1);
z_rel = zeros(numSparPosition,1);
spars_profile = cell(numSparPosition,1);

x = zeros(numSparPosition,1);
y = zeros(numSparPosition,1);
z = zeros(numSparPosition,1);

if Y_spar(:,1)<0
    id = 'VerticalWing';
else
    id = 'HorizontalWing';
end

for k = 1:numSparPosition
    
    idx_smaller_than_sparsTE = find(compseg_etas < spars_eta(k));
    if isempty(idx_smaller_than_sparsTE )
        t = 1;
    else
        t = idx_smaller_than_sparsTE(end);
    end
    % Calculates the scale coefficient to apply in order to get
    % the real size of the copied profile
    scale_coeff(k,1) = ( X_spar_TE(k,1) -  X_spar_LE(k,1))/(coord_x_TE_points(t,1) - coord_x_LE_points(t,1));
    
    x_rel(k,1) = X_spar_LE(k,1)- coord_x_LE_points(t,1);
    y_rel(k,1) = Y_spar_LE(k,1)- coord_y_LE_points(t,1);
    z_rel(k,1) = Z_spar_LE(k,1)- coord_z_LE_points(t,1);
    
    spars_profile{k}(:,1) = wingSectionDef.airfoil{t,1}(:,1).*scale_coeff(k,1);
    
    switch id
        case 'VerticalWing'
            spars_profile{k}(:,2) = wingSectionDef.airfoil{t,1}(:,2).*scale_coeff(k,1);
            
        case  'HorizontalWing'
            spars_profile{k}(:,3) = wingSectionDef.airfoil{t,1}(:,3).*scale_coeff(k,1);
            
    end
    
    %Repositions the copied profile
    [new_LE_x, new_LE_x_indice] = min(spars_profile{k}(:,1));
    x(k,1) = abs( new_LE_x - coord_x_LE_points(t,1));                            % gap between the original profile and the copied profile
    
    if new_LE_x <= coord_x_LE_points(t,1)                                        % Reset the copied profile at the same LE x coordinate than the original
        spars_profile{k}(:,1) = spars_profile{k}(:,1)+ x(k,1);
    else
        spars_profile{k}(:,1) = spars_profile{k}(:,1)- x(k,1);
    end
    
    switch id
        case 'VerticalWing'
            % Reset the copied profile at the same LE z coordinate than the original
            y(k,1) = abs(spars_profile{k}(new_LE_x_indice,2)- coord_y_LE_points(t,1));
            if spars_profile{k}(new_LE_x_indice,2) <= coord_y_LE_points(t,1)                
                spars_profile{k}(:,2) = spars_profile{k}(:,2)+ y(k,1);
            else
                spars_profile{k}(:,2) = spars_profile{k}(:,2)- y(k,1);
            end
            
            % Generates and places the spar profiles copied
            spars_profile{k}(:,1) = spars_profile{k}(:,1)+ x_rel(k,1);
            spars_profile{k}(:,3) = wingSectionDef.airfoil{t,1}(:,3)+ z_rel(k,1);
            spars_profile{k}(:,2) = spars_profile{k}(:,2)+ y_rel(k,1);
            
        case  'HorizontalWing'
            % Reset the copied profile at the same LE z coordinate than the original
            z(k,1) = abs(spars_profile{k}(new_LE_x_indice,3)- coord_z_LE_points(t,1));           
            if spars_profile{k}(new_LE_x_indice,3) <= coord_z_LE_points(t,1)               
                spars_profile{k}(:,3) = spars_profile{k}(:,3)+ z(k,1);
            else
                spars_profile{k}(:,3) = spars_profile{k}(:,3)- z(k,1);
            end
            
            % Generates and places the spar profiles copied
            spars_profile{k}(:,1) = spars_profile{k}(:,1)+ x_rel(k,1);
            spars_profile{k}(:,2) = wingSectionDef.airfoil{t,1}(:,2)+ y_rel(k,1);
            spars_profile{k}(:,3) = spars_profile{k}(:,3)+ z_rel(k,1);
    end
    
    figure(100)
    plot3(spars_profile{k}(:,1), spars_profile{k}(:,2), spars_profile{k}(:,3), 'b+')
    axis equal
    hold on    
end


%------------- Profile_up & Profile_down ---------%
spars_profile_up = cell(numSparPosition,1);
spars_profile_low = cell(numSparPosition,1);
for k = 1:numSparPosition
    switch id
        case 'VerticalWing'
            idx_up = spars_profile{k}(:,2)  >= 0   ;         
        case 'HorizontalWing'
            idx_up = spars_profile{k}(:,3) >= Z_spar(k,1);                   % maybe this way of differenting up and low profile is not correct.   
    end                                                                      % should be that points above the chord line belongs to upper profile
    
    spars_profile_up{k} = spars_profile{k}(idx_up, :);
    spars_profile_low{k} = spars_profile{k}(~idx_up, :);
  
%     figure(100)
%     plot3(spars_profile_up{k}(:,1), spars_profile_up{k}(:,2), spars_profile_up{k}(:,3), 'ro')
%     hold on
%     plot3(spars_profile_low{k}(:,1), spars_profile_low{k}(:,2), spars_profile_low{k}(:,3), 'k*')
%     hold on
    
end

%% -- Calculate X,Y,Z_spar_up & X,Y,Z_spar_low, Spar struct ----

X_spar_up = zeros(numSparPosition,1); Y_spar_up = zeros(numSparPosition,1); Z_spar_up = zeros(numSparPosition,1);
X_spar_low = zeros(numSparPosition,1); Y_spar_low = zeros(numSparPosition,1); Z_spar_low = zeros(numSparPosition,1);

for k = 1:numSparPosition       
    [X_spar_up(k), Y_spar_up(k), Z_spar_up(k)] = dist_profile_sparPoint(id, spars_profile_up{k}, X_spar(k), Y_spar(k), Z_spar(k));    
    [X_spar_low(k), Y_spar_low(k), Z_spar_low(k)] = dist_profile_sparPoint(id, spars_profile_low{k}, X_spar(k), Y_spar(k), Z_spar(k));     
end


%% ------------- Build Spar Structure ---------------%
numSparSegment = length(sparsRibs_geo.spars.segments.uIDs);
Spars_Segment = cell(numSparSegment,1);

for k = 1:numSparSegment
   
    %---------------- number of points for each spar ---------------%
    Spars_Segment{k}.uIDs = sparsRibs_geo.spars.segments.uIDs;
    Spar_points_number = length(sparsRibs_geo.spars.segments.positions{1,k});
    Spars_Segment{k}.middle = zeros(Spar_points_number,3);
    Spars_Segment{k}.inf = zeros(Spar_points_number,3);
    Spars_Segment{k}.sup = zeros(Spar_points_number,3);
    
    for t=1:Spar_points_number
                
        for u = 1:numSparPosition
            if strcmp(sparsRibs_geo.spars.positions.uIDs{1,u}, sparsRibs_geo.spars.segments.positions{1,k}{1,t}) == 1
                Spars_Segment{k}.uID = sparsRibs_geo.spars.segments.uIDs{k};
                Spars_Segment{k}.middle(t,:) = [X_spar(u), Y_spar(u), Z_spar(u)]; 
                Spars_Segment{k}.inf(t,:) = [X_spar_low(u), Y_spar_low(u), Z_spar_low(u)];  
                Spars_Segment{k}.sup(t,:) = [X_spar_up(u), Y_spar_up(u), Z_spar_up(u)];
%                 Spars_Segment{k}.eta_total_real = sqrt((Z_spar(numSparPosition,1)-Z_spar(1,1))^2 + (Y_spar(numSparPosition,1)- Y_spar(1,1))^2 );   
                Spars_Segment{k}.eta(t,1) = spars_eta(u);
                Spars_Segment{k}.xsi(t,1) = spars_xsi(u);
                Spars_Segment{k}.cross_profile{t,1} = spars_profile{u};
                Spars_Segment{k}.cross_profile_inf{t,1} = spars_profile_low{u};
                Spars_Segment{k}.cross_profile_sup{t,1} = spars_profile_up{u};               
            end            
        end
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

function [rib_cell,X_front_rib, Y_front_rib, Z_front_rib] = calc_ribProfiles(sparsRibs_geo, wingSectionDef, Spars_Segment, Y_spar, compseg_etas, compseg_length, TE_points, LE_points)
% Creates for each spar a structure containing points coordinates of this spar
coord_x_TE_points = TE_points(:,1);
coord_y_TE_points = TE_points(:,2);
coord_z_TE_points = TE_points(:,3);

coord_y_LE_points =  LE_points(:,2);
coord_z_LE_points =  LE_points(:,3);

if Y_spar(:,1)<0       % maybe it's not accurate to judge Vertical Wing or Horizontal Wing from Y_spar(:,1)??
    id = 'VerticalWing';
else
    id = 'HorizontalWing';
end

% Creates for each ribs group a structure containing those points
ribs_etaStart = sparsRibs_geo.ribsDefinitions.etaStart;
ribs_etaEnd = sparsRibs_geo.ribsDefinitions.etaEnd;
ribs_numOfRibs = sparsRibs_geo.ribsDefinitions.numberOfRibs;
ribs_rotz = sparsRibs_geo.ribsDefinitions.rotz;
ribs_rotx = sparsRibs_geo.ribsDefinitions.rotx;

ribsDefinition_number = length(sparsRibs_geo.ribsDefinitions.uIDs);

rib_cell = cell(ribsDefinition_number,1);

for k = 1:ribsDefinition_number
    rib_cell{k}.rib_name = sparsRibs_geo.ribsDefinitions.uIDs{1,k};
    rib_cell{k}.rib_start = sparsRibs_geo.ribsDefinitions.ribStart{1,k};
    rib_cell{k}.rib_end = sparsRibs_geo.ribsDefinitions.ribEnd{1,k};
    rib_cell{k}.rib_reference  = sparsRibs_geo.ribsDefinitions.ribReference{1,k};
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
    [X_rib_start(k), Y_rib_start(k), Z_rib_start(k)] = ribs_startPoint(Spars_Segment, rib_cell{k}, compseg_etas, compseg_length, ribs_etaStart(k), id, LE_points);
    [X_rib_end(k), Y_rib_end(k), Z_rib_end(k)] = ribs_endPoint(Spars_Segment, rib_cell{k}, compseg_etas, compseg_length, ribs_etaEnd(k), id, TE_points);  
    
    [rib_cell{k}.X_front_rib, rib_cell{k}.Y_front_rib, rib_cell{k}.Z_front_rib] = get_XYZ_front_rib(rib_cell{k}, Spars_Segment, ribs_numOfRibs(k), ...
                   ribs_etaStart(k), ribs_etaEnd(k), X_rib_start(k), Y_rib_start(k), Z_rib_start(k), X_rib_end(k), Y_rib_end(k), Z_rib_end(k));
    rib_cell{k}.ribs_number_cell = ribs_numOfRibs(k); 
    
    eta_ribs = zeros(ribs_numOfRibs(k)-1, 1);
    for u = 1:ribs_numOfRibs(k)-1
        dist_ribj(u) = sqrt((rib_cell{k}.Y_front_rib(u+1) - rib_cell{k}.Y_front_rib(u))^2 + (rib_cell{k}.Z_front_rib(u+1) - rib_cell{k}.Z_front_rib(u))^2);
        eta_ribs(u) = sum(dist_ribj)/compseg_length;
    end
    
    rib_cell{k}.eta_ribs = [0; eta_ribs];
end    
    

% Calculates the x y and z coordinates of the leading edge of each rib position
for j = 1:ribsDefinition_number
    [rib_cell{j}.X_rib_TE, rib_cell{j}.Y_rib_TE, rib_cell{j}.Z_rib_TE] = ribs_XYZ_LE_TE(rib_cell{j}, compseg_etas, compseg_length, TE_points);
    [rib_cell{j}.X_rib_LE, rib_cell{j}.Y_rib_LE, rib_cell{j}.Z_rib_LE] = ribs_XYZ_LE_TE(rib_cell{j}, compseg_etas, compseg_length, LE_points);
end  

for j = 1:ribsDefinition_number
    [rib_cell{j}.ribs_profile] = get_ribsProfiles(wingSectionDef, rib_cell{j}, compseg_etas, TE_points, LE_points, id, ribs_rotx(j), ribs_rotz(j));
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
    [rib_cell{j}.X_rear_rib, rib_cell{j}.Y_rear_rib, rib_cell{j}.Z_rear_rib] = get_XYZ_rear_rib(sparsRibs_geo, rib_cell{j}, id, compseg_etas, TE_points, Spars_Segment);
end

for j = 1:ribsDefinition_number
    [rib_cell{j}] = get_ribs_upper_lower_Profiles(id, rib_cell{j}); 
end

end

function  Wings = update_wing_struct(sparsRibs_geo, Spar, rib_cell, Y_front_rib, Y_spar)
%% Addon Wings structure, for further use of fuel tank drawing!

Spars_number = length(sparsRibs_geo.spars.segments.uIDs);
ribsDefinition_number = length(sparsRibs_geo.ribsDefinitions.uIDs);

for j = 1:ribsDefinition_number
    for k = 1:rib_cell{j}.ribs_number_cell       
        idx_inbetwn = rib_cell{j}.ribs_profile{k}(:,1) >= rib_cell{j}.X_front_rib(k) & rib_cell{j}.ribs_profile{k}(:,1) <= rib_cell{j}.X_rear_rib(k);         
        rib_cell{j}.ribs_profile_final{k} = rib_cell{j}.ribs_profile{k}(idx_inbetwn, :);   
    end
end

% Separates the rib final profile points which are superiors from those which are inferiors to the rib middle point

if Y_front_rib(:,1)<0                % vertical wing
    for j=1:ribsDefinition_number
        for k = 1:rib_cell{j}.ribs_number_cell
 
            idx_sup = rib_cell{j}.ribs_profile_final{k}(:,2)  >= 0;            
            rib_cell{j}.ribs_profile_final_sup{k} = rib_cell{j}.ribs_profile_final{k}(idx_sup, :); 
            rib_cell{j}.ribs_profile_final_inf{k} = rib_cell{j}.ribs_profile_final{k}(~idx_sup, :); 

        end
    end
    
else                                % horizontal wing
    
    for j=1:ribsDefinition_number
        for k = 1:rib_cell{j}.ribs_number_cell
            idx_sup = rib_cell{j}.ribs_profile_final{k}(:,3) >= rib_cell{j}.Z_front_rib(k);
            rib_cell{j}.ribs_profile_final_sup{k} = rib_cell{j}.ribs_profile_final{k}(idx_sup, :);
            rib_cell{j}.ribs_profile_final_inf{k} = rib_cell{j}.ribs_profile_final{k}(~idx_sup, :);            
        end
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
    
%     
%     for u=1:size(Spar{j}.cross_profile,2)
%         Wings.Spars{j}.Spars_cross_profile{u}=Spar{j}.cross_profile{u};
%         Wings.Spars{j}.Spars_cross_profile_sup{u}=Spar{j}.cross_profile_sup{u};
%         Wings.Spars{j}.Spars_cross_profile_inf{u}=Spar{j}.cross_profile_inf{u};
%     end
    
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
Wings.Y_spar = Y_spar;     %useful for the function build_fuel_tank, in order to know if it is a vertical or horizontal wing

end
