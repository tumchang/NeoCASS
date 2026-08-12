function RBE2writer(fid,flag4NO,RBE2)
if flag4NO == 1
   comC = '';
else
   comC = '$';
end
    
fprintf(fid,'%s%8s%8d%8d%8d',...
            comC,...
            'RBE2    ',...
            RBE2.EID,...
            RBE2.GN,...
            RBE2.CM);
            j=4; 
            for h=1:length(RBE2.GMi)                
                if j==9
                    fprintf(fid,'\n%8s','');
                    j=1;
                end
                j=j+1;
                fprintf(fid,'%8d',RBE2.GMi(h));
            end
            fprintf(fid,'\n');
end