function [] = writeMKAERO1(fid, Mvect, kvect)
%
%
%
%-------------------------------------------------------------------------------
% 12-09-2016
%

void = '        ';

nM = length(Mvect);

nmka = ceil(length(kvect)/8);

for j = 1:nmka
	fprintf(fid,'$\n');
	fprintf(fid,'%s', str2char8('MKAERO1','l'));
	for ii = 1:8
		if ii <= nM
			fprintf(fid, '%s', num2char8(Mvect(ii)));
		else
			fprintf(fid, '%s', void);
		end
	end
	fprintf(fid, '+MKA%d\n', j);

	fprintf(fid, '%s', str2char8(['+MKA', num2str(j)], 'l'));

	j1 = (j-1)*8 + 1;
	j2 = min(j*8, length(kvect));

	k_inner = kvect(j1:j2);

	for i = 1:length(k_inner)

		fprintf(fid,'%s', num2char8(k_inner(i)));

	end
	fprintf(fid, '\n');
end





return
