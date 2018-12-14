function objects = get_objects(updated_corner_points, original_img, regrouped)
    % Returns a list of all objects in the given image counted by the
    % counting system.
    % Each object is placed in the smallest possible package.
    % The list is sorted from largest to smallest object. 
   
    % Initializing variables
    mat_size = size(updated_corner_points);
    groups = mat_size(2);
    unsorted_objects = {};
    last_added_img = 1;
    
    % Gathering every group.
    for groupnb=1:groups
        
        % Updated_cornern_points can contain zeros as corner points, these
        % aren't valid.
        if updated_corner_points(1,groupnb) ~= 0
            
            % Getting the object cut out of the full image.
            [objAlone, min_row_i, min_col_i, max_row_i, max_col_i,] = single_object(original_img,updated_corner_points, groupnb);
            obj_points = [min_row_i; min_col_i; max_row_i; max_col_i];
        
            % Making the whole image white except the object itself.
            objAlone = object_highlighter(objAlone, obj_points, regrouped, groupnb);
            % Fitting the object in the smallest possible package
            img = boundaryBoxedImgRotator(objAlone);
            
            % Adding the object to the list of objects
            unsorted_objects{last_added_img} = img;
            last_added_img = last_added_img + 1;
        end
    end
    
    % Sort the list of objects
    objects = imgs_InsertionSort(unsorted_objects);
    
end