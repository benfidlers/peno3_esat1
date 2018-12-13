function result = position_tester(package, object, smallest_row, smallest_col)
    % The result of this function is true if and only if appending the
    % package with the given object on the given row and col doesn't result
    % in overlap.
    
    % Remeber that every non-object pixel in package has a value of -1.
    
    % Initialize variables
    result = 1;
    mat_size = size(package);
    object_size = size(object);
    
    % Determine the boundaries of iteration. If the object fully overlaps
    % with the current package use the object dimensions + the position as
    % the upper-boundary else use the package dimensions as the boundary.
    if  object_size(1) + smallest_row-1 > mat_size(1)
        biggest_row = mat_size(1);
    else
        biggest_row = object_size(1) + smallest_row-1;
    end
    
    if object_size(2) + smallest_col - 1 > mat_size(2)
        biggest_col = mat_size(2);
    else
        biggest_col = object_size(2) + smallest_col - 1;
    end
    
    % Run trhough the part of the package with which the object would
    % overlap, if there is another object the result will be changed to 0
    for row=smallest_row:biggest_row
        for col=smallest_col:biggest_col
            if package(row,col) ~= -1
                result = 0;
            end
        end
    end
    
end