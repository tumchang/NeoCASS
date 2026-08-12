function [NewS] = inclWing(NewS,wingNum,CPACSgeo,option)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inclWing                                                              %
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2012-08-27 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Settings

autosym=1;
% hold on
%% Loop for Symmetry

if CPACSgeo.wings.component{wingNum,1}.symmetry==1
    n=2;
else
    n=1;
end
if autosym
    n=1;
end

for sym=1:n;
    if sym==1;
        sig=1;
    else
        sig=-1;
    end
        
%% Set new Structure

%% Check if wingRoot in Fuselage and add an new section inside if not

    % Zur berechnung eines Zwischen stück zweischen einenm unsymetrischen
    % flügel und dem Rumpf.
    % 1. Es wirg geschaut welche teile des rumpfes betroffen sind.
    % 2. Es wird der abstang zwischen jeden punkt (nur in der y-z-Ebene) 
    % des Rumpf profiels und des Flügelprofiels berechent und der maximalste (maxMaxDist) weiter verwendet.
    % 3. Es wird der Flächenschwerpunkt des Flügel profiels berechnet und
    % der mittel punkt des Rumpfprofils. Der vector zwischen den beiden
    % punkten ist der verschiebungs richtungsvector und  maxMaxDist ist der
    % Verschibungswert des Flügelprofiels.

    if ~CPACSgeo.wings.component{wingNum,1}.symmetry  
        try 
            inside=1;
            for i=1:size(CPACSgeo.fuselages.component{1,1}.sectionDef.airfoil,1);
                % Rumpfprofiel
                fusFoil=CPACSgeo.fuselages.component{1,1}.sectionDef.airfoil{i,1};
                %hold on
                %plot3(mean(fusFoil(:,1)),mean(fusFoil(:,2)),mean(fusFoil(:,3)),'*');

                % Rumpfprofiel Mittelpunkt
                mp=[mean(fusFoil(:,1)),mean(fusFoil(:,2)),mean(fusFoil(:,3))];

                isinside=0;
                isinside2=0;
                deltaMinVec=[];           

                for ii=1 % Es wird nur im Ersten Profiel nachgeschaut
                    % Flügelprofiel
                    foil=CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{ii,1};
                    [maxX,maxXpos]=max(foil(:,1));
                    [minX,minXpos]=min(foil(:,1));   

                    % Calc Area Center von Flügelprofiel
                    [ geom ] = polygeom( foil(:,1), foil(:,2)); 
                    X_cen = geom(2);
                    Y_cen = geom(3);                
                    [ geom ] = polygeom(foil(:,1), foil(:,3)) ;
                    Z_cen = geom(3);      
                    
                    % Wenn in Profiel einer Ebene ligt 
                    if isnan(X_cen)||isinf(X_cen)
                        X_cen=mean(foil(:,1));
                    end
                    if isnan(Y_cen)||isinf(Y_cen)
                        Y_cen=mean(foil(:,2));
                    end
                    if isnan(Z_cen)||isinf(Z_cen)
                        Z_cen=mean(foil(:,3));
                    end
                    
                    XYZ_cen=[X_cen,Y_cen,Z_cen]; 
                    %plot3(X_cen,Y_cen,Z_cen,'*r');                
                    %plot3(foil(:,1),foil(:,2),foil(:,3));

                    % Liegt Rumpfprofiel im bereich des Flügelprofiel
                    if minX<mean(fusFoil(:,1)) && mean(fusFoil(:,1))<maxX
                        % Berechnung des Abstandes von jedem Flügelprofielpunkt
                        % zum Rumpfprofielpunkt sowie die auswahl ob ein
                        % Flügelprofielpunkt innerhalb des Rumpfprofiels liegt
                        % oder außerhalb
                        for iii=1:size(foil);
                            vec=[(fusFoil(:,1))-foil(iii,1),(fusFoil(:,2))-foil(iii,2),(fusFoil(:,3))-foil(iii,3)];
                            [deltaMin,deltaMinPos]=min(sqrt(sum(vec(:,2:3).^2,2))); % Abstand Fus zu Wing in y-z Ebene

                            l1=norm(mp(1,2:3)-fusFoil(deltaMinPos,2:3)); % länge von mittelpunkt zu fusPunkt
                            l2=norm(mp(1,2:3)-foil(iii,2:3));            % lange von mittelpunkt zu profil punt
                            if l1>l2
                                isinside=1;                            
                            end
                            deltaMinVec(1,iii)=deltaMin;
                        end
                        isinside2=1;
                        dirVec=mp-XYZ_cen; %V ector from Fuselage profile center to Airfoil area center
                        dirVecYZ=[0,dirVec(2),dirVec(3)];
                        dirVecNormYZ=dirVecYZ/norm(dirVecYZ);                    
                    end            
                end
                if isempty(deltaMinVec)
                    maxdist(i,1)=0;
                else
                    maxdist(i,1)=max(max(deltaMinVec));
                end
                if isinside==1 && isinside2==1
                    %plot3(fusFoil(:,1),fusFoil(:,2),fusFoil(:,3),'r');
                elseif isinside2==1
                    %plot3(fusFoil(:,1),fusFoil(:,2),fusFoil(:,3),'g');
                    inside=0;
                else
                    %plot3(fusFoil(:,1),fusFoil(:,2),fusFoil(:,3),'k');
                end
            end

            % Calc the moving Vector
            maxMaxDist=max(maxdist);
            maxMaxDistVec=dirVecNormYZ*maxMaxDist;
            if ~inside
                disp(['Not all points of Root wing are in Fuselage -- A new section will be added (wingNum: ',num2str(wingNum),')'])           

                % Copy Section definition 
                CPACSgeo.wings.component{wingNum,1}.sectionDef.point                =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.point(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.point);
                CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys             =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys);
                CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil              =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil);
                CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoilScaling       =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoilScaling(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoilScaling);
                CPACSgeo.wings.component{wingNum,1}.sectionDef.relAirfoil           =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.relAirfoil(1,:),CPACSgeo.wings.component{wingNum,1}.sectionDef.relAirfoil);
                CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionElementUIDs   =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionElementUIDs(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionElementUIDs);
                CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionUID           =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionUID(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionUID);
                CPACSgeo.wings.component{wingNum,1}.sectionDef.secPointRelInWing    =  cat(1,CPACSgeo.wings.component{wingNum,1}.sectionDef.secPointRelInWing(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.secPointRelInWing);

                % Copy segment definition
                CPACSgeo.wings.component{3,1}.segmentDef =  cat(1,CPACSgeo.wings.component{wingNum,1}.segmentDef(1,1),CPACSgeo.wings.component{wingNum,1}.segmentDef);

                % Define new  section
                CPACSgeo.wings.component{wingNum,1}.sectionDef.point{1,1}=CPACSgeo.wings.component{wingNum,1}.sectionDef.point{1,1}+maxMaxDistVec';
                CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{1,1}=[CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{1,1}(:,1)+maxMaxDistVec(1,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{1,1}(:,2)+maxMaxDistVec(1,2),CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{1,1}(:,3)+maxMaxDistVec(1,3)];
                CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionUID{1,1}=[CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionUID{1,1},'000'];
                %plot3(CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{1,1}(:,1),CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{1,1}(:,2),CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoil{1,1}(:,3),'b')
                
                % Define new Segment
                CPACSgeo.wings.component{wingNum,1}.segmentDef{1,1}.fromElementUID = CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionUID{1,1};
                CPACSgeo.wings.component{wingNum,1}.segmentDef{1,1}.toElementUID   = CPACSgeo.wings.component{wingNum,1}.segmentDef{2,1}.fromElementUID;  

            end
        catch
            warning('Unknown Error in inclWing.m');
        end
    end
    
%% xyz Positions

    xPos=[];yPos=[];zPos=[];
    for i=1:size(CPACSgeo.wings.component{wingNum,1}.sectionDef.point,1)
        posVec=CPACSgeo.wings.component{wingNum,1}.sectionDef.point{i,1};
        xPos(i,1)=posVec(1);        
        if i==1 && posVec(2)>0%(wingNum>1 becase of flying wings)
            yPos(i,1)=sig*(posVec(2)+0.01);
        else 
            yPos(i,1)=sig*(posVec(2));
        end        
        zPos(i,1)=posVec(3);
        % Round all position Values
        xPos=round(xPos*1000)/1000;
        yPos=round(yPos*1000)/1000;
        zPos=round(zPos*1000)/1000;
    end
    
%% Chord
 
    nelem=size(CPACSgeo.wings.component{wingNum,1}.sectionDef.sectionUID,1);  
    %Chord (2d array) C1  
    for i=1:nelem
        xAxe=[1;0;0];
        coorsSys=CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys{i,1};
        vec=coorsSys*xAxe;
        % Length of 3D Vector 
        chord(i,1)=sqrt(vec(1,1)^2+vec(2,1)^2+vec(3,1)^2); 
    end
        
%% Dihed  (is the dihedral of the airfoil)

    dihed=[];
    dihed(1,1)=0;
    for i=1:nelem        
        yAxe=[0;1;0];
        coorsSys=CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys{i,1};
        vec=coorsSys*yAxe;        
        % Angle of projectet Vector on y-z-Area (angle between Vector
        % and y-axe)
        dh=atan(vec(3)/vec(2)); 
        if sign(vec(2))==-1
            dh=pi-dh*sign(vec(2));
        end            
        if isnan(dh)
          dh=0;
        end
        dihed(i,1)=sig*dh;
        
        % Plot
        % x1=[xPos(i);yPos(i);zPos(i)];
        % x2=x1+[vec(1);vec(2);vec(3);]/norm(vec);
        % vec2=[x1,x2];
        % hold on
        % plot3(vec2(1,:),vec2(2,:),vec2(3,:))
        % plot3(x1(1),x1(2),x1(3),'o')
        % xlabel('X')
        % ylabel('Y')
        % axes equal
    end

%% Twist (is the dihedral of the airfoil)

    for ii=1:nelem 
        % Angle of projectet Vector on x-z-Area (angle between Vector
        % and x-axe)
        xAxe=[1;0;0];
        coorsSys=CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys{ii,1};
%         vec=(xAxe'*coorsSys)';
%         tw=abs(atan(vec(3)/vec(1)));
%         twist(ii,1)=-tw;
        
        vec=coorsSys*xAxe;
        tw=atan(vec(3)/vec(1));  
        twist(ii,1)=tw;  
    end

%% Airfoils

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Delete dubblel Points fom airfiol %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newAirfoil={};
    newAirfoil2={};
    for i=1:nelem        
        [newAirfoil{i,1}]=uniqueColumn(CPACSgeo.wings.component{wingNum,1}.sectionDef.relAirfoil{i,1});
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rotation the point order of the Airfoils %   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if sig==1
    %     rotateAirfoilOrder=0;
    % else
    %     rotateAirfoilOrder=1;
    % end
    for segNum=1:size(CPACSgeo.wings.component{wingNum,1}.segmentDef,1)
        
        % From Airfiol To Airfoil
        fromFoilNum=segNum;
        toFoilNum=segNum+1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % Arifoil rotation Order %
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % 1. If the angle between the normla  vector
        % of the first airfoil coordinate Sys. and of the airfoil is
        % gather than 90° then the point order of the
        % airfoil is inverse. This is only nessearry to
        % have the right conection order between the
        % airfoils 
        
        % 2. If the angle between the normla  vector
        % of the first airfoil coordinate Sys. and of the socond airfoil 
        % coordinate Sys. is gather than 90° then the point order of the
        % airfoil is inverse. This is only nessearry to
        % have the right conection order between the
        % airfoils
        
        % Nomal vector of the airfoil
        fromCoodSys = CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys{fromFoilNum,1}*sig;
        toCoodSys   = CPACSgeo.wings.component{wingNum,1}.sectionDef.coorsSys{toFoilNum,1}*sig;
        normVec=[0;1;0];
        normFrom=fromCoodSys*normVec;
        normTo=toCoodSys*normVec;      
        
        % Plot Vector       
        % x1=CPACSgeo.wings.component{wingNum,1}.sectionDef.point{fromFoilNum,1};
        % x2=x1+normFrom;
        % x3=[x1,x2];
        % hold on
        % plot3(x3(1,:),sig*x3(2,:),x3(3,:),'r')
        % plot3(x1(1),sig*x1(2),x1(3),'ro')
         
        % Define fromAirfoil and toAirfoil
        fromAirfoil=newAirfoil{fromFoilNum,1};
        if segNum==1
            
            % Check Rotation Order (1)
            fromAirfoil=newAirfoil{fromFoilNum,1};   
            foilDirctionFrom=cross(fromAirfoil(1,:),fromAirfoil(floor(size(fromAirfoil,1)/2),:))';       
            normFromf=foilDirctionFrom/norm(foilDirctionFrom);            
            angle=acos(dot(normFromf,normFrom)/(norm(normFromf)*norm(normFrom)));
            if angle>pi/2             
                rotateAirfoilOrder=0;                     
            else
                rotateAirfoilOrder=1; 
            end
            
            % Roate the point order of toAirfoil
            if rotateAirfoilOrder==1
                fromAirfoil(:,1)=[rot90(fromAirfoil(:,1)')];
                fromAirfoil(:,2)=[rot90(fromAirfoil(:,2)')];
                fromAirfoil(:,3)=[rot90(fromAirfoil(:,3)')];
                x1=CPACSgeo.wings.component{wingNum,1}.sectionDef.point{fromFoilNum,1};
                %plot3(x1(1),sig*x1(2),x1(3),'r*')  
            end 
                   
            %newAirfoil2{segNum,1}=floor(fromAirfoil*10000)/10000;
            newAirfoil2{segNum,1}=fromAirfoil;
        end
        toAirfoil=newAirfoil{toFoilNum,1};         
        
        % Check Rotation Order (1)
        toAirfoil=newAirfoil{toFoilNum,1}; 
        foilDirctionTo=cross(toAirfoil(1,:),toAirfoil(floor(size(toAirfoil,1)/2),:))';        
        normTof=foilDirctionTo/norm(foilDirctionTo);
        angle=acos(dot(normFromf,normFrom)/(norm(normFromf)*norm(normFrom)));
        if angle>pi/2             
            rotateAirfoilOrder=0;                     
        else
            rotateAirfoilOrder=1; 
        end        
        
        % Decide to rotate the order of the airfoil because of the
        % differ of form coord. Sys. and to coord. Sys. (2)
        angle=acos(dot(normTo,normFrom)/(norm(normTo)*norm(normFrom)));
        if angle>pi/2             
            %Toggle
            if rotateAirfoilOrder==1
                rotateAirfoilOrder=0;
            elseif rotateAirfoilOrder==0
                rotateAirfoilOrder=1;
            end            
        end
      
        % Roate the point order of fromAirfoil
        if rotateAirfoilOrder==1
            toAirfoil(:,1)=[rot90(toAirfoil(:,1)')];
            toAirfoil(:,2)=[rot90(toAirfoil(:,2)')];
            toAirfoil(:,3)=[rot90(toAirfoil(:,3)')];
            x1=CPACSgeo.wings.component{wingNum,1}.sectionDef.point{toFoilNum,1};
            %plot3(x1(1),sig*x1(2),x1(3),'r*')  
        end
        %newAirfoil2{segNum+1,1}=floor(toAirfoil*10000)/10000;  
        newAirfoil2{segNum+1,1}=toAirfoil;
                
    end
    newAirfoil=newAirfoil2;
       
    % Change the number of points 
    numOfPoints=40;    
    newAirfoil=airfoilInterp(newAirfoil,numOfPoints);
    
%     for i=1:1:size(newAirfoil,1)         
%         figure(i)
%         hold on
%         plot(newAirfoil{i,1}(:,1)*chord(i)+xPos(i),newAirfoil{i,1}(:,3)*chord(i)+zPos(i),'b')
%         plot(newAirfoil{i,1}(:,1)*chord(i)+xPos(i),newAirfoil{i,1}(:,3)*chord(i)+zPos(i),'b*')
%         axis equal
%     end   
%     
%     for i=1:1:size(newAirfoil,1)
%         hold on
%         n=size(newAirfoil{i,1},1);
%         plot3(newAirfoil{i,1}(floor(n/2):end,1)*chord(i)+xPos(i),newAirfoil{i,1}(floor(n/2):end,2)*chord(i)+yPos(i),newAirfoil{i,1}(floor(n/2):end,3)*chord(i)+zPos(i),'b')
%         plot3(newAirfoil{i,1}(1:floor(n/2),1)*chord(i)+xPos(i),newAirfoil{i,1}(1:floor(n/2),2)*chord(i)+yPos(i),newAirfoil{i,1}(1:floor(n/2),3)*chord(i)+zPos(i),'r')      
%         axis equal
%     end
%     for i=1:1:size(newAirfoil,1)         
%         figure(i)
%         hold on
%         n=size(newAirfoil{i,1},1);
%         plot(newAirfoil{i,1}(floor(n/2):end,1)*chord(i)+xPos(i),newAirfoil{i,1}(floor(n/2):end,3)*chord(i)+zPos(i),'b')
%         plot(newAirfoil{i,1}(1:floor(n/2),1)*chord(i)+xPos(i),newAirfoil{i,1}(1:floor(n/2),3)*chord(i)+zPos(i),'r')
%         for ii=1:size(newAirfoil{i,1},1)
%             text(newAirfoil{i,1}(ii,1)*chord(i)+xPos(i) , newAirfoil{i,1}(ii,3)*chord(i)+zPos(i) ,num2str(ii))
%         end
%         axis equal
%     end


       
    % Test: Change the point order of the whole wing (For the Boxwing Nessearry)
    % for segNum=1:size(CPACSgeo.wings.component{wingNum,1}.segmentDef,1)+1
    %     newAirfoil{segNum,1}(:,1)=[rot90(newAirfoil{segNum,1}(:,1)')];
    %     newAirfoil{segNum,1}(:,2)=[rot90(newAirfoil{segNum,1}(:,2)')];
    %     newAirfoil{segNum,1}(:,3)=[rot90(newAirfoil{segNum,1}(:,3)')];
    % end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Scaling and rotation of the airfoils %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i=1:nelem        
        for ii=1:size(newAirfoil{i,1},1)
            [rotAirfoil{i,1}(ii,:)]=(CPACSgeo.wings.component{wingNum,1}.sectionDef.airfoilScaling{i,1}.*newAirfoil{i,1}(ii,:)')'; 
        end
    end
    newAirfoil= rotAirfoil;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % rotate airfoil (for incuding a twist) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:1:size(newAirfoil,1)
        currAirfiol=newAirfoil{i,1};

        % Rotation point
        p=[0,0,0];
        % Rotation Vector
        r=-[0 twist(i,1)*180/pi 0];%+absRot;    

        onesVec=ones(size(newAirfoil{i,1},1),1);

        % Discplacement of airfoil
        currAirfiol=currAirfiol-[p(1)*onesVec,p(2)*onesVec,p(3)*onesVec];

        % Transformation Matrix
        [transMat] = eulerTrans(r(1),r(2),r(3),'xyz');

        % Rotation of airfoil and re-displacement
        rotAirfoil{i,1}=[transMat*currAirfiol']'+[p(1)*onesVec,p(2)*onesVec,p(3)*onesVec];
 
        
        % plot3(newAirfoil{i,1}(:,1),newAirfoil{i,1}(:,2)+i,newAirfoil{i,1}(:,3))
        % hold on
        % plot3(rotAirfoil{i,1}(:,1),rotAirfoil{i,1}(:,2)+i,rotAirfoil{i,1}(:,3),'r')
        % axis equal
    end    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write a Chracter fiel of the Points %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    airfoils={};
    for i=1:nelem  
        if sym==1;
            numAirfoil=[rotAirfoil{i,1}(:,1),rotAirfoil{i,1}(:,3)];
        else        
            numAirfoil=[rot90(rotAirfoil{i,1}(:,1)'),rot90(rotAirfoil{i,1}(:,3)')];
        end
        foilstr=char(' ');
        for ii=1:1:size(numAirfoil,1)
            foilstr=[foilstr,num2str(numAirfoil(ii,1)),' ',num2str(numAirfoil(ii,2)),'   '];
        end    
        airfoils{i,1}(1,:)=char(foilstr);
    end
   
%% Gen new file
%% Counter
 
    try 
        count=size(NewS.Assembly.WingSkeleton,2)+1;
    catch
        count=1;
    end

%% Sttings

    % WingSelektion Settings   
    NewS.Assembly.WingSkeleton{1,count}.Attributes.name=[CPACSgeo.wings.component{wingNum,1}.name];%,num2str(sym)];
    NewS.Assembly.WingSkeleton{1,count}.Attributes.origin=' 0 0 0 ';
    NewS.Assembly.WingSkeleton{1,count}.Attributes.rotation=' 0 0 0 ';
    if yPos(1,1)==0 && dihed(1,1)<pi/2 && autosym==1
            NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='autosym';
    end

    % Cap Settings
    NewS.Assembly.WingSkeleton{1,count}.Cap{1,1}.Attributes.height='0.8';
    NewS.Assembly.WingSkeleton{1,count}.Cap{1,1}.Attributes.shape='LongCap';
    NewS.Assembly.WingSkeleton{1,count}.Cap{1,1}.Attributes.side='north';
    
    NewS.Assembly.WingSkeleton{1,count}.Cap{1,2}.Attributes.height='0.8';
    NewS.Assembly.WingSkeleton{1,count}.Cap{1,2}.Attributes.shape='LongCap';
    NewS.Assembly.WingSkeleton{1,count}.Cap{1,2}.Attributes.side='south';

    %WingCriterion Settings (for Mesh definition)
    %NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.defaults='false'; %Use default Values
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.defaults=option.sumo.wingMeshDefault;
    
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.lerfactor='0.3333'; %1/leading edge refinement
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.terfactor='0.25';%1/trailing edge refinement
    
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.maxlen='0.8'; % Minimum Edge Length
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.minlen='0.01';% Minimum Edge Length
    
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.maxphi='40'; % Normal Diferences
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.maxstretch='20';  
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.nvmax='1073741824';
   
    NewS.Assembly.WingSkeleton{1,count}.WingCriterion{1,1}.Attributes.xcoarse='false'; %Use Hybrid mesh generation algothm
    
    % NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Scale             = s.Assembly.WingSkeleton.WingCriterion.Scale;
    % NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Breaks            = s.Assembly.WingSkeleton.WingCriterion.Breaks;
    % NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Kinks             = s.Assembly.WingSkeleton.WingCriterion.Kinks;
    % NewS.Assembly.WingSkeleton{1,count}.WingCriterion.KinkTangents      = s.Assembly.WingSkeleton.WingCriterion.KinkTangents;
    % NewS.Assembly.WingSkeleton{1,count}.WingCriterion.Attributes        =
    % s.Assembly.WingSkeleton.WingCriterion.Attributes;


%% Generate the new struct

    % Select the order of Sections (from root to tip or otherwise)
    count2=0;
    if autosym==1
        nn=size(xPos,1):-1:1;  
    else
        nn=1:size(xPos,1);
    end
    
    for i=nn 
        count2=count2+1;

        % aifoil name
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Attributes.airfoil='airfoilName';
        
        % WingSectionName
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Attributes.name=['WingSectionName',num2str(i)];

        % Position of section
        center=num2str([xPos(i,1),yPos(i,1),zPos(i,1)]);% [ledaing edge position, y pos,zPos]
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Attributes.center=center; 

        % airfoil
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Text= airfoils{i,1}(1,:);

        % Chord
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Attributes.chord=1;%num2str(chord(i,1));

        % Dihedral (is the dihedral of the airfoil)
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Attributes.dihedral=num2str(dihed(i,1));

        % Twist (arround the leading edge --> currently not neded, above there is a rotationg of airfoils)
        % NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.twist=num2str(twist(i,1));
        % NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.twist=num2str(absRot(1,1))
        % NewS.Assembly.WingSkeleton{1,count}.WingSection{1,i}.Attributes.yaw=num2str(0/180*pi);

        % Other Parameter
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Attributes.napprox='20';% Edit wing section (-1 --> Interpolate coordinates ; x<0 -->Least-squares fit (x =number of Points)
        NewS.Assembly.WingSkeleton{1,count}.WingSection{1,count2}.Attributes.vbreak='true';    
    end
    
     if yPos(1,1)==0 && dihed(1,1)<pi/2 && autosym==1
            break
     end
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% dath horses
%     % Set Basic settings
%     if wingNum==3
%         %NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='detectwing
%         %let,';
% 
%         % Extent the wing (only for vertical wings dh=90°)
%         x1=xPos(1,1);
%         x2=xPos(2,1);
%         k1=sqrt(yPos(1,1)^2+zPos(1,1)^2);
%         k2=sqrt(yPos(2,1)^2+zPos(2,1)^2);
%         b=(k1-x1/x2*k2)/(1-x1/x2);
%         m=(k1-b)/x1;
%         k=0;
%         x=(k-b)/m;
%         y=0;
%         z=k;
% 
%         xPos=[x;xPos];
%         yPos=[sig*y;yPos];
%         zPos=[z;zPos];
% 
%         c1=chord(1,1);
%         c2=chord(2,1);    
%         c=(c1-c2)/(k2-k1)*(k2-k)+c2;
%         chord=[c;chord];
% 
%         twist=[twist(1,1);twist];
%         dihed=[dihed(1,1);dihed];    
%         airfoils=[airfoils(1,1);airfoils];   
% 
%     else
%    
% %         NewS.Assembly.WingSkeleton{1,count}.Attributes.flags='detectwinglet,';
%     end