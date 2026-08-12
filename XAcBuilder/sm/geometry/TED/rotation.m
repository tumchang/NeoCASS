function R = rotation (alpha, axis)

R = zeros (3,3);

if axis == 1 %rotation around x-axis
    
    R(1,:) = [1, 0, 0];
    R(2,:) = [0, cos(alpha), -sin(alpha)];
    R(3,:) = [0, sin(alpha), cos(alpha)];
    
end

if axis == 2 %rotation around y-axis
    
    R(1,:) = [cos(alpha), 0, sin(alpha)];
    R(2,:) = [0, 1, 0];
    R(3,:) = [-sin(alpha), 0, cos(alpha)];
    
end

if axis == 3 %rotation around z-axis
    
    R(1,:) = [cos(alpha), -sin(alpha), 0];
    R(2,:) = [sin(alpha), cos(alpha), 0];
    R(3,:) = [0, 0, 1];
    
end


end