function boxedDim = packaged_objec(boxedObjec, angle, flag)
    % Function which will return either the dimensions of the new boundary
    % box after rotating the image (if flag == 1) or returns the whole
    % image after it has been cropped to the new boundary box of the
    % rotated object (if flag == 0)

    % Initializing constants
    THRESHOLD_VALUE = 2;
    MIN_ROW_LINES_BETWEEN_GROUPS = 10;
    SAME_PIXELS_SEARCH_GRID_SIZE = 10;
    GROUP_SEARCH_GRID_SIZE = 15; 
    SURROUDING_PERCENTAGE = 10;
    MIN_NB_SURROUNDING_PIXELS = floor((SAME_PIXELS_SEARCH_GRID_SIZE * 2)^2 * SURROUDING_PERCENTAGE/100);

    % Rotate the image
    rotatedObj = rotator(boxedObjec, angle);
    
    % Finding the object in the rotated image.
    rotatedObj = gaussian_blur(mean_blur(rotatedObj));    
    first_edge_detect = edge_detect(rotatedObj);
    without_noise_removal = threshold_edge(remove_boundary(first_edge_detect, 15), THRESHOLD_VALUE); 
    [grouped, nb_of_groups] = group(~without_noise_removal, SAME_PIXELS_SEARCH_GRID_SIZE, GROUP_SEARCH_GRID_SIZE, MIN_NB_SURROUNDING_PIXELS); 
    [regrouped, nb_of_groups2] = regroup(grouped, nb_of_groups, MIN_ROW_LINES_BETWEEN_GROUPS);
    corner_points = find_corner_points(regrouped, nb_of_groups);
    [updated_corner_points, nb_of_groups3] = remove_corner_points_within_corner_points(corner_points, nb_of_groups2); 
    
    % Checking whether one object is found
    if nb_of_groups3 == 1 
        
        cropped_rotated_boxedObjec = generic_crop(rotatedObj,updated_corner_points);
        % imshow(cropped_rotated_boxedObjec,[]);
        
       
        if flag == 1
            % Return the new boundary box dimensions.
            matSize = size(cropped_rotated_boxedObjec);
            boxedDim = matSize(1)*matSize(2);
        elseif flag == 0
            % return the whole image.
            boxedDim = cropped_rotated_boxedObjec;
        end
        
    % If there are multiple objects, no rotated image is returned
    else
        disp("not one object");
        boxedDim = 0;
    end
end