function [T1, T2, T3, Rij, Sj, velTransform] = iner2body(e0, v0, edot0, angleCoord)
%
% [T1, T2, T3] = iner2body(e0, v0, edot0, angleCoord)
% [T1, T2, T3] = iner2body(e0, v0, edot0)
%
% Generates the matrices performing the linearized transformation from inertial 
% axes coordinates xi to body axes coordinates xb, where
%
% xi = [ri; e; vi=ri_dot; e_dot];
% xb = [rb; e; vb; omegab];
%
% the transformation is linearized: xi and xb contains the perturbations of 
% the variables with respect to a reference state.
%
% The reference state is defined by:
% e0 = [phi0; theta0; psi0];
% v0 = vb0 = [u0; v0; w0];
% edot0 = [phidot0; thetadot0; psidot0];
%
% If the anleCoord option is activated the resulting xb is modified in order
% to substitute the second and third components of vb with the sideslip angle
% beta and the angle of attack alpha.
%
%
% e = [psi, theta psi] are the euler angles 321. It is assumed that the inertial 
% frame and the body frame coincide when e = 0. If the inertial frame has the x
% axis directed toward the tail of the veichle (most common frame for structural
% and aeroelastic models) the flight speed will have a negative x-component in the
% body frame, e.g. for a levelled symmetric flight
% v0 = [-Uinf; 0; 0]
%
%
% References:
% [1] Gupta, Kajal K., M. J. Brenner, and L. S. Voelker. "Development of an 
%     integrated aeroservoelastic analysis program and correlation with test 
%     data." NASA-TP-3120 (1991).
%
%-------------------------------------------------------------------------------
% 13-10-2015
% 03-09-2016 v1.1 Equations modified with respect to the reference paper
% 19-02-2017 
%

if ~exist('angleCoord', 'var') || isempty(angleCoord)
	angleCoord = false;
end

edot0 = reshape(edot0, [3,1]);

% Get steady state condition
U = v0(1);
V = v0(2);
W = v0(3);

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

Sidot = [-Psidot*sin(Psi)*cos(Theta) - Thetadot*cos(Psi)*sin(Theta), -Psidot*cos(Psi), 0;
          Psidot*cos(Psi)*cos(Theta) - Thetadot*sin(Psi)*sin(Theta),  Psidot*sin(Psi), 0;
                                              - Thetadot*cos(Theta),                0, 0];

if nargout>=5
	% Transformation matrix from euler angles to angular velocity in body frame
	Sj = [  1,                 0,          -sin(Theta);
	        0,          cos(Phi),  cos(Theta)*sin(Phi);
	        0,         -sin(Phi),  cos(Theta)*cos(Phi)];
end


vMat = crossMatrix(Rij*[U; V; W]);
omMat = crossMatrix(Si*[Phidot;Thetadot; Psidot]);


T1 = zeros(12,12);
T1(1:3,1:3) = Rij;
T1(4:6,4:6) = Si;

T1(7:9,4:6) = -vMat*Si;
T1(7:9,7:9) = Rij;

T1(10:12,10:12) = Rij;


T2 = zeros(12,12);

T2(1:3,1:3) = Rij;
T2(4:6,4:6) = Si;
T2(7:9,7:9) = Rij;
T2(10:12,10:12) = Rij;


T3 = zeros(12,12);

T3(1:3,1:3) = omMat*Rij;
T3(1:3,4:6) = -vMat*Si;

T3(4:6,4:6) = Sidot;

T3(7:9,7:9)   = omMat*Rij;
T3(7:9,10:12) = -vMat*Rij;

T3(10:12,10:12) = omMat*Rij;


% substitute the v and w components of the velocity in the body reference with
% alpha and beta.
Vl   = sqrt(U^2 + W^2);
Vinf2 = Vl^2 + V^2;
velTransform = [              1,                0,               0;
                -V*U/(Vl*Vinf2), (1-V^2/Vinf2)/Vl, -V*W/(Vl*Vinf2);
                        -W/Vl^2,                0,          U/Vl^2];

if angleCoord
	invVelTransform = velTransform\eye(3,3);

	T1(:,7:9) = T1(:,7:9)*invVelTransform;
	T2(:,7:9) = T2(:,7:9)*invVelTransform;
	T3(:,7:9) = T3(:,7:9)*invVelTransform;

end


return

function Mat = crossMatrix(vec)

Mat = [      0, -vec(3),  vec(2);
        vec(3),       0, -vec(1);
       -vec(2),  vec(1),       0];

return
