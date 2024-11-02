%%
clear;
clc;

% ------------ Settings ------------

% save path
PATH = 'img/';

% number of fractals
N_FRACTALS = 5;

% Save imgages?
SAVE = true;

% parameters
RAND_SEED = 0;
RAND_RANGE_RECURSION = [3 6];
RAND_RANGE_GA = 0.5;
N_BASE_SHAPES = 2;
N_SHAPES = 4;
SIZE = 419;
BORDER_SIZE = 0.2;

% ---------------------------------


% start shapes
% rect
x_r = [-1 -1 1 1] / sqrt(2);
y_r = [-1 1 1 -1] / sqrt(2);
%triangle
x_t = [0, -sqrt(3)/2, sqrt(3)/2];
y_t = [1, -1/2, -1/2];
% pentagon
x_p = [0, 0.951, 0.588, -0.588, -0.951];
y_p = [1, 0.309, -0.809, -0.809, 0.309];

% set shapes
X = {x_r; x_p};
Y = {y_r; y_p};
% set random seed
rng(RAND_SEED);

%%
% generate and save fractals
for i = 1:N_FRACTALS
        fig = generate_fractal(X, Y, N_BASE_SHAPES, N_SHAPES, RAND_RANGE_RECURSION, RAND_RANGE_GA, BORDER_SIZE);
        if SAVE
            filepath = strcat(PATH, 'fractal_', num2str(i, '%03.f'), '.bmp');
            F = getframe(gca);
            img = frame2im(F);
            img = imresize(img, [SIZE, SIZE]);
            [img, cmap] = rgb2ind(img, 256);

            imwrite(img, cmap, filepath);
            close(fig);
        else
            pause(1);
            if(i == N_FRACTALS)
                close all;
            end
        end
end
%% Functions

function fig = generate_fractal(x_all, y_all,n_baseShapes, n_shapes, range_rec, range_ga, border_size)
    fig = figure;

    x_min = inf;
    x_max = -inf;
    y_min = inf;
    y_max = -inf;

    for i = 1:n_shapes
    
        % get x, y of random shape 
        shape = randi(n_baseShapes);
        x = cell2mat(x_all(shape));
        y = cell2mat(y_all(shape));
    
        % assign random size (size is decreasing)
        % max size: 2
        % min size: 1
        shape_size = (n_shapes - i) * 1/3 + 1;
        x = x * shape_size;
        y = y * shape_size;
        
        n_recursion = randi(range_rec);
    
        for j = 1:n_recursion
            [x,y] = deflect(x,y, range_ga);
        end
        
        [x_min, x_max] = get_min_max(x, x_min, x_max);
        [y_min, y_max] = get_min_max(y, y_min, y_max);

        % style polygon
        color = get_rand_color();
        pgon = polyshape(x,y, Simplify=false);
        pg = plot(pgon);
        hold on;
        pg.FaceColor = color;
        pg.EdgeColor = color;
        pg.FaceAlpha = 1;
    end
    
    % style figure
    ax = gca;

    fig.Color = 'k';
    
    border_min = min(x_min, y_min);
    border_max = max(x_max, y_max);
    xlim([(border_min - border_size) (border_max + border_size)]);
    ylim([(border_min - border_size) (border_max + border_size)]);
    fig.InvertHardcopy = 'off';
    axis off;
    hold off;
    
    % not needed for saving, but shows them rectangular
    axis(ax,'square');

    % set ax over the whole figure
    set(ax, 'InnerPosition', [0 0 1 1]);
end


function [x_frac,y_frac] = deflect(x,y, ga_range)
    
    n_points = size(x,2);

    % output arrays
    x_frac = zeros(1, n_points * 2);
    y_frac = zeros(1, n_points * 2);

    % get GA in range [-ga_range ga_range]
    GA = (rand() - 0.5) * ga_range * 2;

    for i = 1:2*n_points
        if(mod(i,2) == 0)
            j1 = i/2;
            j2 = mod(j1, n_points) + 1;

            mx = (x(j1) + x(j2))/2;
            my = (y(j1) + y(j2))/2;
            dx = x(j2) - x(j1);
            dy = y(j2) - y(j1);

            % get counter clockwise vector
            norm = sqrt(dx^2 + dy^2);
            vec_x = -dy / norm;
            vec_y = dx / norm;
            
            x_frac(i) = mx + GA * vec_x;
            y_frac(i) = my + GA * vec_y;

        else
            j = ceil(i/2);
            x_frac(i) = x(j);
            y_frac(i) = y(j);
        end
    end
end


function color = get_rand_color()
    r = randi(4) / 4;
    g = randi(4) / 4;
    b = randi(4) / 4;
    
    color=[r g b];
end


function [out_min, out_max] = get_min_max(e, in_min, in_max)
    e_min = min(e);
    e_max = max(e);

    % update min
    if e_min < in_min
        out_min = e_min;
    else
        out_min = in_min;
    end

    %update max
    if e_max > in_max
        out_max = e_max;
    else
        out_max = in_max;
    end
 
end


function [x_frac,y_frac] = deflect_trigo(x,y, ga_range)
    n_points = size(x,2);

    % output arrays
    x_frac = zeros(1, n_points * 2);
    y_frac = zeros(1, n_points * 2);

    % get GA in range [-ga_range ga_range]
    GA_value = (rand() - 0.5) * ga_range * 2;

    for i = 1:2*n_points
        if(mod(i,2) == 0)
            j1 = i/2;
            j2 = mod(j1, n_points) + 1;

            mx = (x(j1) + x(j2))/2;
            my = (y(j1) + y(j2))/2;
            dx = x(j2) - x(j1);
            dy = y(j2) - y(j1);
            theta = atan(dy/dx);

            if(dx >= 0 && dy >= 0)
                GA = - GA_value;
            elseif (dx >= 0 && dy < 0)
                GA = - GA_value;
            else 
                GA = GA_value;
            end

            x_frac(i) = mx + GA * sin(theta);
            y_frac(i) = my - GA * cos(theta);
        else
            j = ceil(i/2);
            x_frac(i) = x(j);
            y_frac(i) = y(j);
        end
    end

end
