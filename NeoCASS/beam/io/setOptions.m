function outOpt = setOptions(baseOpt, inputOpt, behaviour)
%
%
% 12-10-2017
%

if nargin==2
	behaviour = 'ignore';
end

if ~isstruct(inputOpt)
	error('inputOpt must be a structure')
end

switch behaviour
case 'error'
	missingFun = @(name) error('Field %s not recognised', name);
case 'warning'
	missingFun = @(name) fprintf('Warning ! field %s not recognised, skipped', name);
case 'ignore'
	missingFun = @(name) true;
otherwise
	error('Wrong value for parameter ''behaviour''');
end

fieldNamesBase = fieldnames(baseOpt);

fieldNamesInput = fieldnames(inputOpt);

outOpt = baseOpt;

for iField = 1:length(fieldNamesInput)
	name = fieldNamesInput{iField};
	if any(strcmp(fieldNamesBase, name))
		field = getfield(inputOpt, name);
		outOpt = setfield(outOpt, name, field);
	else
		missingFun(name);
	end
end



return
