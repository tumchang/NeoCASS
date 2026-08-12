function [Vinf, rhoinf, Minf] = setFlightCondition(refValues, varargin)
%
%
%
%
%-------------------------------------------------------------------------------
% 13-07-2016
%

setInputs = zeros(5,2);


% Check user defined inputs
PARAM = varargin;
for n=1:2:length(PARAM);
	switch PARAM{n}
	case 'Vinf'
		setInputs(1,1) = PARAM{n+1};
		setInputs(1,2) = 1;
	case 'rho'
		if ~isempty(PARAM{n+1})
			setInputs(2,1) = PARAM{n+1};
			setInputs(2,2) = 1;
		end
	case 'Mach'
		if ~isempty(PARAM{n+1})
			setInputs(3,1) = PARAM{n+1};
			setInputs(3,2) = 1;
		end
	case 'ainf'
		setInputs(4,1) = PARAM{n+1};
		setInputs(4,2) = 1;
	case 'h'
		setInputs(5,1) = PARAM{n+1};
		setInputs(5,2) = 1;
	otherwise
		error('Unrecognized option %s', PARAM{n});
	end
end


if ~isempty(refValues)
	% Partial or total use of reference values
	selectedValues = refValues;
	if ~isempty(PARAM)
		position = find(setInputs(:,2));
		if max(position) < 4
			selectedValues(position) = setInputs(position,1);
		else
			error('Please specify only Vinf, rhoinf and/or Minf');
		end
	end

	Vinf   = selectedValues(1);
	rhoinf = selectedValues(2);
	Minf   = selectedValues(3);

end


















return
