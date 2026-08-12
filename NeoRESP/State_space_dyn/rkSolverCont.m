function X = rkSolverCont(odefun, NRfun, Vvect, X0)
%
% X = rkvinCont(odefun, NRfun, Vvect, X0)
%
% Runge-Kutta method for the solution of ODE problems with the inclusion of a
% constraint. The constraint is enforced only at outer steps.
%
%-------------------------------------------------------------------------------
% Modificato 16-12-2012
% Modificato 16-09-13
%

% Parametri del metodo (Metodo di Merson) ---------------------------------
s = 5;
C = [0; 1/3; 1/3; .5; 1];
A = [ 0   0    0 0 0;
    1/3   0    0 0 0;
    1/6 1/6    0 0 0;
    1/8   0  3/8 0 0;
    1/2   0 -3/2 2 0];
B = [1/6; 0; 0; 2/3; 1/6];
%--------------------------------------------------------------------------


nX = length(X0);
nV = length(Vvect);

X = zeros(nX,nV);

% Correction of initial state
X(:,1) = correction(NRfun, Vvect(1), X0);


for i = 2:nV

	h = Vvect(i) - Vvect(i-1);
	
	K = zeros(nX,s);
	
	for j = 1:s
		K(:,j) = odefun(Vvect(i-1) + C(j)*h, X(:,i-1) + h*K*(A(j,:))');
	end
	
	% Update
	X(:,i) = X(:,i-1) + h*K*B;
	
	% Correction
	X(:,i) = correction(NRfun, Vvect(i), X(:,i));
	
	
end 

return
%===============================================================================


%===============================================================================
function Xcorr = correction(NRfun, v, X)
   %
   %
   %-------------------------------------------------------------------------------
   % 16-09-13
   %

   [Res, Jac] = NRfun(v, X);

   err = Res'*Res;

   tol = 1e-4;
   nmax = 10;
   iter = 0;

   while err>tol && iter < nmax
      
      % Update solution
      X = X - Jac\Res;
      
      % Update residual
      [Res, Jac] = NRfun(v, X);
      
      err = Res'*Res;
      
      iter = iter+1;
      
   end

   Xcorr = X;

return
%===============================================================================
