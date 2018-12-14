function result_Callback(hObject, eventdata, handles)
% hObject    handle to result (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggle_state2 = get(handles.test2, 'Value');
result = handles.result2;
nb_of_groups = handles.number_of_groups;

if toggle_state2 == 0
    figure;
    imshow(result,[]);
    title("# objects: "+ nb_of_groups);    
else 
    figure;
    imshow(result,[]);
end