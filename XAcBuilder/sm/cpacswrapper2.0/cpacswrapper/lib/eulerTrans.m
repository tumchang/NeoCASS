function [transMat] = eulerTrans(r1,r2,r3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Euler tranformation                                                    %
%  Special for CPACS operations. The rotation sequence is:                % 
%  1. arround X, 2. arround Y, 3. arround Z                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-28 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input

angles = -[r3(:) r2(:) r1(:)]*pi/180; %--> Drehreinenfolge r1,r2,r3

transMat = zeros(3,3,size(angles,1));
cang = cos( angles );
sang = sin( angles );

%% Tranformation Matrix

% [          cy*cz,          cy*sz,            -sy]
% [ sy*sx*cz-sz*cx, sy*sx*sz+cz*cx,          cy*sx]
% [ sy*cx*cz+sz*sx, sy*cx*sz-cz*sx,          cy*cx]

transMat(1,1,:) = cang(:,2).*cang(:,1);
transMat(1,2,:) = cang(:,2).*sang(:,1);
transMat(1,3,:) = -sang(:,2);
transMat(2,1,:) = sang(:,3).*sang(:,2).*cang(:,1) - cang(:,3).*sang(:,1);
transMat(2,2,:) = sang(:,3).*sang(:,2).*sang(:,1) + cang(:,3).*cang(:,1);
transMat(2,3,:) = sang(:,3).*cang(:,2);
transMat(3,1,:) = cang(:,3).*sang(:,2).*cang(:,1) + sang(:,3).*sang(:,1);
transMat(3,2,:) = cang(:,3).*sang(:,2).*sang(:,1) - sang(:,3).*cang(:,1);
transMat(3,3,:) = cang(:,3).*cang(:,2);
    

% [          cos(y)*cos(x),          cos(y)*sin(x),            -sin(y)]
% [ sin(y)*sin(z)*cos(x)-sin(x)*cos(z), sin(y)*sin(z)*sin(x)+cos(x)*cos(z),          cos(y)*sin(z)]
% [ sin(y)*cos(z)*cos(x)+sin(x)*sin(z), sin(y)*cos(z)*sin(x)-cos(x)*sin(z),          cos(y)*cos(z)]