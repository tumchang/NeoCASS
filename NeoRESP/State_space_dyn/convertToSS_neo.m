function [ssmodel] = convertToSS_neo(inputSyst)
%
%
% Converts a system in the state-space class
%
%
%
%
%-------------------------------------------------------------------------------
% 24-06-2016
%


recognizedFields = {
                    'StateName'; 'stname';
                    'Scaled';
                    'tsam'; 'Ts';
                    'InputName'; 'inname';
                    'OutputName'; 'outname';
                    'InputGroup'; 'ingroup';
                    'OutputGroup'; 'outgroup';
                    'InputDelay';
                    'OutputDelay';
                    'Name';
                    'Notes';
                    'UserData';
                   };
recognizedFields = lower(recognizedFields);


inputFields = fieldnames(inputSyst);

if strcmp(inputFields, 'Bu')
	formatType = '1';
else
	formatType = '2';
end

% Initialize structure with matrix data
switch formatType
case '1'
	error('conversion from format 1 not implemented');
case '2'
	ssmodel = ss(inputSyst.A, inputSyst.B, inputSyst.C, inputSyst.D);
end


for iField = 1:length(inputFields)
	fieldName = inputFields{iField};
	if find(strcmp(lower(recognizedFields), lower(fieldName)))
		set(ssmodel, lower(fieldName), getfield(inputSyst, fieldName));
	end
end


return
