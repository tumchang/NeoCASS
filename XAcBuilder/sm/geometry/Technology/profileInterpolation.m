%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% profileInterpolation 
%
%   INPUT 
%       prof1
%       prof2
%       t
%
%   OUTPUT 
%       profInt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     10.10.13     1.0    F.Dinardo        Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function profInt=profileInterpolation(prof1,prof2,t)

N1=length(prof1(:,1)); N2=length(prof1(:,2));

for i=1:N1
    profInt(i,:)=((prof2(i,:)'-prof1(i,:)')*t+prof1(i,:)')';
end

plot3(profInt(:,1),profInt(:,2),profInt(:,3),'r')