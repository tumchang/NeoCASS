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
%   Author: Nicola Fonzi, DAER
%***********************************************************************************************************************

function [deltaFov, deltaFophi, Fvo, Fphio] = AddChordwiseContribution(deltaFov, deltaFophi, Fvo, Fphio,...
    LKChord, ROTChord, subdivision, gammav, gammaphi, gamma0, VINDu, VINDPhi, VINF, VIND0, ik, in, dlm_model, V ,nt)

counter = 0;
for n = 1:size(subdivision,1)
    np = subdivision(n,1)*subdivision(n,2);
    for spanpos = 1:subdivision(n,2)
        for chordpos = 1:subdivision(n,1)
            gammav_chord(counter + chordpos + subdivision(n,1)*(spanpos-1))...
                = sum(gammav(counter + 1 + subdivision(n,1)*(spanpos-1):...
                counter + chordpos + subdivision(n,1)*(spanpos-1))); % Sum of all the upstream
            gammaphi_chord(counter + chordpos + subdivision(n,1)*(spanpos-1))...
                = sum(gammaphi(counter + 1 + subdivision(n,1)*(spanpos-1):...
                counter + chordpos + subdivision(n,1)*(spanpos-1))); % Sum of all the upstream
            gamma0_chord(counter + chordpos + subdivision(n,1)*(spanpos-1))...
                = sum(gamma0(counter + 1 + subdivision(n,1)*(spanpos-1):...
                counter + chordpos + subdivision(n,1)*(spanpos-1))); % Sum of all the upstream
        end
    end
    counter = counter + np;
end

gammav_chord = gammav_chord(:);
gamma0_chord = gamma0_chord(:);
gammaphi_chord = gammaphi_chord(:);

for segments = 1:2
    deltaFov = deltaFov + cross(VINF-VIND0,squeeze(LKChord(:,segments,:))).*repmat(gammav_chord,1,3);
    deltaFophi = deltaFophi + cross(VINF-VIND0,squeeze(LKChord(:,segments,:))).*repmat(gammaphi_chord,1,3);
    Fvo = Fvo + cross(-VINDu - 1i*dlm_model.aero.k(ik)/dlm_model.aero.cref*V*dlm_model.data(nt).d_displ(:,:,in),...
        squeeze(LKChord(:,segments,:)).*repmat(gamma0_chord,1,3));
    for index = 1:size(VINDu,1)
        temp2(index,:,segments) = (squeeze(ROTChord(index,:,:,segments,in))*squeeze(LKChord(index,segments,:)));
    end
    Fphio = Fphio + (cross(-VINDPhi,squeeze(LKChord(:,segments,:))) + cross(VINF-VIND0,squeeze(temp2(:,:,segments)))).*repmat(gamma0_chord,1,3);
end