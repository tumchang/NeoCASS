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
%**************************************************************************
%  SimSAC Project
%
%  NeoCASS
%  Next generation Conceptual Aero Structural Sizing
%
%                      Sergio Ricci             <ricci@aero.polimi.it>
%                      Luca Cavagna             <cavagna@aero.polimi.it>
%                      Luca Riccobene           <riccobene@aero.polimi.it>
%                      Alessandro De Gaspari    <degaspari@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%**************************************************************************
%
% MODIFICATIONS:
%     DATE        VERS       PROGRAMMER       DESCRIPTION
%     191127      2.2.888    L. Marchetti     Creation
%
%**************************************************************************
%
%
% function [index, sortedIndices] = find_nearest_node(coord_DB, coord_Node)
%
%   DESCRIPTION: Given a set of coordinates find nearest node (in an
%                euclidean sense)
%
%         INPUT: NAME           TYPE       DESCRIPTION
%
%                coord_DB       matrix     coordinates' database
%
%                coord_Node     vector     reference coordinate vector
%
%                direction      scalar     nearest direction (1 2 3 for x y z)
%
%        OUTPUT: NAME           TYPE       DESCRIPTION
%
%                index          scalar     row index corresponding to the
%                                          point in coord_DB which is the
%                                          nearest to coord_Node
%
%                sortedIndices  vector     stores all the nodes' indices
%                                          sorted in ascending order,
%                                          index = sortedIndices(1)
%
%    REFERENCES:
%
%**************************************************************************
function [index, sortedIndices] = find_nearest_node_along_direction(coord_DB, coord_Node, direction)

% Check on input database: the format expexted is a matrix [n x 3]
ncDB = size(coord_DB, 2);

if ncDB > 3
    coord_DB = coord_DB';
end

coord_DB = coord_DB(:,direction);

% Compute the difference between coordinate database coordDB matrix, [nx3],
% and node coordinates, [1x3]

distance = abs(coord_DB - coord_Node(direction));

% Find nearest node: order nodes' distance from the nearest to the farthest
[~, sortedIndices] = sort(distance, 'ascend');

% The first element is the closest one (avoid possible duplication)
index = sortedIndices(1);