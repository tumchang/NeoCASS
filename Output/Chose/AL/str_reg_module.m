function [str, optim, wc, wf, wv, wh] = str_reg_module(fid, niter, pdcylin, aircraft, geo, loads, str, optim, f_can, f_vtp, f_fuse, f_htp)
    %==========================================================================
    % STRUCTURAL MODULUS
    %==========================================================================
    %
    fprintf(fid,'\n\t-------------------------------------------- SIZING ------------------------------------------------');
    
    % Fuselage
    if isequal(pdcylin.stick.model.fuse, 1)
        fprintf(fid, '\n\t- Fuselage structural sizing...');
        str = Str_Fus(pdcylin, aircraft, geo, loads, str, f_fuse);
        fprintf(fid, '\n\tdone.');
    end
    
    % Wing
    if isequal(pdcylin.stick.model.winr, 1)
        fprintf(fid, '\n\t- Wing structural sizing...');
        [str, optim] = Str_Wing(niter, pdcylin, aircraft, geo, loads, str, optim);
        fprintf(fid, '\n\tdone.');
    end
    
    % Wing2 (deprecated)
    if isequal(pdcylin.stick.model.win2r, 1)
        fprintf(fid, '\n\t- Wing2 structural sizing...');
        [str, optim] = Str_Wing2(niter, pdcylin, aircraft, geo, loads, str, optim);
        fprintf(fid, '\n\tdone.');
    end
    
    % VT
    if isequal(pdcylin.stick.model.vert, 1)
        fprintf(fid, '\n\t- Vertical tail structural sizing...');
        [str, optim] = Str_Vtail(niter, pdcylin, aircraft, geo, loads, str, optim, f_vtp);
        fprintf(fid, '\n\tdone.');
    end
    
    % HT
    if isequal(pdcylin.stick.model.horr, 1)
        fprintf(fid, '\n\t- Horizontal tail structural sizing...');
        [str, optim] = Str_Htail(niter, pdcylin, aircraft, geo, loads, str, optim, f_htp);
        fprintf(fid, '\n\tdone.');
    end
    
    % Canard
    if aircraft.Canard.present
        fprintf(fid, '\n\t- Canard structural sizing...');
        [str, optim] = Str_Canr(niter, pdcylin, aircraft, geo, loads, str, optim, f_can);
        fprintf(fid, '\n\tdone.');
    end
    
    % Tail booms
    if isfield(aircraft, 'Tailbooms') && aircraft.Tailbooms.present
        fprintf(fid, '\n\t- Tailbooms structural sizing...');
        str = Str_Tbooms(pdcylin, aircraft, geo, loads, str);
        fprintf(fid, '\n\tdone.');
    end
    
    %==========================================================================
    % REGRESSION ANALYSIS MODULUS
    %==========================================================================
    %
    fprintf(fid,'\n\t-------------------------------------------- REGRESSION --------------------------------------------');
    
    % Fuselage
    if isequal(pdcylin.stick.model.fuse, 1)
        fprintf(fid, '\n\t- Fuselage regression equation, ');
        [str, wf] = Regr_Fus(fid, pdcylin, aircraft, geo, loads, str);
    end
    
    % Wing
    if isequal(pdcylin.stick.model.winr, 1)
        fprintf(fid, '\n\t- Wing regression equation, ');
        str = Regr_Wing(fid, pdcylin, aircraft, geo, loads, str);
    end
    
    % VT
    if isequal(pdcylin.stick.model.vert, 1)
        fprintf(fid, '\n\t- Vertical tail regression equation, ');
        [str, wv] = Regr_Vtail(fid, pdcylin, aircraft, geo, loads, str);
    end
    
    % HT
    if isequal(pdcylin.stick.model.horr, 1)
        fprintf(fid, '\n\t- Horizontal tail regression equation, ');
        [str, wh] = Regr_Htail(fid, pdcylin, aircraft, geo, loads, str);
        save('str_hatil.mat', 'str');
    end
    
    % Canard
    if aircraft.Canard.present
        fprintf(fid, '\n\t- Canard tail regression equation, ');
        [str, wc] = Regr_Canard(fid, pdcylin, aircraft, geo, loads, str);
    end
    
    % Tail booms
    if isfield(aircraft,'Tailbooms') && aircraft.Tailbooms.present
        fprintf(fid, '\n\t- Tailbooms regression equation');
        str = Regr_Tbooms(fid, pdcylin, aircraft, geo, loads, str);
    end
end