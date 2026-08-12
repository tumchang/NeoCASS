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
% function importNastranCAERO(nastranInput, outputFile)
%
%   Read a nastran input file and convert all the CAERO1 entries in NeoCASS
%   format.
%
%
%         INPUT:                                       
%                nastranInput :  string
%                             name of main nastran input file.
%
%                outputFile   :  string 
%                             name of the generated file containing the CAERO1 
%                             entries in NeoCASS format
%                                
%                                       
%        OUTPUT:
%
%
%
%*******************************************************************************
%
function [geo, nasmod, bm] = importNastranCAERO(nastranInput, outputFile)

if nargin < 2
	outputFile = [];
end

if isempty(outputFile)
	writeToFile = false;
else
	fid = fopen(outputFile, 'w');
	writeToFile = true;
end

% Get input data
bm = readNastranInput(nastranInput);

% Process nastran data
nasmod = processNastranInput(bm);

% Check aero reference system: for NeoCASS it must be the basic system
if nasmod.aero.ACSID~=0
	error('NeCASS supports only aerodynamic models defined in the basic reference system');
end

% Transform CAERO cards in NeoCASS convention
nCaero = length(nasmod.caero.EID);

% Define GEO struct
geo = initGeoStruct(nCaero);

% All cards defined in the basic reference by default
CID = 0;

FOIL1 = '0012';
FOIL2 = '0012';
TW1 = 0;
TW2 = 0;

for iCaero = 1:nCaero

	EID = nasmod.caero.EID(iCaero);

	positionInBM = find([bm.caero.EID]==EID);

	P = nasmod.caero.P(:,:,iCaero);

	c1 = sqrt(sum( (P(1,:) - P(2,:)).^2 ));
	c2 = sqrt(sum( (P(4,:) - P(3,:)).^2 ));

	[DIH, SPN, CHD, CX, CY, CZ, TPR, SWP] = CAERO_nas2neo(P(1,:), P(4,:), c1, c2);

	% Panel division
	if nasmod.caero.I(iCaero,3) == -1
		NY = nasmod.caero.I(iCaero,4)-1;
		TYPE_SPAN = 0;
	else
		% AEFACT used, instead of using the Ls array use directly the raw
		% Nastran data
		aefactID = bm.caero(positionInBM).L(1);
		TYPE_SPAN = -aefactID;
		NY = 0;
	end

	if nasmod.caero.I(iCaero,1) == -1
		NX = nasmod.caero.I(iCaero,2)-1;
		TYPE_CHORD = 0;
	else
		% AEFACT used, instead of using the Lc array use directly the raw
		% Nastran data
		aefactID = bm.caero(positionInBM).L(2);
		TYPE_CHORD = -aefactID;
		NX = 0;
	end

	if writeToFile
		writeCAERO(fid, EID, DIH, CID, NY, NX, ...
                     TYPE_SPAN, TYPE_CHORD, CX, CY, CZ, CHD, ...
                     SPN, TPR, SWP, FOIL1, FOIL2, TW1, TW2);
	end

	% Save in geo
	geo.nx(iCaero) = NX;
	geo.ny(iCaero) = NY;

	geo.startx(iCaero) = CX;
	geo.starty(iCaero) = CY;
	geo.startz(iCaero) = CZ;

	geo.c(iCaero) = CHD;
	geo.foil{iCaero,1,1} = FOIL1;
	geo.foil{iCaero,1,2} = FOIL2;

	geo.b(iCaero)    = SPN;
	geo.T(iCaero)    = TPR;
	geo.SW(iCaero)   = SWP*pi/180;
	geo.TW(iCaero,1,:) = [TW1,TW2]*pi/180;

	geo.dihed(iCaero) = DIH*pi/180;
	geo.meshtype(iCaero,:) = [TYPE_SPAN, TYPE_CHORD, 0];


end

% Process AEFACT
nAefact = length(bm.aefact.SID);

geo.aefact.ID = bm.aefact.SID;
geo.aefact.data = bm.aefact.D;

if writeToFile
	for iAefact = 1:nAefact
		writeGenericSet(fid, 'AEFACT', geo.aefact.ID(iAefact), geo.aefact.data{iAefact});
	end
end


if writeToFile
	fclose(fid);
end

return
