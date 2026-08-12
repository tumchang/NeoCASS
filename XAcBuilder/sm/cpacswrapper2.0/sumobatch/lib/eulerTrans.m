function [transMat] = eulerTrans(r1,r2,r3,transType)

%% Tranformation Matrix

angles = -[r1(:) r2(:) r3(:)]*pi/180;

transMat = zeros(3,3,size(angles,1));
cang = cos( angles );
sang = sin( angles );

if nargin == 3
    transType='zyx';
end

% Transformation
switch transType
    case 'zyx'
        % Luftfahrtnorm (DIN 9300) (Yaw-Pitch-Roll, Z, Y’, X’’)
        % Euler Angles psi,theta,phi
        % phi   -> x rotation 
        % theta -> y rotation 
        % psi   -> z rotation 
        
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
    
    case 'xyz'      
        %     [          cy*cz, sz*cx+sy*sx*cz, sz*sx-sy*cx*cz]
        %     [         -cy*sz, cz*cx-sy*sx*sz, cz*sx+sy*cx*sz]
        %     [             sy,         -cy*sx,          cy*cx]

        transMat(1,1,:) = cang(:,2).*cang(:,3);
        transMat(1,2,:) = sang(:,1).*sang(:,2).*cang(:,3) + cang(:,1).*sang(:,3);
        transMat(1,3,:) = -cang(:,1).*sang(:,2).*cang(:,3) + sang(:,1).*sang(:,3);
        transMat(2,1,:) = -cang(:,2).*sang(:,3);
        transMat(2,2,:) = -sang(:,1).*sang(:,2).*sang(:,3) + cang(:,1).*cang(:,3);
        transMat(2,3,:) = cang(:,1).*sang(:,2).*sang(:,3) + sang(:,1).*cang(:,3);        
        transMat(3,1,:) = sang(:,2);
        transMat(3,2,:) = -sang(:,1).*cang(:,2);
        transMat(3,3,:) = cang(:,1).*cang(:,2);   
end

