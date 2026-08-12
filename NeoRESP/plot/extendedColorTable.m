function out = extendedColorTable(colID, reducedColors)
%
%
%
%-------------------------------------------------------------------------------
% 12-06-2014 v1.0
% 25-06-2015 v1.1 reducedColors parameter added
%

nin = nargin;

if nin==0 || ~exist('reducedColors', 'var') || isempty(reducedColors)
	reducedColors = false;
end

onlynumber = nin==0 || isempty(colID);

ReducedList = [1,2,3,4,5,6,7,8,9];

Colors = [
            0,   0, 255; % 'b' : Blue
            0, 153,   0; % 'g' : green 1
          255,   0,   0; % 'r' : Red
            0, 255, 255; % 'c' : cyan
          153,   0, 153; % 'm' : Magenta
          204, 204,   0; % 'y' : yellow
            0,   0,   0; % 'k' : black
          255, 128,   0; % 'o' : orange
          160, 160, 160; % 'n' : grey
          255,  51, 153; % 'M' : Magenta
          102,   0, 204; % 'v' : Violet
            0, 255,   0; % 'G' : green 2
            0,   0, 102; % 'B' : Dark blue
            0, 128, 255; % 's' : light blue
            0, 102,   0; % 'W' : Dark green
            0, 102, 102; % 'C' : Dark cyan
          102,   0,   0; % 'R' : Dark red
          %255, 255, 255; % 'w' : white
          ]/255;
 
Names = { 'b';  
          'g'; 
          'r'; 
          'c'; 
          'm'; 
          'y'; 
          'k'; 
          'o'; 
          'n'; 
          'M'; 
          'v'; 
          'G'; 
          'B'; 
          's'; 
          'W'; 
          'C'; 
          'R';
%          'w';
        };

if reducedColors
	Colors = Colors(ReducedList,:);
	Names = Names(ReducedList);
end

if onlynumber
	out = length(Names);
	return;
end

n = length(colID);

by_ID = strcmp(class(colID(1)), 'char');


if by_ID
	pos = zeros(n,1);
	for i = 1:n
		pos(i) = find(strcmp(Names, colID(i)));
	end
else
	pos = colID - floor((colID-1)/length(Names))*length(Names);
end

out = Colors(pos,:);

return
