%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2008 - 2017
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
%
%  SMARTCAD
%  Simplified Models for Aeroelasticity in Conceptual Aircraft Design  
%
%                      Sergio Ricci         <ricci@aero.polimi.it>
%                      Luca Cavagna         <cavagna@aero.polimi.it>
%                      Alessandro Degaspari <degaspari@aero.polimi.it>
%                      Luca Riccobene       <riccobene@aero.polimi.it>
%                      Federico Fonte       <federico.fonte@polimi.it>
%                      Francesco Toffol     <francesco.toffol@polimi.it>
%
%***********************************************************************************************************************
%
%
% MODIFICATIONS:
%     DATE        VERS    PROGRAMMER       DESCRIPTION
%     16-06-2014  0.0     Federico Fonte   Creation
%     16-11-2017  0.1     Federico Fonte   Included in NeoCASS
%
%*******************************************************************************
%
% caero = processCaero(NAScaero, CORD, aero, NASaefact)
%
% Create caero struct:
%
% caero.EID : [n_caero]
% caero.P   : [4 x 3 x n_caero]
% caero.I   : [n_caero x 4]
% caero.Lc  : [nc_tot]
% caero.Ls  : [ns_tot]
%
%
% index array I:
% I(j,:) refers to panel j,
%    (I(j,1) == -1) ==> panel j has a regular division in chord, it 
%                       has (I(j,2)-1) panels in chord.
%    (I(j,1) >= 0)  ==> the chordwise division of panel j is described
%                       by elements (I(j,1) + (1:I(j,2)) of vector 
%                       caero.Lc. There are (I(j,2)-1) panels.
%
%    (I(j,2) == -1) ==> panel j has a regular division in span, it 
%                       has (I(j,4)-1) panels in span.
%    (I(j,2) >= 0)  ==> the spanwise division of panel j is described
%                       by elements (I(j,2) + (1:I(j,4)) of vector 
%                       caero.Ls. There are (I(j,4)-1) panels.
%
%
%
%
%*******************************************************************************
%
function caero = ProcessCaero(NAScaero, CORD, aero, NASaefact)
%




if ~isempty(NAScaero(1).EID)
	n_caero = length(NAScaero);
else
	n_caero = 0;
end

% Aerodynamic reference system
if aero.ACSID ~= 0
	posCD = find(CORD.ID==aero.ACSID);
	R_a = CORD.R(:,:,posCD);
else
	R_a = eye(3,3);
end

caero.EID = zeros(n_caero,1);
caero.P = zeros(4,3,n_caero);
Lc_tot = zeros(30*n_caero,1); % Overallocated
Ls_tot = zeros(30*n_caero,1); % Overallocated
caero.I = zeros(n_caero,4);

pos_c = 0;
pos_s = 0;
for i = 1:n_caero

	% Get points 1 and 4
	X14 = NAScaero(i).P;

	CP = NAScaero(i).CP;
	if CP ~= 0
		posCD = find(CORD.ID==NAScaero(i).CP);
		X14 = CORD.X0(:,posCD)*[1,1] + CORD.R(:,:,posCD)*X14;
	end

	% Get points 2 and 3
	DX = zeros(3,2);
	DX(1,:) = NAScaero(i).C;
	DX = R_a*DX;

	X23 = X14 + DX;


	% Get spanwise division
	if NAScaero(i).L(1) == 0
		ns = NAScaero(i).N(1) + 1;
		Ls = 0:(1/NAScaero(i).N(1)):1;
		I_pos_s = -1;
	else
		Ls = GetAEFACT(NASaefact, NAScaero(i).L(1));
		ns = length(Ls);
		Ls_tot(pos_s + (1:ns)) = Ls;
		I_pos_s = pos_s;
		pos_s = pos_s + ns;
	end

	% Get chordwise division
	if NAScaero(i).L(2) == 0
		nc = NAScaero(i).N(2) + 1;
		Lc = 0:(1/NAScaero(i).N(2)):1;
		I_pos_c = -1;
	else
		Lc = GetAEFACT(NASaefact, NAScaero(i).L(2));
		nc = length(Lc);
		Lc_tot(pos_c + (1:nc)) = Lc;
		I_pos_c = pos_c;
		pos_c = pos_c + nc;
	end

	caero.EID(i) = NAScaero(i).EID;

	caero.P(:,:,i) = [X14(:,1)';
	                  X23(:,1)';
	                  X23(:,2)';
	                  X14(:,2)'];


	caero.I(i,:) = [I_pos_c, nc, I_pos_s, ns];


end

caero.Lc = Lc_tot(1:pos_c);
caero.Ls = Ls_tot(1:pos_s);

[sorted, isort] = sort(caero.EID);
caero.EID = caero.EID(isort);
caero.P = caero.P(:,:,isort);
caero.I = caero.I(isort,:);

return
