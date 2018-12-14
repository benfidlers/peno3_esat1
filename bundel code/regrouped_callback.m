function regrouped_Callback(hObject, eventdata, handles)
% hObject    handle to regrouped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regrouped = handles.regrouped2;

figure;
imagesc(regrouped(:,:,2));