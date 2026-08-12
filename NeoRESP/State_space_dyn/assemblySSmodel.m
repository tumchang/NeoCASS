function ssmodel = assemblySSmodel(SSmodelArray, inputList, outputList)
%
% ssmodel = assemblySSmodel(SSmodelArray, inputList, outputList)
%
% Generates the state space system with the desired inputs (inputList)
% and outputs (outputList). The model is generated from a set of models
% contained in the structure array SSmodelArray
%
%-------------------------------------------------------------------------------
% 29-06-2016
%

nInGroups = length(inputList);
nOuGroups = length(outputList);

nModels = length(SSmodelArray);

modelTableIn = zeros(nInGroups,nModels);
modelTableOu = zeros(nOuGroups,nModels);

inputGroup = [];
outputGroup = [];


% Create a output/models correspondence table: for each model defines the 
% contained outputs
for iModel = 1:nModels
	fieldListOu = fieldnames(SSmodelArray(iModel).outputGroup);
	for iGroup = 1:nOuGroups
		modelTableOu(iGroup,iModel) = ~isempty(find(strcmp(fieldListOu, outputList{iGroup})));
	end
end


% Check if requested inputs are inputs in model array, get
% the first occurence of the input in model array
for iGroup = 1:nInGroups

	foundIn = false;

	outputsFound = zeros(nOuGroups,1);
	for iModel = 1:nModels
		fieldListIn = fieldnames(SSmodelArray(iModel).inputGroup);
		if ~isempty(find(strcmp(fieldListIn, inputList{iGroup})))
			foundIn = true;

			outputsMissing = find(1 - outputsFound);

			modelOutputs = modelTableOu(outputsMissing,iModel);

			nOutModel = sum(modelOutputs);

			outputsFound(outputsMissing) = outputsFound(outputsMissing) + modelOutputs;

			% If the model has some outputs (not already found), keep it
			if nOutModel >= 1
				modelTableIn(iGroup, iModel) = 1;
			end

			% If the model has all the desired outputs, stop searching
			if sum(outputsFound)==nOuGroups
				break
			end

		end
	end

	if ~foundIn
		error('The selected input %s is not contained in the provided model', inputList{iGroup});
	end

	if sum(outputsFound)==0
		error('Input %s is not connected to any of the selected outputs', inputList{iGroup});
	elseif sum(outputsFound) < nOuGroups
		delta = nOuGroups - sum(outputsFound);
		fprintf('WARNING!!! %d outputs are not linked to input %s\n', delta, inputList{iGroup});
	end

	inputGroup = setfield(inputGroup, inputList{iGroup}, []);

end

% Set input/output length
nInputs = 0;
InPosition_old = {};
InPosition_new = {};
for iGroup = 1:nInGroups
	% For each input, for each selected model, define the position in the input vector
	relatedModels = find(modelTableIn(iGroup,:));
	for iModel = 1:length(relatedModels)
		jModel = relatedModels(iModel);
		position = getfield(SSmodelArray(jModel).inputGroup, inputList{iGroup});
		if iModel==1
			groupDim = length(position);
			inPosition_old{iGroup} = zeros(groupDim,nModels);
		end
		inPosition_old{iGroup}(:,jModel) = position;
	end
	% Position of the input in the input vector for the new system
	inPosition_new{iGroup} = nInputs + (1:groupDim);
	inputGroup = setfield(inputGroup, inputList{iGroup}, inPosition_new{iGroup});
	nInputs = nInputs + groupDim;
end

nOutputs = 0;
ouPosition_old = {};
ouPosition_new = {};
for iGroup = 1:nOuGroups
	relatedModels = find(modelTableOu(iGroup,:));
	for iModel = 1:length(relatedModels)
		jModel = relatedModels(iModel);
		position = getfield(SSmodelArray(jModel).outputGroup, outputList{iGroup});
		if iModel==1
			groupDim = length(position);
			ouPosition_old{iGroup} = zeros(groupDim,nModels);
		end
		ouPosition_old{iGroup}(:,jModel) = position;
	end
	ouPosition_new{iGroup} = nOutputs + (1:groupDim);
	outputGroup = setfield(outputGroup, outputList{iGroup}, ouPosition_new{iGroup});
	nOutputs = nOutputs + groupDim;
end

% Initialize names for the complete system
inputName = cell(nInputs,1);
outputName = cell(nOutputs,1);

for iGroup = 1:nInGroups
	relatedModels = find(modelTableIn(iGroup,:));

	% Assign output names
	jModel = relatedModels(1);
	inputName(inPosition_new{iGroup}) = SSmodelArray(jModel).inputName(inPosition_old{iGroup}(:,jModel));

	% Check consistency
	for iModel = 2:length(relatedModels)
		jModel = relatedModels(iModel);

		name1 = inputName(inPosition_new{iGroup});
		name2 = SSmodelArray(jModel).inputName(inPosition_old{iGroup}(:,jModel));

		for iName = 1:length(name1)
			if isempty(name1{iName})
				consistency = isempty(name2{iName});
			else
				consistency = strcmp(name1{iName},name2{iName});
			end
			if ~consistency
				error('Input names not consistent for element %d of input group %s', iName, inputList{iGroup});
			end
		end
	end
end


for iGroup = 1:nOuGroups
	relatedModels = find(modelTableOu(iGroup,:));

	% Assign output names
	jModel = relatedModels(1);
	outputName(ouPosition_new{iGroup}) = SSmodelArray(jModel).outputName(ouPosition_old{iGroup}(:,jModel));

	% Check consistency
	for iModel = 2:length(relatedModels)
		jModel = relatedModels(iModel);

		name1 = outputName(inPosition_new{iGroup});
		name2 = SSmodelArray(jModel).outputName(ouPosition_old{iGroup}(:,jModel));

		for iName = 1:length(name1)
			if isempty(name1{iName})
				consistency = isempty(name2{iName});
			else
				consistency = strcmp(name1{iName},name2{iName});
			end
			if ~consistency
				error('Input names not consistent for element %d of output group %s', iName, outputList{iGroup});
			end
		end
	end
end


% Loop on selected models and get input/output indexes
selectedModels = find(sum(modelTableIn, 1));
nSelModels = length(selectedModels);

inPosition_source = {};
inPosition_target = {};
ouPosition_source = {};
ouPosition_target = {};

for iModel = 1:nSelModels

	inPosition_source{iModel} = [];
	inPosition_target{iModel} = [];
	ouPosition_source{iModel} = [];
	ouPosition_target{iModel} = [];

	jModel = selectedModels(iModel);

	relatedGroupsIn = find(modelTableIn(:,jModel));
	for iGroup = 1:length(relatedGroupsIn)
		inPosition_source{iModel} = [inPosition_source{iModel}, inPosition_old{relatedGroupsIn(iGroup)}(:,jModel)'];
		inPosition_target{iModel} = [inPosition_target{iModel}, inPosition_new{relatedGroupsIn(iGroup)}];
	end

	relatedGroupsOu = find(modelTableOu(:,jModel));
	for iGroup = 1:length(relatedGroupsOu)
		ouPosition_source{iModel} = [ouPosition_source{iModel}, ouPosition_old{relatedGroupsOu(iGroup)}(:,jModel)'];
		ouPosition_target{iModel} = [ouPosition_target{iModel}, ouPosition_new{relatedGroupsOu(iGroup)}];
	end

end




% Assembly system
ssmodel.method = '-';
ssmodel.mach = SSmodelArray(1).mach; % TODO check on Mach number consistency
ssmodel.inputGroup = inputGroup;
ssmodel.outputGroup = outputGroup;
ssmodel.inputName = inputName;
ssmodel.outputName = outputName;

model = [];

for iM = 1:length(ssmodel.mach)

	% Check model dimension
	na = 0;
	for iModel = 1:nSelModels
		na = na + size(SSmodelArray(selectedModels(iModel)).model(iM).A,1);
	end

	% Initialize matrices
	model(iM).A  = zeros(na,na);
	model(iM).B0 = zeros(na,nInputs);
	model(iM).B1 = zeros(na,nInputs);
	model(iM).B2 = zeros(na,nInputs);
	model(iM).C  = zeros(nOutputs, na);
	model(iM).D0 = zeros(nOutputs,nInputs);
	model(iM).D1 = zeros(nOutputs,nInputs);
	model(iM).D2 = zeros(nOutputs,nInputs);


	% Get matrices
	posa = 0;
	for iModel = 1:nSelModels
		currentModel = SSmodelArray(selectedModels(iModel)).model(iM);
		if ~isempty(posa)
			lastElem = posa(end);
		else
			lastElem = 0;
		end
		posa = lastElem + (1:size(currentModel.A,1));

		posu_source = inPosition_source{iModel};
		posu_target = inPosition_target{iModel};

		posy_source = ouPosition_source{iModel};
		posy_target = ouPosition_target{iModel};

		model(iM).A(posa,posa) = currentModel.A;

		model(iM).B0(posa,posu_target) = currentModel.B0(:,posu_source);
		model(iM).B1(posa,posu_target) = currentModel.B1(:,posu_source);
		model(iM).B2(posa,posu_target) = currentModel.B2(:,posu_source);

		model(iM).C(posy_target,posa)  = currentModel.C(posy_source, :);

		% Here there is no risk of superposition of the elements of D since there is only one model 
		% for each input
		model(iM).D0(posy_target,posu_target) = currentModel.D0(posy_source,posu_source);
		model(iM).D1(posy_target,posu_target) = currentModel.D1(posy_source,posu_source);
		model(iM).D2(posy_target,posu_target) = currentModel.D2(posy_source,posu_source);

	end
end


ssmodel.model = model;













return
