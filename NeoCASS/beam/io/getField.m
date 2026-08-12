function [field] = GetField(NAME, pos, chars_in_field)
%
% field = GetField(NAME, pos, chars_in_field)
%
% default value for chars_in field is 8
%
%-------------------------------------------------------------------------------
% 13-05-2014
% 20-10-2015 free-format supported
%

comma_position = find(NAME==',');

if isempty(comma_position) % Fixed format
	if nargin < 3
		chars_in_field = 8;
	end
	fields_in_line = 10;

	pos1 = (pos-1)*chars_in_field + 1;
	pos2 = pos*chars_in_field;

	if length(NAME) < pos1
		field = [];
	else
		field = NAME(pos1:min(pos2,length(NAME)));
	end

else % Free format
	comma_position = [0, comma_position, length(NAME)+1];

	if pos > length(comma_position)-1
		field = [];
	else
		pos1 = comma_position(pos) + 1;
		pos2 = comma_position(pos+1) - 1;

		field = NAME(pos1:pos2);
	end
end

return
