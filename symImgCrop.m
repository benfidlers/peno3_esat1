<<<<<<< HEAD
function cropped_img = symImgCrop(img,cutted_edge_size)
    original_img_size = size(img);
    original_max_row = original_img_size(1);
    original_max_column = original_img_size(2);
    cropped_img = zeros(original_max_row - 2*cutted_edge_size,original_max_column - 2*cutted_edge_size,1);
    
    for row=cutted_edge_size:original_max_row - cutted_edge_size
        for col=cutted_edge_size:original_max_column - cutted_edge_size
            cropped_img(row - cutted_edge_size + 1,col - cutted_edge_size + 1) = img(row,col);
        end
    end
=======
function cropped_img = symImgCrop(img,cutted_edge_size)
    original_img_size = size(img);
    original_max_row = original_img_size(1);
    original_max_column = original_img_size(2);
    cropped_img = zeros(original_max_row - 2*cutted_edge_size,original_max_column - 2*cutted_edge_size,1);
    
    for row=cutted_edge_size:original_max_row - cutted_edge_size
        for col=cutted_edge_size:original_max_column - cutted_edge_size
            cropped_img(row - cutted_edge_size + 1,col - cutted_edge_size + 1) = img(row,col);
        end
    end
>>>>>>> f57d7bae21cb23a358a76864756de25e897d8715
end