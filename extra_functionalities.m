%% Extract features
[labeled, numObjects] = bwlabel(Image_black);
stats = regionprops(labeled,'Eccentricity', 'Area', 'BoundingBox');
eccentricities = [stats.Eccentricity];

%% Use feature analysis to count objects
idxOfObjects = find(eccentricities);

figure, imshow(Image);
hold on;
for idx = 1 : length(idxOfObjects)
    h = rectangle ('Position', stats(idx).BoundingBox);
    set(h,'EdgeColor',[.75 0 0]);
    set(h,'LineWidth',2);
end

title(['There are ', num2str(numObjects), ' objects in the picture']);
hold off;

%% Draw boundaries
B = bwboundaries(Image_black);
imshow(Image);
hold on;
visboundaries(B);
hold off;
