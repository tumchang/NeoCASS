function sigma = qxdsigm(alt, disa)
%--------------------------------------------------------------------------
% Computes the density lapse ratio for given ISA deviation and flight level
%

if alt < 0.0001
    alt = 0.0001; % change zero to something small
end
% density lapse ratio at ISA
isigm = (qxdthet(alt,0)^4.2561)+qxheavy(alt,361,0)*(2.583-0.4398*(log(alt)));
sigma = qxdthet(alt,0)*isigm/qxdthet(alt,disa);% density lapse ratio at dISA