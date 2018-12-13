function replacedObjects = smallest_package(objects)
    % This fucntion creates a possible packaging for all the objects given.
    % This package has to be as small as possible, but isn't the optimal
    % packaging. This is a greedy algorithm which fills the package from
    % the biggest to smallest objects.
    
    % The function returns an image of the package with each individual
    % object's package outlinded in black.
    
    % OBJECTS HAS TO BE SORTED FROM BIGGEST TO SMALLEST BEFOREHAND

  
    % The optimal package for the biggest object is the object itself.
    replacedObjects = black_edger(objects{1});
    
    % Iterate over every object except the biggest and make a new package
    % of the old package and the new object
    listSize = size(objects);
    for i=2:listSize(2)
       
       % Initialize variables
       mat_size = size(replacedObjects);
       object_size = size(objects{i});
       extra_size_smallest = inf;
       smallest_col = 0;
       smallest_row = 0;
       flag = 0;
       
       % Iterate over every pixel
       for row=1:mat_size(1)+1
           for col=1:mat_size(2)+1
               
              % Checking wether there is an object at this location.
              if row ~= mat_size(1)+1 && col ~= mat_size(2)+1 
                % If there is an object, continue with the next pixel. 
                if replacedObjects(row,col) ~= -1
                  continue
                end
              end
            
              % Measuring the size of the package if it were appended with
              % object at on this position.
              vert_diff = object_size(1)  + row - 1;
              hor_diff = object_size(2) + col - 1;
              
              if vert_diff < mat_size(1)
                  vert_diff = mat_size(1);
              end
              if hor_diff < mat_size(2)
                  hor_diff = mat_size(2);
              end
              
              extra_size = vert_diff * hor_diff;
              
              % Measuring the same size as above, but the object is rotated
              % 90°.
              vert_diff_rot = object_size(2)  + row - 1;
              hor_diff_rot = object_size(1) + col - 1;
              
              if vert_diff_rot < mat_size(1)
                  vert_diff_rot = mat_size(1);
              end
              if hor_diff_rot < mat_size(2)
                  hor_diff_rot = mat_size(2);
              end
              
              extra_size_rot = vert_diff_rot * hor_diff_rot;
              
              
              % If the this position results in a smaller package than the
              % previous one use this one as the best position.
              if extra_size < extra_size_smallest 
                  % Appending the object at this position may not result
                  % in overlap of objects.
                  bool = position_tester(replacedObjects, objects{i}, row, col);
                  if bool == 1
                    extra_size_smallest = extra_size;
                    smallest_row = row;
                    smallest_col = col;
                    flag = 0;
                  end
              end
              
              % Same as above but for the rotated object.
              if extra_size_rot < extra_size_smallest
                  % Appending the rotated object at this position may not result
                  % in overlap of objects.
                  bool =  position_tester(replacedObjects, transpose(objects{i}), row, col);
                  if bool == 1
                   extra_size_smallest = extra_size_rot;
                   smallest_row = row;
                   smallest_col = col;
                   flag = 1;
                  end
              end
           end
       end
       
       % Append the object on the best position to the old package.
       % If the optimal measurments are reached bij rotationg the object
       % transpose it.
       if flag == 1
            replacedObjects = package_appender(replacedObjects, black_edger(transpose(objects{i})), smallest_row, smallest_col);
           
       else
            replacedObjects = package_appender(replacedObjects, black_edger(objects{i}), smallest_row, smallest_col);
       end

       imshow(replacedObjects,[]);
       
    end
end