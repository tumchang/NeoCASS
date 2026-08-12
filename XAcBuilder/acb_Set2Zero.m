function acb_Set2Zero(componente)
global ac;
campo_ac = componente;
ac.(campo_ac).area = 0;
disp(sprintf('%s Area set to 0', componente));
%disp('%s Area set to 0',componente)
end