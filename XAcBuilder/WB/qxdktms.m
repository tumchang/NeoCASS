function kmspd = qxdktms(spd, alt, disa)

	kmspd = spd * 0.5144/(340.3*qxdthet(alt,disa)^0.5);

return