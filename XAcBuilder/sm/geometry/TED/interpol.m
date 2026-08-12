function x = interpol (x_0, x_1, s, y_0, y_1)
%linear interpolation between two points

%get slope
delta_x = x_1 - x_0;

if delta_x ~= 0
m = (y_1-y_0)/(x_1-x_0);

b = y_0 - x_0 * m;

x = m*s + b;
end

if delta_x == 0
    x = x_1;
end

end