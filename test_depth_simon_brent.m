clearvars
h = 900;

% Processing the image using the depthsensor

min_y = 120;
max_y = 480;
min_x = 70;
max_x = 330;
% Threshold values
min_thresh = 30;
max_thresh = 500;

% Get image from depth sensor
%depth = getsnapshot(depthVid);
%color = getsnapshot(colorVid);
%color = imread('doos_leeg_overlap_RGB.png');
load('depth_lege_doos.mat');
%Run the sobel operator
shapes = sobel_operator(depth);



%Run the threshold filter
shapes = threshold(shapes, min_thresh, max_thresh);
shapes = print(shapes, min_x, max_x, min_y, max_y);
%Look at the result
%image(shapes);

% %%%%%outline
shapes = outline(shapes);
final_img = only_outline_visible(shapes);
% shapes = fill_matrix(shapes);
% shapes = fill_matrix(shapes);

edged_matrix = only_edge(shapes);
c = find_corner_points(edged_matrix);


lol = imrotate(edged_matrix, 90);

d = find_corner_points(lol);

for i=1:4
    % row1 row2 row3
    %col1 col2
    coordinates = c(:,i);
    row = coordinates(1);
    col = coordinates(2);
    for e=-3:3
        for b=-3:3
           edged_matrix(row + e, col + b) = 100; 
        end
    end
end

for i=1:4
    coordinates = d(:,i);
    row = coordinates(1);
    col = coordinates(2);
    for e=-3:3
        for b=-3:3
           lol(row + e, col + b) = 100; 
        end
    end
end
lol = imrotate(lol, -90);
imagesc(edged_matrix);
%OVERLAP
%%%%%%%%%%%%%%%%%%%%%%%%%%

% %color: 1920x1080 met 84.1 x 53.8
% %depth: 512x424  met 70.6 x 60
% depth = shapes; 
% %color = imread('doos_leeg_overlap_RGB.png');
% 
% %color = getsnapshot(colorVid);
% 
% [reformed_depth,reformed_color, res_height_angle, res_width_angle] = reform(depth, color);
% [pipemm_depth_H, pipemm_depth_W, pipemm_color_H, pipemm_color_W] = get_pipemm(res_height_angle, res_width_angle, h, reformed_depth,reformed_color);
% 
% 
% 
% 
% [prop,nb_rows_color , nb_columns_color,nb_rows_depth, nb_columns_depth] = proportion(reformed_depth , reformed_color);
% 
% tot_size = size_matching(prop);
% 
% % om te testen
% disp([pipemm_depth_H, pipemm_depth_W, pipemm_color_H, pipemm_color_W]);
% 
% % testen totaal programma
% 
% total = overlap_depth_to_RGB(reformed_depth, reformed_color, pipemm_depth_H , pipemm_depth_W , pipemm_color_H , pipemm_color_W,tot_size,nb_rows_color , nb_columns_color);
% 
% %image(total);
% imshow(total);
%%%%%%%%%%%%%

%%%%% Functions %%%%%

function shapes = sobel_operator(img)

    X = img;
    Gx = [1 +2 +1; 0 0 0; -1 -2 -1]; Gy = Gx';
    temp_x = conv2(X, Gx, 'same');
    temp_y = conv2(X, Gy, 'same');
    shapes = sqrt(temp_x.^2 + temp_y.^2);
end 

function thresholded = threshold(img, min_thresh, max_thresh)

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

function printed = print(img, min_x, max_x, min_y, max_y)
    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    mat = zeros(MAX_ROW,MAX_COLUMN,1);
    
    for row = 1:MAX_ROW
        
        for col = 1: MAX_COLUMN
            if (row>min_x) && (row<max_x) && (col> min_y) && (col<max_y)
                mat(row, col) = img(row, col);
            end
        end
    end
    printed = mat;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%FUNCTIONS FOR OUTLINE BEGINING%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  
  
  function outlined_matrix = outline(img)
    
    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    x = 0;
    
    for row = 1: MAX_ROW
        col = 1;
        while col <= MAX_COLUMN
             position = img(row, col);
            if position == 0
                col = col + 1;
            elseif position == -1
                col = skip(img, row, col, MAX_COLUMN);
            elseif position == 1
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
    good_value = 0;
    while (good_value ~= 1) && (col < MAX_COLUMN)
        col = col+ 1;
        if img(row, col) == -1
            good_value = 1;
        end
    end
    new_col = col +1;
end

function RGB_matrix = only_outline_visible(img)
    
    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    matrix_a = zeros(MAX_ROW, MAX_COLUMN); 
    matrix_b = zeros(MAX_ROW, MAX_COLUMN); 
    matrix_c = zeros(MAX_ROW, MAX_COLUMN); 
    
    matrix_complete = matrix_a;
    matrix_complete(:,:,2) = matrix_b;
    matrix_complete(:,:,3) = matrix_c;
    
    for row = 1 : MAX_ROW
        for col = 1: MAX_COLUMN
            if img(row, col) == -1
                matrix_complete(row, col, 1) = 255;
            end
        end
    end

    RGB_matrix = matrix_complete;
end


%%%%%%%%start outline software

function outlined_objects = outline_shape(img, row, col, MAX_ROW, MAX_COLUMN)
    
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


%%%%%%%%end outline software


%%%%%%%%%%%Start positions
function placing = top_left(position, img, MAX_ROW, MAX_COLUMB)
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


function [reformed_depth,reformed_color,resulting_height_angle,resulting_width_angle] = reform(depth, color) %met h= height camera

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


function edged_matrix = only_edge(img)

    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    to_be_edged_matrix = zeros(MAX_ROW, MAX_COLUMN);
    
    for i = 1: MAX_ROW
        for j = 1 : MAX_COLUMN
            if img(i, j) == -1
                to_be_edged_matrix(i, j) = 100;
            end
        end
    end    
    edged_matrix = to_be_edged_matrix;    
end

function result = find_corner_points(img) % Returns 4 corner points (elke rij is een hoekpunt, met eerst x dan y)
    % row1 row2 row3 row4
    % col1 col2 col3 col4
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    max_row = zeros(1,2); 
    max_col = zeros(1,2);
    min_row = zeros(1,2);
    min_col = zeros(1,2);
           
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            pixel_value = img(row, col, 1);
            if pixel_value == 100
                % Found boundary
                if max_row(1) == 0 || max_row(1,1) < row
                    max_row = [row col];
                end
                
                if max_col(2) == 0 || max_col(1,2) <= col
                    max_col = [row col];
                end
                
                if min_row(1) == 0 || min_row(1,1) > row
                    min_row = [row col];
                end
                if min_col(2) == 0 || min_col(1,2) > col
                    min_col = [row col];
                end                
            end
           
        end
        result = [transpose(min_row) transpose(min_col) transpose(max_col) transpose(max_row)];
    end
    
end

function drawnLine = drawLine(img, fpoint, spoint)

   drawnLine = img;
   ratioVector = abs(fpoint-spoint);
   top = max(ratioVector(1), ratioVector(2));
   bot = min(ratioVector(1), ratioVector(2));
   
   ratio = top/bot;
   
   base = floor(ratio);
   error = round((ratio-base)*10);
   
   if error == 1
       base = base+1;
       error = 0;
   end
   
   
   
   
   
   cntr = 0;
   errorCoo = 0;
   if max(ratioVector(1), ratioVector(2)) == ratioVector(1)
       %top is y
       if fpoint(1) > spoint(1)
           startCoo = fpoint;
           if fpoint (2) <= spoint(2)
               errorCorec = 1;
           else
               errorCorec = -1;
           end
       else
           startCoo = spoint;
            if fpoint (2) > spoint(2)
               errorCorec = 1;
           else
               errorCorec = -1;
           end
       end
       
        for i=1:base
           if cntr == error
              cntr = 0; 
              errorCoo = errorCoo + 1;
           else
               cntr = cntr+1;
           end
           
           drawline(startCoo(1) + i, startCoo(2)+ errorCorec*errorCoo);
           
        end
   else
       %top is x
       if fpoint(2) > spoint(2)
           startCoo = fpoint;
           if fpoint (1) <= spoint(1)
               errorCorec = 1;
           else
               errorCorec = -1;
           end
       else
           startCoo = spoint;
            if fpoint (1) > spoint(1)
               errorCorec = 1;
           else
               errorCorec = -1;
           end
       end
       
        for i=1:base
           if cntr == error
              cntr = 0; 
              errorCoo = errorCoo + 1;
           else
               cntr = cntr+1;
           end
           
           drawline(startCoo(1) + errorCorec*errorCoo, startCoo(2)+ i);
           
        end  
   end
end

for result = new_points(img, corner_points)
    top_corner = corner_points(:,1);
    left_corner = corner_points(:,2);
    right_corner = corner_points(:,3);
    bottom_corner = corner_points(:,4);
    
    result = zeros(2,4); % New points
    left =  - left_corner)/2
    top = (top_corner - right_corner)/2
end
