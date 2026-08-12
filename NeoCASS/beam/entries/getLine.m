function [lineData, k, longFormat] = getLine(fid, lineString, k);
%
%
% 07-08-2017
%

if isempty(lineString)
	k = k + 1;
	lineString = fgetl(fid);

end

longFormat = any(lineString=='*');
freeFormat = any(lineString==',');

% Remove comments
posComment = find(lineString=='$');
if ~isempty(posComment)
	lineString = lineString(1:posComment-1);
end

if ~freeFormat
	if length(lineString)<80
		% Expand length to 80 characters
		lineString = [lineString, blanks(80-length(lineString))];
	elseif length(lineString)>80
		% Limit to 80 characters
		lineString = lineString(1:80);
	end
end

if longFormat % Only 6 fields can be found
	nFields = 6;
	lineData = cell(nFields,1);

	if ~freeFormat
		fieldLength = 16;
		lineData{1} = lineString(1:8); pos = 8;
		for iField = 1:4
			lineData{iField + 1} = lineString(pos + (1:fieldLength));
			pos = pos + fieldLength;
		end
		lineData{6} = lineString(73:80);
	end

else
	nFields = 10;
	lineData = cell(nFields,1);

	if ~freeFormat
		fieldLength = 8;
		pos = 0;
		for iField = 1:10
			lineData{iField} = lineString(pos + (1:fieldLength));
			pos = pos + fieldLength;
		end
	end

end


if freeFormat
	comma_position = find(lineString==',');
	comma_position = [0, comma_position, length(lineString)+1];

	for iField = 1:min(nFields, length(comma_position)-1);
		pos1 = comma_position(iField)   + 1;
		pos2 = comma_position(iField+1) - 1;

		lineData{iField} = lineString(pos1:pos2);
	end
end






return
