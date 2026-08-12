function [TID, XAXIS, YAXIS, X, Y, lineString, k, ReadAnotherLine] = readTABLED1(fid, lineString, k)
%
%
%
%-------------------------------------------------------------------------------
%
%

[lineData, k, longFormat] = getLine(fid, lineString, k);


TID = getFieldNum(lineData,2, 0);

XAXIS = getFieldStr(lineData,3, 'LINEAR');
YAXIS = getFieldStr(lineData,4, 'LINEAR');


% Try to read second line
[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);

if ~isContinuationEntry
	error('Error in reading TABLED1 with id %d: continuation entry missing', TID);
end

% Dummy initialization
X = zeros(150,1);
Y = zeros(150,1);

nPoints = 0;

continueReading = true;

while continueReading

	[lineData, k, longFormat] = getLine(fid, lineString, k);

	if longFormat
		nPointsInLine = 2;
	else
		nPointsInLine = 4;
	end

	for iPoints = 1:nPointsInLine

		% Get the points and stop if ENDT or an empty field is found
		field1 = lineData{1+(iPoints-1)*2 + 1};
		field2 = lineData{1+(iPoints-1)*2 + 2};
		if isempty(field1)
			fprintf('Warning : empty field in TABLED1 %d, assumed as ENDT\n', TID);
			endFound = true;
			break;
		elseif strcmp(strtrim(field1), 'ENDT');
			endFound = true;
			break;
		elseif isempty(field2)
			error('Y data corresponding to X=%s missing for TABLED1 %d', field1, TID)
		else
			nPoints = nPoints + 1;
			X(nPoints) = getFieldNum({field1}, 1, 0);
			Y(nPoints) = getFieldNum({field2}, 1, 0);
			endFound = false;
		end
	end

	if endFound
		continueReading = false;
		ReadAnotherLine = true;
	else
		[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);
		if ~isContinuationEntry
			fprintf('Warning : TABLED with ID %d terminated without ENDT\n', TID);
			continueReading = false;
			ReadAnotherLine = false;
		end
	end

end

X = X(1:nPoints);
Y = Y(1:nPoints);

delta = X(2:end) - X(1:end-1);
if any(delta<0)
	error('(TABLED1 with ID %d) the X coordinates cannot decrease', TID);
end


return
%*******************************************************************************
