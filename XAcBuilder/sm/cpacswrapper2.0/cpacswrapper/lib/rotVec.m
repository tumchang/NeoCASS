function [x2] = rotVec(alpha,x1,rotAxe)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  rotVec                                                                 %
%  Rotate a vector arround one axe                                        %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-28 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Descibtion
% rotVec(alpha,x1,rotAxe)
%   alpha  - rotation Angle
%   x1     - Vector which should be rotated
%   rotAxe - Rotation arround 1 = x-axe , 2 = y-axe , 3= z-axe

%% Calc Rotation
alpha=alpha*pi/180;
switch rotAxe
    case 1
        R=[1 0 0;0 cos(alpha) -sin(alpha);0 sin(alpha) cos(alpha)];
    case 2
        R=[cos(alpha) 0  sin(alpha);0 1 0;-sin(alpha) 0 cos(alpha)];
    case 3
        R=[cos(alpha) -sin(alpha) 0;sin(alpha) cos(alpha) 0; 0 0 1];
end
x2=R*x1;
