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
%                  1.0       L. Cavagna       Creation
%
%**************************************************************************
%
%
% function   mass_distr = massCONC_opt(nodes, domain, mass, CG, X0)
%
%   DESCRIPTION: Run optimization problem to distribute fuselage
%                concentrated masses preserving total mass and cg 
%
%         INPUT: NAME           TYPE       DESCRIPTION
%
%
%        OUTPUT: NAME           TYPE       DESCRIPTION
%
%
%
%    REFERENCES:
%
%**************************************************************************
function mass_distr = massCONC_opt(nodes, domain, mass, CG, X0)

% Init vector
mass_distr = zeros(1, length(X0));

if mass > 0
    
    % Find nodes inside domain
    indx = find( nodes >= domain(1) & nodes <= domain(2) );
    if isempty(indx)
        indx1 = find( nodes >= domain(1),1);
        indx2 = find( nodes <= domain(2));
        indx = sort([indx1 indx2(end)]);
    end
    
    % Compute non structural mass as initial value linear density [kg/m]
    cg_prev = sum(X0.*nodes)/mass;
    
    % Optimization
    mass_distr(1, indx) = opt_cg_pos(X0(indx), nodes(indx), mass, CG);
    cg = sum(mass_distr(indx).* nodes(indx))/sum(mass_distr(indx));
    
    fprintf('\n\t - Optimization problem for fuselage lumped mass:');
    fprintf('\n\t\t- CG required: %g [m].', CG);
    fprintf('\n\t\t- CG trial solution: %g [m].', cg_prev);
    fprintf('\n\t\t- CG determined: %g [m].', cg);
    fprintf('\n\t\t- Mass required: %g [Kg].', mass);
    fprintf('\n\t\t- Mass determined: %g [Kg].', sum(mass_distr(indx)));
    
end

%==========================================================================
% Auxiliary functions
%
function mass_distr = opt_cg_pos(X0, nodes, MTOT, CG)
%
nm = length(X0);

OPTIONS = optimset('Algorithm', 'sqp', 'Display', 'notify-detailed');%,'GradObj', 'on','Display', 'notify-detailed','MaxFunEvals',500000, 'LargeScale', 'off', 'tolfun',1e-9);

[mass_distr, ~, flag] = fmincon(@(x) myobj(x, nodes, CG, MTOT),X0, [],[],ones(1,nm),MTOT,zeros(nm,1),ones(nm,1)*100000,[],OPTIONS);

if flag < 0
    fprintf('\n### Warning: optimization process failes for mass distribution.');
    mass_distr = X0;
end

function f = myobj(x, nodes, CG, MTOT)
%

f = abs(sum(x.*nodes) - MTOT*CG)/MTOT*CG;


