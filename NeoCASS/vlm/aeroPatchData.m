function [wingP] = aeroPatchData(fc, flapped, TW1deg,TW2deg, T, SWPdeg, c, DIHdeg, b, ox, oy, oz)
%
% 21-05-2017
%

%function [C, Vor, N, DN, P, ndof, cdof, hinge,S] = geometry19(fnx, ny, nx, fsym, fc, flapped, TW, foil, T, SW, c, dihed, b, sym, sx, sy, sz, meshtype, aefact)
TW1 = TW1deg*pi/180;
TW2 = TW2deg*pi/180;
SW = SWPdeg*pi/180;
dihed = DIHdeg*pi/180;

%%%%%%%%%%%%%%%%%%%%%%%
%Calculates geometry, collocationpoints, panels and vortecies for a flat quad
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%
% Plotting planform
%%%%%%%%%%%%%%%%%%

lem(1)=0.25*c;
lem(2)=0.25*T*c;
lem(3)=-0.75*T*c;
lem(4)=-0.75*c;

DX =[(1-cos(TW1))*cos(SW) (1-cos(TW2))*cos(SW) (1-cos(TW2))*cos(SW) (1-cos(TW1))*cos(SW)].*lem;

DY =-[sin(TW1)*sin(dihed)*cos(SW) sin(TW2)*sin(dihed)*cos(SW) sin(TW2)*sin(dihed)*cos(SW) sin(TW1)*sin(dihed)*cos(SW)].*lem;

DZ =[sin(TW1)*cos(dihed) sin(TW2)*cos(dihed) sin(TW2)*cos(dihed) sin(TW1)*cos(dihed)].*lem;

wingx =[0 0.25*c+b*tan(SW)-0.25*T*c 0.25*c+b*tan(SW)+0.75*T*c c] + ox + DX;
wingy =[0 b*cos(dihed) b*cos(dihed) 0] + oy + DY;
wingz =[0 b*sin(dihed) b*sin(dihed) 0] + oz + DZ;

wingP = [wingx',wingy',wingz'];

% %%%%%%%%%%%%%%%%%
% %Plotting hinge %
% %%%%%%%%%%%%%%%%%
% hinge = zeros(1,2,3);
% cdof = [];
% 
% if (flapped==1) || (flapped==-1)
% 
% 	[flapx flapy flapz] = drawhinge(wingx, wingy, wingz, fc);
% 
% 	hinge(1,1,1) = flapx(1);
% 	hinge(1,2,1) = flapx(2);
% 
% 	hinge(1,1,2) = flapy(1);
% 	hinge(1,2,2) = flapy(2);
% 
% 	hinge(1,1,3) = flapz(1);
% 	hinge(1,2,3) = flapz(2);
% 
% 	offset = 0;
% 
% end

return
