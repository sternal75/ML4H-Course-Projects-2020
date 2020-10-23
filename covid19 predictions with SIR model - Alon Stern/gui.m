function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 28-Aug-2020 21:44:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% open dialog box to choose input file
% [file,path] = uigetfile('./ecdc_input/*.xlsx');
%input_data = readtable('ecdc_covid19_25-Aug-2020.xlsx', 'ReadVariableNames', true);

fileID = fopen('./ecdc_input/file_name_of_last_calc.txt','r');
ecdcExcelFileName = fscanf(fileID,'%c');
fclose(fileID);

input_data = readtable(ecdcExcelFileName, 'ReadVariableNames', true);
all_countries = unique(input_data.countriesAndTerritories);
handles.select_country.String{1} = 'Select country';
for(i=1:length(all_countries))
    country_name = all_countries{i};
    handles.select_country.String{i+1}=country_name;
end
% load constant variables
load_constants
global g_all_input_data;
g_all_input_data.input_data = input_data;

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.axes_S.Visible='off';
% handles.axes_I.Visible='off';
% handles.axes_R.Visible='off';
% handles.axes_sim_vs_reported.Visible='off';
% handles.axes_sim_vs_reported_per_day.Visible='off';
% handles.axes_R0.Visible='off';        

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in select_country.
function select_country_Callback(hObject, eventdata, handles)
load_constants
global g_all_input_data;
% hObject    handle to select_country (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_country contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_country
selected_country = handles.select_country.String(handles.select_country.Value);
selected_country = selected_country{1};
if(strcmp(selected_country,'Select country'))
    return; 
end
load(strcat('mat_files/',selected_country,'.mat'));
% result.best_fitted_params

country_indices = find(strcmpi(selected_country, g_all_input_data.input_data.countriesAndTerritories));   % find the indices of the selected country in the ECDC data file
country_data = flipud(g_all_input_data.input_data(country_indices',:));                          % selected country data
country_data.all_cases = cumsum(country_data.cases);                            % all positive corona cases
country_data(country_data.all_cases==0,:) = [];                                 % data starts on the first person infected
I_per_day = country_data.cases;                                                 % number of cases each day
I_total   = country_data.all_cases;                                             % total infected for each day
time_in_days  = 1:length(I_total);                                              
N = country_data.popData2019(1);                                                % population for the SIR model

time_in_days  = 1:length(I_total); 
simulation_length   = length(time_in_days)+number_of_prediction_days; 
simulated_time      = 1:simulation_length;
initial_sir_state_values  = [N-I_per_day(1); I_per_day(1); 0];     

first_date = country_data.dateRep(1); 
simulated_SIR_values = solve_sir(result.best_fitted_params, simulated_time,initial_sir_state_values,N);
simulated_S             = simulated_SIR_values(:,1);
simulated_I             = simulated_SIR_values(:,2);
simulated_R             = simulated_SIR_values(:,3);
simulated_total_cases   = simulated_I+simulated_R;
Simulated_N             = simulated_S+simulated_I+simulated_R;

axes(handles.axes_S);
plot_S(simulated_time, simulated_S, simulation_length, first_date);
axes(handles.axes_I);
plot_I(simulated_time, simulated_I, simulation_length, first_date);
axes(handles.axes_R);
plot_R(simulated_time, simulated_R, simulation_length, first_date);
axes(handles.axes_sim_vs_reported);
plot_sim_vs_reported(simulated_time, simulated_total_cases, I_total, simulation_length, first_date);
axes(handles.axes_sim_vs_reported_per_day);
plot_sim_vs_reported_per_day(simulated_time, simulated_total_cases, I_per_day, simulation_length, first_date);
axes(handles.axes_R0);
plot_R0(simulated_time, result.best_fitted_params, simulation_length, first_date);





% --- Executes during object creation, after setting all properties.
function select_country_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_country (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in select_country.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to select_country (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_country contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_country


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_country (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
