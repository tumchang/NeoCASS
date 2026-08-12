function [comp1, comp2] = Available_Volume(length, spardistance1, thickness1, chord1, spardistance2, thickness2, chord2)
% This computes the available fuel volume
%

kadj = 0.92;  % Accounts for geometric and structural adjustments
s1 = thickness1*spardistance1*(chord1^2);
s2 = thickness2*spardistance2*(chord2^2);
comp1 = length/3*kadj*(s1+s2+(s1*s2)^0.5);  % Torenbeek volume
comp2 = length/4*(s1+3*s2+2*(s1*s2)^0.5)/(s1+s2+(s1*s2)^0.5);  % Torenbeek cog