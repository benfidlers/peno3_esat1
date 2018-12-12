
h = 900;

min_y = 120;
max_y = 460;
min_x = 75;
max_x = 310;

% Threshold values
min_thresh = 30;
max_thresh = 500;

% Get image from depth sensor
colorVid = videoinput('kinect',1);
depthVid = videoinput('kinect',2);
depth = getsnapshot(depthVid);
color = getsnapshot(colorVid);
raw_matrix = depth;
%%
%Run the sobel operator

depth = sobel_operator(depth);
shapes_after_sobel = depth;
%Run the threshold filter
depth = threshold(depth, min_thresh, max_thresh);
depth = print(depth, min_x, max_x, min_y, max_y);
depth_after_threshold = depth;

%%%%%%%outline
depth = outline(depth);
final_img = only_outline_visible(depth);
edged_matrix = only_edge(depth);

new_depth = crop_depth_to_basket(edged_matrix, depth_after_threshold);
depth_tester = new_depth;

%OVERLAP
%%%%%%%%%%%%%%%%%%%%%%%%%%

%color: 1920x1080 met 84.1 x 53.8
%depth: 512x424  met 70.6 x 60

[reformed_depth,reformed_color, res_height_angle, res_width_angle] = reform(depth, color);
[pipemm_depth_H, pipemm_depth_W, pipemm_color_H, pipemm_color_W] = get_pipemm(res_height_angle, res_width_angle, h, reformed_depth,reformed_color);


[prop,nb_rows_color , nb_columns_color,nb_rows_depth, nb_columns_depth] = proportion(reformed_depth , reformed_color);

tot_size = size_matching(prop);

total = overlap_depth_to_RGB(reformed_depth, reformed_color, pipemm_depth_H , pipemm_depth_W , pipemm_color_H , pipemm_color_W,tot_size,nb_rows_color , nb_columns_color);

new_RGB = crop_RGB_to_basket(total);
image(new_RGB);

img = new_RGB;

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
SURROUDING_PERCENTAGE = 10;% %
MIN_NB_SURROUNDING_PIXELS = floor((SAME_PIXELS_SEARCH_GRID_SIZE * 2)^2 * SURROUDING_PERCENTAGE/100) ;%125 % 50
% The minimum number of pixels with the same value that are in the grid
% size defined by SAME_PIXELS_SEARCH_GRID
% The pixels that have a less number of surrounding pixels, are not defined
% as a group but as noise.

% CROPPING: Defining rectangle
%top_row = 290 ; top_col = 760; bottom_row = 690 ; bottom_col = 1440;
%top_row = 150; top_col = 750; bottom_row = 950; bottom_col = 1900;
%top_row = 200; top_col = 850; bottom_row = 750; bottom_col = 1850; % For pictues with x2_RGB_... in name
%top_row = 100, top_col = 100; bottom_row = 980; bottom_col = 1820; % For pictues with RGB in name.

disp("Step 1: loading the image...");
disp("Minimum distance between 2 objects (only straight vertical or straight horizontal = " + max([MIN_ROW_LINES_BETWEEN_GROUPS SAME_PIXELS_SEARCH_GRID_SIZE MIN_NB_SURROUNDING_PIXELS;]) + " pixels");

disp("Step 2: converting the image to greyscale...");

A = greyscale(img); % Convert image to grayscale

%top_left_row, top_left_col, bottom_right_row, bottom_right_col
disp("Step 3: cropping the image...");

%A = simon_crop(A, top_row, top_col, bottom_row, bottom_col);
imshow(A, []);
%%
%A = simon_crop(A, 100,100,980,1820, 1); % USE FOR foto RGB X
%A = simon_crop(A, top_row,top_col,bottom_row, bottom_col,1); % USE FOR foto XX RGB

disp("Step 4: blurring the image...");
A = gaussian_blur(mean_blur(A)); % Filters
% Method 3: First greyscale, then blur, then edge detect then threshold and then noise removal
disp("Step 5: edge detecting...");
first_edge_detect = edge_detect(A); % Laplacian edge detection
disp("Step 6: thresholding edge");
without_noise_removal = threshold_edge(remove_boundary(first_edge_detect, 15), THRESHOLD_VALUE); % Remove boundary around image & threshold the edges.
disp("Step 7: noise removing...");
%with_noise_removal = noise_deletion(without_noise_removal,5); % Noise removal
with_noise_removal = without_noise_removal;
disp("Step 8: grouping...");
[grouped, nb_of_groups] = group(~with_noise_removal, SAME_PIXELS_SEARCH_GRID_SIZE, GROUP_SEARCH_GRID_SIZE, MIN_NB_SURROUNDING_PIXELS); % Group pixels together

disp("Step 9: regrouping...");
[regrouped, nb_of_groups2] = regroup(grouped, nb_of_groups, MIN_ROW_LINES_BETWEEN_GROUPS); % Regroup (nessicary because group function works from top left to bottom right

%Find corner points of object (not really corner points on the boundary,
%but corner points for the boundary box)
disp("Step 10: calculating corner points...");
corner_points = find_corner_points(regrouped, nb_of_groups); % Make sure to use nb_of_groups and not groups 2 because some groups don't exist anymore!

disp("Step 11: removing objects within objects...");
%[updated_corner_points, nb_of_groups3] = remove_corner_points_within_corner_points(corner_points, nb_of_groups2); % To remove objects within objects
[updated_corner_points, nb_of_groups3] = remove_box_edge(corner_points, nb_of_groups2);
[updated_corner_points, nb_of_groups3] = remove_corner_points_within_corner_points(updated_corner_points, nb_of_groups3);
%updated_corner_points = corner_points;
%nb_of_groups3 = nb_of_groups2;

disp("Step 12: drawing boundary boxes...");
boundary_box = draw_boundary_box(A, updated_corner_points);
disp("Step 13: drawing red boundary boxes on full image...");
red_boundary_box = draw_red_boundary_box(reformed_color, updated_corner_points, 1,1);
disp("Step 13: Done!!!");
toc
%%
% Original image
imshow(img, []);
imwrite(img, 'img_brent_2.png');
title("Original image");
%% After edge detection
imshow(first_edge_detect, []);
title("Edge detection");
%% Grouped image
imagesc(grouped(:,:,2));
title("Groups, #nb_objects = " + nb_of_groups);
%% Regrouped image
imagesc(regrouped(:,:,2));
title("Regrouped, Number of objects = " + nb_of_groups2);
%%
%imshow(recolor(regrouped(:,:,2), nb_of_groups2), []);
%% Result
imshow(boundary_box, []);
title("Boundary box + removed objects within objects, Number of objects = "+ nb_of_groups3);
%%
imshow(red_boundary_box, []);
title("# objects: "+ nb_of_groups3);