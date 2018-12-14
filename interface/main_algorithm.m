% Static variables for depth

t1 = datetime('now','Format','HH:mm:ss');
time = string(t1);

h = 900;
min_y = 120;
max_y = 480;
min_x = 50;
max_x = 340;

% Threshold values
min_thresh = 30;
max_thresh = 500;

% Static variables for color
THRESHOLD_VALUE = 2;

MIN_ROW_LINES_BETWEEN_GROUPS = 10; %25 %15
% Once the groups are found, the algorithm searches for groups too close
% near each other
% This is defined as the min distance between two groups (only searched
% vertical)
SAME_PIXELS_SEARCH_GRID_SIZE = 10;%25
% Grid size = this variable *2, it searches for pixels with the same value
% in this grid.
GROUP_SEARCH_GRID_SIZE = 15; %25
% Grid size = this variable * 2, it searches for pixels with a group number
% (not 0) in this grid.
SURROUDING_PERCENTAGE = 10;% 
MIN_NB_SURROUNDING_PIXELS = floor((SAME_PIXELS_SEARCH_GRID_SIZE * 2)^2 * SURROUDING_PERCENTAGE/100) ;%125 % 50
% The minimum number of pixels with the same value that are in the grid
% size defined by SAME_PIXELS_SEARCH_GRID
% The pixels that have a less number of surrounding pixels, are not defined
% as a group but as noise.

tic
% Get image from depth sensor
colorVid = videoinput('kinect',1);
depthVid = videoinput('kinect',2);
depth = getsnapshot(depthVid);
color = getsnapshot(colorVid);

% Get data from file
% color = imread('color 15.000000 .png');
% load('depth 15.000000 .mat');

%Run the sobel operator
depth_after_sobel = sobel_operator(depth);

%Run the threshold filter
depth_after_threshold = threshold(depth_after_sobel, min_thresh, max_thresh);

% Cropping image (not reducing size but removing data outside these values)
depth_cropped = crop(depth_after_threshold, min_x, max_x, min_y, max_y);

% 
depth_after_outline = outline(depth_cropped);

%
final_img = only_outline_visible(depth_after_outline);

%
edged_matrix = only_edge(depth_after_outline);

%
new_depth = crop_depth_to_basket(edged_matrix, depth_after_sobel);

%color: 1920x1080 met 84.1 x 53.8
%depth: 512x424  met 70.6 x 60

%
[reformed_depth,reformed_color, res_height_angle, res_width_angle] = reform(depth_after_outline, color);

%
[pipemm_depth_H, pipemm_depth_W, pipemm_color_H, pipemm_color_W] = get_pipemm(res_height_angle, res_width_angle, h, reformed_depth,reformed_color);

%
[prop,nb_rows_color , nb_columns_color,nb_rows_depth, nb_columns_depth] = proportion(reformed_depth , reformed_color);

%
tot_size = size_matching(prop);

%
total = overlap_depth_to_RGB(reformed_depth, reformed_color, pipemm_depth_H , pipemm_depth_W , pipemm_color_H , pipemm_color_W,tot_size,nb_rows_color , nb_columns_color);

%
new_RGB = crop_RGB_to_basket(total);

% Color
img = new_RGB;
disp("Minimum distance between 2 objects (only straight vertical or straight horizontal = " + max([MIN_ROW_LINES_BETWEEN_GROUPS SAME_PIXELS_SEARCH_GRID_SIZE MIN_NB_SURROUNDING_PIXELS;]) + " pixels");
A = greyscale(img); % Convert image to grayscale
A = gaussian_blur(mean_blur(A)); % Filters
first_edge_detect = edge_detect(A); % Laplacian edge detection
without_noise_removal = threshold_edge(remove_boundary(first_edge_detect, 15), THRESHOLD_VALUE); % Remove boundary around image & threshold the edges.
[grouped, nb_of_groups] = group(~without_noise_removal, SAME_PIXELS_SEARCH_GRID_SIZE, GROUP_SEARCH_GRID_SIZE, MIN_NB_SURROUNDING_PIXELS); % Group pixels together
[regrouped, nb_of_groups2] = regroup(grouped, nb_of_groups, MIN_ROW_LINES_BETWEEN_GROUPS); % Regroup (nessicary because group function works from top left to bottom right
%Find corner points of object (not really corner points on the boundary,
%but corner points for the boundary box)
corner_points = find_corner_points(regrouped, nb_of_groups); % Make sure to use nb_of_groups and not groups 2 because some groups don't exist anymore!
%[updated_corner_points, nb_of_groups3] = remove_corner_points_within_corner_points(corner_points, nb_of_groups2); % To remove objects within objects
[updated_corner_points, nb_of_groups3] = remove_box_edge(corner_points, nb_of_groups2);
[updated_corner_points, nb_of_groups3] = remove_corner_points_within_corner_points(updated_corner_points, nb_of_groups3);
red_boundary_box = draw_red_boundary_box(reformed_color, updated_corner_points, 1,1);
toc

figure;
imshow(red_boundary_box, []);
title("# objects: "+ nb_of_groups3);

%% Functions

% Depth functions
function shapes = sobel_operator(img)
    % use the sobel-operator on the raw depth image
    % this function returns a matrix of the same size as the original
    % matrix with on every position the gradiënt

    X = img;
    Gx = [1 +2 +1; 0 0 0; -1 -2 -1]; Gy = Gx';
    temp_x = conv2(X, Gx, 'same');
    temp_y = conv2(X, Gy, 'same');
    shapes = sqrt(temp_x.^2 + temp_y.^2);
end 

function thresholded = threshold(img, min_thresh, max_thresh)
    % run the image through a threshold to get rid of impossible values
    % this function returns a binary matrix with a 1 on the edges
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    for row = 1 : MAX_ROW        
        for col = 1: MAX_COLUMN
           if (img(row, col) > min_thresh) && (img(row, col)< max_thresh)
               img(row, col) = 1;
           else
               img(row, col) = 0;
           end
        end
    end
    thresholded = img;
end

function printed = crop(img, min_x, max_x, min_y, max_y)
    % this function uses a threshold to cut of part of the edges to get rid
    % of noise that appears in every image and replace them by '0'
    % it returns a binary image 
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    mat = zeros(MAX_ROW,MAX_COLUMN,1); % Everything zero
    mat(min_x:max_x, min_y:max_y, :) = img(min_x:max_x, min_y:max_y);
    printed = mat;
end

  function outlined_matrix = outline(img)
    % the main outline function, given a binary matrix, this function
    % outlines every shape defined by '1'
    % it returns a matrix with '-1' as value for the outlines
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    x = 0;
    for row = 1: MAX_ROW
        col = 1;
        while col <= MAX_COLUMN
             pixel_value = img(row, col);
            if pixel_value == 0
                col = col + 1;
            elseif pixel_value == -1 % Start of an object
                % Search column where this object ends. (= right boundary)
                col = skip(img, row, col, MAX_COLUMN);
            elseif pixel_value == 1
                x = x + 1;
                img = outline_shape(img, row, col-1, MAX_ROW, MAX_COLUMN);
                col = col - 1;
            end
        end
    end
    disp(x);
    outlined_matrix = img;
  end

  function new_col = skip(img, row, col, MAX_COLUMN)
    % this function skips the part of the row that is defined to be inside
    % a shape
    % it returns the first column number outside a shape

    good_value = 0;
    while (good_value ~= 1) && (col < MAX_COLUMN)
        col = col+ 1;
        if img(row, col) == -1
            good_value = 1;
        end
    end
    new_col = col +1;
  end

function outlined_objects = outline_shape(img, row, col, MAX_ROW, MAX_COLUMN)
    %Given a binary matrix and a position that is connected to a '1', this
    %recursive function outlines the object and returns a matrix with the
    %value '-1' surrounding the object

    img(row, col) = -1;
    matrix = surrounded_matrix(img, row, col, MAX_ROW, MAX_COLUMN);
    for i = 1:3
        for j = 1:3
            if (matrix(i, j, 1) == 0) & (connected_to_one(img, matrix(i,j,2), matrix(i,j,3), MAX_ROW, MAX_COLUMN) == 1)
                img = outline_shape(img, matrix(i,j,2), matrix(i,j,3), MAX_ROW, MAX_COLUMN);
            end
        end
    end
    outlined_objects = img; 
end


function created_matrix = surrounded_matrix(img, row, col, MAX_ROW, MAX_COLUMN)
    % given a position in a matrix, this matrix returns the value and
    % position of the 9 surrounding positions

    position = [row, col];  
    TL = top_left(position, img, MAX_ROW, MAX_COLUMN);
    T = top(position, img, MAX_ROW, MAX_COLUMN);
    TR = top_right(position, img, MAX_ROW, MAX_COLUMN);
    R = right(position, img, MAX_ROW, MAX_COLUMN);
    BR = bottom_right(position, img, MAX_ROW, MAX_COLUMN);
    B = bottom(position, img, MAX_ROW, MAX_COLUMN);
    BL = bottom_left(position, img, MAX_ROW, MAX_COLUMN);
    L = left(position, img, MAX_ROW, MAX_COLUMN);

    matrix_1 = [TL(1), T(1), TR(1); L(1), -1, R(1); BL(1), B(1), BR(1)];
    matrix_2 = [TL(2), T(2), TR(2); L(2), row, R(2); BL(2), B(2), BR(2)];
    matrix_3 = [TL(3), T(3), TR(3); L(3), col, R(3); BL(3), B(3), BR(3)];

    matrix_total = matrix_1;
    matrix_total(:,:,2) = matrix_2;
    matrix_total(:,:,3) = matrix_3;

    created_matrix = matrix_total;

end 

function is_connected_to_one = connected_to_one(img, row, col, MAX_ROW, MAX_COLUMN)
    % given a position that is equal to '0', this function checks in a
    % cross shape if a '1' is present

    position = [row, col];
    T = top(position, img, MAX_ROW, MAX_COLUMN);
    R = right(position, img, MAX_ROW, MAX_COLUMN);
    B = bottom(position, img, MAX_ROW, MAX_COLUMN);
    L = left(position, img, MAX_ROW, MAX_COLUMN);

    matrix = [0, T(1), 0; L(1), -1, R(1); 0, B(1), 0];
    is_connected  = 0;
    for i = 1:3
        for j = 1:3
            if matrix(i,j) == 1
                is_connected = 1;
            end
        end
    end
    is_connected_to_one = is_connected;


end 

function RGB_matrix = only_outline_visible(img)
    % given a matrix mith '-1' as value for the outline of the objects,
    % this function returns a RGB matrix with 255,0,0 on the edges and
    % 0,0,0 in all the other positions
    
    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    matrix_complete = zeros(MAX_ROW, MAX_COLUMN, 3); 

    for row = 1 : MAX_ROW
        for col = 1: MAX_COLUMN
            if img(row, col) == -1
                matrix_complete(row, col, 1) = 255;
            end
        end
    end

    RGB_matrix = matrix_complete;
end

function edged_matrix = only_edge(img)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    to_be_edged_matrix = zeros(MAX_ROW, MAX_COLUMN);

    for i = 1: MAX_ROW
        for j = 1 : MAX_COLUMN
            if img(i, j) == -1
                to_be_edged_matrix(i, j) = 1;
            end
        end
    end    
    edged_matrix = to_be_edged_matrix;    
end

function usefull_matrix = crop_depth_to_basket(depth_img, original_img)
    z = 15;
    matrix_size = size(depth_img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    for i = (1 + z): (MAX_ROW - z)
        for j = (1 + z) : (MAX_COLUMN - z)
            if (depth_img(i, j) == 1)
                original_img(i-z:i+z, j-z:j+z)=-2;
            end
        end
    end
    %left to right
    row = 1;
    col = 1;
    while (row <= MAX_ROW)
        if col == (MAX_COLUMN + 1)
            col = 1;
            row = row + 1;
        elseif (original_img(row, col) == -2) 
            col = 1;
            row = row + 1;
        else
            original_img(row, col) = -3;
            col = col + 1;
        end
    end
    %right to left
    row = MAX_ROW;
    col = MAX_COLUMN;
    while (row ~= 1)
        if col == 1
            col = MAX_COLUMN;
            row = row - 1;
        elseif (original_img(row, col) == -2) 
            col = MAX_COLUMN;
            row = row - 1;
        else
            original_img(row, col) = -3;
            col = col - 1;
        end
    end
    %top to bottom
    row = 1;
    col = 1;
    while (col <= MAX_COLUMN)
        if row == (MAX_ROW + 1)
            row = 1;
            col = col + 1;
        
        elseif (original_img(row, col) == -2) 
            row = 1;
            col = col + 1;
        else
            original_img(row, col) = -3;
            row = row + 1;
        end
    end 
    %bottom to top
    row = MAX_ROW;
    col = MAX_COLUMN;
    while (col ~= 1)
        if row == 1
            row = MAX_ROW;
            col = col - 1;
        elseif (original_img(row, col) == -2) 
            row = MAX_ROW;
            col = col - 1; 
        else
            original_img(row, col) = -3;
            row = row - 1;
        end
    end
    %add in the edge
    for i = 1: MAX_ROW
        for j = 1: MAX_COLUMN
            if (original_img(i, j) == -2)
                original_img(i,j)=-3;
            end
        end
    end
   usefull_matrix = original_img;
end

function [reformed_depth,reformed_color,resulting_height_angle,resulting_width_angle] = reform(depth, color) %met h= height camera
    % this function modifies the incomming color and depth matrices to give
    % them the same aspect ratio
    %breedte van color naar 70.6 brengen
    width_color_angle = 84.1;
    height_color_angle = 53.8;
    width_depth_angle = 70.6;
    height_depth_angle = 60;
    resulting_height_angle = height_color_angle;
    resulting_width_angle = width_depth_angle;    
    [~ , nb_columns_color,~]=size(color);
    nb_pixels_color_per_degree_width = nb_columns_color / width_color_angle;
    nb_width_pixels_removed_color = (width_color_angle-width_depth_angle) * nb_pixels_color_per_degree_width ;
        %totaal aantal pixels dat in de breedte weggehaald moeten worden bij color   
    reformed_color = color(:,80 + round(nb_width_pixels_removed_color/2,0): round(nb_columns_color-(nb_width_pixels_removed_color/2),0),:);
        %Dit is een 1080 x (aangepaste breedte) matrix
    % hoogte van depth naar 53.8 brenge
    [nb_rows_depth,~]=size(depth);
    nb_pixels_depth_per_degree_height = nb_rows_depth / height_color_angle;
    nb_height_pixels_removed_depth = (height_depth_angle-height_color_angle)*nb_pixels_depth_per_degree_height;
    reformed_depth = depth(round(nb_height_pixels_removed_depth/2,0): round(nb_rows_depth -(nb_height_pixels_removed_depth/2),0),:);
end   

function [pipemm_depth_H, pipemm_depth_W, pipemm_color_H, pipemm_color_W] = get_pipemm(res_height_angle, res_width_angle, h, reformed_depth,reformed_color)
    % this function returns the pixels per millimeter for the given depth
    % and color matrices
    depth_size = size(reformed_depth);
    MAX_ROW_DEPTH = depth_size(1);
    MAX_COLUMN_DEPTH = depth_size(2);
    color_size = size(reformed_color);
    MAX_ROW_COLOR = color_size(1);
    MAX_COLUMN_COLOR = color_size(2);
    tot_width = 2*h*tan(((res_width_angle)/2)*(pi/180));
    tot_height = 2*h*tan(((res_height_angle)/2)*(pi/180));
    pipemm_depth_H = MAX_ROW_DEPTH/tot_height;
    pipemm_depth_W = MAX_COLUMN_DEPTH/tot_width;
    pipemm_color_H = MAX_ROW_COLOR/tot_height;
    pipemm_color_W = MAX_COLUMN_COLOR/tot_width;
end

function [prop,nb_rows_color , nb_columns_color,nb_rows_depth, nb_columns_depth] = proportion(reformed_depth , reformed_color)
    % this function returns the size of the given color and depth matrices,
    % and the proportion between the depth and color pixels 

    [nb_rows_color , nb_columns_color,~]=size(reformed_color);
    [nb_rows_depth, nb_columns_depth]= size(reformed_depth);
    
    nb_pixels_color=nb_rows_color * nb_columns_color;
    nb_pixels_depth=nb_rows_depth * nb_columns_depth;
    
    x= max(nb_pixels_color,nb_pixels_depth);
    y= min(nb_pixels_color,nb_pixels_depth);
 
    prop = x/y;
end

function the_size=size_matching(prop)
    the_size= round(sqrt(prop));
end

function overlapped_matrix = overlap_depth_to_RGB(reformed_depth, reformed_color, pipemm_depth_H , pipemm_depth_W , pipemm_color_H , pipemm_color_W,the_size,nb_rows_color , nb_columns_color)

    depth_size = size(reformed_depth);

    MAX_ROW_DEPTH = depth_size(1);

    MAX_COLUMN_DEPTH = depth_size(2);
    
    for row = 1:MAX_ROW_DEPTH
        for col = 1:MAX_COLUMN_DEPTH
            if(reformed_depth(row, col, 1) == -1)
                [row_start, row_stop, col_start, col_stop] = depth_to_color(pipemm_depth_H , pipemm_depth_W , pipemm_color_H , pipemm_color_W,row, col,the_size,nb_rows_color , nb_columns_color);
                reformed_color(row_start:row_stop, col_start:col_stop, 1) = 255;
                reformed_color(row_start:row_stop, col_start:col_stop, 2) = 0;
                reformed_color(row_start:row_stop, col_start:col_stop, 3) = 0;            
            end
        end
    end
    overlapped_matrix = reformed_color;
end

function [row_start, row_stop, col_start, col_stop]= depth_to_color(pipemm_depth_H , pipemm_depth_W , pipemm_color_H , pipemm_color_W,row, col,the_size,nb_rows_color , nb_columns_color)

    mm_width_from_left = col/pipemm_depth_W;
    mm_height_from_top = row/pipemm_depth_H;
    
    corr_pixel_col_color = round(mm_width_from_left * pipemm_color_W);
    corr_pixel_row_color = round(mm_height_from_top * pipemm_color_H);
    
    steps = floor(the_size/2);
    %steps=5;
    
    row_start=corr_pixel_row_color-steps;
    row_stop=corr_pixel_row_color+steps;
    
    col_start=corr_pixel_col_color-steps;
    col_stop=corr_pixel_col_color+steps;
    
    if row_start<1
        row_start = 1;
    end
    if row_stop > nb_rows_color
        row_stop=nb_rows_color;
    end
    if col_start<1
        col_start = 1;
    end  
    if col_stop > nb_columns_color
        col_stop = nb_columns_color;
    end
end

function usefull_matrix = crop_RGB_to_basket(img)

    z = 20;

    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    row = 1;
    col = 1;
    %thicken the edge
    for i = (1+z): (MAX_ROW-z)
        for j = (1+z) : (MAX_COLUMN-z)
            if (img(i, j, 1) == 255) && (img(i, j, 2) == 0) && (img(i, j, 3) == 0)
                img(i-z:i+z, j-z:j+z, 1) = 0;
                img(i-z:i+z, j-z:j+z, 2) = 0;
                img(i-z:i+z, j-z:j+z, 3) = 255;
            end
        end
    end
    %go from left to right
    while (row ~= MAX_ROW)
        if col == MAX_COLUMN
            col = 1;
            row = row + 1;
        
        elseif (img(row, col, 1) == 0 ) && (img(row, col, 2) == 0) && (img(row, col, 3) == 255)
            col = 1;
            row = row + 1;
        
        else
            img(row, col, 1) = 255;
            img(row, col, 2) = 255;
            img(row, col, 3) = 255;
            col = col + 1;
        end
    end
    %go from right to left
    row = MAX_ROW;
    col = MAX_COLUMN;
    while (row ~= 1)
        if col == 1
            col = MAX_COLUMN;
            row = row - 1;
        
        elseif (img(row, col, 1) == 0) && (img(row, col, 2) == 0) && (img(row, col, 3) == 255)
            col = MAX_COLUMN;
            row = row - 1;
        
        else
            img(row, col, 1) = 255;
            img(row, col, 2) = 255;
            img(row, col, 3) = 255;
            col = col - 1;
        end
    end
    %go from top to bottom
    row = 1;
    col = 1;
    while (col ~= MAX_COLUMN)
        if row == MAX_ROW
            row = 1;
            col = col + 1;
        
        elseif (img(row, col, 1) == 0) && (img(row, col, 2) == 0) && (img(row, col, 3) == 255)
            row = 1;
            col = col + 1;
        
        else
            img(row, col, 1) = 255;
            img(row, col, 2) = 255;
            img(row, col, 3) = 255;
            row = row + 1;
        end
    end
    %go from bottom to top
    row = MAX_ROW;
    col = MAX_COLUMN;
    while (col ~= 1)
        if row == 1
            row = MAX_ROW;
            col = col - 1;
        
        elseif (img(row, col, 1) == 0) && (img(row, col, 2) == 0) && (img(row, col, 3) == 255)
            row = MAX_ROW;
            col = col - 1;
        else
            img(row, col, 1) = 255;
            img(row, col, 2) = 255;
            img(row, col, 3) = 255;
            row = row - 1;
        end
    end    
    %add in the white edge
    for i = 1: MAX_ROW
        for j = 1 : MAX_COLUMN
            if (img(i, j, 1) == 0) && (img(i, j, 2) == 0) && (img(i, j, 3) == 255)
                img(i,j, 1) = 255;
                img(i,j, 2) = 255;
                img(i,j, 3) = 255;
            end
        end
    end    
   usefull_matrix = img;

end


% color functions

function grey = greyscale(img)
    grey = img(:,:,1) * 0.2989 + img(:,:,2) * 0.5870 + img(:,:,3) * 0.1140;
   
end

function mean_blurred = mean_blur(img)
    mean = (1/9) * [ 1 1 1; 1 1 1; 1 1 1];
    mean_blurred = conv2(img, mean);
end

function gaussian_blurred = gaussian_blur(img)
    gaussian = (1/159) * [2 4 5 4 2; 4 9 12 9 4; 5 12 15 12 5; 4 9 12 9 4; 2 4 5 4 2;];
    gaussian_blurred = conv2(img, gaussian);
end


function [updated_corner_points, nb_of_groups] = remove_corner_points_within_corner_points(corner_points, nb_groups)
    mat_size = size(corner_points);
    groups = mat_size(2); % This is the original number_of_groups
    nb_of_groups = nb_groups; % This is the number_of_groups after regroup
    updated_corner_points = corner_points;
    
    for first=1:groups
        % Loop through every group
        % Now draw boundary box
        min_row_first = corner_points(1,first);
        min_col_first = corner_points(2,first);
        max_row_first = corner_points(3,first);
        max_col_first = corner_points(4,first);
        for second = 1:groups
            if first ~= second && max_row_first ~= 0 && corner_points(4, second) ~= 0 % If the max values would be 0, this won't be a group
                % Same groups, cant lay within eachother
                min_row_second = corner_points(1,second);
                min_col_second = corner_points(2,second);
                max_row_second = corner_points(3,second);
                max_col_second = corner_points(4,second);
                
                % Check if second lays within first
                
                if min_row_second >= min_row_first && min_col_second >= min_col_first && max_row_second <= max_row_first && max_col_second <= max_col_first
                    % Second object lays within first object
                    % Remouve this object
                    updated_corner_points(:, second) = zeros(4,1);

                    nb_of_groups = nb_of_groups - 1;
                end
            end
        end
    end
end

function [result, new_nb_of_groups] = remove_box_edge(corner_points, nb_of_groups)
    mat_size = size(corner_points);
    groups = mat_size(2);
    surfaces = zeros(groups); % Every column is a group, the value is the distance
    
    for i=1:groups
        
        min_row = corner_points(1,i);
        min_col = corner_points(2,i) ;
        max_row = corner_points(3,i);
        max_col = corner_points(4,i);
        
        surfaces(i) = (max_row - min_row) * (max_col - min_col);
    end
    
    %Now find biggest surface
    [max_value, max_col] = max(surfaces);
    for i=1:4
        % Set the coordinates of the outer points to 0
        corner_points(i, max_col) = 0;
    end
    
    result = corner_points;
    new_nb_of_groups = nb_of_groups-1;
end

function result = is_valid_position(max_row, max_col, row, col)
    if row <= max_row && row >= 1 && col <= max_col && col > 1
        result = 1;
    else
        result = 0;
    end
end

function result = same_pixels_in_range(img, row, col, SEARCH_GRID_SIZE)
    
    required_color = img(row, col);
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    result = 0; % = # pixels of the same value in a grid size of -SEARCH_GRID_SIZE to SEARCH_GRID_SIZE
    
    for row_i = -SEARCH_GRID_SIZE:SEARCH_GRID_SIZE
        for col_i = -SEARCH_GRID_SIZE:SEARCH_GRID_SIZE
            if is_valid_position(MAX_ROW, MAX_COLUMN, row + row_i, col + col_i) == 1 && img(row + row_i, col + col_i) == required_color
                result = result + 1; % Found pixel with same value in range
            end
        end
    end
    
    
end

function result = real_connecting_pixels(img, row, col)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    required_color = img(row, col);
    connecting = 0;
    new_img = img;
    for row_i = -1:1
        for col_i= -1:1
            new_row = row + row_i;
            new_col = col + col_i;
            if is_valid_position(MAX_ROW,MAX_COLUMN, new_row, new_col) == 1
                new_img(new_row, new_col) = -required_color; % random value that is not equal to the required color.
            end
        end
    end
    
    if connecting < 20
        
        for row_i=-1:1
            for col_i=-1:1
                % This is a grid of 3x3 around the pixel
                if row_i ~= 0 && col_i ~= 0 % Check if its the pixel that we search the connecting pixels for
                    new_row = row + row_i;
                    new_col = col + col_i;
                    if is_valid_position(MAX_ROW,MAX_COLUMN, new_row, new_col) == 1
                        if img(new_row, new_col) == required_color
                            % this is a connecting pixel
                            connecting = connecting + 1 + real_connecting_pixels(new_img, new_row, new_col); % Recursion
                        end
                    end
                end
            end
        end
    end
    
    result = connecting;
end

function result = find_group_in_range(img, row, col, SEARCH_GRID_SIZE)
    
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    result = 0; 
    % Because the algorithm works from top-left to bottom-right, we now
    % that after (row, col), every pixel is useless.
    for row_i=-SEARCH_GRID_SIZE:0 % So we only need to go to the row that the pixel is on
        for col_i=-SEARCH_GRID_SIZE:SEARCH_GRID_SIZE % Here we make the mistake that we search in (MAX_COL - col) pixels too much
            % Search in a grid around the pixel
            % This searches too much pixels, need to change that
            if is_valid_position(MAX_ROW, MAX_COLUMN, row +row_i, col +col_i) == 1 && img(row + row_i, col + col_i, 2) ~= 0
                result = img(row+row_i, col + col_i, 2); 
                break; % Stop algorithm if a group is found.
                
                % We dont work from row, row-1, row-2,... (further from
                % pixel) because it is slower.
            end
            
        end
    end
end

function [result, nb_of_groups] = group(img, SAME_PIXEL_SEARCH_GRID_SIZE, GROUP_SEARCH_GRID_SIZE, MIN_NB_SURROUNDING_PIXELS)
    % Goal, group pixels.
    % First loop from left to right to find an object
    % Check if it's connected
    % Number connected pixels in the second dimension
    WHITE = 1;
    BLACK = 0;
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    groups = 0;
    
    result = zeros(MAX_ROW,MAX_COLUMN,2); % Dimension 2 is for the group number.
    [first_row, last_row, first_col, last_col] = find_fist_and_last_occurrence(img);
    for row=first_row:last_row
        for col=1:MAX_COLUMN
          pixel_value = img(row, col);
          result(row, col,1) = pixel_value; % Transfer picture to result variable (in dim 1)
          if pixel_value == BLACK
              % This is an edge
              connecting_pixels = same_pixels_in_range(img, row, col, SAME_PIXEL_SEARCH_GRID_SIZE);
              %connecting_pixels = real_connecting_pixels(img, row, col);
              
              
              if connecting_pixels > MIN_NB_SURROUNDING_PIXELS
                  % This is defined as an object outline.
                  group_number = find_group_in_range(result, row, col, GROUP_SEARCH_GRID_SIZE);
                  
                  if group_number == 0
                      % assign new group
                      groups = groups + 1;
                      group_number = groups;
                  end
                  %disp("connecting pixels=" + connecting_pixels + " group number=" + group_number + " pos=" + row + ", " + col);
                  result(row, col, 2) = group_number;
              end
          end
        end
            %imagesc(result(:,:,2));
            %pause(0.001);
    end    
    nb_of_groups = groups;
end

function result = group_replace(grouped_img, to_replace, replace_with)
    matrix_size = size(grouped_img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    result = grouped_img;
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
           if grouped_img(row, col,2) == to_replace
               result(row, col,2) = replace_with;
           end
        end
    end
end

function [first_row, last_row, first_col, last_col] = find_fist_and_last_occurrence(img)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    first_row = 0;
    last_row = 0;
    first_col = 0; 
    last_col = 0;
    
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            if img(row, col) == 0
                first_row = row;
                break;
            end
        end
        if first_row ~= 0
            break;
        end
    end

    for row_i=1:MAX_ROW
        row = MAX_ROW - row_i + 1;
        for col=1:MAX_COLUMN
            if img(row, col) == 0
                last_row = row;
                break;
            end
        end
        if last_row ~= 0
            break;
        end
    end
    
    for col=1:MAX_COLUMN
        for row=1:MAX_ROW
            if img(row, col) == 0
                first_col = col;
                break;
            end
        end
        if first_col ~= 0
            break;
        end
    end

    for col_i=1:MAX_COLUMN
        col = MAX_COLUMN - col_i + 1;
        for row=1:MAX_ROW
            if img(row, col) == 0
                last_col = col;
                break;
            end
        end
        if last_col ~= 0
            break;
        end
    end
end

function [result, nb_groups] = regroup(grouped_img, nb_of_groups, MIN_ROW_LINES_BETWEEN_GROUPS)
    % Loop from (right)top to (left)bottom
    % Check if there are connecting groups.
    
    matrix_size = size(grouped_img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    nb_groups = nb_of_groups;
    for col_i=1:MAX_COLUMN
        for row=1:MAX_ROW
            col = MAX_COLUMN - col_i+1;
            group_nb = grouped_img(row, col, 2);
            if group_nb ~= 0
                for row_i=1:MIN_ROW_LINES_BETWEEN_GROUPS
                    if is_valid_position(MAX_ROW, MAX_COLUMN, row + row_i, col) == 1 && grouped_img(row + row_i, col, 2) ~= 0 && grouped_img(row+row_i, col,2) ~= group_nb
                        % Found a different group in the next 5 pixels
                        % below this one
                        % Replace next group with previous group number
                        grouped_img = group_replace(grouped_img, grouped_img(row+row_i, col, 2), group_nb);
                        nb_groups = nb_groups - 1;
                        break;
                    end
                end
            end
        end
    end
    
    
    result = grouped_img;
end

function img = draw_red_boundary_box(img, corner_points, top_row, top_col)
    mat_size = size(corner_points);
    groups = mat_size(2);
    THICKNESS = 5;
    
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    for i=1:groups
        % Loop through every group
        % Now draw boundary box
        min_row = corner_points(1,i) + top_row;
        min_col = corner_points(2,i) + top_col;
        max_row = corner_points(3,i) + top_row;
        max_col = corner_points(4,i) + top_col;
        % First draw horizontal lines
        for col=min_col:max_col
            for e=0:THICKNESS
                if is_valid_position(MAX_ROW, MAX_COLUMN, min_row+e, col) == 1
                    img(min_row+e, col, 1) = 255;
                    img(min_row+e, col, 2) = 1;
                    img(min_row+e, col, 3) = 1;
                end
                if is_valid_position(MAX_ROW, MAX_COLUMN, max_row-e, col) == 1
                    img(max_row-e, col,1) = 255;
                    img(max_row-e, col,2) = 1;
                    img(max_row-e, col,3) = 1;
                end
            end
        end
        
        % Vertical lines
        for row=min_row:max_row
            for e=0:THICKNESS
                if is_valid_position(MAX_ROW, MAX_COLUMN, row, min_col + e) == 1
                    img(row, min_col+e, 1) = 255;
                    img(row, min_col+e, 2) = 1;
                    img(row, min_col+e, 3) = 1;
                end
                if is_valid_position(MAX_ROW, MAX_COLUMN, row, max_col - e) == 1
                    img(row, max_col-e, 1) = 255;
                    img(row, max_col-e, 2) = 1;
                    img(row, max_col-e, 3) = 1;
                end
            end
            
        end
    end
end

function result = find_corner_points(img, nb_groups)
    % Loop through grouped image
    % find MIN_ROW & MIN_COL and MAX_ROW & MAX_COL
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    GROUP_MAX_ROW = zeros(1,nb_groups);
    GROUP_MAX_COL = zeros(1,nb_groups);
    GROUP_MIN_ROW = zeros(1,nb_groups);
    GROUP_MIN_COL = zeros(1,nb_groups);
           
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            group_nb = img(row, col, 2);
            if group_nb ~= 0 
                % Group found (==0 means nothing is set)
                if GROUP_MAX_ROW(1,group_nb) == 0 || GROUP_MAX_ROW(1,group_nb) < row
                    GROUP_MAX_ROW(1,group_nb) = row;
                end
                
                if GROUP_MAX_COL(1,group_nb) == 0 || GROUP_MAX_COL(1,group_nb) < col
                    GROUP_MAX_COL(1,group_nb) = col;
                end
                
                if GROUP_MIN_ROW(1,group_nb) == 0 || GROUP_MIN_ROW(1,group_nb) > row
                    GROUP_MIN_ROW(1,group_nb) = row;
                end
                if GROUP_MIN_COL(1,group_nb) == 0 || GROUP_MIN_COL(1,group_nb) > col
                    GROUP_MIN_COL(1,group_nb) = col;
                end                
            end
           
        end
        result = [GROUP_MIN_ROW; GROUP_MIN_COL; GROUP_MAX_ROW; GROUP_MAX_COL];
    end
    
end

function result = remove_boundary(img, remove_size)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    result = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
           if row < remove_size || col < remove_size || row > (MAX_ROW - remove_size) || col > (MAX_COLUMN - remove_size)
               % Inside boundary ==> needs to be white (= 1)
               result(row, col) = 1;
           else
               result(row, col) = img(row, col);
           end
           
        end
    end
end

function thresholded_img = threshold_edge(img, THRESHOLD_VALUE) 
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    THICKNESS = 1; % 3 
    
    thresholded_img = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            if img(row, col) > THRESHOLD_VALUE
                value = 1;
                for i=1:THICKNESS
                    % Create thicker edges (edges of THICKNESS pixels thick)
                    if (col - i) > 0
                        thresholded_img(row, col-i) = 1;
                    end
                    
                    if (col + i) <= MAX_COLUMN
                        thresholded_img(row, col+i) = 1;
                    end
                    
                    if (row - i) > 0
                        thresholded_img(row -i, col) = 1;
                    end
                    
                    if (row + i) <+ MAX_ROW
                        thresholded_img(row +i, col) = 1;
                    end
                   
                end
            else
                value = 0;
            end
            thresholded_img(row, col) = value;
        end
    end
end

function edge = edge_detect(img)
    klaplace=[0 -1 0; -1 4 -1;  0 -1 0];             % Laplacian filter kernel
    edge=conv2(img,klaplace);                         % convolve test img with
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%FUNCTIONS FOR OUTLINE BEGINING%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%start outline software

%%%%%%%%end outline software

%%%%%%%%%%%Start positions
function placing = top_left(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position top left of the given position
    x = position(1) -1;
    y = position(2) -1;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
function placing = top(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position above the given position
    x = position(1) -1;
    y = position(2) ;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end
end
function placing = top_right(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position top right of the given position
    x = position(1) - 1;
    y = position(2) + 1;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
function placing = right(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position to the right of the given position
    x = position(1) ;
    y = position(2) +1;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
function placing = bottom_right(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position bottom right of the given position
    x = position(1) +1;
    y = position(2) +1;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
function placing = bottom(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position below the given position
    x = position(1) +1;
    y = position(2) ;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
function placing = bottom_left(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position bottom left of the given position
    x = position(1) +1;
    y = position(2) -1;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
function placing = left(position, img, MAX_ROW, MAX_COLUMB)
    % returns the position to the left of the given position
    x = position(1);
    y = position(2) -1;
    
    if (0 < x) && (x <= MAX_ROW) && (0 < y) && (y <= MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
%%%%%%%end positions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%FUNCTIONS FOR OUTLINE END%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%START OVERLAP%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%END OVERLAP%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

function filled_matrix = fill_matrix(img)

    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);

    new_matrix = zeros(MAX_ROW, MAX_COLUMN);
    
    for i = 1 : MAX_ROW
        for j = 1 : MAX_COLUMN
            if img(i, j) == -1
                new_matrix(i-1: i+1, j-1: j+1) = -1;
                
            end
        end 
    end
                
    filled_matrix = new_matrix;            
            
end

function result = recolor(img, nb_of_groups)
    max_color_value = 255;
    result(:,:,1) = img;
    result(:,:,2) = img;
    result(:,:,3) = img;
    
    result = result * max_color_value/nb_of_groups;
    
end


