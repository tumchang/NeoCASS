function setSVNversions()
%**************************************************************************
%
%  NeoCASS
%  Next generation Conceptual Aero Structural Sizing
%
%                      Sergio Ricci          <ricci@aero.polimi.it>
%                      Luca Cavagna          <cavagna@aero.polimi.it>
%                      Luca Riccobene        <riccobene@aero.polimi.it>
%                      Alessandro De Gaspari <degaspari@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%**************************************************************************
%
% MODIFICATIONS:
%     DATE        VERS      PROGRAMMER              DESCRIPTION
%     230418      2.2.809   F. Fonte/L.Riccobene    Creation
%
%**************************************************************************
%
% function        setSVNversions()
%
%   DESCRIPTION: Automatic update of the packages version number based on
%                SVN revision. 
%                On Windows system, it needs TortoiseSVN installed, with
%                command line commands enabled. Go to:
%
%                https://tortoisesvn.net/
%
%                and when prompted by the installation GUI select
%                "command line client tools"
%
%                Beforre running this function, update the database
%
%         INPUT: NAME            TYPE       DESCRIPTION
%
%
%        OUTPUT: NAME           TYPE       DESCRIPTION
%
% See also set_neocass_version, get_neocass_version
%**************************************************************************

if ispc
	SVN_EXE = 'C:\"Program Files"\TortoiseSVN\bin\svn.exe';
elseif isunix
	SVN_EXE = 'svn';
else
	error('Only Windows and Linux systems supported');
end

mfile = ['.', filesep];

command = sprintf('%s info %s', SVN_EXE, mfile);
[status,out] = system(command);

% check everything went well:
assert(~status, 'Failed to issue svn command.');

% parse revision from output:
rev = regexp(out, 'Revision: (\d+)', 'tokens', 'once');
% alternatively - depending on which info you really want
% rev = regexp(out, 'Last Changed Rev: (\d+)', 'tokens', 'once');

% Save (old) revision, the one stored in the SVN server, and increase the
% actual by 1
revisionOld = rev{1};
revision = num2str(str2double(rev{1}) + 1);

fprintf('\n');
fprintf(' Updating NeoCASS packages versions according to SVN revision\n');
fprintf('\n');
fprintf(' WARNING: remember to run ''svn update'' before running this function\n');
fprintf('\n');
fprintf(' SVN revision : %s\n', revisionOld);
fprintf('\n');
fprintf(' next SVN revision : %s\n', revision);
fprintf('\n');
fprintf(' WARNING: remember to run ''svn commit'' right after running this function\n');
fprintf('\n');

[~, versionNum] = get_neocass_version('NeoCASS');
versionNum = strsplit(versionNum,'.');
if length(versionNum)==3
	set_neocass_version('NeoCASS', [versionNum{1}, '.', versionNum{2}, '.', revision]);
	disp(get_neocass_version('NeoCASS'));
else
	error('setSVNversions:WrongNeoCASSVersionFromFile',...
	    'Version number is composed by three elements separated by dots');
end

[~, versionNum] = get_neocass_version('NeoRESP');
versionNum = strsplit(versionNum,'.');
if length(versionNum)==3
	set_neocass_version('NeoRESP', [versionNum{1}, '.', versionNum{2}, '.', revision]);
	disp(get_neocass_version('NeoRESP'));
else
	error('setSVNversions:WrongNeoRESPVersionFromFile',...
	    'Version number is composed by three elements separated by dots');
end

[~, versionNum] = get_neocass_version('XAcBuilder');
versionNum = strsplit(versionNum,'.');
if length(versionNum)==3
	set_neocass_version('XAcBuilder', [versionNum{1}, '.', versionNum{2}, '.', revision]);
	disp(get_neocass_version('XAcBuilder'));
else
	error('setSVNversions:WrongAcBuilderVersionFromFile',...
	    'Version number is composed by three elements separated by dots');
end

