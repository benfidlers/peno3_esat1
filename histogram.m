%% Read image
I = imread('shapes.jpg');
imshow(I);

%% Rgb space
rmat= I(:,:,1);
gmat= I(:,:,2);
bmat= I(:,:,3);

subplot(2,2,1), imshow(rmat);
title('Red plane');
subplot(2,2,2), imshow(gmat);
title('Green plane');
subplot(2,2,3), imshow(bmat);
title('Blue plane');
subplot(2,2,4), imshow(I);
title('Original image');

%% Histogram
nb_bins = 2;
width_bins = 256/nb_bins;

h1 = histogram(rmat,nb_bins);
hold on;
h2 = histogram(gmat,nb_bins);
h3 = histogram(bmat,nb_bins);

biggest_bin_red = 0;
biggest_bin_green = 0;
biggest_bin_blue = 0;
for i = 1:nb_bins
    nb_elems_red = h1.Values;
    nb_elems_green = h2.Values;
    nb_elems_blue = h3.Values;
    if nb_elems_red(i) > biggest_bin_red
        biggest_bin_red = nb_elems_red(i);
        bin_red=i;
    end
    if nb_elems_green(i) > biggest_bin_green
        biggest_bin_green = nb_elems_green(i);
        bin_green=i;
    end
    if nb_elems_blue(i) > biggest_bin_blue
        biggest_bin_blue = nb_elems_blue(i);
        bin_blue=i;
    end
end
colour_value_red_min = (bin_red-1)*width_bins;
colour_value_red_max = bin_red*width_bins;
colour_value_green_min = (bin_green-1)*width_bins;
colour_value_green_max = bin_green*width_bins;
colour_value_blue_min = (bin_blue-1)*width_bins;
colour_value_blue_max = bin_blue*width_bins;
disp(colour_value_red_min);
disp(colour_value_red_max);

%% Convert to black and white
%red
matrix_size = size(rmat);
MAX_ROW = matrix_size(1);
MAX_COLUMN = matrix_size(2);
rmat_bw = zeros(MAX_ROW,MAX_COLUMN);
for row=1:MAX_ROW
    for col=1:MAX_COLUMN
        if (colour_value_red_min < rmat(row,col)) && (rmat(row,col) < colour_value_red_max)
            rmat_bw(row,col) = 255;
        else
            rmat_bw(row,col) = 0;
        end
    end
end

%green
matrix_size = size(gmat);
MAX_ROW = matrix_size(1);
MAX_COLUMN = matrix_size(2);
gmat_bw = zeros(MAX_ROW,MAX_COLUMN);
for row=1:MAX_ROW
    for col=1:MAX_COLUMN
        if (colour_value_green_min < gmat(row,col)) && (gmat(row,col) < colour_value_green_max)
            gmat_bw(row,col) = 255;
        else
            gmat_bw(row,col) = 0;
        end
    end
end

%blue
matrix_size = size(bmat);
MAX_ROW = matrix_size(1);
MAX_COLUMN = matrix_size(2);
bmat_bw = zeros(MAX_ROW,MAX_COLUMN);
for row=1:MAX_ROW
    for col=1:MAX_COLUMN
        if (colour_value_blue_min < bmat(row,col)) && (bmat(row,col) < colour_value_blue_max)
            bmat_bw(row,col) = 255;
        else
            bmat_bw(row,col) = 0;
        end
    end
end

Isum = (rmat_bw & bmat_bw & gmat_bw);
Icomp = imcomplement(Isum);

%plot
subplot(2,2,1), imshow(rmat_bw);
title('Red plane');
subplot(2,2,2), imshow(gmat_bw);
title('Green plane');
subplot(2,2,3), imshow(bmat_bw);
title('Blue plane');
subplot(2,2,4), imshow(Icomp);
title('Sum');

%% Fill in holes
Ifilled = imfill(Icomp,'holes');
imshow(Ifilled);

%% Erasing noise
%se = strel('disk',5);
%Iopenned = imopen(Ifilled, se);
%imshow(Iopenned);

%% Extract features
Iregion = regionprops(Iopenned, 'centroid');
[labeled, numObjects] = bwlabel(Iopenned, 4);
stats = regionprops(labeled,'Eccentricity', 'Area', 'BoundingBox');
areas = [stats.Area];
eccentricities = [stats.Eccentricity];
boundingbox = [stats.BoundingBox];

%% Use feature analysis to count objects
idxOfObjects = find(eccentricities);
statsDefects = stats(idxOfObjects);

figure, imshow(I);
hold on;
for idx = 1 : length(idxOfObjects)
    h = rectangle ('Position', statsDefects(idx).BoundingBox);
    set(h,'EdgeColor',[.75 0 0]);
    hold on;
end

if idx > 10
    title(['There are ', num2str(numObjects), ' objects in the picture']);
else 
    title(['There are ', num2str(numObjects), ' objects in the picture']);
end
hold off;
