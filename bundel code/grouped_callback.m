function grouped_Callback(hObject, eventdata, handles)
% hObject    handle to grouped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
grouped = handles.grouped2;

figure;
imagesc(grouped(:,:,2));