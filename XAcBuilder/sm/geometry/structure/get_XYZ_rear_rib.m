function  [X_rear_rib, Y_rear_rib, Z_rear_rib] = get_XYZ_rear_rib(sparsRibs_geo, rib_cellj, sum_eta, TE_points, Spars_Segment)

coord_x_TE_points = TE_points(:,1);
coord_y_TE_points = TE_points(:,2);
coord_z_TE_points = TE_points(:,3);

% Calculates the average value of the y position of each rib profile in order to know between wich spars
% this rib profile is placed and then to be able to know where it will end

    if strcmp(rib_cellj.rib_end,'trailingEdge') == 1  % if end with 'trailing edge'
        
        for k = 1:rib_cellj.ribs_number_cell                              
            rib_cellj.rear_rib{k} = [];           
            rib_cellj.moy_Y_rib(k,1) = abs(rib_cellj.rib_TE_point{k}(1,2)-rib_cellj.rib_LE_point{k}(1,2))/2 + rib_cellj.rib_TE_point{k}(1,2);
            
            s = length(sum_eta); 
            while  coord_y_TE_points(s,1) > rib_cellj.moy_Y_rib(k,1)
                s = s-1;
            end            
            % Creates the plane equation for each rib of each ribs_cell
            
            rib_profile_points_number = length(rib_cellj.ribs_profile{k});
            t1 = round(rand*rib_profile_points_number);
            while t1 == 0
                t1 = round(rand*rib_profile_points_number);
            end
            P1 = [rib_cellj.ribs_profile{k}(t1,1),rib_cellj.ribs_profile{k}(t1,2),rib_cellj.ribs_profile{k}(t1,3)];
            t2 = round(rand*rib_profile_points_number);
            while t2 == 0 || t2 == t1
                t2 = round(rand*rib_profile_points_number);
            end
            P2 = [rib_cellj.ribs_profile{k}(t2,1),rib_cellj.ribs_profile{k}(t2,2),rib_cellj.ribs_profile{k}(t2,3)];
            t3 = round(rand*rib_profile_points_number);
            while t3 == 0 || t3 == t1 || t3 == t2
                t3 = round(rand*rib_profile_points_number);
            end
            P3 = [rib_cellj.ribs_profile{k}(t3,1),rib_cellj.ribs_profile{k}(t3,2),rib_cellj.ribs_profile{k}(t3,3)];
            
            normal = cross(P1-P2, P1-P3);
            
            P4 = [coord_x_TE_points(s,1),coord_y_TE_points(s,1),coord_z_TE_points(s,1)];
            P5 = [coord_x_TE_points(s+1,1),coord_y_TE_points(s+1,1),coord_z_TE_points(s+1,1)];
            
            [I,check]=plane_line_intersect(normal,P1,P4,P5);
            
            rib_cellj.rear_rib{k,1} = I;
            
            X_rear_rib(k,1) = rib_cellj.rear_rib{k,1}(1,1);
            Y_rear_rib(k,1) = rib_cellj.rear_rib{k,1}(1,2);
            Z_rear_rib(k,1) = rib_cellj.rear_rib{k,1}(1,3);            
        end
        
    else
  
%         switch id
%             case 'VerticalWing'         % Error in the xml file : it should be VTP instead of HTP for vertical tail
%                 u = 2;
%             case 'HorizontalWing'
                num_segments = length(Spars_Segment);
                for i = 1: num_segments
                    spar_segmentsUID{i} = Spars_Segment{i}.uID;
                end
                try
                    u = find(strcmp(spar_segmentsUID, rib_cellj.rib_end));
                catch
                    disp('This rib ends at a spar segment whose uID is not listed in the available spar segments')
                end
%         end
              
        for k = 1:rib_cellj.ribs_number_cell
            
            Spar_points_number = length(Spars_Segment{u}.eta);
   
            % Calculates the average value of the y position of each rib profile in order to know between wich spars
            % this rib profile is placed and then to be able to know where it will end
           
            rib_cellj.rear_rib{k} = [];            
            rib_cellj.moy_Y_rib(k,1) = abs(rib_cellj.rib_TE_point{k}(1,2) - rib_cellj.rib_LE_point{k}(1,2))/2 + rib_cellj.rib_TE_point{k}(1,2);
           
            s = Spar_points_number;
            while  Spars_Segment{u}.middle(s,2) > rib_cellj.moy_Y_rib(k,1)
                s = s-1;
            end
            
            % Creates the plane equation for each rib of each ribs_cell
            
            rib_profile_points_number = size(rib_cellj.ribs_profile{k},1);   % number of points on each rib plane belonging to certain rib cell;
            t1 = round(rand*rib_profile_points_number);
            while t1 == 0
                t1 = round(rand*rib_profile_points_number);
            end
            P1 = [rib_cellj.ribs_profile{k}(t1,1),rib_cellj.ribs_profile{k}(t1,2),rib_cellj.ribs_profile{k}(t1,3)]; % selecting a random point of the kth rib plane, j cell
            t2 = round(rand*rib_profile_points_number);
            while t2 == 0 || t2 == t1
                t2 = round(rand*rib_profile_points_number);
            end
            P2 = [rib_cellj.ribs_profile{k}(t2,1),rib_cellj.ribs_profile{k}(t2,2),rib_cellj.ribs_profile{k}(t2,3)]; % selecting 2nd random point of the kth rib plane, j cell
            t3 = round(rand*rib_profile_points_number);
            while t3 == 0 || t3 == t1 || t3 == t2
                t3 = round(rand*rib_profile_points_number);
            end
            P3 = [rib_cellj.ribs_profile{k}(t3,1),rib_cellj.ribs_profile{k}(t3,2),rib_cellj.ribs_profile{k}(t3,3)]; % selecting 3rd random point of the kth rib plane, j cell
            
            normal = cross(P1-P2, P1-P3);
            
            %   save('err.mat','Spar','s','u')
            P4 = Spars_Segment{u}.middle(s,:);                                         %    P4 = [Spar{u}.middle(s,1),Spar{u}.middle(s,2),Spar{u}.middle(s,3)];
            
            try
                P5 = Spars_Segment{u}.middle(s+1,:);                                       %[Spar{u}.middle(s+1,1),Spar{u}.middle(s+1,2),Spar{u}.middle(s+1,3)];
            catch
                P5 =  Spars_Segment{u}.middle(s-1,:);
            end
            [I,check]= plane_line_intersect(normal,P1,P4,P5);
            
            rib_cellj.rear_rib{k,1} = I;
            
            X_rear_rib(k,1) = rib_cellj.rear_rib{k,1}(1,1);
            Y_rear_rib(k,1) = rib_cellj.rear_rib{k,1}(1,2);
            Z_rear_rib(k,1) = rib_cellj.rear_rib{k,1}(1,3);
            
        end
    end
end