function pos_vec = positioning (wing, sec)
%calculates necessary positioning vector for this section

size_pos = size(wing.positionings{1,1}.positioning);

%initialize positioning vector
pos_vec = [0 0 0];

%to elemnt for which the positioning has to be found
stop = 0;

while (stop == 0)
    for ii=1 : size_pos(2)
        
        pos_nmbr_try = wing.positionings{1,1}.positioning{1,ii}.toSectionUID{1,1}.CONTENT;
        pos_nmbr_try = str2double (pos_nmbr_try (19));     % dangerous here!!
        
        %see if to element of the try positioning is the right one
        if pos_nmbr_try == sec
            pos_nmbr = pos_nmbr_try;
            
            %load values for positioning vector
            length = str2double (wing.positionings{1,1}.positioning{1,pos_nmbr}.length{1,1}.CONTENT);
            sweep_angle = str2double (wing.positionings{1,1}.positioning{1,pos_nmbr}.sweepangle{1,1}.CONTENT);
            dihedral_angle = str2double (wing.positionings{1,1}.positioning{1,pos_nmbr}.dihedralangle{1,1}.CONTENT);
            
            pos_vec_rel = [0 0 0];
            
            Rot1 = rotVec(-sweep_angle,[0;length;0],3);
            Rot2 = rotVec(dihedral_angle,Rot1,1);
            
            pos_vec_rel (1) = Rot2(1);
            pos_vec_rel (2) = Rot2(2);
            pos_vec_rel (3) = Rot2(3);
            
            %add to previous relative vectors
            pos_vec = pos_vec + pos_vec_rel;
            
            %check if the from element is origin otherwise find the other
            %positionings necesseary
            try from_1 = wing.positionings{1,1}.positioning{1,pos_nmbr}.fromSectionUID{1,1}.CONTENT;
                sec_new = str2double (from_1(19));
                if sec_new == sec
                    stop = 1;
                else
                    sec = sec_new;
                end
                
            catch
                stop = 1;
                sec = NaN;
                
            end
        end
    end
    
end

end
