%
%***********************************************************************************************************************
%  FFAST Project
%
%  NeoSYM
%
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Lorenzo Travaglini   <>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by FFAST partners.
%  Any usage without an explicit authorization may be persecuted.
%
%***********************************************************************************************************************
%
%   Author: Lorenzo Travaglini
%           Luca Cavagna
%           Federico fonte 12-04-2016
%***********************************************************************************************************************
%
% Get the transfer function for a free aircraft
%

%-------------------------------------------------------------------------------------------------------------------------
% SUPORT and PARAM MACH/RHOREF/VREF are mandatory.
% MSELECT must include rigid modes from 1->6 to have aero coefficients.
% UMODES and FMODES sets are not mandatory.
% UMODES should at least include the rigid modes of interest, i.e. 3-5 for symmetric flight, 2-4-6 for asymmetric flight.
% FMODES should not include rigid body modes. Their damping will be carried out through a dedicated process to 
% estimate phugoid, short period, roll, duth roll and spiral modes.
% The values of phugoid are rather inaccurate due to the inviscid aero model.
%
%
function getSystemTF(varargin)

global dyn_model
global fl_model
%

beam_model = dyn_model.beam;
%
NPFREQ = 4;
T1XR = 20;
T1XE = 20;
%
fid = beam_model.Param.FID;
%
if (isempty(beam_model.Param.GUST) && isempty(beam_model.Param.SURFDEF) && isequal(beam_model.Param.LOAD, 0))
  fprintf(fid,'\n No input force defined. Solution ended.\n');
  return;
end
%

FmaxUser = [];
DfUser = [];
rhoUser = [];
VinfUser = [];
MachUser = [];

% Check user defined inputs
if nargin > 0
	PARAM = varargin;
	for n=1:2:length(PARAM);
		switch PARAM{n}
		case 'Fmax'
			FmaxUser = PARAM{n+1};
			fprintf(fid,' - User defined frequency range Fmax: %g Hz.\n', FmaxUser);
		case 'Df'
			DfUser = PARAM{n+1};
			fprintf(fid,' - User defined frequency step Df: %g Hz.\n', DfUser);
		case 'rho'
			rhoUser = PARAM{n+1};
		case 'Vinf'
			VinfUser = PARAM{n+1};
		case 'Mach'
			MachUser = PARAM{n+1};
		otherwise
			error('Unknown input parameter name, valid parameter names are ''Fmax'' and ''Df''.');
		end
	end
end
%
%
if ~beam_model.Param.SOL == 146 
  error('\n SOL 146 must be specified in input file.\n');
end


% Initialize time values
Df   = 0; % Tmax      = 0;
Fmax = 0; % Dt        = 0;
%
if isempty(VinfUser)
	VREF = beam_model.Param.VREF;
else
	VREF = VinfUser;
end

if isempty(rhoUser)
	RHOREF = beam_model.Param.RHOREF;
else
	RHOREF = rhoUser;
end
RHO_VG = beam_model.Param.RHO_VG;

if isempty(MachUser)
	MREF = beam_model.Param.MACH;
else
	MREF = MachUser;
end

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

nk = length(dyn_model.dlm.aero.k);
cref = dyn_model.dlm.aero.cref;
bref = beam_model.Aero.ref.b_ref;
sref = beam_model.Aero.ref.S_ref;
MODACC = beam_model.Param.MODACC;
SDAMP = beam_model.Param.SDAMP;

fprintf(fid,'\n'); 
fprintf(fid,' - Reference chord:    %g m.\n', cref); 
fprintf(fid,' - Reference span:     %g m.\n', bref); 
fprintf(fid,' - Reference surface:  %g m2.\n', sref); 
if (MODACC == 0)
  fprintf(fid,' - Acceleration modes required.\n'); 
end
if (SDAMP)
  DAMP = beam_model.Damp;
  fprintf(fid,' - Structural damping required: '); 
  if (beam_model.Param.KDAMP == 1)
    fprintf(fid,'viscous type.\n'); 
  else
    fprintf(fid,'complex stiffness.\n'); 
  end
else
  fprintf(fid,' - No structural damping required.\n'); 
end
% dofs
ndof   = beam_model.Info.ndof;
ndof2  = beam_model.Info.ndof2;
% Aero mesh coordinates and reference point
np = beam_model.Aero.lattice_dlm.np;
midPoint = beam_model.Aero.lattice_dlm.COLLOC(1:np,:)*cref;
X0min = min(midPoint(:,1));
Xsup = beam_model.WB.CG;


%-------------------------------------------------------------------------------
% MODAL BASE
%           

rigidDof = find(beam_model.Struct.rigidDOF(:,3));
rigidModes = beam_model.Struct.rigidDOF(rigidDof,3);

NMODES = size(beam_model.Struct.Mmm,1);
% Modes used in eig and flutter
if (isempty(beam_model.Param.MSELECT))
  mbase = beam_model.Struct.ID;
else
  mbase = beam_model.Param.MSELECT;
end
% Modes used in dynamic solution
% UMODESIND index from UMODES TO MBASE to reduce matrices
if (isempty(beam_model.Param.UMODES))
  UMODESIND = [1:NMODES]; 
else
  if(~all(ismember(beam_model.Param.UMODES, mbase)))
    index = find(ismember(beam_model.Param.UMODES, mbase)==0);
    fprintf(fid,' UMODE %d not present in current modal base.\n',...
            beam_model.Param.UMODES(index)); 
  end
  [dummy, dummy, UMODESIND] = intersect(beam_model.Param.UMODES, mbase);
end
UMODES = mbase(UMODESIND);
nUMODES = length(UMODES);
% get rigid modes
[UMODESE, index] = setdiff(UMODES, rigidModes);
% Find rigid modes involved            
UMODESR = setdiff(UMODES, UMODESE);
nr = length(UMODESR); % number of rigid modes in UMODES
ne = length(UMODESE); % number of elastic modes in UMODES
% Find mode index in UMODES array
[dummy, dummy, UMODESRLOC] = intersect(UMODESR, UMODES);
[dummy, dummy, UMODESELOC] = intersect(UMODESE, UMODES);
% Find mode index in MBASE array
UMODESRGLOB =  UMODESIND(1:nr);
UMODESEGLOB =  UMODESIND(nr+1:end);
%
side_mode   = find(UMODES == 2);
plunge_mode = find(UMODES == 3);
roll_mode   = find(UMODES == 4);
pitch_mode  = find(UMODES == 5);
%
%  dyn_model.dlm.data.Qhh(:,UMODESRGLOB(side_mode),1,MINDEX) = 0;
%  dyn_model.dlm.data.Qhh(:,UMODESRGLOB(plunge_mode),1,MINDEX) = 0;
%  dyn_model.dlm.data.Qhh(:,UMODESRGLOB(roll_mode),1,MINDEX) = 0;
%
%-------------------------------------------------------------------------------
% update matrices to account for damping
Kmm = beam_model.Struct.Kmm;
Bmm = zeros(NMODES); % viscous damp
Gmm = zeros(NMODES); % complex stiff
if (SDAMP)
  if (beam_model.Param.KDAMP==1)
    Bmm = modal_damp(DAMP.g{SDAMP}, DAMP.Freq{SDAMP}, DAMP.Type(SDAMP), beam_model.Param.KDAMP, ...
                        beam_model.Struct.Mmm, beam_model.Struct.Omega./(2*pi));
  else
    Kmm = Kmm + 1i*beam_model.Struct.Gmm*Kmm;
    Gmm = beam_model.Struct.Gmm;
  end
end
%-------------------------------------------------------------------------------
%
% check load SET, if symmetric or antisymmetric or neither
%
symLoad  = 1;
NsymLoad = 1;
nLOAD    = 0;
nSURF    = 0;
nGUST    = 0;
% nodal inputs
if  ~isequal(beam_model.Param.LOAD, 0)
  nLOAD = length(beam_model.Param.LOAD);
  fextdof = beam_model.Dextload.NDOF(beam_model.Param.LOAD);
  symLoad   = all(fextdof == 3 | fextdof == 5);
  NsymLoad  = all(fextdof == 2 | fextdof == 4 | fextdof == 6);
end
% controls
if  ~isempty(beam_model.Param.SURFDEF)
  surfLoad = zeros(length(beam_model.Param.SURFDEF),1);
  nSURF = length(beam_model.Param.SURFDEF);
  for i = 1: nSURF % choose if longitudinal or latero directional control
    [dummy, surfLoad(i)] = max(abs(dyn_model.dlm.data.Qhd(1:6,beam_model.Param.SURFDEF(i))));
  end
  symLoad  = all(surfLoad == 3 | surfLoad == 5);
  NsymLoad = all(surfLoad == 2 | surfLoad == 4 | surfLoad == 6);
end
% gusts
if ~isempty(beam_model.Param.GUST)
  nGUST = length(beam_model.Param.GUST);
  symLoad = all([symLoad , all(beam_model.Gust.DIR(beam_model.Param.GUST) == 3)]);
  NsymLoad = all([NsymLoad, all(beam_model.Gust.DIR(beam_model.Param.GUST) == 2)]);
end

% Get the names of the inputs
inputNames = {};
for iLoad = 1:nLOAD
	inputNames{iLoad} = ['load', num2str(beam_model.Param.LOAD(iLoad))];
end
for iSurf = 1:nSURF
	inputNames{nLOAD+iSurf} = ['surf', num2str(beam_model.Param.SURFDEF(iSurf))];
end
for iGust = 1:nGUST
	inputNames{nLOAD+nSURF+iGust} = ['gust', num2str(beam_model.Param.GUST(iGust))];
end

posLoad = 1:nLOAD;
posSurf = nLOAD + (1:nSURF);
posGust = nLOAD + nSURF + (1:nGUST);


inputName = {};
position = 0;
for iLoad = 1:nLOAD
	position = position + 1;
	inputName{position} = ['load', num2str(iLoad)];
end

for iSurf = 1:nSURF
	position = position + 1;
	%inputName{position} = beam_model.Aero.Trim.MasterSurf{beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF(iSurf))};
	inputName{position} = dyn_model.Out.surfaceName{beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF(iSurf))};
end

for iGust = 1:nGUST
	position = position + 1;
	inputName{position} = ['alphag', num2str(iGust)];
end

%-------------------------------------------------------------------------------
defom = find(UMODESE>6); ndefom = length(UMODESE(defom));
TimeDefo = zeros(ndefom,1);
DFREQ = zeros(ndefom,1);
if (isempty(beam_model.Param.FMODES))
	flwbase = mbase;
else
	flwbase = beam_model.Param.FMODES;
end
%
if ~isempty(FmaxUser)
	Fmax = FmaxUser;
end
if ~isempty(DfUser)
	Df = DfUser;
end
%
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% DAMPING ESTIMATE for frequency step
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (Df==0)
  %
  %   DAMPING AVAILABLE
  %
  if (RHOREF == RHO_VG)
    %
    %     RIGID MODES
    %
    sigma_ph = interp1(dyn_model.flu.Res_rigid.Velocity, dyn_model.flu.Res_rigid.data(MINDEX).RealE{1}, VREF, 'linear', 'extrap');   
    sigma_sp = interp1(dyn_model.flu.Res_rigid.Velocity, dyn_model.flu.Res_rigid.data(MINDEX).RealE{2}, VREF, 'linear', 'extrap');     
    %
    sigma_dr = interp1(dyn_model.flu.Res_rigid.Velocity, dyn_model.flu.Res_rigid.data(MINDEX).RealE{5}, VREF, 'linear', 'extrap');       
    %
    fprintf('\n');
    fprintf(fid,' - RIGID MODES: time to 1/%g amplitude:\n', T1XR); 
    symTime = log(1/T1XR) / sigma_sp;
    fprintf(fid,'\t - Short period:     %g s.\n', symTime); 
    NsymTime = log(1/T1XR) / sigma_dr;
    fprintf(fid,'\t - Dutch roll:       %g s.\n', NsymTime); 
    %
    %     ELASTIC MODES
    %
    fprintf(fid,' - ELASTIC MODES: time to 1/%g amplitude:\n', T1XE); 
    for i = 1:ndefom
      ind = find(UMODESE(defom(i)) == flwbase);
      if (isempty(ind))
        error(['Mode ',num2str(UMODESE(defom(i))),' not defined in FMODES set.']);
      end
      [Vel, indVel] = unique(dyn_model.flu.Res.data(MINDEX).Velocity{ind});
      TimeDefo(i) = log(1/T1XE)/(spline(Vel,dyn_model.flu.Res.data(MINDEX).RealE{ind}(indVel),VREF));
      DFREQ(i) = (spline(Vel,dyn_model.flu.Res.data(MINDEX).Freq{ind}(indVel),VREF)); 
      % Print summary to help in choosing modal base
      fprintf(fid,'\t - Mode %3d: %8g s, %8g Hz.\n', UMODESE(defom(i)), TimeDefo(i), DFREQ(i)); 
    end
  else
    %
    %   NEW DAMPING CALCULATION
    %
    %
    %     RIGID MODES
    %
    counter = 99;
    RigRes = []; RigRes.data = [];
    RStab_Der = [];
    RStab_Der = get_dynder(1, dyn_model.dlm.aero.k, cref, cref*2, bref, sref, dyn_model.dlm.data.Qhh(:,:,:,MINDEX), 0, []);
    [dummy, RigRes] = rig_modes(fid, -2, RHOREF, VREF, MREF, cref, bref, sref,...
                     beam_model.WB.MCG(1,1), diag(beam_model.WB.MCG(4:6,4:6)), ...
                     RStab_Der, 1, RigRes);
    sigma_ph = RigRes.data.RealE{1}(1);   
    sigma_sp = RigRes.data.RealE{2}(1);    
    %
    sigma_dr = RigRes.data.RealE{5}(1);      
    %
    fprintf(fid,' - RIGID MODES: time to 1/%g amplitude:\n', T1XR); 
    symTime = log(1/T1XR) / sigma_sp;
    fprintf(fid,'\t - Short period:     %g s.\n', symTime); 
    NsymTime = log(1/T1XR) / sigma_dr;
    fprintf(fid,'\t - Dutch roll:       %g s.\n', NsymTime); 
    fprintf(fid,' - RIGID MODES: frequency at VREF %g m/s:\n', VREF); 
    fprintf(fid,'\t - Short period:     %g Hz.\n', RigRes.data.Freq{2}(1)); 
    fprintf(fid,'\t - Dutch roll:       %g Hz.\n', RigRes.data.Freq{5}(1)); 
    %
    %     ELASTIC MODES
    %
    fl_model.Res = [];
    fl_model.Res.data = [];
    fl_model.Res.Env = [];
    vmax =  beam_model.Param.VMAX;
    vstep = vmax/beam_model.Param.NVSTEP;
    % run flutter
    Hamf = zeros(NMODES,NMODES,nk*2);
    Hamf(:,:,1:2:nk*2) = dyn_model.dlm.data.Qhh(:,:,1:nk,MINDEX);
    [VF, HF] = run_flutter(fid, beam_model.Struct.Mmm, Gmm*beam_model.Struct.Kmm, beam_model.Struct.Kmm, beam_model.Struct.Omega./(2*pi), ...
                           beam_model.Struct.ID, Hamf, dyn_model.dlm.aero.k, MREF, cref, mbase, UMODESE(defom), ...
                           RHOREF, [vstep, vmax], beam_model.Param.AUTOPLOT, counter, 1);
    fprintf(fid,' - ELASTIC MODES: time to 1/%g amplitude:\n', T1XE); 
    for i = 1:ndefom
      [Vel, indVel] = unique(fl_model.Res.data.Velocity{i});
      TimeDefo(i) = log(1/T1XE)/(spline(Vel, fl_model.Res.data.RealE{i}(indVel),VREF));
      DFREQ(i) = (spline(Vel, fl_model.Res.data.Freq{i}(indVel),VREF));
      % Print summary to help in choosing modal base
      fprintf(fid,'\t - Mode %d: %g s, \n', UMODESE(defom(i)), TimeDefo(i)); 
    end
    fprintf(fid,' - ELASTIC MODES: frequency at VREF %g m/s:\n', VREF); 
    for i = 1:ndefom
      fprintf(fid,'\t - Mode %d: %g Hz, \n', UMODESE(defom(i)), DFREQ(i)); 
    end
  end

  if (Fmax == 0)
    Fmax = max(DFREQ) * NPFREQ;
  end
  fprintf(fid,' - Maximum frequency: %g Hz.\n', Fmax);

  T_defo = max(TimeDefo);                
  fprintf(fid,' - Elastic modes period TE set to %g s.\n', T_defo); 
  if symLoad
    fprintf(fid,' - Rigid modes period TR set to %g s.\n', symTime); 
    TimeDelay = max([symTime;TimeDefo]);
  elseif NsymLoad
    fprintf(fid,' - Rigid modes period TR set to %g s.\n', NsymTime); 
    TimeDelay = max([NsymTime;TimeDefo]);
  else
    TimeDelay = max([symTime; NsymTime; TimeDefo]);
  end
  Df = 1/TimeDelay;
  fprintf(fid,' - Frequency step Df = 1/max(TR,TE): %g Hz.\n', Df);
end
% compute dt starting from model's frequency
if (Fmax==0)
	Fmax = max(beam_model.Struct.Omega(UMODESIND)) * NPFREQ /2/pi;
	fprintf(fid,' - Maximum frequency: %g Hz.\n', Fmax);
end
%-------------------------------------------------------------------------------

% Number of frequency steps
nf = ceil(Fmax/Df);
Fmax_actual = nf*Df;

Fvect = (0:nf-1)'*Df;
Omega = 2*pi * Fvect;
k =  Omega'*dyn_model.dlm.aero.cref/VREF;

fprintf(fid,' - Frequency sample points: %d\n', nf);

%
% Check aero model
%
KMAX     = 2*pi*Fmax_actual*dyn_model.dlm.aero.cref/VREF;
KMIN_DLM = min((2*pi/beam_model.Param.DLM_NP)./beam_model.Aero.lattice_dlm.dx);
fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,' - Frequency step         : %g Hz\n', Df);
fprintf(fid,' - Max frequency FMAX     : %g Hz\n', Fmax_actual);
fprintf(fid,' - Max red. frequency KMAX: %g\n', KMAX);
fprintf(fid,'\n');
fprintf(fid,'\n');
if (KMAX > KMIN_DLM)
	fprintf(fid,'   ### Warning: aerodynamic mesh too coarse to sample KMAX with %d points.\n', beam_model.Param.DLM_NP);
	fprintf(fid,'                Aerodynamic maximum red. frequency: %g (%g Hz). \n', KMIN_DLM, KMIN_DLM*VREF/dyn_model.dlm.aero.cref/2/pi);
end



%-------------------------------------------------------------------------------
% FORCING TERMS
%-------------------------------------------------------------------------------

% control input
if  ~isempty(beam_model.Param.SURFDEF)

	Hac = zeros(nUMODES, nSURF, nk);
	if MODACC==0
		Hdc = zeros(ndof, nSURF, nk);
	end

	for i = 1: nSURF
		Hac(:,i,:) = dyn_model.dlm.data.Qhd(UMODESIND,beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF(i)),:, MINDEX);
		if (MODACC==0)
			Hdc(:,i,:) = dyn_model.dlm.data.Qnd(:,beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF(i)), :, MINDEX);
		end
	end

	if ~isempty(beam_model.Param.AEROFORCE)
		CPsurf = dyn_model.dlm.data.Cp(beam_model.Param.AEROFORCE, NMODES + beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF(i)), :, MINDEX);

		[CPsurf_R, CPsurf_I] = aeroMatrixSpline_get(CPsurf, dyn_model.dlm.aero.k);
	end

	if ~isempty(beam_model.Param.HINGEFORCE)
		HFsurf = dyn_model.dlm.data.Qdd(beam_model.Param.HINGEFORCE,beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF), :, MINDEX);

		[HFsurf_R, HFsurf_I] = aeroMatrixSpline_get(HFsurf, dyn_model.dlm.aero.k);
	end

	%   Aero forces - rigid
	selectColumns = NMODES+beam_model.Surfdef.LabelID(beam_model.Param.SURFDEF);
	[Cy_surf, Cz_surf, Cl_surf, Cm_surf, Cn_surf] = ...
	                 rigid_aero_force(dyn_model.dlm.data.Cp(:,selectColumns,:,MINDEX),...
	                                  dyn_model, cref, bref, sref, Xsup);
end


% Gust
if ~isempty(beam_model.Param.GUST)

	% Here Qhg means U'*S*invD
	% Hag is the true gust input matrix Hag = U'*S*invD*exp(jk/c*(x-x0))*normal
	% normal is gust.dwnwash

	Fg = zeros(size(midPoint, 1), nGUST, nf);
	DXgust = zeros(size(midPoint, 1), nGUST);

	if MODACC==0
		Hdg = zeros(ndof, nGUST, nk);
	end

	for i = 1:nGUST
		DXgust(:,i) = midPoint(:,1) - beam_model.Gust.X0(beam_model.Param.GUST(i));
	end

	Qhg = dyn_model.gust.Qhg(UMODESIND,:,:,MINDEX);

	if (MODACC==0)
		Qdg = dyn_model.gust.Qng(:,:,:,MINDEX);
	end

	if ~isempty(beam_model.Param.AEROFORCE)
		CPgust = dyn_model.gust.Cp(beam_model.Param.AEROFORCE,:,:,MINDEX);

		[CPgust_R, CPgust_I] = aeroMatrixSpline_get(CPgust, dyn_model.dlm.aero.k);
	end

	if ~isempty(beam_model.Param.HINGEFORCE)
		HFgust = dyn_model.gust.Qdg(beam_model.Param.HINGEFORCE,:,:,MINDEX);

		[HFgust_R, HFgust_I] = aeroMatrixSpline_get(HFgust, dyn_model.dlm.aero.k);
	end

	%   Aero forces
	[Cy_gust, Cz_gust, Cl_gust, Cm_gust, Cn_gust] = rigid_aero_force(dyn_model.gust.Cp(:,:,:,MINDEX), dyn_model, cref, bref, sref, Xsup);


	[Qhg_R, Qhg_I] = aeroMatrixSpline_get(Qhg, dyn_model.dlm.aero.k);
	if (MODACC==0)
		[Qdg_R, Qdg_I] = aeroMatrixSpline_get(Qdg, dyn_model.dlm.aero.k);
	end

end

%  gravitational terms
Kmg = zeros(nUMODES,nUMODES);

% Assembly aerodynamic matrices
% HAM: modal aero 
Ham = dyn_model.dlm.data.Qhh(UMODESIND,UMODESIND,:,MINDEX);
[Ham_R, Ham_I] = aeroMatrixSpline_get(Ham, dyn_model.dlm.aero.k);

% HAC, QHG: modal aero for inputs
[Hac_R, Hac_I] = aeroMatrixSpline_get(Hac, dyn_model.dlm.aero.k);

if (MODACC == 0)
	% HDM: nodal aero
	Hdm = dyn_model.dlm.data.Qnh(:,UMODESIND,:,MINDEX);
	[Hdm_R, Hdm_I] = aeroMatrixSpline_get(Hdm, dyn_model.dlm.aero.k);

	% HDC, QDG: nodal aero for inputs
	[Hdc_R, Hdc_I] = aeroMatrixSpline_get(Hdc, dyn_model.dlm.aero.k);
end

if ~isempty(beam_model.Param.AEROFORCE)
	CPmode = dyn_model.dlm.data.Cp(beam_model.Param.AEROFORCE, UMODESIND, :, MINDEX);
	[CPmode_R, CPmode_I] = aeroMatrixSpline_get(CPmode, dyn_model.dlm.aero.k);
end

if ~isempty(beam_model.Param.HINGEFORCE)
	HFmode = dyn_model.dlm.data.Qdh(beam_model.Param.HINGEFORCE, UMODESIND, :, MINDEX);
	[HFmode_R, HFmode_I] = aeroMatrixSpline_get(HFmode, dyn_model.dlm.aero.k);
end

% Aero forces
[Cy_mode, Cz_mode, Cl_mode, Cm_mode, Cn_mode] = rigid_aero_force(dyn_model.dlm.data.Cp(:,UMODESIND,:,MINDEX), ...
                                                  dyn_model, cref, bref, sref, Xsup);



%-------------------------------------------------------------------------------
% Frequency response  
%-------------------------------------------------------------------------------

nInput = nLOAD + nSURF + nGUST;

Q      = zeros(nUMODES, nInput, nf);
Qdot   = zeros(nUMODES, nInput, nf);
Qddot  = zeros(nUMODES, nInput, nf);


Cyome_mode = zeros(1,nInput,nf);
Czome_mode = zeros(1,nInput,nf);
Clome_mode = zeros(1,nInput,nf);
Cmome_mode = zeros(1,nInput,nf);
Cnome_mode = zeros(1,nInput,nf);



Bmm(UMODESRGLOB,UMODESRGLOB) = Bmm(UMODESRGLOB,UMODESRGLOB) ./ 1i;

Omega(1) = 0.1;
for i = 2 : nf
	MASS = zeros(nUMODES,nUMODES);
	MASS = [1i*Omega(i).*beam_model.Struct.Mmm(UMODESRGLOB,UMODESRGLOB),    zeros(nr, ne); ...
	        zeros(ne,nr),    -Omega(i)^2*beam_model.Struct.Mmm(UMODESEGLOB,UMODESEGLOB)];

	% add aero mass terms
	HAM = aeroMatrixSpline_eval(k(i), dyn_model.dlm.aero.k, Ham, Ham_R, Ham_I);
	HAM(:,UMODESRLOC) = imag(HAM(:,UMODESRLOC))/Omega(i) - 1i * real(HAM(:,UMODESRLOC)) / Omega(i);

	Finput = zeros(nUMODES, nInput);

	% control surface
	if nSURF
		HAC = aeroMatrixSpline_eval(k(i), dyn_model.dlm.aero.k, Hac, Hac_R, Hac_I);
		Finput(:,posSurf) = qinfty*HAC;
	end

	% Gust contribution
	if nGUST > 0
		Fg(:,:,i) = exp(-DXgust * (1i*k(i)/cref)) .* dyn_model.gust.dwnwash;
		QHG = aeroMatrixSpline_eval(k(i), dyn_model.dlm.aero.k, Qhg, Qhg_R, Qhg_I);
		Finput(:,posGust) = qinfty*QHG *Fg(:,:,i);
	end

	% external force
	if (nLOAD)
		Fload = set_modal_extload(beam_model.Struct.NDispl(:,:,UMODESIND), beam_model.Param.LOAD, beam_model.Dextload, ones(nLOAD,1));
		Finput(:,posLoad) = Fload;
	end

	% system dynamics
	Aow = MASS + 1i*Omega(i)*Bmm(UMODESIND,UMODESIND) + Kmm(UMODESIND,UMODESIND) + Kmg - qinfty*HAM;

	% response
	Q(:,:,i) = Aow \ Finput;

	% recover modal velocities
	Qdot(UMODESRLOC,:,i)  = Q(UMODESRLOC,:,i);
	Qdot(UMODESELOC,:,i)  = (1i*Omega(i)) .* Q(UMODESELOC,:,i);

	% determine rigid mode amplitudes
	Q(UMODESRLOC,:,i)     = Qdot(UMODESRLOC,:,i) / (1i*Omega(i));

	% recover modal accelerations
	Qddot(:,:,i) = (1i*Omega(i)) .* Qdot(:,:,i);

	% Rigid aero coefficients
	Cyome_mode(:,:,i) = aero_interp_vec(Cy_mode, 2, k(i), dyn_model.dlm.aero.k)*Q(:,:,i);
	Czome_mode(:,:,i) = aero_interp_vec(Cz_mode, 2, k(i), dyn_model.dlm.aero.k)*Q(:,:,i);
	Clome_mode(:,:,i) = aero_interp_vec(Cl_mode, 2, k(i), dyn_model.dlm.aero.k)*Q(:,:,i);
	Cmome_mode(:,:,i) = aero_interp_vec(Cm_mode, 2, k(i), dyn_model.dlm.aero.k)*Q(:,:,i);
	Cnome_mode(:,:,i) = aero_interp_vec(Cn_mode, 2, k(i), dyn_model.dlm.aero.k)*Q(:,:,i);
end

%-------------------------------------------------------------------------------
% Save data
%-------------------------------------------------------------------------------
dyn_model.Res.Fvect = Fvect;

dyn_model.Res.inputNames = inputNames;
dyn_model.Res.inputName = inputName;

% Modal response
dyn_model.Res.Q     = Q;
dyn_model.Res.Qd    = Qdot;
dyn_model.Res.Qddot = Qddot;

% save rigid aero response
dyn_model.Res.Cy_mode = Cyome_mode;
dyn_model.Res.Cz_mode = Czome_mode;
dyn_model.Res.Cl_mode = Clome_mode;
dyn_model.Res.Cm_mode = Cmome_mode;
dyn_model.Res.Cn_mode = Cnome_mode;


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% STRUCTURAL OUTPUTS
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

dyn_model.Res.DISP         = zeros(length(beam_model.Param.DISP),         6,    nInput, nf);
dyn_model.Res.VELOCITY     = zeros(length(beam_model.Param.VELOCITY),     6,    nInput, nf);
dyn_model.Res.ACCELERATION = zeros(length(beam_model.Param.ACCELERATION), 6,    nInput, nf);
dyn_model.Res.IFORCE       = zeros(length(beam_model.Param.IFORCE),       6, 2, nInput, nf);
dyn_model.Res.IFORCEBE     = zeros(length(beam_model.Param.IFORCEBE),     6, 2, nInput, nf);

for iInput = 1:nInput

	Qinput = permute(dyn_model.Res.Q(:,iInput,:), [1,3,2]);
	Qdinput = permute(dyn_model.Res.Qd(:,iInput,:), [1,3,2]);
	Qddinput = permute(dyn_model.Res.Qddot(:,iInput,:), [1,3,2]);


	%-------------------------------------------------------------------------------
	% DISPLACEMENT
	if ~isempty(beam_model.Param.DISP)
		dyn_model.Res.DISP(:,:,iInput,:) = reshape(dyn_model.Out.DISP*Qinput,...
		                                           [length(beam_model.Param.DISP),6,1,nf]);
	end

	%-------------------------------------------------------------------------------
	% VELOCITY
	if ~isempty(beam_model.Param.VELOCITY)
		dyn_model.Res.VELOCITY(:,:,iInput,:) = reshape(dyn_model.Out.VELOCITY*Qdinput,...
		                                               [length(beam_model.Param.VELOCITY),6,1,nf]);
	end

	%-------------------------------------------------------------------------------
	% ACCELERATION
		if ~isempty(beam_model.Param.ACCELERATION)
		dyn_model.Res.ACCELERATION(:,:,iInput,:) = reshape(dyn_model.Out.ACCELERATION*Qddinput,...
		                                                   [length(beam_model.Param.ACCELERATION),6,1,nf]);
	end

	%-------------------------------------------------------------------------------
	% BAR INTERNAL LOAD
	if ~isempty(beam_model.Param.IFORCE)
		force = reshape(dyn_model.Out.IFORCE*Qinput, [6,2,length(beam_model.Param.IFORCE),nf]);

		dyn_model.Res.IFORCE(:,:,:,iInput,:) = permute(force, [3,1,2,5,4]);
	end
	%-------------------------------------------------------------------------------
	% BEAM INTERNAL LOAD
	if ~isempty(beam_model.Param.IFORCEBE)
		force = reshape(dyn_model.Out.IFORCEBE*Qinput, [6,2,length(beam_model.Param.IFORCEBE),nf]);

		dyn_model.Res.IFORCEBE = permute(force, [3,1,2,5,4]);
	end
end



%-------------------------------------------------------------------------------
%
% AERO OUTPUTS
%
%-------------------------------------------------------------------------------
% HF responce
if ~isempty(beam_model.Param.HINGEFORCE)

	nHinge = length(beam_model.Param.HINGEFORCE);
	dyn_model.Res.HINGEFORCE = zeros(nHinge, nInput, nf);

	% Modal contribution
	for iFreq = 1:nf
		HFinterpolated_mode = aeroMatrixSpline_eval(k(iFreq), dyn_model.dlm.aero.k, HFmode, HFmode_R, HFmode_I);
		dyn_model.Res.HINGEFORCE(:,:,iFreq) = qinfty*HFinterpolated_mode*dyn_model.Res.Q(:,:,iFreq);
	end

	% Add direct surface contribution, if surface is present
	if nSURF > 0
		for iFreq = 1:nf
			HFinterpolated_surf = aeroMatrixSpline_eval(k(iFreq), dyn_model.dlm.aero.k, HFsurf, HFsurf_R, HFsurf_I);
			dyn_model.Res.HINGEFORCE(:,posSurf,iFreq) = dyn_model.Res.HINGEFORCE(:,posSurf,iFreq) ...
			                                          + qinfty*HFinterpolated_surf;
		end
	end

	% Add direct gust contribution, if gust is present
	if nGUST > 0
		for iFreq = 1:nf
			HFinterpolated_gust = aeroMatrixSpline_eval(k(iFreq), dyn_model.dlm.aero.k, HFgust, HFgust_R, HFgust_I);
			dyn_model.Res.HINGEFORCE(:,posGust,iFreq) = dyn_model.Res.HINGEFORCE(:,posGust,iFreq) ...
			                                          + qinfty*HFinterpolated_gust*Fg(:,:,iFreq);
		end
	end
end
return
%-------------------------------------------------------------------------------
% Controls
  if  ~isempty(beam_model.Param.SURFDEF)
    Cyome_surf = zeros(1,nt);
    Czome_surf = zeros(1,nt);
    Cmome_surf = zeros(1,nt);
    Clome_surf = zeros(1,nt);
    Cnome_surf = zeros(1,nt);
    for i = 2 : nt
      Cyome_surf(:,i) = sum(aero_interp_vec(Cy_surf, 2, k(i), dyn_model.dlm.aero.k) * Load(1:nSURF,i));
      Czome_surf(:,i) = sum(aero_interp_vec(Cz_surf, 2, k(i), dyn_model.dlm.aero.k) * Load(1:nSURF,i));
      Clome_surf(:,i) = sum(aero_interp_vec(Cl_surf, 2, k(i), dyn_model.dlm.aero.k) * Load(1:nSURF,i));
      Cmome_surf(:,i) = sum(aero_interp_vec(Cm_surf, 2, k(i), dyn_model.dlm.aero.k) * Load(1:nSURF,i));
      Cnome_surf(:,i) = sum(aero_interp_vec(Cn_surf, 2, k(i), dyn_model.dlm.aero.k) * Load(1:nSURF,i));
    end
    Cyome_surf = [Cyome_surf,conj(Cyome_surf(:,end:-1:2))];
    Czome_surf = [Czome_surf,conj(Czome_surf(:,end:-1:2))];
    Clome_surf = [Clome_surf,conj(Clome_surf(:,end:-1:2))];
    Cmome_surf = [Cmome_surf,conj(Cmome_surf(:,end:-1:2))];
    Cnome_surf = [Cnome_surf,conj(Cnome_surf(:,end:-1:2))];
    dyn_model.Res.Cy_surf = ifft(Cyome_surf); dyn_model.Res.Cy_surf = dyn_model.Res.Cy_surf(:,1:nt);
    dyn_model.Res.Cz_surf = ifft(Czome_surf); dyn_model.Res.Cz_surf = dyn_model.Res.Cz_surf(:,1:nt);
    dyn_model.Res.Cl_surf = ifft(Clome_surf); dyn_model.Res.Cl_surf = dyn_model.Res.Cl_surf(:,1:nt);
    dyn_model.Res.Cm_surf = ifft(Cmome_surf); dyn_model.Res.Cm_surf = dyn_model.Res.Cm_surf(:,1:nt);
    dyn_model.Res.Cn_surf = ifft(Cnome_surf); dyn_model.Res.Cn_surf = dyn_model.Res.Cn_surf(:,1:nt);
  end
%-------------------------------------------------------------------------------
% GUST
  if  ~isempty(beam_model.Param.GUST)
    Cyome_gust = zeros(1,nt);
    Czome_gust = zeros(1,nt);
    Cmome_gust = zeros(1,nt);
    Clome_gust = zeros(1,nt);
    Cnome_gust = zeros(1,nt);
    for i = 2 : nt
      Cyome_gust(:,i) = sum(aero_interp_vec(Cy_gust, 2, k(i), dyn_model.dlm.aero.k)*reshape(Load(nSURF+1:nSURF+nGUST*np,i), np, nGUST));
      Czome_gust(:,i) = sum(aero_interp_vec(Cz_gust, 2, k(i), dyn_model.dlm.aero.k)*reshape(Load(nSURF+1:nSURF+nGUST*np,i), np, nGUST));
      Clome_gust(:,i) = sum(aero_interp_vec(Cl_gust, 2, k(i), dyn_model.dlm.aero.k)*reshape(Load(nSURF+1:nSURF+nGUST*np,i), np, nGUST));
      Cmome_gust(:,i) = sum(aero_interp_vec(Cm_gust, 2, k(i), dyn_model.dlm.aero.k)*reshape(Load(nSURF+1:nSURF+nGUST*np,i), np, nGUST));
      Cnome_gust(:,i) = sum(aero_interp_vec(Cn_gust, 2, k(i), dyn_model.dlm.aero.k)*reshape(Load(nSURF+1:nSURF+nGUST*np,i), np, nGUST));
    end
    Cyome_gust = [Cyome_gust,conj(Cyome_gust(:,end:-1:2))];
    Czome_gust = [Czome_gust,conj(Czome_gust(:,end:-1:2))];
    Clome_gust = [Clome_gust,conj(Clome_gust(:,end:-1:2))];
    Cmome_gust = [Cmome_gust,conj(Cmome_gust(:,end:-1:2))];
    Cnome_gust = [Cnome_gust,conj(Cnome_gust(:,end:-1:2))];
    dyn_model.Res.Cy_gust = ifft(Cyome_gust); dyn_model.Res.Cy_gust =dyn_model.Res.Cy_gust(:,1:nt);
    dyn_model.Res.Cz_gust = ifft(Czome_gust); dyn_model.Res.Cz_gust =dyn_model.Res.Cz_gust(:,1:nt);
    dyn_model.Res.Cl_gust = ifft(Clome_gust); dyn_model.Res.Cl_gust =dyn_model.Res.Cl_gust(:,1:nt);
    dyn_model.Res.Cm_gust = ifft(Cmome_gust); dyn_model.Res.Cm_gust =dyn_model.Res.Cm_gust(:,1:nt);
    dyn_model.Res.Cn_gust = ifft(Cnome_gust); dyn_model.Res.Cn_gust =dyn_model.Res.Cn_gust(:,1:nt);
  end
  fprintf(fid,'\n');
%-------------------------------------------------------------------------------
% ACCELERATION MODES
%
keyboard
  if (MODACC == 0)
    if (~isempty(beam_model.Param.IFORCE) || ~isempty(beam_model.Param.IFORCEBE))
%
      NODEST = beam_model.Node;
      if ~isempty(beam_model.RBE2.ID)
        NODEST.DOF = NODEST.DOF2;
      end
      M = beam_model.Struct.M; 
      K = beam_model.Struct.K;
      Mu = M * beam_model.Struct.V;
%     Apply SUPORT
      [D, Kll, Klr, Krr, Krl, rdof, ldof, KEPS] = get_suport_shapes(K, NODEST, beam_model.Param.SUPORT, beam_model.Param.EPS);
      invKll = inv(Kll);
%
      U = zeros(ndof2, nt);
%
      Fexta = zeros(ndof, 1);
      Fextl = zeros(ndof, 1);
%
      for i = 2 : nt
%
        Fext  = zeros(ndof, 1);
%       External inputs along FE mesh (gust + controls) : HAG * LOAD
        if (nSURF || nGUST)
          Fexta  =  qinfty * aero_interp_vec(Hdl,2, k(i), dyn_model.dlm.aero.k) * Load(:,i);
          Fext = Fexta;
        end
%       add external contribution
        if (nLOAD)
          Fextl = set_nodal_extload(beam_model.Node.DOF, beam_model.Param.LOAD, beam_model.Dextload, LoadE(:,i));
          Fext = Fext + Fextl;
        end
%       Aero forces along FE mesh : HAM * U * q
        Faeroel = -qinfty * aero_interp_vec(Hdm,2, k(i), dyn_model.dlm.aero.k)* Q(:,i);
%       reduce RBE2 dofs from ndof to ndfo2
        if ~isempty(beam_model.RBE2.ID)
          Faeroel = RBE2Assembly2(beam_model.RBE2, Faeroel);
          Fext    = RBE2Assembly2(beam_model.RBE2, Fext);
        end
%       Forces due to qddot   
        Fqddot = -Omega(i)^2 * Mu(:,UMODESIND) *  Q(:,i);
%       rhs
        Ftot = Fext - Fqddot - Faeroel;
%       solve system
        U(ldof,i) = invKll * Ftot(ldof);
%
      end
%
      U = [U, conj(U(:,end:-1:2))];
      u = zeros(ndof2, nt*2-1);
      SOL = zeros(ndof, nt);
%     transform ldof nodal displacements
      for i = 1 : length(ldof)
        u(ldof(i),:) = ifft(U(ldof(i),:));
      end
%     Get complete dof displacements field
      if ~isempty(beam_model.RBE2.ID)
        for i=1:nt
          SOL(:,i) = RBE2disp(beam_model.RBE2, u(:,i), ndof);
        end  
      else
        SOL = u;
      end
%     Assembly nodal displacements
      ngrid = beam_model.Info.ngrid;
      nbar =  beam_model.Info.nbar;
      nbeam =  beam_model.Info.nbeam;
  	  NDispl = zeros(ngrid, 6, nt);
%     store nodal displacement
      for n = 1:ngrid 
	      dof = beam_model.Node.DOF(n, 1:6);
	      index = find(dof);
	      if ~isempty(index)
          for i=1:nt
		        NDispl(n, index, i) = SOL(dof(index), i);
          end
	      end
      end
%
%      assembly BAR contributions directly in the undeformed position
      if ~isempty(beam_model.Param.IFORCE)
        CForces = zeros(2, 6, nbar); CStrains = zeros(2, 6, nbar); CSM = [];
        nb = length(beam_model.Param.IFORCE);
        dyn_model.Res.MODACC.IFORCE = zeros(6,2,nb);
        for i=1:nt
          [CForces, CStrains, CStresses, CSM] = ...
          get_bar_force_strain(beam_model.Info.nbar, beam_model.Bar, beam_model.PBar, beam_model.Mat, beam_model.Node, ...
          NDispl(:,:,i), beam_model.Param.FUSE_DP);
%         export only required bar
          for k=1:nb
            dyn_model.Res.MODACC.IFORCE(:,:,k,i) = CForces(:,:,beam_model.Param.IFORCE(k))';
          end
        end
      end
%     assembly BEAM contributions directly in the undeformed position
      if ~isempty(beam_model.Param.IFORCEBE)
        CForces = zeros(2, 6, nbeam);  CStrains = zeros(2, 6, nbeam); CSM = [];
        nb = length(beam_model.Param.IFORCEBE);
        dyn_model.Res.MODACC.IFORCEBE = zeros(6,2,nb,nt);
        for i=1:nt
          [CForces, CStrains, CStresses, CSM] = ...
          get_bar_force_strain(beam_model.Info.nbeam, beam_model.Beam, beam_model.PBeam, beam_model.Mat, beam_model.Node, ...
          NDispl(:,:,i), beam_model.Param.FUSE_DP);
          for k=1:nb
            dyn_model.Res.MODACC.IFORCEBE(:,:,k,i) = CForces(:,:,beam_model.Param.IFORCEBE(k))';
          end
        end
      end
%     save displacements
      if ~isempty(beam_model.Param.DISP)
        dyn_model.Res.MODACC.DISP = NDispl(beam_model.Param.DISP,:,:);
      else
        dyn_model.Res.MODACC.DISP = NDispl;
      end
    else
      fprintf(fid, '\n\t### Warning: acceleration modes required. No Bar/beam elements given in IFORCE/IFORCEBE set.');
      fprintf(fid, '\n\t    Process skipped.');
    end
  end % MODE ACC
%            









return




%-------------------------------------------------------------------------------
% Determine generalized forces for external input
function Q = set_modal_extload(NDispl, PLOAD, LOAD, LoadE)
  nm = size(NDispl,3);
  Q = zeros(nm,1);
  nLOAD = length(PLOAD);
  for n=1:nLOAD
    ind = PLOAD(n);
    node = LOAD.Node(ind); % node index
    DOF = LOAD.NDOF(ind);  % node DOF 1->6
%   gen forces
    Q(:,1) = Q(:,1) + squeeze(NDispl(node, DOF, :) * LoadE(n,1));
  end
return
%-------------------------------------------------------------------------------
% Apply external loads on FE mesh
function F = set_nodal_extload(DOF, PLOAD, LOAD, LoadE)
  ndof = max(max(DOF));
  F = zeros(ndof,1);
  nLOAD = length(PLOAD);
  for n=1:nLOAD
    ind = PLOAD(n);
    node = LOAD.Node(ind); % node index
    NDOF = LOAD.NDOF(ind); % node DOF 1->6
    index = DOF(node, NDOF); % dof
    F(index,1) = F(index,1) + LoadE(n,1);
  end
return

