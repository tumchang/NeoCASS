function [figHandle] = plotFlutterDiagram(Vvect, FLeig, l_a, nameList)
%
%
%
%
%
%-------------------------------------------------------------------------------
% 31-08-2016
%

lineStyleList = {'-', '-.', '--', ':', '-', ':', '--'};
colorList = {'b', 'r', 'g', 'c', 'm', 'k', 'y'};


nResults = length(FLeig);

if nResults > 7
	error('Maximum 5 result set allowed');
end

if nargin<4 || isempty(nameList)
	namelist = cell(1,nResults);
	for iResult = 1:nResults
		nameList{iResult} = ['Set ', num2str(iResult)];
	end
end

figHandle = [];

% Complex plane ----------------------------------------------------------------
figure; hold on;
figHandle(1) = gcf;
set(gca, 'fontsize', 16);

htot = zeros(nResults,1);

for iResult = 1:nResults
	h = plot(real(FLeig{iResult}), imag(FLeig{iResult}));

	set(h, 'linewidth', 1.5);

	set(h, 'linestyle', lineStyleList{iResult});
	set(h, 'color', colorList{iResult});

	htot(iResult) = h(1);

end


grid on
xlabel('real part [rad/s]');
ylabel('imaginary part [rad/s]')
legend(htot, nameList, 'location', 'eastoutside')

% Frequency --------------------------------------------------------------------
figure; hold on
figHandle(2) = gcf;
set(gca, 'fontsize', 16)
grid on
xlabel('V [m/s]')
ylabel('frequency [Hz]')

% Damping ----------------------------------------------------------------------
figure; hold on
figHandle(3) = gcf;
set(gca, 'fontsize', 16)
grid on
xlabel('V [m/s]')
ylabel('g = -2\xi')

htotfreq = zeros(nResults,1);
htotdamp = zeros(nResults,1);

for iResult = 1:nResults
	[freq, damp] = complexEig2FreqDamp(Vvect{iResult}, FLeig{iResult}, l_a);


	figure(figHandle(2));
	h = plot(Vvect{iResult}, freq);

	set(h, 'linewidth', 1.5);
	set(h, 'linestyle', lineStyleList{iResult});
	set(h, 'color', colorList{iResult});

	htotfreq(iResult) = h(1);


	figure(figHandle(3));
	h = plot(Vvect{iResult}, damp);

	set(h, 'linewidth', 1.5);
	set(h, 'linestyle', lineStyleList{iResult});
	set(h, 'color', colorList{iResult});

	htotdamp(iResult) = h(1);


end



figure(figHandle(2))
legend(htotfreq, nameList, 'location', 'eastoutside')
figure(figHandle(3))
legend(htotdamp, nameList, 'location', 'eastoutside')





return
