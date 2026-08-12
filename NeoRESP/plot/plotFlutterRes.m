function figHandle = plotFlutterRes(FlutterData)
nMode = size(FlutterData.Velocity,2);

colorTable = [ ...
         0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.0000    0.5000    0.0000
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    0.0000    0.0000    1.0000
    1.0000    0.0000    0.0000
    0.0000    1.0000    0.0000
    0.6000    0.6000    0.6000
    0.0000    0.0000    0.0000
    0.5000    0.0000    0.8000
    0.0000    0.4000    0.4000
];
markerList = {'o', 's', 'd', 'v', '^', '<', '>', '+', '*', 'x', '.'};

figHandle = figure;
iColor = 0;
iMarker = 1;
for iMode=1:nMode
    flutterDetector = 0;

    Vvect  = FlutterData.Velocity{iMode};
    Freq   = FlutterData.Freq{iMode};
    Damp   = FlutterData.g{iMode};
    if any(Damp>0)
        flutterDetector = 1;
        index = (find(Damp>0));
        int = [index(1)-1 index(1)];
        Vflutter = interp1(Damp(int),Vvect(int),0);
        Fflutter = interp1(Vvect,Freq,Vflutter);
        fprintf('Mode %d unstable, flutter detected at V=%5.2f [m/s] and F=%5.2f[Hz]\n',iMode,Vflutter,Fflutter)
    end
    axFreq = subplot(2,1,1); hold on;
    xlabel('velocity [m/s]')
    ylabel('frequency [Hz]')
    xlim([Vvect(1) Vvect(end)])
    title('V-f')
    grid minor
    hold on
    set(gca,'fontsize',16)
    
    axDamp = subplot(2,1,2); hold on
 
    plot([Vvect(1) Vvect(end)],[0 0],'k--')
    xlabel('velocity [m/s]')
    ylabel('g or 2\xi [-]')
    title('V-g')
    xlim([Vvect(1) Vvect(end)])
    grid minor
    set(gca,'fontsize',16)


    iColor = iColor + 1;
    if iColor > size(colorTable,1)
        iColor = 1;
        iMarker = iMarker + 1;
    end

    color = colorTable(iColor,:);
    marker = markerList{iMarker};

    plot(axFreq, Vvect, Freq,'-xk','MarkerSize',4,'LineWidth',1,'color', color, 'marker', marker, 'markerfacecolor', color)
    plot(axDamp, Vvect, Damp,'-xk','MarkerSize',4,'LineWidth',1,'color', color, 'marker', marker, 'markerfacecolor', color)
    if flutterDetector
        color='k';
        marker='p';
        
    plot(axFreq, Vflutter, Fflutter,'-xk','MarkerSize',4,'LineWidth',1,'color', color, 'marker', marker, 'markerfacecolor', color,'MarkerSize',12)
    plot(axDamp, Vflutter, 0,'-xk','MarkerSize',4,'LineWidth',1,'color', color, 'marker', marker, 'markerfacecolor', color,'MarkerSize',12)    
    end
end
set(axDamp,'XMinorGrid','on')
set(axDamp,'XMinorTick','on')
set(axDamp,'YMinorGrid','on')
set(axDamp,'YMinorTick','on')
set(axFreq,'XMinorGrid','on')
set(axFreq,'XMinorTick','on')
set(axFreq,'YMinorGrid','on')
set(axFreq,'YMinorTick','on')
end