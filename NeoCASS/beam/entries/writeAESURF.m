function [] = writeAESURF(fid, ID, NAME, CID, AERID)
%
%
%
%-------------------------------------------------------------------------------
% 03-01-2017
%




void = '        ';

%             1 2 3 4 
fprintf(fid, '%s%s%s%s', str2char8('AESURF', 'l'), ...
        int2char8(ID), str2char8(NAME), int2char8(CID), int2char8(AERID));

fprintf(fid, '\n');







return
