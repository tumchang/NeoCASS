function [SID, G, C, A, k, lineString, ReadAnotherLine] = readMPC(fid, lineString, k)
%
%
%-------------------------------------------------------------------------------
% 31-08-2017
%

[lineData, k, longFormat] = getLine(fid, lineString, k);

SID  = getFieldNum(lineData,2);

iPoint = 0;
G = [];
C = [];
A = [];

ReadAnotherLine = true;

positionInLine = 2;
anotherPoint = ~isempty(getFieldNum(lineData,positionInLine+1));

while anotherPoint
	iPoint = iPoint + 1;
	G(iPoint) = getFieldNum(lineData, positionInLine + 1);
	C(iPoint) = getFieldNum(lineData, positionInLine + 2);
	A(iPoint) = getFieldNum(lineData, positionInLine + 3);

	positionInLine = positionInLine + 3;

	if positionInLine == 8
		[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);
		if ~isContinuationEntry
			ReadAnotherLine = false;
			return
		end
		[lineData, k, longFormat] = getLine(fid, lineString, k);
		positionInLine = 2;
	end

	anotherPoint = ~isempty(getFieldNum(lineData,positionInLine+1));
end


return
%*******************************************************************************
