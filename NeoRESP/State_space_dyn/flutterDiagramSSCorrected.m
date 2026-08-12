function [figHandle] = flutterDiagramSSCorrected(dyn_model, Vlist, ssmodel, figHandle, lineSpec, l_a, varargin)
%
%
%
%-------------------------------------------------------------------------------
% 26-08-2016
%


if nargin < 4 || isempty(figHandle)
	figCmplx = figure;
	figFreq = figure;
	figDamp = figure;
else
	figCmplx = figHandle(1);
	figFreq = figHandle(2);
	figDamp = figHandle(3);
end


figure(figCmplx); hold on
set(gca, 'fontsize', 16)
grid on
xlabel('real(\lambda) [rad/s]')
ylabel('imag(\lambda) [rad/s]')


% Frequency --------------------------------------------------------------------
figure(figFreq); hold on
set(gca, 'fontsize', 16)
grid on
xlabel('V [m/s]')
ylabel('frequency [Hz]')

% Damping ----------------------------------------------------------------------
figure(figDamp); hold on
set(gca, 'fontsize', 16)
grid on
xlabel('V [m/s]')
ylabel('g = -2\xi')

for iv = 1:length(Vlist)

	ssAEmodel = getAEmodelCorrected(dyn_model, ssmodel, 'Vinf', Vlist(iv), varargin{:});

	if iv == 1
		nx = size(ssAEmodel,1);
		eigTable = zeros(nx,length(Vlist));
		fillTable = false(nx,length(Vlist));
	end

	l = eig(ssAEmodel.A);

	l = l(imag(l)>=0);

	nEig = length(l);

	eigTable(1:nEig,iv) = l;
	fillTable(1:nEig,iv) = true;

end

nmax = sum( (sum(fillTable,2)>0) );

for iMode = 1:nmax
	l = eigTable(iMode,fillTable(iMode,:));

	figure(figCmplx);
	plot(real(l), imag(l), lineSpec);

	%[freq, damp] = complexEig2FreqDamp(Vlist(iv), l, l_a);

	% figure(figFreq);
	% plot(Vlist(iv), freq, lineSpec);

	% figure(figDamp);
	% plot(Vlist(iv), damp, lineSpec);

end


figHandle(1) = figCmplx;
figHandle(2) = figFreq;
figHandle(3) = figDamp;

return
