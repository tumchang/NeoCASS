function str = getFieldStr(lineData, pos, default_value)
%
%
%
%-------------------------------------------------------------------------------
% 10-06-2014
%

field = lineData{pos};

if ~isempty(field)
	str = strtok(field);
else
	str = '';
end

if isempty(str)
	str = default_value;
end



return
