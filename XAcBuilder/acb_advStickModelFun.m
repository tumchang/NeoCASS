% ********* New functions for AcBuilder  *************
function acb_advStickModelFun(nomecomando)

switch nomecomando
   case 'setSMpath'
       % Set Dir for stick model data
      cd(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''));
    case 'addSMpath'
        % Add Dir for stick model data if Dir doesn't exist
      addpath(strcat(strrep(which('acb_advStickModelFun.m'),'acb_advStickModelFun.m', ''),'AcBSMDir'));
   otherwise
      disp('Unknown command! Check Java code!')
end

end