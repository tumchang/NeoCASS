function output_txt = displayNodeID_fun(obj,event_obj, ID, Coord)
%
% Display the position of the data cursor and the ID of the closest GRID
%
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).
% ID           array of IDs
% Coords       [x,y,z] locations of each GRID
%
% 14-10-2016
%

pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4)], ...
              ['Y: ',num2str(pos(2),4)], ...
              ['Z: ',num2str(pos(3),4)]};

n_grid = length(ID);
pos = reshape(pos, [1,3]);

dist = Coord - ones(n_grid,1)*pos;
dist = sum(dist.^2, 2);

[dmin, imin] = min(dist);

if dmin < 1e-3
	output_txt{4} = ['ID: ', num2str(ID(imin))];
else
	output_txt{4} = ['(closest ID: ', num2str(ID(imin)), ')'];
end




return
