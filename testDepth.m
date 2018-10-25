%processing the image using the depthsensor


%treshold values
min_tresh = 30;
max_tresh = 500;

% get image from depth sensor
depth = getsnapshot(depthVid);

%run the sobel operator
shapes = sobel_operator(depth);

%run the treshold filter
shapes = treshold(shapes, min_tresh, max_tresh);

%look at the result
image(depth);

function shapes = sobel_operator(img)

    X = img;
    Gx = [1 +2 +1; 0 0 0; -1 -2 -1]; Gy = Gx';
    temp_x = conv2(X, Gx, 'same');
    temp_y = conv2(X, Gy, 'same');
    shapes = sqrt(temp_x.^2 + temp_y.^2);
end 

function tresholded = treshold(img, min_tresh, max_tresh)

    matrix_size = size(img);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    for row = 1 : MAX_ROW        
        for col = 1: MAX_COLUMN
           if (img(row, col) > min_tresh) && (img(row, col)< max_tresh)
               img(row, col) = 1;
           else
               img(row, col) = 0;
           end
        end
    end
    tresholded = img;
end


        