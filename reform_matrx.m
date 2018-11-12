%color: 1920x1080 met 84.1 x 53.8
%depth: 512x424  met 70.6 x 60

depth = importdata('depth.mat');
color = imread('foto RGB 1.png');
h = 0.9;
[reformed_depth,reformed_color] = reform(depth, color);

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


    
    


    
    
    
    
    
    
    
    
    
    
    
    
