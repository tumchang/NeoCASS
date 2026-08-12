function [fdAEmodel_base, aero] = aemodelFD_set(type, varargin)
%
%
%
%
%-------------------------------------------------------------------------------
% 08-11-2016
%

global dyn_model

beam_model = dyn_model.beam;
fid = beam_model.Param.FID;

% Default values
axesUsed = 'inertial';
e0 = [0,0,0];
v0OverVinf = [-1,0,0];
edot0 = [0,0,0];
seljUsed = [];
rigidDisplacement = nan;
rigidVelocity = nan;
modifyAeroSS = [];
angleCoord = false;

dtpos = find('.' == beam_model.Param.FILE);
headname = beam_model.Param.FILE(1:dtpos(end)-1);

machVariation = false;


cref = dyn_model.dlm.aero.cref;

refValues = [beam_model.Param.VREF;
             beam_model.Param.RHOREF;
             beam_model.Param.MACH];

% Check user defined inputs
PARAM = varargin;
stillToCheck = ones(length(PARAM),1);

for n=1:2:length(PARAM);
	switch PARAM{n}
	case 'axesUsed'
		axesUsed = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'seljUsed'
		seljUsed = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'rigidDisplacement'
		rigidDisplacement = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'rigidVelocity'
		rigidVelocity = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'modifyAeroSS'
		modifyAeroSS = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	end
end

[Vinf, rhoinf, Minf] = setFlightCondition(refValues, PARAM{find(stillToCheck)});

% fprintf(fid,' - Reference chord :      %g m.     \n', cref); 
% fprintf(fid,'\n'); 
% fprintf(fid,'\n'); 
% fprintf(fid,' - Flight velocity :      %g m/s.   \n', Vinf); 
% fprintf(fid,' - density         :      %g Kg/m^3.\n', rhoinf); 
% fprintf(fid,' - Mach number     :      %g.       \n', Minf);
% fprintf(fid,'\n'); 

% The reference chord has already been divided by 2
l_a = cref;


v0 = v0OverVinf*Vinf;

aero.l_a = l_a;
aero.Vinf = Vinf;
aero.rhoinf = rhoinf;
aero.Minf = Minf;

ta = l_a/Vinf;

if strcmp(axesUsed, 'bodyAngles')
	angleCoord = true;
end

%-------------------------------------------------------------------------------
% Modal base
%-------------------------------------------------------------------------------
% 
% Set definition:
% i : set of all modes computed from modal analysis
% j : set of modes used for the computation of aerodynamic matrices Qhh
% d : set of modes and extra points used for the dynamic analysis
ni = size(beam_model.Struct.Mmm,1);

% Modes used in dlm
if (isempty(beam_model.Param.MSELECT))
	mbase = beam_model.Struct.ID;
else
	mbase = beam_model.Param.MSELECT;
end

selj = mbase;
nj = length(selj);

% Modes used for dynamic analysis
if isempty(beam_model.Param.UMODES)
	seld = 1:ni;
else
	seld = beam_model.Param.UMODES;
end

% Remove from seld all modes for which no aerodynamic loads are computed
selectionArray = zeros(ni,1);
selectionArray(selj) = 1;
selectionArray(seld) = selectionArray(seld) + 1;
seld = find(selectionArray==2);
seldFromj = find(selectionArray(selj)==2);

nd = length(seld);


% Find rigid and elastic modes involved            
indexRigid   = (seld<=6);
indexElastic = (seld>6);

seldRigid   = seld(indexRigid);
seldElastic = seld(indexElastic);
nRigid   = length(seldRigid  ); % number of rigid modes in UMODES
nElastic = length(seldElastic); % number of elastic modes in UMODES

scaleRigid = diag(diag(1./sqrt(beam_model.Struct.Mmm(1:6,1:6))));
scaleMatrix = blkdiag(scaleRigid(seldRigid,seldRigid), eye(nElastic,nElastic));

% TODO : this function assumes that all six rigid DOFs are available
%   - organize the rigid mode database (position in j and corresponding mode) (outside this function)


if isempty(seljUsed)
	seljUsed = seld;
end

if isnan(rigidDisplacement)
	rigidDisplacement = seljUsed(seljUsed<=6);
end

if isnan(rigidVelocity)
	rigidVelocity = seljUsed(seljUsed<=6);
end

if strcmp(axesUsed, 'body') || strcmp(axesUsed, 'bodyAngles')
	% Keep all the rigid modes
	seljUsed = [(1:6)'; seljUsed(seljUsed>6)];
end

%-------------------------------------------------------------------------------
% Mass and stiffness
%-------------------------------------------------------------------------------
Mhh = beam_model.Struct.Mmm;
Khh = beam_model.Struct.Kmm;
ne = 0;
nh = nj + ne;

%-------------------------------------------------------------------------------
% structural damping
%-------------------------------------------------------------------------------
SDAMP = beam_model.Param.SDAMP;

Chh = zeros(ni,ni); % viscous damp

if (SDAMP)
	DAMP = beam_model.Damp;
	%fprintf(fid,' - Structural damping required: '); 
	if (beam_model.Param.KDAMP == 1)
		%fprintf(fid,'viscous type. \n'); 
		Chh = modal_damp(DAMP.g{SDAMP}, DAMP.Freq{SDAMP}, DAMP.Type(SDAMP), beam_model.Param.KDAMP, ...
		                    beam_model.Struct.Mmm, beam_model.Struct.Omega./(2*pi));
	else
		fprintf(fid,'\n'); 
		error('Histeretic damping not compatible with time domain analysis.'); 
	end
else
	%fprintf(fid,' - No structural damping required.\n'); 
end


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Base transformation
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

nx = 2*nh;

T1 = eye(nx,nx);
T2 = eye(nx,nx);
T3 = zeros(nx,nx);

posRigid = [seldRigid, nh + seldRigid];

switch axesUsed
case 'body'
	[T1hat, T2hat, T3hat] = iner2body(e0, v0, edot0);
	T1(posRigid,posRigid) = T1hat;
	T2(posRigid,posRigid) = T2hat;
	T3(posRigid,posRigid) = T3hat;
case 'bodyAngles'
	[T1hat, T2hat, T3hat] = iner2body(e0, v0, edot0, true);
	T1(posRigid,posRigid) = T1hat;
	T2(posRigid,posRigid) = T2hat;
	T3(posRigid,posRigid) = T3hat;
case 'inertial'
otherwise
	error('Invalid choice for ''axesUsed'' parameter')
end

%-------------------------------------------------------------------------------

% Descriptor matrix
fdAEmodel_base.E = [  eye(nh,nh), zeros(nh,nh);
               zeros(nh,nh),          Mhh];

% State matrix without aerodynamics
fdAEmodel_base.As = [ zeros(nh,nh), eye(nh,nh);
                         -Khh,       -Chh];

fdAEmodel_base.As = fdAEmodel_base.As*T1 - fdAEmodel_base.E*T3;
fdAEmodel_base.E = fdAEmodel_base.E*T2;

fdAEmodel_base.dim.nh = nh;
fdAEmodel_base.dim.ne = ne;

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Aerodynamic system
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

[~, selMach_freq] = min(abs(Minf - dyn_model.dlm.aero.M));
nM = length(selMach_freq);
nk = length(dyn_model.dlm.aero.k);

fdAEmodel_base.fdAero.kvect = dyn_model.dlm.aero.k;
fdAEmodel_base.fdAero.Mvect = dyn_model.dlm.aero.M(selMach_freq);

fdAEmodel_base.Arows = nh+(1:nh);

Qhh = dyn_model.dlm.data.Qhh(:,:,:,selMach_freq);
switch axesUsed
case 'inertial'
	fdAEmodel_base.Acols = 1:nh;
	fdAEmodel_base.fdAero.Ham = Qhh;
case {'body', 'bodyAngles'}
	fdAEmodel_base.Acols = [seldElastic; nh + seldRigid];
	Ham = getHamBodyCoord(Qhh, fdAEmodel_base.fdAero.kvect, seldRigid, ta, e0, v0, edot0, angleCoord);
	fdAEmodel_base.fdAero.Ham = Ham(:, [seldElastic; seldRigid], :, :);
end

% Get coefficients for spline interpolation of Qhh matrix (over reduced frequencies)
DR = zeros(nh, nh, nk, nM);
DI = zeros(nh, nh, nk, nM);

for iM = 1:nM
	[DR(:,:,:,iM), DI(:,:,:,iM)] = aeroMatrixSpline_get(fdAEmodel_base.fdAero.Ham(:,:,:,iM), fdAEmodel_base.fdAero.kvect, 1);
end

fdAEmodel_base.fdAero.HamR = DR;
fdAEmodel_base.fdAero.HamI = DI;



return
% Set acceleration output
if ~isempty(beam_model.Param.ACCELERATION)
	Uaj = dyn_model.Out.ACCELERATION(:,seljUsed);
end

ssmodel= assemblySSAEmodel(Vinf, rhoinf, l_a, Esys, AsysSS, 'ssmodel', seljUsed);
nx = size(ssmodel.A,1);
nInputs = size(ssmodel.B0,2);


ssmodel.C = ssmodel.C*T1 + ssmodel.F*T3;
ssmodel.F = ssmodel.F*T2;



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
A = ssmodel.E\[ssmodel.A, ssmodel.B0, ssmodel.B1, ssmodel.B2];

Bae = A(:, nx + (1:3*nInputs));
Aae = A(:,1:nx);

Dae = [ssmodel.D0, ssmodel.D1, ssmodel.D2];

% Inputs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
inputGroup = [];
inputName = {};
selectInputs = zeros(3*nInputs,1);
nAEinputs = 0;

% Gust input
if isfield(ssmodel.inputGroup, 'g')
	position = ssmodel.inputGroup.g;
	nGust = length(position);
	inputGroup.gust = nAEinputs + (1:nGust*3);
	for iGust = 1:nGust
		position_new = nAEinputs + (1:3);
		selectInputs(position(iGust) + (0:2)*nInputs) = position_new;
		nAEinputs = nAEinputs + 3;
		name_base = ['alphag', int2str(iGust)];
		inputName(position_new) = {name_base, [name_base,'-dot'], [name_base, '-ddot']};
	end
	isGust = true;
else
	isGust = false;
end

% Control surfaces input
if isfield(ssmodel.inputGroup, 'c')
	position = ssmodel.inputGroup.c;
	nSurf = length(position);
	inputGroup.controlSurf = nAEinputs + (1:nSurf*3);
	for iContr = 1:nSurf
		position_new = nAEinputs + (1:3);
		selectInputs(position(iContr) + (0:2)*nInputs) = position_new;
		nAEinputs = nAEinputs + 3;
		%name_base = beam_model.Aero.Trim.MasterSurf{beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF(iContr))};
		name_base = dyn_model.Out.surfaceName{beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF(iContr))};
		inputName(position_new) = {name_base, [name_base,'-dot'], [name_base, '-ddot']};
	end
	isSurf = true;
else
	isSurf = false;
end

% TODO add external loads
nLoad = 0;

% Select final input matrix
position = find(selectInputs>0);
Bae(:,selectInputs(position)) = Bae(:,position);
Dae(:,selectInputs(position)) = Dae(:,position);

% Outputs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

outputGroup = [];
outputName = {};
nAEoutputs = 0;

C = zeros(0,nx);
D = zeros(0,nAEinputs);

% Accelerations
if isfield(ssmodel.outputGroup, 'a')
	position = ssmodel.outputGroup.a;
	nAcc = length(position);
	outputGroup.accel = nAEoutputs + (1:nAcc);

	% Get node ID and DOF
	nodeID = beam_model.Node.ID(beam_model.Param.ACCELERATION);
	nNode = length(nodeID);
	nodeIDlist = reshape(reshape(nodeID, [nNode,1])*ones(1,6), [nNode*6,1]);
	dofList = reshape(ones(nNode,1)*(1:6), [nNode*6,1]);

	for iAcc = 1:nAcc
		outputName{nAEoutputs + iAcc} = ['ACC-', int2str(nodeIDlist(iAcc)), '-', int2str(dofList(iAcc))];
	end
	nAEoutputs = nAEoutputs + nAcc;

	CC = ssmodel.C(position,:) + ssmodel.F(position,:)*Aae;
	DD =       Dae(position,:) + ssmodel.F(position,:)*Bae;

	C = [C; CC];
	D = [D; DD];
else
	outputGroup.accel = [];

end

% Displacements
if ~isempty(beam_model.Param.DISP)

	% Get node ID and DOF
	nodeID = beam_model.Node.ID(beam_model.Param.DISP);
	nNode = length(nodeID);
	nodeIDlist = reshape(reshape(nodeID, [nNode,1])*ones(1,6), [nNode*6,1]);
	dofList = reshape(ones(nNode,1)*(1:6), [nNode*6,1]);

	nDisp = 6*nNode;
	outputGroup.displ = nAEoutputs + (1:nDisp);

	for iDisp = 1:nDisp
		outputName{nAEoutputs + iDisp} = ['DISP-', int2str(nodeIDlist(iDisp)), '-', int2str(dofList(iDisp))];
	end
	nAEoutputs = nAEoutputs + nDisp;

	Uj = dyn_model.Out.DISP(:,seljUsed);
	CC = zeros(nDisp,nx); CC(:,ssmodel.stateGroup.j) = Uj;
	DD = zeros(nDisp,nAEinputs);

	C = [C; CC];
	D = [D; DD];
else
	outputGroup.displ = [];

end


% Velocities
if ~isempty(beam_model.Param.VELOCITY)

	% Get node ID and DOF
	nodeID = beam_model.Node.ID(beam_model.Param.VELOCITY);
	nNode = length(nodeID);
	nodeIDlist = reshape(reshape(nodeID, [nNode,1])*ones(1,6), [nNode*6,1]);
	dofList = reshape(ones(nNode,1)*(1:6), [nNode*6,1]);

	nVel = 6*nNode;
	outputGroup.vel = nAEoutputs + (1:nVel);

	for iVel = 1:nVel
		outputName{nAEoutputs + iVel} = ['VEL-', int2str(nodeIDlist(iVel)), '-', int2str(dofList(iVel))];
	end
	nAEoutputs = nAEoutputs + nVel;

	Uj = dyn_model.Out.VELOCITY(:,seljUsed);
	CC = zeros(nVel,nx); CC(:,ssmodel.stateGroup.jdot) = Uj;
	DD = zeros(nVel,nAEinputs);

	C = [C; CC];
	D = [D; DD];
else

	outputGroup.vel = [];

end

% Bar internal load
if ~isempty(beam_model.Param.IFORCE)

	% Get bar ID and DOF
	barID = beam_model.Bar.ID(beam_model.Param.IFORCE);
	nBar = length(barID);
	barIDlist = reshape(repmat(reshape(barID, [1,1,nBar]), [6,2,1]), [nBar*12,1]);
	dofList   = reshape(repmat((1:6)', [1,2,nBar]), [nBar*12,1]);
	pointList = reshape(repmat((1:2), [6,1,nBar]), [nBar*12,1]);

	nForce = 12*nBar;
	outputGroup.barforce = nAEoutputs + (1:nForce);

	for iForce = 1:nForce
		outputName{nAEoutputs + iForce} = ['FORCE-BAR-', int2str(barIDlist(iForce)), '-', int2str(dofList(iForce)), '-C', int2str(pointList(iForce))];
	end
	nAEoutputs = nAEoutputs + nForce;

	Uj = dyn_model.Out.IFORCE(:,seljUsed);
	CC = zeros(nForce,nx); CC(:,ssmodel.stateGroup.j) = Uj;
	DD = zeros(nForce,nAEinputs);

	C = [C; CC];
	D = [D; DD];
else
	outputGroup.barforce = [];

end

% Beam internal load -----------------------------------------------------------
if ~isempty(beam_model.Param.IFORCEBE)

	% Get bar ID and DOF
	barID = beam_model.Bar.ID(beam_model.Param.IFORCEBE);
	nBar = length(barID);
	barIDlist = reshape(repmat(reshape(barID, [1,1,nBar]), [6,2,1]), [nBar*12,1]);
	dofList   = reshape(repmat((1:6)', [1,2,nBar]), [nBar*12,1]);
	pointList = reshape(repmat((1:2), [6,1,nBar]), [nBar*12,1]);

	nForce = 12*nBar;
	outputGroup.beamforce = nAEoutputs + (1:nForce);

	for iForce = 1:nForce
		outputName{nAEoutputs + iForce} = ['FORCE-BEAM-', int2str(barIDlist(iForce)), '-', int2str(dofList(iForce)), '-C', int2str(pointList(iForce))];
	end
	nAEoutputs = nAEoutputs + nForce;

	Uj = dyn_model.Out.IFORCEBE(:,seljUsed);
	CC = zeros(nForce,nx); CC(:,ssmodel.stateGroup.j) = Uj;
	DD = zeros(nForce,nAEinputs);

	C = [C; CC];
	D = [D; DD];
else
	outputGroup.beamforce = [];

end

% Hinge moments ----------------------------------------------------------------
if isfield(ssmodel.outputGroup, 'h')
	position = ssmodel.outputGroup.h;
	nHinge = length(position);
	outputGroup.hingemom = nAEoutputs + (1:nHinge);

	for iHinge = 1:nHinge
		surfname = dyn_model.Out.surfaceName{iHinge};
		%surfname = beam_model.Aero.Trim.MasterSurf{iHinge};
		outputName{nAEoutputs + iHinge} = ['HMOM-', surfname];
	end
	nAEoutputs = nAEoutputs + nHinge;

	CC = ssmodel.C(position,:) + ssmodel.F(position,:)*Aae;
	DD =       Dae(position,:) + ssmodel.F(position,:)*Bae;

	C = [C; CC];
	D = [D; DD];
else
	outputGroup.hingemom = [];

end

% Add delays +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% controls
if isSurf
	delay_delta = beam_model.Surfdef.X0(beam_model.Param.SURFDEF);
	delay_delta = reshape(delay_delta, [1,nSurf]);
end

% gusts
if isGust
	% Aero mesh coordinates and reference point
	np = beam_model.Aero.lattice_dlm.np;
	midPoint = beam_model.Aero.lattice_dlm.COLLOC(1:np,:)*cref;
	X0min = min(midPoint(:,1));


	delay_vg = (X0min - beam_model.Gust.X0(beam_model.Param.GUST))./Vinf;
	delay_vg = reshape(delay_vg, [1,nGust]);
end

posSurf = inputGroup.controlSurf;
posGust = inputGroup.gust;

inputDelay = zeros(nSurf*3+nGust*3+nLoad,1);


inputDelay(posSurf) = reshape(repmat(delay_delta, [3,1]), [3*nSurf,1]);
inputDelay(posGust) = reshape(repmat(delay_vg,    [3,1]), [3*nGust,1]);



% Assembly final model +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Select rigid degree of freedom
select = ones(nx,1);
select(ssmodel.stateGroup.j(1:6)) = 0;
select(ssmodel.stateGroup.jdot(1:6)) = 0;

select(ssmodel.stateGroup.j(rigidDisplacement)) = 1;
select(ssmodel.stateGroup.jdot(rigidVelocity)) = 1;

select = find(select);

Aae = Aae(select,select);
Bae = Bae(select,:);
C = C(:,select);


ssAEmodel.A = Aae;
ssAEmodel.B = Bae;
ssAEmodel.C = C;
ssAEmodel.D = D;

ssAEmodel.inputGroup = inputGroup;
ssAEmodel.outputGroup = outputGroup;

ssAEmodel.inputName = inputName;
ssAEmodel.outputName = outputName;

ssAEmodel.inputDelay = inputDelay;

return
