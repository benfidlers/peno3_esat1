clearvars
img = imread('kinect/kinect3.png');
A = greyscale(img); % Convert image to grayscale
A = gaussian_blur(mean_blur(A)); % Filters
subplot(2,2,1), imshow(A, []); % Plot
title('Greyscale');
B = threshold(A); % Threshold image
C = invertornot(B); % Check if threshold is OK or needs to be inverted
%subplot(2,2,2), imshow(B, []);
%title('Output after thresholding');

%D = edge2_detect(C, 3);
%subplot(2,2,4), imshow(D), []);
%title('Output after edge detection');

first_edge_detect = edge_detect(A);
subplot(2,2,3), imshow(first_edge_detect, []);
title('Output after laplacian edge detection (with original image)');%
without_noise_removal = threshold_edge(first_edge_detect);
subplot(2,2,2), imshow(without_noise_removal, []);
title('llkmlkj');
subplot(2,2,4), imshow(noise_deletion(without_noise_removal, 3), []);
title('Output after thresholding edge detection');


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

function thresholded_img = threshold_edge(img)
    threshold_value = 2;
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
    
    %% Horizontaal laten checken voor edges.
    previous_value = img(1,1);
    for row=1:MAX_ROW  % We gaan elke rij af
        for col=1:MAX_COLUMN
            i=1;
            flag = 0;
            if img(row, col) == 1 && previous_value == 0  
                %% DUS: Het begin van een object. (hele tijd wit, nu zwart), flag voor intolerantie controle aanzetten.
                flag = 1;
            elseif img(row, col) == 0 && previous_value == 1
                 %% DUS: Het einde van een object (hele tijd zwart, nu wit), flag voor intolerantie controle aanzetten.
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
            else
                edge2(row, col) = 0;
            end
            
            previous_value = img(row, col);
        end
        
    previous_value = img(row,1);
    end
    
    %% Verticaal controleren op edges.
    previous_value = img(1,1);
    for col=1:MAX_COLUMN  % We gaan elke kolom af
       for row=1:MAX_ROW
            i=1;
            flag = 0;
            if img(row, col) == 1 && previous_value == 0  
                %% DUS: Het begin van een object. (hele tijd wit, nu zwart), flag voor intolerantie controle aanzetten.
                %value = 1;
                flag = 1;
            elseif img(row, col) == 0 && previous_value == 1
                 %% DUS: Het einde van een object (hele tijd zwart, nu wit), flag voor intolerantie controle aanzetten.
                %value = 1;
                flag = 1;
            end
            
            %% Intolerantie controle
            while i <= intolerance && flag && row+i <= MAX_ROW
                if img(row-1+i,col) ~= img(row+i,col)
                    flag = 0;
                end
                i=i+1;
            end
            
            % Enkel nullen overriden
            if flag
                edge2(row, col) = 1;
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
    threshold_value = 255/2;
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


