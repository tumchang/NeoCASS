function [freq, damp] = complexEig2FreqDamp(V, eigmat, l_a)
%
% [freq, damp] = compl2freqdamp(V, eigmat, l_a)
%
% Compute frequency and damping from complex eigenvalues in eigmat, evaluatet
% at speed in V
%
% eigmat(length(v), n_entries)
%
%-------------------------------------------------------------------------------
% 24-08-13
%

if size(V,1) < size(V,2)
    V = V';
end

% Number of entries
n = size(eigmat,2);


IM = imag(eigmat);
RM = real(eigmat);

% Frequency
omega = IM;
freq = abs(omega/2/pi);

% Damping (g)
damp = 2*RM./(omega + (IM == 0)).*(IM ~= 0);

% For real roots damping is expressed as the decay rate coefficient
damp = damp + RM.*(IM == 0)*l_a./(log(2)*V*ones(1,n));




return
