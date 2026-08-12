function AELISTwriter(fid,AELIST)       
fprintf(fid,'%8s%8d',...
            'AELIST  ',AELIST.SID);
j=2; 
for h=1:length(AELIST.Ei)                
    if j==9
        fprintf(fid,'\n%8s','');
        j=1;
    end
    j=j+1;
    fprintf(fid,'%8d',AELIST.Ei(h));
end
fprintf(fid,'\n');    