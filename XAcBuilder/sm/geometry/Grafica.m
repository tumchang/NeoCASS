function Grafica()
global handles TechGeoModel %CPACS_struct

%Part visibility
    h = get(gca,'Children');
    set(h,'visible','off');
    set(handles.axes3d_technology,'Visible','off');
% %Fuselage
%       set(handles.D150Fuselage1ID,'Visible','off');
% %Wing
%     set(handles.D150_wing_1ID,'Visible','off'); 
%     set(handles.component_D150_wing_1ID,'Visible','off'); 
%     % Wing TED
%     set(handles.D150_wing_1ID_D150_wing_CS_D150_InnerFlap,'Visible','off');
%     set(handles.D150_wing_1ID_D150_wing_CS_D150_OuterFlap,'Visible','off');

%Panel visibility
    %Hide Project Panel
    set(handles.Components,     'Visible','off');
    set(handles.Sub_Components, 'Visible','off');
    set(handles.Parameters,     'Visible','off');
    set(handles.Actions,        'Visible','off');
    set(handles.axes3d,         'Visible','off');
    try
        set(handles.A3204CM036,     'Visible','on','FaceColor',[.5 .5 .5],'FaceAlpha',0.5);
    end
    %Hide W&B panel 
    set(handles.WB_parameters,'Visible','off');
    %Technology Panel
    set(handles.Technology,     'Visible','off'); % on
    set(handles.tech_parameters,'Visible','off'); % on
    set(handles.tech_listbox,   'Visible','off'); % on
    set(handles.tech_listbox,   'String',  {'Geometry (beam_model)',...
                                            'Geometry (aero_model)',...
                                            'Geometry (spar_location)',...
                                            'Material',...
                                            'Loading',...
                                            'Analysis',...
                                            'Experienced'});   
%Get CPACS struct
    %[CPACS_struct] = assemble_compStructs; 
    % CPACS_struct.vehicles{1,1}.aircraft{1,1}.model{1,1}.name{1,1}.CONTENT = 'tempModel';
    %[CPACSgeo, CPACS_struct] = cpacsWrapper_CPACScreator(path, CPACS_struct); 
    %CPACS_struct
%Generate Technology Geometry 
    %TechMode=1;  %Generate whole model
    %Technology_Fun(TechMode,CPACS_struct);   
%Goemetry Visibility Option
    %set(handles.Tech.Curve(TechGeoModel.iFus{1}.Geometry.splineID(2:end,1)),'Visible','off');
%Set Tech Graphical Object Hide until from menù User activate them
    %handles
    set(handles.Tech.SparLine,'Visible','on'); % off
    set(handles.Tech.BeamLine,'Visible','on'); % off
    set(handles.Tech.AeroMesh,'Visible','off'); % off
%     handles
%     set(menu_weightBallnce,'Enable','on');
end