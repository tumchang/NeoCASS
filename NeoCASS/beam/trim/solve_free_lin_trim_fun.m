%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2008 - 2011 
% 
% Sergio Ricci (sergio.ricci@polimi.it)
%
% Politecnico di Milano, Dipartimento di Ingegneria Aerospaziale
% Via La Masa 34, 20156 Milano - ITALY
% 
% This file is part of NeoCASS Software (www.neocass.org)
%
% NeoCASS is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation;
% either version 2, or (at your option) any later version.
%
% NeoCASS is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public
% License along with NeoCASS; see the file GNU GENERAL 
% PUBLIC LICENSE.TXT.  If not, write to the Free Software 
% Foundation, 59 Temple Place -Suite 330, Boston, MA
% 02111-1307, USA.
%
%
%
%***********************************************************************************************************************
%  SimSAC Project
%
%  SMARTCAD
%  Simplified Models for Aeroelasticity in Conceptual Aircraft Design  
%
%                      Sergio Ricci           <ricci@aero.polimi.it>
%                      Luca Cavagna           <cavagna@aero.polimi.it>
%                      Alessandro De Gaspari  <degaspari@aero.polimi.it>
%                      Luca Riccobene         <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%***********************************************************************************************************************
%
%   Author: Luca Cavagna, Pierangelo Masarati, DIAPM
%
%   Modification:
%   160916    F.Fonte
%
%
%***********************************************************************************************************************
function [Res, Trim, state, lattice_defo] = solve_free_lin_trim_fun(beam_model, varargin)
% use INDEX to provide trim ID card
% FLAG: 0 to export aero and struct database for restarts
% FLAG: 1 to allow restart
% FLAG: 2 to build and run
%
fid = beam_model.Param.FID; 
%***********************************************************************************************************************

% Parameters
LOAD_SCALE = 1.0;
EPS = D2R(0.001); % perturbation value to extract aerodynamic derivatives

% Default values
TRIM_INDEX = 1;
FLAG = 2;
RES = [];
%
%
nin = nargin;
%
if nin > 1
	PARAM = varargin;
	for n=1:2:length(PARAM);

		switch PARAM{n}
		case 'INDEX'
			TRIM_INDEX = PARAM{n+1};
		case 'FLAG'
			FLAG = PARAM{n+1};
		case 'RES'
			RES = PARAM{n+1};
		otherwise
			error('Unrecognized option %s', PARAM{n});
		end
	end
end


%***********************************************************************************************************************
if (isempty(find(beam_model.Param.MSOL == 144)))
	error('SOL 144 must be given in input file to run linear static analysis.');
end



nc = beam_model.Aero.geo.nc;

%
%   select trim case
%
lattice = beam_model.Aero.lattice_vlm; % already defined for null variables (alpha, beta, p q r)

    index = find(beam_model.Aero.Trim.Select(TRIM_INDEX) == beam_model.Aero.Trim.ID);

%   select external forces having the same trim ID
LOADI = beam_model.Aero.Trim.ID(index);    

if ~isempty(index)

	% Initialize the Trim struct
	Trim.ID = beam_model.Aero.Trim.ID(index);
	Trim.Type = beam_model.Aero.Trim.Type(index);
	Trim.Select = beam_model.Aero.Trim.Select(index);
	Trim.Man_index = beam_model.Aero.Trim.Man_index;
	Trim.CID = beam_model.Aero.Trim.CID;
	Trim.Mach = beam_model.Aero.Trim.Mach(index);
	Trim.ALT = beam_model.Aero.Trim.ALT(index);
	Trim.FM = beam_model.Aero.Trim.FM;
	Trim.CS = beam_model.Aero.Trim.CS;
	Trim.Link = beam_model.Aero.Trim.Link;
	Trim.NC = beam_model.Aero.Trim.NC(index);
	Trim.Symm = beam_model.Aero.Trim.Symm;
	Trim.Param = beam_model.Aero.Trim.Param(index);
	Trim.Value = beam_model.Aero.Trim.Value(index);
	Trim.Ext = beam_model.Aero.Trim.Ext;
	Trim.MINDEX = beam_model.Aero.Trim.MINDEX(index);
	Trim.Label_Select = beam_model.Aero.Trim.Label_Select(index);
	Trim.MasterSurf = beam_model.Aero.Trim.MasterSurf;

	dotpos = strfind(beam_model.Param.FILE,'.');
	outf = [beam_model.Param.FILE(1:dotpos-1), '_man_', num2str(Trim.ID),'.txt'];

	switch (Trim.Type)
	case 0
		NDOF = 6;
		STRIM = 0;
		FMDOF = [];
	case 1 % full simmetric trim
		NDOF = 3;
		STRIM = 1; 
		FMDOF = [1,3,5];
	case 2 % pitch spin
		NDOF = 1;
		STRIM = 1; 
		FMDOF = [5];
	case 3 % plunge spin
		NDOF = 1;
		STRIM = 1; 
		FMDOF = [3];
	case -1 % full anti-simmetric trim
		NDOF = 3;
		STRIM = 1; 
		FMDOF = [2,4,6];
	case -2 % roll spin
		NDOF = 1;
		STRIM = 1;  
		FMDOF = [4];
	case -3 % yaw spin
		NDOF = 1;
		STRIM = 1;  
		FMDOF = [6];
	end

	fprintf(fid,'\nSolving linear static unrestrained trim (ID %d)...\n\n', Trim.ID);


	% set flight mechanics trim params
	Trim.Extra = check_extra_param(Trim.NC, Trim.Param.data, Trim.Value.data);

	Trim.FM = get_free_body_trim_params(Trim.NC, Trim.Param.data, Trim.Value.data);

	% Define state
	state = beam_model.Aero.state;
	[state.alpha,  state.betha, ...
	 state.P, state.Q, state.R] = get_state_trim_vars(Trim.FM);

	% make sure angles are converted
	state.alpha = D2R(state.alpha);
	state.betha = D2R(state.betha);

	Trim.FM.Value(2) = D2R(Trim.FM.Value(2));
	Trim.FM.Value(3) = D2R(Trim.FM.Value(3));

	% set Tornado state struct
	state.ALT = Trim.ALT;
	[state.rho, p, T, a, mu] = ISA_h(state.ALT);
	state.AS = Trim.Mach * a;
	state.Mach(1) = Trim.Mach;
else
	error('Unable to find the required TRIM set %d.', TRIM_INDEX);
end

if nc
	Trim.CS = get_control_surf_trim_params(beam_model.Aero.geo.nc, Trim.NC, ...
	                                       Trim.Param.data, Trim.Value.data, lattice.Control);
end

% check trim variables
ncs = sum(Trim.CS.Fixed);
nfm = sum(Trim.FM.Fixed);
ne  = sum(Trim.Extra.Fixed);

if (ncs + nfm + ne) ~= Trim.NC
	error('Unable to fix trim variables. Wrong variable name given in TRIM card %d.', Trim.ID);
end


% Check Mach number of provided data (if a restart is required)
if FLAG==1 || FLAG==3
	if state.Mach~=RES.state.Mach
		fprintf(fid, 'Required Mach number different from that of the provided data, recomputing ...\n');
		FLAG = 2;
    end
	% if state.rho~=RES.state.rho
	% 	fprintf(fid, 'Required density different from that of the provided data, recomputing ...\n')
	% 	FLAG = 2;
	% end
end

%***********************************************************************************************************************
% check for duplicated AELINK labels
if (beam_model.Info.nlink) 
	[labels, i] = unique(Trim.Link.ID);
		if (length(labels) ~= beam_model.Info.nlink)

		n = [1 : beam_model.Info.nlink];
		dof = Trim.Link.ID(setdiff(n, i));

		for k=1:length(dof)

			fprintf(fid, '\n\tWarning: duplicated labels for AELINK card: %d.', Trim.Link.ID(dof(k)));

		end
 
		error('AELINK entries have duplicated labels.');

	end
end

Trim.CS.MPC = [];   % store control surfaces contraint equations
Trim.CS.Coeff = []; % store control surfaces contraint coefficients


% set output struct
Res = []; 
Res.SOL = 'Static linear unrestrained trim';
Res.FM.Value = repmat(Trim.FM.Value,2,1); % current flight mechanics solution
Res.FM.Fixed = Trim.FM.Fixed;
Res.CS.Value = Trim.CS.Value; % current control surfaces solution
Res.CS.Fixed = zeros(1,nc); % set later
Res.state.rho  = state.rho; % Tornado dummy state (changed during nonlinear solution search)
Res.state.Mach = state.Mach; % Tornado dummy state (changed during nonlinear solution search)


% set constraints for control surfaces
[Trim.CS.MPC, Trim.CS.Coeff, Res.CS.Fixed] = set_constr_eq(nc, lattice.Control, Trim.CS.Fixed, beam_model.Info.nlink, Trim.Link);

% count variables
NC_TOT = sum(Res.FM.Fixed) + sum(Res.CS.Fixed);
NTOT = length(Res.FM.Fixed) + length(Res.CS.Fixed);

% free variables
NF_TOT = NTOT - NC_TOT;

if NF_TOT ~= NDOF
	if NF_TOT<NDOF
		error('Number of degrees of freedom are less than number of DOF %d (%d).', NDOF, NF_TOT);
	else
		fprintf(fid, '\n - Non linear trim solution...');
	end
end

% Print to fil the trim parameters
outp = fopen(outf, 'w');
print_state(outp, state); 
print_attitude(outp, Res.FM);
print_trim_problem(outp, NF_TOT, NDOF);


ngrid = beam_model.Info.ngrid;
nbar  =  beam_model.Info.nbar;
nbeam =  beam_model.Info.nbeam;
ndof  =  beam_model.Info.ndof;
nbody = beam_model.Info.nbaero;
npa   = length(beam_model.Aero.lattice_vlm.COLLOC);


SPLINE_TYPE = beam_model.Info.spline_type;

% create intermediate storage struct
fprintf(fid, '\n- Setting internal database...');

% store bar internal forces
Res.Bar.CForces = zeros(2, 6, nbar);
Res.Beam.CForces = zeros(2, 6, nbeam);

% store bar internal strains and curvatures
Res.Bar.CStrains = zeros(2, 6, nbar);
Res.Beam.CStrains = zeros(2, 6, nbeam);

% store bar stresses
Res.Bar.CStresses = zeros(2, 4, nbar);
Res.Beam.CStresses = zeros(2, 4, nbeam);
Res.Bar.CSM = [];
Res.Beam.CSM = [];

% store nodal displacement
Res.NDispl = zeros(ngrid, 6);
NODEPOS = beam_model.Node.Coord;

% store updated bar rotations
Res.Bar.R = beam_model.Bar.R;
Res.Bar.Colloc = beam_model.Bar.Colloc;

% store updated beam rotations
Res.Beam.R = beam_model.Beam.R;
Res.Beam.Colloc = beam_model.Beam.Colloc;

% store updated node rotation
Res.NRd = beam_model.Node.R;
fprintf(fid, 'done.');

Res.Aero = [];                         

%***********************************************************************************************************************
%
% STRUCTUAL DATABASE
%
if FLAG ~= 1
	% run aeroelastic interpolation
	[Interp, InterpBody] = aeroelastic_interface_fun(fid, beam_model.Param, beam_model.Info, ...
	                                                 beam_model.Node, beam_model.Aero, lattice);

	% stiffness matrix   
	fprintf(fid, '\n- Assemblying stiffness matrix...');
	K = st_lin_matrix(beam_model.Info, beam_model.Node.DOF, beam_model.Node.R, beam_model.Node.Coord, beam_model.Bar, beam_model.Beam, beam_model.Celas);
	fprintf(fid, 'done.');

	% assembly mass matrix 
	fprintf(fid, '\n- Assemblying mass matrix...');
	M = ms_matrix(beam_model.Info, beam_model.Node.DOF, beam_model.Node.R, beam_model.ConM, beam_model.Bar, beam_model.Beam);
	fprintf(fid, 'done.'); 

	if (SPLINE_TYPE == 1)
		fprintf(fid, '\n- Assemblying linear aerodynamic influence matrix...');
		[Qaa, CPaeroDef, GAMMA_P] = st_linaer_matrix(Interp.Ic, Interp.Imv, beam_model.Aero.geo, lattice, state);
		fprintf(fid, 'done.');
	else
		GAMMA_P = [];
		CPaeroDef = zeros(npa*3,ndof);
	end

	if ~isempty(beam_model.RBE2.ID)
		K = RBE2Assembly(beam_model.RBE2,K);
		M = RBE2Assembly(beam_model.RBE2,M);
	end

	%   RHS 
	fprintf(fid,'\n- Setting system rhs...');

	% set generalized forces 
	fprintf(fid, '\n     External forces...');
	F = gf_lin_nodal(LOADI, beam_model.Info, beam_model.F, beam_model.M, beam_model.Node.DOF);
	F_flw = gf_flw_nodal(beam_model.Param.LOAD, beam_model.Info, beam_model.F_FLW, beam_model.Node.R, ...
	                     beam_model.Node.DOF, LOAD_SCALE);
                     
        F = F + F_flw;
    
        if ~isempty(beam_model.RBE2.ID)
		F = RBE2Assembly2(beam_model.RBE2,F);
        end   
    
	fprintf(fid, 'done.');

	%   SUPORT DOF
	fprintf(fid,'\n- Setting SUPORT matrix...');
	if (beam_model.Info.cc_nspc)
		error('SPC case control card detected. This solver allows trim analysis for free-free aircraft.');
	end  

	%   Stiffness matrix
	if (~isempty(beam_model.Param.SUPORT))
		dummy = beam_model.Node;
		if ~isempty(beam_model.RBE2.ID)
			dummy.DOF = dummy.DOF2;
		end
		[D, Kll, Klr, Krr, Krl, rdof, ldof, KEPS] = get_suport_shapes(K, dummy, beam_model.Param.SUPORT, beam_model.Param.EPS);
		nr = find(KEPS < beam_model.Param.EPS);
		if (~isempty(nr))
			fprintf(fid, '\nWarning: %d SUPORT rigid modes exceed deformation energy tolerance %g.', length(nr), beam_model.Param.EPS);
		end
	else 
		error('No SUPORT card given.');
	end

	%   Provisory 
	if ( (size(beam_model.Param.SUPORT,1)>1) || (length(num2str(beam_model.Param.SUPORT(1,2)))~=6))
		error('Provisory: one one suport point with 6 dofs is enabled at the moment.');
	end
	fprintf(fid, 'done.');

elseif FLAG==1

	M = RES.Struct.M;
	K = RES.Struct.K;
	F = RES.Struct.F;
	D = RES.Struct.D;
	ldof = RES.Struct.ldof;
	rdof = RES.Struct.rdof;

	Interp = RES.Interp;

	Kll = K(ldof, ldof);      
	Klr = K(ldof, rdof);
	Krr = K(rdof, rdof);    
	Krl = K(rdof, ldof);

end % FLAG ONE

%   Mass matrix
Mll = M(ldof, ldof); Mlr = M(ldof, rdof); Mrr = M(rdof, rdof); Mrl = M(rdof, ldof); 

%   Rigid body mass matrix for the SUPORTED DOFs 
mr = Mrr + Mrl*D + D'*Mlr + D'*Mll*D;
MSRR = mr; 

%   Aerodynamic influence matrix
fprintf(fid,'\nGenerating aerodynamic database...');
sindex = find(beam_model.Param.SUPORT(1,1) == beam_model.Node.ID);
geo = beam_model.Aero.geo;
geo.ref_point = beam_model.Node.Coord(sindex,:); % set for moments calculations
geo.CG = beam_model.Node.Coord(sindex,:); % set for angular velocities

%***********************************************************************************************************************
%
% store stability derivatives
CREF = beam_model.Aero.ref.C_mgc;
BREF = beam_model.Aero.ref.b_ref;
SREF = beam_model.Aero.ref.S_ref;
VREF = state.AS;
print_refvalues(outp, CREF, BREF, SREF, geo.ref_point, geo.CG);

RHOREF = state.rho; 
QINF = 0.5 * RHOREF * VREF^2;
Res.state.qinf = QINF;
QINFS = QINF * SREF;
LREF = [1.0 1.0 1.0 1/BREF 1/CREF 1/BREF]./QINFS;
NDIM = diag(LREF);

Res.Aero.RStab_Der = [];
Res.Aero.RIntercept = []; 
Res.Aero.DStab_Der = []; 
Res.Aero.DIntercept = [];
Res.Aero.RTrim_sol = [];
Res.Aero.DTrim_sol = [];

Res.Interp = Interp;

%***********************************************************************************************************************
%
% AERO DATABASE
%
if FLAG ~=1 && FLAG~=3
%
%   1 case: static rigid load at NULL reference condition
	fprintf(fid,'\n - Reference rigid case...');

	% Define a dummy state, to be used as reference
	dummy_aero_state = state;
	dummy_aero_state.alpha = 0;
	dummy_aero_state.betha = 0;
	dummy_aero_state.P = 0;
	dummy_aero_state.Q = 0;
	dummy_aero_state.R = 0;

	%-------------------------------------------------------------------------------
	%     Extract VLM matrices
	%
	GAMMA_I = [];
	DOFCT = [];

	if ~isempty(lattice)
		if (SPLINE_TYPE==1)
			[dwcond, GAMMA_P, GAMMA_I] = get_VLM_matrix(geo, lattice, dummy_aero_state, GAMMA_P);
		else
			[dwcond, GAMMA_P, GAMMA_I] = get_VLM_matrix(geo, lattice, dummy_aero_state);
		end
	end

	%-------------------------------------------------------------------------------
	%    Extract BODY matrices
	%
	Sij = {}; DijY = {}; DijZ = {}; SijV = {}; DijYV = {}; DijZV = {}; GAMMA_HB = {}; GAMMA_VEL = {};
	for i=1:nbody
		[Sij{i}, DijY{i}, DijZ{i}, SijV{i}, DijYV{i}, DijZV{i}, GAMMA_HB{i}, GAMMA_VEL{i}] = ...
		                     get_body_matrix(i, lattice, beam_model.Aero.body, state, beam_model.Param);
	end

	%-------------------------------------------------------------------------------
	%  Combine VLM and BODY and determine aero forces
	%
	for i=1:nbody
		for k=1:length(beam_model.Aero.body.geo.CAERO_INT{i})
			patch = beam_model.Aero.body.geo.CAERO_INT{i}(k);
			DOFCT = [DOFCT, [beam_model.Aero.lattice_vlm.DOF(patch, 1):beam_model.Aero.lattice_vlm.DOF(patch, 2)]];
		end
	end

	if (beam_model.Param.BCOU == 2)
		for i=1:nbody
			GAMMA_HB{i}(:,DOFCT) = 0.0;
			GAMMA_VEL{i}(:,DOFCT) = 0.0;
		end
	end

	[results0, GAMMA_MAT, NELEM] = solve_vlm_body(geo, lattice, beam_model.Aero.body, dummy_aero_state, ...
	                                              beam_model.Param, GAMMA_P, GAMMA_I, GAMMA_VEL, Sij, ...
	                                              DijY, DijZ, SijV, DijYV, DijZV, GAMMA_HB, DOFCT);

	Fa0 = gf_transfer_aero_nodal_ext(beam_model.Info, beam_model.Node.DOF, beam_model.Node, Interp, InterpBody, results0);


	%   Total external forces (Applied loads + Follower + reference rigid aero condition)
	if ~isempty(beam_model.RBE2.ID)
		Fa02 = RBE2Assembly2(beam_model.RBE2,Fa0);
	end   
        F = F + Fa02; 
	fprintf(fid,'done.'); 



	Fa_State_aero = zeros(npa*3, 5);

	nr = find(Trim.CS.MPC == 0);
	HINGEMAT = zeros(geo.nc, 5+length(nr));


	%   2 case: rigid body attitude variations ++++++++++++++++++++++++++++++++++++
	%   Alpha
	fprintf(fid,'\n - Alpha perturbation...');
	dummy_aero_state = state; 
	dummy_aero_state.alpha = EPS;
	dummy_aero_state.betha = 0;
	dummy_aero_state.P = 0;
	dummy_aero_state.Q = 0;
	dummy_aero_state.R = 0;

	results = solve_vlm_body_re(geo, lattice, beam_model.Aero.body, ...
	                            dummy_aero_state, beam_model.Param, GAMMA_I, GAMMA_VEL, ...
	                            GAMMA_MAT, NELEM, DOFCT);    

	Fa_ALPHA = gf_transfer_aero_nodal_ext(beam_model.Info, beam_model.Node.DOF, beam_model.Node, Interp, InterpBody, results);
	Fa_ALPHA = (Fa_ALPHA - Fa0)./ EPS; % get force variation

	Fa_State_aero([1:3:end], 1) = [results.F(:,1)-results0.F(:,1)]./ EPS;
	Fa_State_aero([2:3:end], 1) = [results.F(:,2)-results0.F(:,2)]./ EPS;
	Fa_State_aero([3:3:end], 1) = [results.F(:,3)-results0.F(:,3)]./ EPS;
	Fa_ALPHAl = Fa_ALPHA(ldof,1);
	Fa_ALPHAr = Fa_ALPHA(rdof,1);
	if nc
		HINGEMAT(:,1) = (results.HINGE-results0.HINGE)./EPS;
	end
	fprintf(fid,'done.');

	%   Beta
	fprintf(fid,'\n - Sideslip perturbation...');
	dummy_aero_state = state; 
	dummy_aero_state.alpha = 0;
	dummy_aero_state.betha = EPS;
	dummy_aero_state.P = 0;
	dummy_aero_state.Q = 0;
	dummy_aero_state.R = 0;

	results = solve_vlm_body_re(geo, lattice, beam_model.Aero.body, ...
	     dummy_aero_state, beam_model.Param, GAMMA_I, GAMMA_VEL, GAMMA_MAT, NELEM, DOFCT);    

	Fa_BETA = gf_transfer_aero_nodal_ext(beam_model.Info, beam_model.Node.DOF, beam_model.Node, Interp, InterpBody, results);
	Fa_BETA = (Fa_BETA - Fa0) ./ EPS;

	Fa_State_aero([1:3:end], 2) = [results.F(:,1)-results0.F(:,1)]./ EPS;
	Fa_State_aero([2:3:end], 2) = [results.F(:,2)-results0.F(:,2)]./ EPS;
	Fa_State_aero([3:3:end], 2) = [results.F(:,3)-results0.F(:,3)]./ EPS;
	Fa_BETAl = Fa_BETA(ldof,1); Fa_BETAr = Fa_BETA(rdof,1);
	if nc
		HINGEMAT(:,2) = (results.HINGE-results0.HINGE)./EPS;
	end
	fprintf(fid,'done.');

	%   P
	fprintf(fid,'\n - Angular velocities...');
	dummy_aero_state = state; 
	dummy_aero_state.alpha = 0;
	dummy_aero_state.betha = 0;
	dummy_aero_state.P = EPS;
	dummy_aero_state.Q = 0;
	dummy_aero_state.R = 0;

	results = solve_vlm_body_re(geo, lattice, beam_model.Aero.body, ...
	                            dummy_aero_state, beam_model.Param, GAMMA_I, GAMMA_VEL, GAMMA_MAT, NELEM, DOFCT);    

	Fa_P = gf_transfer_aero_nodal_ext(beam_model.Info, beam_model.Node.DOF, beam_model.Node, Interp, InterpBody, results);
	Fa_P = (Fa_P - Fa0) ./ EPS;

	if nc
		HINGEMAT(:,3) = (2*VREF/BREF).*(results.HINGE-results0.HINGE)./EPS;
	end

	%   set to adimensional angular speed
	Fa_P = (2*VREF)*Fa_P ./ BREF;
	Fa_State_aero([1:3:end], 3) = [results.F(:,1)-results0.F(:,1)]./ EPS;
	Fa_State_aero([2:3:end], 3) = [results.F(:,2)-results0.F(:,2)]./ EPS;
	Fa_State_aero([3:3:end], 3) = [results.F(:,3)-results0.F(:,3)]./ EPS;
	Fa_Pl = Fa_P(ldof,1); Fa_Pr = Fa_P(rdof,1);



	%   Q
	dummy_aero_state = state; 
	dummy_aero_state.alpha = 0;
	dummy_aero_state.betha = 0;
	dummy_aero_state.P = 0;
	dummy_aero_state.Q = EPS;
	dummy_aero_state.R = 0;

	results = solve_vlm_body_re(geo, lattice, beam_model.Aero.body, ...
	                            dummy_aero_state, beam_model.Param, GAMMA_I, GAMMA_VEL, GAMMA_MAT, NELEM, DOFCT);

	Fa_Q = gf_transfer_aero_nodal_ext(beam_model.Info, beam_model.Node.DOF, beam_model.Node, Interp, InterpBody, results);


	Fa_Q = (Fa_Q - Fa0) ./ EPS;

	if nc
		HINGEMAT(:,4) = (2*VREF/CREF).*(results.HINGE-results0.HINGE)./EPS;
	end

	%   set to adimensional angular speed
	Fa_Q = (2*VREF)*Fa_Q ./ CREF;
	Fa_State_aero([1:3:end], 4) = [results.F(:,1)-results0.F(:,1)]./ EPS;
	Fa_State_aero([2:3:end], 4) = [results.F(:,2)-results0.F(:,2)]./ EPS;
	Fa_State_aero([3:3:end], 4) = [results.F(:,3)-results0.F(:,3)]./ EPS;
	Fa_Ql = Fa_Q(ldof,1); Fa_Qr = Fa_Q(rdof,1);



	%   R
	dummy_aero_state = state; 
	dummy_aero_state.alpha = 0;
	dummy_aero_state.betha = 0;
	dummy_aero_state.P = 0;
	dummy_aero_state.Q = 0;
	dummy_aero_state.R = EPS;

	results = solve_vlm_body_re(geo, lattice, beam_model.Aero.body, ...
	                            dummy_aero_state, beam_model.Param, GAMMA_I, GAMMA_VEL, GAMMA_MAT, NELEM, DOFCT);    

	Fa_R = gf_transfer_aero_nodal_ext(beam_model.Info, beam_model.Node.DOF, beam_model.Node, Interp, InterpBody, results);
	Fa_R = (Fa_R - Fa0) ./ EPS;

	if nc
		HINGEMAT(:,5) = (2*VREF/BREF).*(results.HINGE-results0.HINGE)./EPS;
	end

	%   set to adimensional angular speed
	Fa_R = (2*VREF)*Fa_R ./ BREF;
	Fa_State_aero([1:3:end], 5) = [results.F(:,1)-results0.F(:,1)]./ EPS;
	Fa_State_aero([2:3:end], 5) = [results.F(:,2)-results0.F(:,2)]./ EPS;
	Fa_State_aero([3:3:end], 5) = [results.F(:,3)-results0.F(:,3)]./ EPS;
	Fa_Rl = Fa_R(ldof,1); Fa_Rr = Fa_R(rdof,1);


	fprintf(fid,'done.');



	%
	%   Control surfaces
	%
	dummy_aero_state = state; 
	dummy_aero_state.alpha = 0;
	dummy_aero_state.betha = 0;
	dummy_aero_state.P = 0;
	dummy_aero_state.Q = 0;
	dummy_aero_state.R = 0;

	FCl = [];
	FCr = [];


	if (~isempty(nr))
		fprintf(fid,'\n - Controls...');
		print_controls(outp, nr, lattice.Control.Name, Res.CS);
		FCtot = zeros(ndof, length(nr));
		FCtot_aero = zeros(npa*3, length(nr));
		FCl = zeros(length(ldof), length(nr));
		FCr = zeros(length(rdof), length(nr)); 

		LUMP_DOF = [];
		LUMP_COEFF = [];

		for k=1:length(nr)
 
			% erase all rotations
			Res.CS.Value(1:length(Trim.CS.MPC)) = 0.0;

			% set master rotation
			Res.CS.Value(nr(k)) = EPS;

			% look for slave
			cdof = find(Trim.CS.MPC == nr(k));
			LUMP_DOF(k).data = [nr(k)];
			LUMP_COEFF(k).data = [1];
			if (~isempty(cdof))
				Res.CS.Value(cdof) = EPS*Trim.CS.Coeff(cdof);
				LUMP_DOF(k).data = [nr(k), cdof];
				LUMP_COEFF(k).data = [1, Trim.CS.Coeff(cdof)];
			end

			lattice_defo = rotate_control_surf(beam_model.Aero.ref, dummy_aero_state, geo, ...
			                                   lattice, Res.CS.Value, lattice.Control.Hinge, beam_model.Aero.ID, 1);


			results = solve_vlm_body_re(geo, lattice_defo, beam_model.Aero.body, ...
			                            dummy_aero_state, beam_model.Param, GAMMA_I, GAMMA_VEL, GAMMA_MAT, NELEM, DOFCT);

			Fa_C = gf_transfer_aero_nodal_ext(beam_model.Info, beam_model.Node.DOF, beam_model.Node, Interp, InterpBody, results);
			Fa_C = (Fa_C - Fa0) ./ EPS;

			FCtot_aero([1:3:end], k) = [results.F(:,1)-results0.F(:,1)]./ EPS;
			FCtot_aero([2:3:end], k) = [results.F(:,2)-results0.F(:,2)]./ EPS;
			FCtot_aero([3:3:end], k) = [results.F(:,3)-results0.F(:,3)]./ EPS;
			FCl(:,k) = Fa_C(ldof,1);     
			FCr(:,k) = Fa_C(rdof,1);     
			FCtot(:,k) = Fa_C;
			HINGEMAT(:,5+k) = (results.HINGE-results0.HINGE)./EPS;

		end

		Res.CS.Value(1:length(Trim.CS.MPC)) = 0.0;

		%     tranform moments to coefficients
		HINGEMAT = HINGEMAT./(QINFS*CREF);
		results0.HINGE = results0.HINGE./(QINFS*CREF);

		%     lump rows
		HINGEMAT = lump_hinge(HINGEMAT, LUMP_DOF, LUMP_COEFF);
		results0.HINGE = lump_hinge(results0.HINGE, LUMP_DOF, LUMP_COEFF);
		fprintf(fid,'done.');
	end


	%   Assembly derivatives 
	Kax  =  -[Fa_ALPHA, Fa_BETA, Fa_P, Fa_Q, Fa_R, FCtot];
	KaxDOF = Kax;

	if ~isempty(beam_model.RBE2.ID) 
		Kax = RBE2Assembly2(beam_model.RBE2,Kax);
	end
	Kaxl = Kax(ldof,:); 
	Kaxr = Kax(rdof,:);

	%***********************************************************************************************************************
	%
	%   Assembly deformability influence coefficients 
	%
	if (SPLINE_TYPE > 1)
		fprintf(fid,'\n - Deformability influence coefficients...');
		error('\n TODO\n');
		Qaa = zeros(ndof, ndof); 
		dummy_aero_state = state; 
		dummy_aero_state.alpha = 0;
		dummy_aero_state.betha = 0;
		dummy_aero_state.P = 0;
		dummy_aero_state.Q = 0;
		dummy_aero_state.R = 0;

		%     Get master nodes connected to aerodynamics
		MNODE = [];
		AERO_DOF = [];
		for n = 1:ngrid
			if (~isempty(beam_model.Node.Aero.Index(n).data))
				MNODE = [MNODE, n];
			end
		end
%
		for m = 1:length(MNODE)
			n = MNODE(m);
			% DISPLACEMENT DOF
			for k=1:3
				% loop on node displacements DOFs
				if (beam_model.Node.DOF(n,k))
					AERO_DOF = [AERO_DOF, beam_model.Node.DOF(n,k)];
					NODEPOS = beam_model.Node.Coord;
					NODEPOS(n,k) = beam_model.Node.Coord(n,k) + EPS;  
					% determine updated lattice
					lattice_defo = update_vlm_mesh_ext(beam_model.Node, NODEPOS, beam_model.Node.R, lattice, Interp, state, beam_model.Aero.ref, beam_model.Aero.ID);
            results = solve_vlm_body_re(geo, lattice_defo, beam_model.Aero.body, ...
              dummy_aero.state, beam_model.Param, GAMMA_I, GAMMA_VEL, GAMMA_MAT, NELEM, DOFCT); 
            Fa_D = gf_transfer_aero_nodal(beam_model.Info, beam_model.Node.DOF, beam_model.Node, dummy_aero, ...
              results);
            CPaeroDef([1:3:end], beam_model.Node.DOF(n, k)) = [results.F(:,1)-results0.F(:,1)]./ EPS;
            CPaeroDef([2:3:end], beam_model.Node.DOF(n, k)) = [results.F(:,2)-results0.F(:,2)]./ EPS;
            CPaeroDef([3:3:end], beam_model.Node.DOF(n, k)) = [results.F(:,3)-results0.F(:,3)]./ EPS;
            Qaa(:,beam_model.Node.DOF(n, k)) = (Fa_D - Fa0) ./ EPS; 
          end
        end
%
        for k=4:6
          % erase displacements
          % erase rotations
          beam_model.Res.NRd = beam_model.Node.R;
          % loop on node displacements DOFs
          if (beam_model.Node.DOF(n,k))
            AERO_DOF = [AERO_DOF, beam_model.Node.DOF(n,k)];
            dummyrot = zeros(1,3);
            dummyrot(k-3) = EPS;
			      beam_model.Res.NRd(:,:,n) = Rmat(dummyrot);
  %         determine updated lattice
	          lattice_defo = update_vlm_mesh(beam_model.Node, beam_model.Node.Coord, beam_model.Res.NRd, dummy_aero);
            results = solve_vlm_body_re(geo, lattice_defo, beam_model.Aero.body, ...
              dummy_aero.state, beam_model.Param, GAMMA_I, GAMMA_VEL, GAMMA_MAT, NELEM, DOFCT); 
            Fa_D = gf_transfer_aero_nodal(beam_model.Info, beam_model.Node.DOF, beam_model.Node, dummy_aero, ...
              results);
            CPaeroDef([1:3:end], beam_model.Node.DOF(n, k)) = [results.F(:,1)-results0.F(:,1)]./ EPS;
            CPaeroDef([2:3:end], beam_model.Node.DOF(n, k)) = [results.F(:,2)-results0.F(:,2)]./ EPS;
            CPaeroDef([3:3:end], beam_model.Node.DOF(n, k)) = [results.F(:,3)-results0.F(:,3)]./ EPS;
           Qaa(:,beam_model.Node.DOF(n, k)) = (Fa_D - Fa0) ./ EPS; 
          end
        end
      end
		fprintf(fid,'done.');
	end


	fprintf(fid,'\ndone.');
 
	QaaDOF = Qaa; 
	if ~isempty(beam_model.RBE2.ID)
		Qaa = RBE2Assembly(beam_model.RBE2,Qaa);
	end
	Qaall = Qaa(ldof, ldof);
	Qaalr = Qaa(ldof, rdof);
	Qaarl = Qaa(rdof, ldof);
	Qaarr = Qaa(rdof, rdof);

else % Load from input data
	Qaa   = RES.Aero.Qaa/RES.state.qinf*QINF;
	QaaDOF = RES.Aero.QaaDOF/RES.state.qinf*QINF;

	Qaall = Qaa(ldof, ldof);  
	Qaalr = Qaa(ldof, rdof);  
	Qaarr = Qaa(rdof, rdof);
	Qaarl = Qaa(rdof, ldof);

	Kax = RES.Aero.Kax/RES.state.qinf*QINF;
	KaxDOF = RES.Aero.KaxDOF/RES.state.qinf*QINF;

	Kaxl  = Kax(ldof,:); 
	Kaxr  = Kax(rdof,:);

	F = RES.Aero.Fa0/RES.state.qinf*QINF + F;
	Fa0 = RES.Aero.Fa0DOF/RES.state.qinf*QINF;
	HINGEMAT = RES.Aero.H/RES.state.qinf*QINF; 
	results0.HINGE = RES.Aero.H0/RES.state.qinf*QINF;

	Fa_State_aero = RES.CPaero.State;
	FCtot_aero    = RES.CPaero.Control;
	CPaeroDef     = RES.CPaero.Defo;
	results0.F = zeros(npa,3);
	results0.F(:,1) = RES.CPaero.F0(:,1); %RES.CPaero.F0(1:3:end,1);
	results0.F(:,2) = RES.CPaero.F0(:,2); %RES.CPaero.F0(2:3:end,1);
	results0.F(:,3) = RES.CPaero.F0(:,3); %RES.CPaero.F0(3:3:end,1);
end %FLAG one


Res.NDispl = zeros(ngrid, 6);
Res.NRd = beam_model.Node.R;

acc_dof = Trim.FM.Fixed(7:12);
indexa = find(acc_dof); % fixed acc dofs
index_acc = setdiff([1:6], indexa); % free acc dofs

fm_dof = Trim.FM.Fixed(2:6);
indexfm = find(fm_dof); % fixed fm dofs
index_fm = setdiff([1:5], indexfm); % free fm dofs

index_cs = [];
nr = find(Trim.CS.MPC == 0); % get master rotations
if (~isempty(nr))
	cs_dof = Trim.CS.Fixed(nr); % check if master deflections are fixed
	indexcs = find(cs_dof); % fixed cs dofs
	index_cs = setdiff([1:length(nr)], indexcs); % free cs dofs
end


%***********************************************************************************************************************
%
% SAVE DATABASE
Res.Struct.M = M;
Res.Struct.K = K;
if ~isempty(beam_model.RBE2.ID)
	Fa02 = RBE2Assembly2(beam_model.RBE2,Fa0);
else
	Fa02 = Fa0;
end  
Res.Struct.F = F - Fa02;
Res.Struct.D = D;
Res.Struct.ldof = ldof;
Res.Struct.rdof = rdof;

% aero
Res.Aero.Qaa = Qaa;
Res.Aero.Kax = Kax;
Res.Aero.QaaDOF = QaaDOF;
Res.Aero.KaxDOF = KaxDOF;
Res.Aero.Fa0 = Fa02;
Res.Aero.Fa0DOF = Fa0;
Res.Aero.H = HINGEMAT; 
Res.Aero.H0 = results0.HINGE;

% matrices along aero panels
Res.CPaero.State   =  Fa_State_aero;
Res.CPaero.Control =  FCtot_aero;
Res.CPaero.Defo    =  CPaeroDef;
Res.CPaero.F0 =  zeros(npa*3,1);
Res.CPaero.F0(1:3:end,1) = results0.F(:,1);
Res.CPaero.F0(2:3:end,1) = results0.F(:,2);
Res.CPaero.F0(3:3:end,1) = results0.F(:,3);

% trim
Res.Trim.index_acc = index_acc;
Res.Trim.index_fm = index_fm;
Res.Trim.index_cs = index_cs;
Res.Trim.masterSurf = nr; 
Res.Trim.FMDOF = FMDOF;

if FLAG == 0 % NO TRIM REQUIRED
	Res.CPaero.F0 = results0.F;
	return;
end

%---------------------------------------------------------------------------------------------------------
UX = zeros(length(find(Trim.CS.MPC == 0))+5, 2);
for ntrim = 1:2

	if ntrim == 1 % switch off deformability effects on aerodynamics
		fprintf(fid,'\nSolving rigid aircraft trim condition...');
		Kall = Kll;
		Kalr = Klr;
		Karl = Krl;
		Karr = Krr;
		invKall = inv(Kall);
		RFLEX_MAT = invKall;
	else
		fprintf(fid,'\nSolving deformable aircraft trim condition...');
		Kall = Kll - Qaall;
		Kalr = Klr - Qaalr;
		Karl = Krl - Qaarl;
		Karr = Krr - Qaarr; 
		invKall = inv(Kall);
	end


	AMLR  = invKall * (Mll*D + Mlr); 
	ARLR  = invKall * Kalr;
	ALX   = invKall * Kaxl;
	UINTL = invKall * F(ldof,1);

	DUMMY = D'*Mll + Mrl;
	M2RR =  (D'*Mlr + Mrr) - DUMMY * ARLR;
	M3RR = -DUMMY * AMLR;
	K3LX = -DUMMY * ALX;
	TMP1 = DUMMY * UINTL;

	invM2RR = inv(M2RR);
	M4RR = invM2RR * M3RR;
	K4LX = invM2RR * K3LX;
	TMP2 = invM2RR * TMP1;

	DUMMY = D'*Kall + Karl;
	K2RR = -DUMMY * ARLR + (D'*Kalr + Karr);
	KAZL = DUMMY;
	%    KARZX = KAZL - KAXL * ALX;
	KARZX = (D'*Kaxl + Kaxr) - KAZL * ALX;
	INTZ = D'*F(ldof,1) + F(rdof,1);
	IPZ = INTZ - DUMMY * UINTL;

	M5RR = -K2RR * M4RR + MSRR;
	MIRR = -KAZL * AMLR + M5RR;
	invMIRR = inv(MIRR);
	KR1ZX = -K2RR * K4LX + KARZX;
	IPZF = K2RR * TMP2 + IPZ;

	IPZF1 = invMIRR * IPZF;
	IPZF2 = MSRR * IPZF1;
	KR2ZX = -invMIRR * KR1ZX;
	Z1ZX = MSRR * KR2ZX;
	IPZF = IPZF2;  

	%
	%   Determine trim unknows
	%
	%   assemble rectangular system matrix
	TMAT_ACC = MSRR;
	%   select independent dofs
	%   structural suport accelerations     
	%   set acceleration dofs
	UDD(:,ntrim) = Trim.FM.Value(7:12)';

	if ~isempty(indexa)
		IPZF = IPZF - MSRR(:, indexa) * UDD(indexa,ntrim);
		TMAT_ACC = MSRR(:, index_acc); % clean for constrained acc
	end

	Z1ZX_FM = Z1ZX(:,1:5);
	UX(1:5,ntrim) = Trim.FM.Value(2:6)';
	if ~isempty(indexfm)
		IPZF = IPZF + Z1ZX_FM(:, indexfm) * UX(indexfm,ntrim);
		Z1ZX_FM = Z1ZX_FM(:, index_fm); % clean for constrained fm param
	end

	Z1ZX_CS = [];
	if (~isempty(nr))
		Z1ZX_CS = Z1ZX(:,6:end);
		defl = Trim.CS.Value(nr)'; 
		UX(6:end,ntrim) = defl;
		if (~isempty(indexcs))
			UCS(:,ntrim) = defl(indexcs);
			IPZF = IPZF + Z1ZX_CS(:, indexcs) * UCS(:,ntrim);
			Z1ZX_CS = Z1ZX_CS(:, index_cs); % clean for constrained fm param
		end
		free_cs = intersect(nr,  find(Trim.CS.Fixed==0));
		NAME = lattice.Control.Name;
	end

	TMAT = [TMAT_ACC, -Z1ZX_FM, -Z1ZX_CS]; 

	switch (STRIM)
	case 1  % simmetric trim
		TMAT = TMAT(FMDOF,:);
		IPZF = IPZF(FMDOF);
	case -1 % antisimmetric trim
		TMAT = TMAT(FMDOF,:);
		IPZF = IPZF(FMDOF);
	end

	if NF_TOT ~= NDOF
		funmin = @(x) handlemin(x,index_acc,index_fm,index_cs);
		options = optimset('Algorithm','active-set','TolCon', 1e-6);
		sol = fmincon(funmin, zeros(size(TMAT,2),1), [] , [] ,full(TMAT) , IPZF, [], [], [], options);
	else
		sol = inv(TMAT) * IPZF;
	end

	sol_offset = 0;


	%   recover solution acceleration
	if (~isempty(index_acc))
		UDD(index_acc,ntrim) = sol([1:length(index_acc)]);
		sol_offset = sol_offset + length(index_acc);
		Res.FM.Value(ntrim, 7:12) = UDD(:,ntrim)';
	end

	%   recover solution fm
	if (~isempty(index_fm))
		UX(index_fm,ntrim) = sol([sol_offset+1:sol_offset+length(index_fm)]);
		sol_offset = sol_offset + length(index_fm);
		Res.FM.Value(ntrim, 2:6) = UX(1:5,ntrim)';
	end

	%   recover solution cs
	Res.CS.Value(ntrim, :) = Trim.CS.Value;
	if (~isempty(index_cs))
		UX(index_cs+5,ntrim) = sol([sol_offset+1:sol_offset+length(index_cs)]);
		sol_offset = sol_offset + length(index_cs);
		Res.CS.Value(ntrim, free_cs) = UX(index_cs+5,ntrim);
	end

	% store stability derivatives 
	FMDER = NDIM * Z1ZX;
	FM0 = NDIM * IPZF2;
	if ntrim==1
		Res.Aero.RStab_Der = get_stab_der(FMDER, HINGEMAT); 
		Res.Aero.RIntercept = get_aero_intercept(FM0, results0.HINGE);
		Res.Aero.RStab_Der.Control.Name = {};
		if (~isempty(nr))
			Res.Aero.RStab_Der.Control.Name = lattice.Control.Name(nr);
		end
		Res.Aero.RTrim_sol = store_trim_sol(fid, UDD(:,1), UX(:,1), Res.Aero.RStab_Der.Control.Name);
		fprintf(outp, '\n\nRIGID TRIM RESULTS\n');
		dummy = store_trim_sol(outp, UDD(:,1), UX(:,1), Res.Aero.RStab_Der.Control.Name);
		print_intercept(outp, Res.Aero.RIntercept);
		print_hinge_intercept(outp, Res.Aero.RIntercept.cmh0, Res.Aero.RStab_Der.Control.Name);
	else
		Res.Aero.DStab_Der = get_stab_der(FMDER,[]);
		Res.Aero.DIntercept = get_aero_intercept(FM0, []);
		Res.Aero.DStab_Der.Control.Name = {};
		if (~isempty(nr))
			Res.Aero.DStab_Der.Control.Name = lattice.Control.Name(nr);
		end 
		Res.Aero.DTrim_sol = store_trim_sol(fid, UDD(:,2), UX(:,2), Res.Aero.DStab_Der.Control.Name);
		fprintf(outp, '\n\nELASTIC TRIM RESULTS\n');
		dummy = store_trim_sol(outp, UDD(:,2), UX(:,2), Res.Aero.DStab_Der.Control.Name);
		print_intercept(outp, Res.Aero.DIntercept);
	end 
	fprintf(fid,'\ndone.');
end % trim loop%


% Determine divergence dynamic pressure for the restrained aircraft if required

ndof2 = ndof;
ndof = size(Kax,1);
Res.Aero.DIVERG_Q = 0;

if (beam_model.Param.DIVERG > 0)
	fprintf(fid, '\n Solving for unrestrained aeroelastic divergence...');
	DIV_FOUND = false;
	HR = [eye(length(rdof)); D];
	IR = eye(ndof) - HR*inv(MSRR)*HR'*[Mrr, Mrl; Mlr,Mll]; % inertia relief matrix
	AF = IR * [zeros(6,ndof); zeros(length(ldof),6),RFLEX_MAT] * IR'; % mean axes flex matrix

	[DMODE, dynp] = eig(eye(ndof), AF*[Qaarr, Qaarl; Qaalr, Qaall]./QINF);

	dynp = diag(dynp);
	index = find(real(dynp)>0);
	mindex = [];
	e = [];
	for n=1:length(index)
		if isreal(dynp(index(n)))
			e = [e, dynp(index(n))];
			mindex = [mindex, index(n)];
		end
	end

	if (~isempty(e))

		DIV_FOUND = true;
		%     sort eigenvalues
		[e, index] = sort(e);
		mindex = mindex(index);
		Res.Aero.DIVERG_Q = e(1:beam_model.Param.DIVERG);

		for k=1:beam_model.Param.DIVERG
			SOL = zeros(ndof, 1); 
			SOL(ldof,1) = DMODE(length(rdof)+1:end,mindex(k));
			SOL(rdof,1) = DMODE(1:length(rdof),mindex(k));

			if ~isempty(beam_model.RBE2.ID)
				SOL = RBE2disp(beam_model.RBE2,SOL,ndof2);
			end
        
			gdef = zeros(beam_model.Info.ngrid, 6);
			for n = 1:beam_model.Info.ngrid
				dof = beam_model.Node.DOF(n, 1:6);
				index = find(dof);
				if ~isempty(index)
					gdef(n, index) = SOL(dof(index));
				end
			end

			% store nodal displacement
			Res.NDispl(:,:,1+k) = gdef;

			% set delta Rot
			for n = 1:beam_model.Info.ngrid
				Res.NRd(:,:,n,1+k) = Rmat(gdef(n, 4:6));
			end

			if (beam_model.Info.nrbe0 > 0)
				AERO_POS = update_aerobeam_node(beam_model.Info.ngrid, beam_model.Node, Res.NDispl(:,1:3,1+k),...
				                                Res.NRd(:,:,:,1+k)-repmat(eye(3,3),[1,1,beam_model.Info.ngrid]));

				% update coord database with slave nodes position
				for n=1:beam_model.Info.ngrid
					ne = length(beam_model.Node.Aero.Index(n).data);
					if ne
						Res.NDispl(beam_model.Node.Aero.Index(n).data, 1:3, 1+k) = AERO_POS(n).data';
					end
				end
				clear AERO_POS;
			end
		end % mode loop
	end % divergence detected

	if (DIV_FOUND)
		fprintf(fid, '\n - Divergence dynamic pressure: %4e [Pa].', Res.Aero.DIVERG_Q); 
	else
		fprintf(fid, '\n - No divergence detected.'); 
	end
	fprintf(fid,'\ndone.');

end % divergence calculation



ndof = ndof2;

% Recover structural displacements and rotations

UR = -M4RR * UDD(:,ntrim) - K4LX * UX(:,ntrim) - TMP2; 
UL = -AMLR * UDD(:,ntrim) - ARLR * UR - ALX * UX(:,ntrim) + UINTL;
     
SOL =  zeros(size(K,1),1); SOL(rdof,1) = UR; SOL(ldof,1) = UL;
if ~isempty(beam_model.RBE2.ID)
	SOL = RBE2disp(beam_model.RBE2,SOL,ndof);
end
gdef = zeros(beam_model.Info.ngrid, 6);                     

for n = 1:beam_model.Info.ngrid 
	dof = beam_model.Node.DOF(n, 1:6);
	index = find(dof);
	if ~isempty(index)
		gdef(n, index) = SOL(dof(index));
	end
end

% store nodal displacement
Res.NDispl(:,:,1) = gdef;
% set delta Rot
for n = 1:beam_model.Info.ngrid
	Res.NRd(:,:,n,1) = Rmat(gdef(n, 4:6));
end

% recover solution in matrix form
[DS, DR] = get_nodal_displ(beam_model.Info.ngrid, beam_model.Node.DOF, SOL); %
% update BAR rotations
Res.Bar.R = update_bar_rot(nbar, DR, beam_model.Bar.Conn, Res.Bar.R , DS); % ok

% update BEAM rotations
Res.Beam.R = update_bar_rot(nbeam, DR, beam_model.Beam.Conn, Res.Beam.R , DS);

COORD = beam_model.Node.Coord + Res.NDispl(:,1:3);
Res.Bar.Colloc  = bar_defo_colloc(nbar,  beam_model.Bar,  beam_model.Node.DOF, COORD, Res.NRd);
Res.Beam.Colloc = bar_defo_colloc(nbeam, beam_model.Beam, beam_model.Node.DOF, COORD, Res.NRd);

% calculate new mass matrix
Res.WB = [];
[Res.WB.CG, Res.WB.MCG, Res.WB.MRP] = wb_set_conm_mass(beam_model.Info.nconm, beam_model.Node.Index, ...
                                                       COORD, Res.NRd, beam_model.Param.GRDPNT, beam_model.ConM);

% set bar mass CG
[Res.WB.CG, Res.WB.MCG, Res.WB.MRP] = wb_add_bar_mass(nbar, COORD, Res.NRd, Res.WB.CG, ...
                                                      beam_model.Param.GRDPNT, Res.WB.MCG, Res.WB.MRP, beam_model.Bar);

% set beam mass CG
[Res.WB.CG, Res.WB.MCG, Res.WB.MRP] = wb_add_bar_mass(nbeam, COORD, Res.NRd, Res.WB.CG, beam_model.Param.GRDPNT, ...
                                                      Res.WB.MCG, Res.WB.MRP, beam_model.Beam);

% get principal axes
[Res.WB.MCG_pa, Res.WB.R_pa] = wb_principal_axis(Res.WB.MCG);

%
% update aerobeam nodes (if any)    
%
if (beam_model.Info.nrbe0 > 0)
	AERO_POS = update_aerobeam_node(beam_model.Info.ngrid, beam_model.Node, Res.NDispl(:,1:3,1),...
	                                Res.NRd(:,:,:,1)-repmat(eye(3,3),[1,1,beam_model.Info.ngrid]));

	% update coord database with slave nodes position
		for n=1:beam_model.Info.ngrid
			ne = length(beam_model.Node.Aero.Index(n).data);
			if ne
				Res.NDispl(beam_model.Node.Aero.Index(n).data, 1:3, 1) = AERO_POS(n).data';
			end
		end
		clear AERO_POS;
	end


% assembly BAR contributions directly in the undeformed position
[Res.Bar.CForces, Res.Bar.CStrains, Res.Bar.CStresses, Res.Bar.CSM] = get_bar_force_strain(beam_model.Info.nbar, beam_model.Bar, beam_model.PBar, ...
                                                                                           beam_model.Mat, beam_model.Node, Res.NDispl, beam_model.Param.FUSE_DP);

% assembly BEAM contributions directly in the undeformed position
[Res.Beam.CForces, Res.Beam.CStrains, Res.Beam.CStresses, Res.Beam.CSM] = get_bar_force_strain(beam_model.Info.nbeam, beam_model.Beam, beam_model.PBeam, ...
                                                                                               beam_model.Mat, beam_model.Node, Res.NDispl, beam_model.Param.FUSE_DP);


% save internal aero database

% structure
Res.Aero.Fa0tot(:,1) = Fa0 - KaxDOF * UX(:,1);
DS = zeros(size(Fa0,1),1);
for k=1:ngrid
	index = find(beam_model.Node.DOF(k,:));
	if (~isempty(index))
		DS(beam_model.Node.DOF(k,index),1) = gdef(k,index);
	end
end
Res.Aero.Fa0tot(:,2) = Fa0 - KaxDOF * UX(:,2) + QaaDOF * DS;

ADOF = [];
aero_data = [];
for k=1:length(beam_model.Aero.ID)
	n1 = lattice.DOF(k,1,1);
	n2 = lattice.DOF(k,1,2);
	ADOF = [ADOF, [n1:n2]];
	for j=n1:n2
		coord = (lattice.VORTEX([j],[4],:) + lattice.VORTEX([j],[5],:)).*0.5;
		aero_data = [aero_data; [coord(:,:,1), coord(:,:,2), coord(:,:,3)]];
	end
end

Res.Aero.XYZ = aero_data;
naer = length(aero_data);

Res.Aero.F0_RTrim = recover_trim_vlm_forces(Res.CPaero.F0, Res.Aero.RTrim_sol, Res.CPaero, CREF, BREF, SREF, VREF, ADOF);
Res.Aero.F0_DTrim = recover_trim_vlm_forces_defo(Res.CPaero.F0, Res.Aero.DTrim_sol, Res.CPaero, SOL, CREF, BREF, SREF, VREF, ADOF);


F0 = zeros(naer, 3);
% State   = zeros(naer, 3, size(Res.CPaero.State,2));
% Control = zeros(naer, 3, size(Res.CPaero.Control,2));
% Defo    = zeros(naer, 3, size(Res.CPaero.Defo,2));
for k=1:naer
	offset = (ADOF(k)-1)*3;
	F0(k,1) = Res.CPaero.F0(offset+1);
	F0(k,2) = Res.CPaero.F0(offset+2);
	F0(k,3) = Res.CPaero.F0(offset+3);
	% State(k,1,:) = Res.CPaero.State(offset+1,:);
	% State(k,2,:) = Res.CPaero.State(offset+2,:);
	% State(k,3,:) = Res.CPaero.State(offset+3,:);
	% Control(k,1,:) = Res.CPaero.Control(offset+1,:);
	% Control(k,2,:) = Res.CPaero.Control(offset+2,:);
	% Control(k,3,:) = Res.CPaero.Control(offset+3,:);
	% Defo(k,1,:) = Res.CPaero.Defo(offset+1,:);
	% Defo(k,2,:) = Res.CPaero.Defo(offset+2,:);
	% Defo(k,3,:) = Res.CPaero.Defo(offset+3,:);
end
Res.CPaero.F0 = F0;
% Res.CPaero.State = State;
% Res.CPaero.Control = Control;
% Res.CPaero.Defo = Defo;


% update final vector
index = find(Trim.CS.MPC);
for k=1:length(index)
	Res.CS.Value(1,index(k)) = Trim.CS.Coeff(index(k)) * Res.CS.Value(1,Trim.CS.MPC(index(k)));
	Res.CS.Value(2,index(k)) = Trim.CS.Coeff(index(k)) * Res.CS.Value(2,Trim.CS.MPC(index(k)));
end


%
% RUN gust
%
if (Trim.Extra.Value(1)~=0.0)
	[Res, Trim, SOL] = solve_free_lin_gust_ext(beam_model, Trim, state, Res, outp);
end

%
% RUN landing
%
if ( Trim.Extra.Fixed(2) && Trim.Extra.Fixed(3) ) 
	error('Update this section')
	solve_free_lin_land(TRIM_INDEX, outp); 
end
%

fprintf(fid, '\n - Updating vlm model in Aero.lattice_defo...'); 
lattice_cs = rotate_control_surf(beam_model.Aero.ref, state, geo, lattice, ...
                                 Res.CS.Value(2,:), lattice.Control.Hinge, beam_model.Aero.ID);


if (SPLINE_TYPE==1)
	lattice_defo = update_vlm_mesh1_ext(beam_model.Node, SOL, geo, lattice_cs, Interp, state, beam_model.Aero.ref, beam_model.Aero.ID);
else
	lattice_defo = update_vlm_mesh_ext(beam_model.Node, beam_model.Node.Coord+Res.NDispl(:,1:3), Res.NRd, lattice_cs, Interp, state, beam_model.Aero.ref, beam_model.Aero.ID);
end
fprintf(fid, 'done.'); 

fprintf(fid, '\n - Solution summary exported to %s file.', outf);


fprintf(fid, '\n\ncompleted.\n\n');




print_aeroderRE(outp, Res.Aero.RStab_Der, Res.Aero.DStab_Der, nr);

if (nbody)
	dCmda_fus = 0;
elseif ~isfield(beam_model.Param, 'CMAFUS') || isnan(beam_model.Param.CMAFUS)
	[FUSD, FUSL] = RecoverFusGeoDataFromBeamModel(beam_model);
	% Compute fuelage volume (considered as a cylinder from nose to tail)
	FUSV = (pi*(FUSD/2)^2)*FUSL;
	% Very rough approximation
	dCmda_fus = 2*FUSV/SREF/CREF;
else
	dCmda_fus = beam_model.Param.CMAFUS;
end

[Res.Aero.RStability, Res.Aero.DStability] = get_stab_marginRE(beam_model.Aero.geo.ref_point, beam_model.WB.CG, ...
    CREF, SREF, dCmda_fus, Res.Aero.RStab_Der, Res.Aero.DStab_Der, outp);
%
fclose(outp);
%
return
% E' necessario dividere ogni variabile xx in xxl e xxr?
% Check on a model with planar splines
% Control beam_model.Aero.geo, nel passaggio a 'geo', verifica se conviene cambiare solo funzione che usa geo.CG
% Remove the dynamic pressure from the definition of Qaa, in order to allow for a computation with different flight speed and density from that of restart
