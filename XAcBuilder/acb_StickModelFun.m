function acb_StickModelFun

    disp(' *********** Start Stick Model generation... *************')
    structACBprj = xml2struct(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\AcBExpXML.xml'));
    
    save(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir\ACBprj.mat'),'structACBprj');
	
	
	
    % Da CPACS Creator
	% Folder Technology, stickmodel
	% Ordine funzioni: Technology_Fun(1,CPACSXMLstruct)
	
	% Technology_Fun(1,CPACSTEST)
	disp('Matlab CPACS >>> STRUCT XML creation...')
	[struct_20_D150] = xml2structN(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBuilderSM\CPACS_20_D150.xml'));
	struct_20_D150 % controllo
    TOLOAD=struct_20_D150.cpacs{1,1};
	disp('OK!')
    %load(struct_20_D150);
	Technology_Fun(1,TOLOAD);
	
	
end