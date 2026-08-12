function writeCAERO(fid, AID, DIH, CID, NY, NX, ...
                     TYPE_SPAN, TYPE_CHORD, CX, CY, CZ, CHD, ...
                     SPN, TPR, SWP, FOIL1, FOIL2, TW1, TW2, ...
                     FC1, FC2, FNX, FNAME, TYPE_FLAP)
%
% v1.1 20-05-2017 Adapted to new definition of mesh type
%
%

% Keep backward compatibility
if nargin==14
	fprintf('Warning: using old format for writing CAERO %d\n', AID);
	% FBL: in this cases the names are messed up
	writeCAERO_v10(fid, AID, DIH, CID, NY, NX, TYPE_SPAN, TYPE_CHORD, CX, CY, CZ, CHD, SPN, TPR);
	return
end

flapped = (nargin>20);

if isempty(NY) || NY==0 || ~isstr(TYPE_SPAN)
	TYPE_SPAN = int2char8(TYPE_SPAN);
else
	TYPE_SPAN = str2char8(TYPE_SPAN);
end

if isempty(NX) || NX==0 || ~isstr(TYPE_CHORD)
	TYPE_CHORD = int2char8(TYPE_CHORD);
else
	TYPE_CHORD = str2char8(TYPE_CHORD);
end



void = '        ';
%fprintf(fid, '$-------2-------3-------4-------5-------6-------7-------8-------9-------10\n');
fprintf(fid, '%s%s%s%s%s%s%s%s%s%s\n', str2char8('CAERO1', 'l'), ...
        int2char8(AID), dbl2char8(DIH), int2char8(CID), int2char8(NY), int2char8(NX), ... 
        str2char8(FOIL1), str2char8(FOIL2), TYPE_SPAN, TYPE_CHORD);
        
fprintf(fid, '%s%s%s%s%s%s%s%s%s%s\n', void, ...
        dbl2char8(CX), dbl2char8(CY), dbl2char8(CZ), dbl2char8(CHD), dbl2char8(SPN), ...
        dbl2char8(TPR), dbl2char8(SWP), dbl2char8(TW1), dbl2char8(TW2));

if flapped
	if isempty(FNX) || FNX==0 || ~isstr(TYPE_FLAP)
		TYPE_FLAP = int2char8(TYPE_FLAP);
	else
		TYPE_FLAP = str2char8(TYPE_FLAP);
	end

	fprintf(fid, '%s%s%s%s%s%s%s\n', void, ...
	        int2char8(1), dbl2char8(FC1), dbl2char8(FC2), int2char8(FNX), str2char8(FNAME), TYPE_FLAP);
end



return
