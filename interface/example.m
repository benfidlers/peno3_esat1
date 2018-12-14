function varargout = example(varargin)
% EXAMPLE MATLAB code for example.fig
%      EXAMPLE, by itself, creates a new EXAMPLE or raises the existing
%      singleton*.
%
%      H = EXAMPLE returns the handle to a new EXAMPLE or the handle to
%      the existing singleton*.
%
%      EXAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXAMPLE.M with the given input arguments.
%
%      EXAMPLE('Property','Value',...) creates a new EXAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before example_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop. All inputs are passed to example_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help example

% Last Modified by GUIDE v2.5 13-Dec-2018 17:26:17

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @example_OpeningFcn, ...
                   'gui_OutputFcn',  @example_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before example is made visible.
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

% UIWAIT makes example wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = example_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startbutton.
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

% --- Executes on button press in original.
function original_Callback(hObject, eventdata, handles)
% hObject    handle to original (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
image = handles.image;

figure; 
imshow(image);

% --- Executes on button press in sobel.
function sobel_Callback(hObject, eventdata, handles)
% hObject    handle to sobel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sobel = handles.sobel2;

figure;
image(sobel);

% --- Executes on button press in redbox.
function redbox_Callback(hObject, eventdata, handles)
% hObject    handle to redbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
redbox = handles.redbox2;

figure;
imshow(redbox);

% --- Executes on button press in crop.
function crop_Callback(hObject, eventdata, handles)
% hObject    handle to crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
crop = handles.crop2;

figure;
imshow(crop);

% --- Executes on button press in edge.
function edge_Callback(hObject, eventdata, handles)
% hObject    handle to edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edge = handles.edge2;

figure;
imshow(edge,[]);

% --- Executes on button press in grouped.
function grouped_Callback(hObject, eventdata, handles)
% hObject    handle to grouped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
grouped = handles.grouped2;

figure;
imagesc(grouped(:,:,2));

% --- Executes on button press in regrouped.
function regrouped_Callback(hObject, eventdata, handles)
% hObject    handle to regrouped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regrouped = handles.regrouped2;

figure;
imagesc(regrouped(:,:,2));

% --- Executes on button press in result.
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


% --- Executes on button press in test1.
function test1_Callback(hObject, eventdata, handles)
% hObject    handle to test1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of test1


% --- Executes on button press in test2.
function test2_Callback(hObject, eventdata, handles)
% hObject    handle to test2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of test2

