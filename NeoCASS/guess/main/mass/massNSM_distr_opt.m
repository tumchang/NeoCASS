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
% function   rho_nsm = massNSM_distr_opt(nodes, domain, mass, CG, dq, qtot, l_beam)
%
%   DESCRIPTION: Run optimization problem to distribute fuselage non
%                structural distributed masses (i.e. linear densities)
%                preserving total mass and cg 
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
function rho_nsm = massNSM_distr_opt(nodes, domain, mass, CG, dq, qtot, l_beam)

% Set tolerance
TOLL = 1e-3;

% Init vectors
rho_nsm = zeros(length(l_beam), 1);
mass_fraction = rho_nsm;

if mass > 0
    
    % Find nodes inside domain (discard last point)
    indx = find( nodes >= domain(1) & nodes <= domain(2) );
    
    % Compute total over domain (q can be either a wetted area or a volume)
    qt = sum(dq(indx));
    
    % Compute mass fractions as initial value for the optimization problem
    mass_fraction(indx, 1) = mass.*(dq(indx)./qt);
    cg_prev = sum(mass_fraction(indx, 1).* nodes(indx))/mass;
    
    % Optimization
    mass_fraction(indx, 1) = opt_cg_pos(mass_fraction(indx, 1), nodes(indx), mass, CG);
    cg = sum(mass_fraction(indx, 1).* nodes(indx))/sum(mass_fraction(indx, 1));
    
    % Output to video
    fprintf('\n\t - Optimization problem for fuselage distributed mass:');
    fprintf('\n\t\t- CG required: %g [m].', CG);
    fprintf('\n\t\t- CG trial solution: %g [m].', cg_prev);
    fprintf('\n\t\t- CG determined: %g [m].', cg);
    fprintf('\n\t\t- Mass required: %g [Kg].', mass);
    fprintf('\n\t\t- Mass determined: %g [Kg].', sum(mass_fraction(indx, 1)));
    
    if abs(cg - cg_prev)/cg_prev > TOLL
        
        mass_fraction(indx, 1) = opt_cg_pos(ones(length(indx), 1)/length(indx), nodes(indx), mass, CG);
        cg = sum(mass_fraction(indx, 1).* nodes(indx))/sum(mass_fraction(indx, 1));
        
        fprintf('\n\t\t  Solution discarded.');
        fprintf('\n\t\t- Optimization problem for fuselage distributed mass:');
        fprintf('\n\t\t\t- CG required: %g [m].', CG);
        fprintf('\n\t\t\t- CG trial solution: %g [m].', cg_prev);
        fprintf('\n\t\t\t- CG determined: %g [m].', cg);
        fprintf('\n\t\t\t- Mass required: %g [Kg].', mass);
        fprintf('\n\t\t\t- Mass determined: %g [Kg].', sum(mass_fraction(indx, 1)));
    end
    
    % Divide mass fraction by beam element length, in order to obtain a
    % linear density for the non-structural mass [kg/m]
    rho_nsm(indx, 1) = mass_fraction(indx, 1)./l_beam(indx);
    
end

function mass_distr = opt_cg_pos(X0, nodes, MTOT, CG)
%

nm = length(X0);
OPTIONS = optimset('Algorithm', 'sqp', 'Display', 'notify-detailed', 'tolfun',1e-9);

[mass_distr, ~, flag] = fmincon(@(x) myobj(x, nodes, CG, MTOT),X0, [],[],ones(1,nm),MTOT,zeros(nm,1),ones(nm,1)*100000,[],OPTIONS);

if flag < 0
    fprintf('\n### Warning: optimization process for mass distribution failed.');
    mass_distr = X0;
end

function f = myobj(x, nodes, CG, MTOT)
%
f = abs(sum(x.*nodes) - MTOT*CG)/MTOT*CG;


