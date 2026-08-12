function WB_Table_Viewer()
%
%  Weight and Balance Table Viewer
%
%
% Copyright (C) 2016
%
%   Luca Riccobene	<luca.riccobene@polimi.it>
%
% Dipartimento di Scienze e Tecnologie Aerospaziali - Politecnico di Milano
% via La Masa, 34 - 20156 Milano, Italy
% http://www.aero.polimi.it
%
% Warning: This code can be only used with permission of the author; any
% usage, development or distribution outside the Department of Aerospace
% Science and Technologies of Politecnico di Milano without an explicit
% authorization  may be persecuted.
% Changing this notice is forbidden.
%
% function         WB_Table_Viewer()
%
%   DESCRIPTION:  Load from an *.xml file - NeoCASS format - the center of
%                 gravity table (COG), allowing to modify it and save it on
%                 the same or a new xml file.
%                 Neocass built-in xml parser functions (see below) should
%                 be in the path.
%
% See also neocass_xmlwrapper, neocass_xmlunwrapper
%
%**************************************************************************

% Set figure
scrs = get(0, 'screensize');
px = 680;
py = 740;

hfig = figure('menu', 'none', 'name', 'W&B COG Viewer', 'numbertitle', 'off', ...
    'position', [scrs(3)/4 scrs(4)-(py+40) px py], 'units', 'normalized', 'resize', 'on');

% Set private data
db.data  = [];
db.fname = [];
db.aac   = [];  % actual aircraft
db.dac   = [];  % default aircraft
db.tb    = [];  % table handle
db.hist  = [];  % modification history
db.tmass = [];  % total mass [kg]
setappdata(hfig, 'db', db);

% Menu
h_file  = uimenu('Parent', hfig, 'Label', 'File');

uimenu('Parent', h_file, 'Label', 'Load XML...', 'Callback', @Load_Callback);
uimenu('Parent', h_file, 'Label', 'Reset data...', 'Callback', @Reset_Callback);
uimenu('Parent', h_file, 'Label', 'Save XML...',   'Callback', @Save_Callback);
uimenu('Parent', h_file, 'Label', 'Exit...', 'Callback', @Close_Callback, 'separator', 'on');

% Divide the GUI in two areas
posm = [0. .95 1. .05];
msgp = uipanel('Parent', hfig, 'Position', posm);
tblp = uipanel('Parent', hfig, 'Position', [0. 0. 1. 1-(posm(4))]);

% Total mass
uicontrol('parent', msgp,...
    'style', 'text',...
    'string', 'Total mass [kg]:',...
    'position', [1 4 124 20],...
    'fontsize', 9,...
    'fontweight', 'bold');
hmass = uicontrol('parent', msgp,...
    'style', 'text',...
    'string', '',...
    'position', [128 4 80 20],...
    'fontsize', 9);

%==========================================================================
% Auxiliary functions
%
    function Load_Callback(hObject, eventdata)
        % Load XML file
        
        % Accepted formats
        fmts = {'*.xml',   'xml'};
        
        [filename, pathname, filterindex] = uigetfile(fmts, 'Select a file...');
        
        if filterindex
            
            % Save file full path into database
            db       = getappdata(hfig, 'db');
            db.fname = fullfile([pathname, filename]);
            
            % Use NeoCASS built-in function to read the file
            try
                aircraft = neocass_xmlwrapper(db.fname);
            catch excp
                warn_str = strcat('Error while loading file...', '\n', excp.message);
                warndlg(warn_str, 'load warn');
            end
            
            % Store struct
            db.dac = aircraft;
            db.aac = aircraft;
            
            % Recover centers of gravity table (if weigh_balance field is
            % missing, show a message)
            try
                cog = squeeze(aircraft.weight_balance.COG(:,:,1));
            catch excp
                warn_str = strcat('Error in XML format...', '\n', excp.message);
                warndlg(warn_str, 'COG warn');
            end
            nel = size(cog, 1);
            
            % Compute total mass
            tmass = sum(cog(:, 4));
            set(hmass, 'string', num2str(tmass, '%8.2f'));
            db.tmass = tmass;
            
            % Compute actual CG position and save it in default aircraft
            % (fix a discrepancy found between rweig CG computation and
            % WB_Table_Viewer: in the first it accounts for ramp increment)
            cog(27, 1, 1) = sum(cog(:,4).*cog(:,1))/tmass;
            cog(27, 3, 1) = sum(cog(:,4).*cog(:,3))/tmass;
            
            db.dac.weight_balance.COG(:, :, 1) = cog;
            db.aac.weight_balance.COG(:, :, 1) = cog;

            % Create uitable object
            
            % Set table row and column names
            columnname   = {' X [m] ', ' Y [m] ', ' Z [m] ', ' Mass [kg] '};
            columnformat = {'numeric', 'numeric', 'numeric', 'numeric'};
            position     = cellfun(@(x)num2str(x, '%2d'), num2cell(1:nel), 'uniformoutput', false);
            label        = {'WING1',...
                'WING2'...
                'HT'...
                'VT'...
                'FUSELAGE'...
                'LANDING GEAR'...
                'POWERPLANT1'...
                'POWERPLANT2'...
                'AUX LANDING GEAR'...
                'VT2'...
                'CANARD'...
                'TAILBOOMS'...
                'DUMMY MASS #1'...
                'DUMMY MASS #2'...
                'DUMMY MASS #3'...
                'DUMMY MASS #4'...
                'SYSTEMS'...
                'WING TANKS'...
                'CENTRE FUEL TANKS'...
                'AUXILIARY TANKS'...
                'INTERIOR'...
                'PILOTS'...
                'CREW'...
                'PASSENGERS'...
                'BAGGAGE'...
                'DUMMY MASS #5'...
                'CG_at_MTOW_wrt_nose'...
                'DUMMY MASS #6'...
                'CG_at_MEW_wrt_nose'...
                'DUMMY MASS #7'};
            
            rowname = strcat(repmat({'('}, 1, nel), position, repmat({')'}, 1, nel), repmat({'   '}, 1, nel), label);
            
            tb = uitable('parent', tblp,...
                'Data', cog,...
                'ColumnName', columnname,...
                'ColumnFormat', columnformat,...
                'ColumnEditable', [true true true true],...
                'RowName', rowname,...
                'fontsize', 9,...
                'units', 'normalized',...
                'position', [0.05 0.11 1. 1.],...
                'CellEditCallback', @cellEdit);
            
            % Set width and height
            ext = get(tb, 'Extent');
            pos = get(tb, 'Position');
            pos(3:4) = ext(3:4);
            set(tb, 'Position', pos);

            % Save table handle
            db.tb = tb;
            
            % Update database
            setappdata(hfig, 'db', db);
            
        end
        
    end

    function cellEdit(hObject, callbackdata)
        % Cell editing function
        
        % Recover actual (modified) value
        actual_cog = get(hObject, 'Data');
        
        % Update actual aircraft
        db = getappdata(hfig, 'db');
        db.aac.weight_balance.COG(:,:,1) = actual_cog;
        
        % Save history
        ModifiedElementIndices = [callbackdata.Indices(1) callbackdata.Indices(2)];
        db.hist = [db.hist; ModifiedElementIndices];
        
        % Compute and display total mass
        tmass = sum(actual_cog(:, 4));
        set(hmass, 'string', num2str(tmass, '%8.2f'));
        db.tmass = tmass;
        
        % CG
        xcg = sum(actual_cog(:,4).*actual_cog(:,1))/tmass;
        zcg = sum(actual_cog(:,4).*actual_cog(:,3))/tmass;
        
        actual_cog(27, 1) = xcg;
        actual_cog(27, 3) = zcg;
        
        set(db.tb, 'Data', actual_cog);
        db.aac.weight_balance.COG(:,:,1) = actual_cog;
        
        % Update database
        setappdata(hfig, 'db', db);
        
    end

    function Save_Callback(hObject, eventdata)
        % Save XML file
        
        % Recover database
        db = getappdata(hfig, 'db');
        
        % Default filename is the original one
        [filename, pathname] = uiputfile(db.fname, 'Save XML file...');
        
        if isequal(filename,0) || isequal(pathname,0)
            % Skip
            return
        else
            
            % Save to file using NeoCASS built-in function
            try
                neocass_xmlunwrapper([pathname, filename], db.aac);
            catch excp
                warn_str = strcat('Error while saving file...', '\n', excp.message);
                warndlg(warn_str, 'save warn');
            end
            
        end
        
    end

    function Reset_Callback(hObject, eventdata)
        % Restore original data into table
        
        % Recover COG data
        db   = getappdata(hfig, 'db');
        data = db.dac.weight_balance.COG(:,:,1);
        
        Choice = questdlg('Ok to reset centre of gravity data to original values?', ...
            'Reset dialog', 'Ok', 'Cancel', 'Cancel');
        
        switch lower(Choice)
            
            case 'ok'
                
                % Update table and actual aircraft struct
                set(db.tb, 'Data', data);
                db.aac = db.dac;
                
                % Use 0 to record the reset into history
                db.hist = [db.hist; zeros(1, 2)];
                
                % Compute and display total mass
                tmass = sum(data(:, 4));
                set(hmass, 'string', num2str(tmass, '%8.2f'));
                db.tmass = tmass;
                
                % Update database
                setappdata(hfig, 'db', db);
                
            case 'cancel'
                % Do nothing
                return
                
        end
        
    end

    function Close_Callback(hObject, eventdata)
        % Pop-up a quest dialog to choose leaving the GUI or not
        
        Choice = questdlg('Are you sure you want to quit?', ...
            'Close dialog', 'Yes', 'No', 'No');
        
        switch lower(Choice)
            case 'yes'
                delete(hfig);
            case 'no'
                return
        end
        
    end


end
