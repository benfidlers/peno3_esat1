function [result, new_nb_of_groups] = remove_box_edge(corner_points, nb_of_groups)
    mat_size = size(corner_points);
    groups = mat_size(2);
    surfaces = zeros(groups); % Every column is a group, the value is the distance
    
    for i=1:groups
        
        min_row = corner_points(1,i);
        min_col = corner_points(2,i) ;
        max_row = corner_points(3,i);
        max_col = corner_points(4,i);
        
        surfaces(i) = (max_row - min_row) * (max_col - min_col);
    end
    
    %Now find biggest surface
    [max_value, max_col] = max(surfaces);
    for i=1:4
        % Set the coordinates of the outer points to 0
        corner_points(i, max_col) = 0;
    end
    
    result = corner_points;
    new_nb_of_groups = nb_of_groups-1;
end