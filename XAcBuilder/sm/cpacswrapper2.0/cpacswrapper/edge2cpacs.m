function [CPACS_XML]=edge2cpacs(CPACS_XML,analysis,aircraft)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  edge2CPACS                                                          %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-10-11 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Multy run
AERODATA=analysis.parameterSweep.AERODATA;

file='aerodataTestOut.xml';

homeDir=pwd;

%% ISA

cd ..
[rho,a,p,mu]=ISAtmosphere(analysis.state.ALT);
cd(homeDir)

%% Definitions
% Global Parameter
cfx='';cfy='';cfz='';cmx='';cmy='';cmz='';machNumber='';reynoldsNumber='';angleOfYaw='';angleOfAttack='';cL='';cD='';cD0='';
% Dynamic Damping Derivatives
dcfxda ='';dcfyda ='';dcfzda ='';dcmxda ='';dcmyda ='';dcmzda ='';dcfxdb ='';dcfydb ='';dcfzdb ='';dcmxdb ='';dcmydb ='';dcmzdb ='';
% Damping derivatives
dcfxdp = '';dcfxdr = '';dcfxdq = '';dcfydp = '';dcfydr = '';dcfydq = '';dcfzdp = '';dcfzdr = '';dcfzdq = '';dcmxdr = '';dcmxdp = '';dcmxdq = '';dcmydp = '';dcmydq = '';dcmydr = '';dcmzdp = '';dcmzdq = '';dcmzdr = '';    

% CS Derivative array
% for csNum=1:size(AERODATA.Cxd,4)+size(AERODATA.CXi,4)
%     cs{csNum,1}.machNumberCS     = '';
%     cs{csNum,1}.reynoldsNumberCS = '';
%     cs{csNum,1}.angleOfYawCS     = '';
%     cs{csNum,1}.angleOfAttackCS  = '';
%     cs{csNum,1}.relDeflectionCS  = '';
%     cs{csNum,1}.dcfx             = '';
%     cs{csNum,1}.dcfy             = '';
%     cs{csNum,1}.dcfz             = '';
%     cs{csNum,1}.dcmx             = '';
%     cs{csNum,1}.dcmy             = '';
%     cs{csNum,1}.dcmz             = '';
% end

%% State Parameter

for iii=1:size(AERODATA.TASrange,2)
    if iii==1
        machNumber =     [num2str(AERODATA.TASrange(1,iii)/a)];
    else
        machNumber =     [machNumber,';',num2str(AERODATA.TASrange(1,iii)/a)];
    end        
end
for ii=1:size(AERODATA.betarange,2)
    if ii==1
        angleOfYaw =     [num2str(AERODATA.betarange(1,ii)*180/pi)];
    else
        angleOfYaw =     [angleOfYaw,';',num2str(AERODATA.betarange(1,ii)*180/pi)];
    end   
end
for i=1:size(AERODATA.alpharange,2)
    if i==1
        angleOfAttack =     [num2str(AERODATA.betarange(1,i)*180/pi)];
    else
        angleOfAttack =     [angleOfAttack,';',num2str(AERODATA.alpharange(1,i)*180/pi)];
    end   
end
reynoldsNumber = num2str(0);

%% Get alpha, betha, Velocity Data

for i=1:size(AERODATA.alpharange,2)
    for ii=1:size(AERODATA.betarange,2)
        for iii=1:size(AERODATA.TASrange,2)

%% Global Parameter
            
            % Add CD0 to CD
            % AERODATA.CD(i,ii,iii) = AERODATA.CD(i,ii,iii)+AERODATA.CD0(i,ii,iii);
            
            cfx =            [cfx,num2str(AERODATA.CD(i,ii,iii)),';'];%Defined in CPACS as CX
            cfy =            [cfy,num2str(AERODATA.CC(i,ii,iii)),';'];%Defined in CPACS as CY
            cfz =            [cfz,num2str(AERODATA.CL(i,ii,iii)),';'];%Defined in CPACS as CZ
            cmx =            [cmx,num2str(AERODATA.Cl(i,ii,iii)),';'];
            cmy =            [cmy,num2str(AERODATA.Cm(i,ii,iii)),';'];
            cmz =            [cmz,num2str(AERODATA.Cn(i,ii,iii)),';'];
            
            % Extra parameter (not define in theCPACS shema jet)  
            cL =            [cL,num2str(AERODATA.CL(i,ii,iii)),';'];
            cD =            [cD,num2str(AERODATA.CD(i,ii,iii)),';'];
            cC =            [cD,num2str(AERODATA.CC(i,ii,iii)),';'];
            % cD0 =           [cD0,num2str(AERODATA.CD0(i,ii,iii)),';'];            
            
            try dcfxda =            [dcfxda,num2str(AERODATA.Cxa(i,ii,iii)),';']; catch disp('no Cxa'); end
            try dcfyda =            [dcfyda,num2str(AERODATA.Cya(i,ii,iii)),';']; catch disp('no Cya'); end
            try dcfzda =            [dcfzda,num2str(AERODATA.Cza(i,ii,iii)),';']; catch disp('no Cza'); end
            try dcmxda =            [dcmxda,num2str(AERODATA.Cla(i,ii,iii)),';']; catch disp('no Cla'); end
            try dcmyda =            [dcmyda,num2str(AERODATA.Cma(i,ii,iii)),';']; catch disp('no Cma'); end
            try dcmzda =            [dcmzda,num2str(AERODATA.Cna(i,ii,iii)),';']; catch disp('no Cna'); end
            
            try dcfxdb =            [dcfxdb,num2str(AERODATA.Cxb(i,ii,iii)),';']; catch disp('no Cxb'); end
            try dcfydb =            [dcfydb,num2str(AERODATA.Cyb(i,ii,iii)),';']; catch disp('no Cyb'); end
            try dcfzdb =            [dcfzdb,num2str(AERODATA.Czb(i,ii,iii)),';']; catch disp('no Czb'); end
            try dcmxdb =            [dcmxdb,num2str(AERODATA.Clb(i,ii,iii)),';']; catch disp('no Clb'); end
            try dcmydb =            [dcmydb,num2str(AERODATA.Cmb(i,ii,iii)),';']; catch disp('no Cmb'); end
            try dcmzdb =            [dcmzdb,num2str(AERODATA.Cnb(i,ii,iii)),';']; catch disp('no Cnb'); end

%% Damping derivatives

            try dcfxdp = [dcfxdp,num2str(AERODATA.Cxp(i,ii,iii)),';']; catch disp('no Cxp'); end
            try dcfxdr = [dcfxdr,num2str(AERODATA.Cxr(i,ii,iii)),';']; catch disp('no Cxr'); end
            try dcfxdq = [dcfxdq,num2str(AERODATA.Cxq(i,ii,iii)),';']; catch disp('no Cxq'); end
            
            try dcfydp = [dcfydp,num2str(AERODATA.Cyp(i,ii,iii)),';']; catch disp('no Cyp'); end
            try dcfydr = [dcfydr,num2str(AERODATA.Cyq(i,ii,iii)),';']; catch disp('no Cyq'); end
            try dcfydq = [dcfydq,num2str(AERODATA.Cyr(i,ii,iii)),';']; catch disp('no Cyr'); end
            
            try dcfzdp = [dcfzdp,num2str(AERODATA.Czp(i,ii,iii)),';']; catch disp('no Czp'); end
            try dcfzdr = [dcfzdr,num2str(AERODATA.Czq(i,ii,iii)),';']; catch disp('no Czq'); end
            try dcfzdq = [dcfzdq,num2str(AERODATA.Czr(i,ii,iii)),';']; catch disp('no Czr'); end
            
            try dcmxdr = [dcmxdr,num2str(AERODATA.Clp(i,ii,iii)),';']; catch disp('no Clp'); end
            try dcmxdp = [dcmxdp,num2str(AERODATA.Clq(i,ii,iii)),';']; catch disp('no Clq'); end
            try dcmxdq = [dcmxdq,num2str(AERODATA.Clr(i,ii,iii)),';']; catch disp('no Clr'); end
            
            try dcmydp = [dcmydp,num2str(AERODATA.Cmp(i,ii,iii)),';']; catch disp('no Cmp'); end
            try dcmydq = [dcmydq,num2str(AERODATA.Cmq(i,ii,iii)),';']; catch disp('no Cmq'); end
            try dcmydr = [dcmydr,num2str(AERODATA.Cmr(i,ii,iii)),';']; catch disp('no Cmr'); end
            
            try dcmzdp = [dcmzdp,num2str(AERODATA.Cnp(i,ii,iii)),';']; catch disp('no Cnp'); end
            try dcmzdq = [dcmzdq,num2str(AERODATA.Cnq(i,ii,iii)),';']; catch disp('no Cnq'); end
            try dcmzdr = [dcmzdr,num2str(AERODATA.Cnr(i,ii,iii)),';']; catch disp('no Cnr'); end


%% CS Derivative array
            % for csNum=1:size(AERODATA.Cxd,4)
            %     cs{csNum,1}.controlSurfaceUID=['',num2str(csNum)];
            % 
            %     %cs{csNum,1}.machNumberCS =     [cs{csNum,1}.machNumberCS,num2str(AERODATA.TASrange(1,iii)/a),';'];
            %     %cs{csNum,1}.reynoldsNumbeCSr = [cs{csNum,1}.reynoldsNumberCS,num2str(0),';'];
            %     %cs{csNum,1}.angleOfYawCS =     [cs{csNum,1}.angleOfYawCS,num2str(AERODATA.betarange(1,ii)),';'];
            %     %cs{csNum,1}.angleOfAttackCS =  [cs{csNum,1}.angleOfAttackCS,num2str(AERODATA.alpharange(1,i)),';'];
            %     %cs{csNum,1}.relDeflectionCS  = [cs{csNum,1}.relDeflectionCS,num2str(0),';'];
            % 
            %     %cs{csNum,1}.dcfx             = [cs{csNum,1}.dcfx,num2str(AERODATA.Cxd(i,ii,iii,csNum)),';'];
            %     %cs{csNum,1}.dcfy             = [cs{csNum,1}.dcfy,num2str(AERODATA.Cyd(i,ii,iii,csNum)),';'];
            %     %cs{csNum,1}.dcfz             = [cs{csNum,1}.dcfz,num2str(AERODATA.Czd(i,ii,iii,csNum)),';'];
            % 
            %     cs{csNum,1}.dcfx             = [cs{csNum,1}.dcfx,num2str(AERODATA.CLd(i,ii,iii,csNum)),';'];%Defined in CPACS as CX
            %     cs{csNum,1}.dcfy             = [cs{csNum,1}.dcfy,num2str(AERODATA.CCd(i,ii,iii,csNum)),';'];%Defined in CPACS as CX
            %     cs{csNum,1}.dcfz             = [cs{csNum,1}.dcfz,num2str(AERODATA.CDd(i,ii,iii,csNum)),';'];%Defined in CPACS as CX
            % 
            %     cs{csNum,1}.dcmx             = [cs{csNum,1}.dcmx,num2str(AERODATA.Cld(i,ii,iii,csNum)),';'];
            %     cs{csNum,1}.dcmy             = [cs{csNum,1}.dcmy,num2str(AERODATA.Cmd(i,ii,iii,csNum)),';'];
            %     cs{csNum,1}.dcmz             = [cs{csNum,1}.dcmz,num2str(AERODATA.Cnd(i,ii,iii,csNum)),';'];
            % 
            %     cs{csNum,1}.dcL              = [cs{csNum,1}.dcmz,num2str(AERODATA.Cnd(i,ii,iii,csNum)),';'];
            % end
%% Wing Derivative (when as Controls, eg. as a vertical tail trim)            
            % for csWingNum=1:size(AERODATA.CXi,4)
            %     cs{csNum+csWingNum,1}.controlSurfaceUID=['wing',num2str(csWingNum)];
            % 
            %     %cs{csNum+csWingNum,1}.machNumberCS =     [cs{csNum+csWingNum,1}.machNumberCS,num2str(AERODATA.TASrange(1,iii)/a),';'];
            %     %cs{csNum+csWingNum,1}.reynoldsNumbeCSr = [cs{csNum+csWingNum,1}.reynoldsNumberCS,num2str(0),';'];
            %     %cs{csNum+csWingNum,1}.angleOfYawCS =     [cs{csNum+csWingNum,1}.angleOfYawCS,num2str(AERODATA.betarange(1,ii)),';'];
            %     %cs{csNum+csWingNum,1}.angleOfAttackCS =  [cs{csNum+csWingNum,1}.angleOfAttackCS,num2str(AERODATA.alpharange(1,i)),';'];
            %     %cs{csNum+csWingNum,1}.relDeflectionCS  = [cs{csNum+csWingNum,1}.relDeflectionCS,num2str(0),';'];
            % 
            %     %cs{csNum+csWingNum,1}.dcfx             = [cs{csNum+csWingNum,1}.dcfx,num2str(AERODATA.CXi(i,ii,iii,csWingNum)),';'];
            %     %cs{csNum+csWingNum,1}.dcfy             = [cs{csNum+csWingNum,1}.dcfy,num2str(AERODATA.CYi(i,ii,iii,csWingNum)),';'];
            %     %cs{csNum+csWingNum,1}.dcfz             = [cs{csNum+csWingNum,1}.dcfz,num2str(AERODATA.CZi(i,ii,iii,csWingNum)),';'];
            % 
            %     cs{csNum+csWingNum,1}.dcfx             = [cs{csNum+csWingNum,1}.dcfx,num2str(AERODATA.CLi(i,ii,iii,csWingNum)),';'];%Defined in CPACS as CX
            %     cs{csNum+csWingNum,1}.dcfy             = [cs{csNum+csWingNum,1}.dcfy,num2str(AERODATA.CCi(i,ii,iii,csWingNum)),';'];%Defined in CPACS as CX
            %     cs{csNum+csWingNum,1}.dcfz             = [cs{csNum+csWingNum,1}.dcfz,num2str(AERODATA.CDi(i,ii,iii,csWingNum)),';'];%Defined in CPACS as CX
            % 
            %     cs{csNum+csWingNum,1}.dcmx             = [cs{csNum+csWingNum,1}.dcmx,num2str(AERODATA.Cli(i,ii,iii,csWingNum)),';'];
            %     cs{csNum+csWingNum,1}.dcmy             = [cs{csNum+csWingNum,1}.dcmy,num2str(AERODATA.Cmi(i,ii,iii,csWingNum)),';'];
            %     cs{csNum+csWingNum,1}.dcmz             = [cs{csNum+csWingNum,1}.dcmz,num2str(AERODATA.Cni(i,ii,iii,csWingNum)),';'];        
            % 
            % end         
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Writing Array to CPACS mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CPACS version Specifics

if str2num(CPACS_XML.header{1,1}.cpacsVersion{1,1}.CONTENT)<2 
    CPvesion=1;
    CPversionType{1,1}='global';
    CPversionType{2,1}='controlSurfacesPolars';
    CPversionType{3,1}='controlSurfacePolars';
else %CPACS VERSION 2.0
    CPvesion=2;
    CPversionType{1,1}='analyses';
    CPversionType{2,1}='controlSurfacesPerformanceMaps';
    CPversionType{3,1}='controlSurfacePerformanceMap';
end

%% Referece values

CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.area{1,1}.CONTENT = num2str(AERODATA.S);
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.length{1,1}.CONTENT = num2str(AERODATA.c);
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.point{1,1}.x{1,1}.CONTENT = num2str(AERODATA.refPoint(1,1));
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.point{1,1}.y{1,1}.CONTENT = num2str(AERODATA.refPoint(1,2));
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.reference{1,1}.point{1,1}.z{1,1}.CONTENT = num2str(AERODATA.refPoint(1,3));

%% Global Parameter
% Type definition
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.machNumber{1,1}.ATTRIBUTE.mapType='vector';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.reynoldsNumber{1,1}.ATTRIBUTE.mapType='vector';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.angleOfYaw{1,1}.ATTRIBUTE.mapType='vector';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.angleOfAttack{1,1}.ATTRIBUTE.mapType='vector';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfx{1,1}.ATTRIBUTE.mapType='array';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfy{1,1}.ATTRIBUTE.mapType='array';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfz{1,1}.ATTRIBUTE.mapType='array';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmx{1,1}.ATTRIBUTE.mapType='array';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmy{1,1}.ATTRIBUTE.mapType='array';
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmz{1,1}.ATTRIBUTE.mapType='array';

% Array
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.machNumber{1,1}.CONTENT        = machNumber;    
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.reynoldsNumber{1,1}.CONTENT    = reynoldsNumber;
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.angleOfYaw{1,1}.CONTENT        = angleOfYaw;    
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.angleOfAttack{1,1}.CONTENT     = angleOfAttack; 
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfx{1,1}.CONTENT               = cfx;           
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfy{1,1}.CONTENT               = cfy;           
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cfz{1,1}.CONTENT               = cfz;           
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmx{1,1}.CONTENT               = cmx;           
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmy{1,1}.CONTENT               = cmy;           
CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cmz{1,1}.CONTENT               = cmz;  


 % Extra parameter (not define in theCPACS shema jet)
%  % Type definition
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cL{1,1}.ATTRIBUTE.mapType='array';      
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cD{1,1}.ATTRIBUTE.mapType='array';      
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cD0{1,1}.ATTRIBUTE.mapType='array';      
%  
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cL{1,1}.CONTENT  = cL; 
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cD{1,1}.CONTENT  = cD; 
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.cD0{1,1}.CONTENT = cD0;
%  
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfxda{1,1}.ATTRIBUTE.mapType='array';      
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfyda{1,1}.ATTRIBUTE.mapType='array';      
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfzda{1,1}.ATTRIBUTE.mapType='array';      
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmxda{1,1}.ATTRIBUTE.mapType='array';      
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmyda{1,1}.ATTRIBUTE.mapType='array';      
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmzda{1,1}.ATTRIBUTE.mapType='array';      
% % Array                                                                                                                                                                                                                                                                  
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfxda{1,1}.CONTENT               = dcfxda; 
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfyda{1,1}.CONTENT               = dcfyda; 
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfzda{1,1}.CONTENT               = dcfzda; 
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmxda{1,1}.CONTENT               = dcmxda; 
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmyda{1,1}.CONTENT               = dcmyda; 
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmzda{1,1}.CONTENT               = dcmzda; 
% 
% % Type definition
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfxdb{1,1}.ATTRIBUTE.mapType='array';     
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfydb{1,1}.ATTRIBUTE.mapType='array';     
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfzdb{1,1}.ATTRIBUTE.mapType='array';     
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmxdb{1,1}.ATTRIBUTE.mapType='array';     
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmydb{1,1}.ATTRIBUTE.mapType='array';     
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmzdb{1,1}.ATTRIBUTE.mapType='array';                                                                                                                                   
% % Array                                                                                                                                
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfxdb{1,1}.CONTENT               = dcfxdb;
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfydb{1,1}.CONTENT               = dcfydb;
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcfzdb{1,1}.CONTENT               = dcfzdb;
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmxdb{1,1}.CONTENT               = dcmxdb;
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmydb{1,1}.CONTENT               = dcmydb;
% CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dcmzdb{1,1}.CONTENT               = dcmzdb;

%% Damping derivatives

% if CPvesion==2
%     % Type definition
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdpstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdrstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdqstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydpstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydrstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydqstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdpstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdrstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdqstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdrstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdpstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdqstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydpstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydqstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydrstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdpstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdqstar{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdrstar{1,1}.ATTRIBUTE.mapType='array';
% 
%     % Array
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdpstar{1,1}.CONTENT    =dcfxdp;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdrstar{1,1}.CONTENT    =dcfxdr;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfxdqstar{1,1}.CONTENT    =dcfxdq;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydpstar{1,1}.CONTENT    =dcfydp;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydrstar{1,1}.CONTENT    =dcfydr;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfydqstar{1,1}.CONTENT    =dcfydq;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdpstar{1,1}.CONTENT    =dcfzdp;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdrstar{1,1}.CONTENT    =dcfzdr;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcfzdqstar{1,1}.CONTENT    =dcfzdq;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdrstar{1,1}.CONTENT    =dcmxdr;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdpstar{1,1}.CONTENT    =dcmxdp;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmxdqstar{1,1}.CONTENT    =dcmxdq;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydpstar{1,1}.CONTENT    =dcmydp;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydqstar{1,1}.CONTENT    =dcmydq;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmydrstar{1,1}.CONTENT    =dcmydr;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdpstar{1,1}.CONTENT    =dcmzdp;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdqstar{1,1}.CONTENT    =dcmzdq;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.positiveRates{1,1}.dcmzdrstar{1,1}.CONTENT    =dcmzdr;
% 
% else
    % % Type definition
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdp{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdr{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdq{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydp{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydr{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydq{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdp{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdr{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdq{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdr{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdp{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdq{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydp{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydq{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydr{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdp{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdq{1,1}.ATTRIBUTE.mapType='array';
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdr{1,1}.ATTRIBUTE.mapType='array';
    % 
    % % Array
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdp{1,1}.CONTENT    =dcfxdp;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdr{1,1}.CONTENT    =dcfxdr;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfxdq{1,1}.CONTENT    =dcfxdq;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydp{1,1}.CONTENT    =dcfydp;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydr{1,1}.CONTENT    =dcfydr;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfydq{1,1}.CONTENT    =dcfydq;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdp{1,1}.CONTENT    =dcfzdp;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdr{1,1}.CONTENT    =dcfzdr;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcfzdq{1,1}.CONTENT    =dcfzdq;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdr{1,1}.CONTENT    =dcmxdr;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdp{1,1}.CONTENT    =dcmxdp;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmxdq{1,1}.CONTENT    =dcmxdq;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydp{1,1}.CONTENT    =dcmydp;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydq{1,1}.CONTENT    =dcmydq;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmydr{1,1}.CONTENT    =dcmydr;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdp{1,1}.CONTENT    =dcmzdp;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdq{1,1}.CONTENT    =dcmzdq;
    % CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.(CPversionType{1,1}){1,1}.aeroPerformanceMap{1,1}.dampingDerivatives{1,1}.dcmzdr{1,1}.CONTENT    =dcmzdr;

% end

%% controlSurfacesPolars

% for csNum=1:size(AERODATA.Cxd,4)+size(AERODATA.CXi,4)
%     
%     controlSurfaceUID=cs{csNum,1}.controlSurfaceUID;    
%     machNumberCS    = cs{csNum,1}.machNumberCS;
%     reynoldsNumberCS= cs{csNum,1}.reynoldsNumberCS ; 
%     angleOfYawCS    = cs{csNum,1}.angleOfYawCS     ; 
%     angleOfAttackCS = cs{csNum,1}.angleOfAttackCS  ; 
%     relDeflectionCS = cs{csNum,1}.relDeflectionCS  ; 
%     dcfx            = cs{csNum,1}.dcfx             ; 
%     dcfy            = cs{csNum,1}.dcfy             ; 
%     dcfz            = cs{csNum,1}.dcfz             ; 
%     dcmx            = cs{csNum,1}.dcmx             ; 
%     dcmy            = cs{csNum,1}.dcmy             ; 
%     dcmz            = cs{csNum,1}.dcmz             ; 
% 
%     % CS UID
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.controlSurfaceUID{1,1}.CONTENT=controlSurfaceUID;
% 
%     % Type definition
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.machNumber{1,1}.ATTRIBUTE.mapType='vector';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.reynoldsNumber{1,1}.ATTRIBUTE.mapType='vector';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.angleOfYaw{1,1}.ATTRIBUTE.mapType='vector';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.angleOfAttack{1,1}.ATTRIBUTE.mapType='vector';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.relDeflection{1,1}.ATTRIBUTE.mapType='vector';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcfx{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcfy{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcfz{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcmx{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcmy{1,1}.ATTRIBUTE.mapType='array';
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcmz{1,1}.ATTRIBUTE.mapType='array';
% 
%     % CS Derivative array
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.machNumber{1,1}.CONTENT         = machNumberCS;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.reynoldsNumber{1,1}.CONTENT     = reynoldsNumberCS;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.angleOfYaw{1,1}.CONTENT         = angleOfYawCS;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.angleOfAttack{1,1}.CONTENT      = angleOfAttackCS;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.relDeflection{1,1}.CONTENT      = relDeflectionCS;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcfx{1,1}.CONTENT               = dcfx;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcfy{1,1}.CONTENT               = dcfy;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcfz{1,1}.CONTENT               = dcfz;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcmx{1,1}.CONTENT               = dcmx;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcmy{1,1}.CONTENT               = dcmy;
%     CPACS_XML.vehicles{1,1}.aircraft{1,1}.model{1,1}.analyses{1,1}.(CPversionType{2,1}){1,1}.(CPversionType{3,1}){1,csNum}.performanceMap{1,1}.dcmz{1,1}.CONTENT               = dcmz;
% 
% end

%% Writing CPACSxml struct to CPACS XML file
s.cpacs{1,1}=CPACS_XML;
try
    struct2xml(s,file)
catch 
    %disp([err.identifier])
    initialize
    struct2xml(s,file)
end
