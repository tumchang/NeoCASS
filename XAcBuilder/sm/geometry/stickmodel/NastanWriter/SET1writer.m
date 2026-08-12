function SET1writer(fid,SET1)       
fprintf(fid,'%8s%8d',...
            'SET1    ',SET1.SID);
j=2; 
for h=1:length(SET1.IDs)                
    if j==9
        fprintf(fid,'\n%8s','');
        j=1;
    end
    j=j+1;
    fprintf(fid,'%8d',SET1.IDs(h));
end
fprintf(fid,'\n');    