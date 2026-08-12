function [] = createModelReport(filename_sma, inputOpt)
%
%
% 17-11-2017
%
%



if nargin == 1
	inputOpt = [];
end

baseOpt.saveFig = true;
baseOpt.modeSet = 'elastic';
baseOpt.scale = 100;
baseOpt.onlyStru = false;
baseOpt.dirNameLatex = './modelReport';
baseOpt.tag = '';

options = setOptions(baseOpt, inputOpt, 'warning');

tag = options.tag;

dirNameLatex = options.dirNameLatex;
figfolder = ['imgs/ModalShapesNeoCASS', tag];
figfolderSurf = ['imgs/controlSurfaces', tag];
nameFile = ['modalShapes', tag, '.tex'];
nameFileSurf = ['controlSurfaces', tag, '.tex'];

savefig  = options.saveFig;
scale    = options.scale;
modeSet  = options.modeSet;
onlyStru = options.onlyStru;



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[beam_model, dlm_model] = generateDeformedMesh(filename_sma);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if isfield(beam_model, 'Res')
	resultsStruct = beam_model.Res;
elseif isfield(beam_model, 'Struct')
	resultsStruct = beam_model.Struct;
else
	error('No result struct available');
end

if onlyStru
	beam_model.Aero.lattice_vlm = [];
	beam_model.Aero.lattice_dlm = [];
end

system(['mkdir -p ', dirNameLatex]);
if savefig
	system(['mkdir -p ', dirNameLatex, '/', figfolder]);
end

nModes = length(resultsStruct.Omega);
if ~isempty(modeSet) && isstr(modeSet)
	switch modeSet
	case 'all'
		modeSet = 1:nModes;
	case 'elastic'
		modeSet = find(abs(resultsStruct.Omega)>1e-4);
	otherwise
		error('Not recognized value for option ''modeSet'', good values are: ''all'', ''elastic''');
	end
end

nSet = length(modeSet);

if nSet>0
	fid = fopen([dirNameLatex, '/', nameFile], 'w');

	fprintf(fid, '\\begin{table}[h]\n');
	fprintf(fid, '	\\centering\n');
	fprintf(fid, '	\\begin{tabular}{r c}\n');
	fprintf(fid, '		\\hline\\hline\n');
	fprintf(fid, '		Mode $\\#$ & Frequency [Hz] \\\\ \n');
	fprintf(fid, '		\\hline\n');
	for iSet = 1:nSet
		freq = resultsStruct.Omega(modeSet(iSet))/2/pi;
		fprintf(fid, '		  %2d  &  $%7.3f$  \\\\ \n', modeSet(iSet), freq);
	end
	fprintf(fid, '		\\hline\\hline\n');
	fprintf(fid, '	\\end{tabular}\n');
	fprintf(fid, '	\\caption{Modal frequencies}\n');
	fprintf(fid, '	\\label{tab:modalFrequecnies}\n');
	fprintf(fid, '\\end{table}\n');

	nFigInPage = 0;

	for iSet = 1:nSet

		figID = plotLinearDispl(beam_model, beam_model.Struct, modeSet(iSet), scale);

		if isempty(figID)
			continue;
		end

		figure(figID);

		set(figID, 'Position', [97 54 1011 585]);
		set(gca, 'visible', 'off')

		%set(gca, 'CameraTarget', [0, 0, 0]);


		ax0 = gca;
		set(ax0, 'Position', [0.5, 0.02,  0.5,0.5]);
		set(ax0, 'view', [-65,27])
		set(ax0, 'CameraViewAngle', 5)

		axTop = copyobj(ax0,figID);
		set(axTop, 'Position', [0.02, 0.02, 0.5,0.5]);
		set(axTop, 'view', [0,90])

		axFront = copyobj(ax0,figID);
		set(axFront, 'Position', [0.5,0.5,0.5,0.5]);
		set(axFront, 'view', [-90,0])


		axSide = copyobj(ax0,figID);
		set(axSide, 'Position', [0.02, 0.5, 0.5,0.5]);
		set(axSide, 'view', [0,0])

		figName = get(figID, 'Name');
		for ii = 1:length(figName)
			if figName(ii)==' ';
				figName(ii) = '_';
			end
		end

		extension = 'png';

		if savefig
			figname_png = [dirNameLatex, '/', figfolder, '/', figName, '.', extension];
			print(figID, figname_png, '-dpng', '-r200');
		end

		htitle = get(ax0, 'title');
		labelString = get(htitle, 'string');

		fprintf(fid, '\\begin{figure}[H]\n');
		fprintf(fid, '	\\centering\n');
		fprintf(fid, '	\\includegraphics[width = 1.0\\textwidth]{%s/{%s}.%s}\n', figfolder, figName, extension);
		fprintf(fid, '	\\caption{%s}\n', labelString);
		fprintf(fid, '\\end{figure}\n');
		fprintf(fid, '\n');

		nFigInPage = nFigInPage + 1;

		if nFigInPage == 2
			fprintf(fid, '\\clearpage\n');
			nFigInPage = 0;
		end
		fprintf(fid, '\n');

		if savefig
			close(figID);
		end
	end

	fclose(fid);
end



%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Plot control surfaces displacements
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if ~onlyStru
	deformSet = nModes+1 :size(dlm_model.data.n_displ,3);
	lattice = beam_model.Aero.lattice_dlm;
	scale = 1;
	nfig = [];
	plotUndeformed = false;

	nSet = length(deformSet);

	if savefig
		system(['mkdir -p ', dirNameLatex, '/', figfolderSurf]);
	end

	if nSet>0
		fid = fopen([dirNameLatex, '/', nameFileSurf], 'w');

		nFigInPage = 0;

		for iSet = 1:nSet

			figID = plot_dlm_deformed(lattice, dlm_model, deformSet(iSet), scale, nfig, plotUndeformed);

			if isempty(figID)
				continue;
			end

			figure(figID);

			set(figID, 'Position', [1 1 1254 443]);
			set(gca, 'visible', 'off')

			ax0 = gca;

			child = get(ax0, 'children');
			for iChildren = 1:length(child)
				type = get(child(iChildren), 'type');
				if strcmp(type, 'patch')
					set(child(iChildren), 'facealpha', 1);
					set(child(iChildren), 'linewidth', 0.5);
					set(child(iChildren), 'facecolor', [0.5,0.5,0.5]);
					set(child(iChildren), 'edgecolor', 'k');
					break;
				end
			end

			set(ax0, 'view', [-65,27])
			set(ax0, 'CameraViewAngle', 5)
			set(ax0, 'Position', [0.02, 0.02, 0.5,1.0]);

			ax1 = copyobj(ax0,figID);
			set(ax1, 'view', [-115,-27])
			set(ax1, 'Position', [0.4, 0.02, 0.5,1.0]);


			extension = 'png';

			figName = ['deflection_', beam_model.Aero.lattice.Control.Name{iSet}];

			if savefig
				figname_png = [dirNameLatex, '/', figfolderSurf, '/', figName, '.', extension];
				print(figID, figname_png, '-dpng', '-r200');
			end

			htitle = get(ax0, 'title');
			labelString = get(htitle, 'string');

			fprintf(fid, '\\begin{figure}[H]\n');
			fprintf(fid, '	\\centering\n');
			fprintf(fid, '	\\includegraphics[width = 1.0\\textwidth]{%s/{%s}.%s}\n', figfolderSurf, figName, extension);
			fprintf(fid, '	\\caption{%s}\n', labelString);
			fprintf(fid, '\\end{figure}\n');
			fprintf(fid, '\n');

			nFigInPage = nFigInPage + 1;

			if nFigInPage == 2
				fprintf(fid, '\\clearpage\n');
				nFigInPage = 0;
			end
			fprintf(fid, '\n');

			if savefig
				close(figID);
			end
		end

		fclose(fid);
	end
end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
return
