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
%***********************************************************************************************************************
function assembly_dyn_model(filename)

% global beam_model;
global dyn_model;
global beam_model;
global fl_model;
%

dyn_model = [];

beam_model = load_nastran_model(filename);
fid = beam_model.Param.FID;
%
MASTER = [];
MODACC = beam_model.Param.MODACC;
%
if (~isempty(find(beam_model.Param.MSOL == 145,1)))
%    
      fprintf(fid,'\nPreprocessing modal dynamic response analysis...\n');
%
%       Check PARAMS for dynamic solution
        if isempty(beam_model.Param.VREF)
          error('PARAM VREF not defined.');
        end
        if isempty(beam_model.Param.RHOREF)
          error('PARAM RHOREF not defined.');
        end
        if isempty(beam_model.Param.MACH)
          error('PARAM MACH not defined.');
        end
%
%
%
        fprintf(fid,'\n\tRunning DLM solver for aerodynamic transfer matrix calculation...\n');
%---------------------------------------------------------------------------------------------------
%       DLM struct
%---------------------------------------------------------------------------------------------------
        dlm_model = set_struct(fid, beam_model.Aero.state.Mach_qhh, beam_model.Aero.state.Kfreq, ...
                               beam_model.Aero.ref.C_mgc, beam_model.Aero.state.SIMXZ, ...
                               beam_model.Param.DLM_ORDER, beam_model.Aero.lattice_dlm.dx, beam_model.Param.DLM_NP);
        beam_model.Param.SUP_MAMPL = 1;

%---------------------------------------------------------------------------------------------------
%       Define table of rigid modes
%---------------------------------------------------------------------------------------------------

[rigidDOF, nRigid, rigidDofUsed] = rigidDofTable(beam_model.Param.SUPORT);


%---------------------------------------------------------------------------------------------------
%       MODAL BASE - defo modes + control surfs modes
%---------------------------------------------------------------------------------------------------
        if isempty(beam_model.Param.EIG_FILE)
            solve_eig;
            rigidDOF(rigidDofUsed,3) = 1:nRigid;
            selectRigid = rigidDOF(rigidDofUsed, 3);
        else
           position = find((beam_model.Param.FILE=='/') | (beam_model.Param.FILE=='\'));

           if ~isempty(position)
             baseDirectory = beam_model.Param.FILE(1:position(end));
           else
             baseDirectory = './';
           end

           % load data from external files

           filename_mas = [beam_model.Param.EIG_FILE, '.mas'];
           filename_stf = [beam_model.Param.EIG_FILE, '.stf'];
           filename_mod = [beam_model.Param.EIG_FILE, '.mod'];

           if ~exist(filename_mas, 'file'); filename_mas = [baseDirectory, filename_mas]; end
           if ~exist(filename_stf, 'file'); filename_stf = [baseDirectory, filename_stf]; end
           if ~exist(filename_mod, 'file'); filename_mod = [baseDirectory, filename_mod]; end

          beam_model.Res.Mmm = load(filename_mas);
          beam_model.Res.Kmm = load(filename_stf);
          EXT_MODES = load(filename_mod);

          ngrid = beam_model.Info.ngrid;
          if mod(size(EXT_MODES, 1), ngrid)  
            error('Mode shape file %s does not contain displacements for all vibration modes.', filename);
          end
          NMODES = size(beam_model.Res.Mmm, 1);
          ncol = size(EXT_MODES, 2);
          beam_model.Res.NDispl = zeros(ngrid, ncol-1, NMODES);
          id = EXT_MODES(1:ngrid, 1);
          [v, i1, i2] = intersect(beam_model.Node.ID, id);
          counter = 0;
          for n=1:NMODES
            beam_model.Res.NDispl(i1, 1:ncol-1, n) = EXT_MODES(i2 + counter, 2:ncol);      
            counter = counter + ngrid;
          end
          beam_model.Res.Omega = sqrt(diag(beam_model.Res.Kmm)./diag(beam_model.Res.Mmm));
          Freq = beam_model.Res.Omega ./ (2*pi);
          beam_model.Res.ID = [1:NMODES];
          fprintf(fid,' \n ### Warning: loaded mode shapes will have sequential ID number.');
          il = find(Freq >= beam_model.Param.MINF);
          if (isempty(il))
            error('No eigenvalue higher than %g found.', beam_model.Param.MINF);   
          end
          ih = find(Freq <= beam_model.Param.MAXF);
          if (isempty(ih))
            error('No eigenvalue lower than %g found.', beam_model.Param.MAXF);   
          end
          index = intersect(il, ih);
          if (isempty(index))
            error('Unable to extract vibration modes for the required frequency range.');
          end
          if (~isempty(beam_model.Param.MSELECT))
            [v, ia, ib] = intersect(beam_model.Res.ID, beam_model.Param.MSELECT);
            index = intersect(index, ia);
            beam_model.Res.Omega = beam_model.Res.Omega(index);
            Freq = Freq(index);
            beam_model.Res.ID = beam_model.Res.ID(index);
            beam_model.Res.NDispl = beam_model.Res.NDispl(:,:,index);
            beam_model.Res.Mmm = beam_model.Res.Mmm(index,index);
            beam_model.Res.Kmm = beam_model.Res.Kmm(index,index);
            NMODES = length(index);
          end
%         overwrite rigid body modes
          if nRigid > 0
            selectRigid = rigidDOF(rigidDofUsed, 3);
            fprintf(fid,' \n ### Warning: rigid body modes will be overwritten with unitary modes at CG.');
            [RMODE, RMODE2, RINDEX, KEPS] = get_CG_shapes(beam_model.Node, beam_model.RBE2, beam_model.WB.CG, beam_model.Param.SUPORT);
            beam_model.Res.NDispl(:,:,selectRigid) = get_mode_shapes(beam_model.Info.ngrid, beam_model.Node.DOF, nRigid, RMODE2);
            beam_model.Res.Mmm(selectRigid,selectRigid) = beam_model.WB.MCG(rigidDofUsed,rigidDofUsed);
          end


          SDAMP = beam_model.Param.SDAMP;
          if (beam_model.Param.SDAMP)
            fprintf(fid,'\n - Building complex stiffness matrix for damping...');
            DAMP = beam_model.Damp;
            beam_model.Res.Gmm = modal_damp(DAMP.g{SDAMP}, DAMP.Freq{SDAMP}, DAMP.Type(SDAMP), 0, ...
                            beam_model.Res.Mmm, beam_model.Res.Omega./(2*pi));
            fprintf(fid, 'done.');
          end

        end
%        
        NMODES = size(beam_model.Res.NDispl, 3);
        NMACH  = length(dlm_model.aero.M);
        NK     = length(dlm_model.aero.k);
        beam_model.Aero.lattice = beam_model.Aero.lattice_dlm;
%        
        np = beam_model.Aero.lattice.np;
        SPLINE_TYPE = beam_model.Info.spline_type;
%       boundary condition
        if (SPLINE_TYPE==1)
          [dlm_model.data.c_displ, dlm_model.data.dwnwash, dlm_model.data.n_displ] = ...
            set_boundary_condition1(fid, beam_model.Aero.geo, beam_model.Aero.lattice, dlm_model, beam_model.Node, ...
            beam_model.Res.NDispl, beam_model.Aero, true, false);  
        else
          [dlm_model.data.c_displ, dlm_model.data.dwnwash, dlm_model.data.n_displ] = set_boundary_condition(fid, beam_model.Aero.geo, ...
                                                                                     beam_model.Aero.lattice, dlm_model, beam_model.Node.Coord, ...
                                                                                     beam_model.Res.NDispl, beam_model.Aero, true, false);
        end
        CONTR_SURF = beam_model.Aero.geo.nc;
%       boundary condition for control surfaces
        counter = 0;
        if (CONTR_SURF)
            NMODES = size(dlm_model.data.c_displ,3);
            index = find(beam_model.Aero.geo.flapped);
            %
            CSURF_MODES = zeros(size(dlm_model.data.c_displ,1), 3, length(index));
            DSURF_MODES = zeros(size(dlm_model.data.dwnwash,1), length(index), NK);
            NSURF_MODES = zeros(size(dlm_model.data.n_displ,1), 3, length(index));
            %
            for n=1:length(index)
                REF_POINT(1:3) = beam_model.Aero.lattice.Control.Hinge(n,1,:);
                HINGE_AXIS(1:3) = beam_model.Aero.lattice.Control.Hinge(n,2,:) - beam_model.Aero.lattice.Control.Hinge(n,1,:);
                HINGE_AXIS = HINGE_AXIS ./norm(HINGE_AXIS);
                % construct modes for control surfaces
                [CSURF_MODES(:,:,n), DSURF_MODES(:,n,:), NSURF_MODES(:,:,n)] = ...
                    set_patch_crigid_bc(dlm_model.aero.cref, dlm_model.aero.V, beam_model.Aero.lattice.MID_DPOINT(1:np,:), ...
                                        beam_model.Aero.lattice.COLLOC(1:np,:), beam_model.Aero.lattice.XYZ(1:np,:,:), ...
                                        beam_model.Aero.lattice.N(1:np,:), REF_POINT, beam_model.Aero.lattice.Control.DOF(n).data, ...
                                        HINGE_AXIS, beam_model.Param.SUP_MAMPL, dlm_model.aero.k, ...
                                        true, false);
            end
            %
            if (beam_model.Info.nlink)
                
                counter = length(unique(beam_model.Aero.Trim.Link.Master));
                MASTER = unique(beam_model.Aero.Trim.Link.Master);
                master = zeros(counter,1);
                sl_control_index = zeros(counter, 2);
                added_surf = [];
                %       get master
                for nmas = 1:length(MASTER)
                    for ncontrols = 1:beam_model.Aero.geo.nc
                        if (isequal(MASTER{nmas}, beam_model.Aero.lattice.Control.Name{ncontrols}))
                            master(nmas) = ncontrols;
                            added_surf = [added_surf, ncontrols];
                            break;
                        end
                    end
                end
                %       get slaves
                for m=1:length(MASTER)
                    dlm_model.data.c_displ(:,:,NMODES+m) = CSURF_MODES(:,:,master(m));
                    dlm_model.data.dwnwash(:,NMODES+m,:) = DSURF_MODES(:,master(m),:);
                    dlm_model.data.n_displ(:,:,NMODES+m) = NSURF_MODES(:,:,master(m));
                    for k=1:length(beam_model.Aero.Trim.Link.Slave)
                        if (isequal(beam_model.Aero.Trim.Link.Master{k}, MASTER{m}))
                            for ncontrols = 1:beam_model.Aero.geo.nc
                                if (isequal(beam_model.Aero.Trim.Link.Slave{k}, beam_model.Aero.lattice.Control.Name{ncontrols}))
                                    control_index(nmas,ncontrols) = ncontrols;
                                    added_surf = [added_surf, ncontrols];
                                    break;
                                end
                            end
                            dlm_model.data.c_displ(:,:,NMODES+m) = dlm_model.data.c_displ(:,:,NMODES+m)+CSURF_MODES(:,:,ncontrols).*beam_model.Aero.Trim.Link.Coeff(k);
                            dlm_model.data.dwnwash(:,NMODES+m,:) = dlm_model.data.dwnwash(:,NMODES+m,:)+DSURF_MODES(:,ncontrols,:).*beam_model.Aero.Trim.Link.Coeff(k);
                            dlm_model.data.n_displ(:,:,NMODES+m) = dlm_model.data.n_displ(:,:,NMODES+m)+NSURF_MODES(:,:,ncontrols).*beam_model.Aero.Trim.Link.Coeff(k);
                        end
                    end
                end
                %       add independent surfaces
                missing_surf = setdiff(1:beam_model.Aero.geo.nc, added_surf);
                if (~isempty(missing_surf))
                    
                    missing_surf_name = setdiff(beam_model.Aero.lattice.Control.Name,beam_model.Aero.lattice.Control.Name(added_surf));
                    [missing_surf_name,ordersurf] = unique(missing_surf_name);
                    
                    missing_surf = missing_surf(ordersurf);
                    NMODES3 = NMODES + length(MASTER);
                    for m=1:length(missing_surf)
                        dlm_model.data.c_displ(:,:,NMODES3+m) = CSURF_MODES(:,:,missing_surf(m));
                        dlm_model.data.dwnwash(:,NMODES3+m,:) = DSURF_MODES(:,missing_surf(m),:);
                        dlm_model.data.n_displ(:,:,NMODES3+m) = NSURF_MODES(:,:,missing_surf(m));
                    end
                    MASTER = [MASTER, beam_model.Aero.lattice.Control.Name{missing_surf}];
%                     NMODES = NMODES + length(missing_surf);
%                     counter = counter + length(missing_surf);
                end
                %
            else
                m = 1:length(index);
                dlm_model.data.c_displ(:,:,NMODES+m) = CSURF_MODES(:,:,m);
                dlm_model.data.dwnwash(:,NMODES+m,:) = DSURF_MODES(:,m,:);
                dlm_model.data.n_displ(:,:,NMODES+m) = NSURF_MODES(:,:,m);
                counter = beam_model.Aero.geo.nc;
                MASTER = beam_model.Aero.lattice.Control.Name;
            end
        end
%
        NMODES2 = NMODES;
        NMODES = size(dlm_model.data.c_displ,3);
        fprintf('\nAdded %d control surface modes.', NMODES - NMODES2);
        dlm_model.data.D = assembly_AIC_matrix(fid, beam_model.Aero.lattice, dlm_model);
%---------------------------------------------------------------------------------------------------
%      MODAL CP
%---------------------------------------------------------------------------------------------------
        [dlm_model.data.Cp, dlm_model.data.invD] = solve_system_CP(fid, np, NK, NMODES, NMACH, dlm_model.data.D, dlm_model.data.dwnwash);
%        Build modal aero transfer matrix HAM
        dlm_model.data.Qhh = set_generalized_f(fid, NMODES, dlm_model.data.c_displ, NK, NMACH, beam_model.Aero.lattice.area(1:np), ...
            beam_model.Aero.lattice.N(1:np,:), dlm_model.data.Cp);
%        Build nodal aero transfer matrix HAM*
        if (MODACC == 0)
          % interface collocation points
          fprintf(fid, '\n - Assemblying collocation points interpolation matrix...'); 
          if (SPLINE_TYPE == 1)
            cref = dlm_model.aero.cref;
            beam_model.Aero.Interp.Imv = assembly_midv_interp_mat1(beam_model.Info.ncaero, beam_model.Node, beam_model.Aero, beam_model.Aero.lattice.COLLOC*cref);
          else
            beam_model.Aero.Interp.Imv = assembly_colloc_interp_mat(beam_model.Info.ncaero, beam_model.Node, beam_model.Aero);
          end

          fprintf(fid, 'done.'); 
          dlm_model.data.Qnh = set_nodal_f(fid, beam_model.Info, beam_model.Node, NMODES, beam_model.Aero, NK, NMACH, dlm_model.data.Cp);
        end
%
%       Aero derivatives       
        beam_model.Res.Aero = []; beam_model.Res.Aero.RStab_Der = [];
        dlm_model.data.Qhh = dlm_model.data.Qhh./(beam_model.Param.SUP_MAMPL^2);
        CHREF = dlm_model.aero.cref; 
        CREF = CHREF*2;
        BREF = beam_model.Aero.ref.b_ref;
        SREF = beam_model.Aero.ref.S_ref;
%
        % Generate fake Ham with all the 6x6 rigid DOFs
        if nRigid > 0
          Ham_rigid = zeros(6+counter,6+counter,NK,NMACH);
          Ham_rigid(rigidDofUsed,rigidDofUsed,:,:)   = dlm_model.data.Qhh(selectRigid,selectRigid,:,:);
          Ham_rigid(rigidDofUsed,6+(1:counter),:,:)  = dlm_model.data.Qhh(selectRigid,NMODES2+(1:counter),:,:);
          Ham_rigid(6+(1:counter), rigidDofUsed,:,:) = dlm_model.data.Qhh(NMODES2+(1:counter),selectRigid,:,:);
          Ham_rigid(6+(1:counter),6+(1:counter),:,:) = dlm_model.data.Qhh(NMODES2+(1:counter),NMODES2+(1:counter),:,:);
          beam_model.Res.Aero.RStab_Der = get_dynder(NMACH, dlm_model.aero.k, CHREF, CREF, BREF, SREF, Ham_rigid, counter, MASTER);
        else
          beam_model.Res.Aero.RStab_Der = [];
        end
%
        if (CONTR_SURF)
            dlm_model.data.Qhd = dlm_model.data.Qhh(1:NMODES2,NMODES2+1:end,:,:);
            dlm_model.data.Qdh = dlm_model.data.Qhh(NMODES2+1:end,1:NMODES2,:,:);
            dlm_model.data.Qdd = dlm_model.data.Qhh(NMODES2+1:end,NMODES2+1:end,:,:);
            dlm_model.data.Qhh = dlm_model.data.Qhh(1:NMODES2,1:NMODES2,:,:);
            if (MODACC == 0)
              dlm_model.data.Qnd = dlm_model.data.Qnh(:,NMODES2+1:end,:,:);
              dlm_model.data.Qnh = dlm_model.data.Qnh(:,1:NMODES2,:,:);
            end
        else
            dlm_model.data.Qhd = [];
            dlm_model.data.Qdh = [];
            dlm_model.data.Qdd = [];
            if (MODACC == 0)
              dlm_model.data.Qnd = [];
              dlm_model.data.Qnh = [];
            end
        end
%
        Gmm = zeros(NMODES2); % complex stiff
        if (beam_model.Param.SDAMP)
          Gmm = beam_model.Res.Gmm;
        end
%
        export_str_modal_ffa(fid, beam_model.Param.FILE, beam_model.Node.ID, beam_model.Node.Coord, beam_model.Res.NDispl, ...
                              beam_model.Res.ID, beam_model.Res.Mmm, beam_model.Res.Kmm, Gmm);
        %   export aerodynamic transfer matrix
        export_qhh_massa(fid, beam_model.Param.FILE, dlm_model.aero.k, dlm_model.aero.M, dlm_model.data.Qhh);
        %   require FFA matlab toolbox
        export_qhh_ffa(fid, beam_model.Param.FILE, dlm_model.aero.k, dlm_model.aero.M, dlm_model.data.Qhh, dlm_model.aero.cref);
        fprintf(fid, '\n\n\tdone.\n');
%
%
%
%       Check rigid modes are found
        if (beam_model.Param.MINF>eps)
          error('Minimum cut-off modal frequency in EIGR card must be set to null value. Rigid modes required.');
        else
          fprintf(fid,'\n\tRigid modes will be considered in modal base (EIGR).');
        end        
%       Define used modes
        if (isempty(beam_model.Param.MSELECT))
%          if (beam_model.Param.NROOTS == 0)
%            NMODES = int32(beam_model.Info.ndof);
%          else
%            NMODES = beam_model.Param.NROOTS;
%          end
            mbase = beam_model.Res.ID;
        else
            mbase = beam_model.Param.MSELECT;
        end
%       Define flutter modes
        if (isempty(beam_model.Param.FMODES))
            flwbase = mbase;
        else
            flwbase = beam_model.Param.FMODES;
            flwbase = intersect(flwbase, mbase);
        end
%       delete rigid body modes from FMODES
        index = find(flwbase<6);
        if (~isempty(index))
          fprintf(fid,'\n\tRigid body modes will be discarded from FMODES set.');
          flwbase = flwbase(find(flwbase>6));
        end
%       check UMODES are included in FMODES
        if (~isempty(beam_model.Param.UMODES))
          UMODESE = beam_model.Param.UMODES(find(beam_model.Param.UMODES>6));
          if (~all(ismember(UMODESE, flwbase)))
            error('UMODES are not a subset of FMODES. Please check.');
          end
        end
%       check FMODES are included in mbase
        if (~all(ismember(flwbase, mbase)))
          error('FMODES are not a subset of select modal base (through NROOTS in EIGR card or MSELECT). Please check.');
        end
%---------------------------------------------------------------------------------------------------
%      STABILITY: flutter and rigid modes 
%---------------------------------------------------------------------------------------------------
%
        res = zeros(NMACH, 2);
        dtpos = find('.' == beam_model.Param.FILE);
        headname = [];
        %
        vrange = [];
        rho = beam_model.Param.RHO_VG;
        vmax =  beam_model.Param.VMAX;
        vstep = vmax/beam_model.Param.NVSTEP;
        if (isempty(dtpos))
            headname = beam_model.Param.FILE;
        else
            headname = beam_model.Param.FILE(1:dtpos(end)-1);
        end
        strf = [headname, '.bmod'];
        %   clean or define Res field
        fl_model.Res = []; fl_model.Res.data = []; fl_model.Res.Env = [];
        % Run flutter and rigid modes tracking
        nfig = 99; RigRes = []; RigRes.data = [];
        for n=1:NMACH
%   
            if nRigid > 0
              [nfig, RigRes] = rig_modes(fid, nfig, beam_model.Param.RHO_VG, [vstep:vstep:vmax], dlm_model.aero.M(n), CREF, BREF, SREF,...
                               beam_model.WB.MCG(1,1), diag(beam_model.WB.MCG(4:6,4:6)), ...
                               beam_model.Res.Aero.RStab_Der, n, RigRes);
            end
            %
            Hamf = zeros(NMODES2,NMODES2,NK*2);
            Hamf(:,:,1:2:NK*2) = dlm_model.data.Qhh(:,:,1:NK,n);
            nfig = nfig + 1;
            [VF{n}, HF{n}] = run_flutter(fid, beam_model.Res.Mmm, Gmm*beam_model.Res.Kmm, beam_model.Res.Kmm, beam_model.Res.Omega./(2*pi), ...
            beam_model.Res.ID, Hamf, dlm_model.aero.k, dlm_model.aero.M(n), CHREF, mbase, flwbase, rho, [vstep, vmax], true, nfig, n);
        end

        beam_model.Struct = beam_model.Res;
        beam_model = rmfield(beam_model, 'Res');
        beam_model.Struct.rigidDOF = rigidDOF;
        dyn_model.dlm  = dlm_model;
        dyn_model.beam = beam_model;
        fl_model = rmfield(fl_model,'aero');
        dyn_model.flu  = fl_model;
        dyn_model.flu.Res_rigid = RigRes;


%---------------------------------------------------------------------------------------------------
%      GUST
%---------------------------------------------------------------------------------------------------
        if ~isempty(dyn_model.beam.Gust.ID)
            fprintf(fid,'\n - Assemblying gust model...');
            init_gust;
            fprintf(fid,'done.');
        end
%---------------------------------------------------------------------------------------------------
%      OUTPUT DATA FOR RESPONSE
%---------------------------------------------------------------------------------------------------

        % Save surface name
        dyn_model.Out.surfaceName = MASTER;

        fprintf(fid,'\n - Assemblying structural responces model...');
%       DISPLACEMENT 
        if ~isempty(dyn_model.beam.Param.DISP)
            dyn_model.Out.DISP = reshape(dyn_model.beam.Struct.NDispl(dyn_model.beam.Param.DISP,:,:),length(dyn_model.beam.Param.DISP)*6,NMODES2,1);
        end
%       VELOCITY 
        if ~isempty(dyn_model.beam.Param.VELOCITY)
            dyn_model.Out.VELOCITY = reshape(dyn_model.beam.Struct.NDispl(dyn_model.beam.Param.VELOCITY,:,:),length(dyn_model.beam.Param.VELOCITY)*6,NMODES2,1);
        end
%       ACCELERATION 
        if ~isempty(dyn_model.beam.Param.ACCELERATION)
            dyn_model.Out.ACCELERATION = reshape(dyn_model.beam.Struct.NDispl(dyn_model.beam.Param.ACCELERATION,:,:),length(dyn_model.beam.Param.ACCELERATION)*6,NMODES2,1);
        end
%       FORCE bar       
        if ~isempty(dyn_model.beam.Param.IFORCE)
            dyn_model.Out.IFORCE = get_auto_internal_load(dyn_model.beam.Param.IFORCE, dyn_model.beam.Bar, dyn_model.beam.PBar, dyn_model.beam.Mat, ...
                                     dyn_model.beam.Node, dyn_model.beam.Struct.NDispl);
        end
%       FORCE beam       
        if ~isempty(dyn_model.beam.Param.IFORCEBE)
            dyn_model.Out.IFORCEBE = get_auto_internal_load(dyn_model.beam.Param.IFORCEBE, dyn_model.beam.Beam, dyn_model.beam.PBeam, dyn_model.beam.Mat, ...
                                       dyn_model.beam.Node, dyn_model.beam.Struct.NDispl);
        end
        fprintf(fid,'done.');
%
        fprintf(fid,'\ndone\n');
%         
        clear beam_model;
        clear dlm_model;
        clear fl_model;
%
end
