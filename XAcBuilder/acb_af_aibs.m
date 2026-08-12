% **** Rev. 2016-07-07


function acb_af_aibs()
IDAF = 1;
%path_cpacs = strcat(pwd,filesep,'aif.mat');
path_cpacs=strcat(strrep(which('acbuilder.m'),'acbuilder.m',''),'aif.mat')
save(path_cpacs','IDAF')
AirFoil_List = dir(strcat(strrep(which('acbuilder.m'),'acbuilder.m',''),'airfoil'));
filenum=1;
for faf = 1:length(AirFoil_List)
    if (AirFoil_List(faf).isdir == 0)
        try
        disp('file')
       
  
    pathfoil = (strcat(strrep(which('acbuilder.m'),'acbuilder.m',''),'airfoil'));
    qq = strcat(pathfoil,filesep,(AirFoil_List(faf).name));
    
    
    text = strtrim(fileread(qq));
    textlineparse=strsplit(text,char(10));
    
     %fid = fopen(strcat(pathfoil,filesep,(AirFoil_List(faf).name)));
% 
% k = 0;
 lineax = '';
 lineay = '';
 lineaz = '';
 indexcoor = 1;
 x_coor_num = [];
 y_coor_num = [];
 z_coor_num = [];
 for lineafile = 1:length(textlineparse)
%while ~feof(fid)
     %tline = (fgetl(fid));
     tline = textlineparse{lineafile};
     tline_trim = strtrim(tline);
     tline_ready = strrep(tline_trim,' ','|');
     tline_parse = (strsplit(tline_ready,'|'));
     if (length(tline_parse) == 2) %&& isnumeric(cell2mat(tline_parse(1))) && isnumeric(cell2mat(tline_parse(2))) )
        %xaf_coor = 
        %xisnum   = isnumeric(xaf_coor)
         try
         xaf_coor = str2double(tline_parse{1});
         yaf_coor = str2double(tline_parse{2});
         if ( ~isnan(xaf_coor) && ~isnan(yaf_coor) && xaf_coor<=1) % Aggiunto controllo per X>1 CPACS non compatibile
             % Sicuramente coppia di coordinate
          x_coor_num(indexcoor,1)= xaf_coor;
          y_coor_num(indexcoor,1)= yaf_coor;
          z_coor_num(indexcoor,1)= 0.0;
          indexcoor=indexcoor+1;
         lineax = strcat(lineax,';',tline_parse(1));
         lineaz = strcat(lineaz,';','0');
         lineay = strcat(lineay,';',tline_parse(2));
         disp('Coord. OK!')
         else
            fprintf('ERROR: impossible evaluate coordinate from airfoil file - %s at line %d.',AirFoil_List(faf).name,lineafile)           
         end
         catch
            fprintf('INFO / ERROR: impossible evaluate coordinate from airfoil file - %s.',AirFoil_List(faf).name) 
         end
         
         
     else
         disp('NO')
     end
% end %while
 end %for test
     listaf{IDAF,1} = AirFoil_List(faf).name(1:end-4);%char(39),,char(39
     
     
     % ***** Riordino Coordinate **********
     %%{
     [CoordNewScX CoordNewScY] = acb_af_aibs_ord_b(x_coor_num,y_coor_num)
     lineax_sup = ''
     lineay_sup = ''
     % Conversione Coordinate in stringa
     for kkk=1:length(CoordNewScX)
         lineax_sup = strcat(lineax_sup,';',num2str(CoordNewScX(kkk)));
         lineay_sup = strcat(lineay_sup,';',num2str(CoordNewScY(kkk)));
     end
     %%}
     % ************************************
     
     
     %clc
     lineax{1} = lineax_sup;
     XPnts = lineax{1}(2:end);
     stringa=strcat('AF_',AirFoil_List(faf).name(1:end-4), 'x=' , char(39), XPnts, char(39));
     eval(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'x=' , char(39), XPnts, char(39)));
     listaf{IDAF,2} = eval(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'x'));
     %eval(strcat('save(', char(39),'h:\vertestv.mat',char(39),',',char(39),'AF_',AirFoil_List(faf).name(1:end-4), 'x',char(39),')','-append'))
     eval(strcat('save(', char(39),path_cpacs,char(39),',',char(39),'AF_',AirFoil_List(faf).name(1:end-4), 'x',char(39),', ',char(39),'-append',char(39),')'));
     
     %strcat( 'save(' , char(39), 'h:\vertestv.mat' , char(39), ',', char(39),'AF_B109x',char(39),char(39),'-append',char(39),')');
     
     %save('h:\testapp.mat',eval(stringa),'-append')
     %disp('salva xX')
     %clc
     ZPnts = lineaz(2:end);
     stringa=strcat('AF_',AirFoil_List(faf).name(1:end-4), 'z=' , char(39), ZPnts, char(39));
     eval(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'z=' , char(39), ZPnts, char(39)));
     listaf{IDAF,3} = eval(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'z'));
     eval(strcat('save(', char(39),path_cpacs,char(39),',',char(39),'AF_',AirFoil_List(faf).name(1:end-4), 'z',char(39),', ',char(39),'-append',char(39),')'));
    %clc
     %save('h:\testapp.mat','stringa','-append')
    lineay{1}= lineay_sup; 
    YPnts = lineay{1}(2:end);
    stringa=strcat('AF_',AirFoil_List(faf).name(1:end-4), 'y=' , char(39), YPnts, char(39));
    eval(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'y=' , char(39), YPnts, char(39)));
    listaf{IDAF,4} = eval(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'y'));
    eval(strcat('save(', char(39),path_cpacs,char(39),',',char(39),'AF_',AirFoil_List(faf).name(1:end-4), 'y',char(39),', ',char(39),'-append',char(39),')'));
    
    clear(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'x'));
    clear(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'y'));
    clear(strcat('AF_',AirFoil_List(faf).name(1:end-4), 'z'));
    
    
     %save('h:\testapp.mat','stringa','-append')
     
     
 %fclose(fid);
    
    IDAF = IDAF+1;      
    file_foils.name{filenum}=AirFoil_List(faf).name(1:end-4);
    file_foils.xco{filenum}=XPnts;%x_coor_num;
    file_foils.yco{filenum}=ZPnts;%y_coor_num; %CPACS AcBuilder Y<>Z
    file_foils.zco{filenum}=YPnts;%z_coor_num;
    filenum =filenum + 1;
    save(path_cpacs,'file_foils', '-append');
    
    catch
    end
    
    
    else
        disp('dir')
    end 
    
    
end

listaf

end