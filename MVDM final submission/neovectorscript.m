%This is Adam Crego's Noldus Ethovision XT Script to analyze VTE head turns
%MVDM's Neural Data Course Project
%Updated 3/6/16
%This script allows uploading of Fabian's + maze .xlsx data from the Noldus Ethovision XT files into .csv files to put into vectors for analysis
%Orgininally, I was going to call in the "neovectorreader" function to this script as an exercise to write my own function but ended up re-writing my script to simplify the problem 

%To make sure data is in the target directory
cd('C:\Users\Smith Lab\Desktop\Matlab Project MVDM\Fabian_Plus_Data_Scripts') %location of main script
addpath('C:\Users\Smith Lab\Desktop\Matlab Project MVDM\VTE_MATLAB_Project\') %include functions from Reddish code directory (did not use, made my own instead)

%First I needed to set the directory of the files
directory = 'C:\Users\Smith Lab\Desktop\Matlab Project MVDM\Noldus_Trials_Fabian_PlaceTask\';

%Need to convert xlsx files to csv using function found on Mathworks - modified function for this purpose
%(xlsx doesnt seem to work but csv does)

%% Convert Noldus .xlsx files into .csv files for MATLAB
files2conv = ls(strcat(directory,'R*.xlsx')); %directory of folder with xlsx files to convert
%List out all files within this folder starting with R and ending with
%.xlsx (i.e. name of a file: Raw data-Fabian82015- Mindfulness trial analysis-Trial     71.xlsx)

for c = 1:size(files2conv,1) %number of rows (or files in this case) in the matrix
    %Testing this with files2conv(1,end) gives me the character x, or files2conv(1,2) gives me the character a (both w/in the actual name of the file)
    %Using a file from Mathworks, convert each xlsx file to csv in same directory 
    %(xlsx files weren't working with xlsxread function, but csvread function works somewhat)
    xlsx2csv(strcat(directory,files2conv(c,:)),directory) % Take each file and convert in same directory - edited original function xlsx2csv
    %This function is from: http://www.mathworks.com/matlabcentral/fileexchange/36982-xlsx2csv--transform-sheets-in-xlsx-file-to-csv-files/content/xlsx2csv.m
    %Edited to save as .csv in directory with exact same name as the Excel file, but only saving the first sheet since that is where the data of interest is
end

%% Create function to read in data from files - currently broken
%I need to list the files that are of the appropriate extension in that location

%files = ls(strcat(directory,'R*.csv')); %assuming all files are starting with that R extension
%Everything in the directory that begins with the letter R and ends with .csv

%data = struct; %predefining this variable as a structure, not necessarily needed in this case but for clarity

%Following loop no longer works ***** issue with reading data files in - no access? cant use import data anymore - Matlab or windows or other
%Permission issue?
% for f = 1:size(files,1) %get count of number of files in directory (= # rows since records strings as characters)
%     fileloc = strcat(directory,files(f,:));  %define location of file
%     [data(f).time,data(f).xnose, data(f).ynose] = neovectorreader(fileloc); %output all three vectors into a structure
% end 

%Keep in mind the difference between function calls and variable indexing
% fun(input1, input2,...) 
% variable(row,column)

%% New method to read in .csv data from Noldus - csvread

files = ls(strcat(directory,'R*.csv')); %assuming all files are starting with that R extension
%everything in the directory that begins with the letter R and ends with .csv

data = struct; %Predefining this variable as a structure, not necessarily needed in this case but for clarity
    
%Read new fancy .csv files using built-in Matlab function csvread instead - but cant use if there are dashes in a file -- not sure why??
for f = 1:size(files,1) 
    fileloc = strcat(directory,files(f,:));  %define location of file
    data(f).alldata = csvread(fileloc,35,0); 
    %Try later?: strrep(data, '-', 'NaN') this will find all the '-' in the data and replaces it with 'NaN'
    %Can read in entire matrix of data - want to include all columns and start at row 36 for data, but CSV read likely zero-indexes so we need
    %to shift this to 0 and 35 to include all relevant data
end

%Extract the three columns of interest
for f = 1:size(files,1) %need to delineate time and x/y nose vectors
    data(f).TrialTime = data(f).alldata(:,1) ; 
    data(f).XNose = data(f).alldata(:,5) ; %from looking at Excel sheet, know locations of columns of interest
    data(f).YNose = data(f).alldata(:,6) ;
end


%% Plot resulting data
%Plotting - can loop through this too!
%If already have data saved, drag and drop into "workspace" or use load function before running this section
for r = 1:5 %5 data files
    figure
    scatter(data(r).XNose,data(r).YNose)
    xlabel('X nose')
    ylabel('Y nose')
end 


%% See if other functions work
%Functions aren't really working - not compatible with csv? only with manually reading in data?
%Reddish code: [C, eventStart, eventMean, eventEnd] = CurvatureOnNoldusData(data(1).XNose,data(1).YNose,data(1).TrialTime)dxdt(data(1).XNose)
%Using code from matlab "diff" function - use help diff to look at sin wave example

for rat = 1:5 %know we have 5 files, if this changes, can use size 
x = data(rat).XNose; 
y = data(rat).YNose; 
t = data(rat).TrialTime;
h = mean(diff(t)); %make step size an average of the difference in t

data(rat).dxdt = diff(x)/h;   % first derivative of X is Velocity
data(rat).dx2dt = diff(data(rat).dxdt)/h; %second derivative of X is Acceleration
data(rat).dydt = diff(y)/h; %first derivative of Y is Velocity
data(rat).dy2dt = diff(data(rat).dydt)/h; % second derivative of Y is Acceleration
end
%Note I found online in Mathworks: if div or mult doesnt work, try ./ or .* when working with matrices or vectors

%%
%Plot loops
for rat = 1:5
%Look at Velocity of XNose (X derivatives)
figure
%plot(t(1:end-1),dxdt,'r',t,x,'b') 
plot(1:length(data(rat).dxdt),data(rat).dxdt,'r') %Takes the lenght of all x derivatives and plots them in red against TrialTime
title(['XNose Velocity (dxdt) of trial #' num2str(rat)]) %Will loop each Velocity graph of all 5 .csv trials because of the function num@str for same rat

%Look at original X data with respect to time
figure
plot(data(rat).TrialTime,data(rat).XNose,'bx') 
title(['Original X Data of trial #' num2str(rat)])

%Look at Velocity of YNose (Y derivatives)
figure
plot(1:length(data(rat).dydt),data(rat).dydt,'r') %Takes the lenght of all y derivatives and plots them in red against TrialTime
title(['YNose Velocity (dydt) of trial #' num2str(rat)]) %Will loop each Velocity graph of all 5 .csv trials because of the function num@str for same rat

%Look at original X data with respect to time
figure
plot(data(rat).TrialTime,data(rat).YNose,'bx') 
title(['Original Y Data of trial #' num2str(rat)])

%Plot both on one graph to see if large jumps (spikes) line up
figure
plot(1:length(data(rat).dxdt),data(rat).dxdt,'b')
hold all
plot(1:length(data(rat).dydt),data(rat).dydt,'r')
title(['XVelocity vs YVelocity of trial #' num2str(rat)])

%Plot each of the XNose and YNose accelerations (second derivatives)
figure
plot(1:length(data(rat).dx2dt),data(rat).dx2dt,'b')
hold all
plot(1:length(data(rat).dy2dt),data(rat).dy2dt,'r')
title(['XNose Acceleration vs YNose Accleration of trial #' num2str(rat)])
end

%% %Curvature equation - Crego Adaptation from Reddish
% dx, dy: velocity
% ddx, ddy: acceleration
% C: curvature, as defined by Hart 1999 (Int J Med Informatics)
% C(t) = (dx(t) * ddy(t) + dy(t) * ddx(t))*(dx(t)^2+dy(t)^2)^-3/2

for rat = 1:5 % five files as of now, will change later for more trials
%Not sure how to make these vectors equal (since first derivative is being used to calcualte the second derivative), but currently removing last of
%the first deriv for simplicity *** check this at some point

N = (data(rat).dxdt(1:end-1) .* data(rat).dy2dt + data(rat).dydt(1:end-1) .* data(rat).dx2dt);
D = ((data(rat).dxdt(1:end-1).^2)+(data(rat).dydt(1:end-1).^2)).^(-3/2);
data(rat).C = N.*D;
%Need to set a threshold, Jeff mentioned a C value of 2 as a VTE, need to revisit
figure
plot(data(rat).C)
title(['Curvature for file #' num2str(rat)])
%ylim([-10,10])
end 

%% Get rid of statistical outliers - next steps
