%color: 1920x1080 met 84.1 x 53.8
%depth: 512x424  met 70.6 x 60
 
depth = importdata('depth.mat');
color = imread('foto RGB 1.png');
h = 900;
[reformed_depth,reformed_color, res_height_angle, res_width_angle] = reform(depth, color);
[pipemm_depth_H, pipemm_depth_W, pipemm_color_H, pipemm_color_W] = get_pipemm(res_height_angle, res_width_angle, h, reformed_depth,reformed_color);

% om te testen
disp([pipemm_depth_H, pipemm_depth_W, pipemm_color_H, pipemm_color_W]);


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
        
    reformed_color = color(:,round(nb_width_pixels_removed_color/2,0): round(nb_columns_color-(nb_width_pixels_removed_color/2),0),:);
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
function [prop] = proportion(reformed_depth , reformed_color)
    [nb_rows_color , nb_columns_color]=size(color);
    [nb_rows_depth, nb_columns_depth]= size(depth);
    
    nb_pixels_color=nb_rows_color * nb_columns_color;
    nb_pixels_depth=nb_rows_depth * nb_columns_depth;
    
    x= max(nb_pixels_color,nb_pixels_depth);
    y= min(nb_pixels_color,nb_pixels_depth);
    
    prop = x/y;
    
end

function [size]=size_matching(prop)
    size= round(sqrt(prop));
end

function [row_start, row_stop, col_start, col_stop]= depth_to_color(pipemm_depth_H , pipemm_depth_W , pipemm_color_H , pipemm_color_W,row, col,size)

    mm_width_from_left = col/pipemm_depth_W;
    mm_height_from_top = row/pipemm_depth_H;
    
    corr_pixel_col_color = round(mm_width_from_left * pipemm_color_W);
    corr_pixel_row_color = round(mm_height_from_top * pipemm_color_H);
    
    steps = floor(size/2);
    
    row_start=corr_pixel_row_color-steps;
    row_stop=corr_pixel_row_color+steps;
    
    col_start=corr_pixel_col_color-steps;
    col_stop=corr_pixel_col_color+steps;
end
    
