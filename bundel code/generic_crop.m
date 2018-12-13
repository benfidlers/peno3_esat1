function img_crop = generic_crop(img, fourp)
    % A function which crops the given image so that the edges are
    % definened by the four point given in fourp.
    mat_size = size(fourp);
    groups = mat_size(2);

    for i=1:groups
        if fourp(1,i)~=0
        MIN_ROW = fourp(1,i);
        MIN_COL = fourp(2,i);
        MAX_ROW = fourp(3,i);
        MAX_COL = fourp(4,i);
        end
    end

    img_crop = zeros(MAX_ROW-MIN_ROW+1,MAX_COL-MIN_COL+1,1);
        for row = MIN_ROW:MAX_ROW
            for col = MIN_COL:MAX_COL

                img_crop(row - MIN_ROW + 1,col - MIN_COL + 1,1) = img(row,col);
            end
        end

end