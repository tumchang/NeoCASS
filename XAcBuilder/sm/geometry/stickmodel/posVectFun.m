%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mode 1
%   varargin{1} = pnt0
%   varargin{2} = n
%   varargout   = PosVect
% mode 2
%   varargin{1} = vect
%   varargin{2} = n
%   varargout   = PosVect 
% mode 2
%   varargin{1} = PosVect
%   varargin{2} = etaS
%   varargout   = C 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output]=posVectFun(mode,PLOT,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kk=1
%     for kkk=1
%         close all, clear all, clc
%         mode=1;
%         % pnt0
%         varargin{1}=[0 0 0;...
%                      1 1 0;...
%                      2 1 1;...
%                      3 0 1];
%         % n
%         varargin{2}=[1 0 0]';
%         PLOT=1;
%     end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     for kkk=1
%         close all, clear all, clc
%         mode=2;
%         %vect
%         varargin{1}=[0         1.9750    0     ;...
%                      2.0698    3.1752    0.2778;...
%                      5.8599    8.9562    1.0997;...
%                      0.5384    0.6351    0.5329;...
%                      0.5412    0.2851    0.7832;...
%                      0.7082    0.0000    1.0905;...
%                      0.5412   -0.2851    0.7832;...
%                      0.5384   -0.6351    0.5329;...
%                      6.7535  -10.3219    1.2674;...
%                      0.5996   -3.7850    0.0661]; 
%         %n
%         varargin{2}=[1         0         0     ]';
%         PLOT=1;
%     end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     for kkk=1
%     close all, clear all, clc
%     mode=3;
%     PosVect.vect=[0         1.9750    0     ;...
%                   2.0698    3.1752    0.2778;...
%                   5.8599    8.9562    1.0997;...
%                   0.5384    0.6351    0.5329;...
%                   0.5412    0.2851    0.7832;...
%                   0.7082    0.0000    1.0905;...
%                   0.5412   -0.2851    0.7832;...
%                   0.5384   -0.6351    0.5329;...
%                   6.7535  -10.3219    1.2674;...
%                   0.5996   -3.7850    0.0661]; 
%     PosVect.pnt0=[0         0         0;...  
%                   0    1.9750         0;...  
%                   2.0698    5.1502    0.2778;...  
%                   7.9297   14.1064    1.3775;...  
%                   8.4681   14.7415    1.9104;...  
%                   9.0093   15.0266    2.6936;...  
%                   9.7175   15.0266    3.7841;...  
%                  10.2587   14.7415    4.5673;...  
%                  10.7971   14.1064    5.1002;...  
%                  17.5506    3.7845    6.3676;...  
%                  18.1502   -0.0005    6.4337];    
%     PosVect.n   =[1         0         0     ]';
%     PosVect.pntP=[0         0         0;... 
%                   0         1.9750    0;... 
%                   0         5.1502    0.2778;... 
%                   0        14.1064    1.3775;... 
%                   0        14.7415    1.9104;... 
%                   0        15.0266    2.6936;... 
%                   0        15.0266    3.7841;... 
%                   0        14.7415    4.5673;... 
%                   0        14.1064    5.1002;... 
%                   0         3.7845    6.3676;... 
%                   0        -0.0005    6.4337];   
%     PosVect.li  =[0    1.9750    3.1873    9.0235    0.8291    0.8335    1.0905    0.8335    0.8291   10.3994    3.7856]';
%     PosVect.sl  =[0    1.9750    5.1623   14.1858   15.0148   15.8483   16.9388   17.7723   18.6014   29.0008   32.7864]';
%     PosVect.L   =32.7864;
%     PosVect.eta =[0    0.0602    0.1575    0.4327    0.4580    0.4834    0.5166    0.5421    0.5674    0.8845    1.0000]';
% 
%     etaS        =0.8;
%     PLOT=1;
%     end
 end
%% Generate Positioning Vector Structure
if mode==1 
    % point mode
    for kk=1
    % Initialize
        pnt0=varargin{1};
        n   =varargin{2};
        N=length(pnt0(:,1));
        vect=zeros(N-1,3);
        t   =zeros(N  ,3); % is defined for each point
        pntP=zeros(N,3); pntP(1,:)=pnt0(1,:);
        li  =zeros(N,1);
        sl  =zeros(N,1);
        eta =zeros(N,1);       
    % Point generation & projection    
        % projector matrix
        prj=eye(3)-n*n';
        % point &  
        for i=2:N
%             i
%             pnt0(i,:)',pnt0(i-1,:)'
            vect(i-1,:)=(pnt0(i,:)'-pnt0(i-1,:)')';  
            t(i-1,:)=vect(i-1,:)/norm(vect(i-1,:)); %tangent versor(vect)
            pntP(i,:)=(prj*pnt0(i,:)')';                  %projected points (on plane n)
%             pntP(i,:)=(prj*pnt0(i,:)'+pnt0(1,:)')';                  %projected points (on plane n)
            li(i)=norm(pntP(i,:)'-pntP(i-1,:)');          
            sl(i)=sl(i-1)+li(i);
        end
        t(N,:)=t(N-1,:);  %the last point has the same versor of previous point
        L=sl(end);
        for i=2:N, eta(i)=sl(i)/L; end
    % Joint info in a structure
        PosVect.vect=vect;
        PosVect.t=t;
        PosVect.pnt0=pnt0;
        PosVect.n   =n;
        PosVect.pntP=pntP;
        PosVect.li  =li;
        PosVect.sl  =sl;
        PosVect.L   =L;
        PosVect.eta =eta;
    end
    output=PosVect;
%%
elseif mode==2
    % vector mode
    for kk=1
    % Initialize
        vect=varargin{1};
        n   =varargin{2};
        N=length(vect(:,1))+1;
        pnt0=zeros(N,3);
        pntP=zeros(N,3);
        li  =zeros(N,1);
        sl  =zeros(N,1);
        eta =zeros(N,1);        
    % Point generation & projection    
        % projector matrix
        prj=eye(3)-n*n';
        % point &  
        for i=2:N
            pnt0(i,:)=[sum(vect(1:i-1,1)),sum(vect(1:i-1,2)),sum(vect(1:i-1,3))];    
            pntP(i,:)=(prj*pnt0(i,:)')';  
            li(i)=norm(pntP(i,:)'-pntP(i-1,:)');
            sl(i)=sl(i-1)+li(i);
        end    
        L=sl(end);
        for i=2:N, eta(i)=sl(i)/L; end
    % Joint info in a structure
        PosVect.vect=vect;
        PosVect.pnt0=pnt0;
        PosVect.n   =n;
        PosVect.pntP=pntP;
        PosVect.li  =li;
        PosVect.sl  =sl;
        PosVect.L   =L;
        PosVect.eta =eta;        
    end
    output=PosVect;
elseif mode==3
%% Find position on a existing Positioning Vector 
    for kk=1
        PosVect=varargin{1};
        etaS   =varargin{2};
        ieta=1;
        while PosVect.eta(ieta)<etaS            
            ieta=ieta+1;
        end
        if ieta~=1
            ieta=ieta-1;
        end
        C=((PosVect.pnt0(ieta+1,:)'-PosVect.pnt0(ieta,:)')*(etaS-PosVect.eta(ieta))+PosVect.pnt0(ieta,:)')';
    end
    output{1}=C;
    output{2}=ieta;
end        
%% Plot 
if PLOT
    %hold on, axis equal    
    plot3(PosVect.pnt0(:,1),PosVect.pnt0(:,2),PosVect.pnt0(:,3),'b')  
    plot3(PosVect.pntP(:,1),PosVect.pntP(:,2),PosVect.pntP(:,3),'r')
    if mode==3        
        plot3([PosVect.pnt0(1:ieta,1);C(1)],[PosVect.pnt0(1:ieta,2);C(2)],[PosVect.pnt0(1:ieta,3);C(3)],'g','Linewidth',3)
    end
end
