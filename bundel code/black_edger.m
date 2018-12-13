function blackEdged = black_edger(img)
    % Function which the outer one pixel in both dimensions of an image
    % black.
    % Used to see the edge of each individual package in the combined one.

    img_size = size(img);
    
    for row = 1:img_size(1)
        for col = 1:img_size(2)
            if row == 1 || row == img_size(1) || col == 1 || col == img_size(2)
                img(row,col) = 1;
            end
        end
    end
    
    blackEdged = img;

end