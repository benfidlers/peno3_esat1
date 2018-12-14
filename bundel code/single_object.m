function [objAlone, min_row_group, min_col_group, max_row_group, max_col_group] = single_object(img, corner_points, groupnb)    
    % Returns a part of the image which fully contains the group associated with the given group number.
    
    min_row_group = corner_points(1,groupnb);
    min_col_group = corner_points(2,groupnb);
    max_row_group = corner_points(3,groupnb);
    max_col_group = corner_points(4,groupnb);
    % Crop around the group
    objAlone = simon_crop(img, min_row_group,min_col_group,max_row_group,max_col_group);
end