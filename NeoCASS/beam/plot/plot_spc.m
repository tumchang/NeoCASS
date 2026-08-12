%*******************************************************************************
function hPlot = plot_spc(Coord, NodeID, SPC)

nSpc = length(SPC.ID);

if nSpc == 0
	hPlot = [];
	return
end

nNodes = 0;
for iSpc = 1:nSpc
	nNodes = nNodes + length(SPC.Nodes(iSpc).list);
end

nodeList = zeros(nNodes,1);
jNode = 0;
for iSpc = 1:nSpc
	list = SPC.Nodes(iSpc).list;
	nList = length(list);
	for iList = 1:nList
		position = NodeID==list(iList);
		if all(position==false)
			error('SPC constraining a non existing node %d', list(iList))
		end

		nodeList(jNode+iList) = find(position);
	end
	jNode = jNode + nList;
end


hPlot = plot3(Coord(nodeList, 1), Coord(nodeList, 2), Coord(nodeList, 3), ...
              'k^', 'MarkerSize',  6, 'MarkerFaceColor','k');

return
%*******************************************************************************


