function hSurf = plotAeroBody(bodyElem, meshScale)


nBody = length(bodyElem.Node);

hSurf = zeros(nBody, 1);

for iBody = 1:nBody
	np = size(bodyElem.Conn{iBody},1);
	coordsX = bodyElem.Node{iBody}(:,1)*meshScale;
	coordsY = bodyElem.Node{iBody}(:,2)*meshScale;
	coordsZ = bodyElem.Node{iBody}(:,3)*meshScale;
	connectivity = bodyElem.Conn{iBody};

	hSurf(iBody) = trisurf(connectivity, coordsX, coordsY, coordsZ);
	axis equal;
	grid on
	set(hSurf, 'faceColor', 'b');
	set(hSurf, 'edgeColor', 'r');
	set(hSurf, 'faceAlpha', 0.5);
end


return
