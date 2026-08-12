function  [vertices_SubComponent, facets_SubComponent] = TEDfoil2triangles(Airfoils, local_symmetry)

 
size_numberOfAirfoils = length(Airfoils);    % three sections;
size_numberOfPoints = length(Airfoils{1,1});    % the number of points on each section

basic = cell(1, size_numberOfAirfoils);
XYZ_SubComponent = cell(size_numberOfAirfoils, 1);

Sum_NoOfpoints = size_numberOfAirfoils * size_numberOfPoints; 

switch  local_symmetry
    case 0
        vertices_SubComponent = zeros(Sum_NoOfpoints, 3);
        NoOfQuads = (size_numberOfAirfoils - 1) * (size_numberOfPoints - 1);  %        
    case {1,2,3}
        vertices_SubComponent = zeros(2 * Sum_NoOfpoints, 3);
        NoOfQuads = 2 * (size_numberOfAirfoils - 1) * (size_numberOfPoints - 1);  %
end

facets_SubComponent = zeros( NoOfQuads, 4);

for k=1:size_numberOfAirfoils
    
    basic{1,k}=Airfoils{1,k};    % ignore Basic{1,1} on purpose, it's so close to Basic{1,2}!
    XYZ_SubComponent{k,1}=basic{1,k};
    
    startidx = (k-1)*size_numberOfPoints + 1;
    endidx = (k-1)*size_numberOfPoints + size_numberOfPoints;
    vertices_SubComponent(startidx:endidx,:) = XYZ_SubComponent{k,1};    
end

quadIndex = 1;
for ki = 1:(size_numberOfAirfoils-1)
    for kj = 1:(size_numberOfPoints(1)-1)
        p1 = (ki-1) * size_numberOfPoints(1) + kj;
        p2 = (ki-1) * size_numberOfPoints(1) + kj + 1;
        p3 = (ki) * size_numberOfPoints(1) + kj;
        p4 = (ki) * size_numberOfPoints(1) + kj + 1;
        facets_SubComponent(quadIndex,:) = [p1 p2 p4 p3];
        quadIndex = quadIndex + 1;
    end
end

%--------------------------------------------------------------%
%---Furtheron is to process Symmetry property, to copy data----%

switch local_symmetry
    case 0       % no symmetry
    case 1       % x-z plane symmetry
        for ki = (size_numberOfAirfoils + 1) : (2 * size_numberOfAirfoils)                % symmetry
            startidx = (ki-1)*size_numberOfPoints + 1;
            endidx = (ki-1)*size_numberOfPoints + size_numberOfPoints;
            vertices_SubComponent(startidx:endidx,[1,3]) = XYZ_SubComponent{(ki - size_numberOfAirfoils),1}(:,[1,3]);
            vertices_SubComponent(startidx:endidx,2) = -XYZ_SubComponent{(ki - size_numberOfAirfoils),1}(:,2);
        end
    case 2       % x-y plane symmetry
        for ki = (size_numberOfAirfoils + 1) : (2 * size_numberOfAirfoils)                % symmetry
            startidx = (ki-1)*size_numberOfPoints + 1;
            endidx = (ki-1)*size_numberOfPoints + size_numberOfPoints;
            vertices_SubComponent(startidx:endidx,[1,2]) = XYZ_SubComponent{(ki - size_numberOfAirfoils),1}(:,[1,2]);
            vertices_SubComponent(startidx:endidx,3) = -XYZ_SubComponent{(ki - size_numberOfAirfoils),1}(:,3);
        end        
    case 3       % y-z plane symmetry
         for ki = (size_numberOfAirfoils + 1) : (2 * size_numberOfAirfoils)                % symmetry
            startidx = (ki-1)*size_numberOfPoints + 1;
            endidx = (ki-1)*size_numberOfPoints + size_numberOfPoints;
            vertices_SubComponent(startidx:endidx,[2,3]) = XYZ_SubComponent{(ki - size_numberOfAirfoils),1}(:,[2,3]);
            vertices_SubComponent(startidx:endidx,1) = -XYZ_SubComponent{(ki - size_numberOfAirfoils),1}(:,1);
        end        
        
end
 
switch local_symmetry
    case 0
    case {1,2,3}
        for ki = (size_numberOfAirfoils + 1) : (2 * size_numberOfAirfoils - 1)
            for kj = 1:(size_numberOfPoints(1)-1)
                p1 = (ki-1) * size_numberOfPoints(1) + kj;
                p2 = (ki-1) * size_numberOfPoints(1) + kj + 1;
                p3 = (ki) * size_numberOfPoints(1) + kj;
                p4 = (ki) * size_numberOfPoints(1) + kj + 1;
                facets_SubComponent(quadIndex,:) = [p1 p2 p4 p3];
                quadIndex = quadIndex + 1;
            end
        end
end

end
