function [NForces, barNodeCoord] = getForcesOnNodes(beam_model, CForces)

Colloc = beam_model.Bar.Colloc;
NodeCoord = beam_model.Node.Coord;
Conn = beam_model.Bar.Conn;
BarR = beam_model.Bar.R;

nBar = size(Colloc,3);

nBarResults = size(CForces,3);

if nBar~=nBarResults
	if ~isempty(beam_model.Param.IFORCE)
		select = beam_model.Param.IFORCE;
		if length(select)==nBarResults
			Colloc = Colloc(select,:);
			Conn = Conn(select,:);
			BarR = BarR(:,:,:,select);
		else
			error('Number of elements in beam_model and CForces not consistent')
		end
	else
		error('Number of elements in beam_model and CForces not consistent')
	end
end




[NForces, barNodeCoord] = intForcesOnNodes(CForces, Colloc, NodeCoord, Conn, BarR);



return
