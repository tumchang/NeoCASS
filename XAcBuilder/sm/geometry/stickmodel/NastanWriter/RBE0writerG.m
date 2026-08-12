function RBE0writerG(fid,RBE0)
fprintf(fid,'%8s%8d%8d',...
            'RBE0    ',...
            RBE0.ID,...
            RBE0.GM);
            
            j=3; 
            for h=1:length(RBE0.GSi)                
                if j==9
                    fprintf(fid,'\n%8s','');
                    j=1;
                end
                j=j+1;
                fprintf(fid,'%8d',RBE0.GSi(h));
            end
            fprintf(fid,'\n');
end