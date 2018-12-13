function rotated = rotator(img, rads)
    % Calculating the size of the padding matrix
    [ROWS, COLS] = size(img); 
    diagonal = sqrt(ROWS^2 + COLS^2); 
    rowPad = ceil(diagonal - ROWS) + 2;
    colPad = ceil(diagonal - COLS) + 2;
    
    % Creating the paddding matrix and filling it whith the original image
    % in the middle and everything else white.
    padding_mat = ones(ROWS+rowPad, COLS+colPad)*255;
    padding_mat(ceil(rowPad/2):(ceil(rowPad/2)+ROWS-1),ceil(colPad/2):(ceil(colPad/2)+COLS-1)) = img;

    % Calcularting the mid coordinates of the matrices.
    padding_size = size(padding_mat);
    midx=ceil((padding_size(2)+1)/2);
    midy=ceil((padding_size(1)+1)/2);
    
    % Creating the rotated image
    rotated=ones(padding_size)*255;
    rotSize = size(rotated);
    
    % For each position in the rotated image get the value out of the
    % padding matrix which corresponds with the position if it were rotated
    % by the given angle.
    for i=1:rotSize(1)
        for j=1:rotSize(2)

            x = (i-midx)*cos(rads)+(j-midy)*sin(rads);
            x=round(x)+midx;
            y=-(i-midx)*sin(rads)+(j-midy)*cos(rads);
            y=round(y)+midy;

            if x >= 1 && y >= 1 && x <= padding_size(2) && y <= padding_size(1)
                rotated(i,j)=padding_mat(x,y);        
            end

        end
    end
end