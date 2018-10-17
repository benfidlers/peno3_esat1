%% Extract features
[labeled, numObjects] = bwlabel(Image, 4);
stats = regionprops(labeled,'Eccentricity', 'Area', 'BoundingBox');
areas = [stats.Area];
eccentricities = [stats.Eccentricity];
boundingbox = [stats.BoundingBox];

%% Use feature analysis to count objects
idxOfObjects = find(eccentricities);
statsDefects = stats(idxOfObjects);

figure, imshow(I);
hold on;
for idx = 1 : numObjects
    h = rectangle ('Position', statsDefects(idx).BoundingBox);
    set(h,'EdgeColor',[.75 0 0]);
    set(h,'LineWidth',2);
    hold on;
end

title(['There are ', num2str(numObjects), ' objects in the picture']);

hold off;
