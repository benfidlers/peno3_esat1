%% Extract features
[labeled, numObjects] = bwlabel(Iopenned, 4);
stats = regionprops(labeled,'Eccentricity', 'Area', 'BoundingBox');
areas = [stats.Area];
eccentricities = [stats.Eccentricity];
boundingbox = [stats.BoundingBox];

%% Use feature analysis to count objects
idxOfObjects = find(eccentricities);
statsDefects = stats(idxOfObjects);

figure, imshow(I);
for idx = 1 : length(idxOfObjects)
    h = rectangle ('Position', statsDefects(idx).BoundingBox);
    set(h,'EdgeColor',[.75 0 0]);
    set(h,'LineWidth',2);
end

title(['There are ', num2str(numObjects), ' objects in the picture']);
