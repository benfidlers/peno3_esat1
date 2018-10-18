clearvars
img = imread('kinect/foto RGB 4.png');
%% Method 3: First greyscale, then trheshold ivm background, than edge detection
A = greyscale(img); % Convert image to grayscale
A = symImgCrop(A, 50); % CROP IMAGE SO IT's the same size.
A = gaussian_blur(mean_blur(A)); % Filters

bg = imread('kinect/foto RGB 1.png');
bg = greyscale(bg); % Convert image to grayscale
bg = symImgCrop(bg, 50); % CROP IMAGE SO IT's the same size.
bg = gaussian_blur(mean_blur(bg)); % Filters

B = threshold_ivm_background(A, bg);
C = invertornot(B); % Check if threshold is OK or needs to be inverted
D = ~edge2_detect(C, 3);
E = remove_boundary(D, 25);
subplot(2,2,1), imshow(A, []);
title("Input (after blur)");
subplot(2,2,2), imshow(C, []);
title("After thresholding");
subplot(2,2,3), imshow(E, []);
title("After edge detection & boundary removed");
%% Method 1: First greyscale, then blur, then threshold, then edge detection.
A = greyscale(img); % Convert image to grayscale
A = symImgCrop(A, 50); % CROP IMAGE SO IT's the same size.
A = gaussian_blur(mean_blur(A)); % Filters
B = threshold(A); % Threshold image
C = invertornot(B); % Check if threshold is OK or needs to be inverted
D = ~edge2_detect(C, 3);
E = remove_boundary(D, 25);
subplot(2,2,1), imshow(A, []);
title("Input (after blur)");
subplot(2,2,2), imshow(C, []);
title("After thresholding");
subplot(2,2,3), imshow(E, []);
title("After edge detection & boundary removed");


%% Method 2: First greyscale, then blur, then edge detect then threshold and then noise removal
first_edge_detect = edge_detect(A);
without_noise_removal = threshold_edge(remove_boundary(first_edge_detect, 15));
with_noise_removal = noise_deletion(without_noise_removal, 3);
subplot(2,2,1), imshow(A, []);
title("Input (after blur)");
subplot(2,2,2), imshow(first_edge_detect, []);
title("After edge detection");
subplot(2,2,3), imshow(without_noise_removal, []);
title("Threshold without noise removal")
subplot(2,2,4), imshow(with_noise_removal, []);
title("Threshold with noise removal");

function result = threshold_ivm_background(img, bg)
    % DIMENSIONS MUST MATCH
    % Compare pixel at img(row, col) with bg(row, col).
    % if bg(row, col) - D <= img(row, col) <= bg(row, col) + D
    %       The pixels are defined as background!! (= white)
    
    D = 10;
    WHITE = 1;
    BLACK = 0;
    
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    result = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
           if img(row, col) <= bg(row, col) + D && img(row, col) >= bg(row, col) - D
               % Classified as background
               result(row, col) = WHITE;
           else
               % Not background
               result(row, col) = BLACK;
           end
        end
    end
    
end

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
end

function nes = noise_deletion(img,window)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    side = floor(window/2);
    disp(floor((window^2)/2)+1);
    nes = img;
    
    for col=side+1:MAX_COLUMN-side
        for row=side+1:MAX_ROW-side
            list=zeros(window);
            q=1;
            for i=-side:side
                for j=-side:side
                    list(q) = img(row+i,col+j);
                    q = q+1;
                end
            end
            list=sort(list);
            nes(row,col) = list(floor((window^2)/2)+1);
        end
    end
end

function result = remove_boundary(img, remove_size)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    result = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
           if row < remove_size || col < remove_size || row > (MAX_ROW - remove_size) || col > (MAX_COLUMN - remove_size)
               % Inside boundary ==> needs to be white (= 1)
               result(row, col) = 1;
           else
               result(row, col) = img(row, col);
           end
           
        end
    end
end

function thresholded_img = threshold_edge(img)
    threshold_value = 2;
    %most_occuring =mode(img) +100;
    %threshold_value = most_occuring(1);
   
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    THICKNESS = 10;
    
    thresholded_img = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            if img(row, col) > threshold_value
                value = 0;
                for i=1:THICKNESS
                    % Create thicker edges (edges of THICKNESS pixels thick)
                    if (col - i) > 0
                        thresholded_img(row, col-i) = 0;
                    end
                end
            else
                value = 1;
            end
            thresholded_img(row, col) = value;
        end
    end
end

function threshold_value_calculated = determine_threshold_value(img)
    % By looking at the edge of the figure, determine background color.
    % This color needs to be filtered out. 
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    number_of_edge_layers = 3; %3 rijen boven & onder en 3 kolommen links en rechts
    values = 0;
    counts = 0;
    for row=1:MAX_ROW  % We gaan elke rij af
        for col=1:MAX_COLUMN
            if col <= number_of_edge_layers || row <= number_of_edge_layers || col >= (MAX_COLUMN - number_of_edge_layers) || row >= (MAX_ROW - number_of_edge_layers)
                % Dit zijn de cellen tussen de rand, tel alle waarden op en
                % neem gemiddelde.
                values = values + img(row, col);
                counts = counts + 1;
            end
        end
    end
    
    threshold_value_calculated = values / counts;
    disp(threshold_value_calculated)
end

function mean_blurred = mean_blur(img)
    mean = (1/9) * [ 1 1 1; 1 1 1; 1 1 1];
    mean_blurred = conv2(img, mean);
end

function gaussian_blurred = gaussian_blur(img)
    gaussian = (1/159) * [2 4 5 4 2; 4 9 12 9 4; 5 12 15 12 5; 4 9 12 9 4; 2 4 5 4 2;]
    gaussian_blurred = conv2(img, gaussian);
end

function edge2 = edge2_detect(img,intolerance)
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    edge2 = zeros(MAX_ROW,MAX_COLUMN,1);
    THICKNESS = 10;
    
    % Horizontaal laten checken voor edges.
    previous_value = img(1,1);
    for row=1:MAX_ROW  % We gaan elke rij af
        for col=1:MAX_COLUMN
            i=1;
            flag = 0;
            if img(row, col) == 1 && previous_value == 0  
                % DUS: Het begin van een object. (hele tijd wit, nu zwart), flag voor intolerantie controle aanzetten.
                flag = 1;
            elseif img(row, col) == 0 && previous_value == 1
                 % DUS: Het einde van een object (hele tijd zwart, nu wit), flag voor intolerantie controle aanzetten.
                flag = 1;
            end
            
            %%Intolerantie controle
            while i <= intolerance && flag && col+i <= MAX_COLUMN
                if img(row,col-1+i) ~= img(row,col+i)
                    flag = 0;
                end
                i=i+1;
            end
            
            % Eertse maal edgematrix vullen
            if flag
                edge2(row, col) = 1;
                
                for i=1:THICKNESS
                    % Create thicker edges (edges of THICKNESS pixels thick)
                    if (col - i) > 0
                        edge2(row, col-i) = 1;
                    end
                end
            else
                edge2(row, col) = 0;
            end
            
            previous_value = img(row, col);
        end
        
    previous_value = img(row,1);
    end
    
    % Verticaal controleren op edges.
    previous_value = img(1,1);
    for col=1:MAX_COLUMN  % We gaan elke kolom af
       for row=1:MAX_ROW
            i=1;
            flag = 0;
            if img(row, col) == 1 && previous_value == 0  
                % DUS: Het begin van een object. (hele tijd wit, nu zwart), flag voor intolerantie controle aanzetten.
                %value = 1;
                flag = 1;
            elseif img(row, col) == 0 && previous_value == 1
                 %DUS: Het einde van een object (hele tijd zwart, nu wit), flag voor intolerantie controle aanzetten.
                %value = 1;
                flag = 1;
            end
            
            % Intolerantie controle
            while i <= intolerance && flag && row+i <= MAX_ROW
                if img(row-1+i,col) ~= img(row+i,col)
                    flag = 0;
                end
                i=i+1;
            end
            
            % Enkel nullen overriden
            if flag
                edge2(row, col) = 1;
                for i=1:THICKNESS
                    % Create thicker edges (edges of THICKNESS pixels thick)
                    if (row - i) > 0
                        edge2(row - i, col) = 1;
                    end
                end
            end
            
            previous_value = img(row, col);
       end
        
    previous_value = img(1,col);
    end
    
end

function edge = edge_detect(img)
    klaplace=[0 -1 0; -1 4 -1;  0 -1 0];             % Laplacian filter kernel
    edge=conv2(img,klaplace);                         % convolve test img with
end

function inverse = invertornot(img)
    gem = mode(img);
    disp(gem(1))
    if gem(1) == 1
        inverse = ~img;
    else 
        inverse = img;
    end
end

function thresholded_img2 = threshold2(img)
    threshold_value = determine_threshold_value(img);
    threshold_band = 220;
   
    matrix_size = size(img);
    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);

    thresholded_img2 = zeros(MAX_ROW,MAX_COLUMN,1);
    for row=1:MAX_ROW
        for col=1:MAX_COLUMN
            if img(row, col) > (threshold_value - threshold_band) && img(row, col) < (threshold_value + threshold_band)
                value = 0;
            else
                value = 1;
            end
            thresholded_img2(row, col) = value;
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
            grey(row, col) = 0.2989 * R + 0.5870 * G + 0.1140 * B ;  
            %These are two methods for grayscaling.
            %grey(row, col) = (R + G + B)/3;
        end
    end
end

function thresholded_img = threshold(img)
    threshold_value = 125;
    %most_occuring =mode(img) +100;
    %threshold_value = most_occuring(1);
   
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


