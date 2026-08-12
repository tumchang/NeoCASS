function [FL_Eig, Vvect] = solve_linflutt_cont(varargin)
%
%
% Compute aeroelastic roots - continuation method.
%
%
%-------------------------------------------------------------------------------
% 30-06-2016
%

global dyn_model

fl_model = dyn_model.flu;
beam_model = dyn_model.beam;
fid = beam_model.Param.FID;

dtpos = find('.' == beam_model.Param.FILE);
headname = beam_model.Param.FILE(1:dtpos(end)-1);

machVariation = false;

Vmin = fl_model.param.VMIN;
Vmax = fl_model.param.VMAX;
DV = fl_model.param.DVEL;

selUsed = [];
selTracked = [];
selVisualized = [];

method = 'continuation'; % 'pointwise';

axesUsed = 'inertial';
angleCoord = false;

e0 = [0,0,0];
v0norm = [-1, 0, 0];
edot0norm = [0,0,0];

% Check user defined inputs
PARAM = varargin;
for n=1:2:length(PARAM);
	switch PARAM{n}
	case 'Vmin'
		Vmin = PARAM{n+1};
	case 'Vmax'
		Vmax = PARAM{n+1};
	case 'DV'
		DV = PARAM{n+1};
	case 'selUsed'
		selUsed = PARAM{n+1};
	case 'selTracked'
		selTracked = PARAM{n+1};
	case 'selVisualized'
		selVisualized = PARAM{n+1};
	case 'method'
		method = PARAM{n+1};
	case 'axesUsed'
		axesUsed = PARAM{n+1};
	case 'e0'
		e0 = PARAM{n+1};
	case 'v0norm'
		v0norm = PARAM{n+1};
	case 'edot0norm'
		edot0norm = PARAM{n+1};
	otherwise
		error('Unrecognized option %s', PARAM{n});
	end
end

% Check compatibility among options
if strcmp(axesUsed, 'body') || strcmp(axesUsed, 'bodyAngles')
	if strcmp(method, 'continuation')
		error(['Continuation method not available with body coordinates: ', ...
		       'Use the option ''method'' with parameter ''pointwise''.']);
	end
end

if strcmp(axesUsed, 'bodyAngles')
	angleCoord = true;
end

% Get reference values
% Reference chord has already been divided by two
l_a  = dyn_model.dlm.aero.cref;
Vref   = beam_model.Param.VREF;
rhoRef = beam_model.Param.RHOREF;
rho_vg = beam_model.Param.RHO_VG;

Mref   = beam_model.Param.MACH;
aref = Vref/Mref;
qinfty = 0.5*rhoRef*Vref^2;

fprintf(fid,' - Reference density:          %g Kg/m3.\n', rhoRef); 
fprintf(fid,' - Reference length:           %g m.    \n', l_a); 
fprintf(fid,' - Reference sound speed:      %g m/s.  \n', aref); 


if machVariation
	fprintf(fid,' - Computation performed with Mach number variation.\n');
	selMach_freq = 1:length(dyn_model.dlm.aero.M);
else
	fprintf(fid,' - Reference Mach number:      %g.      \n', Mref);
	[~, selMach_freq] = min(abs(Mref - dyn_model.dlm.aero.M));
	fprintf(fid,'    - Mach number Hag   :      %g.      \n', dyn_model.dlm.aero.M(selMach_freq));
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
if isfield(beam_model.Struct, 'rigidDOF');
	rigidDOF = beam_model.Struct.rigidDOF;
else
	rigidDOF = zeros(6,3);
	rigidDOF(:,3) = 1:6;
end


seldRigid   = rigidDOF(rigidDOF(:,3)>0,3);
seldElastic = setdiff(seld, seldRigid);
nRigid   = length(seldRigid); % number of rigid modes in UMODES
nElastic = length(seldElastic); % number of elastic modes in UMODES
scaleRigid = diag(diag(1./sqrt(beam_model.Struct.Mmm(seldRigid,seldRigid))));
scaleMatrix = blkdiag(scaleRigid, eye(nElastic,nElastic));

%-------------------------------------------------------------------------------
% structural damping
%-------------------------------------------------------------------------------
SDAMP = beam_model.Param.SDAMP;

if (SDAMP)
	DAMP = beam_model.Damp;
	fprintf(fid,'\n - Structural damping required: '); 
	if (beam_model.Param.KDAMP == 1)
		fprintf(fid,'viscous type.'); 
	else
		error('Histeretic damping not compatible with time domain analysis.'); 
	end
else
	fprintf(fid,'\n - No structural damping required.'); 
end

% update matrices to account for damping
Kmm = beam_model.Struct.Kmm;
Bmm = zeros(ni,ni); % viscous damp
Gmm = zeros(ni,ni); % complex stiff
if (SDAMP)
	if (beam_model.Param.KDAMP==1)
		Bmm = modal_damp(DAMP.g{SDAMP}, DAMP.Freq{SDAMP}, DAMP.Type(SDAMP), beam_model.Param.KDAMP, ...
		                 beam_model.Struct.Mmm, beam_model.Struct.Omega./(2*pi));
	end
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
Esys.rigidDOF = beam_model.Struct.rigidDOF;

AsysFreq.kvect = dyn_model.dlm.aero.k;
AsysFreq.Mvect = dyn_model.dlm.aero.M(selMach_freq);
AsysFreq.Qhh = dyn_model.dlm.data.Qhh(:,:,:,selMach_freq);

switch axesUsed
case 'inertial'
	flutterPKfunction = @(V) flutterPK_o0(V, rhoRef, aref, l_a, Esys, AsysFreq);
	flightCond = [];
case {'body', 'bodyAngles'}
	flutterPKfunction = @(V) flutterPKbody_o0(V, rhoRef, aref, l_a, Esys, AsysFreq, selj, ...
	                                          e0, v0norm, edot0norm, angleCoord);

	flightCond.e0 = e0;
	flightCond.v0norm = v0norm;
	flightCond.edot0norm = edot0norm;
	flightCond.bref = l_a;
	flightCond.cref = l_a;
otherwise
	error('Invalid choice for ''axesUsed'' parameter')
end


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Mode tracking
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

fprintf('\n');

Vvect = Vmin:DV:Vmax;
nV = length(Vvect);

if isempty(selUsed)
	selUsed = selj;
end
if isempty(selTracked)
	selTracked = selUsed;
end


FL_Eig_Cont = zeros(nV,nj);

switch method
case 'test'
	FL_Eig(:,selTracked) = flutterTrackingPK(Vvect, rhoRef, aref, l_a, Esys, AsysFreq, selTracked, axesUsed, flightCond);
case 'pointwise'
	for iV = 1:nV
		fprintf(' - Vinf = %5.1f m/s (%3d/%3d)\r', Vvect(iV), iV, nV);
		[svect, Q] = flutterPKfunction(Vvect(iV));
		FL_Eig(iV,:) = svect;
	end
	fprintf('\n');
	fprintf('\n');
case 'continuation'
	FL_Eig(:,selTracked) = flutterTrackingCont(Vvect, rhoRef, aref, l_a, Esys, AsysFreq, selTracked, selUsed);
end


return
