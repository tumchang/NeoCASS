function [HamBody] = getHamBodyCoord(Ham, kvect, rigidDOF, l_a, e0, v0norm, edot0norm, ctilde, angleCoord)
%
% [HamBody] = getHamBodyCoord(Ham, kvect, rigidDOF, l_a, e0, v0norm, edot0norm, ctilde, angleCoord)
%
% Ham : (3D-array [nrows x ncols x nk]) Aerodynamic matrix
% kvect : (1D-array [nk]) reduced frequencies
%
% rigidDOF : (2D-array [6 x 3]) table with rigid motion data. The third column of 
%            rigidDOF indicates the location of each component of rigid motion
%            in the modal base (the base used for the computation of the columns of 
%            Ham). The element rigidDOF(i,3) indicates the location of the rigid
%            component i, if rigidDOF(i,3) is zero, the component is discarded.
%
% l_a : aerodynamic reference length, used for the computation of the aerodynamic 
%       reference time ta = l_a/Vref
%
% e0        : (1D-array [3]) euler angles 321
% v0norm    : (1D-array [3]) normalized velocity v0norm = v0/Vref
% edot0norm : (1D-array [3]) normalized angular rates edot0norm = edot0*ta = edot0*l_a/Vref
%
% ctilde    : (1D array [3]) scale vector with the scale factors for the angular velocities
%             normalized with respect to the aerodynamic reference length l_a:
%             ctilde = [b/l_a, c/l_a, b/l_a]
%
% angleCoord : logical
%
%
% The portion of the aerodynamic matrix relative to the rigid motion (specified
% in rigidDOF) will be substituted by the arrays Hu, Hom defined as
%
% aeroForces(jk) = qinf*Hu*[u; v; w]/Vref  +  qinf*Hom*[p*b/Vref; q*c/Vref; r*b/Vref]
%
% where b and c are the same lengths used in the definition of ctilde
%
% Converts the rigid aero forces from the inertial coordinates 
% ([x,y,z], [phi,theta,psi] and their time derivatives) to the body coordinates
% ([u,v,w], [p,q,r] and their derivatives). If angleCoord = true, [u,beta,alpha] 
% are used instead of [u,v,w].
%
%
%-------------------------------------------------------------------------------
% 30-08-2016
% 21-11-2016 v2.0 nondimensional definition of velocities
%

nh = size(Ham,1);
nk = size(Ham,3);

disUsed = find(rigidDOF(1:3,3));
rotUsed = find(rigidDOF(4:6,3));

Hx = Ham(:,rigidDOF(disUsed,3),:);
He = Ham(:,rigidDOF(3+rotUsed,3),:);

dHx = imag(Hx(:,:,2))/kvect(2) - 1j*real(Hx(:,:,2))/(kvect(2))^2*kvect(1);


if isempty(ctilde)
	ctilde = ones(3,1);
end
ctilde = ctilde(rotUsed);

% Get the transformation matrices from inertial to body axes (VORU)
[T1, T2, T3] = iner2body(e0, v0norm, edot0norm, angleCoord);
R = T1(7:9,7:9);               R = R(disUsed,disUsed);
Gamma2norm = T1(10:12,10:12);  Gamma2norm = Gamma2norm(rotUsed,rotUsed)*diag(1./ctilde);
Lambda1 = T1(7:9,4:6);         Lambda1 = Lambda1(disUsed,rotUsed);
%Lambda2 = T1(10:12,4:6);       Lambda2 = Lambda2(rotUsed,rotUsed);

Hu = zeros(nh,length(disUsed),nk);
Hu(:,:,1) = l_a*dHx*R;

for ik = 2:nk
	Hu(:,:,ik) = - l_a*1j * (Hx(:,:,ik)/kvect(ik))*R;
end

if norm(edot0norm)>0
	error('edot0 must be null for the conversion of the Ham matrix in body coordinates')
end


R2 = R'*Lambda1;
HH = zeros(nh,3,nk);
for ik = 1:nk
	HH(:,:,ik) = He(:,:,ik) + Hu(:,:,ik)*R2;
end

dHH = imag(HH(:,:,2))/kvect(2) - 1j*real(HH(:,:,2))/(kvect(2))^2*kvect(1);

Hom = zeros(nh,3,nk);
Hom(:,:,1) = dHH*Gamma2norm;

for ik = 2:nk
	Hom(:,:,ik) = - 1j * (HH(:,:,ik)/kvect(ik))*Gamma2norm;
end


HamBody = Ham;
HamBody(:,rigidDOF(  disUsed,3),:) = Hu;
HamBody(:,rigidDOF(3+rotUsed,3),:) = Hom;

return
