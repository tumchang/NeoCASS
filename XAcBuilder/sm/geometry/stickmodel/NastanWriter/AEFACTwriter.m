function AEFACTwriter(fid,AEFACT)
fprintf(fid,'%8s%8d',...
            'AEFACT  ',AEFACT.SID);
            j=2; 
            for h=1:length(AEFACT.Di)                
                if j==9
                    fprintf(fid,'\n%8s','');
                    j=1;
                end
                j=j+1;
                fprintf(fid,'%8.4f',AEFACT.Di(h));
            end
            fprintf(fid,'\n');
end