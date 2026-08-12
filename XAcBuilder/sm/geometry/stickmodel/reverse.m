function [vect_reverse]=reverse(vect)
%La funzione legge un vettore e lo inverte
vtemp=vect; 
for i=1:length(vect)
    vect_reverse(i)=vtemp(end-i+1);
end