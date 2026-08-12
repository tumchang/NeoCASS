function varargout = assemblySSAEmodel(Vinf, rho, l_a, Esys, Asys, out, selj, modalForces, sele)
%
%  [E, A] = assemblySSAEmodel(rho, Vinf, l_a, Esys, Asys, 'EA')
%  [E, A, E_v, A_v] = assemblySSAEmodel(rho, Vinf, l_a, Esys, Asys, 'DV')   
%  [AEmodel] = assemblySSAEmodel(rho, Vinf, l_a, Esys, Asys, 'ssmodel')
%
%  Create the state space model of the aeroservoelastic system with state space 
%  representation of the aerodynamic system.
%
% Esys:
%  - Mhh
%  - Chh
%  - Khh
%  - Msh  (optional, only for load recovery)
%  - K2sh (optional, only for load recovery)
%  - Uaj  (optional, only for acceleration recovery)
% 
% Asys
%  - model.A
%  - model.B0
%  - model.B1
%  - model.B2
%  - model.C
%  - model.D0
%  - model.D1
%  - model.D2
%  - inputGroup
%  - outputGroup
%
%
%-------------------------------------------------------------------------------
% 29-06-2016 
%

qinf = 0.5*rho*Vinf^2;
ta = l_a/Vinf;

if ~exist('out','var') || isempty(out)
	out = 'EA';
end

if ~exist('selj', 'var')
	selj = [];
end

if ~exist('sele', 'var')
	sele = 1:Esys.ne;
end

onlyEA = false;
computeDer = false;
computeSS  = false;

switch out
case 'EA'
	onlyEA = true;
case 'DV'
	computeDer = true;
case 'ssmodel'
	computeSS = true;
end


% Set system dimension
nj = Esys.nj;
ne = Esys.ne;


if ~isempty(selj)
	selj = selj(selj<=nj);
	selh = [selj, nj+sele];

	nj = length(selj);
	nh = length(selh);

	% Set matrices 
	Esys.Mhh = Esys.Mhh(selh,selh);
	Esys.Chh = Esys.Chh(selh,selh);
	Esys.Khh = Esys.Khh(selh,selh);
	Esys.nj = nj;
	Esys.ne = ne;

	Asys.inputGroup.j = Asys.inputGroup.j(selj);
	Asys.outputGroup.j = Asys.outputGroup.j(selj);
else
	nh = nj + ne;
end


pickj_in = Asys.inputGroup.j;
pickj_ou = Asys.outputGroup.j;

na = size(Asys.model(1).A,1);

nx = 2*nh + na;

D0hh = zeros(nh,nh); D0hh(1:nj,1:nj) = Asys.model(1).D0(pickj_ou,pickj_in);
D1hh = zeros(nh,nh); D1hh(1:nj,1:nj) = Asys.model(1).D1(pickj_ou,pickj_in);
D2hh = zeros(nh,nh); D2hh(1:nj,1:nj) = Asys.model(1).D2(pickj_ou,pickj_in);

B0ah = zeros(na,nh); B0ah(:,1:nj) = Asys.model(1).B0(:,pickj_in);
B1ah = zeros(na,nh); B1ah(:,1:nj) = Asys.model(1).B1(:,pickj_in);
B2ah = zeros(na,nh); B2ah(:,1:nj) = Asys.model(1).B2(:,pickj_in);


Cha = zeros(nh,na); Cha(1:nj,:) = Asys.model(1).C(pickj_ou,:);


E = [  eye(nh,nh),            zeros(nh,nh),  zeros(nh,na);
     zeros(nh,nh), Esys.Mhh-qinf*ta^2*D2hh,  zeros(nh,na);
     zeros(na,nh),                -ta*B2ah,    eye(na,na)];


A = [         zeros(nh,nh),               eye(nh,nh),       zeros(nh,na);
     -(Esys.Khh-qinf*D0hh), -(Esys.Chh-qinf*ta*D1hh),           qinf*Cha;
                   B0ah/ta,                     B1ah, Asys.model(1).A/ta];



if onlyEA
	varargout{1} = E;
	varargout{2} = A;
	return
end



if computeDer
	E_v = [ zeros(nh,nh),     zeros(nh,nh),        zeros(nh,na);
	        zeros(nh,nh),     zeros(nh,nh),        zeros(nh,na);
	        zeros(na,nh),     ta*B2ah/Vinf,        zeros(na,na)];


	A_v = [  zeros(nh,nh),         zeros(nh,nh),            zeros(nh,na);
	        rho*Vinf*D0hh, 0.5*rho*Vinf*ta*D1hh,            rho*Vinf*Cha;
	         B0ah/ta/Vinf,         zeros(na,nh), Asys.model(1).A/ta/Vinf];


	varargout{1} = E;
	varargout{2} = A;
	varargout{3} = E_v;
	varargout{4} = A_v;
	return
   
end

if computeSS

	if ~exist('modalForces','var') || isempty(modalForces)
		modalForces = false;
	end

	inputGroup = [];
	outputGroup = [];

	% From outputs get loads
	if isfield(Asys.outputGroup, 's');
		picks = Asys.outputGroup.s;
	else
		picks = [];
	end

	% Get all inputs that are not j
	fieldList = fieldnames(Asys.inputGroup);
	nInputs = 0;
	positionIn = [];
	for iField = 1:length(fieldList);
		if ~strcmp(fieldList{iField},'j')
			position = getfield(Asys.inputGroup, fieldList{iField});
			positionIn = [positionIn, position];
			position = position - position(1) + 1 + nInputs;
			inputGroup = setfield(inputGroup, fieldList{iField}, position);
			nInputs = nInputs + length(position);
		end
	end

	% Get all outputs that are not j and s
	fieldList = fieldnames(Asys.outputGroup);
	nOutputs = 0;
	positionOu = [];
	for iField = 1:length(fieldList);
		if ~strcmp(fieldList{iField},'j') && ~strcmp(fieldList{iField},'s')
			position = getfield(Asys.outputGroup, fieldList{iField});
			positionOu = [positionOu, position];
			position = position - position(1) + 1 + nOutputs;
			outputGroup = setfield(outputGroup, fieldList{iField}, position);
			nOutputs = nOutputs + length(position);
		end
	end


	% Process inputs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	D0hu = zeros(nh,nInputs); D0hu(1:nj,:) = Asys.model(1).D0(pickj_ou,positionIn);
	D1hu = zeros(nh,nInputs); D1hu(1:nj,:) = Asys.model(1).D1(pickj_ou,positionIn);
	D2hu = zeros(nh,nInputs); D2hu(1:nj,:) = Asys.model(1).D2(pickj_ou,positionIn);

	B0 = [                zeros(nh,nInputs);
	                              qinf*D0hu;
	      Asys.model(1).B0(:,positionIn)/ta];

	B1 = [             zeros(nh,nInputs);
	                        qinf*ta*D1hu;
	      Asys.model(1).B1(:,positionIn)];

	B2 = [                zeros(nh,nInputs);
	                         qinf*ta^2*D2hu;
	      Asys.model(1).B2(:,positionIn)*ta];

	% Process outputs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	D0yh = zeros(nOutputs,nh); D0yh(:,1:nj) = Asys.model(1).D0(positionOu,pickj_in);
	D1yh = zeros(nOutputs,nh); D1yh(:,1:nj) = Asys.model(1).D1(positionOu,pickj_in);
	D2yh = zeros(nOutputs,nh); D2yh(:,1:nj) = Asys.model(1).D2(positionOu,pickj_in);

	D0yu = Asys.model(1).D0(positionOu,positionIn);
	D1yu = Asys.model(1).D1(positionOu,positionIn);
	D2yu = Asys.model(1).D2(positionOu,positionIn);

	Cya = Asys.model(1).C(positionOu,:);

	F = [zeros(nOutputs,nh), qinf*ta^2*D2yh, zeros(nOutputs,na)];

	C = [qinf*D0yh, qinf*ta*D1yh, qinf*Cya];

	D = qinf*[D0yu, ta*D1yu, ta^2*D2yu];

	% Load recovery
	if ~isempty(picks) && isfield(Esys, 'Msh')
		ls = size(Esys.Msh,1);

		Msh  = Esys.Msh;
		K2sh = Esys.K2sh;

		D0sh = zeros(ls,nh); D0sh(:,1:nj) = Asys.model(1).D0(picks,pickj_in);
		D1sh = zeros(ls,nh); D1sh(:,1:nj) = Asys.model(1).D1(picks,pickj_in);
		D2sh = zeros(ls,nh); D2sh(:,1:nj) = Asys.model(1).D2(picks,pickj_in);

		D0su = Asys.model(1).D0(picks,positionIn);
		D1su = Asys.model(1).D1(picks,positionIn);
		D2su = Asys.model(1).D2(picks,positionIn);

		Csa = Asys.model(1).C(picks,:);

		Fs = [zeros(ls,nh), qinf*ta^2*D2sh-Msh, zeros(ls,na)];

		Cs = [qinf*D0sh-K2sh, qinf*ta*D1sh, qinf*Csa];

		Ds = qinf*[D0su, ta*D1su, ta^2*D2su];

		outputGroup = setfield(outputGroup, 's', nOutput+(1:ls));
		nOutput = nOutput + ls;

		F = [F; Fs];
		C = [C; Cs];
		D = [D; Ds];

	end
  
	% Accelerations
	if isfield(Esys, 'Uaj')
		la = size(Esys.Uaj,1);

		Uah = zeros(la,nh);
		Uah(:,1:nj) = Esys.Uaj;

		Ca = [zeros(la,nh), zeros(la,nh), zeros(la,na)];
		Fa = [zeros(la,nh), Uah, zeros(la,na)];
		Da = zeros(la,3*nInputs);

		outputGroup = setfield(outputGroup, 'a', nOutputs+(1:la));
		nOutputs = nOutputs + la;

		F = [F; Fa];
		C = [C; Ca];
		D = [D; Da];

	end

	% Modal Forces
	if modalForces
		lm = nj;

		Uah = zeros(la,nh);
		Uah(:,1:nj) = Esys.Uaj;

		Cm = [qinf*D0hh(selj,:), qinf*ta*D1hh(selj,:), qinf*Cha(selj,:)];
		Fm = [zeros(lm,nh), qinf*ta^2*D2hh(selj,:), zeros(lm,na)];
		Dm = [qinf*D0hu, qinf*ta*D1hu, qinf*ta^2*D2hu];

		outputGroup = setfield(outputGroup, 'm', nOutputs+(1:lm));
		nOutputs = nOutputs + lm;

		F = [F; Fm];
		C = [C; Cm];
		D = [D; Dm];

	end

	% % Add modal output
	% CC = zeros(2*nj+2*ne,nx);
	% FF = zeros(2*nj+2*ne,nx);
	% DD = zeros(2*nj+2*ne,3*nInputs);

	% CC(1:nj,1:nj) = eye(nj,nj);
	% CC(nj + (1:ne), nj + (1:ne)) = eye(ne,ne);
	% CC(nh + (1:nj), nh + (1:nj)) = eye(nj,nj);
	% CC(nh+nj + (1:ne), nh+nj + (1:ne)) = eye(ne,ne);

	% F = [F; FF];
	% C = [C; CC];
	% D = [D; DD];

	% outputGroup.j    = nOutputs + (1:nj);
	% outputGroup.e    = nOutputs + nj + (1:ne);
	% outputGroup.jdot = nOutputs + nh + (1:nj);
	% outputGroup.edot = nOutputs + nh + nj + (1:ne);

	% nOutputs = nOutputs + 2*nh;

	% Define states
	stateGroup.j = 1:nj;
	stateGroup.e = nj + (1:ne);
	stateGroup.jdot = nh + (1:nj);
	stateGroup.edot = nh + nj + (1:ne);
	stateGroup.aero = 2*nh + (1:na);


	ssmodel.E = E;
	ssmodel.A = A;
	ssmodel.B0 = B0;
	ssmodel.B1 = B1;
	ssmodel.B2 = B2;
	ssmodel.F = F;
	ssmodel.C = C;
	ssmodel.D0 = D(:,             1:nInputs);
	ssmodel.D1 = D(:,  nInputs + (1:nInputs));
	ssmodel.D2 = D(:,2*nInputs + (1:nInputs));

	ssmodel.inputGroup = inputGroup;
	ssmodel.outputGroup = outputGroup;
	ssmodel.stateGroup = stateGroup;

	varargout{1} = ssmodel;

end






return
