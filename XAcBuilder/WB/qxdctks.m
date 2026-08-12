function ckspd = qxdctks(spd, alt, disa)
%--------------------------------------------------------------------------
% Conversion from CAS to TAS for given ISA deviation and altitude
%

ckspd = 1479.1 * (qxdthet(alt,disa) * ((((1/(qxdsigm(alt,disa)*qxdthet(alt,disa))*(((1+...
    ((spd/661.4786)^2)*0.2)^3.5)-1)+1)^(1/3.5))-1)))^0.5;
