img = [0 0 0 0 0 0; 0 1 1 1 1 0; 0 1 0 0 1 0; 
      0 1 0 0 1 0; 0 1 1 1 1 0; 0 0 0 0 0 0];

% matrix_size = size(img);
% 
% MAX_ROW = matrix_size(1);
% 
% MAX_COLUMN = matrix_size(2);
% 
% 
% position = [2, 2];  
img = outline(img);
disp(img);

  
  
  function outlined_matrix = outline(img)
    
    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    
    for row = 1: MAX_ROW
        col = 1;
        while col <= MAX_COLUMN
             position = img(row, col);
            if position == 0
                col = col + 1;
            elseif position == -1
                col = skip(img, row, col);
            elseif position == 1
                img = outline_shape(img, row, col-1, MAX_ROW, MAX_COLUMN);
            
            end
        end
    end   
    outlined_matrix = img;
end
function new_col = skip(img, row, col)
    good_value = 0;
    while good_value ~= 1
        col = col+ 1;
        if img(row, col) == -1
            good_value = 1;
        end
    end
    new_col = col +1;
end

%%%%%%%%start outline software

function oulined_objects = outline_shape(img, row, col, MAX_ROW, MAX_COLUMN)
    img(row, col) = -1;
    matrix = surrounded_matrix(img, row, col, MAX_ROW, MAX_COLUMN);
    
    for i = 1:3
        for j = 1:3
            if (matrix(i:j:1) == 0) & (connected_to_one(img, matrix(i:j:2), matrix(i:j:3), MAX_ROW, MAX_COLUMN) == 1)
                outlined_objects = outline_shape(img, matrix(i:j:2), matrix(i:j:3), MAX_ROW, MAX_COLUMN);
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
            if matrix(i:j) == 1
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
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        
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
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end
end
function placing = top_right(position, img, MAX_ROW, MAX_COLUMB)
    x = position(1) + 1;
    y = position(2) + 1;
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        
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
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        
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
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        
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
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        
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
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        
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
    
    if (0 < x) && (x < MAX_ROW) && (0 < y) && (y < MAX_COLUMB) 
        
        value = img(x, y);
        placing = [value, x, y];
    else
        
        value = -2;
        placing = [value, x, y];
    end 
end
%%%%%%%end positions
