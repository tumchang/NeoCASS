function [FUSgeo]=readfuselage_localStruct(FUSgeo, fuselage_struct)
   
%     try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Run Outer Surface Wrapper %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         componentTypeName='fuselages';
        [FUSgeo]=cpacsGeoReader_localStruct(fuselage_struct,FUSgeo,componentTypeName); 
        
        %for fusNum=1:length(CPACSgeo.fuselages.component)
            for i=1:length(FUSgeo.sectionDef.point)  

                airfoil=FUSgeo.sectionDef.airfoil;
                % Calculation of each area with profile geometrie and scaling
                [geom] = polygeom(airfoil{i,1}(:,2),airfoil{i,1}(:,3));
                sec_area(1,i)=geom(1,1);        

                xpos(i,1)=FUSgeo.sectionDef.point{i,1}(1,1);


            end
            % Alternate Diameter
            d_alt=sqrt(max(sec_area)/pi)*2; 
            fuselage.d    = d_alt;
            % Fuselage Length
            fuselage.l    = max(xpos)-min(xpos);


            FUSgeo.diameter=fuselage.d;
            FUSgeo.length=fuselage.l;
        %end          
%     catch
%         disp('read CPACSgeo: Non Fuselage ') 
%     end
        
end