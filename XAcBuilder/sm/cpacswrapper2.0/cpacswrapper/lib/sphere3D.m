function sphere3D(refPoint,scale)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  sphere3D                                                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                         
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-28 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inputs

if nargin<1
    refPoint=[1 1 1]';
end

if nargin<2
    scale=1;
end

xpos=refPoint(1);
ypos=refPoint(2);
zpos=refPoint(3);

%% Plot sphere

% Fidelity setting
n = 20;

% Calc sphere coordinates
theta = (-n:2:n)/n*pi;
phi = (-n:2:n)'/n*pi/2;
cosphi = cos(phi); cosphi(1) = 0; cosphi(n+1) = 0;
sintheta = sin(theta); sintheta(1) = 0; sintheta(n+1) = 0;
x = cosphi*cos(theta)*scale+xpos;
y = cosphi*sintheta*scale+ypos;
z = sin(phi)*ones(1,n+1)*scale+zpos;

% Plot with surf
surf(x,y,z)
colormap([0  0  0])

