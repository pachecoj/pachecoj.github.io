function [ pts h ] = getpoints(img)
%#ok<*NASGU>
%#ok<*AGROW>

disp('Left mouse button picks points.')
disp('Right mouse button ends')

[pts h ] = markpts(img);


end

function [pts h] = markpts(img)
 
img = im2double(img);

h = figure;
image(img);
hold on


% Initially, the list of points is empty.
xy = [];
n = 0;
% Loop, picking up the points.
but = 1;
while but == 1
    [xi,yi,but] = ginput(1);
    if (but == 1)
        n = n+1;
        xi = round(xi);
        yi = round(yi);
        pts(n,:) = [xi,yi]; 
        text(xi, yi, sprintf('%d',size(pts,1)), ...
                'FontSize',20,'Color','r',      ...
                'HorizontalAlignment','center'  ...
            );
    end
end

hold off
drawnow

end