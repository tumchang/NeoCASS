function  [X_front_rib, Y_front_rib, Z_front_rib] = get_XYZ_front_rib( compseg_etas, rib_cellj, Spars_Segment, numOfRibsj, ribs_etaStartj, ribs_etaEndj, ...
    X_rib_startj, Y_rib_startj, Z_rib_startj, X_rib_endj, Y_rib_endj, Z_rib_endj,  LE_points)
%   X_front_rib = linspace(X_rib_startj,X_rib_endj, numOfRibsj)';

% load matlab.mat

if strcmp(rib_cellj.rib_start,'leadingEdge')==1
    
    idx_smaller_start = find(compseg_etas <= ribs_etaStartj);
    if isempty(idx_smaller_start)
        t_start = 1;
    else
        t_start = idx_smaller_start(end);
    end
    
    idx_smaller_end = find(compseg_etas <= ribs_etaEndj);
    if isempty(idx_smaller_end)
        t_end = 1;
    else
        t_end = idx_smaller_end(end);
    end
    
    if  t_start == t_end
        X_front_rib = linspace(X_rib_startj, X_rib_endj, numOfRibsj)';
        Y_front_rib = linspace(Y_rib_startj, Y_rib_endj, numOfRibsj)';
        Z_front_rib = linspace(Z_rib_startj, Z_rib_endj, numOfRibsj)';
    else
        num_elems =  t_end + 1 - t_start + 1;
        elems = zeros(num_elems,3);
        dist_elems = zeros(num_elems-1,1);
        num_interp = zeros(num_elems-1,1);
        
        elems(1,:) = [X_rib_startj, Y_rib_startj, Z_rib_startj];
        elems(end,:) = [X_rib_endj, Y_rib_endj, Z_rib_endj];
        
        for i = 2 : num_elems - 1
            elems(i,:) =  LE_points(t_start + i - 1,:);
        end
        
        for i = 1 : num_elems - 1
            dist_elems(i) = sqrt( sum(( elems(i+1, 2:3) - elems(i, 2:3) ).^2 ));
        end
        
        length_ribs = sum(dist_elems);
        
        for i = 1 : num_elems - 1
            %   num_intp = round(dist_sparpos(i) / length_ribs * numOfRibsj);
            num_intp = round( numOfRibsj / length_ribs *  dist_elems(i) );
            if i == 1
                num_interp(i) = num_intp;
            elseif i == num_elems - 1
                num_interp(i) = numOfRibsj + num_elems - 2 - sum(num_interp);
            else
                num_interp(i) = num_intp + 1;
            end
            
            X_front_rib{i,1} = linspace(elems(i,1), elems(i+1,1), num_interp(i))';
            Y_front_rib{i,1} = linspace(elems(i,2), elems(i+1,2), num_interp(i))';
            Z_front_rib{i,1} = linspace(elems(i,3), elems(i+1,3), num_interp(i))';
        end
        
        X_front_rib = cell2mat(X_front_rib);
        Y_front_rib = cell2mat(Y_front_rib);
        Z_front_rib = cell2mat(Z_front_rib);
        
        idx_rec = zeros(num_elems - 2,1);
        k = 0;
        for i = 1 : length(X_front_rib)-1
            if X_front_rib(i) ==  X_front_rib(i+1)
                k = k + 1;
                idx_rec(k) = i;
            end
        end
        X_front_rib(idx_rec) = [];
        Y_front_rib(idx_rec) = [];
        Z_front_rib(idx_rec) = [];
    end
    
else                       % 'frontSpar'
    
    %     switch id
    %         case 'VerticalWing'         % Error in the xml file : it should be VTP instead of HTP for vertical tail
    %             u = 1;
    %         case 'HorizontalWing'
    num_segments = length(Spars_Segment);
    for i = 1: num_segments
        spar_segmentsUID{i} = Spars_Segment{i}.uID;
    end
    try
        u = find(strcmp(spar_segmentsUID, rib_cellj.rib_start));
    catch
        errordlg('This rib starts at a spar segment whose uID is not listed in the available spar segments')
    end
    %     end
    
    idx_smaller_ribstart = find(Spars_Segment{u}.eta <= ribs_etaStartj);
    if isempty(idx_smaller_ribstart)
        t_start = 1;
    else
        t_start = idx_smaller_ribstart(end);
    end
    
    idx_smaller_ribend = find(Spars_Segment{u}.eta <= ribs_etaEndj);
    if isempty(idx_smaller_ribend)
        t_end = 1;
    else
        t_end = idx_smaller_ribend(end);
    end
    
    if  t_start == t_end
        X_front_rib = linspace(X_rib_startj, X_rib_endj, numOfRibsj)';
        Y_front_rib = linspace(Y_rib_startj, Y_rib_endj, numOfRibsj)';
        Z_front_rib = linspace(Z_rib_startj, Z_rib_endj, numOfRibsj)';
    else
        if Spars_Segment{u}.eta(t_end) == ribs_etaEndj
            num_sparpos =  t_end - t_start + 1;
        else
            num_sparpos =  t_end + 1 - t_start + 1;
        end
        
        sparpos = zeros(num_sparpos,3);
        dist_sparpos = zeros(num_sparpos-1,1);
        num_interp = zeros(num_sparpos-1,1);
        
        sparpos(1,:) = [X_rib_startj, Y_rib_startj, Z_rib_startj];
        sparpos(end,:) = [X_rib_endj, Y_rib_endj, Z_rib_endj];
        
        for i = 2 : num_sparpos-1
            sparpos(i,:) = Spars_Segment{u}.middle(t_start + i - 1,:);
        end
        
        for i = 1 : num_sparpos - 1
            dist_sparpos(i) = sqrt( sum(( sparpos(i+1, 2:3) - sparpos(i, 2:3) ).^2 ));
        end
        
        length_ribs = sum(dist_sparpos);
        
        if   numOfRibsj == 2
            X_front_rib = [X_rib_startj; X_rib_endj];
            Y_front_rib = [Y_rib_startj; Y_rib_endj];
            Z_front_rib = [Z_rib_startj; Z_rib_endj];
        else
            
            for i = 1 : num_sparpos - 1
                %   num_intp = round(dist_sparpos(i) / length_ribs * numOfRibsj);
                num_intp = round( numOfRibsj / length_ribs * dist_sparpos(i) );
                if i == 1
                    num_interp(i) = num_intp;
                elseif i == num_sparpos - 1
                    num_interp(i) = numOfRibsj + num_sparpos - 2 - sum(num_interp);
                else
                    num_interp(i) = num_intp + 1;
                end
                
                if num_interp(i) == 0
                    X_front_rib{i,1} = []; 
                    Y_front_rib{i,1} = [];
                    Z_front_rib{i,1} = [];                   
                elseif num_interp(i) == 1
                    if i == num_sparpos - 1
                        X_front_rib{i,1} = sparpos(i+1,1);
                        Y_front_rib{i,1} = sparpos(i+1,2);
                        Z_front_rib{i,1} = sparpos(i+1,3);
                    else
                        X_front_rib{i,1} = sparpos(i,1);
                        Y_front_rib{i,1} = sparpos(i,2);
                        Z_front_rib{i,1} = sparpos(i,3);
                    end
                elseif num_interp(i) >= 2
                    X_front_rib{i,1} = linspace(sparpos(i,1), sparpos(i+1,1), num_interp(i))';
                    Y_front_rib{i,1} = linspace(sparpos(i,2), sparpos(i+1,2), num_interp(i))';
                    Z_front_rib{i,1} = linspace(sparpos(i,3), sparpos(i+1,3), num_interp(i))';           
                end
            end
            
            X_front_rib = cell2mat(X_front_rib);
            Y_front_rib = cell2mat(Y_front_rib);
            Z_front_rib = cell2mat(Z_front_rib);
            
            %    idx_rec = zeros(num_sparpos - 2,1);
            k = 0;
            for i = 1 : length(X_front_rib)-1
                if X_front_rib(i) ==  X_front_rib(i+1)
                    k = k + 1;
                    idx_rec(k) = i;
                end
            end
            
            if k > 0
                X_front_rib(idx_rec) = [];
                Y_front_rib(idx_rec) = [];
                Z_front_rib(idx_rec) = [];
            end
        end
    end
    
end

% % %figure()
% hold on
% plot3(X_front_rib, Y_front_rib, Z_front_rib, 'ro');
% axis equal
% hold on

end