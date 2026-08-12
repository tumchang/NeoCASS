function [rigidDOF, nRigid, rigidDofUsed] = rigidDofTable(SUPORT)
%
% 18-11-2016 Federico Fonte
%


rigidDOF = zeros(6,3);

% Apply default choice: the component used in the SUPORT entry is the component of rigid
% displacement
for iNode = 1:size(SUPORT, 1);
	idTag = num2str(SUPORT(iNode,2));
	for iComp = 1:length(idTag)
		component = str2num(idTag(iComp));
		position = component;
		if rigidDOF(position,1) > 0
			error('Redundant definition of SUPORT DOFs');
		end
		rigidDOF(position,1) = SUPORT(iNode);
		rigidDOF(position,2) = component;
		rigidDOF(position,3) = 0;
	end
end

rigidDofUsed = rigidDOF(:,2)>0;
nRigid = sum(rigidDofUsed);

return
