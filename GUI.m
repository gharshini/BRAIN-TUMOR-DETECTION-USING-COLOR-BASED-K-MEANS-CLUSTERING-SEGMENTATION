%% Final Project BME 5020
%  Title: BRAIN TUMOR DETECTION USING COLOR BASED K MEANS CLUSTERING SEGMENTATION
% Students: Abhijit Nikhade (fr4466)
%            Harshini Gangapuram (fr8393)
% Instructor: Dr Richard Genik
%%
function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
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
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 24-Nov-2014 23:10:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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
% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%%
%  Executes on button press in pushbutton1 ('Select the MR image').
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Img;
[f,p]=uigetfile('*');
if f==0
    warndlg('User has to select Input');  % Warning dialog box 
else
Img1=imread([p f]);  
Img = double(Img1(:,:,1));
axes(handles.axes1);
imshow(uint8(Img)),colormap(gray),axis off;axis equal
end
set(handles.text3, 'String','Image Loaded')
%%
%  Executes on button press in pushbutton2 ('Contour for Selected MR Image').
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Img phi NumIter lambda1 lambda2 nu timestep mu sigma epsilon c0 alf Height Wide xx yy Ksigma ONE KONE KI KI2;  % Global variable declaration
% Setting up the values for global variables 
NumIter = 250; % iterations
timestep=0.1; % time step
mu=0.1/timestep; 
sigma = 5; % constant
epsilon = 1; % constant
c0 = 2; % constant 
lambda1=1.0; % outer weight,
lambda2=1.0; % inner weight
nu = 0.001*255*255; % length term
alf = 20;%
[Height,Wide] = size(Img);
[xx,yy] = meshgrid(1:Wide,1:Height);
phi = (sqrt(((xx - 90).^2 + (yy - 84).^2 )) - 11);
phi = sign(phi).*c0;
Ksigma=fspecial('gaussian',round(2*sigma)*2 + 1,sigma); %  kernel
ONE=ones(size(Img));
KONE = imfilter(ONE,Ksigma,'replicate');  
KI = imfilter(Img,Ksigma,'replicate');  
KI2 = imfilter(Img.^2,Ksigma,'replicate'); 
axes(handles.axes1);
imagesc(uint8(Img),[0 255]),colormap(gray),axis off;axis equal,
hold on
% For setting up a contour for a selected MR image.
[c,h] = contour(phi,[0 0],'r','linewidth',1); 
hold off
set(handles.text3, 'String','Contour fixed')
%%
%   Executes on button press in pushbutton3('Calculate the Tumor').
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Img phi NumIter lambda1 lambda2 nu timestep mu  epsilon alf Ksigma  KONE KI KI2;
% Waitbar for the given time taken
h1 = waitbar(0,'Please Wait....');
tic % Initialization of stopwatch timer
for iter = 1:NumIter
    phi =evolution_LGD(Img,phi,epsilon,Ksigma,KONE,KI,KI2,mu,nu,lambda1,lambda2,timestep,alf);
    if(mod(iter,10) == 1)
        axes(handles.axes1);
        imagesc(uint8(Img),[0 255]),colormap(gray),axis off;axis equal,title(num2str(iter))
        hold on,[c,h] = contour(phi,[1 1],'r','linewidth',1); hold off
        pause(0.01);
    end
waitbar(iter/NumIter,h1);
string=['Completed:' num2str((iter/NumIter)*100) '%'];
set(handles.text3, 'String',string)
end
close(h1);
timetaken=toc; % Setting up a value of toc(i.e. the time taken from start of the stopwatch till toc command)
a=['Clustering completed.......time taken:' num2str(timetaken) 'secs'];
set(handles.text3, 'String',a)
%%
%   Executes on button press in pushbutton4 (�Show Tumor').
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global phi;
imshow(phi) % To show the calculated tumor
set(handles.text3, 'String','Final Tumor')
%%
% End of the Program
%%
