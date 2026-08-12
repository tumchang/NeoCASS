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
function [ACSID, V, C, RHO, symmXZ, symmXY, k] = ReadAERO(fid, lineString, k)

[lineData, k, longFormat] = getLine(fid, lineString, k);

ACSID  = getFieldNum(lineData,2, 0);
V      = getFieldNum(lineData,3, 0);
C      = getFieldNum(lineData,4, 0);
RHO    = getFieldNum(lineData,5, 0);
symmXZ = getFieldNum(lineData,6, 0);
symmXY = getFieldNum(lineData,7, 0);


return
