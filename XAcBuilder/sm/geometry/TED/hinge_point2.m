function hinge_point = hinge_point2 (iTED_geo, num_element_iTED, start, component, TED_inOrOutboardAirfoil, location)

% cs = TED.Componentsegment;

%load parameters for hinge points
switch location 
    case 1 %front
          hingeRelChord = iTED_geo.hingeXsi(1);
          hingeRelHeight = iTED_geo.hingeRelHeight(1);

    case 2 %back
          hingeRelChord = iTED_geo.hingeXsi(2);
          hingeRelHeight = iTED_geo.hingeRelHeight(2);    
end


%get number of airfoils for this ted
% g = size(TED.Airfoils{1,1}.Basic);    % num_element_iTED
g = num_element_iTED;

s = size(component{1,start});
s = s(1);

%calculate inner Hingepoint
[val, idx] = min(component{1,start}(:,1));
front = component{1,start}(idx,:);
[val, idx] = max(component{1,start}(:,1));
back = component{1,start}(idx,:);
hinge_1 = back + hingeRelChord * (front - back);

A = abs(component{1,start}-hinge_1(1));
[val, idx] = min(A);
f = idx(1);

e = abs ((component{1,start} (f, 3)) + abs (component{1,start} (s - (f-1), 3)))*hingeRelHeight;
hinge_1 (3) = component{1,start} (s-(f-1), 3) + e;

%%%%%%%%%%%%%%%%%%%%%%%%
[val, idx] = min(component{1,start+1}(:,1));
front = component{1,start+1}(idx,:);
[val, idx] = max(component{1,start+1}(:,1));
back = component{1,start+1}(idx,:);
hinge_2 = back + hingeRelChord * (front - back);

A = abs(component{1,start+1}-hinge_2(1));
[val, idx] = min(A);
f = idx(1);

e = abs ((component{1,start+1} (f, 3)) + abs (component{1,start+1} (s - (f-1), 3)))*hingeRelHeight;
hinge_2 (3) = component{1,start+1} (s-(f-1), 3) + e;


%interpolation, since hinge_1 hinge_2 on two neighbout elements surrounding
%inboard or outboard


y_soll = mean(TED_inOrOutboardAirfoil(:,2));

hinge_point = interpol_hp (hinge_1', hinge_2', y_soll);

end

function [xyz] = interpol_hp(A0, B0, y)
% A0 1*3
% B0 1*3
% x scalar
xyz = zeros(size(A0));
xyz(2) = y; 

for i = [1,3]
    slopem = (B0(i) - A0(i))/(B0(2)-A0(2));
    xyz(i) = A0(i) + (y-A0(2))*slopem;
end

end
