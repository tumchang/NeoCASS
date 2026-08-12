function varargout = aematrixFD_set(Vinf, l_a, Esys, Asys, axesUsed, flightCond, out)
%
% varargout = aematrixFD_set(Vinf, l_a, Esys, Asys, axesUsed, flightCond, out)
%
%-------------------------------------------------------------------------------
% 21-11-2016
%


if ~exist('out','var') || isempty(out)
	out = 'EA';
end

onlyEA = false;
computeDer = false;
computeInOut  = false;

switch out
case 'EA'
	onlyEA = true;
case 'DV'
	computeDer = true;
case 'fdmodel'
	computeInOut = true;
end


% Set system dimension
nj = Esys.nj;
ne = Esys.ne;

nh = nj + ne;


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Base transformation
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

nx = 2*nh;

T1 = eye(nx,nx);
T2 = eye(nx,nx);
T3 = zeros(nx,nx);

rigidDofUsed = find(Esys.rigidDOF(:,3));
posRigid = Esys.rigidDOF(rigidDofUsed,3);
posElastic = setdiff(1:nh, posRigid)';
posRigid_state = [posRigid, nh + posRigid];

disUsed = find(Esys.rigidDOF(1:3,3));
rotUsed = find(Esys.rigidDOF(4:6,3));

nElastic = length(posElastic);
nRigid = length(posRigid);
nDisp = length(disUsed);


switch axesUsed
case {'body', 'bodyAngles'}

	if isempty(flightCond)
		flightCond.v0norm = [-1; 0; 0];
		flightCond.e0 = [0;0;0];
		flightCond.e0norm = [0;0;0];
	end

	angleCoord = strcmp(axesUsed, 'bodyAngles');
	[T1hat, T2hat, T3hat] = iner2body(flightCond.e0, flightCond.v0norm*Vinf, flightCond.edot0norm*Vinf/l_a, angleCoord);
	T1(posRigid_state,posRigid_state) = T1hat;
	T2(posRigid_state,posRigid_state) = T2hat;
	T3(posRigid_state,posRigid_state) = T3hat;
case 'inertial'
otherwise
	error('Invalid choice for ''axesUsed'' parameter')
end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Structural system
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Descriptor matrix
E = [  eye(nh,nh), zeros(nh,nh);
     zeros(nh,nh),     Esys.Mhh];

% State matrix without aerodynamics
A = [ zeros(nh,nh), eye(nh,nh);
         -Esys.Khh,  -Esys.Chh];

A = A*T1 - E*T3;
E = E*T2;


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Aerodynamic system
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

nM = length(Asys.Mvect);
nk = length(Asys.kvect);

fdAero.kvect = Asys.kvect;
fdAero.Mvect = Asys.Mvect;

fdAero.Arows = nh+(1:nh);

switch axesUsed
case 'inertial'
	fdAero.Acols = 1:nh;
	fdAero.Ham = Asys.Qhh;
	fdAero.HamVscale = [];
case {'body', 'bodyAngles'}
	fdAero.Acols = [posElastic; nh + posRigid];
	Ham = zeros(nh,nh,nk,nM);
	for iM = 1:nM
		Ham(:,:,:,iM) = getHamBodyCoord(Asys.Qhh, Asys.kvect, Esys.rigidDOF, l_a, ...
		                                flightCond.e0, flightCond.v0norm, ...
		                                flightCond.edot0norm, [1,1,1], angleCoord);
	end
	fdAero.Ham = Ham(:, [posElastic; posRigid], :, :);

	% Recover physical velocities and angular velocities
	fdAero.Ham(:, nElastic+(1:nRigid),:)       = fdAero.Ham(:,nElastic+(1:nRigid),:)/Vinf; 
	fdAero.Ham(:, nElastic+(nDisp+1:nRigid),:) = fdAero.Ham(:,nElastic+(nDisp+1:nRigid),:)*l_a; 
end

% % Get coefficients for spline interpolation of Qhh matrix (over reduced frequencies)
% DR = zeros(nh, nh, nk, nM);
% DI = zeros(nh, nh, nk, nM);
% 
% for iM = 1:nM
% 	[DR(:,:,:,iM), DI(:,:,:,iM)] = aeroMatrixSpline_get(fdAero.Ham(:,:,:,iM), fdAero.kvect, 1);
% end
% 
% fdAero.HamR = DR;
% fdAero.HamI = DI;

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



if onlyEA
	varargout{1} = E;
	varargout{2} = A;
	varargout{3} = fdAero;
	varargout{4} = flightCond;
	return
end



if computeDer
	error('Not implemented');
end

if computeInOut

	% Process inputs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	nInputs = size(Asys.Qhu,2);

	B = [zeros(nh,nInputs); zeros(nh,nInputs)];

	fdAero.Brows = nh + (1:nh);

	fdAero.Hau = Asys.Qhu;

	% % Get coefficients for spline interpolation of Qhh matrix (over reduced frequencies)
	% DR = zeros(nh, nInputs, nk, nM);
	% DI = zeros(nh, nInputs, nk, nM);

	% for iM = 1:nM
	% 	[DR(:,:,:,iM), DI(:,:,:,iM)] = aeroMatrixSpline_get(fdAero.Hau(:,:,:,iM), fdAero.kvect, 1);
	% end

	% fdAero.HauR = DR;
	% fdAero.HauI = DI;


	% Process outputs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	outputGroup = Asys.outputGroup;
	nOutputs = size(Asys.Qyh,1);

	C = [zeros(nOutputs,nh); zeros(nh,nh)];

	fdAero.Ccols = fdAero.Acols;

	switch axesUsed
	case 'inertial'
		fdAero.Hym = Asys.Qyh;
	case {'body', 'bodyAngles'}
		Ham = zeros(nh,nh,nk,nM);
		for iM = 1:nM
			Hym(:,:,:,iM) = getHamBodyCoord(Asys.Qyh, Asys.kvect, Esys.rigidDOF, l_a, ...
			                                flightCond.e0, flightCond.v0norm, ...
			                                flightCond.edot0norm, [1,1,1], angleCoord);
		end
		fdAero.Hym = Hym(:, [posElastic; posRigid], :, :);
		fdAero.Hym(:, nElastic+(nDisp+1:nRigid)) = fdAero.Hym(:,nElastic+(nDisp+1:nRigid))*l_a; 
	end


	% % Get coefficients for spline interpolation of Qhh matrix (over reduced frequencies)
	% DR = zeros(nOutputs, nh, nk, nM);
	% DI = zeros(nOutputs, nh, nk, nM);

	% for iM = 1:nM
	% 	[DR(:,:,:,iM), DI(:,:,:,iM)] = aeroMatrixSpline_get(fdAero.Hym(:,:,:,iM), fdAero.kvect, 1);
	% end

	% fdAero.HymR = DR;
	% fdAero.HymI = DI;

	D = zeros(nOutputs,nInputs);

	fdAero.Hyu = Asys.Qyu;

	% % Get coefficients for spline interpolation of Qhh matrix (over reduced frequencies)
	% DR = zeros(nOutputs, nInputs, nk, nM);
	% DI = zeros(nOutputs, nInputs, nk, nM);

	% for iM = 1:nM
	% 	[DR(:,:,:,iM), DI(:,:,:,iM)] = aeroMatrixSpline_get(fdAero.Hyu(:,:,:,iM), fdAero.kvect, 1);
	% end

	% fdAero.HyuR = DR;
	% fdAero.HyuI = DI;

	% Load recovery
	if ~isempty(picks) && isfield(Esys, 'Msh')
		error('Load recovery not implemented');
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

		Ca = [zeros(la,nh), Uah]*T3;
		Fa = [zeros(la,nh), Uah]*T2;
		Da = zeros(la,3*nInputs);

		outputGroup = setfield(outputGroup, 'a', nOutputs+(1:la));
		nOutputs = nOutputs + la;

		F = [F; Fa];
		C = [C; Ca];
		D = [D; Da];

	end

	% Define states
	stateGroup.j = 1:nj;
	stateGroup.e = nj + (1:ne);
	stateGroup.jdot = nh + (1:nj);
	stateGroup.edot = nh + nj + (1:ne);

	fdmodel_base.E = E;
	fdmodel_base.A = A;
	fdmodel_base.B = B;
	fdmodel_base.F = F;
	fdmodel_base.C = C;
	fdmodel_base.D = D;

	fdmodel_base.inputGroup = Asys.inputGroup;
	fdmodel_base.outputGroup = outputGroup;
	fdmodel_base.stateGroup = stateGroup;

	fdmodel_base.fdAero = fdAero;

	varargout{1} = fdmodel_base;
	varargout{2} = flightCondition;

end






return
