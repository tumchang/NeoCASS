function control_absolut = absolut_transformation (A, wing, pos_vector, SecNum)
%transforms basic control surface airfoil into the global coordinates

%load values for transformation from wing into global coordinate system
trans_wg = zeros(3,1);
trans_wg(1) = str2double(wing.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
trans_wg(2) = str2double(wing.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
trans_wg(3) = str2double(wing.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);

scal_wg = zeros(3,1);
scal_wg(1) = str2double(wing.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT);
scal_wg(2) = str2double(wing.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT);
scal_wg(3) = str2double(wing.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT);

alpha_wg = zeros(3,1);
alpha_wg(1) = str2double(wing.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT) * (pi/180);
alpha_wg(2) = str2double(wing.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT) * (pi/180);
alpha_wg(3) = str2double(wing.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT) * (pi/180);

%load values for Transformation element into the section coordinate system
trans_es = zeros (3, 1);
trans_es(1) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
trans_es(2) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
trans_es(3) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);

scal_es = zeros(3, 1);
scal_es(1) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT);
scal_es(2) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT);
scal_es(3) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT);

alpha_es = zeros (3, 1);
alpha_es(1) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)*(pi/180);
alpha_es(2) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)*(pi/180);
alpha_es(3) = str2double(wing.sections{1,1}.section{1,SecNum}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)*(pi/180);
    
%load values for Transformation from section into the wing coordinate system
trans_sw = zeros (3, 1);
trans_sw(1) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.translation{1,1}.x{1,1}.CONTENT);
trans_sw(2) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.translation{1,1}.y{1,1}.CONTENT);
trans_sw(3) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.translation{1,1}.z{1,1}.CONTENT);

scal_sw = zeros (3, 1);
scal_sw(1) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.scaling{1,1}.x{1,1}.CONTENT);
scal_sw(2) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.scaling{1,1}.y{1,1}.CONTENT);
scal_sw(3) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.scaling{1,1}.z{1,1}.CONTENT);

alpha_sw = zeros (3, 1);
alpha_sw(1) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT)*(pi/180);
alpha_sw(2) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.rotation{1,1}.y{1,1}.CONTENT)*(pi/180);
alpha_sw(3) = str2double(wing.sections{1,1}.section{1,SecNum}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT)*(pi/180);



%transpose airfoil matrix
A=A';

%Transformation into the section coordinate system

rot_es = rotation(alpha_es(1),1) * rotation(-alpha_es(2), 2) * rotation (alpha_es(3), 3);
rot_es = rot_es';


A = rot_es * A;


A(1,:) = A(1,:) + trans_es(1);
A(2,:) = A(2,:) + trans_es(2);
A(3,:) = A(3,:) + trans_es(3);

A(1,:) = A(1,:) * scal_es(1);
A(2,:) = A(2,:) * scal_es(2);
A(3,:) = A(3,:) * scal_es(3);


%Transformation into the wing coordinate system

rot_sw = rotation(alpha_sw(1),1) * rotation(-alpha_sw(2), 2) * rotation (alpha_sw(3), 3);
rot_sw = rot_sw';

A = rot_sw * A;

A(1,:) = A(1,:) + trans_sw(1);
A(2,:) = A(2,:) + trans_sw(2);
A(3,:) = A(3,:) + trans_sw(3);

A(1,:) = A(1,:) * scal_sw(1);
A(2,:) = A(2,:) * scal_sw(2);
A(3,:) = A(3,:) * scal_sw(3);

A(1,:) = A(1,:) + pos_vector(1);
A(2,:) = A(2,:) + pos_vector(2);
A(3,:) = A(3,:) + pos_vector(3);



%Transformation into the global coordinate system

rot_wg = rotation(alpha_wg(1),1) * rotation(-alpha_wg(2), 2) * rotation (alpha_wg(3), 3);
rot_wg = rot_wg';

A = rot_wg * A;

A(1,:) = A(1,:) + trans_wg(1);
A(2,:) = A(2,:) + trans_wg(2);
A(3,:) = A(3,:) + trans_wg(3);


A(1,:) = A(1,:) * scal_wg(1);
A(2,:) = A(2,:) * scal_wg(2);
A(3,:) = A(3,:) * scal_wg(3);

control_absolut=A;
end 
