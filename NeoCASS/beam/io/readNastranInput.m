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
% bm = readNastranInput(filename, fid)
%
%   Read a nastran input file and store all the unprocessed data
%
%         INPUT:                                       
%                filename :  string
%                         name of main input file
%
%                fid      :  file ID [optional, default = 1]
%                         file ID for diagnostic printing
%                                       
%        OUTPUT:
%                bm       :  struct  
%                         unprocessed model data     
%
%
%
%
%*******************************************************************************
%
function [bm, IncludeList] = ReadNastranInput(filename, fidPrint)

if nargin==1 || isempty(fidPrint)
	fidPrint = 1;
end


fprintf(fidPrint, 'Running function readNastranInput:\n\n');

n_aefact = 0;
bm.aefact.SID = [];
bm.aefact.D = [];

bm.aero.ACSID = 0;
bm.aero.V = 0;
bm.aero.c = 0;
bm.aero.rho = 0;
bm.aero.symmXZ = 0;
bm.aero.symmXY = 0;

n_caero = 0;
bm.caero.type = [];
bm.caero.EID = [];
bm.caero.PID = [];
bm.caero.CP = [];
bm.caero.N = [];
bm.caero.L = [];
bm.caero.IGID = [];
bm.caero.P = [];
bm.caero.C = [];

n_cord = 0;
bm.cord.type = [];
bm.cord.CID = [];
bm.cord.RID = [];
bm.cord.Mat = [];

n_symbol = 0;
symboldata.names = {};
symboldata.string = {};

% All included files are defined with respect to the main file
delimiter = '/'; % TODO : automatic choice of delimiter

[StartDir, pos1] = dirFromFilename(filename, delimiter);
StartFile = filename;

% Open NASTRAN input file
fid = my_openfile(filename, fidPrint);



k = 1;
Continue = true;
ReadAnotherLine = true;

n_include = 0;
n_include_processed = 0;
IncludeList = {};

while Continue

	if ReadAnotherLine
		[lineString, k] = readLine(fid, k);
	else
		ReadAnotherLine = true;
	end

	if feof(fid)
		if n_include_processed<n_include

			% Close file
			my_closefile(fid, filename, fidPrint);

			n_include_processed = n_include_processed + 1;
			filename = IncludeList{n_include_processed};

			% Open file
			fid = my_openfile(filename, fidPrint);
			k = 1;

			Continue = true;
		else
			Continue = false;
		end
	else
		Continue = true;
	end

	if ~isempty(lineString) && ischar(lineString)

		% FIXME : this is done twice for most rows, consider providing lineData
		% instead of lineString as output of readXXXX functions
		[lineData, k, longFormat] = getLine(fid, lineString, k);

		switch getFieldStr(lineData,1,'');

		case 'AEFACT'
			n_aefact = n_aefact + 1;
			[SID, List, k, lineString, ReadAnotherLine] = readAEFACT(fid, lineString, k);

			bm.aefact(n_aefact).SID = SID;
			bm.aefact(n_aefact).D = List;


		case 'AERO'
			[ACSID, V, C, RHO, symmXZ, symmXY, k] = readAERO_NAS(fid, lineString, k);
			ReadAnotherLine = true;

			bm.aero.ACSID = ACSID;
			bm.aero.V = V;
			bm.aero.c = C;
			bm.aero.rho = RHO;
			bm.aero.symmXZ = symmXZ;
			bm.aero.symmXY = symmXY;

		case 'CAERO1'
			n_caero = n_caero + 1;
			[EID, PID, CP, N, L, IGID, P1, C1, P2, C2, k, lineString, ReadAnotherLine] = readCAERO0(fid, lineString, k);

			bm.caero(n_caero).type = 'CAERO1';
			bm.caero(n_caero).EID = EID;
			bm.caero(n_caero).PID = PID;
			bm.caero(n_caero).CP = CP;
			bm.caero(n_caero).N = N;
			bm.caero(n_caero).L = L;
			bm.caero(n_caero).IGID = IGID;
			bm.caero(n_caero).P = [P1, P2];
			bm.caero(n_caero).C = [C1, C2];


		case 'CORD2R'
			n_cord = n_cord + 1;
			[CID, RID, NasCord2rMat, k] = readCORD2R(fid, lineString, k);

			bm.cord(n_cord).type = 'CORD2R';
			bm.cord(n_cord).CID = CID;
			bm.cord(n_cord).RID = RID;
			bm.cord(n_cord).Mat = NasCord2rMat;

		case 'INCLUDE'
			n_include = n_include + 1;
			name_file_inc = strtok(lineString(8:end));
			name_file_inc = name_file_inc(2:end-1);

			% Look for the included file in the directory containing the files with the INCLUDE
			% statement
			activeDir = dirFromFilename(filename, delimiter);

			[name_file_inc, lineString, k] = readINCLUDE_NAS(fid, lineString, k, activeDir, symboldata);

			IncludeList{n_include} = name_file_inc;


		case '$#SYMBOL'
			n_symbol = n_symbol + 1;
			eqpos = find(lineString=='=');
			symboldata.names{n_symbol} = lineString(eqpos(1)+1:eqpos(2)-1);
			symboldata.string{n_symbol} = deblank(lineString(eqpos(2)+1:end));

		end
	end

end


% Close file
my_closefile(fid,filename, fidPrint);


fprintf(fidPrint, 'End of function readNastranInput\n');
return
%*******************************************************************************



%*******************************************************************************
function fid = my_openfile(filename, fidPrint)

fid = fopen(filename, 'r');

fprintf(fidPrint, '\tReading from file:   %s  ...  ', filename);

return
%*******************************************************************************


%*******************************************************************************
function [] = my_closefile(fid, filename, fidPrint)

% Close file
status = fclose(fid);

if status == 0
	fprintf(fidPrint, '\tclosed\n');
elseif status == -1
	fprintf(fidPrint, '\n\t### WARNING file:   %s   not closed\n', filename);
end

return
%*******************************************************************************


%*******************************************************************************
function [dirName, pos] = dirFromFilename(filename, delimiter);

dirName = find(filename==delimiter);

if ~isempty(dirName)
	dirName = filename(1:dirName(end));
	pos = length(dirName);
else
	dirName = './';
	pos = 0;
end

return
%*******************************************************************************

