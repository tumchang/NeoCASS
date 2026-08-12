function [HamBody] = getHamBodyCoord(Ham, kvect, selectRigid, ta, e0, v0, edot0, angleCoord)
%
% [HamBody] = getHamBodyCoord(Ham, kvect, selectRigid, ta, e0, v0, edot0, angleCoord)
%
% Converts the rigid aero forces from the inertial coordinates 
% ([x,y,z], [phi,theta,psi] and their time derivatives) to the body coordinates
% ([u,v,w], [p,q,r] and their derivatives). If angleCoord = true, [u,beta,alpha] 
% are used instead of [u,v,w].
%
%
%-------------------------------------------------------------------------------
% 30-08-2016
%

nh = size(Ham,1);
nk = size(Ham,3);


Hx = Ham(:,selectRigid(1:3),:);
He = Ham(:,selectRigid(4:6),:);

dHx = imag(Hx(:,:,2))/kvect(2) - 1j*real(Hx(:,:,2))/(kvect(2))^2*kvect(1);


% Get the transformation matrices from inertial to body axes (VORU)
[T1, T2, T3] = iner2body(e0, v0, edot0, angleCoord);
R = T1(7:9,7:9);
S = inv(T1(10:12,10:12));
Gamma1 = T1(7:9,4:6);


Hu = zeros(nh,3,nk);
Hu(:,:,1) = ta*dHx*R;

for ik = 2:nk
	Hu(:,:,ik) = - ta*1j * (Hx(:,:,ik)/kvect(ik))*R;
end

if norm(edot0)>0
	error('edot0 must be null for the conversion of the Ham matrix in body coordinates')
end


R2 = R\Gamma1;
HH = zeros(nh,3,nk);
for ik = 1:nk
	HH(:,:,ik) = He(:,:,ik) + Hu(:,:,ik)*R2;
end

dHH = imag(HH(:,:,2))/kvect(2) - 1j*real(HH(:,:,2))/(kvect(2))^2*kvect(1);

Hom = zeros(nh,3,nk);
Hom(:,:,1) = ta*dHH*S;

for ik = 2:nk
	Hom(:,:,ik) = - ta*1j * (HH(:,:,ik)/kvect(ik))*S;
end


HamBody = Ham;
HamBody(:,selectRigid(1:3),:) = Hu;
HamBody(:,selectRigid(4:6),:) = Hom;

return
