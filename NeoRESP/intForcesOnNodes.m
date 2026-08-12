function [NForces, barNodeCoord] = intForcesOnNodes(CForces, Colloc, NodeCoord, Conn, BarR);
%
%
%
%-------------------------------------------------------------------------------
% 16-02-2017
%

nBar = size(CForces,3);

if size(Colloc,3)~= nBar
	error('CForces and Colloc do not have consistent dimensions\n');
end

if size(Conn,1)~= nBar
	error('CForces and Conn do not have consistent dimensions');
end

nSet = size(CForces,4);

NForces = zeros(2,6,nBar,nSet);

barNodeCoord = zeros(2,3,nBar);

% Express the loads in the beam extrema
for iBar = 1:nBar

	node1 = NodeCoord(Conn(iBar,1),:);
	colloc1 = Colloc(1,:,iBar);

	dist1 = BarR(:,:,1,iBar)'*(colloc1 - node1)';

	node2 = NodeCoord(Conn(iBar,3),:);
	colloc2 = Colloc(2,:,iBar);

	dist2 = BarR(:,:,5,iBar)'*(colloc2 - node2)';

	barNodeCoord(1,:,iBar) = node1;
	barNodeCoord(2,:,iBar) = node2;

	for iSet = 1:nSet
		NForces(1,1:3,iBar,iSet) = CForces(1,1:3,iBar,iSet);
		NForces(1,4:6,iBar,iSet) = CForces(1,4:6,iBar,iSet) + (crossm(dist1)*CForces(1,1:3,iBar,iSet)')';

		NForces(2,1:3,iBar,iSet) = CForces(2,1:3,iBar,iSet);
		NForces(2,4:6,iBar,iSet) = CForces(2,4:6,iBar,iSet) + (crossm(dist2)*CForces(2,1:3,iBar,iSet)')';

	end
end

















return
