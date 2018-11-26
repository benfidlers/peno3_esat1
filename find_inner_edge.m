clearvars

h=900;
height_box= 400;

min_tresh=400;
max_tresh=h+50;

MAX_I=20;

distance_of_box=possible_distances(h,height_box,MAX_I);
%thresholded = threshold(cropped_matrix, min_thresh, max_thresh);
%result= inner_edge(cropped_matrix);
%disp(distance_of_box);



function distance_of_box = possible_distances(h,height_box,MAX_I)
    
    a=zeros(1,MAX_I*2+1);
    for i=1:MAX_I+1
        a(i)=h-height_box +i-1;
        a(i+MAX_I)=h-height_box-i+1;
        
        
    end
    distance_of_box=a;

end
              

function thresholded = threshold(cropped_matrix, min_thresh, max_thresh)

    matrix_size = size(cropped_matrix);

    MAX_ROW = matrix_size(1);

    MAX_COLUMN = matrix_size(2);
    
    for row = 1 : MAX_ROW        
        for col = 1: MAX_COLUMN
           if (cropped_matrix(row, col) < min_thresh) || (cropped_matrix(row, col)> max_thresh)
               cropped_matrix(row, col) = -20;
           end
        end
    end
    thresholded = img;
end

    
 function result= inner_edge(cropped_matrix,distance_of_box)
    matrix_size = size(cropped_matrix);

    MAX_ROW = matrix_size(1);
    MAX_COLUMN = matrix_size(2);
    
    a=zeros(1,MAX_ROW);
    b=zeros(1,MAX_ROW);
    
    
    for row=1:MAX_ROW
        a(row)= max(cropped_matrix(row,:)); %each pos contains max elem in that row
        b(row)= min(cropped_matrix(row,:)); %each pos contains min elem in that row
    end
    ultimate_max=max(a);

    
    
    if (ultimate_max<h+40) || (ultimate_max>h-40)
        disp("wrong ultimate height")    
    end
    
    
    
    for row = 1:MAX_ROW
        for col=1:40 %not necessary to run trough whole pic
            if b(row)<h-height_box %still a real edge in the pic NOG AAN TE PASSEN
                if any(distance_of_box(:)==cropped_matrix(row,col)) && all(distance_of_box(:)~=cropped_matrix(row,col+1)) %meest rechtse pixel horend bij de linkerrand
                    cropped_matrix(row,col+1)=0; %inner edge
                end
            end
        end
    
        for col=MAX_COLUMN:-1:MAX_column-40 %not necessary to run trough whole pic
            if b(row)< h-height_box %still a real edge in the pic NOG AAN TE PASSEN
                if any(distance_of_box(:)==cropped_matrix(row,col)) && all(distance_of_box(:)~=cropped_matrix(row,col-1)) %meest linkse pixel horend bij de rechterrand
                    cropped_matrix(row,col-1)=0; %inner edge
                end
                
            end
        end
                
    end   
    result=cropped_matrix;
            
 end
    
   
    