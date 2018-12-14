function newImg = object_highlighter(img, obj_points, regrouped, groupnb)
    % Makes everything besides the object with a given group number white.

    % Initializing variables
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COL = matrix_size(2);
    newImg = ones(MAX_ROW,MAX_COL);
    
    % Iterate over every row
    for row = 1:MAX_ROW
        first_pixel = -1;
        last_pixel = -1;
        
        % First iteration over the row
        % Mark for each row the first and the last pixel of the object, as
        % seen by the regrouping algortihm
        for col = 1:MAX_COL
            if regrouped(row + obj_points(1)-1,col + obj_points(2)-1,2) == groupnb
                last_pixel = col-2;
                if first_pixel == -1 
                    first_pixel = col+2;
                end
            end
        end
        
        % Second iteration over the row
        % If the pixel falls inbetween the two marked points, it belongs to
        % the object and is given the same value as the original image. If
        % the pixel is outside those points or there are no marked points
        % at all it is coloured white (255).
        for col = 1:MAX_COL
            
            if first_pixel == -1
               newImg(row,col) = 255;  
            end
            
            if col >= first_pixel && col <= last_pixel
                newImg(row,col) = img(row,col);
            else
               newImg(row,col) = 255; 
            end
        end
    end
end