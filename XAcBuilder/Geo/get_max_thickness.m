function thickness = get_max_thickness(airfoil)
if isempty(strfind(airfoil,'.dat'))
    foil=str2double(airfoil);
    m=fix(foil/1000);	%gives first NACA-4 number
    lemma=foil-m*1000;
    p=fix(lemma/100);	%gives second NACA-4 number
    t=foil-m*1000-p*100; %gives the third NACA 4 number
    
    p=p/10;
    m=m/100;
    t=t/100;
   
        
   xa=0:0.01:1;     
   yt = zeros(1,101);
   yc = zeros(1,101);
   A = zeros(2*101,2);
   for i=1:101
       yt(i)=t/0.2*(0.2969*sqrt(xa(i)) -0.1260*xa(i)-0.3516*xa(i)^2 +0.2843*xa(i)^3 -0.1015*xa(i)^4 );
        if xa(i)<p
        yc(i)=(m/(p^2)*(p-xa(i)))*xa(i);  
        else
        yc(i)=m/((1-p)^2)*((1-2*p)+2*p*xa(i)-xa(i)^2);  
        end
   end
   
   for i=1:101
        A(i,1)=1-xa(i);
        A(i,2)=yc(102-i)+yt(102-i);
        A(101+i,1)=xa(i);
        A(101+i,2)=yc(i)-yt(i);
   end
else
%     A=load(fullfile('..','airfoil',airfoil));
      A=load(airfoil);
end

% Check if the first line describe the number of data points or if it
% starts directly with the data points
if (A(1,1)>1 || A(1,2)>1)
    Nup=A(1,1);
    increment=1; %Increment is an indicator of if one needs to consider the first row or if this first row gives the number of points and thus do not describe the airfoil
else
    Nup=round(length(A(:,1))/2);
    increment=0;
end


%%% Upper surface
% Get the input points and normalize them by the max X
Xup_input=A(1+increment:Nup+increment,1)/max(A(1+increment:end,1));
    
% Check that there are not too many points
if (length(A(:,1))>250)
    Xup_data=0:0.01:1; % If there are too many points just take equally spaced 101 points
else
    %  get points  from Trailing Edge to Leading Edge
    Xup_data=Xup_input';
end

% Check that the points are ordered froö TE to LE for the upper surface
if (Xup_data(1)>Xup_data(end))
    Xup=Xup_data;
else
    Xup=sort(Xup_data,2,'descend');
end

% Compute the Z value at these points and adjust so that the LE is
% at Z=0
Zup=interp1(Xup_input,A(1+increment:Nup+increment,2),Xup)-A(Nup+increment,2);

%%% Lower surface
% We proced exactly in the same manner as for the upper surface
% Get the input points and normalize
Xlow_input=A(Nup+increment+1:end,1)/max(A(1+increment:end,1));   % We start at 2 because the first line gives the nuöber of points

if (length(A(:,1))>250)
    Xlow=0:0.01:1;
else
    Xlow=Xlow_input';
end

% Compute the Z value at these points and adjust so that the LE is
% at Z=0
Zlow=interp1(Xlow_input,A(Nup+increment+1:end,2),Xlow)-A(Nup+increment,2);

STEP = 50;
EP = 0:1/STEP:1;

Zup = interp1(Xup, Zup, EP, 'pchip');
Zlow = interp1(Xlow, Zlow, EP, 'pchip');

thickness = max(abs(Zup-Zlow));
