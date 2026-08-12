function deflected = path_function2(iTED_geo, TEDfoil_global, num_element_iTED, hinge_in, hinge_out)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generates coordinates for trailing edge devices with deflection (steps) %
% of a wing component                                                     %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Pierre Saquet and Lisa Reichert                       %
% LastModified:     2012-01-02                                            %
% LastModifiedBy:   PS                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%                                                                         %
%  - check the coordinates system (relative or absolut) to fit well with  %
%    the main wing                                                        %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% num_element_iTED    

% cs = TED.Componentsegment;

%get number of airfoils for this ted
g = num_element_iTED;  

%load values for interpolation, find nose point for each TED relevant
%element, nose points' y coordinates

pos = zeros(1,g);
for t = 1 : g
    [val, idx] = min(TEDfoil_global{1,t}(:,1));
    pos(t) = TEDfoil_global{1,t}(idx,2);
end

%global x = hinge coordinate system x-axis
x= [1; 0; 0];

%calculate direction vector for hinge line, y-axis in hinge coordinate
%system
y = hinge_out - hinge_in;
y = y / norm(y);

%calculate z-Vector for hinge coordinate system 
z = cross(x,y);

%get number of steps
s = length(iTED_geo.stepRelDeflection);

%calculate deflected airfoils for every step
for i = 1 : s
    %load values for steps and interpolate
    alpha = iTED_geo.stepHingeLineRotation(i) * pi/180;
    
    trans_x = zeros(1,g);
    trans_y = zeros(1,g);
    trans_z = zeros(1,g);
    
    trans_x(1) = iTED_geo.stepInnerHingeTranslationX(i); 
   
    try 
        trans_x(g) = iTED_geo.stepOuterHingeTranslationX(i); 
    catch
        trans_x(g) = trans_x(1);
    end
    
    trans_y(1) = iTED_geo.stepInnerHingeTranslationY(i);    
    try trans_y(g) =  iTED_geo.stepOuterHingeTranslationY(i); 
    catch
        trans_y(g) = trans_y(1);
    end
    
    trans_z(1) = iTED_geo.stepInnerHingeTranslationZ(i);    
    try trans_z(g) = iTED_geo.stepOuterHingeTranslationZ(i); 
    catch
        trans_z(g) = trans_z(1);
    end
        
    for k = 2 : g-1 %interpolate inbetweenvalues for translation
        trans_x(k) = interpol(pos(1), pos(g), pos(k), trans_x(1), trans_x(g));
        trans_y(k) = interpol(pos(1), pos(g), pos(k), trans_y(1), trans_y(g));
        trans_z(k) = interpol(pos(1), pos(g), pos(k), trans_z(1), trans_z(g));
    end
    
    
    for l = 1 : g  %translate each aifoil for this ted
        %x-translation
        x_trans = trans_x(l)*x;
        D(1,:) = TEDfoil_global{1,l}(:,1) + x_trans(1);
        D(2,:) = TEDfoil_global{1,l}(:,2) + x_trans(2);
        D(3,:) = TEDfoil_global{1,l}(:,3) + x_trans(3);
                
        %y-translation
        y_trans = trans_y(l)*y;
        D(1,:) = D(1,:) + y_trans(1);
        D(2,:) = D(2,:) + y_trans(2);
        D(3,:) = D(3,:) + y_trans(3);
        
        %z-translation
        z_trans = trans_z(l)*z;
        D(1,:) = D(1,:) + z_trans(1);
        D(2,:) = D(2,:) + z_trans(2);
        D(3,:) = D(3,:) + z_trans(3);
        
        if l==1
            hinge_in = hinge_in + x_trans + y_trans + z_trans;
        end
        
        if l==g
            hinge_out = hinge_out + x_trans + y_trans + z_trans;
        end
        
        eval(['D_' num2str(l) '=D;']);
        
    end
 
    %calculate direction vector for deflected hinge line
    y = hinge_out - hinge_in;
    y = y / norm(y);

    %calculate new z-Vector 
    z = cross(x,y);
    colspe = {'r+','y^','go'};
    for l = 1 : g %rotate each airfoil around deflected hinge line
        
        eval(['D=D_' num2str(l) ';']);
        
        D = rotate (hinge_in, y, D, alpha);
        
        %safe result to struct
        deflected.steps{1,i}.airfoils{1,l}=D';
  
%        % figure(100)
%         plot3(D(1,:),D(2,:),D(3,:),colspe{i})
%         hold on
%         axis equal
        
    end
    
    
end

end