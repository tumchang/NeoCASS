function Res = getSystemTF_ss(ssmodelArray, varargin)
%
%
%
%
%
%
%
%-----------------------------------------------------------------------
% 07-07-2016
%

global dyn_model


% Check input model: aerodynamic model vs. aeroelastic model
isAeroModel = isfield(ssmodelArray, 'model');

if isAeroModel
	beam_model = dyn_model.beam;

	fid = beam_model.Param.FID;

	isGust = ~isempty(beam_model.Gust.ID);
	isContr = ~isempty(beam_model.Surfdef.ID);
	isLoad  = ~isempty(beam_model.Dextload.ID);

	% Assembly total aero model
	inputList = {'j'};
	outputList = {'j'};
	if isGust;  inputList = [inputList, 'g']; end
	if isContr; inputList = [inputList, 'c']; outputList = [outputList, 'h']; end
	ssmodel = assemblySSmodel(ssmodelArray, inputList, outputList);


	if ~isGust && ~isContr && ~isLoad
		fprintf(fid,'\n No input force defined. Solution ended.\n');
		return;
	end
	%
	%
	if ~beam_model.Param.SOL == 146 
		error('\n SOL 146 must be specified in input file.\n');
	end


	% Initialize time values
	%
	VREF = beam_model.Param.VREF;
	RHOREF = beam_model.Param.RHOREF;
	RHO_VG = beam_model.Param.RHO_VG;
	MREF = beam_model.Param.MACH;
	qinfty = 0.5*RHOREF*VREF^2;
	fprintf(fid,'\n'); 
	fprintf(fid,' - Reference flight speed:     %g m/s.\n',   VREF); 
	fprintf(fid,' - Reference dynamic pressure: %g Pa.\n',    qinfty); 
	fprintf(fid,' - Reference density:          %g Kg/m3.\n', RHOREF); 
	fprintf(fid,' - Reference Mach number:      %g.\n',       MREF); 
	MINDEX = find(MREF == dyn_model.dlm.aero.M);
	if (isempty(MINDEX))
		fprintf(fid,' ### Warning: The required Mach %g is not within the aerodynamic dabatase.\n', MREF); 
		mdiff = dyn_model.dlm.aero.M-MREF; mdiff = sqrt(mdiff.*mdiff); [dummy, MINDEX] = min(mdiff); 
		fprintf(fid,'              All aero data will be extrapolated to the closest value available of %g.\n', ...
		        dyn_model.dlm.aero.M(MINDEX)); 
	end

	cref = dyn_model.dlm.aero.cref;
	bref = beam_model.Aero.ref.b_ref;
	sref = beam_model.Aero.ref.S_ref;
	MODACC = beam_model.Param.MODACC;

	fprintf(fid,'\n'); 
	fprintf(fid,' - Reference chord:    %g m.\n', cref); 
	fprintf(fid,' - Reference span:     %g m.\n', bref); 
	fprintf(fid,' - Reference surface:  %g m2.\n', sref); 
	if (MODACC == 0)
		fprintf(fid,' - Acceleration modes required.\n'); 
	end

	ssAEmodel = getAEmodel(ssmodel, 'Vinf', VREF);

else

	ssAEmodel = ssmodelArray;
	fid = 1;

end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Frequency step
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Df   = 0;
Fmax = 0;

% Check user defined inputs
if nargin > 0
	PARAM = varargin;
	for n=1:2:length(PARAM);
		switch PARAM{n}
		case 'Fmax'
			Fmax = PARAM{n+1};
			fprintf(fid,' - User defined frequency range Fmax: %g Hz.\n', Fmax);
		case 'Df'
			Df = PARAM{n+1};
			fprintf(fid,' - User defined frequency step Df: %g Hz.\n', Df);
		otherwise
			error('Unknown input parameter name, valid parameter names are ''Fmax'' and ''Df''.');
		end
	end
end
%
fprintf(fid,'\n');
fprintf(fid,'\n');

if Fmax>0
	fprintf(fid,' - Max frequency FMAX     : %g Hz\n', Fmax);
	if (Df==0)
		fprintf(fid,' - Frequency step         : auto\n');
		Fvect = {0, Fmax};

		defineF = true;

	else
		% Number of frequency steps
		nf = ceil(Fmax/Df);
		Fmax_actual = nf*Df;

		Fvect = (0:nf-1)'*Df;
		Omega = 2*pi * Fvect;

		defineF = false;
		fprintf(fid,' - Frequency step         : %g Hz\n', Df);
	end
else
	fprintf(fid,' - Max frequency FMAX     : auto\n');
	fprintf(fid,' - Frequency step         : auto\n');
	defineF = true;
end

fprintf(fid,'\n');
fprintf(fid,'\n');




%-------------------------------------------------------------------------------
% Frequency response  
%-------------------------------------------------------------------------------

% Get model in matlab/octave ss class
ssmat = convertToSS_neo(ssAEmodel);

if defineF
	[freqResp, Omega] = freqresp(ssmat);
	Fvect = Omega/2/pi;
	nf = length(Fvect);
else
	[freqResp] = freqresp(ssmat, Omega);
end

%-------------------------------------------------------------------------------
% Process input derivatives
%-------------------------------------------------------------------------------

inputName             = ssmat.inputName;
inputName_independent = ssmat.inputName;

nInputs  = size(ssAEmodel.B,2);
nOutputs = size(ssAEmodel.C,1);

nIndependent = 0;
derivativeTable = zeros(nInputs,3);

% Loop on all inputs, if derivatives exists merge them
for iInput = 1:nInputs

	name = inputName{iInput};

	derivativePos = 0;
	baseName = name;

	pos1 = strfind(name, '-dot');
	pos2 = strfind(name, '-ddot');
	if ~isempty(pos1)
		derivativePos = 1;
		baseName = name(1:pos1(1)-1);
	elseif ~isempty(pos2)
		derivativePos = 2;
		baseName = name(1:pos2(1)-1);
	end

	% Check if the baseName has been already found
	alreadyFound = false;
	for iIndependent = 1:nIndependent
		if strcmp(inputName_independent{iIndependent}, baseName)
			alreadyFound = true;
			break;
		end
	end

	if alreadyFound
		inputPosition = iIndependent;
	else
		nIndependent = nIndependent + 1;
		inputName_independent{nIndependent} = baseName;
		inputPosition = nIndependent;
	end

	derivativeTable(iInput, derivativePos+1) = inputPosition;

end

inputName_independent = inputName_independent(1:nIndependent);

% Update input groups
fieldList = fieldnames(ssmat.inputGroup);
inputGroup = [];
sortingTable = sum(derivativeTable,2);
for iGroup = 1:length(fieldList);
	position = getfield(ssmat.inputGroup, fieldList{iGroup});
	inputGroup = setfield(inputGroup, fieldList{iGroup}, unique(sortingTable(position)));
end


jomMat = permute(reshape(1j*Omega,  [nf,1]), [2,3,1]);
om2Mat = permute(reshape(-Omega.^2, [nf,1]), [2,3,1]);

positionList = zeros(nIndependent,1);

for iInput = 1:nIndependent

	H = zeros(nOutputs,nInputs,nf);

	pos0 = find(derivativeTable(:,1)==iInput);
	pos1 = find(derivativeTable(:,2)==iInput);
	pos2 = find(derivativeTable(:,3)==iInput);

	if ~isempty(pos1)
		freqResp(:,pos1,:) = bsxfun(@times, freqResp(:,pos1,:), jomMat);
	end

	if ~isempty(pos2)
		freqResp(:,pos2,:) = bsxfun(@times, freqResp(:,pos2,:), om2Mat);
	end

	position = min([pos0,pos1,pos2]);

	freqResp(:,position,:) = sum(freqResp(:,[pos0,pos1,pos2],:),2);

	positionList(iInput) = position;

end



%-------------------------------------------------------------------------------
% Save model data
%-------------------------------------------------------------------------------
Res.Fvect = Fvect;

Res.inputName = inputName_independent;
Res.inputGroup = inputGroup;

Res.outputName  = ssmat.outputName;
Res.outputGroup = ssmat.outputGroup;

Res.freqResp = freqResp(:,positionList,:);


return
