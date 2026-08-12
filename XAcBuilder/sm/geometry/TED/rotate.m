function A = rotate (inner_hinge, axis, A, alpha)

g = size (A);


%transform into rotation coordinate system where the inner hinge point is
%the origin
%x-values
for i = 1 : g(2)
    A(1,i) = A(1,i) - inner_hinge(1);
    A(2,i) = A(2,i) - inner_hinge(2);
    A(3,i) = A(3,i) - inner_hinge(3);
end


%calculate orthonormalbasis from given axis (hinge line and global x-axis
r = axis / norm(axis);
e_x = [1; 0; 0];

s = cross (r, e_x);
s = s / norm (s);

t = cross (r, s);
t = t / norm(t);

%get transformation matrix for the new basis
T_1 = [r s t];
T_2 = T_1';

%set standard rotation matrix
R_stand = rotation(alpha, 1);

%rotation matrix for this case
R = T_1 * R_stand * T_2;


%transform airfoil
A = R*A;


%transform back into global coordinate system
for i = 1 : g(2)
    A(1,i) = A(1,i) + inner_hinge(1);
    A(2,i) = A(2,i) + inner_hinge(2);
    A(3,i) = A(3,i) + inner_hinge(3);
end


end