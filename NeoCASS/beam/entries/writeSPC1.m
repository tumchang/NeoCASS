function [] = writeSPC1(fid, SID, C, Gvect)
%
% WriteNAS_SPC1(fid, SID, C, Gvect)
%
%-------------------------------------------------------------------------------
% 27-05-2014
%


void = '        ';

fprintf(fid, '%s%s%s', str2char8('SPC1','l'), int2char8(SID), int2char8(C));


n = length(Gvect);
n1 = 6;
d = 8;
for i = 1:n
	fprintf(fid,'%s', int2char8(Gvect(i)));
	if ((i == n1) || ((i-n1)/d == round((i-n1)/d))) && (i < n)
		fprintf(fid,'\n');
		fprintf(fid,'%s', void);
	end
end
fprintf(fid, '\n');





return
