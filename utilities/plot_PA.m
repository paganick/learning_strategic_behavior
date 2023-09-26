function plot_PA(output_matrix)
% plot_PA: plots and save the output of the preferential attachment test

[n_rows, n_columns, ~] = size(output_matrix);

colormap = color_map();

im = zeros(n_rows,n_columns,3);
for row=1:n_rows
    for col=1:n_columns
        x = output_matrix(row, col, 1);
        y = output_matrix(row, col, 2); 
        im(row,col,:) = get_color(x,y, colormap);
    end
end
resolution_x = 500;
resolution_y = 800;
im = imresize(im, [resolution_y, resolution_x], 'nearest');
figure();
image('CData',im);
xlim([0.5, resolution_x+0.5]);
ylim([0.5, resolution_y+0.5]);

yticks([]);
xticks([]);

matlab2tikz('PA_result.tikz');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function colormap = color_map()
% colormap: creates a customized 2-D color map in order to describe each
% point in the \theta_1 - \theta_3 space with a unique color.

red_white = [1   0.5 0.6];
red    = [1 0 0];
blue   = [0 0 1];
blue_white = [0.6 0.5 1];

TL = red_white;
TR = red;
BL = blue;
BR = blue_white;
colormap.xLim = [0 2];
colormap.yLim = [-2 2];
colormap.n = 100;

colormap.map = zeros(colormap.n,colormap.n,3);
% i=1, j=1:  BL
% i=1, j=n:  BR
% i=n, j=n:  TR
% i=n, j=1:  TL
for i=1:colormap.n
    for j=1:colormap.n
        colormap.map(i,j,:) = ((i-1)*(j-1)*TR + (i-1)*(colormap.n-j)*TL + ...
        (colormap.n -i)*(colormap.n -j)*BL + (colormap.n-i)*(j-1)*BR)/(colormap.n-1)^2;
    end
end

image('XData', linspace(colormap.xLim(1), colormap.xLim(2), colormap.n), ...
                    'YData', linspace(colormap.yLim(1), colormap.yLim(2), colormap.n), ...
                    'CData', colormap.map);
xlabel('$\theta_1$');
ylabel('$\theta_3$');
xlim(colormap.xLim);
ylim(colormap.yLim);
yticks([-2 0 2]);
xticks([0 0.5 1 1.5 2]);

matlab2tikz('PA_colormap.tikz');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function color = get_color(x, y, colormap)
% Returns the color of the colormap in the coordinates specified by x and
% y (pixel).
pixel = [ 1 + floor((x-colormap.xLim(1))/(colormap.xLim(2)-colormap.xLim(1))*(colormap.n -1)), ...
          1 + floor((y-colormap.yLim(1))/(colormap.yLim(2)-colormap.yLim(1))*(colormap.n -1))];

color = colormap.map(pixel(2),pixel(1),:);
end
