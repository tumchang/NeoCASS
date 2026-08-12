function [] = writeRBE2(fid, EID, GN, CM, GMvect)
%
%
%
%-------------------------------------------------------------------------------
% 13-03-2014
%

n1 = 5;
d = 8;
n = length(GMvect);

void = '        ';

fprintf(fid, '%s%s%s%s', str2char8('RBE2','l'), int2char8(EID), ...
                         int2char8(GN), int2char8(CM));

for i = 1:n
	fprintf(fid,'%s', int2char8(GMvect(i)));
	if ((i == n1) || ((i-n1)/d == round((i-n1)/d))) && (i < n)
		fprintf(fid,'\n');
		fprintf(fid,'%s', void);
	end
end
fprintf(fid, '\n');


return
