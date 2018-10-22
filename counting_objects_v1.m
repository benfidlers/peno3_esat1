%% Read image
I = imread('test2.png');
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

%% Convert to black and white
rlevel = 0.5;
glevel = 0.5;
blevel = 0.5;

rthresh = imbinarize(rmat,'adaptive');
%rthresh = im2bw(rmat,rlevel);
gthresh = imbinarize(gmat,'adaptive');
%gthresh = im2bw(gmat,glevel);
bthresh = imbinarize(bmat,'adaptive');
%bthresh = im2bw(bmat,blevel);
Isum = (rthresh & gthresh & bthresh);

subplot(2,2,1), imshow(rthresh);
title('Red plane');
subplot(2,2,2), imshow(gthresh);
title('Green plane');
subplot(2,2,3), imshow(bthresh);
title('Blue plane');
subplot(2,2,4), imshow(Isum);
title('Sum');

%% Complement of image
%Icomp = imcomplement(Isum);
%imshow(Icomp);

%% Fill in holes
Ifilled = imfill(Isum,'holes');
imshow(Ifilled);

%% Erasing noise
se = strel('disk',10);
Iopenned = imopen(Ifilled, se);
imshow(Iopenned);

%% Extract features
[labeled, numObjects] = bwlabel(Iopenned, 4);

%% Use feature analysis to count objects
figure, imshow(I);
title(['There are ', num2str(numObjects), ' objects in the picture']);