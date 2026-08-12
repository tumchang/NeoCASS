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
function [EID, PID, CP, N, L, IGID, ...
          P1, C1, P2, C2, ...
          k, lineString, ReadAnotherLine] = ReadCAERO0(fid, lineString, k)

[lineData, k, longFormat] = getLine(fid, lineString, k);

EID = getFieldNum(lineData,2, 0);
PID = getFieldNum(lineData,3, 0);
CP  = getFieldNum(lineData,4, 0);

N = zeros(2,1);
L = zeros(2,1);

N(1) = getFieldNum(lineData,5, 0);
L(1) = getFieldNum(lineData,7, 0);
N(2) = getFieldNum(lineData,6, 0);
L(2) = getFieldNum(lineData,8, 0);

IGID = getFieldNum(lineData,9, 0);


P1 = zeros(3,1);
P2 = zeros(3,1);

% Try to read second line
[isContinuationEntry, k, lineString] = getContinuationEntry(fid, k);

if ~isContinuationEntry
	error('Error in reading %s with id %d: continuation entry missing', getFieldStr(lineData, 1, '???'), EID);
end

[lineData, k, longFormat] = getLine(fid, lineString, k);
ReadAnotherLine = true;

P1(1) = getFieldNum(lineData,2, 0);
P1(2) = getFieldNum(lineData,3, 0);
P1(3) = getFieldNum(lineData,4, 0);

C1 = getFieldNum(lineData,5, 0);

P2(1) = getFieldNum(lineData,6, 0);
P2(2) = getFieldNum(lineData,7, 0);
P2(3) = getFieldNum(lineData,8, 0);

C2 = getFieldNum(lineData,9, 0);






return
%*******************************************************************************
