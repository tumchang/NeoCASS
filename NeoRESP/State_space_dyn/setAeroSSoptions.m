function opt = setAeroSSoptions(inOpt, varargin)
%
% opt = setAeroSSoptions([], optName, optValue, ...)
% opt = setAeroSSoptions(inOpt, optName, optValue, ...)
%
%  Generate an option structure for the aerodynamic state-space model generation
%  The input option structure can either be empty (a new structure is generated)
%  or an already existent structure that will be updated.
% 
% setAeroSSoptions('help')
%     Display all available options, with description
%
%-------------------------------------------------------------------------------
% 28-06-2016
%
if nargin == 0
	inOpt = 'help';
end

if isempty(inOpt) || ischar(inOpt)

	descr = {};
	iDescr = 1;

	opt.input  = {'modal'};    descr{iDescr} = 'Input to aerodynamic system (''modal'', ''gust'', ''control'')';        iDescr = iDescr+1;
	opt.output = {'modal'};    descr{iDescr} = 'Output from aerodynamic system (''modal'')';                            iDescr = iDescr+1;

	opt.selIn  = {};           descr{iDescr} = 'Select among input variables';        iDescr = iDescr+1;
	opt.selOu  = {};           descr{iDescr} = 'Select among output variables';                            iDescr = iDescr+1;

	opt.mach = [];             descr{iDescr} = 'Selection of Mach number';                                              iDescr = iDescr+1;
	opt.kvect = [];            descr{iDescr} = 'Selection of reduced frequencies (interpolation performed)';                                              iDescr = iDescr+1;

	opt.method = 'mfd';        descr{iDescr} = 'Method for generation of the state space model (''mfd'', ''qs'')';      iDescr = iDescr+1;


	opt.mfdOrder    = 2;       descr{iDescr} = 'MFD order (2)';                                                         iDescr = iDescr+1;
	opt.mfdAlg      = 2;       descr{iDescr} = 'MFD algorithm (2)';                                                     iDescr = iDescr+1;
	opt.mfdSide     = 'rmfd';  descr{iDescr} = 'left or right MFD (''rmfd'', ''lmfd'') Used for reduced model';         iDescr = iDescr+1;
	opt.mfdWeight   = 100;     descr{iDescr} = 'weight to enforce low frequency fitting (100) Used for reduced model';  iDescr = iDescr+1;
	opt.mfdResOrder = 2;       descr{iDescr} = 'order of residualization (2) automatically set to 2 with ''lmfd''';     iDescr = iDescr+1;
	opt.mfdRollOff  = 2;       descr{iDescr} = 'roll off for discrete gust (2) (not used)';                             iDescr = iDescr+1;

	opt.LMtau     = 1e-1;      descr{iDescr} = 'tau: starting value for LM damping';                                    iDescr = iDescr+1;
	opt.LMgradTol = 1e-9;      descr{iDescr} = 'tolerance on gradient'; iDescr = iDescr+1;
	opt.LMsolTol  = 1e-9;      descr{iDescr} = 'tolerance on solution variation'; iDescr = iDescr+1;
	opt.LMmaxIter = 10;        descr{iDescr} = 'Max num of iterations'; iDescr = iDescr+1;

	opt.eigThres = -1e-4;      descr{iDescr} = 'threshold value for the eigenvalues real part'; iDescr = iDescr+1;
	opt.eigMeth  = 'eigshift'; descr{iDescr} = 'method for enforce stability (''eigshift'', ''polesplace'')'; iDescr = iDescr+1;
	opt.eigType  = 'bound';    descr{iDescr} = 'target poles (''bound'', ''flip'')'; iDescr = iDescr+1;
	opt.eigBound = -1e-2;      descr{iDescr} = 'bound value '; iDescr = iDescr+1;

	opt.algROM = 'hankel';     descr{iDescr} = 'Model reduction algorithms: ''balance'', ''hankel'', ''schur'', ''bst'''; iDescr = iDescr+1;
	opt.orderROM = [];         descr{iDescr} = 'Order for model reduction, if empty it will be requested during execution'; iDescr = iDescr+1;

	opt.useGUI = false;        descr{iDescr} = 'Use the gui for identification                                         '; iDescr = iDescr+1;

	opt.restartFile = '';      descr{iDescr} = 'Name of file used for restart'; iDescr = iDescr+1;

	opt.kmin = 0;              descr{iDescr} = 'Minimum reduced frequency in QS approximation'; iDescr = iDescr+1;
	opt.kmax = 1;              descr{iDescr} = 'Maximum reduced frequency in QS approximation'; iDescr = iDescr+1;

	opt.SnodalLoad = [];       descr{iDescr} = 'Combination matrix for nodal loads (default: identity matrix)'; iDescr = iDescr+1;
	opt.SnodalName = [];       descr{iDescr} = 'Names of outputs related to load recovery                    '; iDescr = iDescr+1;

elseif isstruct(inOpt)
	opt = inOpt;
else
	error('Unrecognized type for parameter ''inOpt''');
end

if isstr(inOpt)
	switch inOpt
	case 'help'
		% Print all the available options, with the description
		fieldList = fieldnames(opt);
		nchar = 12;
		formatStr = ['\t%', num2str(nchar), 's  :  %s\n'];

		fprintf('Available options for the ss model generation:\n');

		for iField = 1:length(fieldList)
			fprintf(formatStr, fieldList{iField}, descr{iField});
		end
		return
	end
end


n_values = length(varargin)/2;


if n_values ~= floor(n_values)
	error('Wrong number of arguments');
end

% Get all fields in opt struct
fieldList = fieldnames(opt);

for i_values = 1:n_values
	fieldname = varargin{(i_values-1)*2 + 1};
	value     = varargin{(i_values-1)*2 + 2};

	% Check on lowercase names
	position = find(strcmp(lower(fieldList), lower(fieldname)));

	if ~isempty(position)
		opt = setfield(opt, fieldList{position}, value);
	else

		fprintf('WARNING: Unrecognized option ''%s''\n', fieldname);
		fprintf('         skipping ...\n');
	end
end















return
