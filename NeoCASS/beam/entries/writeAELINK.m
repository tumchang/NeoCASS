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
%
% 01-08-2016
%**************************************************************************
function [] = writeAELINK(fid, ID, LABLD, LABL, C)

void = '        ';

if isstr(LABL)
    LABL = {LABL};
end

nMaster = length(LABL);
if length(C) ~= nMaster
    error('The number of elements in C and in LABL must be the same');
end

%             1 2 3
fprintf(fid, '%s%s%s', str2char8('AELINK', 'l'), int2char8(ID), str2char8(LABLD));

lastPositionInLine = 9;
positionInLine = 3;

for iMaster = 1:nMaster
    
    fprintf(fid, '%s%s', str2char8(LABL{iMaster}), dbl2char8(C(iMaster)));
    
    positionInLine = positionInLine + 2;
    
    if positionInLine == lastPositionInLine && iMaster < nMaster
        fprintf(fid, '\n');
        fprintf(fid, '%s', void);
        positionInLine = 1;
    end
    
end

fprintf(fid,'\n');
