<<<<<<< HEAD

img = imread('test2.png');
A = greyscale(img);
B = threshold(img);
%imshow(~B, []) %~for inverting.
%imshow(B, [])
C = edge_detect(B);
%imshow(C, [])
subplot(1,2,1), imshow(C, []);
subplot(1,2,2), imshow(B, []);


function edge = edge_detect(img)
    klaplace=[0 -1 0; -1 4 -1;  0 -1 0];             % Laplacian filter kernel
    edge=conv2(img,klaplace);                         % convolve test img with
end

function thresholded_img = threshold(img)
    threshold_value = 255/2 + 25;
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    thresholded_img = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            if img(row, col) > threshold_value
                value = 0;
            else
                value = 1;
            end
            thresholded_img(row, col) = value;
        end
    end
end

function grey = greyscale(img)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    grey = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            R = img(row, col, 1);
            G = img(row, col, 2);
            B = img(row, col, 3);
            %grey(row, col) = 0.2989 * R + 0.5870 * G + 0.1140 * B ;  
            %These are two methods for grayscaling.
            grey(row, col) = (R + G + B)/3;
        end
    end
  
end
=======

img = imread('test2.png');
A = greyscale(img);
B = threshold(img);
%imshow(~B, []) %~for inverting.
%imshow(B, [])
C = edge_detect(B);
%imshow(C, [])
subplot(1,2,1), imshow(C, []);
subplot(1,2,2), imshow(B, []);


function edge = edge_detect(img)
    klaplace=[0 -1 0; -1 4 -1;  0 -1 0];             % Laplacian filter kernel
    edge=conv2(img,klaplace);                         % convolve test img with
end

function thresholded_img = threshold(img)
    threshold_value = 255/2 + 25;
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    thresholded_img = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            if img(row, col) > threshold_value
                value = 0;
            else
                value = 1;
            end
            thresholded_img(row, col) = value;
        end
    end
end

function grey = greyscale(img)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    grey = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            R = img(row, col, 1);
            G = img(row, col, 2);
            B = img(row, col, 3);
            %grey(row, col) = 0.2989 * R + 0.5870 * G + 0.1140 * B ;  
            %These are two methods for grayscaling.
            grey(row, col) = (R + G + B)/3;
        end
    end
  
end
>>>>>>> f57d7bae21cb23a358a76864756de25e897d8715
