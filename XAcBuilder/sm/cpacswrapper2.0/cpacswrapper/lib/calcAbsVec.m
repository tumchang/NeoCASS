function [posStruct,absVec] = calcAbsVec(posStruct,posNum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  calcAbsVec                                                             %
%  Calculate the absolut positioning vecors.                              %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-07-26 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear a Check Value
    for i=1:size(posStruct,1)
        posStruct{i,5}=[];
    end

%% Call Subfunction
    [posStruct]=sumUpPos(posStruct,posNum);

%% Select all relative vectos (wich are conected
    absVec=[];
    for i=1:size(posStruct,1)
        if posStruct{i,5}==1
            absVec(i,:)=posStruct{i,3};
        end
    end

%% Write Absolute Vector (by Sum up all positioning vectors before)
    posStruct{posNum,4}=sum(absVec,1)+posStruct{posNum,3};

%% Clear a Check Value
    for i=1:size(posStruct,1)
        posStruct{i,5}=[];
    end

end%mainFunction
%% SubFunction
%% sumUpPos !Rekursion!
function [posStruct]=sumUpPos(posStruct,posNum)

    SecUID=posStruct{posNum,1};
    if ~isempty(SecUID)
        for i=1:size(posStruct,1)
            if strcmp(SecUID,posStruct{i,2})      
                % Set a Check Value
                posStruct{i,5}=1;
                if ~isempty(posStruct{i,1})
                    posNum=i;
                    % !Rekursion!
                    [posStruct]=sumUpPos(posStruct,posNum);
                end
            end
        end
    end
    
end%subFunction