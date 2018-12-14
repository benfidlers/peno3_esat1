function redbox_Callback(hObject, eventdata, handles)
% hObject    handle to redbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
redbox = handles.redbox2;

figure;
imshow(redbox);