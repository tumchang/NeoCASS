function [SSaero, SSopt] = getAeroModel(SSopt, varargin)
%
% SSaero = getAeroModel()
% SSaero = getAeroModel(SSopt)
% SSaero = getAeroModel(SSopt, varargin)
%
% Get a state space approximation of aerodynamic forces.
%
%
%-------------------------------------------------------------------------------
% 28-06-2016
% 19-07-2016 v1.1 bug fixed
% 25-02-2017 v1.2 Nodal forces added
%

global dyn_model

beam_model = dyn_model.beam;

if nargin==0
	SSopt = [];
end

% beam_model = dyn_model.beam;
% fid = beam_model.Param.FID;
% 
% dtpos = find('.' == beam_model.Param.FILE);
% headname = beam_model.Param.FILE(1:dtpos(end)-1);

SSopt = setAeroSSoptions(SSopt, varargin{:});


%-------------------------------------------------------------------------------
% Select system input/output
%-------------------------------------------------------------------------------

recognizedInput = {
                    'j', {'modes', 'Modes', 'modal', 'j'};
                    'g', {'gust', 'Gust', 'g'};
                    'c', {'control', 'Control', 'c'};
                    'd', {'downwash', 'd'};
                   };

recognizedOutput = {
                    'j', {'modes', 'Modes', 'modal', 'j'};
                    'r', {'rigid', 'Rigid', 'r'};
                    'h', {'hingemom', 'Hingemom', 'HingeForce', 'h'};
                    'n', {'nodal', 'nodalForces', 'n'};
                   };

input = [];
output = [];
usedList = [];

for iGroup = 1:size(recognizedInput, 1)
	select = strcmp(SSopt.input, recognizedInput{iGroup,2}{1});
	for iName = 2:length(recognizedInput{iGroup,2})
		select = select | strcmp(SSopt.input, recognizedInput{iGroup,2}{iName});
	end

	used = [];
	position = find(select);
	if ~isempty(position)
		input = setfield(input, recognizedInput{iGroup,1}, true);
		% Set selection
		if ~isempty(SSopt.selIn)
			used = SSopt.selIn{position(1)};
		end
		usedList = setfield(usedList, recognizedInput{iGroup,1}, used);
	else
		input = setfield(input, recognizedInput{iGroup,1}, false);
	end
end
input.used = usedList;
usedList = [];

for iGroup = 1:size(recognizedOutput, 1)
	select = strcmp(SSopt.output, recognizedOutput{iGroup,2}{1});
	for iName = 2:length(recognizedOutput{iGroup,2})
		select = select | strcmp(SSopt.output, recognizedOutput{iGroup,2}{iName});
	end

	used = [];
	position = find(select);
	if ~isempty(position)
		output = setfield(output, recognizedOutput{iGroup,1}, true);
		% Set selection
		if ~isempty(SSopt.selOu)
			used = SSopt.selOu{position(1)};
		end
		usedList = setfield(usedList, recognizedOutput{iGroup,1}, used);
	else
		output = setfield(output, recognizedOutput{iGroup,1}, false);
	end
end
output.used = usedList;


%-------------------------------------------------------------------------------
% Get model dimension
%-------------------------------------------------------------------------------

nInput = 0;
nOutput = 0;

inputGroup = [];
outputGroup = [];

nInputUsed = 0;
nOutputUsed = 0;


% Modal base +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if output.j || input.j || output.r
	% Set definition:
	% i : set of all modes computed from modal analysis
	% j : set of modes used for the computation of aerodynamic matrices Qhh

	ni = size(beam_model.Struct.Mmm,1);

	% Modes used in dlm
	if (isempty(beam_model.Param.MSELECT))
		mbase = beam_model.Struct.ID;
	else
		mbase = beam_model.Param.MSELECT;
	end

	seljFromi = mbase;
	nj = length(seljFromi);

	% Define dimension of modal input
	if input.j
		if isempty(input.used.j)
			input.used.j = 1:nj;
		end

		inputGroup.j = nInput + (1:nj);
		nInput = nInput + nj;
		inputGroupUsed.j = nInputUsed + (1:length(input.used.j));
		nInputUsed = nInputUsed + length(input.used.j);
	end

	% Define dimension of modal output
	if output.j
		if isempty(output.used.j)
			output.used.j = 1:nj;
		end

		outputGroup.j = nOutput + (1:nj);
		nOutput = nOutput + nj;
		outputGroupUsed.j = nOutputUsed + (1:length(output.used.j));
		nOutputUsed = nOutputUsed + length(output.used.j);
	end


	% Find rigid and elastic modes involved            
	seljRigid   = find(seljFromi<=6);
	seljElastic = find(seljFromi>6);

	seljRfromi = seljFromi(seljRigid);
	seljEfromi = seljFromi(seljElastic);

	nRigid   = length(seljRigid  ); % number of rigid modes in UMODES
	nElastic = length(seljElastic); % number of elastic modes in UMODES


	side_mode   = find(seljRfromi == 2);
	plunge_mode = find(seljRfromi == 3);
	roll_mode   = find(seljRfromi == 4);
	pitch_mode  = find(seljRfromi == 5);


	% Scaling matrices
	scaleRigid = diag(diag(1./sqrt(beam_model.Struct.Mmm(seljRfromi, seljRfromi))));
	scaleMatrix_j = blkdiag(scaleRigid, eye(nElastic,nElastic));

	if  input.j; scaleMatrix_jin = scaleMatrix_j( input.used.j, input.used.j); end;
	if output.j; scaleMatrix_jou = scaleMatrix_j(output.used.j,output.used.j); end;

end

% Gust input +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if input.g
	ng = length(beam_model.Gust.ID);
	if ng > 0

		if isempty(input.used.g)
			input.used.g = 1:ng;
		end

		inputGroup.g = nInput + (1:ng);
		nInput = nInput + ng;
		inputGroupUsed.g = nInputUsed + (1:length(input.used.g));
		nInputUsed = nInputUsed + length(input.used.g);


	else
		fprintf('WARNING: gust input selected but not included in the model, skipping\n');
		input.g = false;
	end
end

% Control surface input ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if input.c
	nc = length(beam_model.Surfdef.ID);
	if nc > 0

		if isempty(input.used.c)
			input.used.c = 1:nc;
		end

		inputGroup.c = nInput + (1:nc);
		inputGroupUsed.c = nInputUsed + (1:length(input.used.c));
		nInput = nInput + nc;
		nInputUsed = nInputUsed + length(input.used.c);

	else
		fprintf('WARNING: control surface input selected but not included in the model, skipping\n');
		input.c = false;
	end
end

% Panel downwash input +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if input.d
	nd = beam_model.Aero.lattice_dlm.np;

	if isempty(input.used.d)
		input.used.d = 1:nd;
	end

	inputGroup.d = nInput + (1:nd);
	nInput = nInput + nd;
	inputGroupUsed.d = nInputUsed + (1:length(input.used.d));
	nInputUsed = nInputUsed + length(input.used.d);

end


% Rigid force output +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if output.r
		nr = 5; %length(seljRigid);

		if isempty(output.used.r)
			output.used.r = 1:nr;
		end

		outputGroup.r = nOutput + (1:nr);
		outputGroupUsed.r = nOutputUsed + (1:length(output.used.r));
		nOutput = nOutput + nr;
		nOutputUsed = nOutputUsed + length(output.used.r);

end

% Control surface hinge moment output ++++++++++++++++++++++++++++++++++++++++++
if output.h
	if ~isempty(beam_model.Aero.Trim.MasterSurf)
		nh = length(beam_model.Aero.Trim.MasterSurf);

		if isempty(output.used.h)
			output.used.h = 1:nh;
		end

		outputGroup.h = nOutput + (1:nh);
		outputGroupUsed.h = nOutputUsed + (1:length(output.used.h));
		nOutput = nOutput + nh;
		nOutputUsed = nOutputUsed + length(output.used.h);

	else
		fprintf('WARNING: control surface input selected but not included in the model, skipping\n');
		output.h = false;
	end
end

% Nodal forces for load recovery +++++++++++++++++++++++++++++++++++++++++++++++
if output.n
	nn_tot = size(beam_model.Struct.M,1);

	% Check if a transformation matrix has been defined
	if ~isempty(opt.SnodalLoad);
		SnodalLoad = opt.SnodalLoad;
		if size(SnodalLoad, 2) ~= nn_tot
			fprintf('The matrix provided as opt.SnodalLoad does not agree with the dimension of the n set\n');
			fprintf(' %d ~= %d\n', size(SnodalLoad,2), nn_tot);
			error('aborting ...');
		end
	else
		SnodalLoad = eye(nn_tot,nn_tot);
	end

	nn = size(SnodalLoad,1);

	% The selected output refers to the SnodalLoad matrix
	if isempty(output.used.n)
		output.used.n = 1:nn;
	end

	outputGroup.n = nOutput + (1:nn);
	outputGroupUsed.n = nOutputUsed + (1:length(output.used.n));
	nOutput = nOutput + nn;
	nOutputUsed = nOutputUsed + length(output.used.n);

end


% Complete position arrays for the used inputs/outputs
% Used to select from the complete H matrix the columns corresponding to the H
% matrix actually interpolated
inputUsed = zeros(1,nInputUsed);
outputUsed = zeros(1,nOutputUsed);

position = 0;
fieldList = fieldnames(inputGroup);
for iGroup = 1:length(fieldList)
	selectGroup = getfield(inputGroup, fieldList{iGroup});
	usedInGroup = getfield(input.used, fieldList{iGroup});
	inputUsed(position + (1:length(usedInGroup))) = selectGroup(usedInGroup);
	position = position + length(usedInGroup);
end


position = 0;
fieldList = fieldnames(outputGroup);
for iGroup = 1:length(fieldList)
	selectGroup = getfield(outputGroup, fieldList{iGroup});
	usedInGroup = getfield(output.used, fieldList{iGroup});
	outputUsed(position + (1:length(usedInGroup))) = selectGroup(usedInGroup);
	position = position + length(usedInGroup);
end

% Generate input/output loads
inputName = cell(nInput,1);
outputName = cell(nOutput,1);


%-------------------------------------------------------------------------------
% Aero system
%-------------------------------------------------------------------------------

kvect = dyn_model.dlm.aero.k;
Mvect = dyn_model.dlm.aero.M;

nk = length(kvect);
nM = length(Mvect);
cref = dyn_model.dlm.aero.cref;
bref = beam_model.Aero.ref.b_ref;
sref = beam_model.Aero.ref.S_ref;

% TODO : it must use the SUPORT not the CG
Xsup = beam_model.WB.CG;

% Initialize matrices
Ha = zeros(nOutputUsed, nInputUsed, nk, nM);
scaleMatrixIn = zeros(nInputUsed, nInputUsed);
scaleMatrixOu = zeros(nOutputUsed, nOutputUsed);

% Modal input
if input.j

	% Modal output
	if output.j
		Ham = dyn_model.dlm.data.Qhh(output.used.j,input.used.j,:,:);
		Ha(outputGroupUsed.j, inputGroupUsed.j,:,:) = Ham;
	end

	% Rigid forces output
	if output.r
		for iM = 1:nM
			[Cy, Cz, Cl, Cm, Cn] = rigid_aero_force(dyn_model.dlm.data.Cp(:,input.used.j,:,iM), ...
			                                        dyn_model, cref, bref, sref, Xsup);
			Ham = [Cy(:,:,1:2:2*nk); Cz(:,:,1:2:2*nk); Cl(:,:,1:2:2*nk); Cm(:,:,1:2:2*nk); Cn(:,:,1:2:2*nk)];
		end
		Ha(outputGroupUsed.r, inputGroupUsed.j,:,:) = Ham;
	end

	% Hinge moments output
	if output.h
		Ham = dyn_model.dlm.data.Qdh(output.used.h, input.used.j, :, :);
		Ha(outputGroupUsed.h, inputGroupUsed.j,:,:) = Ham;
	end

	% Nodal forces output
	if output.n
		Ham = SnodalLoad(output.used.n,:) * dyn_model.dlm.data.Qnh(:,input.used.j,:,:);
		Ha(outputGroupUsed.n, inputGroupUsed.j,:,:) = Ham;
	end

	scaleMatrixIn(inputGroupUsed.j, inputGroupUsed.j) = scaleMatrix_jin;
end

% Gust/turbulence input
if input.g
	% Aero mesh coordinates and reference point
	np = beam_model.Aero.lattice_dlm.np;
	midPoint = beam_model.Aero.lattice_dlm.COLLOC(1:np,:)*cref;

	X0min = min(midPoint(:,1));

	Qhg = bsxfun(@times, permute(exp(-(midPoint(:,1) - X0min)*(1i*dyn_model.dlm.aero.k/cref)), [1,3,2]), ...
	                     dyn_model.gust.dwnwash(:,:)); 

	% Modal output
	if output.j
		Hag = zeros(length(output.used.j),ng,nk,nM);
		for iM = 1:nM
			for ik = 1:nk
				Hag(:,:,ik,iM) = dyn_model.gust.Qhg(output.used.j,:,ik,iM)*Qhg(:,:,ik);
			end
		end
		Ha(outputGroupUsed.j,inputGroupUsed.g,:,:) = Hag;
	end

	% Rigid forces output
	if output.r
		Hag = zeros(length(output.used.r),ng,nk,nM);
		HH = zeros(np,ng,nk);
		for iM = 1:nM
			for ik = 1:nk
				HH(:,:,ik) = dyn_model.gust.Cp(:,:,ik,iM) * Qhg(:,:,ik);
			end
			[Cy, Cz, Cl, Cm, Cn] = rigid_aero_force(HH, dyn_model, cref, bref, sref, Xsup);
			Hag(:,:,:,iM) = [Cy(:,:,1:2:2*nk); Cz(:,:,1:2:2*nk); Cl(:,:,1:2:2*nk); Cm(:,:,1:2:2*nk); Cn(:,:,1:2:2*nk)];
		end
		Ha(outputGroupUsed.r,inputGroupUsed.g,:,:) = Hag;
	end

	% Hinge moment output
	if output.h
		Hag = zeros(length(output.used.h),ng,nk,nM);
		for iM = 1:nM
			for ik = 1:nk
				Hag(:,:,ik,iM) = dyn_model.gust.Qdg(output.used.h,:,ik,iM)*Qhg(:,:,ik);
			end
		end
		Ha(outputGroupUsed.h,inputGroupUsed.g,:,:) = Hag;
	end

	% Nodal forces output
	if output.n
		Hag = zeros(length(output.used.n),ng,nk,nM);
		for iM = 1:nM
			for ik = 1:nk
				Hag(:,:,ik,iM) = SnodalLoad(output.used.n,:)*dyn_model.gust.Qng(:,:,ik,iM)*Qhg(:,:,ik);
			end
		end
		Ha(outputGroupUsed.n,inputGroupUsed.g,:,:) = Hag;
	end

	scaleMatrixIn(inputGroupUsed.g, inputGroupUsed.g) = eye(ng,ng);
end

% Control surface input
if input.c

	selectedSurf = beam_model.Surfdef.LabelID(input.used.c);

	% Modal output
	if output.j
		Had = dyn_model.dlm.data.Qhd(output.used.j,selectedSurf,:,:);
		Ha(outputGroupUsed.j,inputGroupUsed.c,:,:) = Had;
	end

	% Rigid forces
	if output.r
		for iM = 1:nM
			[Cy, Cz, Cl, Cm, Cn] = rigid_aero_force(dyn_model.dlm.data.Cp(:,nj+selectedSurf,:,iM),...
			                                        dyn_model, cref, bref, sref, Xsup);
			Had = [Cy(:,:,1:2:2*nk); Cz(:,:,1:2:2*nk); Cl(:,:,1:2:2*nk); Cm(:,:,1:2:2*nk); Cn(:,:,1:2:2*nk)];
			Ha(outputGroupUsed.r, inputGroupUsed.c,:,iM) = Had;
		end
	end

	% Hinge moment output
	if output.h
		Had = dyn_model.dlm.data.Qdd(output.used.h,selectedSurf, :, :);
		Ha(outputGroupUsed.h, inputGroupUsed.c,:,:) = Had;
	end

	% Nodal load output
	if output.n
		Had = SnodalLoad(output.used.n,:)*dyn_model.dlm.data.Qdd(:,selectedSurf, :, :);
		Ha(outputGroupUsed.n, inputGroupUsed.c,:,:) = Had;
	end

	scaleMatrixIn(inputGroupUsed.c, inputGroupUsed.c) = eye(nc,nc);
end

% Panel downwash input
if input.d

	% Modal output
	if output.j
		Had = zeros(length(output.used.j),nd,nk,nM);
		for iM = 1:nM
			for ik = 1:nk
				Had(:,:,ik,iM) = dyn_model.gust.Qhg(output.used.j,input.used.d,ik,iM);
			end
		end
		Ha(outputGroupUsed.j,inputGroupUsed.d,:,:) = Had;
	end

	% Rigid forces output
	if output.r
		error('To be implemented')
		Ha(outputGroupUsed.r,inputGroupUsed.d,:,:) = Had;
	end

	% Hinge moment output
	if output.h
		Had = zeros(length(output.used.h),nd,nk,nM);
		for iM = 1:nM
			for ik = 1:nk
				Had(:,:,ik,iM) = dyn_model.gust.Qdg(output.used.h,input.used.d,ik,iM);
			end
		end
		Ha(outputGroupUsed.h,inputGroupUsed.d,:,:) = Had;
	end

	% Nodal forces output
	if output.n
		Had = zeros(length(output.used.n),nd,nk,nM);
		for iM = 1:nM
			for ik = 1:nk
				Had(:,:,ik,iM) = Qnl_g(:,input.used.d,ik,iM);
			end
		end
		Ha(outputGroupUsed.n,inputGroupUsed.d,:,:) = Had;
	end

	scaleMatrixIn(inputGroupUsed.d, inputGroupUsed.d) = eye(nd,nd);
end


% Get output scale matrix
if output.j
	scaleMatrixOu(outputGroupUsed.j,outputGroupUsed.j) = inv(scaleMatrix_jou');
end
if output.r
	scaleMatrixOu(outputGroupUsed.r,outputGroupUsed.r) = eye(nr,nr);
end
if output.h
	scaleMatrixOu(outputGroupUsed.h,outputGroupUsed.h) = eye(nh,nh);
end
if output.n
	scaleMatrixOu(outputGroupUsed.n,outputGroupUsed.n) = eye(nn,nn);
end





%-------------------------------------------------------------------------------
% Selection on Mach number
%-------------------------------------------------------------------------------
% 
% TODO  allow interpolation on mach number
if isempty(SSopt.mach)
	machList = Mvect;
	machIndex = 1:length(Mvect);
else
	nM = length(SSopt.mach);
	machIndex = zeros(nM,1);
	for iM = 1:nM
		[minval, minpos] = min(abs(Mvect - SSopt.mach(iM)));
		machIndex(iM) = minpos;
	end
	machIndex = unique(machIndex);
	machList = Mvect(machIndex);

	Ha = Ha(:,:,:,machIndex);

end

Mvect = machList;
nM = length(Mvect);

%-------------------------------------------------------------------------------
% State-space generation
%-------------------------------------------------------------------------------

% Scale aerodynamic matrix
if strcmp(SSopt.method, 'freq')
	scaleMatrix = false;
else
	scaleMatrix = true;
end

if scaleMatrix
	for iM = 1:nM
		for ik = 1:nk
			Ha(:,:,ik,iM) = scaleMatrixOu\(Ha(:,:,ik,iM)*scaleMatrixIn);
		end
	end
end

SSaero.method = SSopt.method;
SSaero.mach = machList;
SSaero.inputGroup = inputGroup;
SSaero.outputGroup = outputGroup;
SSaero.inputName = inputName;
SSaero.outputName = outputName;
SSaero.model = [];

model = [];

switch SSopt.method
case 'mfd'
	mfdopt{1} = SSopt.mfdOrder;
	mfdopt{2} = SSopt.mfdAlg;
	mfdopt{3} = SSopt.mfdSide;
	mfdopt{5} = SSopt.mfdWeight;
	mfdopt{4} = SSopt.mfdResOrder;
	mfdopt{6} = SSopt.mfdRollOff;

	LMopt(1) = SSopt.LMtau;   
	LMopt(2) = SSopt.LMgradTol;
	LMopt(3) = SSopt.LMsolTol;
	LMopt(4) = SSopt.LMmaxIter;

	eigsopt.threshold = SSopt.eigThres;
	eigsopt.method    = SSopt.eigMeth;
	eigsopt.type      = SSopt.eigType;
	eigsopt.bound     = SSopt.eigBound;

	for iM = 1:nM
		fprintf('Processing system for Mach = %1.3f\n', machList(iM));

		if ~isempty(SSopt.orderROM)
			if length(SSopt.orderROM) == nM
				orderROM = SSopt.orderROM(iM);
			else
				orderROM = SSopt.orderROM(1);
			end
		else
			orderROM = [];
		end

		% Reinterpolation over frequency domain
		if ~isempty(SSopt.kvect)
			[DR, DI] = aeroMatrixSpline_get(Ha(:,:,:,iM), kvect, 1);
			HH = zeros(nOutputUsed, nInputUsed, length(SSopt.kvect));
			for ik = 1:length(SSopt.kvect)
				HH(:,:,ik) = aeroMatrixSpline_eval(SSopt.kvect(ik), kvect, Ha(:,:,:,iM), DR, DI, 1);
			end
			kvectUsed = SSopt.kvect;
		else
			HH = Ha(:,:,:,iM);
			kvectUsed = kvect;
		end

		if SSopt.useGUI
			data.Ha = HH;
			data.k = kvectUsed;
			save('inputfile.mat', '-struct', 'data', '-mat');
			fprintf('Running the identification GUI\n');
			fprintf('\n');
			fprintf(' Load the file ''inputfile.mat''\n');
			fprintf('\n');
			fprintf(' Save as ''outputfile.mat''\n');
			fprintf('\n');
			uiwait(mygui_embedded)
			data = load('outputfile.mat');
			solution = data.solution;
		else
			solution = improvedMFDfun(kvectUsed, HH, mfdopt, LMopt, eigsopt, ...
			                          SSopt.algROM, orderROM, SSopt.restartFile);
		end

		model(iM).A = solution.inoutresid.AA;

		na = size(model(iM).A,1);

		model(iM).B0 = zeros(na,nInput);
		model(iM).B1 = zeros(na,nInput);
		model(iM).B2 = zeros(na,nInput);

		model(iM).C = zeros(nOutput,na);

		model(iM).D0 = zeros(nOutput,nInput);
		model(iM).D1 = zeros(nOutput,nInput);
		model(iM).D2 = zeros(nOutput,nInput);


		model(iM).B0(:,inputUsed) = solution.inoutresid.BB{1}/scaleMatrixIn;
		model(iM).B1(:,inputUsed) = solution.inoutresid.BB{2}/scaleMatrixIn;
		model(iM).B2(:,inputUsed) = solution.inoutresid.BB{3}/scaleMatrixIn;

		model(iM).C(outputUsed,:) = scaleMatrixOu*solution.inoutresid.CC;

		model(iM).D0(outputUsed,inputUsed) = scaleMatrixOu*solution.inoutresid.DD{1}/scaleMatrixIn;
		model(iM).D1(outputUsed,inputUsed) = scaleMatrixOu*solution.inoutresid.DD{2}/scaleMatrixIn;
		model(iM).D2(outputUsed,inputUsed) = scaleMatrixOu*solution.inoutresid.DD{3}/scaleMatrixIn;

	end

case 'qs'
	for iM = 1:nM
		fprintf('Processing system for Mach = %1.3f\n', machList(iM));

		% Reinterpolation over frequency domain
		if ~isempty(SSopt.kvect)
			[DR, DI] = aeroMatrixSpline_get(Ha(:,:,:,iM), kvect, 1);
			HH = zeros(nOutputUsed, nInputUsed, length(SSopt.kvect));
			for ik = 1:length(SSopt.kvect)
				HH(:,:,ik) = aeroMatrixSpline_eval(SSopt.kvect(ik), kvect, Ha(:,:,:,iM), DR, DI, 1);
			end
			kvectUsed = SSopt.kvect;
		else
			HH = Ha(:,:,:,iM);
			kvectUsed = kvect;
		end

		[Ma, Ca, Ka] = aeroApprox_qs(HH, kvectUsed, SSopt.kmin, SSopt.kmax);

		na = 0;

		model(iM).A = zeros(na,na);

		model(iM).B0 = zeros(na,nInput);
		model(iM).B1 = zeros(na,nInput);
		model(iM).B2 = zeros(na,nInput);

		model(iM).C = zeros(nOutput,na);

		model(iM).D0 = zeros(nOutput,nInput);
		model(iM).D1 = zeros(nOutput,nInput);
		model(iM).D2 = zeros(nOutput,nInput);

		model(iM).D0(outputUsed,inputUsed) = scaleMatrixOu*Ka/scaleMatrixIn;
		model(iM).D1(outputUsed,inputUsed) = scaleMatrixOu*Ca/scaleMatrixIn;
		model(iM).D2(outputUsed,inputUsed) = scaleMatrixOu*Ma/scaleMatrixIn;

	end

case 'freq'
	% Get spline coefficients

	DR = zeros(nOutput,nInput,nk,nM);
	DI = zeros(nOutput,nInput,nk,nM);

	for iM = 1:nM
		[DR(:,:,:,iM), DI(:,:,:,iM)] = aeroMatrixSpline_get(Ha(:,:,:,iM), kvect, 1);
	end

	model.kvect = kvect;
	model.H = Ha;
	model.DR = DR;
	model.DI = DI;

otherwise
	error('method not recognized');
end


SSaero.model = model;



return
