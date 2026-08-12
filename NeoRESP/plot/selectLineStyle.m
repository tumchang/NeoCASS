function [] = selectLineStyle(hplot, index, selectmajor, reducedColors)
% Select markers and colors in order to avoid repetitions
% [] = markerfun(hplot, index, selectmajor, reducedColors)
%
% selectmajor=1 ==> colors change faster
% selectmajor=2 ==> markers change faster
%
% hplot can be a vector, in that case index can be:
%
% [] (empty vector) : values 1:length(hplot) will be employed
% scalar value      : all curves will be plotted with the same format
% vector with same length of hplot: values in index will be used
%
%
% reducedColors (optional, default=false) if true only a reduced set of
% colors will be used
%
% FIXME: floor(index/n)+1 is wrong (wrong result with index=n)
%-------------------------------------------------------------------------------
% 12-06-2014 v1.0
% 23-04-2015 v1.1 array of plot handles allowed
%

marker_table = {'.', '+', 'x', 'o', 's', 'd', 'v', '<', '>', '*', '^', 'p', 'h'};
linestyle_table = {'-', '--', '-.'};

if ~exist('reducedColors', 'var') || isempty(reducedColors)
	reducedColors = false;
end

n_marker = length(marker_table);
n_color = extendedColorTable([], reducedColors);
n_line = length(linestyle_table);

n_plot = length(hplot);

if isempty(index)
	index_array = 1:n_plot;
elseif length(index)==1
	index_array = index * ones(1,n_plot);
elseif length(index)==n_plot
	index_array = index;
else
	error('Index must be a vector of length 0 (void vector), 1 (scalar), n_plot');
end

for i_plot = 1:n_plot

	index = index_array(i_plot);

	if selectmajor == 1
		i_color = putInside(index, n_color);
		i_marker = putInside(floor(index/n_color) + 1, n_marker);
		i_line = putInside(floor(i_marker/n_marker) + 1, n_line);
	elseif selectmajor == 2
		i_marker = putInside(index, n_marker);
		i_color = floor(index/n_marker) + 1;
		i_line = floor(index/n_line) + 1;
	end

	set(hplot(i_plot), 'Color', extendedColorTable(i_color, reducedColors));
	set(hplot(i_plot), 'Marker', marker_table{i_marker});
end

return


function out = putInside(in, n)

	out = in - floor((in-1)/n)*n;

return
