function new_package = package_appender(package, object, smallest_row, smallest_col)
    % Appends the package with the given object on the given postion.
    % If the object dimensions exceed the dimensions of the package, a new
    % one will be created which wil fit both. Empty spaces in the package
    % are denoted by a value of -1.
    mat_size = size(package);
    object_size = size(object);
    
    
    % The old package can fit the object.
    if mat_size(1) >= object_size(1) + smallest_row && mat_size(2) >= object_size(2) + smallest_col
        % The package is appended with the object at the given position.
        for row = smallest_row:(object_size(1)+smallest_row-1)
            for col = smallest_col:(object_size(2)+smallest_col-1)
                package(row,col) = object(row - smallest_row + 1, col - smallest_col + 1);               
            end
        end
        new_package = package;
        
        
    % The old package can't fit the object horizontally.
    elseif mat_size(1) >= object_size(1) + smallest_row && mat_size(2) < object_size(2) + smallest_col
        % Create a new package which can fit the object.
        new_package =  ones(mat_size(1), object_size(2) + smallest_col)*-1;
        
        % Fill the new package with the old one.
        for row = 1:mat_size(1)
            for col = 1:mat_size(2)
                new_package(row,col) = package(row,col);
            end
        end
        
        % The package is appended with the object at the given position.
        for row = smallest_row:(object_size(1)+smallest_row-1)
            for col = smallest_col:(object_size(2) + smallest_col-1)
                new_package(row,col) = object(row - smallest_row+1, col - smallest_col+1);
            end
        end
        
        
    % The old package can't fit the object vertically.    
    elseif mat_size(1) < object_size(1) + smallest_row && mat_size(2) >= object_size(2) + smallest_col
        % Create a new package which can fit the object.
        new_package =  ones(object_size(1) + smallest_row, mat_size(2))*-1;
        
        % Fill the new package with the old one.
        for row = 1:mat_size(1)
            for col = 1:mat_size(2)
                new_package(row,col) = package(row,col);
            end
        end
        
        % The package is appended with the object at the given position.
        for row = smallest_row:(object_size(1) + smallest_row-1)
            for col = smallest_col:(object_size(2)+smallest_col-1)
                new_package(row,col) = object(row - smallest_row+1, col - smallest_col+1);
            end
        end
        
        
    % The old package can't fit the object both vertically and horizontally.  
    else
        % Create a new package which can fit the object.
        new_package =  ones(object_size(1) + smallest_row, object_size(2) + smallest_col)*-1;
        
        % Fill the new package with the old one.
        for row = 1:mat_size(1)
            for col = 1:mat_size(2)
                new_package(row,col) = package(row,col);
            end
        end
        
        % The package is appended with the object at the given position.
        for row = smallest_row:(object_size(1) + smallest_row-1)
            for col = smallest_col:(object_size(2) + smallest_col-1)
                new_package(row,col) = object(row - smallest_row + 1, col - smallest_col + 1);
            end
        end
    end
    
    
end