function [CID, RID, NasCORD2Rmat, k] = readCORD2R(fid, lineString, k)
%
%
% 16-11-2017
%

[lineData, k, longFormat] = getLine(fid, lineString, k);

CID = getFieldNum(lineData,2, 0);
RID = getFieldNum(lineData,3, 0);

NasCORD2Rmat = zeros(3,3);

% First row: origin
NasCORD2Rmat(1,1) = getFieldNum(lineData,4,0);
NasCORD2Rmat(1,2) = getFieldNum(lineData,5,0);
NasCORD2Rmat(1,3) = getFieldNum(lineData,6,0);

% Second row: z axis
NasCORD2Rmat(2,1) = getFieldNum(lineData,7,0);
NasCORD2Rmat(2,2) = getFieldNum(lineData,8,0);
NasCORD2Rmat(2,3) = getFieldNum(lineData,9,0);


% Try to read second line
[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);

if ~isContinuationEntry
	error('Error in reading CORD2R with id %d: continuation entry missing', CID);
end

[lineData, k, longFormat] = getLine(fid, lineString, k);


% Third row: xz plane
NasCORD2Rmat(3,1) = getFieldNum(lineData,2, 0);
NasCORD2Rmat(3,2) = getFieldNum(lineData,3, 0);
NasCORD2Rmat(3,3) = getFieldNum(lineData,4, 0);



return
