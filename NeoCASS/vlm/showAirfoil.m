function showAirfoil(fileName)


data = load(fileName, '-ascii');

nUpper = data(1,1);
nLower = data(1,2);

upperData = data(1 + (1:nUpper), :);
lowerData = data(1 + nUpper + (1:nLower), :);

figure; hold on
plot(upperData(:,1), upperData(:,2), 'k', 'linewidth', 2);
plot(lowerData(:,1), lowerData(:,2), 'k', 'linewidth', 2);

axis equal;


return
