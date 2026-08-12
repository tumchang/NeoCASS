function ftime = defineTimeHistory(T, dataType, data, delay, tmax, amplitude, tabled);


nt = length(T);

ftime = zeros(nt,1);

nSections = length(delay);

for iSection = 1:nSections
	ind = (T >= delay(iSection) & T<= delay(iSection) + tmax(iSection));

	t = T(ind) - delay(iSection);


	switch lower(dataType)

	case 'fun'

		fun = Scalar2VectorialFun(data{iSection});

		ftime(ind) = eval(fun) * amplitude;


	case {'file-a', 'file-m', 'tabled'}

		% Get the XY data
		switch lower(dataType)
		case 'file-a'
			XY = load(data{iSection}, '-ascii');
		case 'file-m'
			matData = load(data{iSection}, '-mat');
			dataNames = fieldnames(matData);
			XY = getfield(matData, dataNames{1});
		case 'tabled'
			tabledID = str2num(data{iSection});
			position = tabled.ID==tabledID;
			if any(position)
				XY = tabled.XY{position};
			else
				error('TABLED with ID %d not found', tabledID);
			end
		end

		% Remove doubled points
		posDoubled = find(abs(XY(2:end,1) - XY(1:end-1,1))<1e-10);
		XY(posDoubled+1,1) = XY(posDoubled+1,1) + (T(2)-T(1))/100;

		ftime(ind) = interp1(XY(:,1), XY(:,2)*amplitude, t, 'linear', 0);

	otherwise
		error('Unrecognized input type ''%s''', dataType);
	end
end

















return
