function [TED_airfoils, iTED_geo] = matrix_controlSurf_4(iTED_struct)
% A compact and clean version of creating control surfaces point coordinate
% matrix, making full use of CPACSgeo from CPACSwrapper.
% Written by Pengfei MENG 2013-01-13, reformat of Lisa's ideas. 
% ----------------------Logic--------------------%
% 2) Find out which elements are relevant for each TED -
% element1 - startTED - element2 - endTED - element3 : like so, element 1-3 are all relevant elements for this TED 
% 3) Interpolate LeadingEdgeShape values for relevant elements of the TED
%    Calculate TED_airfoil for the relevant elements of the TED
% 4) TED inboard & outboard usually locate between predefined elements
%    Hence TED in & outboard airfoils need to be interpolated from
%    the two elements surrounding them. For kink sections crossed by TED,
%    just copy airfoils from previous step.
% 5) Calculate inclination, hinge point, step or path etc.
%-----------------------------------------------%
% Called by load_Wing_Subcomponents
% call functions:   
%        interpol_linear  interpol_inOutBoard  interpol_inclined_inOutBoard
%                  airfoilInterp
%                  standard
%                  get_airfoil
%                  hinge_point2
%                  path_function2
%----------------------------------------------------------------------------------------
%             iTED_geo.wingSectionDef = wing_geo.sectionDef;
%             iTED_geo.compSegStart = startEle_compSeg;
%             iTED_geo.compSegEtas = etaEles_compSeg;

%% 2) Each TED, start/end element number; eta ksi value for TED's innerBorder and outerBorder
% number of sections crossed by this TED's LE & TE
% load iTED_struct3.mat

startEle_compSeg = iTED_struct.compSegStart;
etaEles_compSeg = iTED_struct.compSegEtas;
wingSectionDef = iTED_struct.wingSectionDef;

[iTED_geo] = iTEDstruct2geo(iTED_struct);

[num_startElement_iTED, num_endElement_iTED, num_element_iTED, eta_element_iTED, iTED_relevantElementLEShape, varargout] = calc_crossedSections(etaEles_compSeg, startEle_compSeg, iTED_geo);

%% 3) Get the TED_airfoils on the relevant elements of the TED

iTED_elements_global = cell(1,num_element_iTED);         % this TED's relevant elements' TED_airfoil global

for i = 1:num_element_iTED                           % goes through all relevant airfoils for one ted
    
    SecNum = num_startElement_iTED + i - 1;
    
    %----------------Airfoil Preparation---------------%
    Normed_airfoil = wingSectionDef.relAirfoil{SecNum, 1};
    % glob_airfoil = wing_component.sectionDef.airfoil{num_startElement_iTED + i -1, 1}
    
    Normed_airfoil_interpted = airfoilInterp(Normed_airfoil,299);
    Normed_airfoil_standard = standard(Normed_airfoil_interpted);                           % Ensure that airfoil sequence from TE -> LE -> TE 
    
    %----------------Generate TED_airfoil--------------%
    TED_airfoil_elements = get_airfoil(Normed_airfoil_standard, iTED_relevantElementLEShape.ksiLE_iTED(i), iTED_relevantElementLEShape.relChordUpperSkin_iTED(i), iTED_relevantElementLEShape.relChordLowerSkin_iTED(i), iTED_relevantElementLEShape.relZLE_iTED(i));
    
    %         figure(300)
    %         plot3(TED_airfoil_elements(:,1), TED_airfoil_elements(:,2), TED_airfoil_elements(:,3),'b+');
    %         axis equal
    %         hold on
    
    %-----Get TED_airfoil in global coordinate----------%
    coorsPoint = wingSectionDef.point{SecNum,1};
    coorsSys = wingSectionDef.coorsSys{SecNum};
    
    airfoilBasic = TED_airfoil_elements;
    iTED_relevantElements_global = [coorsSys*airfoilBasic']'+[coorsPoint(1)*ones(size(airfoilBasic,1),1),coorsPoint(2)*ones(size(airfoilBasic,1),1),coorsPoint(3)*ones(size(airfoilBasic,1),1)];
    
    iTED_elements_global{1,i} = iTED_relevantElements_global;
    
    %         figure(400)
    %         plot3(iTED_relevantElements_global(:,1), iTED_relevantElements_global(:,2), iTED_relevantElements_global(:,3),'ro')
    %         axis equal
    %         hold on
    
end

%% 4) First judge whether inboard & outboard etaLE etaTE same
% Then interpolate inboard & outboard TED_airfoils on three conditions
% i:      when etaLE == etaTE
% ii:     when etaLE ~= etaTE, but inboard or outboard LE TE on one segment
% iii:    when etaLE ~= etaTE, and inboard or outboard LE TE on two segments
%-----------------------------------------------------%
%     varargout{1} = num_startElement_iTED_LE;
%     varargout{2} = num_element_iTEDLE;
%     varargout{3} = eta_element_iTEDLE;
%
%     varargout{4} = num_startElement_iTED_TE;
%     varargout{5} = num_element_iTEDTE;
%     varargout{6} = eta_element_iTEDTE;
%-----------------------------------------------------%

%  iTED_airfoils_global = cell(1,num_element_iTED);         % inboard & outboard TED_airfoil interpolated from the two elements surrounding them

% replace TED_airfoil_global{1} TED_airfoil_global{end} with TED inboard outboard airfoils! interpolation!
iTED_airfoils_global = iTED_elements_global;
iTED_airfoils_global{1,1} = interpol_inOutBoard(eta_element_iTED(1:2), [iTED_elements_global{1,1}, iTED_elements_global{1,2}], iTED_geo.etaLE(1));
iTED_airfoils_global{1,end} = interpol_inOutBoard(eta_element_iTED(end-1:end), [iTED_elements_global{1,end-1}, iTED_elements_global{1,end}], iTED_geo.etaLE(end));

if length(varargout)>1    % means  ii or iii,   etaLE ~= etaTE
    
    iTED_etaLE_etaTE = [iTED_geo.etaLE;
        iTED_geo.etaTE];
    
    inBoard_LEx_TEx = [min(iTED_airfoils_global{1,1}(:,1));
        max(iTED_airfoils_global{1,1}(:,1))];
    inBoard = iTED_airfoils_global{1,1}(:,1);
    eta_inBoard  = interpol_linear( inBoard_LEx_TEx, iTED_etaLE_etaTE(:,1),  inBoard);
    
    
    outBoard_LEx_TEx = [min(iTED_airfoils_global{1,end}(:,1));
        max(iTED_airfoils_global{1,end}(:,1))];
    outBoard = iTED_airfoils_global{1,end}(:,1);
    eta_outBoard = interpol_linear( outBoard_LEx_TEx, iTED_etaLE_etaTE(:,2), outBoard);
    
    
    if  varargout{1} == varargout{4}  &&  varargout{2} == varargout{5}       % ii:  etaLE ~= etaTE, inboard / outboard in one segment
        
        iTED_airfoils_global{1,1} = interpol_inclined_inOutBoard(eta_element_iTED(1:2), [iTED_elements_global{1,1}, iTED_elements_global{1,2}], eta_inBoard);
        iTED_airfoils_global{1,end} = interpol_inclined_inOutBoard(eta_element_iTED(end-1:end), [iTED_elements_global{1,end-1}, iTED_elements_global{1,end}], eta_outBoard);
        
    else                                                                         % iii:  etaLE ~= etaTE, inboard / outboard in two segments
        
        inboard_etaLE = min(iTED_geo.etaLE);    outboard_etaLE = max(iTED_geo.etaLE);
        inboard_etaTE = min(iTED_geo.etaTE);    outboard_etaTE = max(iTED_geo.etaTE);
        
        
        idx_in = 0;      idx_out = 0;
        for i = 1:num_element_iTED
            if sign( (inboard_etaLE - eta_element_iTED(i))*(inboard_etaTE - eta_element_iTED(i)) ) < 0
                idx_in = idx_in + 1;
                idx_crossedbyInboard(idx_in) =  i ;
            end
            
            if sign( (outboard_etaLE - eta_element_iTED(i))*(outboard_etaTE - eta_element_iTED(i)) ) < 0
                idx_out = idx_out + 1;
                idx_crossedbyOutboard(idx_out) = i ;
            end
        end
        
        
        for i = 1: idx_crossedbyInboard(end)
            
            idx_1seg = find( eta_inBoard >= eta_element_iTED(i) && eta_inBoard <= eta_element_iTED(i+1) );
            iTED_airfoils_global{1,1}(idx_1seg,:) = interpol_inclined_inOutBoard(eta_element_iTED(i:i+1), [iTED_elements_global{1,i}, iTED_elements_global{1,i+1}], eta_inBoard(idx_1seg));
            
        end
        
        for i = idx_crossedbyOutboard(end)-1 : num_element_iTED-1
            
            idx_2seg = find( eta_outBoard >= eta_element_iTED(i) && eta_outBoard <= eta_element_iTED(i+1) );
            iTED_airfoils_global{1,end}(idx_2seg,:) = interpol_inclined_inOutBoard(eta_element_iTED(i:i+1), [iTED_elements_global{1,i}, iTED_elements_global{1,i+1}], eta_outBoard(idx_2seg));
            
        end
    end
end

%             for i = 1:num_element_iTED
%                 figure(200)
%                 plot3(iTED_airfoils_global{1,i}(:,1), iTED_airfoils_global{1,i}(:,2), iTED_airfoils_global{1,i}(:,3),'go')
%                 hold on
%             end


%% 5) Deflection of control surfaces, path_functions, calculating steps

%calculate hinge points                     iTED_airfoils_global
hingePoint_inboard = hinge_point2(iTED_geo, num_element_iTED, 1, iTED_airfoils_global, iTED_airfoils_global{1,1}, 1);
hingePoint_outboard = hinge_point2(iTED_geo, num_element_iTED, num_endElement_iTED - num_startElement_iTED, iTED_airfoils_global, iTED_airfoils_global{1,end}, 2);

% plot3(wingSectionDef.airfoil{3,1}(:,1), wingSectionDef.airfoil{3,1}(:,2), wingSectionDef.airfoil{3,1}(:,3),'k.');
% hold on
% plot3(wingSectionDef.airfoil{2,1}(:,1), wingSectionDef.airfoil{2,1}(:,2), wingSectionDef.airfoil{2,1}(:,3),'k.');
% hold on
% 
% plot3(hingePoint_inboard(1), hingePoint_inboard(2), hingePoint_inboard(3), 'kv');
% hold on
% plot3(hingePoint_outboard(1), hingePoint_outboard(2), hingePoint_outboard(3), 'kv');
% hold on

% get the deflected airfoils for the different steps
TED_airfoils.Deflected = path_function2(iTED_geo, iTED_airfoils_global, num_element_iTED, hingePoint_inboard, hingePoint_outboard);

TED_airfoils.Basic = iTED_airfoils_global;
% end

end

function [num_startElement_iTED, num_endElement_iTED, num_element_iTED, eta_element_iTED, iTED_relevantElementLEShape, varargout] = calc_crossedSections(eta_element_compSeg, num_startElement_compSeg, iTED_geo)
% 1) For each TED, compare its inboard outboard eta values with that of each element
% on the component segment, hence find out ID of the elements relevant to
% this TED, LE, TE;
% 2) For each TED, since leadingEdgeShape only for for inboard & outboard,
%    leadingEdgeShape for relevant elements of the TED need to be interpolated.

%% 1) for the whole TED, including both LE, TE, relevant elements ---
iTED_etaLE_etaTE = [iTED_geo.etaLE;
    iTED_geo.etaTE];

min_eta = min(min(iTED_etaLE_etaTE));    max_eta = max(max(iTED_etaLE_etaTE));

temp_dif_min = eta_element_compSeg - min_eta;    temp_dif_max = eta_element_compSeg - max_eta;

for i = 1: length(eta_element_compSeg)-1
    
    if temp_dif_min(i) <= 0 && temp_dif_min(i+1) >= 0
        num_startElement_iTED = num_startElement_compSeg + i - 1;
    end
    
    if temp_dif_max(i) <= 0 && temp_dif_max(i+1) >= 0
        num_endElement_iTED = num_startElement_compSeg + i;
    end
end

num_element_iTED = num_endElement_iTED - num_startElement_iTED + 1;


for u = 1 : num_element_iTED
    eta_element_iTED(u) = eta_element_compSeg(num_startElement_iTED + u - 1);
end

iTED_relevantElementLEShape.ksiLE_iTED = interpol_linear(iTED_geo.etaLE, iTED_geo.xsiLE, eta_element_iTED);
iTED_relevantElementLEShape.relZLE_iTED = interpol_linear(iTED_geo.etaLE, iTED_geo.relHeightLE, eta_element_iTED);
iTED_relevantElementLEShape.relChordUpperSkin_iTED = interpol_linear(iTED_geo.etaLE, iTED_geo.xsiUpperSkin, eta_element_iTED);
iTED_relevantElementLEShape.relChordLowerSkin_iTED = interpol_linear(iTED_geo.etaLE, iTED_geo.xsiLowerSkin, eta_element_iTED);

varargout{1} = 0;
%% 2) Check if etaLE == etaTE, if not whether inboard or outboard belong to one segment
idx_inclination = iTED_geo.etaLE == iTED_geo.etaTE;

if idx_inclination  ~= 1

    min_eta_LE = min(iTED_geo.etaLE);     max_eta_LE = max(iTED_geo.etaLE);
    min_eta_TE = min(iTED_geo.etaTE);     max_eta_TE = max(iTED_geo.etaTE);
    
    temp_dif_min_LE = eta_element_compSeg - min_eta_LE;  temp_dif_max_LE = eta_element_compSeg - max_eta_LE;
    temp_dif_min_TE = eta_element_compSeg - min_eta_TE;  temp_dif_max_TE = eta_element_compSeg - max_eta_TE;
    
    for i = 1: length(eta_element_compSeg)-1
        if temp_dif_min_LE(i) <= 0 && temp_dif_min_LE(i+1) >= 0
            num_startElement_iTED_LE = num_startElement_compSeg + i - 1;
        end
        
        if temp_dif_max_LE(i) <= 0 && temp_dif_max_LE(i+1) >= 0
            num_endElement_iTED_LE = num_startElement_compSeg + i;
        end
        
        if temp_dif_min_TE(i) <= 0 && temp_dif_min_TE(i+1) >= 0
            num_startElement_iTED_TE =  num_startElement_compSeg + i - 1;
        end
        
        if temp_dif_max_TE(i) <= 0 && temp_dif_max_TE(i+1) >= 0
            num_endElement_iTED_TE = num_startElement_compSeg + i;
        end
    end
    
    num_element_iTEDLE = num_endElement_iTED_LE - num_startElement_iTED_LE + 1;
    num_element_iTEDTE = num_endElement_iTED_TE - num_startElement_iTED_TE + 1;
    %-------------------------------------------------------------------%
    for u = 1 : num_element_iTEDLE
        eta_element_iTEDLE(u) = eta_element_compSeg(num_startElement_iTED_LE + u - 1);
    end
    
    for u = 1: num_element_iTEDTE
        eta_element_iTEDTE(u) = eta_element_compSeg(num_startElement_iTED_TE + u - 1);
    end
    
    varargout{1} = num_startElement_iTED_LE;
    varargout{2} = num_element_iTEDLE;
    varargout{3} = eta_element_iTEDLE;
    
    varargout{4} = num_startElement_iTED_TE;
    varargout{5} = num_element_iTEDTE;
    varargout{6} = eta_element_iTEDTE;
end
end

function [y_all] = interpol_linear(X0, Y0, x_all)
% X0 1*2
% Y0 1*2
% x_all vector
y_all = Y0(1) + (x_all - X0(1)).*( (Y0(2) - Y0(1))/(X0(2) - X0(1)));
end

function [xyz] = interpol_inOutBoard(X0, Y0, eta)
% X0 1*2
% Y0 n*6, first 3 column first airfoil, last 3 column second airfoil
% eta scalar

xyz = Y0(:,1:3) + (Y0(:,4:6) - Y0(:,1:3)).*((eta-X0(1))/(X0(2)-X0(1)));

end

function [xyz] = interpol_inclined_inOutBoard(X0, Y0, eta)
% X0 1*2
% Y0 n*6, first 3 column first airfoil, last 3 column second airfoil
% eta vector

Y01 = Y0(:,1:3);
Y02 = Y0(:,4:6);
Y_delta = Y02 - Y01;

for i = 1: length(eta)
    xyz(i,:) = Y01(i,:) + Y_delta(i,:).*((eta(i)-X0(1))/(X0(2)-X0(1)));
end

end
