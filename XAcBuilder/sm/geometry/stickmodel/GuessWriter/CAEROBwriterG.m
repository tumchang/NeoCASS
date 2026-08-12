function CAEROBwriterG(fid,CAEROB)
            %CAE ID  0X    0Y    0Z    CID LEN   NP  1
        %    1---2---3-----4-----5-----6---7-----8---9 
fprintf(fid,'%-8s%-8d%-8.4f%-8.4f%-8.4f%-8d%-8.4g%-8d%-8d\n',...
            'CAEROB',...    
            CAEROB.ID,... 
            CAEROB.OX,...
            CAEROB.OY,...
            CAEROB.OZ,...
            CAEROB.CID,...
            CAEROB.LEN,...
            CAEROB.NP,...
            1);
fprintf(fid,'%-8s','');            
        j=1; 
            for h=1:length(CAEROB.ISETxsi)                
                if j>=9
                    fprintf(fid,'\n%-8s','');
                    j=1;
                end
                j=j+1;
                fprintf(fid,'%-8.4g',CAEROB.ISETxsi(h));
                if j>=9
                    fprintf(fid,'\n%-8s','');
                    j=1;
                end
                j=j+1;
                fprintf(fid,'%-8.4g',CAEROB.ISET_R(h));
            end
            fprintf(fid,'ENDT\n');
    
end