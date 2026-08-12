function [IncludeList] = MergeNeoCASSInput(filename_read, filename_out)
%
% MergeNeoCASSInput(filename, filename_out)
% MergeNeoCASSInput(filename)
%
% Read the nastran input file filename and merges all included
% files in an unique input file with name filename_out.
%
% If filename_out is not provided as input the default action
% is to create a file with the same name of filename (but in
% lowercase), placed in the same directory, and with 
% extension '.mod'.
%
%
%
%-------------------------------------------------------------------------------
% 17-12-2014 v1.0
% 08-04-2016 v2.2 : from MergeNeoCASSInput v2.2
%

% default choice
if nargin == 1
	default_name = true;
else
	default_name = false;
end


fprintf(1, 'Running function MergeNeoCASSInput:\n\n');


n_symbol = 0;
symboldata.names = {};
symboldata.string = {};

% All included files are defined with respect to the main file
delimiter = '/'; % TODO : automatic choice of delimiter
StartDir = find(filename_read==delimiter);
if ~isempty(StartDir)
	StartDir = filename_read(1:StartDir(end));
	pos1 = length(StartDir);
else
	StartDir = './';
	pos1 = 0;
end
StartFile = filename_read;

if default_name
	name_red = filename_read(pos1+1:end);
	find_dot = find(name_red=='.');
	filename_out = [StartDir, '/', lower(name_red(1:find_dot(end)-1)), '.mod'];
end

% Open new NASTRAN file
fid_write = my_openfile_write(filename_out);

% Open NASTRAN input file
fid_read = my_openfile(filename_read);

k = 1;
Continue = true;
WriteStart = false;

n_include = 0;
IncludeList = {};

n_opened = 0;
OpenedList = {};
LineList = [];

while Continue

	[NAME, k] = readLine(fid_read, k, false);


	if ~isempty(NAME)
		switch strtok(getField(NAME,1));

		case 'INCLUDE'
			n_include = n_include + 1;
			name_file_inc = strtok(NAME(8:end));
			% Here is the only difference wrt NASTRAN: filename is not within apexes and it is in one line
			name_file_inc = strtok(name_file_inc, '$');
			name_file_inc = strtrim(name_file_inc);

			IncludeList{n_include} = name_file_inc;

			% Save data of the opened file
			if n_opened > 0
				OpenedList(2:n_opened+1) = OpenedList(1:n_opened);
				LineList(2:n_opened+1) = LineList(1:n_opened);
			end

			n_opened = n_opened + 1;
			OpenedList{1} = filename_read;
			LineList(1) = k;

			% Close the opened file
			my_closefile(fid_read, filename_read);

			% Start reading from the included file
			filename_read = [StartDir, name_file_inc];
			fid_read = my_openfile(filename_read);
			k = 1;

			fprintf(fid_write, '$\n');
			fprintf(fid_write, '$#########################################################\n');
			fprintf(fid_write, '$ Begin of included file  %s\n', filename_read);
			fprintf(fid_write, '$#########################################################\n');
			fprintf(fid_write, '$\n');


		case '$#SYMBOL'
			n_symbol = n_symbol + 1;
			eqpos = find(NAME=='=');
			symboldata.names{n_symbol} = NAME(eqpos(1)+1:eqpos(2)-1);
			symboldata.string{n_symbol} = deblank(NAME(eqpos(2)+1:end));

		otherwise
			fprintf(fid_write, '%s\n', NAME);
		end
	end

	% End of file reached: close file and search for already opened files
	if feof(fid_read)

		% Close file
		my_closefile(fid_read, filename_read);

		if n_opened > 0

			fprintf(fid_write, '$\n');
			fprintf(fid_write, '$#########################################################\n');
			fprintf(fid_write, '$ End of included file  %s\n', filename_read);
			fprintf(fid_write, '$#########################################################\n');
			fprintf(fid_write, '$\n');

			% Resume reading from previous file
			filename_read = OpenedList{1};

			% Open file
			fid_read = my_openfile(filename_read);
			k = LineList(1);

			% Resume from last point
			for i_line = 1:k-1
				NAME = readLine(fid_read, 1, false);
			end

			% Remove file from the list of pending files
			if n_opened > 1
				OpenedList(1:n_opened-1) = OpenedList(2:n_opened);
				LineList(1:n_opened-1) = LineList(2:n_opened);
			end
			n_opened = n_opened - 1;

			Continue = true;
		else
			Continue = false;
		end
	else
		Continue = true;
	end
end


my_closefile_write(fid_write,filename_out);

fprintf(1, 'End of function MergeNeoCASSInput\n');
return
%*******************************************************************************



%*******************************************************************************
function fid = my_openfile(filename)

fid = fopen(filename, 'r');

fprintf(1, '\tOpening file:   %s\n', filename);

return
%*******************************************************************************


%*******************************************************************************
function [] = my_closefile(fid, filename)

% Close file
status = fclose(fid);

if status == 0
	fprintf(1, 'file %s closed\n', filename);
elseif status == -1
	fprintf(1, '\n\t### WARNING file:   %s   not closed\n', filename);
end

return
%*******************************************************************************


%*******************************************************************************
function fid = my_openfile_write(filename)

fid = fopen(filename, 'w');

fprintf(1, '\tCreating file:   %s\n', filename);

return
%*******************************************************************************


%*******************************************************************************
function [] = my_closefile_write(fid, filename)

% Close file
status = fclose(fid);

if status == 0
	fprintf(1, 'file %s closed\n', filename);
elseif status == -1
	fprintf(1, '\n\t### WARNING file:   %s   not closed\n', filename);
end

return
%*******************************************************************************


