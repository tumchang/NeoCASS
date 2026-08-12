function C = get_airfoil (A, xsiLE, relChordUpperSkin, relChordLowerSkin, relZLE)
%creates airfoil of the control surface from the given wing airfoil

%get number of points in basic airfoil
g = size (A);
front_idx=fix(g(1)/2);                  % round toward zero

chord = A(1,1)-A(front_idx,1);          % basic airfoil, chord ~ 1

xLE = chord*xsiLE + A(front_idx,1);

% calculate lower and upper cutoff-value from the given parameters
% relChordUpperSkin relative to the TED; Chord - xLE = TED chord
upper_border = xLE + (1 - relChordUpperSkin)*(chord - xLE);
lower_border = xLE + (1 - relChordLowerSkin)*(chord - xLE);


for i = 1 : 1 : g(1)  
    
    % set points on the upper side; if the point on upper surface, rear
    % than upper cut point, copy it; 
    if A (i, 1) > upper_border && A (i, 3) >= 0
       
        B (i, 1) = A (i, 1);
        B (i, 2) = 0;
        B (i, 3) = A (i, 3);
        
    % set points on the lower side; if the point on lower surface, rear
    % than the lower cut point, copy it; 
    elseif A (i, 1) > lower_border && A (i, 3)<= 0
        
        B (i, 1) = A (i, 1);
        B (i, 2) = 0;
        B (i, 3) = A (i, 3);
        
    % set front point    
    elseif A (i, 1) == min (A(:,1)) %&& A (i, 3) == 0
        
       B (i, 1) = xLE;
       B (i, 2) = 0;
       
       D = abs (A - (xLE ));
        
       [val, idx] = min (D);
        
       f = idx (1);
       
       e =  ( abs(A (f, 3)) + abs ( A( g(1)-(f-1), 3)) )*relZLE;
  %      e =   abs( A (f, 3) -  A( g(1)-(f-1), 3))*relZLE; 
   
       if A(f, 3) < 0
           B (i, 3) = A (f, 3) + e;
           
       else 
           
           B (i, 3) = A (g(1)-(f-1), 3) + e;
       end 
        
       
    % set all inbetween points to NAN    
    else 
    
        B (i,1) = NaN;
        B (i, 2) = 0;
        B (i, 3) = NaN;
    end
    
    
    
    
end


% % figure()
% % plot(A(:,1),A(:,3),'b-');
% % axis equal
% % hold on
% % plot(B(:,1),B(:,3),'rd')


%creat ellipse for the rest

%find idx of important points
[val, idx] = max (B);
i_1 = idx (3); %upper point
    
[val, idx] = min (B);
i_2 = idx (3); %lower point
i_3 = idx (1); %front point
    
%calculate necessary parameters for the ellipse    
delta_x_1 = (B(i_1, 1)-B(i_3, 1)); 
delta_y_1 = (B(i_1, 3)-B(i_3, 3)); 
    
delta_x_2 = (B(i_2, 1)-B(i_3, 1)); 
delta_y_2 = (B(i_3, 3)-B(i_2, 3)); 

%calculate how many points are necessary for each ellipse
TF = isnan(B);
[val idx]= max (TF);
    
p = i_3-idx(1); %number of points for upper ellipse
q = i_2-i_3-1;  %number of points for lower ellipse    

%set test alpha
alpha_1 = 0.4*pi;
alpha_2 = 1.5*pi;

    
a_1 = delta_x_1 / (1 + cos(alpha_1));   %major axis of the upper ellipse
b_1 = delta_y_1 / sin(alpha_1);         %minor axis of the upper ellipse
    
a_2 = delta_x_2 / (1 + cos(alpha_2));   %major axis of the lower ellipse
b_2 = -delta_y_2 / sin(alpha_2);        %minor aixs of the lower ellipse
    

  
phi_1 = [ alpha_1 : ((pi-alpha_1)/(p+1)) : pi];
phi_2 = [pi : ((alpha_2-pi)/(q+1)) : alpha_2];
    
X_1 = a_1 * cos (phi_1); %calculate x-values for upper ellipse
Y_1 = b_1 * sin (phi_1); %calculate y-values for upper ellipse
X_2 = a_2 * cos (phi_2); %calculate x-values for lower ellipse
Y_2 = b_2 * sin (phi_2); %calculate y-values for lower ellipse


%transform from origin to airfoil
X_1 = X_1 + a_1 + B(i_3, 1);
Y_1 = Y_1 + B(i_3, 3);
X_2 = X_2 + a_2 + B(i_3, 1);
Y_2 = Y_2 + B(i_3, 3);
    

    
   
%copy points into airfoil matrix    
    for j=2 : 1 : p+1
     
       B(j+i_1-1, 1) = X_1(j);
       B(j+i_1-1, 3) = Y_1(j);
    
    end
    
    
    for j=2 : 1 : q+1
        
        B(j+i_3-1, 1) = X_2(j);
        B(j+i_3-1, 3) = Y_2(j);
    end
    
% figure()
% plot(A(:,1),A(:,3),'b-');
% axis equal
% hold on
% plot(B(:,1),B(:,3),'rd')
   
   
C = B;
end


