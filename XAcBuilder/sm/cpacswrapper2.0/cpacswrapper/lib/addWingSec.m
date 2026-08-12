function [aircraft]=addWingSec(aircraft,wingNums,y_new,minSecSpan)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Add wing section in wing                                              %
%   The segments can be split and flap locations are not more depentent of
%   planform definition.
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0b                                                  %
% LastModified:     2011-11-18 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Use external Function:                                                  %
%       -                                                                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example Imput                                                           %
% wingNums=[1,1,2,2]; Insert the wingnumber which should be change. 
% y_new=[2,5.2,1,3]; Insert new section position
% This example means there will be insert two new section in the first 
% wing and at the position 2 meter and 5.2 meter and the same procedure in
% the second wing.
%       
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 ToDO #                                  %
%   - anpassung des maximalen Klappenausssachlag (bislang für alle Klappen
%     konstant)
%   - anpassung der klappeneigenschaften noch nicht individuell
%   - Interpolation der Profiele
%   
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Vernachlässigungen/Vereinfachunegen                       %
%   - foils werden nicht interpoliert
%   - Pannel größe nx, ny nur linar angepasset
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input

%Max Spannweite/2
% sum(aircraft.wings.b,2)

% Sollen die Klappen neu definiert werden 
% ja=1               (Klappen werden nur dort definiert wo sie auch eingebaut werden)
% nein=0             (Klappen eigenschaften werden werden von den
%                     geschittenen Sectionen übernommen)
newFldef=0;
% Im Fall 1:
% Klappen werden von der erste bis zur zweiten, dritten bis vierten, usw. 
% neuen section eingebaut. Ist die Anzahl der neuen sektionen in einem wing 
% ungrade so werden dem letzten schnitt keine Klappeneigenschaften
% zugeortnet.

% Settings of spanwise pannel distribution
n_norm=0.5; %pannel per meter

wing_mod=aircraft.wings;

%% Generally

% Neuer Spannweitenvektor
b_abs=0;
for i=1:length(aircraft.wings.nelem)    
    % Absolute Spannweiten
    for ii=1:aircraft.wings.nelem(1,i)%length(aircraft.wings.b(i,:))
        b_abs(i,ii+1)=sum(aircraft.wings.b(i,1:ii));
    end
end

% Check ob angegebene sectionen im flügel liegen
for i=1:length(y_new)
    if y_new(1,i)>max(b_abs(wingNums(1,i),:))
        disp('------------------') 
        disp('maximum spans are:') 
        spans=(sum(aircraft.wings.b,2));
        error([num2str(i),'. new section is out of wing'])    
    end
end

% Check ob input richtig
if size(wingNums,2)~=size(y_new,2)
    error('Input is wrong')
end
if max(wingNums)>size(aircraft.wings.nelem,2)
    error('Input is wrong')
end


% Check in ob section Schon vergeben? wenn ja dann löschen und merken
n=0;
y_new_hold=y_new;
wingNums_hold=wingNums;
y_newCorr=[];
wingNums_new=[];
for i=1:length(y_new)
    if isempty(find(b_abs(wingNums(1,i),:)==y_new(1,i)))
        n=n+1;
        y_newCorr(1,n)=y_new(1,i);
        wingNums_new(1,n) =wingNums(1,i);
    end
end
y_new=y_newCorr;
wingNums=wingNums_new;

if ~isempty(y_new)

    % Delete new sections with a smal distance to current sections
    % minSecSpan=0.2; %minimum difference betwen sections
    n=0;
    % find close sections
    pos=[];
    for i=1:size(unique(wingNums),2)
        uni=unique(wingNums);   
        wingNum=uni;
        for ii=find(wingNums==uni(1,i))
            for iii=1:aircraft.wings.nelem(1,wingNum)
                delt=abs(b_abs(wingNums(1,ii),iii)-y_new(1,ii));
                if delt<minSecSpan
                   n=n+1;
                   pos(1,n)=ii; 
                end                
            end
        end    
    end
    % delete close sections
    n=0;
    for i=1:size(wingNums,2)
        if isempty(find(pos==i))
            n=n+1;
            y_newCorr2(1,n) = y_new(1,i);
            wingNums_new2(1,n) =wingNums(1,i);
        end
    end
    y_new=y_newCorr2;
    %wingNums=wingNums_new2


    % delete new sections with a smal distance to each other
    n=0;
    pos=[];
    % find close sections
    for i=1:size(unique(wingNums_new2),2)
        uni=unique(wingNums_new2);    
        for ii=find(wingNums_new2==uni(1,i))
            vec=setdiff(find(wingNums_new2==uni(1,i)),ii);
            for iii=vec
                delt=abs(y_new(1,iii)-y_new(1,ii));
                if delt<minSecSpan
                   n=n+1;
                   pos(1,n)=ii; 
                end                
            end
        end    
    end

    % delete sections and make a new one between
    n=0;
    h=0;
    for i=1:1:size(wingNums_new2,2)
        if isempty(find(pos==i))
            n=n+1;
            y_newCorr3(1,n) = y_new(1,i);
            %wingNums_new2(1,n) =wingNums(1,i);
            h=0;
        elseif h==0
            n=n+1;
            y_newCorr3(1,n) = (y_new(1,i)+y_new(1,i+1))/2;
            %wingNums_new2(1,n) =wingNums(1,i);
            h=1;
        else
            h=0;
        end
    end
    y_new=y_newCorr3;
    %wingNums=wingNums_new2


    % Check in welcher section die neuen sectionen liegen
    for i=1:length(y_new)
        for ii=1:length(aircraft.wings.b)
            if b_abs(wingNums(1,i),ii+1)>=y_new(1,i)
                y_new_sec(1,i)=ii;
                break
            end
        end
    end

%% Chord
% Sectionen in den flügel integrieen

    nelem=aircraft.wings.nelem;
    c=aircraft.wings.c;
    n=zeros(max(wingNums),1);

    for i=1:length(y_new)
        % Nummierung
        nelem(1,wingNums(1,i))=nelem(1,wingNums(1,i))+1;

        % Chord abhänig von Y
        c_new=(1-(y_new(1,i)-(b_abs(wingNums(1,i),y_new_sec(1,i)+1)-aircraft.wings.b(wingNums(1,i),y_new_sec(1,i))))/aircraft.wings.b(wingNums(1,i),y_new_sec(1,i)))*...
              (aircraft.wings.c(wingNums(1,i),y_new_sec(1,i))-aircraft.wings.c(wingNums(1,i),y_new_sec(1,i)+1))+...
               aircraft.wings.c(wingNums(1,i),y_new_sec(1,i)+1);
        % Chord Einbauen
        c_st=cat(2,c(wingNums(1,i),1:y_new_sec(1,i)+ n(wingNums(1,i),1)),c_new,c(wingNums(1,i),y_new_sec(1,i)+1+ n(wingNums(1,i),1):end)); %*
        if length(c_st)>length(c(wingNums(1,i),:))
            c(1:size(c,1),length(c(wingNums(1,i),:))+1:length(c_st))=0;
        end
        c(wingNums(1,i),:)=c_st;  

        % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;

    end

    % Korrigiern von C 
    c=c(:,1:max(nelem)+1);

    %Save
    wing_mod.c=c;

%% Span

    b=aircraft.wings.b;

    for i=1:length(y_new)   

        for ii=1:length(nelem)    
        % Absolute Spannweiten (ik update)
            for iii=1:length(b(ii,:))
                b_abs_st(ii,iii)=sum(b(ii,1:iii));
            end
        end

        % Check in welcher segment die neuen sectionen liegen (ik update)
        for ii=1:length(y_new)
            for iii=1:length(b)
                if b_abs_st(wingNums(1,ii),iii)>=y_new(1,ii)
                    y_new_sec_st(1,ii)=iii;
                    break
                end
            end
        end

        % Spnnweite wird unterteilt
        b_new(1,1)= y_new(1,i)-(b_abs_st(wingNums(1,i),y_new_sec_st(1,i))-...
                    b(wingNums(1,i),y_new_sec_st(1,i)));
        b_new(1,2)= b(wingNums(1,i),y_new_sec_st(1,i))-b_new(1,1);

        % Neuer Spannweitenvektor
        if y_new_sec_st(1,i)==1;
            b_st=cat(2,b_new,b(wingNums(1,i),y_new_sec_st(1,i)+1:end)); 
        else
            b_st=cat(2,b(wingNums(1,i),1:y_new_sec_st(1,i)-1),...
                       b_new,...
                       b(wingNums(1,i),y_new_sec_st(1,i)+1:end)); 
        end

        % Restliche Matix mit Nullen Auffüllen und neuen Spannweitenvektor
        % zuortnen
        if length(b_st)>length(b(wingNums(1,i),:))
            b(1:size(c,1),length(b(wingNums(1,i),:))+1:length(b_st))=0;
        end
        b(wingNums(1,i),:)=b_st;  

    end

    % Überflüssige Nullen werden Abgeschitten
    b=b(:,1:max(nelem));

    % Section Nummern werden erneut upgedated (siehe oben)
    for ii=1:length(nelem)       
        for iii=1:length(b(ii,:))
            b_abs_st(ii,iii)=sum(b(ii,1:iii));
        end
    end
    for ii=1:length(y_new)
        for iii=1:length(b)
            if b_abs_st(wingNums(1,ii),iii)>y_new(1,ii)
                y_new_sec_st(1,ii)=iii;
                break
            end
        end
    end

    %Save
    wing_mod.b=b;

%% Taperratio

    warning off
    for i=1:size(c,1)
        for ii=1:size(c,2)-1
            T(i,ii)=c(i,ii+1)/c(i,ii);
            if isnan( T(i,ii))
               T(i,ii)=0;
            end
        end
    end
    warning on
    %Save
    wing_mod.T=T;

%% Sweep

    n=zeros(max(wingNums),1);
    SW=aircraft.wings.SW;

    for i=1:size(y_new,2)    

        % Sweep einbauen mit CAT
        if y_new_sec(1,i)==1
            SW_st=cat(2,SW(wingNums(1,i),y_new_sec(1,i)),...
                   SW(wingNums(1,i),y_new_sec(1,i):end));
        else
            SW_st=cat(2,SW(wingNums(1,i),1:y_new_sec(1,i)-1+n(wingNums(1,i),1)),...
                   SW(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1)),...
                   SW(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1):end));
        end   

        % Vektorlänge korrigieren   
        if length(SW_st)>length(SW(wingNums(1,i),:))
            SW(1:size(SW,1),length(SW(wingNums(1,i),:))+1:length(SW_st))=0;
        end
        SW(wingNums(1,i),:)=SW_st;      

        % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;    

    end

    % Korrigiern von SW, überflüssige Nullen werden Abgeschitten
    SW=SW(:,1:max(nelem));

    %Save
    wing_mod.SW=SW;

%% Sweep25

    n=zeros(max(wingNums),1);
    SW25=aircraft.wings.SW25;

    for i=1:size(y_new,2)    

        % SW25eep einbauen mit CAT
        if y_new_sec(1,i)==1
            SW25_st=cat(2,SW25(wingNums(1,i),y_new_sec(1,i)),...
                   SW25(wingNums(1,i),y_new_sec(1,i):end));
        else
            SW25_st=cat(2,SW25(wingNums(1,i),1:y_new_sec(1,i)-1+n(wingNums(1,i),1)),...
                   SW25(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1)),...
                   SW25(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1):end));
        end   

        % Vektorlänge korrigieren   
        if length(SW25_st)>length(SW25(wingNums(1,i),:))
            SW25(1:size(SW25,1),length(SW25(wingNums(1,i),:))+1:length(SW25_st))=0;
        end
        SW25(wingNums(1,i),:)=SW25_st;  

         % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;

    end

    % Korrigiern von SW25 
    SW25=SW25(:,1:max(nelem));
    % Save
    wing_mod.SW25=SW25;

%% Sweep LE

    n=zeros(max(wingNums),1);
    SWle=aircraft.wings.SWle;

    for i=1:size(y_new,2)    

        % SWleeep einbauen mit CAT
        if y_new_sec(1,i)==1
            SWle_st=cat(2,SWle(wingNums(1,i),y_new_sec(1,i)),...
                   SWle(wingNums(1,i),y_new_sec(1,i):end));
        else
            SWle_st=cat(2,SWle(wingNums(1,i),1:y_new_sec(1,i)-1+n(wingNums(1,i),1)),...
                   SWle(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1)),...
                   SWle(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1):end));
        end   

        % Vektorlänge korrigieren   
        if length(SWle_st)>length(SWle(wingNums(1,i),:))
            SWle(1:size(SWle,1),length(SWle(wingNums(1,i),:))+1:length(SWle_st))=0;
        end
        SWle(wingNums(1,i),:)=SWle_st;  

        % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;

    end

    % Korrigiern von SWle 
    SWle=SWle(:,1:max(nelem));

    wing_mod.SWle=SWle;

%% Sweep TE

    n=zeros(max(wingNums),1);
    SWte=aircraft.wings.SWte;

    for i=1:size(y_new,2)    

        % SWteeep einbauen mit CAT
        if y_new_sec(1,i)==1
            SWte_st=cat(2,SWte(wingNums(1,i),y_new_sec(1,i)),...
                   SWte(wingNums(1,i),y_new_sec(1,i):end));
        else
           SWte_st=cat(2,SWte(wingNums(1,i),1:y_new_sec(1,i)-1+n(wingNums(1,i),1)),...
                   SWte(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1)),...
                   SWte(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1):end));
        end   

        % Vektorlänge korrigieren   
        if length(SWte_st)>length(SWte(wingNums(1,i),:))
            SWte(1:size(SWte,1),length(SWte(wingNums(1,i),:))+1:length(SWte_st))=0;
        end
        SWte(wingNums(1,i),:)=SWte_st;  

        % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;

    end

    % Korrigiern von SWte 
    SWte=SWte(:,1:max(nelem));
    %Save
    wing_mod.SWte=SWte;

%% Dihed

    n=zeros(max(wingNums),1);
    dihed=aircraft.wings.dihed;

    for i=1:size(y_new,2)    

        % Dihed einbauen mit CAT
        if y_new_sec(1,i)==1
            dihed_st=cat(2,dihed(wingNums(1,i),y_new_sec(1,i)),...
                   dihed(wingNums(1,i),y_new_sec(1,i):end));
        else
            dihed_st=cat(2,dihed(wingNums(1,i),1:y_new_sec(1,i)-1+n(wingNums(1,i),1)),...
                   dihed(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1)),...
                   dihed(wingNums(1,i),y_new_sec(1,i)+n(wingNums(1,i),1):end));
        end   

        % Vektorlänge korrigieren   
        if length(dihed_st)>length(dihed(wingNums(1,i),:))
            dihed(1:size(dihed,1),size(dihed(wingNums(1,i),:),2)+1:length(dihed_st))=0;
        end
        dihed(wingNums(1,i),:)=dihed_st;  

        % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;

    end

    % Korrigiern von dihed 
    dihed=dihed(:,1:max(nelem));
    %Save
    wing_mod.dihed=dihed;

%% Twist

    TW=aircraft.wings.TW;

    nelem=aircraft.wings.nelem;
    n=zeros(max(wingNums),1);

    for i=1:length(y_new)
        % Nummierung
        nelem(1,wingNums(1,i))=nelem(1,wingNums(1,i))+1;

        % Twist abhänig von Y
        TW_new=(1-  (  y_new(1,i)  -  (b_abs(wingNums(1,i),y_new_sec(1,i)+1) - aircraft.wings.b(wingNums(1,i),y_new_sec(1,i)))) / aircraft.wings.b(wingNums(1,i),y_new_sec(1,i)))*... % position in Prozent
               (aircraft.wings.TW(wingNums(1,i),y_new_sec(1,i),1) - aircraft.wings.TW(wingNums(1,i),y_new_sec(1,i),2))+...
               (aircraft.wings.TW(wingNums(1,i),y_new_sec(1,i),2));

        % Twist Einbauen    
        TW_st=cat(2,TW(wingNums(1,i),1:y_new_sec(1,i)+ n(wingNums(1,i),1)) , TW_new , TW(wingNums(1,i),y_new_sec(1,i)+1+n(wingNums(1,i),1):end,1), TW(wingNums(1,i),end,2) );

        if (length(TW_st)-1)>length(TW(wingNums(1,i),:,1))
            TW(1:size(TW,1),length(TW(wingNums(1,i),:,1))+1:length(TW_st)-1,1)=0;
            TW(1:size(TW,1),length(TW(wingNums(1,i),:,2))+1:length(TW_st)-1,2)=0;
        end
        TW(wingNums(1,i),:,1)=TW_st(1,1:end-1);  
        TW(wingNums(1,i),:,2)=TW_st(1,2:end);  

        % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;
    end

    % Korrigiern von C 
    TW=TW(:,1:max(nelem),:);

    % Note:
    % TW(:,:,1)=[a1,b1;a2,b2] %innen 
    % TW(:,:,1)=[b1,c1;b2,c2] %außen

    %Save
    wing_mod.TW=TW;

%% Airfoil
% Vereinfacht ohne interpolirtes Profil (es wird immer das innere Profil
% verwendet) #

    foil=aircraft.wings.foil;

    nelem=aircraft.wings.nelem;
    n=zeros(max(wingNums),1);

    for i=1:length(y_new)
        % Nummierung
        nelem(1,wingNums(1,i))=nelem(1,wingNums(1,i))+1;

        % foilist abhänig von Y
        foil_new=foil(wingNums(1,i),y_new_sec(1,i),1);
        %airfoil_new=aircraft.airfoil(wingNums(1,i),y_new_sec(1,i),1)

        % foilist Einbauen 
        nf=0;
        for ii=1:length(foil(wingNums(1,i),:,2)) 
            if isempty(foil{wingNums(1,i),ii,2})
                break
            end
            nf=nf+1;
        end

        foil_st=cat(2,foil(wingNums(1,i),1:y_new_sec(1,i)+ n(wingNums(1,i),1)) , foil_new , foil(wingNums(1,i),y_new_sec(1,i)+1+n(wingNums(1,i),1):nf,1), foil(wingNums(1,i),nf,2) );

        if (length(foil_st)-1)>length(foil(wingNums(1,i),:,1))
            foil(1:size(foil,1),length(foil(wingNums(1,i),:,1))+1:length(foil_st)-1,1)={[]};
            foil(1:size(foil,1),length(foil(wingNums(1,i),:,2))+1:length(foil_st)-1,2)={[]};
        end
        foil(wingNums(1,i),1:length(foil_st)-1,1)=foil_st(1,1:end-1);  
        foil(wingNums(1,i),1:length(foil_st)-1,2)=foil_st(1,2:end);  

        % Zählen der eingesetzten Sektionen in einem Flügel
        n(wingNums(1,i),1)=n(wingNums(1,i),1)+1;
    end

    % Korrigiern von C 
    foil=foil(:,1:max(nelem),:);

    % Note:
    % foil(:,:,1)=[a1,b1;a2,b2] %innen 
    % foil(:,:,1)=[b1,c1;b2,c2] %außen

    %Save
    wing_mod.foil=foil;

%% Flapped

    flapped=aircraft.wings.flapped;

    % Klappeneigenschaften werden von der geschittenen section übernommen
    for i=1:size(y_new,2)    

        % Flapped in Matrix einbauen mit CAT                                   
        if y_new_sec(1,i)==1
            flapped_st=cat(2,flapped(wingNums(1,i),y_new_sec(1,i)),...
                   flapped(wingNums(1,i),y_new_sec(1,i):end));
        else
            flapped_st=cat(2,flapped(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   flapped(wingNums(1,i),y_new_sec(1,i)),...
                   flapped(wingNums(1,i),y_new_sec(1,i):end));
        end 

        % Vektorlänge korrigieren   
        if length(flapped_st)>length(flapped(wingNums(1,i),:))
            flapped(1:size(flapped,1),length(flapped(wingNums(1,i),:))+1:length(flapped_st))=0;
        end
        flapped(wingNums(1,i),:)=flapped_st;  

    end

    if newFldef==1;% Klappe in nur definierten sections 
        for ii=1:length(nelem)    
        % Absolute Spannweiten (ik update)
            for iii=1:length(b(ii,:))
                b_abs_st(ii,iii)=sum(b(ii,1:iii));
            end
        end
        % vorherige Klappen wedenen daktiviert
        wing_mod.flapped(wingNums(1,i),:)    = zeros(size(wing_mod.flapped(wingNums(1,i),:)));
        for i=2:2:size(y_new_hold,2)
            flapPosN=[find(b_abs_st(wingNums(1,i),:)==y_new_hold(1,i-1)),find(b_abs_st(wingNums(1,i),:)==y_new_hold(1,i))];
            flapPos=min(flapPosN):max(flapPosN);
            flapped(wingNums(1,i),flapPos)=1;    
        end
    end

    % Korrigiern von flapped 
    flapped=flapped(:,1:max(nelem));

    %Save
    wing_mod.flapped=flapped;

%% fc

    fc=aircraft.wings.fc;

    for i=1:size(y_new,2)    

        % Flapped in Matrix einbauen mit CAT
        if y_new_sec(1,i)==1
            fc_st=cat(2,fc(wingNums(1,i),y_new_sec(1,i)),...
                   fc(wingNums(1,i),y_new_sec(1,i):end));
        else
            fc_st=cat(2,fc(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   fc(wingNums(1,i),y_new_sec(1,i)),...
                   fc(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(fc_st)>length(fc(wingNums(1,i),:))
            fc(1:size(fc,1),length(fc(wingNums(1,i),:))+1:length(fc_st))=0;
        end
        fc(wingNums(1,i),:)=fc_st;  

    end

    % Korrigiern von fc 
    fc=fc(:,1:max(nelem));

    %Save
    wing_mod.fc=fc;

%% fsym

    fsym=aircraft.wings.fsym;

    for i=1:size(y_new,2)    

        % Flapped in Matrix einbauen mit CAT                                   % KlappenSymmetrie in sections definierten #
        if y_new_sec(1,i)==1
            fsym_st=cat(2,fsym(wingNums(1,i),y_new_sec(1,i)),...
                   fsym(wingNums(1,i),y_new_sec(1,i):end));
        else
            fsym_st=cat(2,fsym(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   fsym(wingNums(1,i),y_new_sec(1,i)),...
                   fsym(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(fsym_st)>length(fsym(wingNums(1,i),:))
            fsym(1:size(fsym,1),length(fsym(wingNums(1,i),:))+1:length(fsym_st))=0;
        end
        fsym(wingNums(1,i),:)=fsym_st;  

    end

    % Korrigiern von fsym 
    fsym=fsym(:,1:max(nelem));

    %Save
    wing_mod.fsym=fsym;

%% Flap Vector

    flap_vector=aircraft.wings.flap_vector;

    for i=1:size(y_new,2)    

        % Flapped in Matrix einbauen mit CAT
        if y_new_sec(1,i)==1
            flap_vector_st=cat(2,flap_vector(wingNums(1,i),y_new_sec(1,i)),...
                   flap_vector(wingNums(1,i),y_new_sec(1,i):end));
        else
            flap_vector_st=cat(2,flap_vector(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   flap_vector(wingNums(1,i),y_new_sec(1,i)),...
                   flap_vector(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(flap_vector_st)>length(flap_vector(wingNums(1,i),:))
            flap_vector(1:size(flap_vector,1),length(flap_vector(wingNums(1,i),:))+1:length(flap_vector_st))=0;
        end
        flap_vector(wingNums(1,i),:)=flap_vector_st;  

    end

    % Korrigiern von flap_vector 
    flap_vector=flap_vector(:,1:max(nelem));

    %Save
    wing_mod.flap_vector=flap_vector;

%% fnx

    fnx=aircraft.wings.fnx;

    for i=1:size(y_new,2)    

        % Flapped in Matrix einbauen mit CAT
        if y_new_sec(1,i)==1
            fnx_st=cat(2,fnx(wingNums(1,i),y_new_sec(1,i)),...
                   fnx(wingNums(1,i),y_new_sec(1,i):end));
        else
            fnx_st=cat(2,fnx(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   fnx(wingNums(1,i),y_new_sec(1,i)),...
                   fnx(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(fnx_st)>length(fnx(wingNums(1,i),:))
            fnx(1:size(fnx,1),length(fnx(wingNums(1,i),:))+1:length(fnx_st))=0;
        end
        fnx(wingNums(1,i),:)=fnx_st;  

    end

    % Korrigiern von fnx 
    fnx=fnx(:,1:max(nelem));

    %Save
    wing_mod.fnx=fnx;

%% ny

    ny=aircraft.wings.ny;

    for i=1:size(y_new,2)    

        % Ny in Matrix einbauen mit CAT
        if y_new_sec(1,i)==1
            ny_st=cat(2,ny(wingNums(1,i),y_new_sec(1,i)),...
                   ny(wingNums(1,i),y_new_sec(1,i):end));
        else
            ny_st=cat(2,ny(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   ny(wingNums(1,i),y_new_sec(1,i)),...
                   ny(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(ny_st)>length(ny(wingNums(1,i),:))
            ny(1:size(ny,1),length(ny(wingNums(1,i),:))+1:length(ny_st))=0;
        end
        ny(wingNums(1,i),:)=ny_st;  

    end

    % Korrigiern von ny 
    ny=ny(:,1:max(nelem));

    % Mit Homogenere Pannel Verteilung
    ny=round(b*n_norm);

    % Nullen löschen (ny muss immer >0)
    for i=1:length(nelem)
        f=find(ny(i,1:nelem(1,i))==0);
        if ~isempty(f)
            ny(i,f)=1;
        end
    end

    %Save
    wing_mod.ny=ny;

%% nx

    nx=aircraft.wings.nx;

    for i=1:size(y_new,2)    

        % Nx in Matrix einbauen mit CAT
        if y_new_sec(1,i)==1
            nx_st=cat(2,nx(wingNums(1,i),y_new_sec(1,i)),...
                   nx(wingNums(1,i),y_new_sec(1,i):end));
        else
            nx_st=cat(2,nx(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   nx(wingNums(1,i),y_new_sec(1,i)),...
                   nx(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(nx_st)>length(nx(wingNums(1,i),:))
            nx(1:size(nx,1),length(nx(wingNums(1,i),:))+1:length(nx_st))=0;
        end
        nx(wingNums(1,i),:)=nx_st;  

    end

    % Korrigiern von nx 
    nx=nx(:,1:max(nelem));

    %Save
    wing_mod.nx=nx;

%% flap_vector_max

    try
        flap_vector_max=aircraft.wings.flap_vector_max;
    catch
        flap_vector_max= ones(size(aircraft.wings.flap_vector))*0/180*pi;
    end

    for i=1:size(y_new,2)    

        % Flapped in Matrix einbauen mit CAT
        if y_new_sec(1,i)==1
            flap_vector_max_st=cat(2,flap_vector_max(wingNums(1,i),y_new_sec(1,i)),...
                   flap_vector_max(wingNums(1,i),y_new_sec(1,i):end));
        else
            flap_vector_max_st=cat(2,flap_vector_max(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   flap_vector_max(wingNums(1,i),y_new_sec(1,i)),...
                   flap_vector_max(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(flap_vector_max_st)>length(flap_vector_max(wingNums(1,i),:))
            flap_vector_max(1:size(flap_vector_max,1),length(flap_vector_max(wingNums(1,i),:))+1:length(flap_vector_max_st))=0;
        end
        flap_vector_max(wingNums(1,i),:)=flap_vector_max_st;  

    end

    % Korrigiern von flap_vector_max 
    flap_vector_max=flap_vector_max(:,1:max(nelem));

    %Save
    wing_mod.flap_vector_max=flap_vector_max;

%% flap_vector_min

    try
        flap_vector_min=aircraft.wings.flap_vector_min;
    catch
        flap_vector_min= ones(size(aircraft.wings.flap_vector))*0/180*pi;
    end

    for i=1:size(y_new,2)    

        % Flapped in Matrix einbauen mit CAT
        if y_new_sec(1,i)==1
            flap_vector_min_st=cat(2,flap_vector_min(wingNums(1,i),y_new_sec(1,i)),...
                   flap_vector_min(wingNums(1,i),y_new_sec(1,i):end));
        else
            flap_vector_min_st=cat(2,flap_vector_min(wingNums(1,i),1:y_new_sec(1,i)-1),...
                   flap_vector_min(wingNums(1,i),y_new_sec(1,i)),...
                   flap_vector_min(wingNums(1,i),y_new_sec(1,i):end));
        end   

        % Vektorlänge korrigieren   
        if length(flap_vector_min_st)>length(flap_vector_min(wingNums(1,i),:))
            flap_vector_min(1:size(flap_vector_min,1),length(flap_vector_min(wingNums(1,i),:))+1:length(flap_vector_min_st))=0;
        end
        flap_vector_min(wingNums(1,i),:)=flap_vector_min_st;  

    end

    % Korrigiern von flap_vector_min 
    flap_vector_min=flap_vector_min(:,1:max(nelem));

    % Save
    wing_mod.flap_vector_min=flap_vector_min;

%% Zusätzliche Klappendefinition

    if newFldef==1;
        % Klappendefinitionen werden bei den wings mit neuen sectionen zurückgesetzt 
        for  i=1:size(wingNums,2)
            wing_mod.fc(wingNums(1,i),:)         = zeros(size(wing_mod.fc(wingNums(1,i),:)));
            wing_mod.fsym(wingNums(1,i),:)       = zeros(size(wing_mod.fsym(wingNums(1,i),:)));
            wing_mod.flap_vector(wingNums(1,i),:)= zeros(size(wing_mod.flap_vector(wingNums(1,i),:)));
            wing_mod.fnx(wingNums(1,i),:)        = zeros(size(wing_mod.fnx(wingNums(1,i),:)));
        end

        % Wenn klappen in einem Bereich nur definiert werden
        diffwing=unique(wingNums);
        for i=1:size(diffwing,2)
            for ii=1:nelem(1,diffwing(1,i))
                if wing_mod.flapped(diffwing(1,i),ii)==1
                    wing_mod.fc(diffwing(1,i),ii)        =0.3;       %*
                    wing_mod.fsym(diffwing(1,i),ii)      =1;         %*
                    wing_mod.flap_vector(diffwing(1,i),ii)=0/180*pi; %*
                    wing_mod.fnx(diffwing(1,i),ii)       =2;         %*
                end
            end
        end    
    end

%% nelem

    wing_mod.nelem=nelem;

%% Save

    aircraft.wings=wing_mod;
end

