function [aircraft]=refGen(aircraft)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Generate references                                                   % 
%   Code Base on Tornado (flattice_setup2)                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-02-10 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

geo=aircraft.wings;

warning off

for  wingNum=1:size(geo.nelem,2)
%% Reference Area

    for t=1:size(geo.b,2)
        S(wingNum,t)=geo.b(wingNum,t)*geo.c(wingNum,t)*((1+geo.T(wingNum,t)))/2;
        Cmgc(wingNum,t)=S(wingNum,t)/geo.b(wingNum,t);
        if geo.symetric(wingNum)==1
             S(wingNum,t)=S(wingNum,t)*2;
        end
    end

    S_ref(wingNum)=sum(S(wingNum,:));

%% Mean Geometric Chord

    for t=1:size(geo.b,2)
        Cmgc(wingNum,t)=S(wingNum,t)/geo.b(wingNum,t);
    end

    C_m(wingNum,:)=sum(Cmgc(wingNum,:).*S(wingNum,:),2);	
    C_mgc(wingNum)=C_m(wingNum,:)/S_ref(wingNum);

%% Mean Aerodynamic Chord

    SX(wingNum,1)=geo.startx(wingNum);	
    SY(wingNum,1)=geo.starty(wingNum);	
    SZ(wingNum,1)=geo.startz(wingNum); 


    for t=1:size(geo.b,2)    
        SX(wingNum,t+1)=0.25*geo.c(wingNum,t)+geo.b(wingNum,t)*(tan(geo.SW(wingNum,t)))...
                        -0.25*geo.c(wingNum,t+1)+SX(wingNum,t) ;					
        SY(wingNum,t+1)=geo.b(wingNum,t)*cos(geo.dihed(wingNum,t))+SY(wingNum,t);   
        SZ(wingNum,t+1)=geo.b(wingNum,t)*sin(geo.dihed(wingNum,t))+SZ(wingNum,t);
    end


    for i=1:length(find(geo.b(wingNum,:)>0))
        T(wingNum,i)=geo.c(wingNum,i+1)/geo.c(wingNum,i);									
        Cb=geo.c(wingNum,i);										
        Ct=geo.c(wingNum,i+1);		

        b_mac(i)=geo.b(wingNum,i)*(2*Ct+Cb)/(3*(Ct+Cb));
        Cmac(i)=Cb-(Cb-Ct)/geo.b(wingNum,i)*b_mac(i);

        Cmac(find(isnan(Cmac)))=0; 

        start(i,1)=0.25*Cb+b_mac(i)*tan(geo.SW(wingNum,i))-0.25*Cmac(i)+SX(wingNum,i);
        start(i,2)=cos(geo.dihed(wingNum,i))*b_mac(i)+SY(wingNum,i);
        start(i,3)=sin(geo.dihed(wingNum,i))*b_mac(i)+SZ(wingNum,i);

    end

    if geo.symetric(wingNum)
       start(:,2)=0;  
    end

    A=(1+T(wingNum)).*geo.c(wingNum,1:end-1).*geo.b(wingNum,:)./2;
    % Cut zeros
    A=A(1:size(Cmac,2));
    
    C_mac(wingNum)=sum(Cmac.*A)./sum(A);					
    mac_pos(wingNum,1)=sum((start(:,1).*A')./sum(A));   		
    mac_pos(wingNum,2)=sum((start(:,2).*A')./sum(A));
    mac_pos(wingNum,3)=sum((start(:,3).*A')./sum(A));   		
end

warning on
%% Save

aircraft.ref.S_ref      = S_ref(1);
aircraft.ref.C_mgc      = C_mgc(1);
aircraft.ref.C_mac      = C_mac(1);
aircraft.ref.mac_pos    = mac_pos(1,:);

aircraft.ref.S_refi      = S_ref;
aircraft.ref.C_mgci      = C_mgc;
aircraft.ref.C_maci      = C_mac;
aircraft.ref.mac_posi    = mac_pos;

