function [ssAEmodel, aero, ssmodel, descrForm] = getAEmodelCorrected(dyn_model, ssmodel, varargin)
%
%
%
% TODO : remove modifyAeroSS option
%
% The aeroelastic interaction could be defined using a standard
% routine for the generation of a closed loop system, provided that
% the structural system has the additional inputs:
% - modal force
% - surface hinge moment
%
%-------------------------------------------------------------------------------
% 23-01-2017
%


beam_model = dyn_model.beam;
fid = beam_model.Param.FID;

% Default values
axesUsed = 'bodyAngles';

e0 = [0,0,0];
v0OverVinf = [-1,0,0];
edot0 = [0,0,0];

seljUsed = 'all';

rigidDisplacement = nan;
rigidVelocity = nan;
modifyAeroSS = true;
AEopt.modalForces = false; % Provides aerodynamic modal forces as output
AEopt.modalDisp = [];
AEopt.modalVel = [];
AEopt.aeroAngles = [];
AEopt.acce = -1;
AEopt.velo = -1;
AEopt.disp = -1;
AEopt.barforce = -1;
aeroCoef = [];


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
	case 'aeroAngles'
		AEopt.aeroAngles = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'acce'
		AEopt.acce = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'velo'
		AEopt.velo = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'disp'
		AEopt.disp = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'barforce'
		AEopt.barforce = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'v0overVinf'
		v0overVinf = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'e0'
		e0 = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'edot0'
		e0 = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	case 'aeroCoef'
		aeroCoef = PARAM{n+1};
		stillToCheck([n,n+1]) = 0;
	end
end

[Vinf, rhoinf, Minf] = setFlightCondition(refValues, PARAM{find(stillToCheck)});

% The reference chord has already been divided by 2
l_a = cref;


v0 = v0OverVinf*Vinf;

aero.l_a = l_a;
aero.Vinf = Vinf;
aero.rhoinf = rhoinf;
aero.Minf = Minf;

qinf = 0.5*aero.rhoinf*aero.Vinf^2;
ta = aero.l_a/aero.Vinf;
 
% TODO : automatic check based on aerodynamic coefficients provided
if strcmp(axesUsed, 'bodyAngles')
	useAngle = true;
else
	useAngle = false;
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

% Modes used for dynamic analysis
if isempty(beam_model.Param.UMODES)
	seld = 1:ni;
else
	seld = beam_model.Param.UMODES;
end

selj = mbase;
nj = length(selj);

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
nj = length(seljUsed);

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

% Process output requests
if AEopt.acce == -1 % Use already set values
	ACCELERATION = dyn_model.Out.ACCELERATION;
	isAcce = ~isempty(beam_model.Param.ACCELERATION);
	positionAcce = beam_model.Param.ACCELERATION;
else
	nAcce = length(AEopt.acce);
	positionAcce = zeros(nAcce,1);
	for iAcce = 1:nAcce
		positionAcce(iAcce) = find(beam_model.Node.ID==AEopt.acce(iAcce));
	end
	ACCELERATION = reshape(dyn_model.beam.Struct.NDispl(positionAcce,:,:),nAcce*6,ni,1);
	isAcce = (nAcce>0);
end

if AEopt.velo == -1 % Use already set values
	VELOCITY = dyn_model.Out.VELOCITY;
	isVelo = ~isempty(beam_model.Param.VELOCITY);
	positionVelo = beam_model.Param.VELOCITY;
else
	nVelo = length(AEopt.velo);
	positionVelo = zeros(nVelo,1);
	for iVelo = 1:nVelo
		positionVelo(iVelo) = find(beam_model.Node.ID==AEopt.velo(iVelo));
	end
	VELOCITY = reshape(dyn_model.beam.Struct.NDispl(positionVelo,:,:),nVelo*6,ni,1);
	isVelo = (nVelo>0);
end

if AEopt.disp == -1 % Use already set values
	DISP = dyn_model.Out.DISP;
	isDisp = ~isempty(beam_model.Param.DISP);
	positionDisp = beam_model.Param.DISP;
else
	nDisp = length(AEopt.disp);
	positionDisp = zeros(nDisp,1);
	for iDisp = 1:nDisp
		positionDisp(iDisp) = find(beam_model.Node.ID==AEopt.disp(iDisp));
	end
	DISP = reshape(dyn_model.beam.Struct.NDispl(positionDisp,:,:),nDisp*6,ni,1);
	isDisp = (nDisp>0);
end

% Process output requests
if AEopt.barforce == -1 % Use already set values
	IFORCE = dyn_model.Out.IFORCE;
	isBarforce = ~isempty(beam_model.Param.IFORCE);
	positionBarforce = beam_model.Param.IFORCE;
else
	nBarforce = length(AEopt.barforce);
	positionBarforce = zeros(nBarforce,1);
	for iBarforce = 1:nBarforce
		if isempty(find(beam_model.Bar.ID==AEopt.barforce(iBarforce)))
			error('Bar %d requested for output not found\n', AEopt.barforce(iBarforce))
		end
		positionBarforce(iBarforce) = find(beam_model.Bar.ID==AEopt.barforce(iBarforce));
	end
	IFORCE = get_auto_internal_load(positionBarforce', dyn_model.beam.Bar, dyn_model.beam.PBar, dyn_model.beam.Mat, ...
	                                dyn_model.beam.Node, dyn_model.beam.Struct.NDispl);
	isBarforce = (nBarforce>0);
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
% Assembly Structural system
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Aeroelastic system
Esys.Mhh = beam_model.Struct.Mmm(seljUsed,seljUsed);
Esys.Khh = beam_model.Struct.Kmm(seljUsed,seljUsed);
Esys.Chh =                   Bmm(seljUsed,seljUsed);
ne = 0;
nh = nj;

% Set acceleration output
if isAcce
	Uaj = ACCELERATION(:,seljUsed);
	Esys.Uaj = Uaj;
end

% Assembly the structural system
E = [  eye(nh,nh), zeros(nh,nh);
     zeros(nh,nh),     Esys.Mhh];


A = [zeros(nh,nh), eye(nh,nh);
        -Esys.Khh,  -Esys.Chh];

% Define inputs ----------------------------------------------------------------

inputGroup = [];
inputName = {};
nInputs = 0;

B = zeros(2*nh,0);

% Applied nodal force
nLoad = length(beam_model.Dextload.Node);

if nLoad > 0
	Fload = zeros(nj,nLoad);

	inputGroup.load = nInputs + (1:nLoad);

	for iLoad = 1:nLoad
		node = beam_model.Dextload.Node(iLoad);  % node index
		DOF  = beam_model.Dextload.NDOF(iLoad);  % node DOF 1->6
		Fload(:,iLoad) = squeeze(beam_model.Struct.NDispl(node, DOF, :));
		inputName{nInputs+iLoad} = ['LOAD-', num2str(beam_model.Node.ID(node)), '-C', num2str(DOF)];
	end
	nInputs = nInputs + nLoad;

	B = [B, [zeros(nh,nLoad); Fload; zeros(ne,ne)] ];

	isLoad = true;
else
	isLoad = false;
end

% Define Steady loads ----------------------------------------------------------

sloadGroup = [];
sloadName = {};
nSload = 0;

B0 = zeros(2*nh,0);
f0 = zeros(0,1);


% Steady loads define fake input matrices:
% xdot = A*x + B*u + b
%    y = C*x + D*u + d
% And cannot be used directly: they must be linearized

% Gravitational load (mass-proportional force field)
nGrav = size(beam_model.Param.GRAV,2);

if nGrav==3 && size(beam_model.Param.GRAV,1)~=3;
	GRAV = beam_model.Param.GRAV';
	nGrav = size(GRAV,2);
else
	GRAV = beam_model.Param.GRAV;
end

if nGrav > 0

	% Get the gravitational generalized force
	% Use the motion of the SUPORT for the definition of the 
	% gravitational load.
	gravLoadMat = beam_model.Struct.V(:,seljUsed)'*beam_model.Struct.M*beam_model.Struct.V(:,1:3);


	sloadGroup.grav = nSload + (1:nGrav);

	for iGrav = 1:nGrav
		sloadName{nSload+iGrav} = ['GRAV-', num2str(iGrav)];
	end
	nSload = nSload + nGrav;

	B0 = [B0, [zeros(nh,3*nGrav); repmat(gravLoadMat, [1,nGrav]); zeros(ne,3*nGrav)]];
	f0 = [f0; GRAV];
end



% Define outputs ---------------------------------------------------------------
outputGroup = [];
outputName = {};
nOutputs = 0;

F = [zeros(0,nh), zeros(0,nh)];
C = [zeros(0,nh), zeros(0,nh)];
D = zeros(0,nInputs);
D0 = zeros(0,3*nSload);

% Load recovery
if isfield(Esys, 'Msh')
	error('Load recovery not yet implemented');
end

% Accelerations
if isfield(Esys, 'Uaj')
	la = size(Esys.Uaj,1);

	nAcc = la;
	outputGroup.accel = nOutputs + (1:nAcc);

	% Get node ID and DOF
	nodeID = beam_model.Node.ID(positionAcce);
	nNodes = length(nodeID);
	nodeIDlist = reshape(reshape(nodeID, [nNodes,1])*ones(1,6), [nNodes*6,1]);
	dofList = reshape(ones(nNodes,1)*(1:6), [nNodes*6,1]);

	for iAcc = 1:nAcc
		outputName{nOutputs + iAcc} = ['ACC-', int2str(nodeIDlist(iAcc)), '-C', int2str(dofList(iAcc))];
	end
	nOutputs = nOutputs + nAcc;

	Uah = zeros(la,nh);
	Uah(:,1:nj) = Esys.Uaj;

	Ca = [zeros(la,nh), zeros(la,nh)];
	Fa = [zeros(la,nh), Uah];
	Da = zeros(la,nInputs);
	D0a = zeros(la,3*nSload);

	F = [F; Fa];
	C = [C; Ca];
	D = [D; Da];
	D0 = [D0; D0a];
else
	nAcc = 0;
	outputGroup.accel = [];
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

	outputGroup.modalDisp = nOutputs + (1:lm);

	for iMod = 1:lm
		outputName{nOutputs + iMod} = ['modalDisp-', int2str(AEopt.modalDisp(iMod))];
	end
	nOutputs = nOutputs + lm;


	Cm = zeros(lm,2*nh); 
	Cm(:,AEopt.modalDisp) = eye(lm,lm);

	F = [F; zeros(lm,2*nh)];
	C = [C; Cm];
	D = [D; zeros(lm,nInputs)];
	D0 = [D0; zeros(lm,3*nSload)];

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

	outputGroup.modalVel = nOutputs + (1:lm);

	for iMod = 1:lm
		outputName{nOutputs + iMod} = ['modalVel-', int2str(AEopt.modalVel(iMod))];
	end
	nOutputs = nOutputs + lm;

	Cm = zeros(lm,2*nh); 
	Cm(:,nh + AEopt.modalVel) = eye(lm,lm);

	F = [F; zeros(lm,2*nh)];
	C = [C; Cm];
	D = [D; zeros(lm,nInputs)];
	D0 = [D0; zeros(lm,3*nSload)];

else
	outputGroup.modalVel = [];
end


% Displacements
if ~isempty(beam_model.Param.DISP)

	% Get node ID and DOF
	nodeID = beam_model.Node.ID(positionDisp);
	nNodes = length(nodeID);
	nodeIDlist = reshape(reshape(nodeID, [nNodes,1])*ones(1,6), [nNodes*6,1]);
	dofList = reshape(ones(nNodes,1)*(1:6), [nNodes*6,1]);

	nDisp = 6*nNodes;
	outputGroup.displ = nOutputs + (1:nDisp);

	for iDisp = 1:nDisp
		outputName{nOutputs + iDisp} = ['DISP-', int2str(nodeIDlist(iDisp)), '-C', int2str(dofList(iDisp))];
	end
	nOutputs = nOutputs + nDisp;

	Uj = DISP(:,seljUsed);
	Cm = zeros(nDisp,2*nh); Cm(:,1:nj) = Uj;

	F = [F; zeros(nDisp,2*nh)];
	C = [C; Cm];
	D = [D; zeros(nDisp,nInputs)];
	D0 = [D0; zeros(nDisp,3*nSload)];

else
	nDisp = 0;
	outputGroup.displ = [];

end


% Velocities
if ~isempty(beam_model.Param.VELOCITY)

	% Get node ID and DOF
	nodeID = beam_model.Node.ID(positionVelo);
	nNodes = length(nodeID);
	nodeIDlist = reshape(reshape(nodeID, [nNodes,1])*ones(1,6), [nNodes*6,1]);
	dofList = reshape(ones(nNodes,1)*(1:6), [nNodes*6,1]);

	nVel = 6*nNodes;
	outputGroup.vel = nOutputs + (1:nVel);

	for iVel = 1:nVel
		outputName{nOutputs + iVel} = ['VEL-', int2str(nodeIDlist(iVel)), '-C', int2str(dofList(iVel))];
	end
	nOutputs = nOutputs + nVel;

	Uj = VELOCITY(:,seljUsed);
	Cm = zeros(nVel,2*nh); Cm(:,nh + (1:nj)) = Uj;

	F = [F; zeros(nVel,2*nh)];
	C = [C; Cm];
	D = [D; zeros(nVel,nInputs)];
	D0 = [D0; zeros(nVel,3*nSload)];

else
	nVel = 0;
	outputGroup.vel = [];

end

% Bar internal load
if ~isempty(beam_model.Param.IFORCE)

	% Get bar ID and DOF
	barID = beam_model.Bar.ID(positionBarforce);
	nBar = length(barID);
	barIDlist = reshape(repmat(reshape(barID, [1,1,nBar]), [6,2,1]), [nBar*12,1]);
	dofList   = reshape(repmat((1:6)', [1,2,nBar]), [nBar*12,1]);
	pointList = reshape(repmat((1:2), [6,1,nBar]), [nBar*12,1]);

	nForce = 12*nBar;
	outputGroup.barforce = nOutputs + (1:nForce);

	for iForce = 1:nForce
		outputName{nOutputs + iForce} = ['FORCE-BAR-', int2str(barIDlist(iForce)), '-', int2str(dofList(iForce)), '-C', int2str(pointList(iForce))];
	end
	nOutputs = nOutputs + nForce;

	Uj = IFORCE(:,seljUsed);
	Cm = zeros(nForce,2*nh); Cm(:,1:nj) = Uj;

	F = [F; zeros(nForce,2*nh)];
	C = [C; Cm];
	D = [D; zeros(nForce,nInputs)];
	D0 = [D0; zeros(nForce,3*nSload)];

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
	outputGroup.beamforce = nOutputs + (1:nForce);

	for iForce = 1:nForce
		outputName{nOutputs + iForce} = ['FORCE-BEAM-', int2str(barIDlist(iForce)), '-', int2str(dofList(iForce)), '-C', int2str(pointList(iForce))];
	end
	nOutputs = nOutputs + nForce;

	Uj = dyn_model.Out.IFORCEBE(:,seljUsed);
	Cm = zeros(nForce,2*nh); Cm(:,nh + (1:nj)) = Uj;

	F = [F; zeros(nForce,2*nh)];
	C = [C; Cm];
	D = [D; zeros(nForce,nInputs)];
	D0 = [D0; zeros(nForce,3*nSload)];

else
	outputGroup.beamforce = [];

end

stateGroup.j = 1:nj;
stateGroup.e = nj + (1:ne);
stateGroup.jdot = nh + (1:nj);
stateGroup.edot = nh + nj + (1:ne);


% TODO follower forces?
% TODO forces on EPOINT?
% TODO steady state value for Force?
% TODO allow direct definition of outputs
% TODO reduced rigid set 
% TODO reduced output set (single DOF per node)


% Express structural system in body axes

nx = 2*nh;
posRigid = [stateGroup.j(seldRigid),stateGroup.jdot(seldRigid)];

T1 = eye(nx,nx);
T2 = eye(nx,nx);
T3 = zeros(nx,nx);

[T1hat, T2hat, T3hat, Rij, Sj] = iner2body(e0, v0, edot0, useAngle);
T1(posRigid,posRigid) = T1hat;
T2(posRigid,posRigid) = T2hat;
T3(posRigid,posRigid) = T3hat;


% Output: angle of attack ------------------------------------------------------
if ~isempty(AEopt.aeroAngles)

	% TODO: allows definition of generic orientation
	Riq = Rij; 

	nNodes = length(AEopt.aeroAngles);

	Ca = zeros(2*nNodes, 2*nh);
	Fa = zeros(2*nNodes, 2*nh);
	Da = zeros(2*nNodes, nInputs);

	outputGroup.aeroangles = nOutputs + (1:2*nNodes);

	outputName = [outputName, cell(1,2*nNodes)];

	position = zeros(nNodes,1);
	for iNode = 1:nNodes
		position(iNode) = find(beam_model.Node.ID==AEopt.aeroAngles(iNode));

		outputName{nOutputs + 2*(iNode-1) + 1} = [ 'BETA-', int2str(AEopt.aeroAngles(iNode))];
		outputName{nOutputs + 2*(iNode-1) + 2} = ['ALPHA-', int2str(AEopt.aeroAngles(iNode))];

	end

	Up = dyn_model.beam.Struct.NDispl(position,:,:);

	[Cj, Cjdot] = aoaPoint(Up, rigidDOF, v0, e0, edot0, Riq, 'inertial');

	Ca(:,1:nj) = Cj(:,seljUsed);
	Ca(:,nh + (1:nj)) = Cjdot(:,seljUsed);


	F = [F; Fa];
	C = [C; Ca];
	D = [D; Da];
	D0 = [D0; zeros(2*nNodes,3*nSload)];
	nOutputs = nOutputs + 2*nNodes;

else
	outputGroup.aeroangles = [];
end


A = A*T1 - E*T3;
E = E*T2;

C = C*T1 + F*T3;
F = F*T2;

% Rotate forces/displacements in body axes
posDispl  = seldRigid(1:3);
posRot    = seldRigid(4:6);
posVel    = nh + seldRigid(1:3);
posRotVel = nh + seldRigid(4:6);

if max(abs(e0))>0
	A(posDispl,:)  = Rij'*A(posDispl,:);
	A(posRot,:)    = Rij'*A(posRot,:);
	A(posVel,:)    = Rij'*A(posVel,:);
	A(posRotVel,:) = Rij'*A(posRotVel,:);


	E(posDispl,:)  = Rij'*E(posDispl,:);
	E(posRot,:)    = Rij'*E(posRot,:);
	E(posVel,:)    = Rij'*E(posVel,:);
	E(posRotVel,:) = Rij'*E(posRotVel,:);

	B(posVel,:)    = Rij'*B(posVel,:);
	B(posRotVel,:) = Rij'*B(posRotVel,:);

	% B0 must be converted in body axes
	B0(posVel,:)    = Rij'*B0(posVel,:);
	B0(posRotVel,:) = Rij'*B0(posRotVel,:);
	B0 = B0*Rij;

	% Rotate output
	for iAcc = 1:nAcc/6
		position = outputGroup.accel(6*(iAcc-1)+(1:6));
		C(position(1:3),:) = Rij'*C(position(1:3),:);
		F(position(1:3),:) = Rij'*F(position(1:3),:);
		D(position(1:3),:) = Rij'*D(position(1:3),:);
		D0(position(1:3),:) = Rij'*D0(position(1:3),:);
		C(position(4:6),:) = Rij'*C(position(4:6),:);
		F(position(4:6),:) = Rij'*F(position(4:6),:);
		D(position(4:6),:) = Rij'*D(position(4:6),:);
		D0(position(4:6),:) = Rij'*D0(position(4:6),:);
	end

	for iVel = 1:nVel/6
		position = outputGroup.vel(6*(iVel-1)+(1:6));
		C(position(1:3),:) = Rij'*C(position(1:3),:);
		F(position(1:3),:) = Rij'*F(position(1:3),:);
		D(position(1:3),:) = Rij'*D(position(1:3),:);
		D0(position(1:3),:) = Rij'*D0(position(1:3),:);
		C(position(4:6),:) = Rij'*C(position(4:6),:);
		F(position(4:6),:) = Rij'*F(position(4:6),:);
		D(position(4:6),:) = Rij'*D(position(4:6),:);
		D0(position(4:6),:) = Rij'*D0(position(4:6),:);
	end

	for iDisp = 1:nDisp/6
		position = outputGroup.displ(6*(iDisp-1)+(1:6));
		C(position(1:3),:) = Rij'*C(position(1:3),:);
		F(position(1:3),:) = Rij'*F(position(1:3),:);
		D(position(1:3),:) = Rij'*D(position(1:3),:);
		D0(position(1:3),:) = Rij'*D0(position(1:3),:);
		C(position(4:6),:) = Rij'*C(position(4:6),:);
		F(position(4:6),:) = Rij'*F(position(4:6),:);
		D(position(4:6),:) = Rij'*D(position(4:6),:);
		D0(position(4:6),:) = Rij'*D0(position(4:6),:);
	end

	D0 = D0*Rij;

end

% Linearize steady load
for iSload = 1:nSload

	% TODO : correct for reduced rigid set

	position = 3*(iSload-1) + (1:3);

	F0load = Rij'*crossm(f0(position)) * Sj;

	DA = B0(:,position)*F0load;

	A(:,posRot) = A(:,posRot) + DA;

	DeltaC = D0(:,position)*F0load;
	C(:,posRot) = C(:,posRot) + DeltaC;

end

% Include static loads as fake inputs
Bsload = zeros(2*nh,nSload);
Dsload = zeros(nOutputs,nSload);

for iSload = 1:nSload
	position = 3*(iSload-1) + (1:3);

	Bsload(:,iSload) = B0(:,position)*f0(position);
	Dsload(:,iSload) = D0(:,position)*f0(position);

end

B = [B, Bsload];
D = [D, Dsload];
inputName = [inputName, sloadName];
inputGroup.static = nInputs + (1:nSload);
nInputs = nInputs + nSload;

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

struModel.E = E;
struModel.A = A;
struModel.B = B;
struModel.F = F;
struModel.C = C;
struModel.D = D;


struModel.inputName = inputName;
struModel.outputName = outputName;

struModel.inputGroup = inputGroup;
struModel.outputGroup = outputGroup;
struModel.stateGroup = stateGroup;

if Vinf==0
	ssAEmodel = struModel;
	descrForm = [];
	return
end

%-------------------------------------------------------------------------------
% Modify state-space matrices for body coordinates
%-------------------------------------------------------------------------------

[~, selMach_ss  ] = min(abs(Minf - ssmodel.mach));

% Default choice: modify aerodynamic SS system only if body coordinates are used
if isempty(modifyAeroSS)
	modifyAeroSS = strcmp(axesUsed, 'body') || strcmp(axesUsed, 'bodyAngles');
end

% The correction also provides a system with the static response 
% concentrated in D0, D1
if modifyAeroSS
	ssmodel = ssRigidCorrection(ssmodel, dyn_model.dlm.aero.cref, rigidDOF);
end


%-------------------------------------------------------------------------------
% Process aerodynamic forces
%-------------------------------------------------------------------------------

% Convert in body axes (partial conversion) ------------------------------------

% Generate transformation matrices
% Transformation scaled in order to allow the evaluation at several
% Mach numbers
T1 = zeros(nj,nj);
T2 = zeros(nj,nj);

[T1hat, T2hat, T3hat, Rij, Sj] = iner2body(zeros(3,1), v0, zeros(3,1), useAngle);

% TODO : reduced rigid set
T1(posDispl,posRot) = T1hat(7:9,4:6)/Vinf;
T2(posDispl,posRot) = T3hat(7:9,10:12)/Vinf;

nModels = length(ssmodel);

for iModel = 1:nModels

	nSubmodel = length(ssmodel(iModel).model);

	if isfield(ssmodel(iModel).inputGroup, 'j')
		posj = ssmodel(iModel).inputGroup.j(seljUsed);

		for iSubmodel = 1:nSubmodel

			model = ssmodel(iModel).model(iSubmodel);

			B0bar = model.B0(:,posj) + l_a*model.B1(:,posj)*T1;
			B1bar = model.B1(:,posj) + l_a*model.B2(:,posj)*T2;
                                                        
			D0bar = model.D0(:,posj) + l_a*model.D1(:,posj)*T1;
			D1bar = model.D1(:,posj) + l_a*model.D2(:,posj)*T2;

			ssmodel(iModel).model(iSubmodel).B0(:,posj) = B0bar;
			ssmodel(iModel).model(iSubmodel).B1(:,posj) = B1bar;

			ssmodel(iModel).model(iSubmodel).D0(:,posj) = D0bar;
			ssmodel(iModel).model(iSubmodel).D1(:,posj) = D1bar;

		end
	end
end


% Introduce stability derivatives
% - scale by reference surface and length
% - scale derivatives with ratio cref_aero/l_a and bref_aero/l_a
% - introduce stiffness on e if F0 are provided
% - provide names of control surfaces
% - provide SUPORT node
% - transport moments
if ~isempty(aeroCoef)
	suportID = unique(beam_model.Param.SUPORT(:,1));
	if length(suportID)>1
		error('Only a single SUPORT point supported for aero coefficient modification');
	else
		suportCoord = beam_model.Node.Coord(beam_model.Node.ID==suportID,:);
	end
	surfNames = dyn_model.Out.surfaceName(beam_model.Surfdef.LabelID);
	ssmodel = includeAeroCoef(ssmodel, aeroCoef, l_a, surfNames, suportCoord);
end


% Assembly system (apply modal forces) -----------------------------------------

% Define system
Asys = ssmodel;
Asys.model = Asys.model(selMach_ss);
Asys.mach  = Asys.mach(selMach_ss);

ns = size(struModel.A,1);
na = size(Asys.model.A,1);
nx = na + ns;

posj    = struModel.stateGroup.j;
posjdot = struModel.stateGroup.jdot;
posa    = ns + (1:na);

pickj_in = Asys.inputGroup.j(seljUsed);
pickj_ou = Asys.outputGroup.j(seljUsed);


if useAngle

	rigidDofUsed = find(rigidDOF(:,3));
	rigidModeTable = [rigidDofUsed, rigidDOF(rigidDofUsed,3)];

	rigidPos = rigidModeTable(:,2);

	posu     = rigidModeTable((rigidModeTable(:,1)==1), 2);
	posv     = rigidModeTable((rigidModeTable(:,1)==2), 2);
	posw     = rigidModeTable((rigidModeTable(:,1)==3), 2);

	position = pickj_in([posv,posw]);

	scale = Vinf*diag([1,-1]);

	Asys.model(1).B1(:,position) = Asys.model(1).B1(:,position)*scale;
	Asys.model(1).B2(:,position) = Asys.model(1).B2(:,position)*scale;
	Asys.model(1).D1(:,position) = Asys.model(1).D1(:,position)*scale;
	Asys.model(1).D2(:,position) = Asys.model(1).D2(:,position)*scale;

end


EE = zeros(nx,nx); 
EE(1:ns,1:ns) = struModel.E;

EE(posjdot,posjdot) = EE(posjdot,posjdot) - qinf*ta^2*Asys.model(1).D2(pickj_ou,pickj_in);
EE(   posa,posjdot) = EE(   posa,posjdot) - ta*Asys.model(1).B2(:,pickj_in);
EE(posa,posa) = eye(na,na);



AA = zeros(nx,nx); 
AA(1:ns,1:ns) = struModel.A;

AA(posjdot,   posj) = AA(posjdot,   posj) + qinf*Asys.model(1).D0(pickj_ou,pickj_in);
AA(posjdot,posjdot) = AA(posjdot,posjdot) + qinf*ta*Asys.model(1).D1(pickj_ou,pickj_in);
AA(posjdot,   posa) = AA(posjdot,   posa) + qinf*Asys.model(1).C(pickj_ou,:);
AA(   posa,   posj) = AA(   posa,   posj) + Asys.model(1).B0(:,pickj_in)/ta;
AA(   posa,posjdot) = AA(   posa,posjdot) + Asys.model(1).B1(:,pickj_in);
AA(posa,posa) = Asys.model(1).A/ta;

% Inputs +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


nStruInputs = size(struModel.B,2);

% Assign input Group
inputGroup = struModel.inputGroup;


% Add additional input ---------------------------------------------------------
nAeroInputsTot = size(Asys.model(1).B0,2);

% Position in the input matrix of aero system
selectAeroIn = zeros(nAeroInputsTot,1);

nInputs = nStruInputs;
nAeroInputs = 0;

inputName = [struModel.inputName, cell(1,3*nAeroInputsTot)];

% Gust input
if isfield(Asys.inputGroup, 'g')
	position = Asys.inputGroup.g;
	nGust = length(position);
	selectAeroIn(position) = nAeroInputs + (1:nGust);

	inputGroup.gust = nInputs + (1:nGust*3);
	nAeroInputs = nAeroInputs + nGust;

	for iGust = 1:nGust
		position_new = nInputs + (1:3);
		nInputs = nInputs + 3;

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

	selectAeroIn(position) = nAeroInputs + (1:nSurf);
	nAeroInputs = nAeroInputs + nSurf;

	inputGroup.controlSurf = nInputs + (1:nSurf*3);

	for iContr = 1:nSurf
		position_new = nInputs + (1:3);

		nInputs = nInputs + 3;

		name_base = dyn_model.Out.surfaceName{beam_model.Surfdef.LabelID(iContr)};
		inputName(position_new) = {name_base, [name_base,'-dot'], [name_base, '-ddot']};
	end
	isSurf = true;
else
	nSurf = 0;
	isSurf = false;
	inputGroup.controlSurf = [];
end


inputName = inputName(1:nInputs);

positions = find(selectAeroIn);
[~,sortOrder] = sort(positions);
selectAeroIn = positions(sortOrder);

posAeroIn0 = nStruInputs + (1:3:3*nAeroInputs);
posAeroIn1 = nStruInputs + (2:3:3*nAeroInputs);
posAeroIn2 = nStruInputs + (3:3:3*nAeroInputs);


BB = zeros(nx,nInputs);
BB(1:ns,1:nStruInputs) = struModel.B;

BB(posjdot,posAeroIn0) = qinf * Asys.model(1).D0(pickj_ou,selectAeroIn);
BB(posjdot,posAeroIn1) = qinf * Asys.model(1).D1(pickj_ou,selectAeroIn) * ta;
BB(posjdot,posAeroIn2) = qinf * Asys.model(1).D2(pickj_ou,selectAeroIn) * ta^2;

BB(posa,posAeroIn0) = Asys.model(1).B0(:,selectAeroIn) / ta;
BB(posa,posAeroIn1) = Asys.model(1).B1(:,selectAeroIn);
BB(posa,posAeroIn2) = Asys.model(1).B2(:,selectAeroIn) * ta;




% Outputs ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

nStruOutputs = size(struModel.C,1);

% Assign output Group
outputGroup = struModel.outputGroup;


% Add additional output --------------------------------------------------------

nAeroOutputsTot = size(Asys.model(1).C,1);

% Position in the input matrix of aero system
selectAeroOu = zeros(nAeroOutputsTot,1);

nOutputs = nStruOutputs;
nAeroOutputs = 0;

outputNameAero = cell(1,nAeroOutputsTot);

% Modal aero forces
if isfield(ssmodel.outputGroup, 'm')
	position = ssmodel.outputGroup.m;
	nMod = length(position);
	selectAeroOu(position) = nAeroOutputs + (1:nMod);
	outputGroup.modalForce = nOutputs + (1:nMod);

	for iMod = 1:nMod
		outputNameAero{nAeroOutputs + iMod} = ['modForce-', int2str(iMod)];
	end

	nAeroOutputs = nAeroOutputs + nMod;
	nOutputs = nOutputs + nMod;

else
	outputGroup.modalForce = [];
end

% Hinge moments ----------------------------------------------------------------
if isfield(ssmodel.outputGroup, 'h')
	position = ssmodel.outputGroup.h;
	nHinge = length(position);
	selectAeroOu(position) = nAeroOutputs + (1:nHinge);
	outputGroup.hingemom = nOutputs + (1:nHinge);

	for iHinge = 1:nHinge
		surfname = dyn_model.Out.surfaceName{iHinge};
		%surfname = beam_model.Aero.Trim.MasterSurf{iHinge};
		outputNameAero{nAeroOutputs + iHinge} = ['HMOM-', surfname];
	end

	nAeroOutputs = nAeroOutputs + nHinge;
	nOutputs = nOutputs + nHinge;

else
	outputGroup.hingemom = [];
end

outputName = [struModel.outputName, outputNameAero(1:nAeroOutputs)];

positions = find(selectAeroOu);
[~,sortOrder] = sort(positions);
selectAeroOu = positions(sortOrder);


posAeroOu = nStruOutputs + (1:nAeroOutputs);

CC = zeros(nOutputs,nx);
CC(1:nStruOutputs,1:ns) = struModel.C;

FF = zeros(nOutputs,nx);
FF(1:nStruOutputs,1:ns) = struModel.F;

DD = zeros(nOutputs,nInputs);
DD(1:nStruOutputs,1:nStruInputs) = struModel.D;

CC(posAeroOu,   posj) = qinf * Asys.model(1).D0(selectAeroOu,pickj_in);
CC(posAeroOu,posjdot) = qinf * Asys.model(1).D1(selectAeroOu,pickj_in)*ta;
CC(posAeroOu,   posa) = qinf * Asys.model(1).C(selectAeroOu,:);

FF(posAeroOu,posjdot) = qinf * Asys.model(1).D2(selectAeroOu,pickj_in)*ta^2;

DD(posAeroOu,posAeroIn0) = qinf * Asys.model(1).D0(selectAeroOu,selectAeroIn);
DD(posAeroOu,posAeroIn1) = qinf * Asys.model(1).D1(selectAeroOu,selectAeroIn)*ta;
DD(posAeroOu,posAeroIn2) = qinf * Asys.model(1).D2(selectAeroOu,selectAeroIn)*ta^2;


% Add gust input to angle of attack output -------------------------------------
positionOu = outputGroup.aeroangles(2:2:end); % only angle of attack
positionIn = inputGroup.gust(1:3:end);       % only gust angle, not derivatives

DD(positionOu,positionIn) = 1;


% Reshape system (remove descriptor form)
mat = EE\[AA, BB];
A = mat(:,1:nx);
B = mat(:,nx+(1:nInputs));

C = CC + FF*A;
D = DD + FF*B;


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
select(   posj(seldRigid)) = 0;
select(posjdot(seldRigid)) = 0;

select(   posj(rigidDisplacement)) = 1;
select(posjdot(rigidVelocity)) = 1;

select = find(select);

A = A(select,select);
B = B(select,:);
C = C(:,select);


ssAEmodel.A = A;
ssAEmodel.B = B;
ssAEmodel.C = C;
ssAEmodel.D = D;

ssAEmodel.inputGroup = inputGroup;
ssAEmodel.outputGroup = outputGroup;

ssAEmodel.inputName = inputName;
ssAEmodel.outputName = outputName;

ssAEmodel.inputDelay = inputDelay;

descrForm.E = EE;
descrForm.A = AA;
descrForm.B = BB;
descrForm.C = CC;
descrForm.D = DD;
descrForm.F = FF;

return
