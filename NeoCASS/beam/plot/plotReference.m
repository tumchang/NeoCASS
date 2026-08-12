function hPlot = plotReference(X0array, Rarray, scale, label)
%
% hPlot = plotReference(X0array, Rarray, scale, label)
%
%
%
%-------------------------------------------------------------------------------
% 09-06-2014
%

nCoord = size(Rarray,3);

[nr,nc] = size(X0array);
if nr==nCoord && nc==3
	X0array = X0array';
elseif nr==3 && nc==nCoord
	% Do nothing!
else
	error('Dimension on X0 and R not consistent!\n')
end

useLabel = false;
if nargin==4
	if length(label)~=nCoord
		error('Wrong number of elements in label\n')
	end
	useLabel = true;
end

dx = 0.1*scale;
dy = 0.1*scale;
dz = 0.1*scale;

for iCoord = 1:nCoord

		X0 = X0array(:,iCoord);
		R = scale*Rarray(:,:,iCoord);

		h1 = quiver3(X0(1), X0(2), X0(3), R(1,1), R(2,1), R(3,1), 0, 'b');
		h2 = quiver3(X0(1), X0(2), X0(3), R(1,2), R(2,2), R(3,2), 0, 'g');
		h3 = quiver3(X0(1), X0(2), X0(3), R(1,3), R(2,3), R(3,3), 0, 'r');

		linewidth = 2;
		set(h1, 'linewidth', linewidth);
		set(h2, 'linewidth', linewidth);
		set(h3, 'linewidth', linewidth);

		if useLabel
			h_text = text(X0(1), X0(2), X0(3), label{iCoord});
			set(h_text, 'VerticalAlignment', 'top');
			set(h_text, 'fontsize', 18);
			set(h_text, 'fontweight', 'bold');
		end

		ht(1) = text(X0(1)+R(1,1) + dx, X0(2)+R(2,1) + dy, X0(3)+R(3,1) + dz, 'x');
		ht(2) = text(X0(1)+R(1,2) + dx, X0(2)+R(2,2) + dy, X0(3)+R(3,2) + dz, 'y');
		ht(3) = text(X0(1)+R(1,3) + dx, X0(2)+R(2,3) + dy, X0(3)+R(3,3) + dz, 'z');

		for ii=1:3
			set(ht(ii), 'fontsize', 15);
			set(ht(ii), 'fontweight', 'demi');
		end
end




return
