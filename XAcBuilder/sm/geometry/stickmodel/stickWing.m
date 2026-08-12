
%LETTORE FILE
% close all,clear all,clc,delete(get(0,'children'))
% [filename,pathname]=uigetfile('*.*','Seleziona il file');
% fid=fopen(strcat(pathname,filename));
% if fid==-1,disp('Errore in apertura File');break;end
% fseek(fid,0,-1);
% line=fgets(fid);%Titolo...
% if ~isstr(line),break,end
% line=fgets(fid);%Parametri geometria aerodinamica
% if ~isstr(line),break,end
% line=fgets(fid);prov=sscanf(line,'%g',1); Naf=prov; %nameAf=zeros(Naf,8);
% for i=1:Naf
%     line=fgets(fid);if ~isstr(line),break,end%Nome della i superficie aerdinamica
%     line=fgets(fid); if ~isstr(line),break,end,prov=sscanf(line,'%8s',1); nameAf(i,1:length(prov))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',3);       rp(i,:)=prov;
%     line=fgets(fid);prov=sscanf(line,'%d',1);       plane(i)=prov;
%     line=fgets(fid);prov=sscanf(line,'%d',1);       Mirror(i)=prov;
%     line=fgets(fid);prov=sscanf(line,'%d',1);       Np(i)=prov;
%     line=fgets(fid);prov=sscanf(line,'%d',3);       Npc(i,:)=prov;
%     line=fgets(fid);prov=sscanf(line,'%d',Np(i));   Nps(i,1:Np(i))=prov;
%    
%     line=fgets(fid);prov=sscanf(line,'%g',2);       crd(i,:)=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   spn(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   sw(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   dh(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   tp(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i)+1); tw(i,1:Np(i)+1)=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   msrf_fwd(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   msrf_aft(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',3);       hin(i,:)=prov;
%    
%     %Lettura stringa nomi superfici di comando
%     line=fgets(fid); prov=sscanf(line,'%c');
%     k=1; v(k)=0;
%     for j=2:length(prov)
%         if isspace(line(j)) && k<=Np(i)
%             k=k+1;             
%             v(k)=j;
%             nameMSL(i,k-1)={prov(v(k-1)+1:v(k)-1)};           
%         end
%     end
%     line=fgets(fid); prov=sscanf(line,'%c');
%     k=1; v(k)=0;
%     for j=2:length(prov)
%         if isspace(line(j)) && k<=Np(i)
%             k=k+1;            
%             v(k)=j;
%             nameMFL(i,k-1)={prov(v(k-1)+1:v(k)-1)};            
%         end
%     end
%     
%     %struttura
%     line=fgets(fid);if ~isstr(line),break,end %Structure
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   struct(i,1:Np(i))=prov;
%     
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strWidthSL(i,1:Np(i)) =prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strHeightSL(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strThickSL(i,1:Np(i)) =prov;
%     
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strWidthAf(i,1:Np(i)) =prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strHeightAf(i,1:Np(i))=prov;
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strThickAf(i,1:Np(i)) =prov;
%     
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strWidthFL(i,1:Np(i)) =prov;    
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strHeightFL(i,1:Np(i))=prov;   
%     line=fgets(fid);prov=sscanf(line,'%g',Np(i));   strThickFL(i,1:Np(i)) =prov;  
%  
% end
% 
% for i=1:Naf, 
%     if Mirror(i)==2, 
%         tmp(i,1:Np(i)*Mirror(i))=[reverse(nameMSL(i,1:Np(i))) nameMSL(i,1:Np(i))]; 
%     else tmp(i,1:Np(i)*Mirror(i))= nameMSL(i,1:Np(i)*Mirror(i)); 
%     end
% end
% for i=1:Naf
%     for j=1:Np(i)*Mirror(i)
%         if strcmp(char(tmp(i,j)),'fix')
%             tmp2(i,j)=tmp(i,j);
%         else
%             if j<=Np(i)              
%                 tmp2(i,j)={[char(tmp(i,j)) 'L']};
%             else
%                 tmp2(i,j)={[char(tmp(i,j)) 'R']};
%             end
%         end
%     end
% end
% nameMSL=tmp2;
% for i=1:Naf, 
%     if Mirror(i)==2, 
%         tmp(i,1:Np(i)*Mirror(i))=[reverse(nameMFL(i,1:Np(i))) nameMFL(i,1:Np(i))]; 
%     else tmp(i,1:Np(i)*Mirror(i))= nameMFL(i,1:Np(i)*Mirror(i)); 
%     end
% end
% for i=1:Naf
%     for j=1:Np(i)*Mirror(i)
%         if strcmp(char(tmp(i,j)),'fix')
%             tmp2(i,j)=tmp(i,j);
%         else
%             if j<=Np(i)              
%                 tmp2(i,j)={[char(tmp(i,j)) 'L']};
%             else
%                 tmp2(i,j)={[char(tmp(i,j)) 'R']};
%             end
%         end
%     end
% end
% nameMFL=tmp2
%fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
close all, clear all, clc
pathname='C:\Users\Nitro\Desktop\Nitro_on_PC\UNI\TESI_LM\CPACScreator_V1.4\Projects\';
filename='D150_TechGeoModel.mat';
load([pathname,filename]);
Naf=length(TechGeoModel.iWing)

nameAf=['Wing1';...
        'HTail';...
        'VTail';...
        'Wing2'];
plane       =[ 1 1 3 1];
Mirror      =[ 2 2 1 1];
for i=1:Naf
    if plane(i)==1
        rp(i,:)        = TechGeoModel.iWing{i}.Geometry.prof_wing(1).pnt_pos( TechGeoModel.iWing{i}.Geometry.prof_wing(1).iLE,:);
    elseif plane(i)==3
        rp(i,:)        = TechGeoModel.iWing{i}.Geometry.prof_wing(1).pnt_pos( TechGeoModel.iWing{i}.Geometry.prof_wing(1).iLE,[1 3 2]);
    end
        
    %plane(i)       = 1;
    %Mirror(i)      = 2;
    Np(i)          = length(TechGeoModel.iWing{i}.aeroPanel.ny);
    Npc(i,:)       = [0  TechGeoModel.iWing{i}.aeroPanel.nx(1) TechGeoModel.iWing{i}.aeroPanel.nxTED(1)];
    Nps(i,1:Np(i)) = TechGeoModel.iWing{i}.aeroPanel.ny;
    crd(i,:)       = [TechGeoModel.iWing{i}.Geometry.prof_wing(1).chord 0];
    spn(i,1:Np(i)) = TechGeoModel.iWing{i}.Geometry.span;
    sw(i,1:Np(i))  = TechGeoModel.iWing{i}.Geometry.sweep;
    dh(i,1:Np(i))  = TechGeoModel.iWing{i}.Geometry.dihedral;
    for j=1:Np(i)
%         if j==1
%             tp(i,j)=1;
%         else
            tp(i,j)= TechGeoModel.iWing{i}.Geometry.prof_wing(j+1).chord/TechGeoModel.iWing{i}.Geometry.prof_wing(j).chord;
        %end
    end
    tw(i,1:Np(i)+1)=zeros(1,Np(i)+1);
    msrf_fwd(i,1:Np(i))=zeros(1,Np(i));
    msrf_aft(i,1:Np(i))=0.85*ones(1,Np(i));
    hin(i,:)=[0 .5 .25];
    
    for j=1:Np(i)*Mirror(i)
        nameMSL{i,j}='fix';
        nameMFL{i,j}='fix';
    end
    
    %struct
    struct(i,1:Np(i))=2*ones(1,Np(i));
 
    strWidthSL(i,1:Np(i)) = 0.   *ones(1,Np(i));
    strHeightSL(i,1:Np(i))= 0.   *ones(1,Np(i));
    strThickSL(i,1:Np(i)) = 0.   *ones(1,Np(i));
    strWidthAf(i,1:Np(i)) =  .4  *ones(1,Np(i));
    strHeightAf(i,1:Np(i))=  .1  *ones(1,Np(i));
    strThickAf(i,1:Np(i)) =  .001*ones(1,Np(i));
    
    strWidthFL(i,1:Np(i)) =0*ones(1,Np(i));    
    strHeightFL(i,1:Np(i))=2*ones(1,Np(i));   
    strThickFL(i,1:Np(i)) =0*ones(1,Np(i)); 
    

end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rad=pi/180;

%i-> ID aerofoil
%j-> j(i) ID part

%2.INIZIALIZZAZIONE MATRICI
% max_p=0;
% for i=1:Naf,    n_p=sum(Np(i,:))*Mirror(i); if n_p>max_p, max_p=n_p; end, end    
% u_LE=zeros(Naf,max_p+1);x_LE=zeros(Naf,max_p+1);u_TE=zeros(Naf,max_p+1);x_TE=zeros(Naf,max_p+1);
% v_LE=zeros(Naf,max_p+1);y_LE=zeros(Naf,max_p+1);v_TE=zeros(Naf,max_p+1);y_TE=zeros(Naf,max_p+1);
% w_LE=zeros(Naf,max_p+1);z_LE=zeros(Naf,max_p+1);w_TE=zeros(Naf,max_p+1);z_TE=zeros(Naf,max_p+1);
% u_SL=zeros(Naf,max_p+1);x_SL=zeros(Naf,max_p+1);u_FL=zeros(Naf,max_p+1);x_FL=zeros(Naf,max_p+1);
% v_SL=zeros(Naf,max_p+1);y_SL=zeros(Naf,max_p+1);v_FL=zeros(Naf,max_p+1);y_FL=zeros(Naf,max_p+1);
% w_SL=zeros(Naf,max_p+1);z_SL=zeros(Naf,max_p+1);w_FL=zeros(Naf,max_p+1);z_FL=zeros(Naf,max_p+1);
%3.GEOMETRIA
for i=1:Naf    
    %3.1.GEOMETRIA
    for j=1:Np(i)+1
        if j==1
            
            cord(i,j)=crd(i,1);
        %LEADING EDGE & TRAILING EDGE    
            u_LE(i,j)=rp(i,1);                             u_TE(i,j)=rp(i,1)+crd(i,1);
            v_LE(i,j)=rp(i,2);                             v_TE(i,j)=rp(i,2);
            w_LE(i,j)=rp(i,3)+crd(i,2)*crd(i,1)*tan(tw(i,j)*rad);   w_TE(i,j)=rp(i,3)+(crd(i,2)-1)*crd(i,1)*tan(tw(i,j)*rad);
        %SLAT TE & FLAP LE    
            u_SL(i,j)=rp(i,1)+crd(i,1)*msrf_fwd(i,1);      u_FL(i,j)=rp(i,1)+crd(i,1)*msrf_aft(i,1);
            v_SL(i,j)=v_LE(i,j);                           v_FL(i,j)=v_LE(i,j);
            w_SL(i,j)=rp(i,3) + ( crd(i,2)-msrf_fwd(i,1)) * crd(i,1)*tan(tw(i,j)*rad);
            w_FL(i,j)=rp(i,3) + ( crd(i,2)-msrf_aft(i,1)) * crd(i,1)*tan(tw(i,j)*rad);
            
            u_hSL(i,j)=rp(i,1)+crd(i,1)*hin(i,1); 
            u_hAf(i,j)=rp(i,1)+crd(i,1)*hin(i,2);
            %u_hFL(i,j)=rp(i,1)+crd(i,1)*hin(i,3);
            u_hFL(i,j)=u_FL(i,j)+(u_TE(i,j)-u_FL(i,j))*hin(i,3);
            
            v_hSL(i,j)=v_LE(i,j);
            v_hAf(i,j)=v_LE(i,j);
            v_hFL(i,j)=v_LE(i,j);
            
            w_hSL(i,j)=rp(i,3) + ( crd(i,2)-hin(i,1)) * crd(i,1)*tan(tw(i,j)*rad);
            w_hAf(i,j)=rp(i,3) + ( crd(i,2)-hin(i,2)) * crd(i,1)*tan(tw(i,j)*rad);
            w_hFL(i,j)=rp(i,3) + ( crd(i,2)-hin(i,3)) * crd(i,1)*tan(tw(i,j)*rad);
            
            
        else
            cord(i,j)=cord(i,j-1)*tp(i,j-1);
        %LEADING EDGE & TRAILING EDGE
            u_LE(i,j)=u_LE(i,j-1)+spn(i,j-1)*tan(sw(i,j-1)*rad);           u_TE(i,j)=u_LE(i,j) + cord(i,j);
            v_LE(i,j)=v_LE(i,j-1)+spn(i,j-1);                              v_TE(i,j)=v_LE(i,j);
            w_LE(i,j)=w_LE(i,j-1) +   crd(i,2) * cord(i,j)*tan(tw(i,j)*rad) + spn(i,j-1)*tan(dh(i,j-1)*rad);
            w_TE(i,j)=w_LE(i,j-1) + (crd(i,2)-1)*cord(i,j)*tan(tw(i,j)*rad) + spn(i,j-1)*tan(dh(i,j-1)*rad);
        %SLAT TE & FLAP LE
            u_SL(i,j)=u_LE(i,j)+(u_TE(i,j)-u_LE(i,j))*msrf_fwd(i,j-1);  u_FL(i,j)=u_LE(i,j)+(u_TE(i,j)-u_LE(i,j))*msrf_aft(i,j-1);
            v_SL(i,j)=v_LE(i,j);                                        v_FL(i,j)=v_LE(i,j);
            w_SL(i,j)=w_LE(i,j-1) + ( crd(i,2)-msrf_fwd(i,j-1)) * cord(i,j)*tan(tw(i,j)*rad) + spn(i,j-1)*tan(dh(i,j-1)*rad);
            w_FL(i,j)=w_LE(i,j-1) + ( crd(i,2)-msrf_aft(i,j-1)) * cord(i,j)*tan(tw(i,j)*rad) + spn(i,j-1)*tan(dh(i,j-1)*rad);
            
            u_hSL(i,j)=u_LE(i,j) + hin(i,1)*cord(i,j);
            u_hAf(i,j)=u_LE(i,j) + hin(i,2)*cord(i,j);           
            %u_hFL(i,j)=u_LE(i,j) + hin(i,3)*cord(i,j);
            u_hFL(i,j)=u_FL(i,j)+(u_TE(i,j)-u_FL(i,j))*hin(i,3);
            
            v_hSL(i,j)=v_LE(i,j);
            v_hAf(i,j)=v_LE(i,j);
            v_hFL(i,j)=v_LE(i,j);
            
            w_hSL(i,j)=w_LE(i,j-1) + ( crd(i,2)-hin(i,1)) * cord(i,j)*tan(tw(i,j)*rad) + spn(i,j-1)*tan(dh(i,j-1)*rad);
            w_hAf(i,j)=w_LE(i,j-1) + ( crd(i,2)-hin(i,2)) * cord(i,j)*tan(tw(i,j)*rad) + spn(i,j-1)*tan(dh(i,j-1)*rad);
            w_hFL(i,j)=w_LE(i,j-1) + ( crd(i,2)-hin(i,3)) * cord(i,j)*tan(tw(i,j)*rad) + spn(i,j-1)*tan(dh(i,j-1)*rad);
            
            
        end
         
    end  
      %MATRICI PER LA CREAZIONE DELLE SUPERFICI AERODINAMICHE
      U_SL(1:Np(i)+1,:,i)=[u_LE(i,1:Np(i)+1)',u_SL(i,1:Np(i)+1)'];   
      U_Af(1:Np(i)+1,:,i)=[u_SL(i,1:Np(i)+1)',u_FL(i,1:Np(i)+1)'];
      U_FL(1:Np(i)+1,:,i)=[u_FL(i,1:Np(i)+1)',u_TE(i,1:Np(i)+1)'];
      
      V_SL(1:Np(i)+1,:,i)=[v_LE(i,1:Np(i)+1)',v_SL(i,1:Np(i)+1)'];
      V_Af(1:Np(i)+1,:,i)=[v_SL(i,1:Np(i)+1)',v_FL(i,1:Np(i)+1)'];   
      V_FL(1:Np(i)+1,:,i)=[v_FL(i,1:Np(i)+1)',v_TE(i,1:Np(i)+1)'];
      
      W_SL(1:Np(i)+1,:,i)=[w_LE(i,1:Np(i)+1)',w_SL(i,1:Np(i)+1)'];
      W_Af(1:Np(i)+1,:,i)=[w_SL(i,1:Np(i)+1)',w_FL(i,1:Np(i)+1)'];
      W_FL(1:Np(i)+1,:,i)=[w_FL(i,1:Np(i)+1)',w_TE(i,1:Np(i)+1)'];
      
      k=1; j=1;
      %NODI INTERFACCIA AERODINAMICA STRUTTURA
      while j<=Np(i)
         v_int(k:Nps(i,j)+k,i)=linspace(V_SL(j,1,i),V_SL(j+1,1,i),Nps(i,j)+1);
         
         u_intLE(k:Nps(i,j)+k,i)=interp1([v_LE(i,j) v_LE(i,j+1)],[u_LE(i,j) u_LE(i,j+1)],v_int(k:Nps(i,j)+k,i));
         u_intSL(k:Nps(i,j)+k,i)=interp1([v_SL(i,j) v_SL(i,j+1)],[u_SL(i,j) u_SL(i,j+1)],v_int(k:Nps(i,j)+k,i));
         u_intFL(k:Nps(i,j)+k,i)=interp1([v_FL(i,j) v_FL(i,j+1)],[u_FL(i,j) u_FL(i,j+1)],v_int(k:Nps(i,j)+k,i));
         u_intTE(k:Nps(i,j)+k,i)=interp1([v_TE(i,j) v_TE(i,j+1)],[u_TE(i,j) u_TE(i,j+1)],v_int(k:Nps(i,j)+k,i));
         
         u_inthSL(k:Nps(i,j)+k,i)=interp1([v_hSL(i,j) v_hSL(i,j+1)],[u_hSL(i,j) u_hSL(i,j+1)],v_int(k:Nps(i,j)+k,i));
         u_inthAf(k:Nps(i,j)+k,i)=interp1([v_hAf(i,j) v_hAf(i,j+1)],[u_hAf(i,j) u_hAf(i,j+1)],v_int(k:Nps(i,j)+k,i));
         u_inthFL(k:Nps(i,j)+k,i)=interp1([v_hFL(i,j) v_hFL(i,j+1)],[u_hFL(i,j) u_hFL(i,j+1)],v_int(k:Nps(i,j)+k,i));
                
         v_intLE(k:Nps(i,j)+k,i)=v_int(k:Nps(i,j)+k,i);
         v_intSL(k:Nps(i,j)+k,i)=v_int(k:Nps(i,j)+k,i);
         v_intFL(k:Nps(i,j)+k,i)=v_int(k:Nps(i,j)+k,i);
         v_intTE(k:Nps(i,j)+k,i)=v_int(k:Nps(i,j)+k,i);
         
         v_inthSL(k:Nps(i,j)+k,i)=v_int(k:Nps(i,j)+k,i);
         v_inthAf(k:Nps(i,j)+k,i)=v_int(k:Nps(i,j)+k,i);
         v_inthFL(k:Nps(i,j)+k,i)=v_int(k:Nps(i,j)+k,i);
         
         w_intLE(k:Nps(i,j)+k,i)=interp1([v_LE(i,j) v_LE(i,j+1)],[w_LE(i,j) w_LE(i,j+1)],v_int(k:Nps(i,j)+k,i));
         w_intSL(k:Nps(i,j)+k,i)=interp1([v_SL(i,j) v_SL(i,j+1)],[w_SL(i,j) w_SL(i,j+1)],v_int(k:Nps(i,j)+k,i));
         w_intFL(k:Nps(i,j)+k,i)=interp1([v_FL(i,j) v_FL(i,j+1)],[w_FL(i,j) w_FL(i,j+1)],v_int(k:Nps(i,j)+k,i));
         w_intTE(k:Nps(i,j)+k,i)=interp1([v_TE(i,j) v_TE(i,j+1)],[w_TE(i,j) w_TE(i,j+1)],v_int(k:Nps(i,j)+k,i));
         
         w_inthSL(k:Nps(i,j)+k,i)=interp1([v_hSL(i,j) v_hSL(i,j+1)],[w_hSL(i,j) w_hSL(i,j+1)],v_int(k:Nps(i,j)+k,i));
         w_inthAf(k:Nps(i,j)+k,i)=interp1([v_hAf(i,j) v_hAf(i,j+1)],[w_hAf(i,j) w_hAf(i,j+1)],v_int(k:Nps(i,j)+k,i));
         w_inthFL(k:Nps(i,j)+k,i)=interp1([v_hFL(i,j) v_hFL(i,j+1)],[w_hFL(i,j) w_hFL(i,j+1)],v_int(k:Nps(i,j)+k,i));
         
         
         
%          k=k+Nps(i,j)+1;
         k=k+Nps(i,j);
         j=j+1;
      end
            

      %MATRICI PER LE SUPERFICI SHELL DI VISUALIZZAZIONE IN NASTRAN
      for k=1:sum(Nps(i,1:Np(i)))+1
          UU_SL(k,1:Npc(i,1)+1,i)=linspace(u_intLE(k,i),u_intSL(k,i),Npc(i,1)+1);
          UU_Af(k,1:Npc(i,2)+1,i)=linspace(u_intSL(k,i),u_intFL(k,i),Npc(i,2)+1);
          UU_FL(k,1:Npc(i,3)+1,i)=linspace(u_intFL(k,i),u_intTE(k,i),Npc(i,3)+1);
          
          VV_SL(k,1:Npc(i,1)+1,i)=linspace(v_intLE(k,i),v_intSL(k,i),Npc(i,1)+1);
          VV_Af(k,1:Npc(i,2)+1,i)=linspace(v_intSL(k,i),v_intFL(k,i),Npc(i,2)+1);
          VV_FL(k,1:Npc(i,3)+1,i)=linspace(v_intFL(k,i),v_intTE(k,i),Npc(i,3)+1);
          
          WW_SL(k,1:Npc(i,1)+1,i)=linspace(w_intLE(k,i),w_intSL(k,i),Npc(i,1)+1);
          WW_Af(k,1:Npc(i,2)+1,i)=linspace(w_intSL(k,i),w_intFL(k,i),Npc(i,2)+1);
          WW_FL(k,1:Npc(i,3)+1,i)=linspace(w_intFL(k,i),w_intTE(k,i),Npc(i,3)+1);
      end
            
%OPERAZIONE DI SPECCHIATURA DEI NODI 
        Nps2(i,1:Np(i))        =Nps(i,1:Np(i)); 
        struct2(i,1:Np(i))     =struct(i,1:Np(i));
        strWidthAf2(i,1:Np(i)) =strWidthAf(i,1:Np(i));
        strWidthSL2(i,1:Np(i)) =strWidthSL(i,1:Np(i));
        strWidthFL2(i,1:Np(i)) =strWidthFL(i,1:Np(i));
        strHeightAf2(i,1:Np(i))=strHeightAf(i,1:Np(i));
        strHeightSL2(i,1:Np(i))=strHeightSL(i,1:Np(i));
        strHeightFL2(i,1:Np(i))=strHeightFL(i,1:Np(i));
        strThickAf2(i,1:Np(i)) =strThickAf(i,1:Np(i));
        strThickSL2(i,1:Np(i)) =strThickSL(i,1:Np(i));
        strThickFL2(i,1:Np(i)) =strThickFL(i,1:Np(i));
      if Mirror(i)==2
        Nps2(i,1:Mirror(i)*Np(i))     =    [reverse(Nps(i,1:Np(i))) , Nps(i,1:Np(i))]; 
        struct2(i,1:Mirror(i)*Np(i))  =    [reverse(struct(i,1:Np(i))) , struct(i,1:Np(i))]; 
        strWidthAf2(i,1:Mirror(i)*Np(i))=  [reverse(strWidthAf(i,1:Np(i))) , strWidthAf(i,1:Np(i))]; 
        strWidthSL2(i,1:Mirror(i)*Np(i))=  [reverse(strWidthSL(i,1:Np(i))) , strWidthSL(i,1:Np(i))]; 
        strWidthFL2(i,1:Mirror(i)*Np(i))=  [reverse(strWidthFL(i,1:Np(i))) , strWidthFL(i,1:Np(i))]; 
        strHeightAf2(i,1:Mirror(i)*Np(i))= [reverse(strHeightAf(i,1:Np(i))) , strHeightAf(i,1:Np(i))]; 
        strHeightSL2(i,1:Mirror(i)*Np(i))= [reverse(strHeightSL(i,1:Np(i))) , strHeightSL(i,1:Np(i))]; 
        strHeightFL2(i,1:Mirror(i)*Np(i))= [reverse(strHeightFL(i,1:Np(i))) , strHeightFL(i,1:Np(i))]; 
        strThickAf2(i,1:Mirror(i)*Np(i))=  [reverse(strThickAf(i,1:Np(i))) , strThickAf(i,1:Np(i))]; 
        strThickSL2(i,1:Mirror(i)*Np(i))=  [reverse(strThickSL(i,1:Np(i))) , strThickSL(i,1:Np(i))]; 
        strThickFL2(i,1:Mirror(i)*Np(i))=  [reverse(strThickFL(i,1:Np(i))) , strThickFL(i,1:Np(i))]; 
        %if plane(i)==1, PM=[1 -1 1]; elseif plane(i)==2, PM=[1 -1 1]; elseif plane(i)==3, PM=[1 1 -1]; end 
        u_tmp=[ reverse(u_LE(i,1:Np(i)+1)) u_LE(i,2:Np(i)+1)];  u_LE(i,1:2*Np(i)+1)=u_tmp;  clear u_tmp, 
        u_tmp=[ reverse(u_TE(i,1:Np(i)+1)) u_TE(i,2:Np(i)+1)];  u_TE(i,1:2*Np(i)+1)=u_tmp;  clear u_tmp,
        v_tmp=[-reverse(v_LE(i,1:Np(i)+1)) v_LE(i,2:Np(i)+1)];  v_LE(i,1:2*Np(i)+1)=v_tmp;  clear v_tmp, 
        v_tmp=[-reverse(v_TE(i,1:Np(i)+1)) v_TE(i,2:Np(i)+1)];  v_TE(i,1:2*Np(i)+1)=v_tmp;  clear v_tmp,
        w_tmp=[ reverse(w_LE(i,1:Np(i)+1)) w_LE(i,2:Np(i)+1)];  w_LE(i,1:2*Np(i)+1)=w_tmp;  clear w_tmp,
        w_tmp=[ reverse(w_TE(i,1:Np(i)+1)) w_TE(i,2:Np(i)+1)];  w_TE(i,1:2*Np(i)+1)=w_tmp;  clear w_tmp
        
        u_tmp=[ reverse(u_SL(i,1:Np(i)+1)) u_SL(i,2:Np(i)+1)];  u_SL(i,1:2*Np(i)+1)=u_tmp;  clear u_tmp, 
        u_tmp=[ reverse(u_FL(i,1:Np(i)+1)) u_FL(i,2:Np(i)+1)];  u_FL(i,1:2*Np(i)+1)=u_tmp;  clear u_tmp,
        v_tmp=[-reverse(v_SL(i,1:Np(i)+1)) v_SL(i,2:Np(i)+1)];  v_SL(i,1:2*Np(i)+1)=v_tmp;  clear v_tmp, 
        v_tmp=[-reverse(v_FL(i,1:Np(i)+1)) v_FL(i,2:Np(i)+1)];  v_FL(i,1:2*Np(i)+1)=v_tmp;  clear v_tmp,
        w_tmp=[ reverse(w_SL(i,1:Np(i)+1)) w_SL(i,2:Np(i)+1)];  w_SL(i,1:2*Np(i)+1)=w_tmp;  clear w_tmp,
        w_tmp=[ reverse(w_FL(i,1:Np(i)+1)) w_FL(i,2:Np(i)+1)];  w_FL(i,1:2*Np(i)+1)=w_tmp;  clear w_tmp
        
        U_SL(1:Mirror(i)*Np(i)+1,:,i) = [u_LE(i,1:Mirror(i)*Np(i)+1)',u_SL(i,1:Mirror(i)*Np(i)+1)'];
        V_SL(1:Mirror(i)*Np(i)+1,:,i) = [v_LE(i,1:Mirror(i)*Np(i)+1)',v_SL(i,1:Mirror(i)*Np(i)+1)'];
        W_SL(1:Mirror(i)*Np(i)+1,:,i) = [w_LE(i,1:Mirror(i)*Np(i)+1)',w_SL(i,1:Mirror(i)*Np(i)+1)'];
        U_Af(1:Mirror(i)*Np(i)+1,:,i) = [u_SL(i,1:Mirror(i)*Np(i)+1)',u_FL(i,1:Mirror(i)*Np(i)+1)'];
        V_Af(1:Mirror(i)*Np(i)+1,:,i) = [v_SL(i,1:Mirror(i)*Np(i)+1)',v_FL(i,1:Mirror(i)*Np(i)+1)'];
        W_Af(1:Mirror(i)*Np(i)+1,:,i) = [w_SL(i,1:Mirror(i)*Np(i)+1)',w_FL(i,1:Mirror(i)*Np(i)+1)'];
        U_FL(1:Mirror(i)*Np(i)+1,:,i) = [u_FL(i,1:Mirror(i)*Np(i)+1)',u_TE(i,1:Mirror(i)*Np(i)+1)'];
        V_FL(1:Mirror(i)*Np(i)+1,:,i) = [v_FL(i,1:Mirror(i)*Np(i)+1)',v_TE(i,1:Mirror(i)*Np(i)+1)'];
        W_FL(1:Mirror(i)*Np(i)+1,:,i) = [w_FL(i,1:Mirror(i)*Np(i)+1)',w_TE(i,1:Mirror(i)*Np(i)+1)'];
        
        u_intLE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(u_intLE(1:sum(Nps(i,1:Np(i)))+1,i))';u_intLE(2:sum(Nps(i,1:Np(i)))+1,i)];
        u_intSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(u_intSL(1:sum(Nps(i,1:Np(i)))+1,i))';u_intSL(2:sum(Nps(i,1:Np(i)))+1,i)];
        u_intFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(u_intFL(1:sum(Nps(i,1:Np(i)))+1,i))';u_intFL(2:sum(Nps(i,1:Np(i)))+1,i)];
        u_intTE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(u_intTE(1:sum(Nps(i,1:Np(i)))+1,i))';u_intTE(2:sum(Nps(i,1:Np(i)))+1,i)];
        
        u_inthSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(u_inthSL(1:sum(Nps(i,1:Np(i)))+1,i))';u_inthSL(2:sum(Nps(i,1:Np(i)))+1,i)];
        u_inthAf(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(u_inthAf(1:sum(Nps(i,1:Np(i)))+1,i))';u_inthAf(2:sum(Nps(i,1:Np(i)))+1,i)];
        u_inthFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(u_inthFL(1:sum(Nps(i,1:Np(i)))+1,i))';u_inthFL(2:sum(Nps(i,1:Np(i)))+1,i)];       
                
        v_intLE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[-reverse(v_intLE(1:sum(Nps(i,1:Np(i)))+1,i))';v_intLE(2:sum(Nps(i,1:Np(i)))+1,i)];
        v_intSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[-reverse(v_intSL(1:sum(Nps(i,1:Np(i)))+1,i))';v_intSL(2:sum(Nps(i,1:Np(i)))+1,i)];
        v_intFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[-reverse(v_intFL(1:sum(Nps(i,1:Np(i)))+1,i))';v_intFL(2:sum(Nps(i,1:Np(i)))+1,i)];
        v_intTE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[-reverse(v_intTE(1:sum(Nps(i,1:Np(i)))+1,i))';v_intTE(2:sum(Nps(i,1:Np(i)))+1,i)];
        
        u_tmp=[ reverse(u_hSL(i,1:Np(i)+1)) u_hSL(i,2:Np(i)+1)];  u_hSL(i,1:2*Np(i)+1)=u_tmp;  clear u_tmp, 
        u_tmp=[ reverse(u_hFL(i,1:Np(i)+1)) u_hFL(i,2:Np(i)+1)];  u_hFL(i,1:2*Np(i)+1)=u_tmp;  clear u_tmp,
        v_tmp=[-reverse(v_hSL(i,1:Np(i)+1)) v_hSL(i,2:Np(i)+1)];  v_hSL(i,1:2*Np(i)+1)=v_tmp;  clear v_tmp, 
        v_tmp=[-reverse(v_hFL(i,1:Np(i)+1)) v_hFL(i,2:Np(i)+1)];  v_hFL(i,1:2*Np(i)+1)=v_tmp;  clear v_tmp,
        w_tmp=[ reverse(w_hSL(i,1:Np(i)+1)) w_hSL(i,2:Np(i)+1)];  w_hSL(i,1:2*Np(i)+1)=w_tmp;  clear w_tmp,
        w_tmp=[ reverse(w_hFL(i,1:Np(i)+1)) w_hFL(i,2:Np(i)+1)];  w_hFL(i,1:2*Np(i)+1)=w_tmp;  clear w_tmp
        
        v_inthSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[-reverse(v_inthSL(1:sum(Nps(i,1:Np(i)))+1,i))';v_inthSL(2:sum(Nps(i,1:Np(i)))+1,i)];
        v_inthAf(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[-reverse(v_inthAf(1:sum(Nps(i,1:Np(i)))+1,i))';v_inthAf(2:sum(Nps(i,1:Np(i)))+1,i)];
        v_inthFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[-reverse(v_inthFL(1:sum(Nps(i,1:Np(i)))+1,i))';v_inthFL(2:sum(Nps(i,1:Np(i)))+1,i)];
        
        w_intLE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(w_intLE(1:sum(Nps(i,1:Np(i)))+1,i))';w_intLE(2:sum(Nps(i,1:Np(i)))+1,i)];
        w_intSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(w_intSL(1:sum(Nps(i,1:Np(i)))+1,i))';w_intSL(2:sum(Nps(i,1:Np(i)))+1,i)];
        w_intFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(w_intFL(1:sum(Nps(i,1:Np(i)))+1,i))';w_intFL(2:sum(Nps(i,1:Np(i)))+1,i)];
        w_intTE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(w_intTE(1:sum(Nps(i,1:Np(i)))+1,i))';w_intTE(2:sum(Nps(i,1:Np(i)))+1,i)];
        
        w_inthSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(w_inthSL(1:sum(Nps(i,1:Np(i)))+1,i))';w_inthSL(2:sum(Nps(i,1:Np(i)))+1,i)];
        w_inthAf(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(w_inthAf(1:sum(Nps(i,1:Np(i)))+1,i))';w_inthAf(2:sum(Nps(i,1:Np(i)))+1,i)];
        w_inthFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i)=[ reverse(w_inthFL(1:sum(Nps(i,1:Np(i)))+1,i))';w_inthFL(2:sum(Nps(i,1:Np(i)))+1,i)];
        
 
        UU_SL(1:sum(Nps2(i,:))+1,1:Npc(i,1)+1,i)=[ flipud(UU_SL(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,1)+1,i));UU_SL(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,1)+1,i) ];
        VV_SL(1:sum(Nps2(i,:))+1,1:Npc(i,1)+1,i)=[-flipud(VV_SL(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,1)+1,i));VV_SL(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,1)+1,i) ];
        WW_SL(1:sum(Nps2(i,:))+1,1:Npc(i,1)+1,i)=[ flipud(WW_SL(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,1)+1,i));WW_SL(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,1)+1,i) ];
        
        UU_Af(1:sum(Nps2(i,:))+1,1:Npc(i,2)+1,i)=[ flipud(UU_Af(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,2)+1,i));UU_Af(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,2)+1,i) ];
        VV_Af(1:sum(Nps2(i,:))+1,1:Npc(i,2)+1,i)=[-flipud(VV_Af(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,2)+1,i));VV_Af(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,2)+1,i) ];
        WW_Af(1:sum(Nps2(i,:))+1,1:Npc(i,2)+1,i)=[ flipud(WW_Af(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,2)+1,i));WW_Af(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,2)+1,i) ];
        
        UU_FL(1:sum(Nps2(i,:))+1,1:Npc(i,3)+1,i)=[ flipud(UU_FL(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,3)+1,i));UU_FL(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,3)+1,i) ];
        VV_FL(1:sum(Nps2(i,:))+1,1:Npc(i,3)+1,i)=[-flipud(VV_FL(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,3)+1,i));VV_FL(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,3)+1,i) ];
        WW_FL(1:sum(Nps2(i,:))+1,1:Npc(i,3)+1,i)=[ flipud(WW_FL(1:sum(Nps(i,1:Np(i)))+1,1:Npc(i,3)+1,i));WW_FL(2:sum(Nps(i,1:Np(i)))+1,1:Npc(i,3)+1,i) ];
    
    
      end
end
%PROIEZIONE SUL PIANO DEFINITO DALL'UTENTE
for i=1:Naf
      if plane(i)==1
        x_LE(i,:)=u_LE(i,:); x_TE(i,:)=u_TE(i,:);     y_LE(i,:)=v_LE(i,:); y_TE(i,:)=v_TE(i,:);    z_LE(i,:)=w_LE(i,:); z_TE(i,:)=w_TE(i,:);
        x_SL(i,:)=u_SL(i,:); x_FL(i,:)=u_FL(i,:);     y_SL(i,:)=v_SL(i,:); y_FL(i,:)=v_FL(i,:);    z_SL(i,:)=w_SL(i,:); z_FL(i,:)=w_FL(i,:);
        X_SL(:,:,i)=U_SL(:,:,i);                      Y_SL(:,:,i)=V_SL(:,:,i);                     Z_SL(:,:,i)=W_SL(:,:,i);
        X_Af(:,:,i)=U_Af(:,:,i);                      Y_Af(:,:,i)=V_Af(:,:,i);                     Z_Af(:,:,i)=W_Af(:,:,i);
        X_FL(:,:,i)=U_FL(:,:,i);                      Y_FL(:,:,i)=V_FL(:,:,i);                     Z_FL(:,:,i)=W_FL(:,:,i);
        x_intLE(:,i)=u_intLE(:,i);                    y_intLE(:,i)=v_intLE(:,i);                   z_intLE(:,i)=w_intLE(:,i); 
        x_intSL(:,i)=u_intSL(:,i);                    y_intSL(:,i)=v_intSL(:,i);                   z_intSL(:,i)=w_intSL(:,i);
        x_intFL(:,i)=u_intFL(:,i);                    y_intFL(:,i)=v_intFL(:,i);                   z_intFL(:,i)=w_intFL(:,i);
        x_intTE(:,i)=u_intTE(:,i);                    y_intTE(:,i)=v_intTE(:,i);                   z_intTE(:,i)=w_intTE(:,i);
        
        x_hSL(i,:)=u_hSL(i,:);                        y_hSL(i,:)=v_hSL(i,:);                       z_hSL(i,:)=w_hSL(i,:);
        x_hFL(i,:)=u_hFL(i,:);                        y_hFL(i,:)=v_hFL(i,:);                       z_hFL(i,:)=w_hFL(i,:);
        x_inthSL(:,i)=u_inthSL(:,i);                  y_inthSL(:,i)=v_inthSL(:,i);                 z_inthSL(:,i)=w_inthSL(:,i);
        x_inthAf(:,i)=u_inthAf(:,i);                  y_inthAf(:,i)=v_inthAf(:,i);                 z_inthAf(:,i)=w_inthAf(:,i);
        x_inthFL(:,i)=u_inthFL(:,i);                  y_inthFL(:,i)=v_inthFL(:,i);                 z_inthFL(:,i)=w_inthFL(:,i);
        
        XX_SL(:,:,i)=UU_SL(:,:,i);                    YY_SL(:,:,i)=VV_SL(:,:,i);                   ZZ_SL(:,:,i)=WW_SL(:,:,i);
        XX_Af(:,:,i)=UU_Af(:,:,i);                    YY_Af(:,:,i)=VV_Af(:,:,i);                   ZZ_Af(:,:,i)=WW_Af(:,:,i);
        XX_FL(:,:,i)=UU_FL(:,:,i);                    YY_FL(:,:,i)=VV_FL(:,:,i);                   ZZ_FL(:,:,i)=WW_FL(:,:,i);
        
      elseif plane(i)==2
        x_LE(i,:)=w_LE(i,:); x_TE(i,:)=w_TE(i,:);     y_LE(i,:)=v_LE(i,:); y_TE(i,:)=v_TE(i,:);    z_LE(i,:)=u_LE(i,:); z_TE(i,:)=u_TE(i,:);
        x_SL(i,:)=w_SL(i,:); x_FL(i,:)=w_FL(i,:);     y_SL(i,:)=v_SL(i,:); y_FL(i,:)=v_FL(i,:);    z_SL(i,:)=u_SL(i,:); z_FL(i,:)=u_FL(i,:);
        X_SL(:,:,i)=W_SL(:,:,i);                      Y_SL(:,:,i)=V_SL(:,:,i);                     Z_SL(:,:,i)=U_SL(:,:,i);
        X_Af(:,:,i)=W_Af(:,:,i);                      Y_Af(:,:,i)=V_Af(:,:,i);                     Z_Af(:,:,i)=U_Af(:,:,i);
        X_FL(:,:,i)=W_FL(:,:,i);                      Y_FL(:,:,i)=V_FL(:,:,i);                     Z_FL(:,:,i)=U_FL(:,:,i);
        x_intLE(:,i)=w_intLE(:,i);                    y_intLE(:,i)=v_intLE(:,i);                   z_intLE(:,i)=u_intLE(:,i); 
        x_intSL(:,i)=w_intSL(:,i);                    y_intSL(:,i)=v_intSL(:,i);                   z_intSL(:,i)=u_intSL(:,i);
        x_intFL(:,i)=w_intFL(:,i);                    y_intFL(:,i)=v_intFL(:,i);                   z_intFL(:,i)=u_intFL(:,i);
        x_intTE(:,i)=w_intTE(:,i);                    y_intTE(:,i)=v_intTE(:,i);                   z_intTE(:,i)=u_intTE(:,i);
        
        %nodi cerniere superfici aerodinamiche di controllo
        x_hSL(i,:)=w_hSL(i,:);                        y_hSL(i,:)=v_hSL(i,:);                       z_hSL(i,:)=u_hSL(i,:);
        x_hFL(i,:)=w_hFL(i,:);                        y_hFL(i,:)=v_hFL(i,:);                       z_hFL(i,:)=u_hFL(i,:);
        x_inthSL(:,i)=w_inthSL(:,i);                  y_inthSL(:,i)=v_inthSL(:,i);                 z_inthSL(:,i)=u_inthSL(:,i);
        x_inthAf(:,i)=w_inthAf(:,i);                  y_inthAf(:,i)=v_inthAf(:,i);                 z_inthAf(:,i)=u_inthAf(:,i);
        x_inthFL(:,i)=w_inthFL(:,i);                  y_inthFL(:,i)=v_inthFL(:,i);                 z_inthFL(:,i)=u_inthFL(:,i);
        
        XX_SL(:,:,i)=WW_SL(:,:,i);                    YY_SL(:,:,i)=VV_SL(:,:,i);                   ZZ_SL(:,:,i)=UU_SL(:,:,i);
        XX_Af(:,:,i)=WW_Af(:,:,i);                    YY_Af(:,:,i)=VV_Af(:,:,i);                   ZZ_Af(:,:,i)=UU_Af(:,:,i);
        XX_FL(:,:,i)=WW_FL(:,:,i);                    YY_FL(:,:,i)=VV_FL(:,:,i);                   ZZ_FL(:,:,i)=UU_FL(:,:,i);
        
      elseif plane(i)==3
        x_LE(i,:)=u_LE(i,:); x_TE(i,:)=u_TE(i,:);     y_LE(i,:)=w_LE(i,:); y_TE(i,:)=w_TE(i,:);    z_LE(i,:)=v_LE(i,:); z_TE(i,:)=v_TE(i,:);
        x_SL(i,:)=u_SL(i,:); x_FL(i,:)=u_FL(i,:);     y_SL(i,:)=w_SL(i,:); y_FL(i,:)=w_FL(i,:);    z_SL(i,:)=v_SL(i,:); z_FL(i,:)=v_FL(i,:);
        X_SL(:,:,i)=U_SL(:,:,i);                      Y_SL(:,:,i)=W_SL(:,:,i);                     Z_SL(:,:,i)=V_SL(:,:,i);
        X_Af(:,:,i)=U_Af(:,:,i);                      Y_Af(:,:,i)=W_Af(:,:,i);                     Z_Af(:,:,i)=V_Af(:,:,i);
        X_FL(:,:,i)=U_FL(:,:,i);                      Y_FL(:,:,i)=W_FL(:,:,i);                     Z_FL(:,:,i)=V_FL(:,:,i);
        x_intLE(:,i)=u_intLE(:,i);                    y_intLE(:,i)=w_intLE(:,i);                   z_intLE(:,i)=v_intLE(:,i); 
        x_intSL(:,i)=u_intSL(:,i);                    y_intSL(:,i)=w_intSL(:,i);                   z_intSL(:,i)=v_intSL(:,i);
        x_intFL(:,i)=u_intFL(:,i);                    y_intFL(:,i)=w_intFL(:,i);                   z_intFL(:,i)=v_intFL(:,i);
        x_intTE(:,i)=u_intTE(:,i);                    y_intTE(:,i)=w_intTE(:,i);                   z_intTE(:,i)=v_intTE(:,i);
        
        x_hSL(i,:)=u_hSL(i,:);                        y_hSL(i,:)=w_hSL(i,:);                       z_hSL(i,:)=v_hSL(i,:);
        x_hFL(i,:)=u_hFL(i,:);                        y_hFL(i,:)=w_hFL(i,:);                       z_hFL(i,:)=v_hFL(i,:);
        x_inthSL(:,i)=u_inthSL(:,i);                  y_inthSL(:,i)=w_inthSL(:,i);                 z_inthSL(:,i)=v_inthSL(:,i);
        x_inthAf(:,i)=u_inthAf(:,i);                  y_inthAf(:,i)=w_inthAf(:,i);                 z_inthAf(:,i)=v_inthAf(:,i);
        x_inthFL(:,i)=u_inthFL(:,i);                  y_inthFL(:,i)=w_inthFL(:,i);                 z_inthFL(:,i)=v_inthFL(:,i);
        
        XX_SL(:,:,i)=UU_SL(:,:,i);                    YY_SL(:,:,i)=WW_SL(:,:,i);                   ZZ_SL(:,:,i)=VV_SL(:,:,i);
        XX_Af(:,:,i)=UU_Af(:,:,i);                    YY_Af(:,:,i)=WW_Af(:,:,i);                   ZZ_Af(:,:,i)=VV_Af(:,:,i);
        XX_FL(:,:,i)=UU_FL(:,:,i);                    YY_FL(:,:,i)=WW_FL(:,:,i);                   ZZ_FL(:,:,i)=VV_FL(:,:,i);
      end
        
end
%4.PLOTTAGGIO 3D
figure, hold on , axis equal,view(30,45)
colori=['b','g','c','k'];
for i=1:Naf
    for h=1:3,   
        if plane(i)==1,     vect=[0 0 0]; vect(h)=1; quiver3(rp(i,1),rp(i,2),rp(i,3),vect(1), vect(2), vect(3)) 
        elseif plane(i)==2, vect=[0 0 0]; vect(h)=1; quiver3(rp(i,3),rp(i,2),rp(i,1),vect(1), vect(2), vect(3))  
        elseif plane(i)==3, vect=[0 0 0]; vect(h)=1; quiver3(rp(i,1),rp(i,3),rp(i,2),vect(1), vect(2), vect(3)), end 
        end
        
%     plot3(x_LE(i,1:Mirror(i)*Np(i)+1),y_LE(i,1:Mirror(i)*Np(i)+1),z_LE(i,1:Mirror(i)*Np(i)+1),colori(i))
%     plot3(x_TE(i,1:Mirror(i)*Np(i)+1),y_TE(i,1:Mirror(i)*Np(i)+1),z_TE(i,1:Mirror(i)*Np(i)+1),colori(i))
%     plot3(x_SL(i,1:Mirror(i)*Np(i)+1),y_SL(i,1:Mirror(i)*Np(i)+1),z_SL(i,1:Mirror(i)*Np(i)+1),colori(i))
%     plot3(x_FL(i,1:Mirror(i)*Np(i)+1),y_FL(i,1:Mirror(i)*Np(i)+1),z_FL(i,1:Mirror(i)*Np(i)+1),colori(i))
    
%     for j=1:Mirror(i)*Np(i)+1
%         plot3([x_LE(i,j) x_TE(i,j)],[y_LE(i,j) y_TE(i,j)],[z_LE(i,j) z_TE(i,j)],colori(i))
%     end
    
    plot3(x_intLE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          y_intLE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          z_intLE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),colori(i))
    plot3(x_intSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          y_intSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          z_intSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),colori(i))
    plot3(x_intFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          y_intFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          z_intFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),colori(i))
    plot3(x_intTE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          y_intTE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
          z_intTE(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),colori(i))

%     plot3(x_inthSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
%           y_inthSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
%           z_inthSL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),colori(i))
%     plot3(x_inthAf(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
%           y_inthAf(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
%           z_inthAf(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),colori(i))
%     plot3(x_inthFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
%           y_inthFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),...
%           z_inthFL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,i),colori(i))

    if Npc(i,1) ~ 0;
        surface(X_SL(1:Mirror(i)*Np(i)+1,:,i),Y_SL(1:Mirror(i)*Np(i)+1,:,i),Z_SL(1:Mirror(i)*Np(i)+1,:,i))
%         surface(XX_SL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,1)+1,i),...
%                 YY_SL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,1)+1,i),...
%                 ZZ_SL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,1)+1,i));
    end
    if Npc(i,2) ~ 0;
        surface(X_Af(1:Mirror(i)*Np(i)+1,:,i),Y_Af(1:Mirror(i)*Np(i)+1,:,i),Z_Af(1:Mirror(i)*Np(i)+1,:,i))
%         surface(XX_Af(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,2)+1,i),...
%                 YY_Af(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,2)+1,i),...
%                 ZZ_Af(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,2)+1,i));
    end
    if Npc(i,3) ~ 0;
        surface(X_FL(1:Mirror(i)*Np(i)+1,:,i),Y_FL(1:Mirror(i)*Np(i)+1,:,i),Z_FL(1:Mirror(i)*Np(i)+1,:,i))
%         surface(XX_FL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,3)+1,i),...
%                 YY_FL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,3)+1,i),...
%                 ZZ_FL(1:sum(Nps2(i,1:Mirror(i)*Np(i)))+1,1:Npc(i,3)+1,i));
    end
end




%5.FILE DI INPUT A NASTRAN PER I PANNELLI AERODINAMICI
%fp = fopen([filename 'Aero.dat'],'w');
%fileout=strcat('Aero',filename);   
   CID =1;               %ID coordinate start
   gID=1;                %ID GRID   start
   cID=1;                %ID CBEAM  start
   cbarID=1;             %ID CBAR   start
   cbeamID=1;            %ID CBEAM  start
   pID=1;                %ID PBEAML start
   rID=500;              %ID RBE2   start
   IDaero=1000;          %ID CAERO  start
   pAID=1000;            %ID PAERO start
   sgID=1000;            %ID SET GRID start
   spID=1000;            %ID SPLINE start
   saID=1000;            %ID SET BOX AERO start  
   asurfID=1000;         %ID AEROSURF start
   asNmSL=1;             %counter neme AEROSURF SLAT start
   asNmFL=1;             %counter neme AEROSURF FLAP start
fidsave=[pathname,filename(1:end-4) '_Aero.dat'];
%fileout=strcat(fidsave);
fp = fopen(fidsave,'w');
   fprintf(fp,'%s\n','$Aerodynamic');
   fprintf(fp,'$REF\n');
   fprintf(fp,'$END\n');
   fprintf(fp,'$AERO\n');
   CORD2R(CID,:)=[CID,0,rp(1,1)+0.4*crd(1,1),rp(1,2),rp(1,3),rp(1,1)+0.4*crd(1,1),rp(1,2),rp(1,3)-1,rp(1,1)+0.4*crd(1,1)-1,rp(1,2),rp(1,3)-1];
   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f\n%8s%8.4f%8.4f%8.4f\n',...
            'CORD2R  ',CID,0,rp(1,1)+0.4*crd(1,1),rp(1,2),rp(1,3),rp(1,1)+0.4*crd(1,1),rp(1,2),rp(1,3)-1,...
            '',rp(1,1)+0.4*crd(1,1)-1,rp(1,2),rp(1,3)-1);
   CID=CID+1;
   for i=1:Naf
       for j=1:Np(i)
           Sj(i,j) = (cord(i,j)+cord(i,j+1))/2*spn(i,j);
           cord2j(i,j)=(cord(i,j)^2+cord(i,j+1)^2)/2*spn(i,j);
           xbaj(i,j)=(cord(i,j)*x_LE(i,j)+cord(i,j+1)*x_LE(i,j+1))/2*spn(i,j);
       end   
       REFS(i) = sum(Sj(i,:))*Mirror(i);
       REFC(i) = sum(cord2j(i,:))/REFS(i)*Mirror(i);
       REFB(i) = sum(spn(i,:))*Mirror(i);      
       x_LEMAC(i)=sum(xbaj(i,:))/REFS(i)*Mirror(i);
   end
   
   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f\n','AEROS   ',0,1,REFC(1),REFB(1),REFS(1));
   AEROS=[0 1 REFC(1),REFB(1),REFS(1)];
   fprintf(fp,'%8s%8d\n','PAERO1  ',pAID);
   PAERO=pAID;
   
   
   %Materiale e proprietà della sezione strutturale
   fprintf(fp,'%8s%8d%8s%8s%8.4f%8.0f\n','MAT1    ',1,'7.2+10','',0.33,2810.);
   fprintf(fp,'$\n$Movable surface material & BAR property\n');
   fprintf(fp,'%8s%8d%8s%8s%8.4f\n'     ,'MAT1    ',2,'1+11','',0.33);
   r_BAR=min(crd(:,1))*0.05/4; A_BAR=pi*r_BAR^2; J_BAR=r_BAR^2/2;
%    fprintf(fp,'%8s%8d%8d%8.5f%8.5f%8.5f%8.5f\n','PBAR    ',pID,2,A_BAR,J_BAR/2,J_BAR/2,J_BAR); pBAR=pID;
   fprintf(fp,'%8s%8d%8d%8s%8s%8s%8s\n','PBAR    ',pID,2,'1.-10','1.-7','1.-7','1.-5'); pBAR=pID;
   fprintf(fp,'%8s%8d%8s%32s%8.2f\n', 'PBUSH   ',pID+1,'K','',1.);   pBUSH=pID+1;
   pID=pID+2;
   %cID=cID+2;
   for i=1:Naf
       fprintf(fp,'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$%8s\n',nameAf(i,:));
       for j=1:Mirror(i)*Np(i)
           fprintf(fp,'$%s %d\n','Part',j);
%CENTRAL WING       
           %Corda di riferimento alla radice ed estremità
           refC1_Af=norm([X_Af(j,2,i)-X_Af(j,1,i) Y_Af(j,2,i)-Y_Af(j,1,i) Z_Af(j,2,i)-Z_Af(j,1,i)]);
           refC2_Af=norm([X_Af(j+1,2,i)-X_Af(j+1,1,i) Y_Af(j+1,2,i)-Y_Af(j+1,1,i) Z_Af(j+1,2,i)-Z_Af(j+1,1,i)]);
           if refC1_Af>0.0001 && refC2_Af>0.0001 %flag se minore non viene inserita nel file di output
               fprintf(fp,'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$CentralWing\n');
           %Nodi di interfaccia aerodinamica struttura
               gIDSET_Af(j,1,i)=gID;
               gIDhin_Af(j,1,i)=gID+1;
               for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j 
                   h_x=h-j+1;  %puntatore sui punti interpolati
                   %GRID sull'interfaccia SLAT - WING
                   GRID(gID,:)=[gID, 0 ,x_intSL(h_x,i),y_intSL(h_x,i),z_intSL(h_x,i),0];
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,x_intSL(h_x,i),y_intSL(h_x,i),z_intSL(h_x,i),0);
                   mGID_Afa(h,1,i)=gID;                       
                   gID=gID+1;                   
                   %GRID sull'asse strutturale della WING 
                   if h==sum(Nps2(i,1:j))+j-Nps2(i,j) && j~=1
                       %GRID(gID,:)=[gID,0,x_inthAf(h_x,i),y_inthAf(h_x,i),z_inthAf(h_x,i),0];
                       %fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,x_inthAf(h_x,i),y_inthAf(h_x,i),z_inthAf(h_x,i),0);
                       mGID_Afa(h,2,i)=mGID_Afa(h-1,2,i);
                   else                       
                       GRID(gID,:)=[gID,0,x_inthAf(h_x,i),y_inthAf(h_x,i),z_inthAf(h_x,i),0];
                       fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,x_inthAf(h_x,i),y_inthAf(h_x,i),z_inthAf(h_x,i),0);
                       mGID_Afa(h,2,i)=gID;
                       gID=gID+1;
                   end
                       
                   %GRID sull'interfaccia WING - FLAP
                   GRID(gID,:)=[gID,0,x_intFL(h_x,i),y_intFL(h_x,i),z_intFL(h_x,i),0];
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,x_intFL(h_x,i),y_intFL(h_x,i),z_intFL(h_x,i),0);
                   mGID_Afa(h,3,i)=gID;
                   gID=gID+1;
                   if struct2(i,j)==2 || struct2(i,j)==4 || struct2(i,j)==5 || struct2(i,j)==6
                       if h>sum(Nps2(i,1:j))+j-Nps2(i,j) && struct2(i,j)==2
                           Width1 =(x_intTE(h_x,i)-x_intLE(h_x,i))*strWidthAf2(i,j);   Width2 =(x_intTE(h_x-1,i)-x_intLE(h_x-1,i))*strWidthAf2(i,j);   
                           Height1=(x_intTE(h_x,i)-x_intLE(h_x,i))*strHeightAf2(i,j);  Height2=(x_intTE(h_x-1,i)-x_intLE(h_x-1,i))*strHeightAf2(i,j);
                           Thick1 =strThickAf2(i,j);                                   Thick2 =strThickAf2(i,j);
                           %Scrittura della proprietà BEAM e del suo elemento          
                           PBEAM_BOX(fp,pID,1,[Height2 Height1]',[Thick1 Thick1]',[Width2 Width1]',[Thick2 Thick2]',[0 0])
                           %PBEAM()
                           %vettore elemento
                           vBEAM=cross([GRID(mGID_Afa( h ,2,i),3)-GRID(mGID_Afa(h-1,2,i),3),GRID(mGID_Afa( h ,2,i),4)-GRID(mGID_Afa(h-1,2,i),4),GRID(mGID_Afa( h ,2,i),5)-GRID(mGID_Afa(h-1,2,i),5)],...
                                       [GRID(mGID_Afa(h-1,1,i),3)-GRID(mGID_Afa(h-1,2,i),3),GRID(mGID_Afa(h-1,1,i),4)-GRID(mGID_Afa(h-1,2,i),4),GRID(mGID_Afa(h-1,1,i),5)-GRID(mGID_Afa(h-1,2,i),5)]);
                           vBEAM=vBEAM/norm(vBEAM);
                           CBEAM(cbeamID,:)=[cID,pID,mGID_Afa(h-1,2,i),mGID_Afa(h,2,i),vBEAM(1),vBEAM(2),vBEAM(3)]; cbeamID=cbeamID+1;
                           fprintf(fp,'%8s%8d%8d%8d%8d%8.4f%8.4f%8.4f\n','CBEAM   ',cID,pID,mGID_Afa(h-1,2,i),mGID_Afa(h,2,i),vBEAM(1),vBEAM(2),vBEAM(3));
                                

                           cID=cID+1;
                           pID=pID+1;
                       end
                   end
                   
%                    gIDRlineAf(h,1:3,i)=[gID-3,gID-2,gID-1];
                    gIDRlineAf(h,1:3,i)=mGID_Afa(h,:,i);
               end
               gIDSET_Af(j,2,i)=gID-1;   %set grid della parte 
               gIDhin_Af(j,2,i)=gID-2;   %Grid sull'asse delle cerniere agli estremi 
               %RBE2 di collegamento aerodinamica struttura
               fprintf(fp,'$Inerface Element RBE2 Grid-AeroShell\n');
               for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j  
                   fprintf(fp,'%8s%8d%8d%8d%8d%8d\n','RBE2    ',rID,gIDRlineAf(h,2,i),123456,gIDRlineAf(h,1,i),gIDRlineAf(h,3,i));
                   rID=rID+1;
               end
               
               
               %Shell aerodinamica
               fprintf(fp,'$Aerodynamic Shell\n');
               fprintf(fp,'%8s%8d%8d%8d%8d%8d%8s%8s%8d\n%8s%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f\n',...
                          'CAERO1  ',IDaero,pAID,0,Nps2(i,j),Npc(i,2),'','',1,...
                          '',X_Af( j ,1,i),Y_Af( j ,1,i),Z_Af( j ,1,i),refC1_Af,...
                             X_Af(j+1,1,i),Y_Af(j+1,1,i),Z_Af(j+1,1,i),refC2_Af);              
               
               %Set dei nodi di interfaccia
               fprintf(fp,'$Grid Set & Spline\n');
               fprintf(fp,'%8s%8d%8d%8s%8d\n','SET1    ',sgID,gIDSET_Af(j,1,i),'    THRU',gIDSET_Af(j,2,i));
               
               %Spline AeroShell-Grid
               fprintf(fp,'%8s%8d%8d%8d%8d%8d\n','SPLINE1 ',spID,IDaero,IDaero,IDaero+Nps2(i,j)*Npc(i,2)-1,sgID);
               
               sgID=sgID+1;
               spID=spID+1;
               IDaero=IDaero+Nps2(i,j)*Npc(i,2)+1;
           end
%SLAT
           %Da riscrivere xchè troppo cambiato
            
%FLAP
           refC1_FL=norm([X_FL(j,2,i)-X_FL(j,1,i) Y_FL(j,2,i)-Y_FL(j,1,i) Z_FL(j,2,i)-Z_FL(j,1,i)]);
           refC2_FL=norm([X_FL(j+1,2,i)-X_FL(j+1,1,i) Y_FL(j+1,2,i)-Y_FL(j+1,1,i) Z_FL(j+1,2,i)-Z_FL(j+1,1,i)]);
           if refC1_FL>0.0001 && refC2_FL>0.0001
               fprintf(fp,'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\n$Flap\n');
           %Nodi di interfaccia aerodinamica struttura
               gIDSET_FL(j,1,i)=gID;
               gIDhin_FL(j,1,i)=gID+1;
               for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j  
                   h_x=h-j+1;  %puntatore sui punti interpolati
                   GRID(gID,:)=[gID,0,x_intFL(h_x,i),y_intFL(h_x,i),z_intFL(h_x,i),0];
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,x_intFL(h_x,i),y_intFL(h_x,i),z_intFL(h_x,i),0);
                   mGID_FLa(h,1,i)=gID;
                   gID=gID+1;                   
                   
                   GRID(gID,:)=[gID,0,x_inthFL(h_x,i),y_inthFL(h_x,i),z_inthFL(h_x,i),0];
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,x_inthFL(h_x,i),y_inthFL(h_x,i),z_inthFL(h_x,i),0);
                   mGID_FLa(h,2,i)=gID;
                   gID=gID+1;     
                   
                   GRID(gID,:)=[gID,0,x_intTE(h_x,i),y_intTE(h_x,i),z_intTE(h_x,i),0];
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,x_intTE(h_x,i),y_intTE(h_x,i),z_intTE(h_x,i),0);
                   mGID_FLa(h,3,i)=gID;
                   gID=gID+1;    
                   
                   gIDRlineFL(h,1:3,i)=[gID-3,gID-2,gID-1];
                   
                   if strcmp(nameMFL{i,j},'fix')==0 && h>sum(Nps2(i,1:j))+j-Nps2(i,j) && struct2(i,j)==2
                       %BAR di collegamento
                       vBAR=cross([GRID(mGID_FLa( h ,2,i),3)-GRID(mGID_FLa(h-1,2,i),3),GRID(mGID_FLa( h ,2,i),4)-GRID(mGID_FLa(h-1,2,i),4),GRID(mGID_FLa( h ,2,i),5)-GRID(mGID_FLa(h-1,2,i),5)],...
                                  [GRID(mGID_FLa(h-1,1,i),3)-GRID(mGID_FLa(h-1,2,i),3),GRID(mGID_FLa(h-1,1,i),4)-GRID(mGID_FLa(h-1,2,i),4),GRID(mGID_FLa(h-1,1,i),5)-GRID(mGID_FLa(h-1,2,i),5)]);
                       vBAR=vBAR/norm(vBAR);
                       CBAR(cbarID,:)=[cID,pBAR,mGID_FLa(h-1,2,i),mGID_FLa(h,2,i),vBAR(1),vBAR(2),vBAR(3)]; cbarID=cbarID+1;
                       fprintf(fp,'%8s%8d%8d%8d%8d%8.4f%8.4f%8.4f\n','CBAR    ',cID,pBAR,mGID_FLa(h-1,2,i),mGID_FLa(h,2,i),vBAR(1),vBAR(2),vBAR(3));
                       
                       cID=cID+1;
                   end
               end
               gIDSET_FL(j,2,i)=gID-1; 
               gIDhin_FL(j,2,i)=gID-2;
               %RBE2 di collegamento aerodinamica struttura
               fprintf(fp,'$Inerface Element RBE2 Grid-AeroShell\n');
               for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j  
                   fprintf(fp,'%8s%8d%8d%8d%8d%8d\n','RBE2    ',rID,gIDRlineFL(h,2,i),123456,gIDRlineFL(h,1,i),gIDRlineFL(h,3,i));
                   rID=rID+1;
               end
               if strcmp(nameMFL(i,j),'fix')==0                   
                   %Cerniere sferiche
                   fprintf(fp,'$Spherical Hinge Element RBE2 Structure-hingeMovableSurface\n');
                   %Coordinate sistem
                   A=[x_hFL(i,j) y_hFL(i,j) z_hFL(i,j)]';
                   B=A+cross([x_TE(i,j+1) y_TE(i,j+1) z_TE(i,j+1)]'-A,[x_hFL(i,j+1) y_hFL(i,j+1) z_hFL(i,j+1)]'-A);
                   C=A+cross([x_hFL(i,j+1) y_hFL(i,j+1) z_hFL(i,j+1)]'-A,B);
                   CORD2R(CID,:)=[CID,0,A(1),A(2),A(3),B(1),B(2),B(3),C(1),C(2),C(3)];
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f\n%8s%8.4f%8.4f%8.4f\n','CORD2R  ',CID,0,A(1),A(2),A(3),B(1),B(2),B(3),'',C(1),C(2),C(3));
                   
                   %1^ cerniera
                   %nodo master di cerniera
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,GRID(gIDhin_FL(j,1,i),2),GRID(gIDhin_FL(j,1,i),3),GRID(gIDhin_FL(j,1,i),4),GRID(gIDhin_FL(j,1,i),5),GRID(gIDhin_FL(j,1,i),6));
                   gIDhin_FLmaster(j,1,i)=gID;
                   gID=gID+1;
                   %RBE2 collegamento ala Flap
                   fprintf(fp,'%8s%8d%8d%8d%8d\n','RBE2    ',rID,gIDhin_Af(j,1,i)   ,123456,  gIDhin_FLmaster(j,1,i));
                   rID=rID+1;
                   %RBE2 cernira sferica
                   fprintf(fp,'%8s%8d%8d%8d%8d\n','RBE2    ',rID,gIDhin_FLmaster(j,1,i),123,  gIDhin_FL(j,1,i));
                   rID=rID+1;
                   %molla torsionale
                   fprintf(fp,'%8s%8d%8d%8d%8d%24s%8d\n','CBUSH   ',cID,pBUSH,gIDhin_FLmaster(j,1,i),gIDhin_FL(j,1,i),'',CID);
                   cID=cID+1;
                   
                   fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,GRID(gIDhin_FL(j,2,i),2),GRID(gIDhin_FL(j,2,i),3),GRID(gIDhin_FL(j,2,i),4),GRID(gIDhin_FL(j,2,i),5),GRID(gIDhin_FL(j,2,i),6));
                   gIDhin_FLmaster(j,2,i)=gID;
                   gID=gID+1;
                   %RBE2 collegamento ala Flap
                   fprintf(fp,'%8s%8d%8d%8d%8d\n','RBE2    ',rID,gIDhin_Af(j,2,i)   ,123456,  gIDhin_FLmaster(j,2,i));
                   rID=rID+1;
                   %RBE2 cernira sferica
                   fprintf(fp,'%8s%8d%8d%8d%8d\n','RBE2    ',rID,gIDhin_FLmaster(j,2,i),123,  gIDhin_FL(j,2,i));
                   rID=rID+1;
                   %molla torsionale
                   fprintf(fp,'%8s%8d%8d%8d%8d%24s%8d\n','CBUSH   ',cID,pBUSH,gIDhin_FLmaster(j,2,i),gIDhin_FL(j,2,i),'',CID);
                   cID=cID+1;
                   CID=CID+1;
               else
                   %ceniere bloccate
                   fprintf(fp,'$Fix Hinge Element RBE2 Structure-hingeMovableSurface\n');
                   fprintf(fp,'%8s%8d%8d%8d%8d\n','RBE2    ',rID+1,gIDhin_Af(j,1,i),123456,gIDhin_FL(j,1,i));
                   fprintf(fp,'%8s%8d%8d%8d%8d\n','RBE2    ',rID+2,gIDhin_Af(j,2,i),123456,gIDhin_FL(j,2,i));
                   rID=rID+3;
          
               end
               %Shell aerodinamica
               fprintf(fp,'$Aerodynamic Shell\n');
               fprintf(fp,'%8s%8d%8d%8d%8d%8d%8s%8s%8d\n%8s%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f\n',...
                          'CAERO1  ',IDaero,pAID,0,Nps2(i,j),Npc(i,3),'','',1,...
                          '',X_FL( j ,1,i),Y_FL( j ,1,i),Z_FL( j ,1,i),refC1_FL,...
                             X_FL(j+1,1,i),Y_FL(j+1,1,i),Z_FL(j+1,1,i),refC2_FL);           
               
               %Set dei nodi di interfaccia
               fprintf(fp,'$Grid Set & Spline\n');
               fprintf(fp,'%8s%8d%8d%8s%8d\n','SET1    ',sgID,gIDSET_FL(j,1,i),'    THRU',gIDSET_FL(j,2,i));               
               %Spline AeroShell-Grid
               fprintf(fp,'%8s%8d%8d%8d%8d%8d\n','SPLINE1 ',spID,IDaero,IDaero,IDaero+Nps2(i,j)*Npc(i,3)-1,sgID);
               
               if strcmp(nameMFL(i,j),'fix')==0
                   %Movable Aerodynamic Surface
                   

                   %fprintf(fp,'%8s%8d%8d%8s%8d\n','AELIST  ',saID,IDaero,'    THRU',IDaero+Nps2(i,j)*Npc(i,3)-1);
                   fprintf(fp,'%8s%8d','AELIST  ',saID); 
                   row=1; count=IDaero-1; column=3;
                   while count< IDaero+Nps2(i,j)*Npc(i,3)-1
                       while column<=9 && count< IDaero+Nps2(i,j)*Npc(i,3)-1
                           count=count+1; column=column+1;
                           fprintf(fp,'%8d',count);
                       end
                       fprintf(fp,'\n%8s','');
                       column=2;
                   end
                   fprintf(fp,'\n');
                           
                       
%                    CREFC=(x_TE(i,j)-x_FL(i,j)+x_TE(i,j+1)-x_FL(i,j+1))/2;
%                    if plane(i)==1
%                         CREFS=(x_TE(i,j)-x_FL(i,j)+x_TE(i,j+1)-x_FL(i,j+1))/2*(y_TE(i,j+1)-y_TE(i,j));
%                    elseif plane(i)==3
%                         CREFS=(x_TE(i,j)-x_FL(i,j)+x_TE(i,j+1)-x_FL(i,j+1))/2*(z_TE(i,j+1)-z_TE(i,j));
%                    end
%                    fprintf(fp,'%8s%8d%8s%8d%8d%8s%8s%8s%8s\n%8s%8.4f%8.4f%8.4f%8.4f\n',...
%                                 'AESURF  ',asurfID,char(nameMFL(i,j)),CID-1,saID,'','','','','',CREFC,CREFS,-30*rad,30*rad);
                   fprintf(fp,'%8s%8d%8s%8d%8d%8s%8s%8s%8s\n%8s%8.4f%8.4f%8.4f%8.4f\n',...
                                'AESURF  ',asurfID,char(nameMFL(i,j)),CID-1,saID,'','','','','',REFC(i),REFS(i),-20*rad,20*rad);
               end
               
               sgID=sgID+1;
               spID=spID+1;
               saID=saID+1;
               IDaero=IDaero+Nps2(i,j)*Npc(i,3)+1;
               
               asurfID=asurfID+1;
               asNmFL =asNmFL +1;
           end
       
       
       end
   
       fprintf(fp,'\n');
   end
   fprintf(fp,'$END');
   fclose(fp);
%    %type fileout 
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    % SAVE WORK SPACE
%    fidWorkSpace=[pathname,filename(1:end-4) '.mat'];
%    save(fidWorkSpace,'GRID','mGID_Afa','mGID_FLa','cord');
%    
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    fidFuel=[pathname,filename(1:end-4) 'cm_Fuel.mat'];
%    fp=fopen(fidFuel,'w');
%         Mfuel=2682;
%         
%    fclose(fp);
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %FILE INPUT NASTRAN
   fidTrim=[pathname,filename(1:end-4) '_Trim.dat'];
   fp = fopen(fidTrim,'w');
   %fp=fopen('Trim_1.bdf','w');
   fprintf(fp,'%s\n','ID Untitled,FEMAP');
   fprintf(fp,'%s\n','SOL 146');
   fprintf(fp,'%s\n','TIME 10000');
   fprintf(fp,'%s\n','CEND');
   fprintf(fp,'%s\n','ECHO  =SORT');
   fprintf(fp,'%s\n',' METHOD=1');
   fprintf(fp,'%s\n',' DLOAD=2');
   fprintf(fp,'%s\n',' FREQ=40');
   fprintf(fp,'%s\n',' TSTEP=41');
   fprintf(fp,'%s\n',' SET 1=5,24,187');
   fprintf(fp,'%s\n',' DISP=ALL');
   fprintf(fp,'%s\n','BEGIN BULK');
   
   fprintf(fp,'%s\n','PARAM,OPPHIPA,1');
   fprintf(fp,'%s\n','PARAM,AUTOSPC,YES');
   fprintf(fp,'%s\n','PARAM,GRDPNT,0');
   fprintf(fp,'%s\n','PARAM,POST,-1');
   fprintf(fp,'%s\n','PARAM,PRGPST,NO');
 
   astID=5001;
   dof_M=['  ANGLEA';...
          '   SIDES';...
          '    ROLL';...
          '   PITCH';...
          '     YAW'];
   TRIM_M=1;
   fprintf(fp,'%8s%8d%8s\n','AESTAT  ',astID,dof_M(TRIM_M,:));
   VELOCITY=100;
   RHOREF=1.225;
   SoundVel=sqrt(1.4*287*288);
   mach=VELOCITY/SoundVel;
   rfreq=[0.001 0.02 0.1 0.5];
   fprintf(fp,'%8s%8d%8.3f%8.4f%8.4f\n','AERO    ',0,VELOCITY,REFC,RHOREF);
   
   fprintf(fp,'%8s%8.4f\n%8s%8.4f%8.4f%8.4f%8.4f\n','MKAERO1 ',mach,'',rfreq(1),rfreq(2),rfreq(3),rfreq(4));
   
   fprintf(fp,'%s\n',['INCLUDE ' '''Aero.dat''']);
   fclose(fp);
   %type Trim_1.bdf
   
   
  
  %FILE DI INPUT A PATRAN PER LA VISUALIZZAZIONE DEI PANNELLI AERODINAMICI
  fiddisp=[pathname,filename(1:end-4) '_Disp.dat'];  
  %fileout=strcat();
   fp = fopen(fiddisp,'w');
   %fp = fopen('DispAero.dat','w');
   fprintf(fp,'$VisualizzazioneAerodinamica\n');
   
   mID=10000; 
   pID=10000;
   
   gID=10000;
   eID=gID+10000;
   
   fprintf(fp,'%8s%8d%8.4f\n'   ,'MAT1    ',mID,1);
   %fprintf(fp,'%8s%8d%8d%8.4f\n','PSHELL  ',pID,mID,0.001);
   
   for i=1:Naf
       fprintf(fp,'$%8s\n',nameAf(i,:));
       
       for j=1:Mirror(i)*Np(i);
           
           fprintf(fp,'$Part %d\n',j);
           if Npc(i,1)>0
               fprintf(fp,'$Slat\n');
               fprintf(fp,'%8s%8d%8d%8.4f\n','PSHELL  ',pID,mID,0.001);                  
               for k=1:Npc(i,1)+1
                    for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j 
                        h_x=h-j+1;  %puntatore sui punti interpolati
                        if k==1 
                            mGID_SL(h,k,i)=gIDRlineSL(h,1,i);
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',mGID_SL(h,k,i),0,XX_SL(h_x,k,i),YY_SL(h_x,k,i),ZZ_SL(h_x,k,i),0);
                        elseif k==Npc(i,1)+1
                            mGID_SL(h,k,i)=gIDRlineSL(h,3,i);
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',mGID_SL(h,k,i),0,XX_SL(h_x,k,i),YY_SL(h_x,k,i),ZZ_SL(h_x,k,i),0);                     
                        else                            
                            mGID_SL(h,k,i)=gID;
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',mGID_SL(h,k,i),0,XX_SL(h_x,k,i),YY_SL(h_x,k,i),ZZ_SL(h_x,k,i),0);
                            gID=gID+1;
                        end
                    end
               end
               for k=1:Npc(i,1)
                    for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j-1
                        fprintf(fp,'%8s%8d%8d%8d%8d%8d%8d\n','CQUAD4  ',eID,pID,mGID_SL(h,k,i),mGID_SL(h+1,k,i),mGID_SL(h+1,k+1,i),mGID_SL(h,k+1,i));
                        mEID_SL(h,k,i)=eID;
                        eID=eID+1;
                    end
               end
               pID=pID+1;
           end
           
           if Npc(i,2)>0
               fprintf(fp,'$CentralWing\n');
               fprintf(fp,'%8s%8d%8d%8.4f\n','PSHELL  ',pID,mID,0.001);
               for k=1:Npc(i,2)+1
                    for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j
                        h_x=h-j+1;  %puntatore sui punti interpolati
                        if k==1
                            mGID_Af(h,k,i)=gIDRlineAf(h,1,i);
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',mGID_Af(h,k,i),0,XX_Af(h_x,k,i),YY_Af(h_x,k,i),ZZ_Af(h_x,k,i),0);
                        elseif k==Npc(i,2)+1
                            mGID_Af(h,k,i)=gIDRlineAf(h,3,i);
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',mGID_Af(h,k,i),0,XX_Af(h_x,k,i),YY_Af(h_x,k,i),ZZ_Af(h_x,k,i),0); 
                        else
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,XX_Af(h_x,k,i),YY_Af(h_x,k,i),ZZ_Af(h_x,k,i),0);
                            mGID_Af(h,k,i)=gID;
                            gID=gID+1;  
                        end
                    end
               end         
               for k=1:Npc(i,2)
                    for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j-1
                        fprintf(fp,'%8s%8d%8d%8d%8d%8d%8d\n','CQUAD4  ',eID,pID,mGID_Af(h,k,i),mGID_Af(h+1,k,i),mGID_Af(h+1,k+1,i),mGID_Af(h,k+1,i));
                        mEID_Af(h,k,i)=eID;
                        eID=eID+1;
                    end
               end
               pID=pID+1;
           end
           
           if Npc(i,3)>0
               fprintf(fp,'$Flap\n');
               fprintf(fp,'%8s%8d%8d%8.4f\n','PSHELL  ',pID,mID,0.001);
               for k=1:Npc(i,3)+1
                    for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j
                        h_x=h-j+1;  %puntatore sui punti interpolati
                        if k==1
                            mGID_FL(h,k,i)=gIDRlineFL(h,1,i);
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',mGID_FL(h,k,i),0,XX_FL(h_x,k,i),YY_FL(h_x,k,i),ZZ_FL(h_x,k,i),0);
                        elseif k==Npc(i,3)+1
                            mGID_FL(h,k,i)=gIDRlineFL(h,3,i);
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',mGID_FL(h,k,i),0,XX_FL(h_x,k,i),YY_FL(h_x,k,i),ZZ_FL(h_x,k,i),0); 
                        else
                            fprintf(fp,'%8s%8d%8d%8.4f%8.4f%8.4f%8d\n','GRID    ',gID,0,XX_FL(h_x,k,i),YY_FL(h_x,k,i),ZZ_FL(h_x,k,i),0);
                            mGID_FL(h,k,i)=gID;
                            gID=gID+1;  
                        end
                    end
               end
               for k=1:Npc(i,3)
                    for h=sum(Nps2(i,1:j))+j-Nps2(i,j):sum(Nps2(i,1:j))+j-1
                        fprintf(fp,'%8s%8d%8d%8d%8d%8d%8d\n','CQUAD4  ',eID,pID,mGID_FL(h,k,i),mGID_FL(h+1,k,i),mGID_FL(h+1,k+1,i),mGID_FL(h,k+1,i));
                        mEID_FL(h,k,i)=eID;
                        eID=eID+1;
                    end
               end
               pID=pID+1;
           end
                    

       end
   end
   
   fclose(fp);
%    %type DispAero.dat  
            
