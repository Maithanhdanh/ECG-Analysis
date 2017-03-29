function varargout = GUI_MI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_MI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_MI_OutputFcn, ...
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

function GUI_MI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);


function varargout = GUI_MI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function connect_button_Callback(hObject, eventdata, handles)
try 
     if ~usejava('jvm')
         error(message('instrument:instrhwinfo:nojvm'));
     end
     % Determine the jar file version.
     jarFileVersion = com.mathworks.toolbox.instrument.Instrument.jarVersion;

          fields = {'AvailableSerialPorts',...
                    'JarFileVersion',...
                    'ObjectConstructorName',...
                    'SerialPorts'};
     try
         s = javaObject('com.mathworks.toolbox.instrument.SerialComm','temp');
         tempOut = hardwareInfo(s);
         dispose(s)
     catch
         tempOut = {{'COM1'}, '', {}, {}}';
     end
     list = cell(tempOut);
     list = list{1};
     [r,c] = size(list);
     if r==0
          list = {'COM1'}; % if there are no ports leave something in the menu
     end
     set(handles.port_menu,'String',list)
     create_serial_object(hObject, eventdata, handles);
end

function start_button_Callback(hObject, eventdata, handles)
warning('off','all');
%% ========================== declare variable ============================
data = [];          %store all Values to autosave 
all_data = [];
global obj1
fs = 250;
windowl = 5*250;
load('mi_data2.mat');
t = 1:length(data); 

%% =================== set up menu into initial state =====================
set(handles.connect_button,       'Enable','off');
set(handles.port_menu,            'Enable','off');
%% ================== call this once to allow a switch ====================
if strcmp(obj1.Status,'closed')
   try(fopen(obj1));
        fprintf(['port ' obj1.port ' opened\n'])
   catch
        fprintf(['port ' obj1.port ' not available\n'])
        set(hObject,'Value',0)
   end
end
%% ======================== handels for each figure =======================
G1 = plot(handles.axes1,0,0);
set(G1,'XDataSource','t','YDataSource','data')
data2 = [];
j = 1;
count = 1;
%% ======================= update all valid plots =========================
window = floor(windowl * 0.01);
for i = 1:window:length(data)-windowl
    data1 = data(i:i+windowl);
    plot(t(i:i+windowl),data1);
    j = j+window;
    
    if j >= windowl*count
        data2 = data(windowl*(count-1)+1:windowl*count);
        [diagnosis] = detectmi(data2,fs);
        set(handles.diagnosis,'String', diagnosis);
        count = count + 1;
    end
    pause(0.05)
end

pause(0.0001);

%% ==================== setup for plotting data ===========================
fclose(obj1);
fprintf(['port ' obj1.port ' closed\n\n'])
set(handles.connect_button,'Enable','on');
set(handles.port_menu,       'Enable','on');

function create_serial_object(hObject, eventdata, handles)
global obj1
global selection

contents = cellstr(get(handles.port_menu,'String'));
selection = contents{get(handles.port_menu,'Value')};
try
    fclose(instrfind);
    fprintf('closing all existing ports...\n')
catch
    fprintf('could not find existing Serial ports\n')
end

obj1 = instrfind('Type', 'serial', 'Port', selection, 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial(selection);
else
    fclose(obj1);
    obj1 = obj1(1);
end

BAUD = 115200;
set(obj1, 'BaudRate', BAUD, 'ReadAsyncMode','continuous');
set(obj1, 'Terminator','LF');
set(obj1, 'RequestToSend', 'off');
set(obj1, 'Timeout', 4);
set(obj1,  'InputBufferSize', 1000);

fprintf(['serial object created for ' selection ' at ' num2str(BAUD) ' BAUD\n\n']);

function port_menu_Callback(hObject, eventdata, handles)
create_serial_object(hObject, eventdata, handles);

function port_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
