function sorted_imgs = imgs_InsertionSort(listed_imgs)
    % Insurtion sort based fucntion to sort a list of images from biggest
    % to smallest surface area.

    listSize = size(listed_imgs);
        
    % Iterate over every image
    for i=1:listSize(2)
        
        % Calculating the surface size of images i
        img_i = listed_imgs{i};
        img_i_sizes = size(img_i);
        img_i_surface_size = img_i_sizes(1)*img_i_sizes(2);
        
       % Run through the all images before i
       for j=1:i 
           
           % Calculating the surface size of image j
            img_j = listed_imgs{j};
            img_j_sizes = size(img_j);
            img_j_surface_size = img_j_sizes(1)*img_j_sizes(2);
            
            % Swap the two if the image i is bigger than image j
            if img_i_surface_size > img_j_surface_size
                temp = listed_imgs{j};
                listed_imgs{j} = listed_imgs{i};
                listed_imgs{i} = temp;
                img_i_surface_size = img_j_surface_size;
            end
            
        end
    end

    sorted_imgs = listed_imgs;
end