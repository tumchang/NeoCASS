function D = standard(A)

[val idx] = max (A);
g = size(A);
if idx(1)== g (1)
    idx(1) = 1;
end
f = A(idx(1),3)-A(idx(1)+1,3);

if idx(1) == 1 && f<0   %right point, right direction
 
    B = A;
end

if idx(1) == 1 && f>0   %right point, wrong direction
    for i=1 : 1 : g(1)
    
        B(i,:) = A(g(1)-i+1,:);
    
    end
    
end

if idx(1) ~= 1 && f>0  %wrong point, wrong direction

    for i= idx(1) : 1 : g(1)
    
        B(i-idx(1)+1,:) = A (i,:);

    end

    for i=1 : 1 : g(1)-1
    
        B(i,1) = A(g(1)-idx(1)+i+1,:);
    
    end
    
    for i=1 : 1 : g(1)
    
        B(i,:) = A(g(1)-i+1,:);
    
    end

end

if idx(1) ~= 1 && f<0  %wrong point, right direction

    for i= idx(1) : 1 : g(1);
    
        B(i-idx(1)+1,:) = A (i,:);

    end

    for i=1 : 1 : g(1)-1
    
        B(i,1) = A(g(1)-idx(1)+i+1);
    
    end

end

D=B;
end


