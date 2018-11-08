clearvars
img = imread('kinect/foto RGB 2.png'); % Load picture
A = greyscale(img); % Convert image to grayscale
A = symImgCrop(A, 50); % Crop image so it's the same size.
A = gaussian_blur(mean_blur(A)); % Filters
%% Method 3: First greyscale, then blur, then edge detect then threshold and then noise removal
first_edge_detect = edge_detect(A); % Laplacian edge detection
without_noise_removal = threshold_edge(remove_boundary(first_edge_detect, 15)); % Remove boundary around image & threshold the edges.
with_noise_removal = without_noise_removal; % Noise removal
[grouped, nb_of_groups] = group(~with_noise_removal);
corner_points = find_corner_points(grouped, nb_of_groups);
boundary_box = draw_boundary_box(A, corner_points);

subplot(1,2,1), imshow(A, []);
subplot(1,2,2), imshow(boundary_box, []);
title("Number of objects = "+ nb_of_groups);
%title("Input (after blur)");
%subplot(2,2,2), imshow(first_edge_detect, []);
%title("After edge detection");
%subplot(2,2,3), imshow(without_noise_removal, []);
%title("Threshold without noise removal");
%subplot(2,2,4), imshow(grouped(:,:,2), []);
%title("Method 2 with gaussian and mean blur");
%imagesc(grouped(:,:,2));
%imshow(~with_noise_removal, []);
%imshow(with_noise_removal);
disp("done");
function result = is_valid_position(max_row, max_col, row, col)
    if row <= max_row && row >= 1 && col <= max_col && col > 1
        result = 1;
    else
        result = 0;
    end
end

function result = connected_pixels(img, row, col)
    SEARCH_GRID_SIZE = 25;
    
    required_color = img(row, col);
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    result = 0;
    
    for row_i = -SEARCH_GRID_SIZE:SEARCH_GRID_SIZE
        for col_i = -SEARCH_GRID_SIZE:SEARCH_GRID_SIZE
            if is_valid_position(MAX_ROW, MAX_COLUMN, row + row_i, col + col_i) == 1 && img(row + row_i, col + col_i) == required_color
            result = result + 1;
            end
        end
    end
    
    
end

function result = find_connecting_group(img, row, col)
    SEARCH_GRID_SIZE = 25;
    
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    result = 0; 
    
    for row_i=-SEARCH_GRID_SIZE:SEARCH_GRID_SIZE
        for col_i=-SEARCH_GRID_SIZE:SEARCH_GRID_SIZE
            % Search in a grid around the pixel
            % This searches too much pixels, need to change that
            if is_valid_position(MAX_ROW, MAX_COLUMN, row +row_i, col +col_i) == 1 && img(row + row_i, col + col_i, 2) ~= 0
                result = img(row+row_i, col + col_i, 2);
                break;
            end
            
        end
    end
    %for i=1:150
        % Search in a 3x3 grid around pixel.
        % But only up and left because algorithm is going right down.
        % Up connecting
        %if is_valid_position(MAX_ROW, MAX_COLUMN, row -i, col) == 1 &&  img(row -i, col, 2) ~= 0
           % result = img(row-1, col, 2);
            %break;
             %group found
       % end
       
        % Left connectingqw
        %if is_valid_position(MAX_ROW, MAX_COLUMN, row, col-i) == 1&&  img(row, col -i, 2) ~= 0
           % result = img(row, col -i, 2);
           % break;
            %group found
        %end
    %end
end

function [result, nb_of_groups] = group(img)
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
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
          pixel_value = img(row, col);
          result(row, col,1) = pixel_value;
          result(row, col, 2) = 0; % Will be changed if black color.
          if pixel_value == BLACK
              % This is an edge
              connecting_pixels = connected_pixels(img, row, col);
              
              if connecting_pixels > 10
                  % This is defined as an object outline.
                  group_number = find_connecting_group(result, row, col);
                  
                  if group_number == 0
                      % assign new group
                      disp("----new group----");
                      groups = groups + 1;
                      group_number = groups;
                  end
                  disp("connecting pixels=" + connecting_pixels + " group number=" + group_number + " pos=" + row + ", " + col);
                  result(row, col, 2) = group_number;
              end
          end
          %imagesc(result(:,:,2));
          
        end
    end    
    nb_of_groups = groups;
end

function result = draw_boundary_box(img, corner_points)
    matrix_size = size(corner_points);
    groups = matrix_size(2);
    THICKNESS = 5;
    for i=1:groups
        % Loop through every group
        % Now draw boundary box
        
        min_row = corner_points(1,i);
        min_col = corner_points(2,i);
        max_row = corner_points(3,i);
        max_col = corner_points(4,i);
        
        % First draw horizontal lines
        for col=min_col:max_col
            for e=0:THICKNESS
                img(min_row+e, col) = 0;
                img(max_row-e, col) = 0;
            end
        end
        
        % Vertical lines
        for row=min_row:max_row
            for e=0:THICKNESS
                img(row, min_col+e) = 0;
                img(row, max_col-e) = 0;
            end
            
        end
    end
    result = img;
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

function thresholded_img = threshold_edge(img)
    threshold_value = 2;
    %most_occuring =mode(img) +100;
    %threshold_value = most_occuring(1);
   
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    THICKNESS = 3;
    
    thresholded_img = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            if img(row, col) > threshold_value
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

function mean_blurred = mean_blur(img)
    mean = (1/9) * [ 1 1 1; 1 1 1; 1 1 1];
    mean_blurred = conv2(img, mean);
end

function gaussian_blurred = gaussian_blur(img)
    gaussian = (1/159) * [2 4 5 4 2; 4 9 12 9 4; 5 12 15 12 5; 4 9 12 9 4; 2 4 5 4 2;];
    gaussian_blurred = conv2(img, gaussian);
end

function edge = edge_detect(img)
    klaplace=[0 -1 0; -1 4 -1;  0 -1 0];             % Laplacian filter kernel
    edge=conv2(img,klaplace);                         % convolve test img with
end

function grey = greyscale(img)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    grey = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            R = img(row, col, 1);
            G = img(row, col, 2);
            B = img(row, col, 3);
            grey(row, col) = 0.2989 * R + 0.5870 * G + 0.1140 * B ;  
            %These are two methods for grayscaling.
            %grey(row, col) = (R + G + B)/3;
        end
    end
end

%% Cropping and image rotation functions

function cropped_img = symImgCrop(img,cutted_edge_size)
    original_img_size = size(img);
    original_max_row = original_img_size(1);
    original_max_column = original_img_size(2);
    
    cropped_img = zeros(original_max_row - 2*cutted_edge_size,original_max_column - 2*cutted_edge_size,1);
    
    for row=cutted_edge_size:original_max_row - cutted_edge_size
        for col=cutted_edge_size:original_max_column - cutted_edge_size
            cropped_img(row - cutted_edge_size + 1,col - cutted_edge_size + 1) = img(row,col);
        end
    end
end

function img_rot = four_point_img_rotation_crop(img, fourp)
    % A function which crops and rotates the given image so that the only
    % thing shown will be the pixels inside the four points, in horizontal
    % or vertical position.
     fourp_base = [0 fourp(1,2)-fourp(1,1) fourp(1,3)-fourp(1,1) fourp(1,4)-fourp(1,1); 0 fourp(2,2)-fourp(2,1) fourp(2,3)-fourp(2,1) fourp(2,4)-fourp(2,1)];
     if (fourp_base(4,1)-fourp_base(1,1)) > 4
         sigma = atan((fourp_base(2,4)-fourp_base(2,1))/(fourp_base(1,4)-fourp_base(1,1)));
     else
         sigma = pi/2;
     end
     if sigma <= pi/4
         rot_mat = [cos(-sigma) -sin(-sigma); sin(-sigma) cos(-sigma)];
     else
         rot_mat = [cos(pi/2 - sigma) -sin(pi/2 - sigma); sin(pi/2 - sigma) cos(pi/2 - sigma)];
     end
     
     
end

function img_crop = generic_crop(img, fourp)
    % A function which crops the given image so that the edges are
    % definened by the four point given in fourp.
    X_ARRAY = [fourp(1,1) fourp(1,2) fourp(1,3) fourp(1,4)];
    Y_ARRAY = [fourp(2,1) fourp(2,2) fourp(2,3) fourp(2,4)];
    MIN_X = min(X_ARRAY);
    MAX_X = max(X_ARRAY);
    MIN_Y = min(Y_ARRAY);
    MAX_Y = max(Y_ARRAY);
    img_crop = zeros(MAX_X-MIN_X,MAX_Y-MIN_Y);
    
    for row = MIN_X:MAX_X
        for col = MIN_Y:MAX_Y
            img_crop(row - MIN_X + 1,col - MIN_Y + 1) = img(row,col);
        end
    end
end

