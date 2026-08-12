%AeroBox
figure()
wingID=1;
elemID=0;
paeroID=1;
coordID=0;
intgrID=1;

setID=0;
figure, hold on, axis equal
for i=1:Npos
    %
    ABoxSect=TechGeoModel.iWing{wingID}.aeroPanel.SectWing{i};
    %AEFACT LSPAN
    setID=setID+1;
    Nastran.AEFACT(setID).SID = setID;
    Nastran.AEFACT(setID).Di  = ABoxSect.Aefact_span;
    %AEFACT LCHORD
    setID=setID+1;
    Nastran.AEFACT(setID).SID = setID;
    Nastran.AEFACT(setID).Di  = ABoxSect.Aefact_chord;
    %CAERO
    elemID=elemID+1;
    Nastran.CAERO(elemID).EID    = elemID;
    Nastran.CAERO(elemID).PID    = paeroID;
    Nastran.CAERO(elemID).CP     = coordID;   
    Nastran.CAERO(elemID).LSPAN  = setID;
    Nastran.CAERO(elemID).LCHORD = setID;
    Nastran.CAERO(elemID).IGID   = intgrID;
    Nastran.CAERO(elemID).X1     = ABoxSect.X(1,1);
    Nastran.CAERO(elemID).Y1     = ABoxSect.X(1,2);
    Nastran.CAERO(elemID).Z1     = ABoxSect.X(1,3);
    Nastran.CAERO(elemID).X12    = ABoxSect.X(2,1)-ABoxSect.X(1,1);
    Nastran.CAERO(elemID).X4     = ABoxSect.X(4,1);
    Nastran.CAERO(elemID).Y4     = ABoxSect.X(4,2);
    Nastran.CAERO(elemID).Z4     = ABoxSect.X(4,3);
    Nastran.CAERO(elemID).X43    = ABoxSect.X(3,1)-ABoxSect.X(4,1);
    
    %Verify plot
    X=[ABoxSect.X(1,1) ABoxSect.X(2,1);...
       ABoxSect.X(4,1) ABoxSect.X(3,1)];
    Y=[ABoxSect.X(1,2) ABoxSect.X(2,2);...
       ABoxSect.X(4,2) ABoxSect.X(3,2)];
    Z=[ABoxSect.X(1,3) ABoxSect.X(2,3);...
       ABoxSect.X(4,3) ABoxSect.X(3,3)];
   surf(X,Y,Z)

    
    fprintf('%s\n',['$ Wing ',num2str(wingID),' , Sect ',num2str(i)]);
    fprintf('$Aerodynamic Box eta division\n');
    fprintf('%8s%8d',...
            'AEFACT  ',Nastran.AEFACT(Nastran.CAERO(elemID).LSPAN).SID)
            j=2; 
            for i=1:length(Nastran.AEFACT(Nastran.CAERO(elemID).LSPAN).Di)                
                if j==9
                    fprintf('\n%8s','');
                    j=1;
                end
                j=j+1;
                fprintf('%8.4f',Nastran.AEFACT(Nastran.CAERO(elemID).LSPAN).Di(i))
            end
            fprintf('\n');
    fprintf('$Aerodynamic Box xsi division\n');        
    fprintf('%8s%8d',...
            'AEFACT  ',Nastran.AEFACT(Nastran.CAERO(elemID).LCHORD).SID)
            j=2; 
            for i=1:length(Nastran.AEFACT(Nastran.CAERO(elemID).LCHORD).Di)                
                if j==9
                    fprintf('\n%8s','');
                    j=1;
                end
                j=j+1;
                fprintf('%8.4f',Nastran.AEFACT(Nastran.CAERO(elemID).LCHORD).Di(i))
            end
            fprintf('\n');    
    fprintf('$Aerodynamic Box\n');
    fprintf('%8s%8d%8d%8d%8s%8s%8d%8d%8d\n%8s%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f\n',...
              'CAERO1  ',Nastran.CAERO(elemID).EID,...
                         Nastran.CAERO(elemID).PID,...
                         Nastran.CAERO(elemID).CP,...
                         '',...
                         '',...
                         Nastran.CAERO(elemID).LSPAN,...
                         Nastran.CAERO(elemID).LCHORD,...
                         Nastran.CAERO(elemID).IGID,...
                         '',...
                         Nastran.CAERO(elemID).X1,...
                         Nastran.CAERO(elemID).Y1,...
                         Nastran.CAERO(elemID).Z1,...
                         Nastran.CAERO(elemID).X12,...
                         Nastran.CAERO(elemID).X4,...
                         Nastran.CAERO(elemID).Y4,...
                         Nastran.CAERO(elemID).Z4,...
                         Nastran.CAERO(elemID).X43);
     
        
                                 
end
    
    
    
    