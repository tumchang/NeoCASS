function [isContinuationEntry, k, lineString] = getContinuationEntry(fid, k)
%
%
%
%-------------------------------------------------------------------------------
% 12-05-2014 v1.0
% 22-12-2014 v1.1
% 22-10-2015 v1.2
%

[lineString, k, endOfFile] = readLine(fid, k, false);

if endOfFile
	isContinuationEntry = false;
else
	isContinuationEntry =    strcmp(lineString(1), '+') ...
	                      || strcmp(lineString(1), ' ') ...
	                      || strcmp(lineString(1), '*') ...
	                      || strcmp(lineString(1), ',');
end


return
%*******************************************************************************
