function ssmodelCorr = includeAeroCoef(ssmodel, aeroCoef, l_a, surfNames, suportCoord, rigidDOF);
%
%
%
%-------------------------------------------------------------------------------
% 24-01-2017
%

if nargin <= 6
	rigidModeTable = [(1:6)', (1:6)'];
else
	rigidDofUsed = find(rigidDOF(:,3));
	rigidModeTable = [rigidDofUsed, rigidDOF(rigidDofUsed,3)];
end

rigidPos = rigidModeTable(:,2);

% TODO :
% - manage case with reduced rigid set
% - general rotation on alpha
% - general system for definition of ceofficients (possibility to provide CX)

% % Reshape the SS model in order to have B1, B2 = 0
% ssmodelOut = compactResidForm(ssmodel, 'high');


posu     = rigidModeTable((rigidModeTable(:,1)==1), 2);
posv     = rigidModeTable((rigidModeTable(:,1)==2), 2);
posw     = rigidModeTable((rigidModeTable(:,1)==3), 2);
posPhi   = rigidModeTable((rigidModeTable(:,1)==4), 2);
posTheta = rigidModeTable((rigidModeTable(:,1)==5), 2);
posPsi   = rigidModeTable((rigidModeTable(:,1)==6), 2);

nRot = length([posPhi,posTheta,posPsi]);

% Define scaling matrices
cref = aeroCoef.cref;
bref = aeroCoef.bref;

if isfield(aeroCoef, 'crefAdim') && ~isempty(aeroCoef.crefAdim)
	crefAdim = aeroCoef.crefAdim;
else
	crefAdim = cref;
end

if isfield(aeroCoef, 'brefAdim') && ~isempty(aeroCoef.brefAdim)
	brefAdim = aeroCoef.brefAdim;
else
	brefAdim = bref;
end

Scale1 = aeroCoef.Sref*diag([1,1,1,-bref,cref,-bref]);
Scale2 = diag([-1,1,-1,-brefAdim,crefAdim,-brefAdim])/l_a;
Scale3 = diag([-crefAdim,brefAdim,-crefAdim,-brefAdim,crefAdim,-brefAdim])/l_a^2;

% Define moment transport matrix
DR = aeroCoef.refPoint - suportCoord;
DRcross = crossm(DR);

nModels = length(ssmodel);

% Initialize output
ssmodelCorr = ssmodel;

% TODO : introduce dependence on steady alpha and beta:
% - Rbs(alpha0)
% - linearized relation (u,v,w)->(u,alpha,beta)

nMachCoef = length(aeroCoef.Mach);

for iModel = 1:nModels

	nSubmodel = length(ssmodel(iModel).model);

	if isfield(ssmodel(iModel).inputGroup, 'j') && isfield(ssmodel(iModel).outputGroup, 'j')
		posjIn = ssmodel(iModel).inputGroup.j;
		posjOu = ssmodel(iModel).inputGroup.j;

		posrIn = posjIn(rigidPos);
		posrOu = posjOu(rigidPos);

		posDispIn = posjIn([posu,posv,posw]);
		posRotIn  = posjIn([posPhi,posTheta,posPsi]);
		posDispOu = posjIn([posu,posv,posw]);
		posRotOu  = posjIn([posPhi,posTheta,posPsi]);

		for iSubmodel = 1:nSubmodel

			Mach = ssmodel(iModel).mach(iSubmodel);

			% Get aerodynamic coefficients
			position = aeroCoef.Mach < Mach;
			if sum(position)==0 || nMachCoef==1
				C0 = aeroCoef.C0(:,:,1);
				F0 = aeroCoef.F0(:,:,1);
				C1 = aeroCoef.C1(:,:,1);

				% Coefficients constant w.r.t. Mach
				F0M_lin = zeros(6,1);

			elseif sum(position)==length(aeroCoef.Mach)
				C0 = aeroCoef.C0(:,:,end);
				F0 = aeroCoef.F0(:,:,end);
				C1 = aeroCoef.C1(:,:,end);

				% Coefficients constant w.r.t. Mach
				F0M_lin = zeros(6,1);

			else
				kk = sum(position);
				MachRatio = (Mach - aeroCoef.Mach(kk))/(aeroCoef.Mach(kk+1)-aeroCoef.Mach(kk));
				C0 = aeroCoef.C0(:,:,kk) + (aeroCoef.C0(:,:,kk+1)-aeroCoef.C0(:,:,kk))*MachRatio;
				F0 = aeroCoef.F0(:,:,kk) + (aeroCoef.F0(:,:,kk+1)-aeroCoef.F0(:,:,kk))*MachRatio;
				C1 = aeroCoef.C1(:,:,kk) + (aeroCoef.C1(:,:,kk+1)-aeroCoef.C1(:,:,kk))*MachRatio;

				% Derivative w.r.t. Mach number
				F0M_lin = (aeroCoef.F0(:,:,kk+1)-aeroCoef.F0(:,:,kk))*MachRatio;

			end

			% Transform Mach derivative in speed derivative
			if isfield(aeroCoef,'F0M') && ~isempty(aeroCoef.F0M)
				F0M = aeroCoef.F0M;
			else
				F0M = F0M_lin;
			end
			C0(:,1) = C0(:,1) + F0M*Mach;

			% Scale aero coefficients
			C0 = Scale1*C0*Scale2;
			C1 = Scale1*C1*Scale3;
			F0 = Scale1*F0;

			% Define stiffness associated with steady loads
			D0u = -2*F0/l_a;
			D0w = [- crossm(F0(1:3)); -crossm(F0(4:6))]*[0;1;0]/l_a;

			% Insert in matrices
			model = ssmodel(iModel).model(iSubmodel);

			% Remove static component contained in B0, B1, B2
			C0  = C0  + model.C(posrOu,:)*(model.A\model.B1(:,posrIn));
			C1  = C1  + model.C(posrOu,:)*(model.A\model.B2(:,posrIn));


			% Modify coefficients to include effect of steady loads
			D0 = model.D0;
			C0(:,1) = C0(:,1).*aeroCoef.setC0(:,1) + D0u.*aeroCoef.setF0;
			C0(:,3) = C0(:,3).*aeroCoef.setC0(:,1) + D0w.*aeroCoef.setF0;

			setC0 = aeroCoef.setC0;
			setC0(:,1) = setC0(:,1) + aeroCoef.setF0;
			setC0(:,3) = setC0(:,3) + aeroCoef.setF0;
			setC0(setC0>0) = 1;

			% Transport moments
			C0(4:6,:) = C0(4:6,:) + DRcross*C0(1:3,:);
			C1(4:6,:) = C1(4:6,:) + DRcross*C1(1:3,:);

			D1 = model.D1;
			D1(posrOu,posrIn) = D1(posrOu,posrIn).*(1-setC0) + C0.*setC0;

			D2 = model.D2;
			D2(posrOu,posrIn) = D2(posrOu,posrIn).*(1-aeroCoef.setC1) ...
			                  + C1.*aeroCoef.setC1;

			ssmodelCorr(iModel).model(iSubmodel).D1 = D1;
			ssmodelCorr(iModel).model(iSubmodel).D2 = D2;


		end
	end

	if isfield(ssmodel(iModel).inputGroup, 'c') && isfield(ssmodel(iModel).outputGroup, 'j')
		poscIn = ssmodel(iModel).inputGroup.c;
		posjOu = ssmodel(iModel).inputGroup.j;

		posrOu = posjOu(rigidPos);


		for iSubmodel = 1:nSubmodel

			Mach = ssmodel(iModel).mach(iSubmodel);

			% Get aerodynamic coefficients
			position = aeroCoef.Mach < Mach;
			if isempty(position) || nMachCoef == 1
				S0 = aeroCoef.S0(:,:,1);
			elseif sum(position)==length(aeroCoef.Mach)
				S0 = aeroCoef.S0(:,:,end);
			else
				kk = sum(position);
				MachRatio = (Mach - aeroCoef.Mach(kk))/(aeroCoef.Mach(kk+1)-aeroCoef.Mach(kk));
				S0 = aeroCoef.S0(:,:,kk) + (aeroCoef.S0(:,:,kk+1)-aeroCoef.S0(:,:,kk))*MachRatio;
			end

			% Scale aero coefficients
			S0 = Scale1*S0;

			% Transport moments
			S0(4:6,:) = S0(4:6,:) + DRcross*S0(1:3,:);


			% TODO : make selection of rows of S0

			% Insert in matrices
			model = ssmodel(iModel).model(iSubmodel);

			for iSurf = 1:length(aeroCoef.surfNames)
				position = find(strcmp(aeroCoef.surfNames{iSurf},surfNames));

				if ~isempty(position)
					% Remove static component contained in B0, B1, B2
					S0corr = S0(:,iSurf) + model.C(posrOu,:)*(model.A\model.B0(:,poscIn(position)));

					D0 = model.D0;
					D0(posrOu,poscIn(position)) = D0(posrOu,poscIn(position)).*(1-aeroCoef.setS0(:,iSurf)) ...
					                            + S0corr.*aeroCoef.setS0(:,iSurf);
				else
					fprintf('Warning : surface %s not found, skipping\n', aeroCoef.surfNames{iSurf});
				end
			end

			ssmodelCorr(iModel).model(iSubmodel).D0 = D0;

		end
	end
end













return
