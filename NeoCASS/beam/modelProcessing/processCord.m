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
%     13-05-2014          Federico Fonte   Creation
%     02-11-2015          Federico Fonte   bug fixed
%     16-11-2017  0.0     Federico Fonte   Included in NeoCASS
%
%*******************************************************************************
%
%
%
%*******************************************************************************
%
function CORD = processCord(NASCORD)

if ~isempty(NASCORD(1).RID)
	n_cord = length(NASCORD);
else
	n_cord = 0;
end

CORD.ID = zeros(n_cord,1);
CORD.X0 = zeros(3,n_cord);
CORD.R  = zeros(3,3,n_cord);

CordData = zeros(n_cord,3);
for i = 1:n_cord
	CordData(i,:) = [i, NASCORD(i).CID, NASCORD(i).RID];
end

for i = 1:n_cord

	% Check wether the coordinate system is defined in the basic
	% or in an already processed system
	condition = false;
	iter = -1;
	while ~condition && iter <= n_cord
		RID = NASCORD(CordData(i,1)).RID;
		cond1 = RID == 0;
		cond2 = find(CordData(1:i-1,2)==RID);

		condition = cond1 || ~isempty(cond2);

		if ~condition
			CordData = [CordData(1:i-1,:);
			            CordData(i+1:n_cord,:);
			            CordData(i,:)];
		end

		iter = iter + 1;
	end

	if iter >= n_cord
		error('reference system not found')
	end

	pos = CordData(i,1);
	posRID = CordData((CordData(:,2)==NASCORD(pos).RID), 1);
	CORD.ID(pos) = CordData(i,2);

	switch NASCORD(pos).type
	case 'CORD2R'

		RefMat = NASCORD(pos).Mat;

		if ~cond1
			X0_RID = CORD.X0(:,posRID);
			R_RID = CORD.R(:,:,posRID);

			RefMat = [X0_RID + R_RID*(RefMat(1,:))', ...
			          X0_RID + R_RID*(RefMat(2,:))', ...
			          X0_RID + R_RID*(RefMat(3,:))'];

			RefMat = RefMat';

		end

		[CORD.R(:,:,pos), CORD.X0(:,pos)] = CORD2R2RotMat(RefMat);

	end
end

return
