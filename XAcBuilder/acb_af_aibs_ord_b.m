% *** rev. 2016-07-07

function [X_Def Y_Def] = acb_af_aibs_ord_b(Xc,Yc)
% Cerca 0
near_zero_pos = find(Xc<eps)
% Verifica schema coord 
if (length(near_zero_pos)>1)
    % Schema Coord  0 1 0     || A
    %               0 1 - 0 1 || B
    %               1 0 - 1 0 || C
    %               1 0 - 0 1 || D
    %
    if (length(near_zero_pos) == 2)
        % Schema D
        dist_zeros = near_zero_pos(2)-near_zero_pos(1)
        
        if (dist_zeros == 1)
            
            % Schema Coord 1 0 1 
            xf_block = flipud(Xc(near_zero_pos(1):-1:1))
            yf_block = flipud(Yc(near_zero_pos(1):-1:1))
            % Verifica Dorso o Ventre?
            VoD = sum(yf_block)
            if (VoD>0)
            % Dorso - Costruzione Schema Definitivo
             xs_block = flipud(Xc(end:-1:near_zero_pos(1)+1)) % near_zero_pos(2) OK
             ys_block = flipud(Yc(end:-1:near_zero_pos(1)+1)) % near_zero_pos(2) OK
             X_Def = [xf_block;xs_block]
             Y_Def = [yf_block;ys_block]      
            else
             % Ventre  
            end
               
        end
               
    end
        
else
    % Schema Coord 1 0 1 
    xf_block = flipud(Xc(near_zero_pos:-1:1))
    %xf_block_F =flipud(xf_block)
    yf_block = flipud(Yc(near_zero_pos:-1:1))
    % Verifica Dorso o Ventre?
    VoD = sum(yf_block)
    if (VoD>0)
      % Dorso - Costruzione Schema Definitivo
      xs_block = flipud(Xc(end:-1:near_zero_pos+1))
      ys_block = flipud(Yc(end:-1:near_zero_pos+1))
      X_Def = [xf_block;xs_block]
      Y_Def = [yf_block;ys_block]      
    else
      % Ventre  
      
      
    end
    
end

end
