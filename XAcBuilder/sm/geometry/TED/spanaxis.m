function axis = spanaxis(component)  % component -- wing structure

%calculate sum of x-rotation
x_wing =  str2num(component.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT);
x_section =  str2num(component.sections{1,1}.section{1,2}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT);
x_element =  str2num(component.sections{1,1}.section{1,2}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.x{1,1}.CONTENT);

sum_x = x_wing + x_section + x_element;


%calculate sum of z-rotation
z_wing = str2num(component.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT);
z_section = str2num(component.sections{1,1}.section{1,2}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT);
z_element = str2num(component.sections{1,1}.section{1,2}.elements{1,1}.element{1,1}.transformation{1,1}.rotation{1,1}.z{1,1}.CONTENT);

sum_z = z_wing + z_section + z_element;


if sum_x >= 45
    
    axis = 3;
    
elseif sum_z >= 45
    
    axis = 1;
    
else
    
    axis = 2;
    
end

end