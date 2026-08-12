function [] = writeSET_neo(fid, ID, valueList)
%
%
%
%
%-------------------------------------------------------------------------------
% 27-07-2016
%











void = '        ';

n1 = 7;

nValues = length(valueList);

string = ['SET ', num2str(ID), ' = '];

fprintf(fid,'%s', str2char8(string, 'l'));

% All in a line
for iValue = 1:nValues
	fprintf(fid,'%s', int2char8(valueList(iValue)));
end
fprintf(fid, '\n');














return
