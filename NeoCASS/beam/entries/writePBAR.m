function [] = writePBAR(fid, PID, MID, A, I, J, NSM, Ctable, K)
%
% [] = writePBAR(fid, PID, MID, A, I, J, NSM, Ctable, K)
%
%-------------------------------------------------------------------------------
% 20-01-2015
%

isnsm = exist('NSM', 'var') && ~isempty(NSM);
isk = exist('K', 'var') && ~isempty(K) && max(abs(K))>0;
isI12 = length(I)==3 && I(3)~=0;
isC = exist('Ctable', 'var') && ~isempty(Ctable) && max(max(abs(Ctable)))>0;

writethirdline = isk || isI12;
writesecondline = isC || writethirdline;

void = '        ';

if isnsm
	NSMstr = dbl2char8(NSM);
else
	NSMstr = void;
end

fprintf(fid, '%s%s%s%s%s%s%s%s\n', ...
             str2char8('PBAR','l'), int2char8(PID), ...
             int2char8(MID), dbl2char8(A), ...
             dbl2char8(I(1)), dbl2char8(I(2)), ...
             dbl2char8(J), NSMstr);

if writesecondline

	if ~isC
		Ctable = zeros(4,2);
	end

	fprintf(fid, '%s%s%s%s%s%s%s%s%s\n', void, ...
	             dbl2char8(Ctable(1,1)), dbl2char8(Ctable(1,2)), ...
	             dbl2char8(Ctable(2,1)), dbl2char8(Ctable(2,2)), ...
	             dbl2char8(Ctable(3,1)), dbl2char8(Ctable(3,2)), ...
	             dbl2char8(Ctable(4,1)), dbl2char8(Ctable(4,2)));

	if writethirdline
		if isk
			K1str = dbl2char8(K(1));
			K2str = dbl2char8(K(2));
		else
			K1str = void;
			K2str = void;
		end

		if isI12
			I12str = dbl2char8(I(3));
		else
			I12str = void;
		end

		fprintf(fid, '%s%s%s%s\n', void, K1str, K2str, I12str);
	end
end

return
