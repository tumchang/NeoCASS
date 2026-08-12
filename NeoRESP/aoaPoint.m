function [Cj, Cjdot] = aoaPoint(Up, rigidDOF, v0, e0, edot0, Riq, axesUsed)
%
%
%
%-------------------------------------------------------------------------------
% 21-02-2017
%

nj = size(Up,3);
np = size(Up,1);

v0 = reshape(v0, [3,1]);
e0 = reshape(e0, [3,1]);
edot0 = reshape(edot0, [3,1]);

% Get steady state condition
U = v0(1);
V = v0(2);
W = v0(3);

% Get steady state condition
Phi   = e0(1);
Theta = e0(2);
Psi   = e0(3);

Phidot   = edot0(1);
Thetadot = edot0(2);
Psidot   = edot0(3);

% Rotation matrix for Euler angles 321
R1 = [1,        0,         0;
      0, cos(Phi), -sin(Phi);
      0, sin(Phi),  cos(Phi)];

R2 = [ cos(Theta), 0, sin(Theta);
                0, 1,          0;
      -sin(Theta), 0, cos(Theta)];

R3 = [cos(Psi), -sin(Psi), 0;
      sin(Psi),  cos(Psi), 0;
             0,         0, 1];

Rij = R3*R2*R1;


% Transformation matrix from euler angles to angular velocity in inertial frame
Si = [cos(Psi)*cos(Theta), -sin(Psi), 0;
      sin(Psi)*cos(Theta),  cos(Psi), 0;
              -sin(Theta),         0, 1];

% substitute the v and w components of the velocity in the body reference with
% alpha and beta.
Vl   = sqrt(U^2 + W^2);
Vinf2 = Vl^2 + V^2;
velTransform = [              1,                0,               0;
                -V*U/(Vl*Vinf2), (1-V^2/Vinf2)/Vl, -V*W/(Vl*Vinf2);
                        -W/Vl^2,                0,          U/Vl^2];

if strcmp(axesUsed, 'bodyAngles')
	scaleVel = inv(velTransform);
else
	scaleVel = eye(3,3);
end


% Check the degree of freedom included in the model
%
% rigidModeTable: two columns
% - first column  : rigid degree of freedom from 1 to 6 (ux, uy, uz, tx, ty,tz)
% - second column : position of the DOF in th j-set 
%
% rigidDisplTable, rigidRotTable are teh same matrix but only
% for diasplacements and rotations
%
rigidDofUsed = find(rigidDOF(:,3));
rigidModeTable = [rigidDofUsed, rigidDOF(rigidDofUsed,3)];

isDisplacement = (rigidDofUsed < 4);

rigidDisplTable = rigidModeTable(isDisplacement,:);
rigidRotTable = rigidModeTable(~isDisplacement,:);
rigidRotTable(:,1) = rigidRotTable(:,1) - 3;

defoDOF = true(nj,1);
defoDOF(rigidModeTable(:,2)) = false;



%-------------------------------------------------------------------------------

Tai = velTransform(2:3,:) * Riq';

Cj    = zeros(2*np, nj);
Cjdot = zeros(2*np, nj);

vMat = crossMatrix(Rij*v0);
omega = Si*e0;
omMat = crossMatrix(omega);


switch axesUsed
case 'inertial'

	Cj(:,rigidDisplTable(:,2)) = 0;
	Cj(:,rigidRotTable(:,2)) = repmat(Tai * vMat(:,rigidRotTable(:,1)), [np,1]);

	for ip = 1:np

		Upoint = permute(Up(ip,:,:), [2,3,1]);

		T1 = omMat*Upoint(1:3,defoDOF);
		T2 =  vMat*Upoint(4:6,defoDOF);
		T3 = crossMatrix(Upoint(1:3, rigidRotTable(:,2))*omega(rigidRotTable(:,1))) * Upoint(4:6, defoDOF);

		Cj(2*(ip-1)+ (1:2), defoDOF) = Tai*(T1+T2+T3);


		Cjdot(2*(ip-1)+ (1:2),rigidDisplTable(:,2)) = Tai*Upoint(1:3, rigidDisplTable(:,2));
		Cjdot(2*(ip-1)+ (1:2),  rigidRotTable(:,2)) = Tai*Upoint(1:3,   rigidRotTable(:,2));
		Cjdot(2*(ip-1)+ (1:2),             defoDOF) = Tai*Upoint(1:3,              defoDOF);


	end

case {'body', 'bodyAngles'}
	for ip = 1:np

		Upoint = permute(Up(ip,:,:), [2,3,1]);

		T1 = omMat(:,rigidDisplTable(:,1))*Upoint(rigidDisplTable(:,1),defoDOF);
		T2 = vMat(:,rigidRotTable(:,1))*Upoint(rigidRotTable(:,1),defoDOF);
		T3 = crossMatrix(Upoint(1:3, rigidRotTable(:,2))*omega(rigidRotTable(:,1))) * Upoint(4:6, defoDOF);

		Cj(2*(ip-1)+ (1:2), defoDOF) = Tai*(T1+T2+T3);


		Cjdot(2*(ip-1)+ (1:2),rigidDisplTable(:,2)) = Tai*Rij * scaleVel(:, rigidDisplTable(:,1));
		Cjdot(2*(ip-1)+ (1:2),  rigidRotTable(:,2)) = Tai*Upoint(1:3, rigidRotTable(:,2))*Rij(rigidRotTable(:,1), rigidRotTable(:,1));
		Cjdot(2*(ip-1)+ (1:2),             defoDOF) = Tai*Upoint(1:3, defoDOF);
	end


otherwise
	error('Wrong value for parameter ''axesUsed''.');
end







return

function Mat = crossMatrix(vec)

Mat = [      0, -vec(3),  vec(2);
        vec(3),       0, -vec(1);
       -vec(2),  vec(1),       0];

return
