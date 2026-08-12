function stick(CPACSgeo)
global handles
% load('../Projects/CPACSgeo.mat')
%-----------------Wing Model------------------
num_Wings = length(CPACSgeo.wings.component);

for numWing = 1: num_Wings
  clear wing_mid
    wing_points = CPACSgeo.wings.component{numWing}.sectionDef.point; 
    wing_airfoils = CPACSgeo.wings.component{numWing}.sectionDef.airfoil;
    wing_points_LE = zeros(length(wing_points), 3);
    wing_points_TE = zeros(length(wing_points), 3);
    wing_points_middle = zeros(length(wing_points), 3);
    
    axes(handles.axes3d_technology)
    for j = 1: length(wing_points)
        wing_points_LE(j,:) = wing_points{j}';
        
        ifoil_xyz = wing_airfoils{j};
        [Val_x,Idx_x] = max(ifoil_xyz(:,1));
        wing_points_TE(j,:) = ifoil_xyz(Idx_x,:);
 
        wing_chord = zeros(3,3);
        
        wing_chord(1,:) = wing_points_LE(j,:);
        wing_chord(3,:) = wing_points_TE(j,:);
        wing_chord(2,:) = mean(wing_chord([1,3],:));
        
        wing_points_middle(j,:) =  wing_chord(2,:);
        
         
         plot3(wing_chord(:,1), wing_chord(:,2), wing_chord(:,3), 'r-', 'LineWidth',3);
         axis equal
         axis off
         hold on
         plot3(wing_chord(:,1), -wing_chord(:,2), wing_chord(:,3), 'r-', 'LineWidth',3);
         hold on
    end

    axes(handles.axes3d_technology)
    plot3(wing_points_LE(:,1), wing_points_LE(:,2), wing_points_LE(:,3), 'r-', 'LineWidth',3);              
    hold on
    plot3(wing_points_TE(:,1), wing_points_TE(:,2), wing_points_TE(:,3), 'r-', 'LineWidth',3);    
    hold on
    plot3(wing_points_LE(:,1), -wing_points_LE(:,2), wing_points_LE(:,3), 'r-', 'LineWidth',3);              
    hold on
    plot3(wing_points_TE(:,1), -wing_points_TE(:,2), wing_points_TE(:,3), 'r-', 'LineWidth',3);    
    hold on
    
    for j = 1: length(wing_points)-1
        x_added = linspace(wing_points_middle(j,1), wing_points_middle(j+1,1),5)';
        y_added = linspace(wing_points_middle(j,2), wing_points_middle(j+1,2),5)';
        z_added = linspace(wing_points_middle(j,3), wing_points_middle(j+1,3),5)';
        wing_mid{j,1}(:,1) = x_added;
        wing_mid{j,1}(:,2) = y_added;
        wing_mid{j,1}(:,3) = z_added;
    end
    wing_mid = cell2mat(wing_mid);
    
    plot3(wing_mid(:,1), wing_mid(:,2), wing_mid(:,3), 'b-s', 'LineWidth',3,...
          'MarkerEdgeColor','b', 'MarkerFaceColor','b', 'MarkerSize',3);
    hold on
    plot3(wing_mid(:,1), -wing_mid(:,2), wing_mid(:,3), 'b-s', 'LineWidth',3,...
        'MarkerEdgeColor','b', 'MarkerFaceColor','b', 'MarkerSize',3);    
    hold on
end

%% -----------------Fuselage Model----------------
fus_points = CPACSgeo.fuselages.component{1,1}.sectionDef.point; 
fus_points_new = zeros(length(fus_points), 3); 


for i = 1: length(fus_points)
    fus_points_new(i,:) = fus_points{i}';
end

hold on
plot3(fus_points_new(:,1), fus_points_new(:,2), fus_points_new(:,3),'r-s', 'LineWidth',3,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor','b',...
        'MarkerSize',3)
hold on
axis equal

end
