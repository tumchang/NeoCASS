 fid= fopen('TestFILEABCD.dat','w');  
fprintf(fid,['\n\n']);
  fidRBE2 = fopen('Guess_jointsACBD.dat');
  tline = fgets(fidRBE2);
  %fprintf(fid,[tline,'\n']);
  while ischar(tline)
    disp(tline)
    fprintf(fid,[tline]);
    tline = fgets(fidRBE2);
  end
  fclose(fidRBE2);
  fclose(fid);