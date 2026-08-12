function [aflist4CPACS] = acb_setCPACSairfoils()
elencoAF = dir('.\airfoil')
naf = length(elencoAF)
airfoilstore = cell(size(naf-2,4))
for ii = 1:naf
    ii
  datix = ''
  datiy = ''
  datiz = ''  
    
    if elencoAF(ii).isdir == 0
         strcat('.\airfoil\',elencoAF(ii).name)
         fid = fopen(strcat('.\airfoil\',elencoAF(ii).name));
         tline = fgetl(fid);
         commpres = strfind(tline, '%')
         while isempty(commpres) == false
           tline = fgetl(fid);
           commpres = strfind(tline, '%')
         end
         C = strsplit(tline, ' ')
         Cx = C(1)
         Cy = C(2)
         datix = strcat(datix,Cx,';')
         datiy = strcat(datiy,'0',';')
         datiz = strcat(datiz,Cy,';')
         while ischar(tline)
         %tlineflag = fgetl(fileID)
           tline = fgetl(fid);
           if length(tline)>2
           C = strsplit(tline, ' ')
           Cx = C(1)
           Cy = C(2)
           datix = strcat(datix,Cx,';')
           datiy = strcat(datiy,'0',';')
           datiz = strcat(datiz,Cy,';')
         end
         end
         fclose(fid);
        
        
       nome=strrep(elencoAF(ii).name,'.dat','')
       airfoilstore{ii-2,1} = nome
       airfoilstore{ii-2,2} = char(datix)
       airfoilstore{ii-2,3} = datiy
       airfoilstore{ii-2,4} = char(datiz)
       
       
    end
end 

aflist4CPACS = airfoilstore

end