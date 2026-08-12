function node = subdLine(A,B,N,int)

if isempty(int)
    if N <= 2
        node = [A B];
        return
    end
    ds = 1/(N-1);
    X = interp1([0 1],[A(1) B(1)],(0:N-1)*ds);
    Y = interp1([0 1],[A(2) B(2)],(0:N-1)*ds);
    Z = interp1([0 1],[A(3) B(3)],(0:N-1)*ds);
    node = [X;Y;Z];
else
    % if there are intermediate points, make sure they are ordered
    if size(int,2)>1
        dist = zeros(1,size(int,2));
        for i=1:size(int,2)
            dist(i) = norm(A-int(i));
        end
        [~,idx] = sort(dist);
        int = int(:,idx);
    end
    
    %if the total number of nodes is less than or equal to the specified points, node are those specified points
    node = [A int B];
    
    %compute number of unassigned nodes
    n = N-size(node,2);
    
    if n < 1
        return
    end
    
    dist = zeros(1,size(node,2));
    for i = 1:size(node,2)
        dist(i) = norm(node(:,1)-node(:,i));
    end
    L = dist(2:end) - dist(1:end-1);
    parts = ones(1,length(L));
    
    while n > 0
        n = n-1;
        [~,idx] = max((L./parts)/sum(L));
        parts(idx(1)) = parts(idx) + 1;
    end
    
    % recursively apply the same function without intermediate points
    newNodes = zeros(3,N);
    id = 1;
    for i = 1:length(parts)
        out = subdLine(node(:,i),node(:,i+1),parts(i)+1,[]);
        newNodes(:,id:id+parts(i)-1) = out(:,1:end-1);
        id = id + parts(i);
    end
    newNodes(:,end) = B;
    node = newNodes;
end

