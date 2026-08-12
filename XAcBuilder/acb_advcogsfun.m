% ********* New functions for AcBuilder CoGs Module *************
function acb_advcogsfun(nomecomando)

switch nomecomando
   case 'setWPpath'
      cd(strrep(which('acb_weight.m'),'acb_weight.m', ''));
    case 'setNodePath'
      %cd(strrep(which('acb_close.m'),'acb_close.m', 'AcNodes'));
      %disp('bu')
    case 'setRBE2Path'
      cd(strrep(which('acb_close.m'),'acb_close.m', ''));
   otherwise
      disp('Unknown command! Check Java code!')
end

end