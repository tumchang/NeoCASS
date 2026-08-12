function [EID, PID, G, MCID, ZOFF, TFLAG, T, k, lineString, ReadAnotherLine] = readCQUAD4(fid, lineString, k)
%
%
%
%-------------------------------------------------------------------------------
% 13-05-2014
%


[lineData, k, longFormat] = getLine(fid, lineString, k);


EID = getFieldNum(lineData,2);
PID = getFieldNum(lineData,3);

G = zeros(4,1);
G(1) = getFieldNum(lineData, 4, 0);
G(2) = getFieldNum(lineData, 5, 0);
G(3) = getFieldNum(lineData, 6, 0);
G(4) = getFieldNum(lineData, 7, 0);

MCID = getFieldNum(lineData, 8, 0);
ZOFF = getFieldNum(lineData, 9, 0);


% Try to read second line
[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);



TFLAG = 0;
T = zeros(4,1);
if isContinuationEntry
	[lineData, k, longFormat] = getLine(fid, lineString, k);
	TFLAG = GetFieldNum(lineData, 3, 0);
	T(1)  = GetFieldNum(lineData, 4, 1); 
	T(2)  = GetFieldNum(lineData, 5, 1); 
	T(3)  = GetFieldNum(lineData, 6, 1); 
	T(4)  = GetFieldNum(lineData, 7, 1); 
	ReadAnotherLine = true;
else
	ReadAnotherLine = false;
end


return
