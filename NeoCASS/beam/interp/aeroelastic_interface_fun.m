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
%***********************************************************************************************************************
%  SimSAC Project
%
%  SMARTCAD
%  Simplified Models for Aeroelasticity in Conceptual Aircraft Design  
%
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Alessandro Degaspari <degaspari@aero.polimi.it>
%                      Luca Riccobene       <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%***********************************************************************************************************************
%	
%   Author: Luca Cavagna, Pierangelo Masarati, DIAPM
%
%   Modifications
%   15-09-2016 Federico Fonte
%
%
%***********************************************************************************************************************
function [Interp, InterpBody] = aeroelastic_interface_fun(fid, Param, Info, Node, Aero, lattice);


fid = Param.FID;
SPLINE_TYPE = Info.spline_type;

switch (Param.SOL)

case {144,644,150}

	fprintf(fid, '\n- Building aero-structural interpolation matrices...');
	if Info.ninterp == 0
		error('No interpolation set for aeroelastic interface given.');
	end
	fprintf(fid, '\n\t - Method: %d.', SPLINE_TYPE);

	% VLM interface
	switch(SPLINE_TYPE)
	case {1}
		[Interp.Ic, Interp.In, Interp.Iv, Interp.Imv] = interf_vlm_model1_ext(fid, Info.ncaero, ...
		                                                                      Node, Aero, lattice);
	case {2,3}
		[Interp.Ic, Interp.In, Interp.Iv, Interp.Imv] = interf_vlm_model(fid, Info.ncaero, ...
		                                                                 Node, Aero);
	end

	% BODY interface
	InterpBody.Ic = interf_body_model1(1, Node, Aero);

	fprintf(fid, '\n  done.\n');
otherwise
	fprintf(fid, '\n\tAeroelastic interface required only for static solutions 144,644,150.\n');
end

return
