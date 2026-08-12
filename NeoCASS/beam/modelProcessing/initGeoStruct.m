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
%     16-11-2017  0.0     Federico Fonte   Creation
%
%*******************************************************************************
%
%
%
%*******************************************************************************
%
function geo = initGeoStruct(nCaero, nFlapped)

if nargin==0
	nCaero = 0;
end

if nargin < 2
	nFlapped = 0;
end

% Define GEO struct
geo.nx = zeros(nCaero,1);
geo.ny = zeros(nCaero,1);

geo.startx = zeros(1,nCaero);
geo.starty = zeros(1,nCaero);
geo.startz = zeros(1,nCaero);

geo.c = zeros(nCaero,1);
geo.foil = cell(nCaero,1,2);

geo.b  = zeros(nCaero,1);
geo.T  = zeros(nCaero,1);
geo.SW = zeros(nCaero,1);
geo.TW = zeros(nCaero,1,2);

geo.dihed = zeros(nCaero,1);
geo.meshtype = zeros(nCaero,3);

geo.nwing = nCaero;
geo.nelem = ones(1,nCaero);
geo.fsym = zeros(nCaero,1);

geo.symetric = zeros(1,nCaero);

geo.aefact.ID = [];
geo.aefact.data = {};

geo.nc = nFlapped;
geo.controlName = cell(1,nFlapped);

geo.flapped = zeros(nCaero,1);
geo.fc      = zeros(nCaero,1,2);
geo.fnx     = zeros(nCaero,1);


geo.flap_vector = zeros(nFlapped,1);

geo.aesurfData.index = zeros(0,1);
geo.aesurfData.hinge = zeros(0,2,3);

return
