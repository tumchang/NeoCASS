function [ssAEmodel, aero, ssmodel, descrForm] = getAEmodel(ssmodel, varargin)
%
%
%
% TODO : remove modifyAeroSS option
%        make dyn_model as an input parameter
%
%-------------------------------------------------------------------------------
% 30-06-2016
%

global dyn_model

beam_model = dyn_model.beam;
fid = beam_model.Param.FID;

% Default values
axesUsed = 'inertial';
e0 = [0,0,0];
v0OverVinf = [-1,0,0];
edot0 = [0,0,0];
seljUsed = 'all';
rigidDisplacement = nan;
rigidVelocity = nan;
modifyAeroSS = [];
AEopt.modalForces = false; % Provides aerodynamic modal forces as output
AEopt.modalDisp = [];
AEopt.modalVel = [];

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
	case 'modalForces'
		AEopt.modalForces = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'modalDisp'
		AEopt.modalDisp = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'modalVel'
		AEopt.modalVel = PARAM{n+1};
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

[~, selMach_ss  ] = min(abs(Minf - ssmodel.mach));


v0 = v0OverVinf*Vinf;

aero.l_a = l_a;
aero.Vinf = Vinf;
aero.rhoinf = rhoinf;
aero.Minf = Minf;


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



% Find rigid and elastic modes involved            
if isfield(beam_model.Struct, 'rigidDOF');
	rigidDOF = beam_model.Struct.rigidDOF;
else
	rigidDOF = zeros(6,3);
	rigidDOF(:,3) = 1:6;
end


selRigid   = rigidDOF(rigidDOF(:,3)>0,3);

if isstr(seljUsed) 
	if strcmp(seljUsed, 'all') 
		seljUsed = reshape(seld, [1,length(seld)]);
	else
		error('Wrong setting for parameter ''seljUsed''');
	end
end

if strcmp(axesUsed, 'body') || strcmp(axesUsed, 'bodyAngles')
	% Keep all the rigid modes
	if ~isempty(seljUsed)
		seljUsed = [1:length(selRigid), seljUsed(seljUsed>length(selRigid))];
	else
		seljUsed = 1:length(selRigid);
	end
end

seld = seljUsed;

nd = length(seld);
seldRigid = intersect(seld, selRigid);
seldElastic = setdiff(seld, seldRigid);
nRigid   = length(seldRigid  ); % number of rigid modes in UMODES
nElastic = length(seldElastic); % number of elastic modes in UMODES

if isnan(rigidDisplacement)
	rigidDisplacement = seljUsed(seljUsed<=nRigid);
end

if isnan(rigidVelocity)
	rigidVelocity = seljUsed(seljUsed<=nRigid);
end

%-------------------------------------------------------------------------------
% Modify state-space matrices for body coordinates
%-------------------------------------------------------------------------------

% Default choice: modify aerodynamic SS system only if body coordinates are used
if isempty(modifyAeroSS)
	modifyAeroSS = strcmp(axesUsed, 'body') || strcmp(axesUsed, 'bodyAngles');
end

if modifyAeroSS
	ssmodel = ssRigidCorrection(ssmodel, dyn_model.dlm.aero.cref, rigidDOF);
end

%-------------------------------------------------------------------------------
% structural damping
%-------------------------------------------------------------------------------
SDAMP = beam_model.Param.SDAMP;

Kmm = beam_model.Struct.Kmm;

if isfield(beam_model.Struct, 'Bmm')
	Bmm = beam_model.Struct.Bmm;
else
	Bmm = zeros(ni,ni); % viscous damp
end

if (SDAMP)
	DAMP = beam_model.Damp;
	%fprintf(fid,' - Structural damping required: '); 
	if (beam_model.Param.KDAMP == 1)
		%fprintf(fid,'viscous type. \n'); 
		Bmm = modal_damp(DAMP.g{SDAMP}, DAMP.Freq{SDAMP}, DAMP.Type(SDAMP), beam_model.Param.KDAMP, ...
		                    beam_model.Struct.Mmm, beam_model.Struct.Omega./(2*pi));
	else
		fprintf(fid,'\n'); 
		error('Histeretic damping not compatible with time domain analysis.'); 
	end
else
	%fprintf(fid,' - No structural damping required.\n'); 
end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Assembly system
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Aeroelastic system
Esys.Mhh = beam_model.Struct.Mmm;
Esys.Khh = beam_model.Struct.Kmm;
Esys.Chh =                   Bmm;
Esys.nj = nj;
Esys.ne = 0;

AsysSS = ssmodel;
AsysSS.model = AsysSS.model(selMach_ss);
AsysSS.mach = AsysSS.mach(selMach_ss);

%-------------------------------------------------------------------------------
% Set acceleration output
if ~isempty(beam_model.Param.ACCELERATION)
	Uaj = dyn_model.Out.ACCELERATION(:,seljUsed);
	Esys.Uaj = Uaj;
end

ssmodel= assemblySSAEmodel(Vinf, rhoinf, l_a, Esys, AsysSS, 'ssmodel', seljUsed, AEopt.modalForces);

nx = size(ssmodel.A,1);
nInputs = size(ssmodel.B0,2);
nOutputs = size(ssmodel.D0,1);

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Applied nodal force
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

nLoad = length(beam_model.Dextload.Node);

if nLoad > 0
	UMODESIND = seld;

	Bload = zeros(nx,nLoad);
	inputNameLoad = cell(nLoad,1);

	for iLoad = 1:nLoad
		node = beam_model.Dextload.Node(iLoad);  % node index
		DOF  = beam_model.Dextload.NDOF(iLoad);  % node DOF 1->6
		Fload = squeeze(beam_model.Struct.NDispl(node, DOF, :));
		Bload(ssmodel.stateGroup.jdot, iLoad) = Fload;
		inputNameLoad{iLoad} = ['LOAD-', num2str(beam_model.Node.ID(node)), '-C', num2str(DOF)];
	end
	isLoad = true;
else
	isLoad = false;
	inputNameLoad = {};
	Bload = zeros(nx,0);
end
Dload = zeros(nOutputs,nLoad);


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Base transformation
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

T1 = eye(nx,nx);
T2 = eye(nx,nx);
T3 = zeros(nx,nx);

posRigid = [ssmodel.stateGroup.j(seldRigid),ssmodel.stateGroup.jdot(seldRigid)];


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

ssmodel.A = ssmodel.A*T1 - ssmodel.E*T3;
ssmodel.E = ssmodel.E*T2;

ssmodel.C = ssmodel.C*T1 + ssmodel.F*T3;
ssmodel.F = ssmodel.F*T2;

descrForm.E = ssmodel.E;
descrForm.A = ssmodel.A;

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
A = ssmodel.E\[ssmodel.A, ssmodel.B0, ssmodel.B1, ssmodel.B2, Bload];

Bae = A(:, nx + (1:3*nInputs+nLoad));
Aae = A(:,1:nx);

Dae = [ssmodel.D0, ssmodel.D1, ssmodel.D2, Dload];

% Inputs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
inputGroup = [];
inputName = {};
selectInputs = zeros(3*nInputs+nLoad,1);
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
	nGust = 0;
	isGust = false;
	inputGroup.gust = [];
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
		name_base = dyn_model.Out.surfaceName{beam_model.Surfdef.LabelID(iContr)};
		inputName(position_new) = {name_base, [name_base,'-dot'], [name_base, '-ddot']};
	end
	isSurf = true;
else
	nSurf = 0;
	isSurf = false;
	inputGroup.controlSurf = [];
end

if isLoad
	position_new = nAEinputs + (1:nLoad);
	inputGroup.load = position_new;
	inputName(position_new) = inputNameLoad;
	selectInputs(3*nInputs + (1:nLoad)) = position_new;
	nAEinputs = nAEinputs + nLoad;
else
	inputGroup.load = [];
end

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

% Modal aero forces
if isfield(ssmodel.outputGroup, 'm')
	position = ssmodel.outputGroup.m;
	nMod = length(position);
	outputGroup.modalForce = nAEoutputs + (1:nMod);

	for iMod = 1:nMod
		outputName{nAEoutputs + iMod} = ['modForce-', int2str(iMod)];
	end
	nAEoutputs = nAEoutputs + nMod;

	CC = ssmodel.C(position,:) + ssmodel.F(position,:)*Aae;
	DD =       Dae(position,:) + ssmodel.F(position,:)*Bae;

	C = [C; CC];
	D = [D; DD];
else
	outputGroup.modalForce = [];

end

% Modal displacement
if ~isempty(AEopt.modalDisp)

	if isstr(AEopt.modalDisp) 
		if strcmp(lower(AEopt.modalDisp), 'all')
			AEopt.modalDisp = 1:nj;
		else
			error('Invalid choice for ''modalDisp'' parameter');
		end
	end

	lm = length(AEopt.modalDisp);
	position = ssmodel.stateGroup.j(AEopt.modalDisp);

	outputGroup.modalDisp = nAEoutputs + (1:lm);

	for iMod = 1:lm
		outputName{nAEoutputs + iMod} = ['modalDisp-', int2str(AEopt.modalDisp(iMod))];
	end
	nAEoutputs = nAEoutputs + lm;

	CC = zeros(lm, size(ssmodel.A,1)); CC(:,position) = eye(lm,lm);
	DD = zeros(lm, size(D,2));

	C = [C; CC];
	D = [D; DD];

else
	outputGroup.modalDisp = [];
end

% Modal velocity
if ~isempty(AEopt.modalVel)

	if isstr(AEopt.modalVel) 
		if strcmp(lower(AEopt.modalVel), 'all')
			AEopt.modalVel = 1:nj;
		else
			error('Invalid choice for ''modalVel'' parameter');
		end
	end


	lm = length(AEopt.modalVel);
	position = ssmodel.stateGroup.jdot(AEopt.modalDisp);

	outputGroup.modalVel = nAEoutputs + (1:lm);

	for iMod = 1:lm
		outputName{nAEoutputs + iMod} = ['modalVel-', int2str(AEopt.modalDisp(iMod))];
	end
	nAEoutputs = nAEoutputs + lm;

	CC = zeros(lm, size(ssmodel.A,1)); CC(:,position) = eye(lm,lm);
	DD = zeros(lm, size(D,2));

	C = [C; CC];
	D = [D; DD];
else
	outputGroup.modalVel = [];
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
	delay_delta = beam_model.Surfdef.X0;
	delay_delta = reshape(delay_delta, [1,nSurf]);
end

% gusts
if isGust
	% Aero mesh coordinates and reference point
	np = beam_model.Aero.lattice_dlm.np;
	midPoint = beam_model.Aero.lattice_dlm.COLLOC(1:np,:)*cref;
	X0min = min(midPoint(:,1));


	delay_vg = (X0min - beam_model.Gust.X0)./Vinf;
	delay_vg = reshape(delay_vg, [1,nGust]);
end


inputDelay = zeros(nSurf*3+nGust*3+nLoad,1);


if isSurf
	posSurf = inputGroup.controlSurf;
	inputDelay(posSurf) = reshape(repmat(delay_delta, [3,1]), [3*nSurf,1]);
end

if isGust
	posGust = inputGroup.gust;
	inputDelay(posGust) = reshape(repmat(delay_vg,    [3,1]), [3*nGust,1]);
end

if isLoad
	posLoad = inputGroup.load;
	delay_load = beam_model.Dextload.X0;
	inputDelay(posLoad) = delay_load;
end



% Assembly final model +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Select rigid degree of freedom
select = ones(nx,1);
select(ssmodel.stateGroup.j(seldRigid)) = 0;
select(ssmodel.stateGroup.jdot(seldRigid)) = 0;

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
