function example_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to example (see VARARGIN)

% Makes the subbuttons invisible at the start 
set(handles.original,'visible','off')
set(handles.sobel,'visible','off')
set(handles.redbox,'visible','off')
set(handles.crop,'visible','off')
set(handles.edge,'visible','off')
set(handles.grouped,'visible','off')
set(handles.regrouped,'visible','off')
set(handles.result,'visible','off')

% Choose default command line output for example
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);