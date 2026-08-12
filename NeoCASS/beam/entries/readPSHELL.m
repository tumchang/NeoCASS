function [PID, MID1, T, MID2, Iratio, MID3, TSratio, NSM, k, lineString, ReadAnotherLine] = readPSHELL(fid, lineString, k)
%
% TODO : now it reads only the first line
%
%-------------------------------------------------------------------------------
% 31-03-2015
%

[lineData, k, longFormat] = getLine(fid, lineString, k);

PID  = getFieldNum(lineData,2);
MID1 = getFieldNum(lineData,3);

T = getFieldNum(lineData,4);

MID2    = getFieldNum(lineData,5, 0);
Iratio  = getFieldNum(lineData,6, 1);
MID3    = getFieldNum(lineData,7, 0);
TSratio = getFieldNum(lineData,8, 5/6);
NSM     = getFieldNum(lineData,9, 0);

ReadAnotherLine = true;

return
