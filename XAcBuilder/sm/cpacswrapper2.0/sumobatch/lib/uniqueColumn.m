function [outVec]=uniqueColumn(inVec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   uniqueColumn                                                          %
%                                                                         %
%   Delete all lines wich are equal                                       %   
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Author:           Till Pfeiffer                                         %
% Version:          1.0                                                   %
% LastModified:     2011-08-03 18:00                                      %
% LastModifiedBy:   TP                                                    %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Unique points
count=0;
outVec=[];
for i=1:size(inVec,1)-1
    findequNum=[];
    for ii=1:size(inVec,2)
        findequNum(1,ii)=inVec(i,ii)==inVec(i+1,ii);
    end

    if ~isempty(find(findequNum==0))
        count=count+1;
        outVec(count,:)=inVec(i,:);
    end 
end
count=count+1;
outVec(count,:)=inVec(i+1,:);
