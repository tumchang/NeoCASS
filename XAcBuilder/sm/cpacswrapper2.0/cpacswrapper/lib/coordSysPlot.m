function coordSysPlot(p,coordSysMat,sysColor,sysName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  coordSysPlot                                                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-28 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Aplicated functions                                                     %
% - sphere3D                                                              %
% - arrow3D                                                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Sttings

%Plot Coordinate System Center
sphere3D(p,0.05)

% Names of axis
sysName2='';
for i=1:size(sysName,2)
    sysName2=strcat(sysName2,'_',sysName(1,i));   
end
axeName={['x',sysName2],'y','z'};

%% Plot Coord Sys

for i=1:3
    hold on
    axe1=[p,coordSysMat(:,i)]; 
    arrow3D([axe1(1,1),axe1(2,1),axe1(3,1)], [axe1(1,2),axe1(2,2),axe1(3,2)] ,sysColor, 0.82,0.9)  
    text(axe1(1,1)+axe1(1,2),axe1(2,1)+axe1(2,2),axe1(3,1)+axe1(3,2),axeName{i}) % 'FontSize',18,'HorizontalAlignment','left'
end