function [name_file_inc, NAME, k] = readINCLUDE_NAS(fid, NAME, k, StartDir, symboldata);

name_file_inc = strtok(NAME(8:end));

stopcondition = strcmp(name_file_inc(end), '''');
line = 0;
nmax = 10;
while ~stopcondition && line<nmax
	[ContEntry, k, NAME] = IsContinuationEntry(fid, k);
	name_file_inc = [name_file_inc, strtrim(NAME)];
	stopcondition = strcmp(name_file_inc(end), '''');
end

if line==nmax
	fprintf('WARNING: End of INCLUDE card not found after %d lines\n', nmax);
	fprintf('         maybe the final '' is missing\n');
	fprintf('         INCLUDE cards cannot be defined in more than %d lines.\n');
	fprintf('         String read:\n');
	fprintf('         %s\n', name_file_inc);
	name_file_inc = [];
	return
end

name_file_inc = name_file_inc(2:end-1);


name_file_inc = CheckSymbol(name_file_inc, symboldata);


% Check whether the included file has a relative or 
% an absolute path
is_absolute =    strcmp(name_file_inc(1),'/') ...
              || strcmp(name_file_inc(1),'~');

if ~is_absolute
	name_file_inc = [StartDir, name_file_inc];
end

return

%*******************************************************************************
function name_out = CheckSymbol(name_in, symboldata)

n_symbol = length(symboldata.names);

% Check for the presence of a symbol in name
can_symbol =    sum(name_in==':') ...
             && n_symbol>0;

if can_symbol

	posdd = find(name_in==':');

	for i_np = 1:length(posdd)
		for i_symbol = 1:n_symbol
			tag = symboldata.names{i_symbol};
			nt = length(tag);
			is_symbol =    posdd(i_np)>nt ...
			            && strcmp(name_in(posdd(i_np)-nt:posdd(i_np)-1), tag);

			if is_symbol
				str = symboldata.string{i_symbol};
				ns = length(str);
				name_in = [name_in(1:posdd(i_np)-nt-1), str, name_in(posdd(i_np)+1:end)];

				posdd(i_np+1:end) = posdd(i_np+1:end) - (nt+1) + ns;
				break;
			end

		end
	end

end

name_out = name_in;


return
%*******************************************************************************
