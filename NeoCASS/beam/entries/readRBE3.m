function [EID, Gref, Cref, W, CN, GN, alpha, k, lineString, ReadAnotherLine] = readRBE3(fid, lineString, k)
%
%
% TODO : add UM part
%
%-------------------------------------------------------------------------------
% 26-07-2016
%

[lineData, k, longFormat] = getLine(fid, lineString, k);

EID  = getFieldNum(lineData,2);
Gref = getFieldNum(lineData,4);
Cref = getFieldNum(lineData,5);

W = [];
CN = [];
GN = {};
GM = [];
CM = [];
alpha = [];

iSet = 0;

positionInLine = 6;

ReadAnotherLine = true;

field = getFieldStr(lineData,positionInLine);
newSetCondition = find(field=='.');

if newSetCondition
	iSet = iSet + 1;
	W(iSet) = str2num(field);

	if positionInLine == 9
		[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);
		if ~isContinuationEntry
			error('Incomplete definition of RBE3 with ID %d', EID);
		end
		[lineData, k, longFormat] = getLine(fid, lineString, k);
		positionInLine = 2;
	else
		positionInLine = positionInLine + 1;
	end

	CN(iSet) = getFieldNum(lineData,positionInLine);

	if positionInLine == 9
		[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);
		if ~isContinuationEntry
			error('Incomplete definition of RBE3 with ID %d', EID);
		end
		[lineData, k, longFormat] = getLine(fid, lineString, k);
		positionInLine = 2;
	else
		positionInLine = positionInLine + 1;
	end

	lookForNodes = true;
	iNode = 0;
	nodeList = [];

	while lookForNodes
		for iField = positionInLine:9
			field = getFieldStr(lineData,iField,'');
			% Check field only if not empty, ignore empty fields
			if ~isempty(field)
				% New set found
				if find(field=='.');
					newSetCondition = true;
					lookForNodes = false;
					break
				elseif strcmp(field, 'UM')
					newSetCondition = false;
					lookForNodes = false;
					break
				else % Node found
					iNode = iNode + 1;
					nodeList(iNode) = str2num(field);
				end
			end
		end

		if iField == 9
			% Check the following line
			[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);
			[lineData, k, longFormat] = getLine(fid, lineString, k);


			% Condition for reading the line
			condition = isContinuationEntry && ~isempty(lineString);

			if condition
				lookForNodes = true;
				positionInLine = 2;
			else
				newSetCondition = false;
				ReadAnotherLine = false;
				break
			end
		end
	end

	GN{iSet} = nodeList;

end


return
%*******************************************************************************
