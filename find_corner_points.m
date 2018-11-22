function result = find_corner_points(img) % Returns 4 corner points (elke rij is een hoekpunt, met eerst x dan y)
    % row1 col1 TOP 
    % X2 Y2 LEFT
    % X3 Y3 RIGHT
    % X4 Y4 BOTTOM
    % Loop through image
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
            if pixel_value == 1
                % Found boundary
                if max_row(1) == 0 || max_row(1) < row
                    max_row = [row col];
                end
                
                if max_col(2) == 0 || max_col(2) < col
                    max_col = [row col];
                end
                
                if min_row(1) == 0 || min_row(1) > row
                    min_row = [row col];
                end
                if min_col(2) == 0 || min_col > col
                    min_col = [row col];
                end                
            end
           
        end
        result = [transpose(min_row) transpose(min_col) transpose(max_col) transpose(max_row)];
    end
    
end