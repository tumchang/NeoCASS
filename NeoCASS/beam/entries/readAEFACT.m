function [SID, List, k, NAME, ReadAnotherLine] = ReadAEFACT(fid, NAME, k)
%
%
%
%-------------------------------------------------------------------------------
% 16-06-2014
%

chars_in_field = 8;
fields_in_line = 10;

SID = str2num(GetField(NAME,2));
List = zeros(150, 1);

n0 = 2;
n1 = 8;
n_fields = ceil(length(NAME)/chars_in_field) - n0;
n_el = min(n_fields, 9-n0);
n_tot = 0;

% If the first line is full read another line
GoOn = n_fields >= n_el;

for i = 1:n_el
	List(n_tot+i) = str2num(GetField(NAME,n0+i));
end
n_tot = n_tot + n_el;

% This become false only if a new line is read but ContEntry==false
ReadAnotherLine = true;

while GoOn
	[ContEntry, k, NAME] = IsContinuationEntry(fid, k);

	if ContEntry

		n_fields = ceil(length(NAME)/chars_in_field) - 1;
		n_el = min(n_fields, n1);

		GoOn = n_fields >= n_el;

		for i = 1:n_el
			List(n_tot+i) = str2num(GetField(NAME, i+1));
		end
		n_tot = n_tot + n_el;

	else
		GoOn = false;
		ReadAnotherLine = false;
	end

end

List = List(1:n_tot);

return
%*******************************************************************************
