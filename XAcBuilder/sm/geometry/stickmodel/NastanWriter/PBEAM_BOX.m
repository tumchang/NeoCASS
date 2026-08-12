function PBEAM_BOX(file_name,PID,MID,a,t1,b,t2,NSM)
%file_name file where function write CARD
%a         width
%t1        tickness of width side
%b         heigth
%t2        tickness of hegth side
%NSM       NonStructuralMass

%  close all, clear all, clc 
%  file_name1='pippo.dat';
% PID=1;MID=1;
% % a=[10 20]'; t1=[1 1]';
% % 
% % b=[3 6]';  t2=[1 1]';
% % 
% NSM=[0 0]';
% a = [0.1483    0.1443]';
% t1= [0.0059    0.0059]';
% b = [0.5931    0.5774]';
% t2= [0.0059    0.0059]';


% figure(),hold on
% plot([-a/2 a/2 a/2 -a/2],[b/2 b/2 -b/2 -b/2])
% plot([-a/2+t2 a/2-t2 a/2-t2 -a/2+t2],[b/2-t1 b/2-t1 -b/2+t1 -b/2+t1])

for i=1:length(a)
%     plot([-a(i)/2 a(i)/2 a(i)/2 -a(i)/2],[b(i)/2 b(i)/2 -b(i)/2 -b(i)/2])
%     plot([-a(i)/2+t2(i) a(i)/2-t2(i) a(i)/2-t2(i) -a(i)/2+t2(i)],[b(i)/2-t1(i) b(i)/2-t1(i) -b(i)/2+t1(i) -b(i)/2+t1(i)])

    A(i)=a(i)*b(i)-(a(i)-2*t2(i))*(b(i)-2*t1(i));
    I1(i)=a(i)^3*b(i)/12-(a(i)-2*t2(i))^3*(b(i)-2*t1(i))/12; 
    I2(i)=a(i)*b(i)^3/12-(a(i)-2*t2(i))*(b(i)-2*t1(i))^3/12; 
    I12(i)=0; 
    J(i)=1/2*(I1(i)+I2(i));
    
    %points of stress recovery
    %1->y   %2-z
    C1(i)= a(i)/2; C2(i)= b(i)/2;
    D1(i)=-a(i)/2; D2(i)= b(i)/2;
    
    E1(i)=-a(i)/2; E2(i)=-b(i)/2;
    F1(i)= a(i)/2; F2(i)=-b(i)/2;
    
end

                   

% file_name=fopen(file_name1,'w');
                     %Pid mid   A   I1   I2  I12    J  NSM
% fprintf(file_name,'%8s%8i%8i%8.3f%8.3f%8.3f%8.3f%8.3f%8.3f\n%8s%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f\n%8s%8s%8.1f%8.4f%8.2f%8.2f%8.2f%8.2f%8.3f\n%8s%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f\n',...
%         'PBEAM   ',  PID,    MID,   A(1),  I1(1),  I2(1), I12(1),   J(1),   NSM(1),...
%              '',C1(1),  C2(1),  D1(1),  D2(1),  E1(1),  E2(1),  F1(1),    F2(1),...
%              '','YES',      1,   A(2),  I1(2),  I2(2), I12(2),   J(2),   NSM(2),...
%              '',C1(2),  C2(2),  D1(2),  D2(2),  E1(2),  E2(2),  F1(2),    F2(2));

%DOUBLE 16 BIT
                      %Pid mid     A    I1         I2  I12    J  NSM
%                   -    1   2     3     4     -    5       
% fprintf(file_name,'%8s  %14i  %14i%16.3E%16.3E\n','PBEAM*  ',  PID,    MID,   A(1),  I1(1));
% fprintf(file_name,'%8s%16.3E%16.1f%16.3E%16.3f\n','*       ',I2(1), I12(1),   J(1), NSM(1));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',C1(1),  C2(1),  D1(1),  D2(1));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',E1(1),  E2(1),  F1(1),  F2(1));
% fprintf(file_name,'%8s  %14s%16.1f%16.5E%16.2E\n','*       ','YES',      1,   A(2),  I1(2));
% fprintf(file_name,'%8s%16.3E%16.1f%16.3E%16.3f\n','*       ',I2(2), I12(2),   J(2), NSM(2));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',C1(2),  C2(2),  D1(2),  D2(2));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',E1(2),  E2(2),  F1(2),  F2(2));

% fprintf(file_name,'%8s  %14i  %14i%16.6f%16.6f\n','PBEAM*  ',  PID,    MID,   A(1),  I1(1));
% fprintf(file_name,'%8s%16.6f%16.1f%16.6f%16.3f\n','*       ',I2(1), I12(1),   J(1), NSM(1));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',C1(1),  C2(1),  D1(1),  D2(1));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',E1(1),  E2(1),  F1(1),  F2(1));
% fprintf(file_name,'%8s  %14s%16.1f%16.6f%16.6f\n','*       ','YES',      1,   A(2),  I1(2));
% fprintf(file_name,'%8s%16.6f%16.1f%16.6f%16.3f\n','*       ',I2(2), I12(2),   J(2), NSM(2));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',C1(2),  C2(2),  D1(2),  D2(2));
% fprintf(file_name,'%8s%16.5f%16.5f%16.5f%16.5f\n','*       ',E1(2),  E2(2),  F1(2),  F2(2));

fprintf(file_name,'%8s%16i%16i%#16.4G%#16.5G\n','PBEAM*  ',  PID,    MID,   A(1),  I1(1));
fprintf(file_name,'%8s%#16.5G%#16.4G%#16.4G%#16.4G\n','*       ',I2(1), I12(1),   J(1), NSM(1));
fprintf(file_name,'%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',C1(1),  C2(1),  D1(1),  D2(1));
fprintf(file_name,'%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',E1(1),  E2(1),  F1(1),  F2(1));
fprintf(file_name,'%8s%#16s%#16.4G%#16.4G%#16.5G\n',  '*       ','YES',      1,   A(2),  I1(2));
fprintf(file_name,'%8s%#16.5G%#16.4G%#16.4G%#16.4G\n','*       ',I2(2), I12(2),   J(2), NSM(2));
fprintf(file_name,'%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',C1(2),  C2(2),  D1(2),  D2(2));
fprintf(file_name,'%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',E1(2),  E2(2),  F1(2),  F2(2));
% fprintf('%8s%16i%16i%#16.4G%#16.5G\n','PBEAM*  ',  PID,    MID,   A(1),  I1(1));
% fprintf('%8s%#16.5G%#16.4G%#16.4G%#16.4G\n','*       ',I2(1), I12(1),   J(1), NSM(1));
% fprintf('%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',C1(1),  C2(1),  D1(1),  D2(1));
% fprintf('%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',E1(1),  E2(1),  F1(1),  F2(1));
% fprintf('%8s%#16s%#16.4G%#16.4G%#16.5G\n',  '*       ','YES',      1,   A(2),  I1(2));
% fprintf('%8s%#16.5G%#16.4G%#16.4G%#16.4G\n','*       ',I2(2), I12(2),   J(2), NSM(2));
% fprintf('%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',C1(2),  C2(2),  D1(2),  D2(2));
% fprintf('%8s%#16.4G%#16.4G%#16.4G%#16.4G\n','*       ',E1(2),  E2(2),  F1(2),  F2(2));


% fclose(file_name);
% type pippo2.dat
         
                    
