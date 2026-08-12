function [] = requireVersion(name, version)

[versionString, thisVersion] = get_neocass_version(name);

isSameVersion = strcmp(version, thisVersion);

if ~isSameVersion
	fprintf('Error : the required version is different with respect to the\n');
	fprintf('        version of function init_dyn_model                   \n');
	fprintf('         - Required version : %s\n', version);
	fprintf('         - Function version : %s\n', thisVersion);
	error('aborting');
end




return
