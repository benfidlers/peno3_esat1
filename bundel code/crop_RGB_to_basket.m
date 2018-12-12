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