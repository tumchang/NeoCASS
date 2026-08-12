function [X_nac, Y_nac, Z_nac] = matrix_engine_cpacs(engine_structure, engine_transformation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generates coordinates for engine component                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Pierre Saquet and Theophile Hiebel                    %
% LastModified:     2012-01-02                                            %
% LastModifiedBy:   PS                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%reminder, engine_structure = structure.vehicles{1,1}.engines{1,1}.engine{1,counter(4)};

%%
%INPUTS

%Position null of the engine
%{
x_engine = CPACSgeo.engine.pos(1,1);
y_engine = CPACSgeo.engine.pos(1,2);
z_engine = CPACSgeo.engine.pos(1,3);
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Nacelle %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Get the useful informations to create sections of the nacelle
Nacelle = engine_structure.nacelle{1,1};

%Datas requisite to draw the nacelle %Those datas are missing for now

%Position rel of diametre max and value of diametre max

try
    x_maxDiameter = str2num(Nacelle.diameterMax{1,1}.x{1,1}.CONTENT);
    maxDiameter = str2num(Nacelle.diameterMax{1,1}.y{1,1}.CONTENT);   
catch
    x_maxDiameter = str2num(Nacelle.maxDiameter{1,1}.x{1,1}.CONTENT);
    maxDiameter = str2num(Nacelle.maxDiameter{1,1}.y{1,1}.CONTENT);
end

maxRadius = maxDiameter/2;

%Position of the end of the nozzleColdStream

x_nozzleColdStream = str2num(Nacelle.coldStream{1,1}.x{1,1}.CONTENT);
nozzleColdStream_innerRadius = str2num(Nacelle.coldStream{1,1}.innerRadius{1,1}.CONTENT);
nozzleColdStream_outerRadius = str2num(Nacelle.coldStream{1,1}.outerRadius{1,1}.CONTENT);

%Position of the end of the nozzleHotStream
x_nozzleHotStream = str2num(Nacelle.hotStream{1,1}.x{1,1}.CONTENT);
nozzleHotStream_innerRadius = str2num(Nacelle.hotStream{1,1}.innerRadius{1,1}.CONTENT);
nozzleHotStream_outerRadius = str2num(Nacelle.hotStream{1,1}.outerRadius{1,1}.CONTENT);

%Position of the inlet and diameter of the inlet there
x_inlet = str2num(Nacelle.inlet{1,1}.position{1,1}.x{1,1}.CONTENT);
inlet_radius = str2num(Nacelle.inlet{1,1}.radius{1,1}.y{1,1}.CONTENT);

%Radius of the nose of the inlet
inlet_noseRadius = str2num(Nacelle.inlet{1,1}.noseRadius{1,1}.CONTENT);

%Angle of the inlet around y and around z
y_angle_inlet = str2num(Nacelle.inlet{1,1}.angle{1,1}.y{1,1}.CONTENT);
z_angle_inlet = str2num(Nacelle.inlet{1,1}.angle{1,1}.z{1,1}.CONTENT);

%Position of the end of the nacelle
x_end_nacelle = str2num(Nacelle.endPos{1,1}.x{1,1}.CONTENT);

end_nacelle_radius = 0;

%%
%%%%%%%%%%%%%%%%%%%%%%%% Nacelle front %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%no of sections and no of points per sections for the nacelle front
N1 = [13 10];

%N(2) becomes total no of points per section
N1(2) = 4*N1(2);
%generates theta by quarters
N1temp = N1(2)+4;
theta1 = linspace(0, pi/2, N1temp/4);
theta2 = linspace(pi/2, pi, N1temp/4);
theta3 = linspace(-pi, -pi/2, N1temp/4);
theta4 = linspace(-pi/2, 0, N1temp/4);
%theta angles in 1 array
 theta = [theta1(1:end-1), theta2(1:end-1), theta3(1:end-1), theta4(1:end-1)];
%theta = [theta1(1:end), theta2(1:end), theta3(1:end), theta4(1:end)];

% Interpolation of the curve of the front nacelle
A1 = [3*x_maxDiameter^2 2*x_maxDiameter 1 0; x_inlet^3 x_inlet^2 x_inlet 1; x_maxDiameter^3 x_maxDiameter^2 x_maxDiameter 1; x_nozzleColdStream^3 x_nozzleColdStream^2 x_nozzleColdStream 1];
B1 = [0 inlet_radius  maxRadius nozzleColdStream_outerRadius]';
p1 = A1\B1;

% Generates the position of each section of the nacelle end
X_nac_front = linspace(x_inlet,x_nozzleColdStream,N1(1));

% Calculates the radius at each x_nac
r_nac_front = p1(1)*X_nac_front.^3 + p1(2)*X_nac_front.^2 + p1(3)*X_nac_front + p1(4);
diff_p1 = 3*p1(1)*x_nozzleColdStream.^2 + 2*p1(2)*x_nozzleColdStream + p1(3);


% Calculates matrices Y and Z of the nacelle front
Y_nac_front = repmat(r_nac_front, N1(2), 1).*repmat(cos(theta)', 1, N1(1));
Z_nac_front = repmat(r_nac_front, N1(2), 1).*repmat(sin(theta)', 1, N1(1));

%%
%%%%%%%%%%%%%%%%%%%%%%%% Inlet nose %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generates one section for the nose
r_nac_nose = inlet_noseRadius;
X_nac_nose = ones(N1(2),1).*x_inlet;
Y_nac_nose = repmat(r_nac_nose, N1(2), 1).*repmat(cos(theta)', 1, 1);
Z_nac_nose = repmat(r_nac_nose, N1(2), 1).*repmat(sin(theta)', 1, 1);

% Sets the angle in radian
y_angle_inlet_radian = y_angle_inlet*pi/180;
z_angle_inlet_radian = z_angle_inlet*pi/180;

% Generates matrix rotation of the section around y 
Ry = [cos(y_angle_inlet_radian) 0 sin(y_angle_inlet_radian);0 1 0;-sin(y_angle_inlet_radian) 0 cos(y_angle_inlet_radian)];

%Generates matrix rotation of the section around z 
Rz = [cos(z_angle_inlet_radian) -sin(z_angle_inlet_radian) 0; sin(z_angle_inlet_radian) cos(z_angle_inlet_radian) 0; 0 0 1];

M = horzcat(X_nac_nose,Y_nac_nose,Z_nac_nose);

for i = 1:N1(2)
    M(i,:) = Ry*M(i,:)';
    M(i,:) = Rz*M(i,:)';
end

% Rebuild matrix X, Y and Z of the nose after rotation around y and z
X_nac_nose = M(:,1);
Y_nac_nose = M(:,2);
Z_nac_nose = M(:,3);

    
%%%%%%%%%%%%%%%%%%%%% Nozzle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%no of sections and no of points per sections for the Nozzle
N2 = [6 10];

%N(2) becomes total no of points per section
N2(2) = 4*N2(2);

%generates theta by quarters
N2temp = N2(2)+4;
theta1 = linspace(0, pi/2, N2temp/4);
theta2 = linspace(pi/2, pi, N2temp/4);
theta3 = linspace(-pi, -pi/2, N2temp/4);
theta4 = linspace(-pi/2, 0, N2temp/4);

%theta angles in 1 array
theta = [theta1(1:end-1), theta2(1:end-1), theta3(1:end-1), theta4(1:end-1)];

%interpolation of the curve of the nozzle
A2 = [2*x_nozzleColdStream 1 0; x_nozzleColdStream^2 x_nozzleColdStream 1; x_nozzleHotStream^2 x_nozzleHotStream 1];
B2 = [diff_p1  nozzleColdStream_innerRadius nozzleHotStream_outerRadius]';
p2 = A2\B2;

%Generates the position of each section of the nacelle end
X_nac_nozzle = linspace(x_nozzleColdStream,x_nozzleHotStream,N2(1));

%Generates the radius for each section of the nacelle end
r_nac_nozzle = p2(1)*X_nac_nozzle.^2 + p2(2)*X_nac_nozzle+ p2(3);

%Calculates matrix Y and Z of the nozzle
Y_nac_nozzle =  repmat(r_nac_nozzle, N2(2), 1).*repmat(cos(theta)', 1, N2(1));
Z_nac_nozzle =  repmat(r_nac_nozzle, N2(2), 1).*repmat(sin(theta)', 1, N2(1));

%%
%%%%%%%%%%%%%%%%%%%% End of nacelle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%no of sections and no of points per sections for the nacelle end
N3 = [4 10];

%N(2) becomes total no of points per section
N3(2) = 4*N3(2);

%Generates theta by quarters
N3temp = N3(2)+4;
theta1 = linspace(0, pi/2, N3temp/4);
theta2 = linspace(pi/2, pi, N3temp/4);
theta3 = linspace(-pi, -pi/2, N3temp/4);
theta4 = linspace(-pi/2, 0, N3temp/4);

%theta angles in 1 array
theta = [theta1(1:end-1), theta2(1:end-1), theta3(1:end-1), theta4(1:end-1)];

%Interpolation of the curve of the end of the nacelle
A3 = [2*x_nozzleHotStream 1 0; x_nozzleHotStream^2 x_nozzleHotStream 1; x_end_nacelle^2 x_end_nacelle 1];
B3 = [diff_p1  nozzleHotStream_innerRadius end_nacelle_radius]';
p3 = A3\B3;

%Generate the position of each section of the nacelle end
X_nac_end = linspace(x_nozzleHotStream,x_end_nacelle,N3(1));

%Generates the radius for each section of the nacelle end
r_nac_end = p3(1)*X_nac_end.^2 + p3(2)*X_nac_end+ p3(3);

%Calculates matrix Y and Z of the nacelle end
Y_nac_end =  repmat(r_nac_end, N3(2), 1).*repmat(cos(theta)', 1, N3(1));
Z_nac_end =  repmat(r_nac_end, N3(2), 1).*repmat(sin(theta)', 1, N3(1));

%%
%Obtains the whole matrix X, Y and Z of the nacelle by combining those of
%the nacelle front, the nozzle and the nacelle end
%{
X_nac = X_nac_front;
Y_nac = Y_nac_front;
Z_nac = Z_nac_front;
X_nac = repmat(X_nac,N1(2),1);
%}

X_nac = horzcat(X_nac_front,X_nac_nozzle,X_nac_end);
Y_nac = horzcat(Y_nac_front,Y_nac_nozzle,Y_nac_end);
Z_nac = horzcat(Z_nac_front,Z_nac_nozzle,Z_nac_end);
X_nac = repmat(X_nac,N1(2),1);

%Delete the first section in order to be able to replace it with the nose
X_nac(:,1) = [ ];
Y_nac(:,1) = [ ];
Z_nac(:,1) = [ ];

%Obtains the final matrix X, Y and Z of the nacelle by adding the nose
X_nac = horzcat(X_nac_nose,X_nac);
Y_nac = horzcat(Y_nac_nose,Y_nac);
Z_nac = horzcat(Z_nac_nose,Z_nac);

% Matlab mode
if nargin == 1
    size_nac = size(X_nac);
    X_nac(size_nac(1)+1,1:size_nac(2)) = X_nac(1,1:size_nac(2));
    Y_nac(size_nac(1)+1,1:size_nac(2)) = Y_nac(1,1:size_nac(2));
    Z_nac(size_nac(1)+1,1:size_nac(2)) = Z_nac(1,1:size_nac(2));
end

%Obtains the vector normal of the whole nacelle
% vector_normal = Normal(X_nac, Y_nac, Z_nac);

%Draws the nacelle with matlab
%figure(2)
%surf(X_nac, Y_nac, Z_nac)
%hold on
%plot3(X_nac, Y_nac, Z_nac,'r')

%{
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Fan %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Get the useful informations to create sections of the nacelle
%Fan = Engine.geometry{1,1}.fan{1,1};
%{
fan_innerRadius = Fan.innerRadius{1,1}.CONTENT;
fan_outerRadius = Fan.outerRadius{1,1}.CONTENT;

Casing = Fan.casings{1,1};
FrontCasing = Casing.frontCasing{1,1};
RearCasing = Casing.rearCasing{1,1};

x_FrontCasing = FrontCasing.x{1,1}.CONTENT;
FrontCasing_innerRadius = FrontCasing.innerRadius{1,1}.CONTENT;
FrontCasing_outerRadius = FrontCasing.outerRadius{1,1}.CONTENT;

x_RearCasing = RearCasing.x{1,1}.CONTENT;
RearCasing_innerRadius = RearCasing.innerRadius{1,1}.CONTENT;
RearCasing_outerRadius = RearCasing.outerRadius{1,1}.CONTENT;
%}

% Datas replacing those missing
fan_innerRadius = 0.3;
fan_outerRadius = 0.8;

x_FrontCasing = -0.1;
FrontCasing_innerRadius = 0.25;
FrontCasing_outerRadius = 0.83;

x_RearCasing = 0.8;
RearCasing_innerRadius = 0.5;
RearCasing_outerRadius = 0.82;

%%
%no of sections and no of points per sections for the casings of the fan
N4 = [8 10];

%N(2) becomes total no of points per section
N4(2) = 4*N4(2);

%generates theta by quarters
N4temp = N4(2)+4;
theta1 = linspace(0, pi/2, N4temp/4);
theta2 = linspace(pi/2, pi, N4temp/4);
theta3 = linspace(-pi, -pi/2, N4temp/4);
theta4 = linspace(-pi/2, 0, N4temp/4);

%theta angles in 1 array
theta = [theta1(1:end-1), theta2(1:end-1), theta3(1:end-1), theta4(1:end-1)];

%%
%%%%%%%%%%%%%%%%%%% OuterCasing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Interpolation passing by FrontCasing_outerRadius  fan_outerRadius RearCasing_outerRadius
x_interpol_outerCasing = [x_FrontCasing  0 x_RearCasing];
y_interpol_outerCasing = [FrontCasing_outerRadius  fan_outerRadius RearCasing_outerRadius];
p4 = polyfit(x_interpol_outerCasing, y_interpol_outerCasing,2);

%Generates the position of each section of the nacelle end
X_casing = linspace(x_FrontCasing,x_RearCasing,N4(1));

%Calculates the radius at each section
r_outerCasing = p4(1)*X_casing.^2 + p4(2)*X_casing + p4(3);

%Obtains the matrix Y and Z of the outer casing
Y_outerCasing = repmat(r_outerCasing, N4(2), 1).*repmat(cos(theta)', 1, N4(1));
Z_outerCasing = repmat(r_outerCasing, N4(2), 1).*repmat(sin(theta)', 1, N4(1));

%%Draws the outer casing with matlab
%hold on
%surf(X_casing,Y_outerCasing,Z_outerCasing)

%%
%%%%%%%%%%%%%%%%%%% InnerCasing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Interpolation passing by FrontCasing_outerRadius  fan_outerRadius RearCasing_outerRadius
x_interpol_innerCasing = [x_FrontCasing  0 x_RearCasing];
y_interpol_innerCasing = [FrontCasing_innerRadius  fan_innerRadius RearCasing_innerRadius];
p5 = polyfit(x_interpol_innerCasing, y_interpol_innerCasing,2);
diff_p5 =  2*p5(1)*x_FrontCasing + p5(2)*x_FrontCasing;

%calculates the radius at each section
r_innerCasing = p5(1)*X_casing.^2 + p5(2)*X_casing + p5(3);

%Obtains the matrix Y and Z of the inner casing
Y_innerCasing = repmat(r_innerCasing, N4(2), 1).*repmat(cos(theta)', 1, N4(1));
Z_innerCasing = repmat(r_innerCasing, N4(2), 1).*repmat(sin(theta)', 1, N4(1));

%%Draws the inner casing with matlab
%hold on
%surf(X_casing,Y_innerCasing,Z_innerCasing)

%%
%%%%%%%%%%%%%%%%% Fan %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Fan = Engine.global{1,1};
Fan_diameter = Fan.dFan{1,1}.CONTENT;
chordlength = Fan.chordlength{1,1}.CONTENT;
blade_number = Fan.noBla{1,1}.CONTENT;
%}

% Datas replacing those missing
Fan_diameter = 2*fan_outerRadius;
chordlength = 0.1;
blade_number = 24;
%angle in degree between 2 blades
angle = 2*pi/blade_number;

%%
%Generates the cell containing every points of each fan blade
fan_blade = cell(24,1);

%Generates the first fan blade defined by 4 points
point_fan_blade1 = [x_FrontCasing 0 FrontCasing_innerRadius];
point_fan_blade2 = [-chordlength/2 0 p4(1)*(-chordlength/2)^2+p4(2)*(-chordlength/2)+p4(3)];
point_fan_blade3 = [chordlength/2 0 p4(1)*(chordlength/2)^2+p4(2)*(chordlength/2)+p4(3)];
point_fan_blade4 = [-x_FrontCasing 0 p5(1)*(-x_FrontCasing)^2+p5(2)*(-x_FrontCasing)+p5(3)];

fan_blade{1} = vertcat(point_fan_blade1,point_fan_blade2,point_fan_blade3,point_fan_blade4);

%Creates the matrix rotation around x that will allow to generate the other
%fan blade from the first one

Rx = [1 0 0;0 cos(angle) -sin(angle);0 sin(angle) cos(angle)];

%Generates every fan blade by rotation around the x axis
for i = 1:blade_number-1
    point_fan_blade1 = Rx*repmat(fan_blade{i}(1,:)',1,1);
    point_fan_blade2 = Rx*repmat(fan_blade{i}(2,:)',1,1);
    point_fan_blade3 = Rx*repmat(fan_blade{i}(3,:)',1,1);
    point_fan_blade4 = Rx*repmat(fan_blade{i}(4,:)',1,1);
    
    fan_blade{i+1} = vertcat(point_fan_blade1',point_fan_blade2',point_fan_blade3',point_fan_blade4');
end

%Separates the component x, y and z
X_fan_blade = fan_blade{1}(:,1);
Y_fan_blade = fan_blade{1}(:,2);
Z_fan_blade = fan_blade{1}(:,3);

%For the plotting with matlab
for i = 1:blade_number-1
    X_fan_blade = vertcat(X_fan_blade(:,1),fan_blade{i+1}(:,1));
    Y_fan_blade = vertcat(Y_fan_blade(:,1),fan_blade{i+1}(:,2));
    Z_fan_blade = vertcat(Z_fan_blade(:,1),fan_blade{i+1}(:,3));
end
    
%Draws every fan blade of the fan
%hold on
%plot3(X_fan_blade,Y_fan_blade,Z_fan_blade)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Spinner %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Get the useful informations to create sections of the nacelle

%Spinner = Engine.geometry{1,1}.spinner{1,1};
%{
x_nose_spinner = Spinner.nosePos{1,1}.x{1,1}.CONTENT;
x_base_spinner = Spinner.basePos{1,1}.x{1,1}.CONTENT;
spinner_baseRadius = Spinner.baseRadius{1,1}.y{1,1}.CONTENT;
%}

% Datas replacing those missing
x_nose_spinner = -0.7;
x_base_spinner = -0.1;
spinner_baseRadius = 0.25;
%%
%no of sections and no of points per sections for the spinner
N5 = [8 10];

%N(2) becomes total no of points per section
N5(2) = 4*N5(2);

%generates theta by quarters
N5temp = N5(2)+4;
theta1 = linspace(0, pi/2, N5temp/4);
theta2 = linspace(pi/2, pi, N5temp/4);
theta3 = linspace(-pi, -pi/2, N5temp/4);
theta4 = linspace(-pi/2, 0, N5temp/4);

%theta angles in 1 array
theta = [theta1(1:end-1), theta2(1:end-1), theta3(1:end-1), theta4(1:end-1)];
%%
%interpolation of the curve of the spinner
A6 = [2*x_base_spinner 1 0; x_base_spinner^2 x_base_spinner 1; x_nose_spinner^2 x_nose_spinner 1];
B6 = [diff_p5  spinner_baseRadius 0]';
p6 = A6\B6;

%Generates the position of each section of the spinner
X_spinner = linspace(x_nose_spinner,x_base_spinner,N5(1));

%Generates the radius for each section of the spinner
r_spinner = p6(1)*X_spinner.^2 + p6(2)*X_spinner+ p6(3);
 
%Generates the matrix Y and Z of the spinner
Y_spinner =  repmat(r_spinner, N5(2), 1).*repmat(cos(theta)', 1, N5(1));
Z_spinner =  repmat(r_spinner, N5(2), 1).*repmat(sin(theta)', 1, N5(1));

%Draw the spinner with matlab
%hold on
%surf(X_spinner,Y_spinner,Z_spinner)

%xlabel('x')
%ylabel('y')
%zlabel('z')
%grid on
%}

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Transformations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 2

%reminder, engine_transformation = structure.vehicles{1,1}.aircraft{1,1}.model{1,1}.engines{1,1}.engine{1,counter(8)}.transformation{1,1};

%%
%%%%%%%%%%%%%%%%%%%%%% Translation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Get the scaling in x, y and z
translation_x = str2num(engine_transformation.translation{1,1}.x{1,1}.CONTENT);
translation_y = str2num(engine_transformation.translation{1,1}.y{1,1}.CONTENT);
translation_z = str2num(engine_transformation.translation{1,1}.z{1,1}.CONTENT);

% Set the translation transformation on each matrix

%%
%%% translation transformation on nacelle
%{
X_nac = X_nac + translation_x;
Y_nac = Y_nac + translation_y;
Z_nac = Z_nac + translation_z;

%%
%%% translation transformation on fan

% On fan outer_casing
Y_outerCasing = Y_outerCasing + translation_y;
Z_outerCasing = Z_outerCasing + translation_z;

% On fan outer_casing
Y_innerCasing = Y_innerCasing + translation_y;
Z_innerCasing = Z_innerCasing + translation_z;

%
X_casing = X_casing.*translation_x;

%translation transformation on fan blades
X_fan_blade = X_fan_blade + translation_x;
Y_fan_blade = Y_fan_blade + translation_y;
Z_fan_blade = Z_fan_blade + translation_z;

%%
%%% translation transformation on spinner
X_spinner = X_spinner + translation_x;
Y_spinner = Y_spinner + translation_y;
Z_spinner = Z_spinner + translation_z;
%}

%%
%%%%%%%%%%%%%%%%%%%%%%%%% Scaling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Get the scaling in x, y and z
scaling_x = str2num(engine_transformation.scaling{1,1}.x{1,1}.CONTENT);
scaling_y = str2num(engine_transformation.scaling{1,1}.y{1,1}.CONTENT);
scaling_z = str2num(engine_transformation.scaling{1,1}.z{1,1}.CONTENT);

% Set the scaling transformation on each matrix

%%
%%% Scaling transformation on nacelle
%{
X_nac = X_nac.*scaling_x - (scaling_x - 1)*translation_x;
Y_nac = Y_nac.*scaling_y - (scaling_y - 1)*translation_y;
Z_nac = Z_nac.*scaling_z - (scaling_z - 1)*translation_z;

%%
%%% Scaling transformation on fan

% On fan outer_casing
Y_outerCasing = Y_outerCasing.*scaling_y - (scaling_y - 1)*translation_y;
Z_outerCasing = Z_outerCasing.*scaling_z - (scaling_z - 1)*translation_z;

% On fan outer_casing
Y_innerCasing = Y_innerCasing.*scaling_y - (scaling_y - 1)*translation_y;
Z_innerCasing = Z_innerCasing.*scaling_z - (scaling_z - 1)*translation_z;

%
X_casing = X_casing.*scaling_x;

%Scaling transformation on fan blades
X_fan_blade = X_fan_blade.*scaling_x - (scaling_x - 1)*translation_x;
Y_fan_blade = Y_fan_blade.*scaling_y - (scaling_y - 1)*translation_y;
Z_fan_blade = Z_fan_blade.*scaling_z - (scaling_z - 1)*translation_z;

%%
%%% Scaling transformation on spinner
X_spinner = X_spinner.*scaling_x;
Y_spinner = Y_spinner.*scaling_y - (scaling_y - 1)*translation_y;
Z_spinner = Z_spinner.*scaling_z - (scaling_z - 1)*translation_z;
%}


%%
%%%%%%%%%%%%% Rotation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Get the angle of rotation around x, y and z
angle_rotation_x = str2num(engine_transformation.rotation{1,1}.x{1,1}.CONTENT);
angle_rotation_y = str2num(engine_transformation.rotation{1,1}.y{1,1}.CONTENT);
angle_rotation_z = str2num(engine_transformation.rotation{1,1}.z{1,1}.CONTENT);

%% Reference Coordinate system

% Reference Coordinate System Mtarix
globalChoord=[1 0 0;...
              0 1 0;...
              0 0 1];
% Referenc% Point          
globalRefPoint=[0 0 0]';
p=globalRefPoint;

% Scale Matrix
eyeMat=eye(3);
scaleMat=[eyeMat(1,:)*scaling_x; eyeMat(2,:)*scaling_y; eyeMat(3,:)*scaling_z];

% cd(['..' filesep '..'])
% cd(['CPACSWrapper' filesep 'lib'])

% Euler Transformation
[transMat] = eulerTrans(angle_rotation_x, angle_rotation_y, angle_rotation_z);

% Transformed Coordysytem
coordSys1=transMat*globalChoord*scaleMat;

% Transformed point
trans(1,1) = translation_x;
trans(2,1) = translation_y;
trans(3,1) = translation_z;
p1=(p+trans);

SectionBasic = [];

size_mat = size(X_nac);

for i=1:size_mat(2)
    for j=1:size_mat(1)

        SectionBasic(j,1) = X_nac(j,i);
        SectionBasic(j,2) = Y_nac(j,i);
        SectionBasic(j,3) = Z_nac(j,i);
        
    end
    
    section=[coordSys1*SectionBasic']'+[p1(1)*ones(size(SectionBasic,1),1),p1(2)*ones(size(SectionBasic,1),1),p1(3)*ones(size(SectionBasic,1),1)];
    
    X_nac(:,i) = section(:,1);
    Y_nac(:,i) = section(:,2);
    Z_nac(:,i) = section(:,3);
end
% figure()
% plot3(X_nac,Y_nac,Z_nac,'b.')
% axis equal

% cd(['..' filesep 'Geometry'])

end

end