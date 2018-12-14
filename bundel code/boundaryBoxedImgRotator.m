function rotated_objec = boundaryBoxedImgRotator(boxedObjec)
    % Bissection method based algorithm to find the best fitting
    % package/boundary box 

    % Initialize variables
    lower_rad = 0;
    upper_rad = pi*3/8;
    lower_dim = packaged_objec(boxedObjec, lower_rad, 1);
    upper_dim = packaged_objec(boxedObjec, upper_rad, 1);

    i = 0;    
    while i < 10
        % Calculating pivot values
        pivot_rad = (upper_rad-lower_rad)/2+lower_rad;
        pivot_dim = packaged_objec(boxedObjec, pivot_rad, 1);
        
        % Comparing the lower and upper points and changing their values
        % accordingly.
        if lower_dim <= upper_dim
           upper_rad = pivot_rad;
           upper_dim = pivot_dim;
        else
            lower_rad = pivot_rad;
            lower_dim = pivot_dim;
        end
        i=i+1;
    end
        % Returning the the rotated image for the elevnth pivot.
        rotated_objec = packaged_objec(boxedObjec,(abs((upper_rad-lower_rad)/2)+min(upper_rad,lower_rad)),0);

end