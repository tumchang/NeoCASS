function GuessStick_Fun
% 0.inizilization
    %close all, clc, clear all, clear Guess
    global TechGeoModel Guess %wingID
    global CID      GID    MID    EID             PID            SID 
    %global cord2rID gridID mat1ID cbarID caero1ID caerobID pbarID paeroID set1ID intgrID spline1ID 

    addpath('NastanWriter');
    addpath('GuessWriter');
       
    figure(1), hold on, axis equal
    %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_TechGeoModel.mat';
    %str='F:\Roby\CPACCrORIG2\CPACCrORIG\cpacscreator_v1.4\projects\D150 for CPACS 1.3_TechGeoModel.mat';
    str = 'G:\99 - Z DepEnv\CPACCrORIG2\CPACCrORIG2\CPACCrORIG\cpacscreator_v1.4\projects\D150 for CPACS 1.3_TechGeoModel.mat'
    str = 'G:\300-Matlab_2012_2014\NeoCASS_Latest_Version_patched\XAcBuilder\sm\projects\AcBuilder Model_TechGeoModel.mat'
    str = 'F:\Roby\AcBuilder Project Home\Parte 2 - StickModel\2015-04-03 - NeoCASS\NeoCASS_Latest_Version_patched\XAcBuilder\sm\projects\AcBuilder Model_TechGeoModel.mat'
    str = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'\sm\projects\AcBuilder Model_TechGeoModel.mat')
    %str = 'G:\99 - Z DepEnv\CPACCrORIG2\CPACCrORIG2\CPACCrORIG\cpacscreator_v1.4\projects\JJJ.mat'
    %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150 for CPACS 1.3_TechGeoModel.mat';    
    %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_BracedWing_TechGeoModel.mat';
    %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_joinedWing_TechGeoModel_r2';
    %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_xStick_TechGeoModel.mat';
    %str='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\D150_xStick_TechGeoModel_r3.mat';
    load(str)
    
    component=0;
% ********************* ERA COMMENTATO **********************************

% 1.Fuselage genration
     Nfus=length(TechGeoModel.iFus);
     for i=1:Nfus
         component=component+1;    
         GuessFus5(i,component,0);
         disp(['Fuselage ',num2str(i),' generated'])
         if TechGeoModel.iFus{i}.symmetry~=0                
             GuessFus5(i,component,1);
             disp(['Fuselage ',num2str(i),' generated'])
         end            
     end
     
% ***********************************************************************
% 2.Wing generation
    Nwing=length(TechGeoModel.iWing);
    for i=1:Nwing %1
        component=component+1;
        GuessWing7(i,component,0);
         disp(['Wing ',num2str(i),' generated'])
         if TechGeoModel.iWing{i}.symmetry~=0              
             GuessWing7(i,component,1);
             disp(['Wing ',num2str(i),' generated'])
         end
    end   
% 3.Joint 
    %jointStick_Fun3(component,Nfus,Nwing) 
    % Sospeso, funzione trasferita ad AcBuilder in modalità manuale.
    
    
 
%10.save db
    save('StickModel.mat','Guess')
    
%20.write whole model
    pathSMDef = (strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m',''),'AcBSMDir\'))
    fid= fopen([strcat(pathSMDef,'Guess_Model.dat')],'w');
    fprintf(fid,'SOL 144\n');
    fprintf(fid,'PARAM   DIVERG  1\n');
    fprintf(fid,'AEROS           0       1.75644 16.5595 27.6353 0       0\n');     
    fprintf(fid,'TRIM=   2\n');       
    fprintf(fid,'TRIM    2       1       0.3     0.0     SIDES   0.0     ROLL    0.0\n');    
    fprintf(fid,'PITCH   0.0     YAW     0.0     URDD2   0.0     URDD3   9.81\n');
    fprintf(fid,'URDD4   0.0     URDD5   0.0     URDD6   0.0     ANGLEA  0.0\n');     
    fprintf(fid,'flap1r  0.0     flap2r  0.0     aileronr0.0\n');
    % Aerodynamic
    fprintf(fid,['$Aerodynamic \n']);
% ****************************** ERA COMMENTATO **************************    
     for i=1:Nfus
         fprintf(fid,['\n$Fuselage ',num2str(i),'\n\n']);
         CORD2Rwriter(fid,Guess.iFus{i}.CORD2R(1));
         %CAEROBwriterG(fid,Guess.iFus{i}.CAEROB(1)); % *** SOSPESO ***
         for j=1:length(Guess.iFus{i}.RBE0)
             GRIDwriter(fid,Guess.iFus{i}.GRID(j));
         end
     end
% ************************************************************************
% ***************** ERA COMMENTATO **************************************2
    for i=1:Nwing
        fprintf(fid,['\n$Wing ',num2str(i),'\n\n']);
        Guess.iWing{1} % Aggiunto
        
        for j=1:length(Guess.iWing{i}.CAERO1);
            CAERO1writerG(fid,Guess.iWing{i}.CAERO1(j));
        end
        
        for j=1:length(Guess.iWing{i}.SPLINE1);
             SPLINE1writerG(fid,Guess.iWing{i}.SPLINE1(j));
        end
         
         for j=3:length(Guess.iWing{i}.SET1);
             SET1writer(fid,Guess.iWing{i}.SET1(j));
         end
         for j=1:length(Guess.iWing{i}.GRID)
             GRIDwriter(fid,Guess.iWing{i}.GRID(j));
         end
    end
% *********************************************************************2
% ********************* ERA COMMENTATATO *******************************    
   % Structure
   fprintf(fid,['$Structure \n']);
     for i=1:Nfus
         fprintf(fid,['\n$Fuselage ',num2str(i),'\n\n']);
         MAT1writer(fid,Guess.iFus{i}.MAT1);                
         for j=1:length(Guess.iFus{i}.CBAR);
             PBARwriter(fid,Guess.iFus{i}.PBAR(j));
             CBARwriter(fid,Guess.iFus{i}.CBAR(j));
         end
         for j=1:length(Guess.iFus{i}.SET1); %2
             SET1writer(fid,Guess.iFus{i}.SET1(j));
         end
         for j=1:length(Guess.iFus{i}.RBE0)
             RBE0writerG(fid,Guess.iFus{i}.RBE0(j))
         end
         for j=length(Guess.iFus{i}.RBE0)+1:length(Guess.iFus{i}.GRID)
             GRIDwriter(fid,Guess.iFus{i}.GRID(j));
         end
     end
     for i=1:Nwing
         fprintf(fid,['\n$Wing ',num2str(i),'\n\n']);
         MAT1writer(fid,Guess.iWing{i}.MAT1);                
         for j=1:length(Guess.iWing{i}.CBAR);
             PBARwriter(fid,Guess.iWing{i}.PBAR(j));
             CBARwriter(fid,Guess.iWing{i}.CBAR(j));
         end
         
         %{
         for j=1:length(Guess.iWing{i}.SET1); %2
             SET1writer(fid,Guess.iWing{i}.SET1(j));
         end
         %}
         
 % ********************* ERA COMMENTATO *********************************2        
          %{
          for j=1:length(Guess.iWing{i}.RBE0)
              %RBE0writerG(fid,Guess.iWing{fusID}.RBE0(j))
              RBE0writerG(fid,Guess.iWing{i}.RBE0(j))
          end
          
          for j=length(Guess.iWing{i}.RBE0)+1:length(Guess.iWing{i}.GRID)
              GRIDwriter(fid,Guess.iWing{i}.GRID(j));
          end
          %}
 % **********************************************************************2
     end
     
     
 % ****** Copia RBE2 Guess_joints.dat in coda al file Guess_stick.dat *****
 %{
  %copyfile('Guess_joints.dat','Supp.txt');
  fprintf(fid,['\n\n']);
  fidRBE2 = fopen('Guess_joints.dat','r'); %
  tline = fgets(fidRBE2);
  %fprintf(fid,[tline,'\n']);
  while ischar(tline)
    disp(tline)
    fprintf(fid,[tline]);
    tline = fgets(fidRBE2);
  end
  fclose(fidRBE2);
  %delete('Supp.txt');
 %}
%{ 
  pathSMDefB = strrep(pathSMDef,'\','\\')
  %pathINCLUDE = strcat('INCLUDE ',pathSMDef,' Guess_jointsABC.dat\n')
  pathINCLUDE = sprintf('INCLUDE %sGuess_jointsABCD.dat\n',pathSMDefB)
  %fprintf(fid,'INCLUDE Guess_joints.dat\n');
  fprintf(fid,pathINCLUDE);
%} 
  
  %disp('FINE')   
 % ************************    
     
  fclose(fid); % Chiude Guess_model.dat          
% *********************************************************************** 
  % ****** Finalizzazione File Guess_joints.dat ************
  global RadiceNomeFileA;
  global RadiceNomeFileB;
  
  rng shuffle
  RadiceNomeFileA = randi([0 100000],1,1);
  RadiceNomeFileB = randi([100000 500000],1,1);
  
  fileorRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\Guess_joints_AcB.dat');
  filedestRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\ID_',mat2str(RadiceNomeFileA+RadiceNomeFileB),'-Guess_joints_AcB.dat');
  movefile(fileorRBE2,filedestRBE2)
    
  fid = fopen([strcat(pathSMDef,'ID_',mat2str(RadiceNomeFileA+RadiceNomeFileB),'-Guess_joints_AcB.dat')],'a+');
  fprintf(fid,['$END']);
  fclose(fid);
  % ******************************************************
  
  % ***** Scrittura RBE2 in coda al file Stick **************************
  fid = fopen([strcat(pathSMDef,'Guess_Model.dat')],'a+');
  fprintf(fid,['\n\n']);
  %{
  fidRBE2 = fopen([strcat(pathSMDef,'Guess_joints.dat')],'r'); %
  tline = fgets(fidRBE2);
  %fprintf(fid,[tline,'\n']);
  while ischar(tline)
    disp(tline)
    fprintf(fid,[tline]);
    tline = fgets(fidRBE2);
  end
  fclose(fidRBE2);
  % **********************************************************************
  %}
  
  % ********* Aggiunge CARD INCLUDE per file RBE2 Guess_joints.dat *******
  % ********* in coda a Guess_Model.dat **********************************
  pathSMDefB = strrep(pathSMDef,'\','\\');
  %pathINCLUDE = strcat('INCLUDE ',pathSMDef,' Guess_jointsABC.dat\n')
  %pathINCLUDE = sprintf('INCLUDE %sGuess_joints_AcB.dat\n',pathSMDefB);
  pathINCLUDE = sprintf('INCLUDE %sID_%s-Guess_joints_AcB.dat\n',pathSMDefB,mat2str(RadiceNomeFileA+RadiceNomeFileB));
  
  %fprintf(fid,'INCLUDE Guess_joints.dat\n');
  fprintf(fid,['\n\n']);
  fprintf(fid,pathINCLUDE);
  % **********************************************************************
  
  fclose(fid);
  
   fileorRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\Guess_Model.dat');
   filedestRBE2 = strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\ID_',mat2str(RadiceNomeFileA+RadiceNomeFileB),'-Guess_Model.dat');

   movefile(fileorRBE2,filedestRBE2)


% **** Richiamo di NeoCASS *****
% Construct a questdlg with three options
richiestaNeoCASS = questdlg('Display in NeoCASS?', ...
	'Display Menu', ...
	'Yes','No','Yes');
% Handle response
switch richiestaNeoCASS
    case 'Yes'
        disp('Opening NeoCASS Stick Model Plot')
        global beam_model
        fn = strcat('ID_',mat2str(RadiceNomeFileA+RadiceNomeFileB),'-Guess_Model.dat');
        beam_model = load_nastran_model(fn);
        plot_beam_model(1);
    case 'No'
        disp('Use NeoCASS to display Stick Model Plot')
    otherwise
        disp('Use NeoCASS to display Stick Model Plot')
end

disp('!!! FINE   !!!') 


% ******************************


end

    