function acb_initac_addon

global defac
%
% default values
%

disp('Setup Addons values...')

%defac.CampoTest.Caratteristica.Sottocaratteristica.ValoreA = 999.;
%defac.CampoTest.Caratteristica.Sottocaratteristica.ValoreB = 'Pippo';
defac.weight_balance.COG_AddOns.Crew = 80.;
defac.WingMK.Sectors_AsWinglets = 0;
defac.WingMK.winglet_start_at_kink = 8;

defac.WingMK.area_Corr=155.0;
defac.WingMK.Span_Corr=34.1;
defac.WingMK.AR_Corr=(defac.WingMK.Span)^2/defac.WingMK.area;

disp('....................Completed.')
end