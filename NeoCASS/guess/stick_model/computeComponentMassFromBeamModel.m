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
%**************************************************************************
%  SimSAC Project
%
%  NeoCASS
%  Next generation Conceptual Aero Structural Sizing  
%
%                      Sergio Ricci             <ricci@aero.polimi.it>
%                      Luca Cavagna             <cavagna@aero.polimi.it>
%                      Alessandro De Gaspari    <degaspari@aero.polimi.it>
%                      Luca Riccobene           <riccobene@aero.polimi.it>
%
%  Department of Aerospace Engineering - Politecnico di Milano (DIAPM)
%  Warning: This code is released only to be used by SimSAC partners.
%  Any usage without an explicit authorization may be persecuted.
%
%**************************************************************************
%
% Compute paint non-structural mass using wetted surface fraction with
% respect total wetted surface. Do a similar procedure for fuel using
% internal volume fractions.
%
% function [M, ms, mns, mcon] = computeComponentMassFromBeamModel(beam_model)
%
%
%   DESCRIPTION:  Compute aircraft components' mass starting from
%                 beam_model
%
% Input:
%
%
%         INPUT: NAME           TYPE       DESCRIPTION
%             
%                beam_model     struct     beam model read from an ASCII
%                                          file *.inc or *.dat in NeoCASS
%                                          format
%                                       
%        OUTPUT: NAME           TYPE       DESCRIPTION
%                
%                M              vector     [nComponent x 1] each element is
%                                          the sum of structural, non
%                                          structural (linear density) and
%                                          concentrated mass, related to
%                                          the component, i.e. fuselage [kg] 
%
%                ms             vector     [nComponent x 1] structural mass
%                                          (rho*A*L) [kg]
%
%                mns            vector     [nComponent x 1] non-structural
%                                          mass (rho_NS*L) [kg]
%
%                mcon           vector     [nComponent x 1] sum of the
%                                          concentrated masses attached to
%                                          the component, i.e. engines
%                                          under wing -> wing [kg]
%
% Order of the output vector:
%
% ---------------------------
% | Component   |   ID range |
% ---------------------------
% | Fuselage    |  1000:1999 |
% | Wing        |  2000:2999 |
% | VT          |  3000:3999 |
% | HT          |  4000:4999 |
% | Canard      |  5000:5999 |
% | Tail booms  |  7000:7999 |
% ---------------------------
%
% ! REMARK:
% Each non structural mass that is connected to a specific component
% shares the node IDs convention: i.e. if the engine is connected to the
% wing, the node to which the CONM2 is attached to will have an ID that
% ranges from 2000 to 2999. Thus, these masses will be add to the related
% component.
%
% MODIFICATIONS:
%
%     DATE        VERS      PROGRAMMER       DESCRIPTION
%     171023      2.2.793   L. Riccobene     Creation
%
%**************************************************************************
function [M, ms, mns, mcon] = computeComponentMassFromBeamModel(beam_model)

% Each aircraft component can be identified within beam model, using
% dedicated IDs
%       Fuselage   |  Wing   |   VT    |    HT    |  Canard    |  Tbooms   
AllID = [1000:1999; 2000:2999; 3000:3999; 4000:4999; 5000:5999; 7000:7999];

% Init M vector
nComponent = size(AllID, 1);
M    = zeros(nComponent, 1);
ms   = zeros(nComponent, 1);
mns  = zeros(nComponent, 1);
mcon = zeros(nComponent, 1);

% Compute structural and non-structural (distributed) masses for the beam
PBAR = beam_model.PBar;
CBAR = beam_model.Bar;
MAT  = beam_model.Mat;
NODE = beam_model.Node;
CONM = beam_model.ConM;

for l = 1:nComponent
    
    ID = AllID(l, :);
       
    % Recover beam element lengths [m] and areas [m2], in order to compute
    % m = rho*A*L
    
    % Recover CBAR<->PBAR link
    barPIDLineIndex = CBAR.PID;
    
    % Sample densities and areas expanding on beam element number (which
    % can be different from bar property number)
    
    % Structural densities [kg/m3]
    rhoS = MAT.Rho(PBAR.Mat(barPIDLineIndex));
    
    % Non structural densities [kg/m]
    rhoNS = PBAR.RhoNS(barPIDLineIndex);
    
    % Section area [m2]
    A = PBAR.A(barPIDLineIndex);
    
    % Sample from CBAR database
    indx2 = ismember(PBAR.ID(barPIDLineIndex), PBAR.ID( ismember(PBAR.ID, ID) ));
    
    % Recover connections and thus beam end nodes
    cbarConn  = CBAR.Conn(indx2, [1 3]);
    ncbarConn = size(cbarConn, 1);
    beamLen   = zeros(1, ncbarConn);
    
    for k = 1:ncbarConn
        endNodes   = NODE.Coord(cbarConn(k, :), :);
        beamLen(k) = norm( diff(endNodes) );
    end
    
    % Compute mass (structural and non-structural, but distributed as a
    % linear density)
    ms(l)  = sum(rhoS(indx2).*A(indx2).*beamLen);
    mns(l) = sum(rhoNS(indx2).*beamLen);
    
    % Compute non structural mass applied as CONM2
    nid = ismember(NODE.ID(CONM.Node), ID);
    tmp = sum(CONM.M(:, :, nid), 3);
    mcon(l) = tmp(1,1); 
    
    % Total mass
    M(l) = ms(l) + mns(l) + mcon(l);
    
end