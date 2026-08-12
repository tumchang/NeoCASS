function [str]=num2strE(var)
str=sprintf('%8.3e',var);  
str = strrep(str,'e+00','+'); str = strrep(str,'e+0','+'); 
str = strrep(str,'e-00','-'); str = strrep(str,'e-0','-');