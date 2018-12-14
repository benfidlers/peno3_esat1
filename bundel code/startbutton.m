function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the value from the toggle_buttons
toggle_state1 = get(handles.test1, 'Value');
toggle_state2 = get(handles.test2, 'Value');

% Running the main program 
if toggle_state1 == 0 && toggle_state2 == 0
    % Run the appropriate program 
    main_algorithm
    
    % Make the subbuttons visible
    set(handles.original,'visible','on')
    set(handles.sobel,'visible','on')
    set(handles.redbox,'visible','on')
    set(handles.crop,'visible','on')
    set(handles.edge,'visible','on')
    set(handles.grouped,'visible','on')
    set(handles.regrouped,'visible','on')
    set(handles.result,'visible','on')

    % Saving data for the subbuttons
    handles.image = color; 
    guidata(hObject,handles);
    handles.sobel2 = depth_after_sobel;
    guidata(hObject,handles);
    handles.redbox2 = total; 
    guidata(hObject,handles);
    handles.crop2 = img;
    guidata(hObject,handles);
    handles.edge2 = first_edge_detect;
    guidata(hObject,handles);
    handles.grouped2 = grouped;
    guidata(hObject,handles);
    handles.regrouped2 = regrouped;
    guidata(hObject,handles);
    handles.result2 = red_boundary_box;
    guidata(hObject,handles);
    handles.number_of_groups = nb_of_groups3;
    guidata(hObject,handles);
    handles.timestamp = time;
    guidata(hObject,handles);

% Running the visualisation from the group algorithm
elseif toggle_state1 == 1 && toggle_state2 == 0
    % Run the appropriate program 
    grouped_step_by_step
    
    % Make the subbuttons visible
    set(handles.original,'visible','on')
    set(handles.redbox,'visible','on')
    set(handles.redbox,'visible','on')
    set(handles.crop,'visible','on')
    set(handles.edge,'visible','on')
    set(handles.grouped,'visible','on')
    set(handles.regrouped,'visible','off')
    set(handles.result,'visible','off')
    
    % Saving data for the subbuttons
    handles.image = color; 
    guidata(hObject,handles);
    handles.sobel2 = depth_after_sobel;
    guidata(hObject,handles);
    handles.redbox2 = total; 
    guidata(hObject,handles);
    handles.crop2 = img;
    guidata(hObject,handles);
    handles.edge2 = first_edge_detect;
    guidata(hObject,handles);
    handles.grouped2 = grouped;
    guidata(hObject,handles);
    handles.result2 = red_boundary_box;
    guidata(hObject,handles);
    handles.timestamp = time;
    guidata(hObject,handles);
    
% Running the algorithm to find the smallest boundary box
elseif toggle_state1 == 0 && toggle_state2 == 1
    % Run the appropriate program 
    smallest_boundary_box    

    % Make the subbuttons visible
    set(handles.original,'visible','on')
    set(handles.sobel,'visible','on')
    set(handles.redbox,'visible','on')
    set(handles.crop,'visible','on')
    set(handles.edge,'visible','on')
    set(handles.grouped,'visible','on')
    set(handles.regrouped,'visible','on')
    set(handles.result,'visible','on')
    
    % Saving data for the subbuttons
    handles.image = color; 
    guidata(hObject,handles);
    handles.sobel2 = depth_after_sobel;
    guidata(hObject,handles);
    handles.redbox2 = test123; 
    guidata(hObject,handles);
    handles.crop2 = img;
    guidata(hObject,handles);
    handles.edge2 = first_edge_detect;
    guidata(hObject,handles);
    handles.grouped2 = grouped;
    guidata(hObject,handles);
    handles.regrouped2 = regrouped;
    guidata(hObject,handles);
    handles.result2 = total_package;
    guidata(hObject,handles);
    handles.timestamp = time;
    guidata(hObject,handles);

% Option that isn't available
elseif toggle_state1 == 1 && toggle_state2 == 1
    f = warndlg('This option isn"t available','Warning');
end