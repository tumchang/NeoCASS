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
%**************************************************************************
% 
% Given the CG lumped mass coordinates (Xcg,Ycg,Zcg), function calculates
% the closest grid point ID number (IDclc) and offset vector from grid
% point to lumped mass (X1offset,X2offset,X3offset).
% 
% 
% Inputs:   Xcg, Ycg, Zcg, CG coordinates for lumped mass
% 
% Outputs:  IDclc, the closest grid point ID
%           X1offset, X2offset, X3offset, offset vector from grid point to
%                                         lumped mass
% 
% Called by:    Add_NSM_conc.m
% 
% Calls:        find_nearest_node
% 
% MODIFICATIONS:
%     DATE        VERS      PROGRAMMER       DESCRIPTION
%     080508      1.0       A. Da Ronch      Creation
%     171020      2.2.793   L. Riccobene     Modification
%
%**************************************************************************
function [IDclc, X1offset, X2offset, X3offset] = CONM2_setup(Xcg, Ycg, Zcg, ALLnds, ALLIDs)

% Search for the nearest node
imin = find_nearest_node(ALLnds, [Xcg Ycg Zcg]);

% Return node ID
IDclc = ALLIDs(imin);

% Offset vector from the closest grid point to the given CG coordinates
X1offset = Xcg - ALLnds(1, imin);
X2offset = Ycg - ALLnds(2, imin);
X3offset = Zcg - ALLnds(3, imin);
