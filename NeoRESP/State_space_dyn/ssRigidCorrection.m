function ssmodelOut = ssRigidCorrection(ssmodel, l_a, rigidDOF)
%
%  ssmodelOut = ssRigidCorrection(ssmodel, l_a, rigidDOF)
%
%-------------------------------------------------------------------------------
% 29-08-2016
% 05-09-2016
% 11-09-2016 v1.2 multiple Mach supported (submodel)
% 22-10-2016 v2.0 Allow a selection of rigid modes
%

if nargin <= 2
	rigidModeTable = [(1:6)', (1:6)'];
else
	rigidDofUsed = find(rigidDOF(:,3));
	rigidModeTable = [rigidDofUsed, rigidDOF(rigidDofUsed,3)];
end

rigidPos = rigidModeTable(:,2);


% Reshape the SS model in order to have B1, B2 = 0
ssmodelOut = compactResidForm(ssmodel, 'high');
%ssmodelOut = ssmodel;

posu     = rigidModeTable((rigidModeTable(:,1)==1), 2);
posv     = rigidModeTable((rigidModeTable(:,1)==2), 2);
posw     = rigidModeTable((rigidModeTable(:,1)==3), 2);
posPhi   = rigidModeTable((rigidModeTable(:,1)==4), 2);
posTheta = rigidModeTable((rigidModeTable(:,1)==5), 2);
posPsi   = rigidModeTable((rigidModeTable(:,1)==6), 2);

posZero = [posu; posv; posw; posPhi];

% Correct the SS model +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% The correction implicitly uses the transformation matrix from inertial to 
% body axes (valid only for VORU condition):
% Lambda1 = [0,    0,     0;
%            0,    0, -Vinf;
%            0, Vinf,     0];


% First correction: in the body frame the steady aero forces do not depends on the orientation
% angles, but only on the velocity components


selectRows = 1:size(ssmodelOut(1).model(1).C,1);

nRows = length(selectRows);

%DeltaD = - (real(dyn_model.dlm.data.Qhh(selectRows,1:6,1,1)) + [zeros(nRows,4), l_a*ssmodelOut.model.D1(selectRows,3), -l_a*ssmodelOut.model.D1(selectRows,2)]);

nModels = length(ssmodelOut);

for iModel = 1:nModels

	nSubmodels = length(ssmodelOut(iModel).model);

	for iSubmodel = 1:nSubmodels

		model = ssmodelOut(iModel).model(iSubmodel);

		H0 = -model.C(selectRows,:)*(model.A\model.B0(:,rigidPos)) + model.D0(selectRows,rigidPos);

		DeltaD = -H0;
		DeltaD(:,posTheta) = DeltaD(:,posTheta) - l_a*model.D1(selectRows, posw);
		DeltaD(:,posPsi  ) = DeltaD(:,posPsi  ) + l_a*model.D1(selectRows, posv);


		DeltaD0 = DeltaD(:,posZero);

		DeltaD1w =  DeltaD(:,posTheta)/l_a;
		DeltaD1v = -DeltaD(:,posPsi  )/l_a;


		ssmodelOut(iModel).model(iSubmodel).D0(selectRows,[posZero]  ) = model.D0(selectRows,posZero    ) + DeltaD0;
		ssmodelOut(iModel).model(iSubmodel).D1(selectRows,[posv,posw]) = model.D1(selectRows,[posv,posw]) + [DeltaD1v, DeltaD1w];

	end
end












return
