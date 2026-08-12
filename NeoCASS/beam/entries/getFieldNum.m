function num = getFieldNum(fieldData, pos, default_value)
%
%
%
%-------------------------------------------------------------------------------
%

field = fieldData{pos};


if ~isempty(field)
	field = strtrim(field);
	exp_pos = find(field(2:end)=='+' | field(2:end)=='-') + 1;

	if length(exp_pos)==1
		already_exponent = find('eEdD'==field(exp_pos-1));

		if isempty(already_exponent)
			field = [field(1:exp_pos-1), 'e', field(exp_pos:end)];
		end

	elseif length(exp_pos)>1
		error('More than one exponent found on the same field');
	end

	num = str2num(field);

	if isempty(num)
		num = default_value;
	end
else
	num = default_value;
end









return
