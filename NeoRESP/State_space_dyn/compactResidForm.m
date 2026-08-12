function ssmodelOut = compactResidForm(ssmodelIn, type)
%
% ssmodelOut = compactResidForm(ssmodelIn, type)
%
%
%
%
%-------------------------------------------------------------------------------
% 05-08-2016
%

if nargin==1
	type = 'low';
end


ssmodelOut = ssmodelIn;

nModels = length(ssmodelOut);

switch type
case 'low'
	% Model on form
	% wdot = A*w + (B0 + A*B1 + A*A*B2)*u
	%    y = C*w + (D0 + C*B1 + C*A*B2)*u + (D1 + C*B2)*udot + D2*uddot
	%
	% Y(0) = [-C*A\(B0 + A*B1 + A*A*B2) + D0 + C*B1 + C*A*B2]*U(0)
	%      = [-C*A\B0 - C*B1 - C*A*B2 + D0 + C*B1 + C*A*B2]*U(0)
	%      = [-C*A\B0 + D0]*U(0)
	%

% xd = A*x + B0*u + B1*ud + B2*udd ==> xd - B2*udd = A*x -A*B2*ud + A*B2*ud + B0*u + B1*ud
% v = x - B2*ud ==> vd = A*v + B0*u + (B1+A*B2)*ud 
% w = v - (B1+A*B2)u ==> wd = A*w + (B0 + A*B1 + A*A*B2)*u
%
% v = w + (B1+A*B2)u
% x = v + B2*ud = w + (B1+A*B2)*u + B2*ud
%
% y = C*x + D0*u + D1*ud + D2*udd
%

	for iModel = 1:nModels

		nSubmodel = length(ssmodelIn(iModel).model);

		for iSubmodel = 1:nSubmodel

			model = ssmodelIn(iModel).model(iSubmodel);

			B0bar = model.B0 + model.A*(model.B1 + model.A*model.B2);

			D0bar = model.D0 + model.C*(model.B1 + model.A*model.B2);
			D1bar = model.D1 + model.C*model.B2;

			ssmodelOut(iModel).model(iSubmodel).B0 = B0bar;
			ssmodelOut(iModel).model(iSubmodel).B1 = zeros(size(ssmodelOut(iModel).model(iSubmodel).B1));
			ssmodelOut(iModel).model(iSubmodel).B2 = zeros(size(ssmodelOut(iModel).model(iSubmodel).B2));

			ssmodelOut(iModel).model(iSubmodel).D0 = D0bar;
			ssmodelOut(iModel).model(iSubmodel).D1 = D1bar;

		end
	end
	% y = -C(sI-A)\(B0 + B1*s + B2*s^2) + D0 + D1*s + D2*s^2
	% y(0) = -C*A\B0 + D0
	% y_s = C(sI-A)\(sI-A)\(B0 + B1*s + B2*s^2) - C(sI-A)\(B1 - 2*s*B2) + D1 + 2*s*D2
	% y_s(0) = C*A\A\B0 - C*A\B1 + D1

	% C*A\A\(B0+A*B1+A*A*B2) + D1 + C*B2 = C*A\A\B0 + C*A\B1 + C*B2 + D1 + C*B2

	% wdot = A*w + (B0 + A*B1 + A*A*B2)*u
	%    y = C*w + (D0 + C*B1 + C*A*B2)*u + (D1 + C*B2)*udot + D2*uddot
case 'high'
	for iModel = 1:nModels

		nSubmodel = length(ssmodelIn(iModel).model);

		for iSubmodel = 1:nSubmodel

			model = ssmodelIn(iModel).model(iSubmodel);

			B1bar = model.B1 + model.A\model.B0;
			D0bar = model.D0 - model.C*(model.A\model.B0);

			B2bar = model.B2 + model.A\B1bar;
			D1bar = model.D1 - model.C*(model.A\B1bar);

			%D2bar = model.D2 - model.C*(model.A\B2bar);

			ssmodelOut(iModel).model(iSubmodel).B0 = zeros(size(ssmodelOut(iModel).model(iSubmodel).B0));
			ssmodelOut(iModel).model(iSubmodel).B1 = zeros(size(ssmodelOut(iModel).model(iSubmodel).B1));
			ssmodelOut(iModel).model(iSubmodel).B2 = B2bar;

			ssmodelOut(iModel).model(iSubmodel).D0 = D0bar;
			ssmodelOut(iModel).model(iSubmodel).D1 = D1bar;
			%ssmodelOut(iModel).model.D2 = D2bar;

		end
	end
end






return
