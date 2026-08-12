function [NewS] = inclEngine(NewS,aircraft,wingNum)

%% Stet Basic settings

engNum=1;
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.bypass_ratio ='3.5';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.dp_comb      ='0.04';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.eta_inf      ='0.87';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.eta_inlet    ='0.97';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.eta_nozzle   ='0.95';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.fan_pr       ='1.75';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.name         ='Executive jet TF';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.total_pr     ='14';
NewS.Assembly.JetEngineSpec{1,engNum}.Turbofan.AttributeNewS.turbine_temp ='1400';


NewS.Assembly.JetEngineSpec{1,engNum}.IntakeRegionNewS.JeRegion.AttributeNewS.surface	='RightNacelle';
NewS.Assembly.JetEngineSpec{1,engNum}.IntakeRegionNewS.JeRegion.AttributeNewS.type	='nose';

NewS.Assembly.JetEngineSpec{1,engNum}.NozzleRegionNewS.JeRegion.AttributeNewS.surface = 'RightNacelle';
NewS.Assembly.JetEngineSpec{1,engNum}.NozzleRegionNewS.JeRegion.AttributeNewS.type    = 'tail';

NewS.Assembly.JetEngineSpec{1,engNum}.AttributeNewS.massflow = '18';
NewS.Assembly.JetEngineSpec{1,engNum}.AttributeNewS.name     = 'RightEngine';

%% Engine Body

% ---