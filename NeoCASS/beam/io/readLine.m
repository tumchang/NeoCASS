function [lineString, k, endOfFile] = readLine(fid, k, skipNull);
%
% Valid only for fixed format
%
%-------------------------------------------------------------------------------
% 12-05-2014
%

if nargin==2; skipNull = true; end

lineString = '';

readOneLine = true;

while readOneLine

	lineString = fgetl(fid);
	k = k + 1;

	endOfFile = feof(fid);

	% Stop conditions: 
	% stop if end of file is reached
	% continue if a blank line or a comment line is found
	% always stop if skipNull=false
	if ~skipNull || endOfFile 
		readOneLine = false;
	else
		trimmedLine = strtrim(lineString);
		readOneLine = isempty(trimmedLine) || trimmedLine(1)=='$';
	end

end


return
%*******************************************************************************
