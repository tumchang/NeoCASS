function [T, Y, Xf] = ssTimeSimulation(A, B, C, D, forcfun, x0, Tinit, Tfin, Dt, method, meth_opt)
%
% Integration of a system of linear equations
%
% forcfun may be either a function or an array [mu x nT]
%
% if C = [] then it is assumed C = eye(n,n), D = zeros(n,m);
%
%-------------------------------------------------------------------------------
% 10-10-2013 v1.0
% 09-09-2015 v2.0
% 23-02-2016
%

n = size(A,1);
m = size(B,2);

if isempty(C)
	C = eye(n,n);
	D = zeros(n,m);
end

l = size(C,1);

if isempty(D)
	D = zeros(l,m);
end

if isempty(x0)
	x0 = zeros(n,1);
end

% Constant time step
T = Tinit:Dt:Tfin;
nT = length(T);

if isempty(forcfun)
	forcfun = zeros(m,nT);
end

if isstruct(forcfun)

	tmin = min(forcfun.time);
	tmax = max(forcfun.time);
	sel_t = (tmin<=T) & (T<=tmax);

	table = zeros(nT,forcfun.signals.dimensions);
	table(sel_t,:) = interp1(forcfun.time, forcfun.signals.values, T(sel_t));

	u_fun = @(k) table(k,:)';

elseif size(forcfun,2) == nT && ~strcmp(class(forcfun), 'function_handle') %floor((Tfin-Tinit)/Dt)+1
	u_fun = @(k) forcfun(:,k);
elseif size(forcfun,1) == m && size(forcfun,2)==1 && ~strcmp(class(forcfun), 'function_handle')
	u_fun = @(k) forcfun;
else
	u_fun = @(k) forcfun(T(k));
end


u0 = u_fun(1);


Y = zeros(nT, l);
Y(1,:) = (C*x0 + D*u0)';



switch method

case 'CN'

	Mat1 = eye(n,n) - Dt/2*A;
	Mat2 = eye(n,n) + Dt/2*A;
	vec1 = Dt/2*B;

	[L, U] = lu(Mat1);

	for i = 2:nT

		% u0 = u[n-1]
		% u1 = u[n]
		% x0 = x[n-1]
		% x1 = x[n]
		% y(i) = y[n]

		u1 = u_fun(i);

		% Forward
		x = L\(Mat2*x0 + vec1*(u1 + u0));

		% Backward
		x1 = U\x;

		Y(i,:) = (C*x1 + D*u1)';

		u0 = u1;
		x0 = x1;

	end

case 'EI'
	
	Mat1 = eye(n,n) - Dt*A;
	Mat2 = eye(n,n);
	vec1 = Dt*B;

	[L, U] = lu(Mat1);

	for i = 2:nT

		u1 = u_fun(i);

		% Forward
		x = L\(Mat2*x0 + vec1*u1);

		% Backward
		x1 = U\x;

		Y(i,:) = (C*x1 + D*u1)';

		x0 = x1;

	end

case 'EE'

	Mat1 = eye(n,n) + Dt*A;
	vec1 = Dt*B;

	for i = 2:nT
		u1 = u_fun(i);

		x1 = Mat1*x0 + vec1*u0;

		Y(i,:) = (C*x1 + D*u1)';

		u0 = u1;
		x0 = x1;
	end

case 'DIA'

	rho = meth_opt.rho;

	alpha = 1;
	beta = alpha*((2+alpha)*(1-rho)^2 + 2*(1+alpha)*(2*rho-1))/(2*(1+alpha) - (1-rho)^2);
	delta = alpha^2*(1-rho)^2/(2*(2*(1+alpha)-(1-rho)^2));

	a0  = 1 - beta;
	am1 = beta;
	b1  = Dt * (delta/alpha + alpha/2);
	b0  = Dt * (beta/2 + alpha/2 - (1+alpha)*delta/alpha);
	bm1 = Dt * (beta/2 + delta);

	M1 = eye(n,n) - b1*A;
	M0 = a0*eye(n,n) + b0*A;
	Mm1 = am1*eye(n,n) + bm1*A;

	P1 = b1*B;
	P0 = b0*B;
	Pm1 = bm1*B;

	N1 = eye(n,n) - Dt/2*A;
	N0 = eye(n,n) + Dt/2*A;

	Q = Dt/2*B;


	[L, U] = lu(M1);

	u1 = u_fun(2);

	% Computation of Y(2,:)
	if meth_opt.rec
		% First step: recursive computation of Y(2,:)
		res = 1;
		iter = 0;
		tol = 1e-4;
		nmax = 10;

		x1 = x0;

		b = N0*x0 + Q*(u1 + u0);

		res = norm(N1*x1 - b);

		while res>tol && iter<nmax
			iter = iter + 1;

			x = L\((M1-N1)*x1 + b);
			x1 = U\x;

			res = norm(N1*x1 - b);

		end

		if iter == nmax
			fprintf(' *** Warning: maximum number of iterations reached, res = %1.3e\n',res)
		end

	else
		x1 = N1\(N0*x0 + Q*(u1 + u0));
	end


	Y(2,:) = (C*x1 + D*u1)';

	um1 = u0;
	u0 = u1;

	xm1 = x0;
	x0 = x1;

	for i = 3:nT

		u1 = u_fun(i);

		% Forward
		x = L\(M0*x0 + Mm1*xm1 + P1*u1 + P0*u0 + Pm1*um1);

		% Backward
		x1 = U\x;

		um1 = u0;
		u0 = u1;

		xm1 = x0;
		x0 = x1;

		Y(i,:) = (C*x1 + D*u1)';

	end

case 'HEUN'
	
	Mat1 = eye(n,n) + Dt*A;
	Mat2 = Dt/2*A;
	vec1 = Dt/2*B;

	for i = 2:nT
		u1 = u_fun(i);

		x = Mat1*x0 + vec1*u0;

		x1 = x0 + Mat2*(x0 + x) + vec1*(u1 + u0);

		Y(i,:) = (C*x1 + D*u1)';

		u0 = u1;
		x0 = x1;
	end

case 'AB'

	order = meth_opt.order;

	switch order
	case 1
		m = 1;
		b_array = 1;
	case 2
		m = 2;
		b_array = [3, -1]/2;
	case 3
		m = 3;
		b_array = [23, -16, 5]/12;
	case 4
		m = 4;
		b_array = [55, -59, 37, -9]/24;
	end

	% Computes starting point using Heun scheme

	Fold = zeros(n,m);
	Fold(:,m) = A*x0 + B*u0;

	Mat1 = eye(n,n) + Dt*A;
	Mat2 = Dt/2*A;
	vec1 = Dt/2*B;

	for i = 2:m
		u1 = u_fun(i);

		x = Mat1*x0 + vec1*u0;
		x1 = x0 + Mat2*(x0 + x) + vec1*(u1 + u0);

		Fold(:,m-i+1) = A*x1 + B*u1;
		Y(i,:) = (C*x1 + D*u1)';

		u0 = u1;
		x0 = x1;
	end


	% Actual integration with the multistep method
	reorder = 1:m;

	for i = m+1 : nT

		x1 = x0 + Dt* Fold * b_array(reorder)';

		u1 = u_fun(i);

		% The following lines are equivalent to
		Fold = [A*x1+B*u1, Fold(:,1:m-1)];
		%pos = m - mod(i-1,m);
		%Fold(:,pos) = A*x1 + B*u1;
		%reorder = [reorder(2:m), reorder(1)];

		Y(i,:) = (C*x1 + D*u1)';
		x0 = x1;
	end

case 'AM'

	order = meth_opt.order;

	switch order
	case 1
		m = 1;
		bnp1 = 0.5;
		b_array = 0.5;
	case 2
		m = 2;
		bnp1 = 5/12;
		b_array = [8, -1]/12;
	case 3
		m = 3;
		bnp1 = 9/24;
		b_array = [19, -5, 1]/24;
	case 4
		m = 4;
		bnp1 = 251/720;
		b_array = [646, -264, 106, -19]/720;
	end

	% Computes starting point using Crank-Nicolson scheme

	Fold = zeros(n,m);
	Fold(:,m) = A*x0 + B*u0;

	Mat1 = eye(n,n) - Dt/2*A;
	Mat2 = eye(n,n) + Dt/2*A;
	vec1 = Dt/2*B;

	[L, U] = lu(Mat1);

	for i = 2:m

		u1 = u_fun(i);

		% Forward
		x = L\(Mat2*x0 + vec1*(u1 + u0));

		% Backward
		x1 = U\x;

		Fold(:,m-i+1) = A*x1 + B*u1;
		Y(i,:) = (C*x1 + D*u1)';

		u0 = u1;
		x0 = x1;

	end


	% Actual integration with the multistep method
	reorder = 1:m;

	[L, U] = lu(eye(n,n) - Dt*A*bnp1);

	for i = m+1 : nT

		u1 = u_fun(i);
		x = L\(x0 + Dt* Fold * b_array(reorder)' + Dt*bnp1*B*u1);
		x1 = U\x;


		% The following lines are equivalent to
		% Fold = [A*x1+B*u1, Fold(:,1:m-1)];
		pos = m - mod(i-1,m);
		Fold(:,pos) = A*x1 + B*u1;
		reorder = [reorder(2:m), reorder(1)];

		Y(i,:) = (C*x1 + D*u1)';
		x0 = x1;
	end

end



Xf = x1;



return
