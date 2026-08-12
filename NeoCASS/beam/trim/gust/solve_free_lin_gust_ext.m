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
%
%
%***********************************************************************************************************************
%
%
%
%***********************************************************************************************************************
%
% Run this solver after a first solution from solve_free_lin_trim
%
function [Res, Trim, SOL] = solve_free_lin_gust_ext(beam_model, Trim, state, Res, outp)

fid = beam_model.Param.FID; 

LOAD_SCALE = 1.0;
EPS = D2R(0.001); % perturbation value to extract aerodynamic derivatives


if (isempty(find(beam_model.Param.MSOL == 144)))
	error('SOL 144 must be given in input file to run linear static analysis.');
end

	fprintf(fid,'\nSolving linear static unrestrained trim...\n\n');
    fprintf(outp,'\n\nGUST MANEUVER\n');
    nc = beam_model.Aero.geo.nc;
%
%   select trim case
%
%
NDOF = 1;
STRIM = 1; 
FMDOF = [3];

%
%
ngrid = beam_model.Info.ngrid;
nbar  =  beam_model.Info.nbar;
nbeam =  beam_model.Info.nbeam;
ndof  =  beam_model.Info.ndof;
SPLINE_TYPE = beam_model.Info.spline_type;

%
%   CLEAR PREVIOUS SOLUTION
%

K = Res.Struct.K;
M = Res.Struct.M;

D = Res.Struct.D;

ldof = Res.Struct.ldof;
rdof = Res.Struct.rdof;

Kll = K(ldof, ldof);      
Klr = K(ldof, rdof);
Krr = K(rdof, rdof);    
Krl = K(rdof, ldof);

Fext = Res.Struct.F;

%   Mass matrix
Mll = M(ldof, ldof); Mlr = M(ldof, rdof); Mrr = M(rdof, rdof); Mrl = M(rdof, ldof); 
%   Rigid body mass matrix for the SUPORTED DOFs 
mr = Mrr + Mrl*D + D'*Mlr + D'*Mll*D;   
MSRR = mr; 


%-------------------------------------------------------------------------------
%   Restart previus solver
%
%  
Qaa = Res.Aero.Qaa;
Kax = Res.Aero.Kax;
Kaxl = Kax(ldof,:); 
Kaxr = Kax(rdof,:);

Qaall = Qaa(ldof, ldof);
Qaalr = Qaa(ldof, rdof);
Qaarl = Qaa(rdof, ldof);
Qaarr = Qaa(rdof, rdof);
  
for ntrim = 1:2
	%
	%   get total aerodynamic force (zero, trim and aeroelastic)
	%

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

	DUMMY = D'*Mll + Mrl;
	M2RR =  (D'*Mlr + Mrr) - DUMMY * ARLR;
	M3RR = -DUMMY * AMLR;
	K3LX = -DUMMY * ALX;
	DUMMYF = DUMMY;

	invM2RR = inv(M2RR);
	M4RR = invM2RR * M3RR;
	K4LX = invM2RR * K3LX;

	DUMMY = D'*Kall + Karl;
	K2RR = -DUMMY * ARLR + (D'*Kalr + Karr);
	KAZL = DUMMY;
	KARZX = (D'*Kaxl + Kaxr) - KAZL * ALX;

	M5RR = -K2RR * M4RR + MSRR;
	MIRR = -KAZL * AMLR + M5RR;
	invMIRR = inv(MIRR);
	KR1ZX = -K2RR * K4LX + KARZX;

	KR2ZX = -invMIRR * KR1ZX;
	Z1ZX = MSRR * KR2ZX;

	%
	%   GUST DATA
	%
	CREF = beam_model.Aero.ref.C_mgc;
	SREF = beam_model.Aero.ref.S_ref;
	cn_ALPHA = Res.Aero.RStab_Der.Alpha.dcl_dalpha;
	MASS = beam_model.WB.MCG(1,1); 
	mu_g = 2 * MASS / (CREF*SREF*cn_ALPHA*state.rho);
	Kg = (0.88 * mu_g) / (5.3 + mu_g);
	KEAS = sqrt(state.rho/1.225);

	VEAS = KEAS * state.AS;
	VG   = Trim.Extra.Value(1);
	DELTAN = 0.5 * 1.225 * (SREF/MASS) * cn_ALPHA * VEAS * Kg * VG;


	%
	%   Determine trim unknows
	%
	%   Access to previous acceleration values
	UDD(:,ntrim) = Trim.FM.Value(7:12)';

	%   Update URDD3
	UDD(FMDOF,ntrim) = UDD(FMDOF,ntrim) + DELTAN;

	%   Print data
	if (ntrim==1)
		fprintf(fid,'\n - Flight speed (EAS):    %g [m/s].', VEAS);
		fprintf(fid,'\n - Gust speed (EAS):      %g [m/s].', VG);
		fprintf(fid,'\n - Attenuation factor:    %g [].', Kg);
		fprintf(fid,'\n - Delta load factor:     %g [].', DELTAN/beam_model.Param.G);
		fprintf(fid,'\n - Total load factor:     %g [].\n', UDD(FMDOF,ntrim)/beam_model.Param.G);
	end

	%   Load previous solution and fix all trim variables
	Trim.FM.Fixed(1:end) = 1;

	%   SET ANGLEA as free
	Trim.FM.Fixed(2) = 0; 
	acc_dof = Trim.FM.Fixed(7:12);
	indexa = find(acc_dof); % fixed acc dofs

	Z1ZX_FM = Z1ZX(:,1:5);

	%   find ANGLEA
	TMAT = -Z1ZX_FM(FMDOF,1); % alpha term wrt plunge
	DRHS = -MSRR(:, FMDOF) .* DELTAN;

	sol = DRHS(FMDOF)/TMAT;
	UX = zeros(size(K4LX,2),ntrim);
	UX(1,ntrim) = sol;
	Res.FM.Value(ntrim, 2) = Res.FM.Value(ntrim, 2) + sol;
	Res.FM.Value(ntrim, 9) = UDD(FMDOF,ntrim);

	%   recover solution fm
	if ntrim==1
		Res.Aero.RTrim_sol.ACC = UDD(:,1);
		print_trim_sol(fid, Res.FM.Value(ntrim, 9), Res.FM.Value(ntrim, 2));
		Res.Aero.RTrim_sol.Alpha = Res.FM.Value(ntrim, 2) * 57.3;
		fprintf(outp, '\n\nCORRECTIONS TO RIGID TRIM\n');
		print_trim_sol(outp, Res.FM.Value(ntrim, 9), Res.FM.Value(ntrim, 2));
	else
		Res.Aero.DTrim_sol.ACC = UDD(:,2);
		print_trim_sol(fid, Res.FM.Value(ntrim, 9), Res.FM.Value(ntrim, 2));
		Res.Aero.DTrim_sol.Alpha = Res.FM.Value(ntrim, 2) * 57.3;
		fprintf(outp, '\n\nCORRECTIONS TO ELASTIC TRIM\n');
		print_trim_sol(outp, Res.FM.Value(ntrim, 9), Res.FM.Value(ntrim, 2));
	end

	fprintf(fid,'\ndone.');
end % trim loop


% Determine divergence dynamic pressure for the restrained aircraft if required
%
% Recover structural displacements and rotations
%
Fa0 = Res.Aero.Fa0tot(:,ntrim);
Fa = Fa0 - Res.Aero.KaxDOF(:,1) .* sol;

if ~isempty(beam_model.RBE2.ID)
	Fa2 = RBE2Assembly2(beam_model.RBE2,Fa);
end

F = Fext + Fa2;


UINTL = invKall * F(ldof,1);
TMP1 = DUMMYF * UINTL;
TMP2 = invM2RR * TMP1;

UR = -M4RR * UDD(:,ntrim) -TMP2; %- K4LX * UX(:,ntrim) - TMP2; 
UL = -AMLR * UDD(:,ntrim) - ARLR * UR + UINTL;% - ALX * UX(:,ntrim) + UINTL;

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
	beam_model.Res.NRd(:,:,n,1) = Rmat(gdef(n, 4:6));
end

% recover solution in matrix form
[DS, DR] = get_nodal_displ(beam_model.Info.ngrid, beam_model.Node.DOF, SOL); %

% update BAR rotations
Res.Bar.R = update_bar_rot(nbar, DR, beam_model.Bar.Conn, Res.Bar.R , DS);

% update BEAM rotations
Res.Beam.R = update_bar_rot(nbeam, DR, beam_model.Beam.Conn, Res.Beam.R , DS);

COORD = beam_model.Node.Coord + Res.NDispl(:,1:3);
Res.Bar.Colloc = bar_defo_colloc(nbar, beam_model.Bar, beam_model.Node.DOF, COORD, Res.NRd);
Res.Beam.Colloc = bar_defo_colloc(nbeam, beam_model.Beam, beam_model.Node.DOF, COORD, Res.NRd);

% calculate new mass matrix
Res.WB = [];
[Res.WB.CG, Res.WB.MCG, Res.WB.MRP] = wb_set_conm_mass(beam_model.Info.nconm, beam_model.Node.Index, COORD, Res.NRd, beam_model.Param.GRDPNT, beam_model.ConM);

% set bar mass CG
[Res.WB.CG, Res.WB.MCG, Res.WB.MRP] = wb_add_bar_mass(nbar, COORD, Res.NRd, Res.WB.CG, beam_model.Param.GRDPNT, Res.WB.MCG, Res.WB.MRP, beam_model.Bar);

% set beam mass CG
[Res.WB.CG, Res.WB.MCG, Res.WB.MRP] = wb_add_bar_mass(nbeam, COORD, Res.NRd, Res.WB.CG, beam_model.Param.GRDPNT, Res.WB.MCG, Res.WB.MRP, beam_model.Beam);

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
[Res.Bar.CForces, Res.Bar.CStrains, Res.Bar.CStresses, Res.Bar.CSM] = get_bar_force_strain(beam_model.Info.nbar, ...
                             beam_model.Bar, beam_model.PBar, beam_model.Mat, beam_model.Node, Res.NDispl, beam_model.Param.FUSE_DP);

% assembly BEAM contributions directly in the undeformed position
[Res.Beam.CForces, Res.Beam.CStrains, Res.Beam.CStresses, Res.Beam.CSM] = get_bar_force_strain(beam_model.Info.nbeam, ...
                             beam_model.Beam, beam_model.PBeam, beam_model.Mat, beam_model.Node, Res.NDispl, beam_model.Param.FUSE_DP);

% save internal aero database

% update final vector
index = find(Trim.CS.MPC);
for k=1:length(index)
	Res.CS.Value(2,index(k)) = Trim.CS.Coeff(index(k)) * Res.CS.Value(2,Trim.CS.MPC(index(k)));
end
  

fprintf(fid, '\n\ncompleted.\n\n');


return
%***********************************************************************************************************************
function print_trim_sol(fid, UDD, AOA)

	fprintf(fid,'\n - Z acc:      %g [m/s^2].', UDD);
	fprintf(fid,'\n - Alpha:      %g [deg].', AOA*180/pi);
 
return
