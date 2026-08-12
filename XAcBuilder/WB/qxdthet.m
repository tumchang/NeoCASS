function temper = qxdthet(alt, disa)
%--------------------------------------------------------------------------
% Computes the temperature lapse ratio for given ISA deviation and flight level
%

if alt<0.0001
    
    alt = 0.0001;% change zero to something small
    
end

temper = 1+(1454*qxheavy(alt,361,0)*(0.00069*alt-0.248)+5.046*disa-alt)/1454;