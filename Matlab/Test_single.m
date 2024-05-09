% Clear the workspace and command window
clear
clc

% Create a serial port object
baudRate = 115200;
arduinoObj = serialport("COM3",baudRate);

% Clear the input and output buffers of the serial port
flush(arduinoObj);

% Initialize a 1x3 array FRV to zero
FRV = zeros(1,3);

% Get the screen size
screenSize = get(0, 'ScreenSize');

% Define the amount to subtract from the width and height
delta = 200;  % decrease this value to make the plot bigger
samples = 400; % define number of samples displayed

% Define the width and height of the figures
figureWidthPlot = screenSize(3) * 2 / 3 - delta;  % 2/3 of the screen width for the plot
figureWidthTable = screenSize(3) / 3 - delta;  % 1/3 of the screen width for the table
figureHeight = screenSize(4) - delta;

% Create a figure window for the FRV matrix on the right side of the screen
figureF = figure('Position', [screenSize(3) * 2 / 3 delta/2 figureWidthTable figureHeight]);  % use figureWidthTable for the table

% Create a figure window for the plot on the left side of the screen
figurePlot = figure('Position', [delta/2 delta/2 figureWidthPlot figureHeight]);  % use figureWidthPlot for the plot

% Create the table
t = uitable('Parent', figureF, 'Data', FRV, 'ColumnName', {'F', 'R', 'V'}, 'RowName', {'1'});

% Define the axis limits
yLimits = [0, 5];  % adjust these values as needed
xLimits = [0, (samples + samples*9/10)];

% Initialize a cell array to hold the plots and the history of values
hPlots = cell(size(FRV));
history = cell(size(FRV));

% Initialize additional cell arrays to hold the histories of values
historyR = cell(size(FRV));
historyN = cell(size(FRV));
historyV = cell(size(FRV));

% Initialize the histories
for i = 1:numel(FRV)
    historyR{i} = zeros(1, samples);
    historyN{i} = zeros(1, samples);
    historyV{i} = zeros(1, samples);
end

% Initialize a counter
counter = 0;

% Create a single plot for F and Voltage
hPlots{1} = plot(NaN, NaN);
title('F and Voltage');

% Set the y-axis limits
yyaxis left
ylim([0, 5]);
ylabel('V');
yyaxis right
ylim([0, 120]);
ylabel('F');
xlim(xLimits);
grid on

timestamps = [];
tic;

% Loop while the figure window is open
while ishandle(figureF)
    % Read a line of data from the serial port
    data = readline(arduinoObj);
    str = char(data);

    % Find the index of the values
    R_index = strfind(str, 'R');
    F_index = strfind(str, 'F');
    V_index = strfind(str, 'V');
    x = 1;
    y = 1;

    % Read values 
    R = str2double(str(R_index+1:F_index-1));
    N = str2double(str(F_index+2:V_index-1));
    V = str2double(str(V_index+2:end));

    % Update the value in the FRV array
    FRV(x, :) = [N, R, V];

    % Update the table data if the figure is still open
    if ishandle(figureF)
        t.Data = FRV;
    end

    % Update the histories
    historyR{y, x} = [historyR{y, x}(2:end), R];
    historyN{y, x} = [historyN{y, x}(2:end), N];
    historyV{y, x} = [historyV{y, x}(2:end), V];

    % Increment the counter
    counter = counter + 1;

    if mod(counter, 1) == 0
        % Capture the elapsed time and round to the nearest millisecond
        elapsedTimestamp = round(toc, 3);
        timestamps = [timestamps elapsedTimestamp];
    end

    % Update the plots every 10 iterations
    if mod(counter, 10) == 0
        cla;  % Clear the subplot
        yyaxis left
        plot(1:numel(historyV{1}), historyV{1}, 'b', 'LineWidth', 1);  % Plot V in blue
        ylim([0, 5]);
        ylabel('V');
        yyaxis right
        hold on;  % Keep the current plot when adding new plots
        plot(1:numel(historyN{1}), historyN{1}, 'r', 'LineWidth', 1);  % Plot N in red
        ylim([0, 120]);
        ylabel('F');
        hold off;  % Allow new plots to replace the current plot
        xlim([0, max(100, numel(historyV{1}))]);  % Update the x-axis limits based on the number of samples
        grid on
        drawnow;
    end
end

% Convert the cell arrays to matrices
N = cell2mat(historyN(1,1));
R = cell2mat(historyR(1,1));
V = cell2mat(historyV(1,1));

% Ensure all matrices have the same number of columns
minColumns = min([size(timestamps, 2), size(N, 2), size(R, 2), size(V, 2)]);

timestamps = timestamps(1:minColumns);

N = N(:, 1:minColumns);
R = R(:, 1:minColumns);
V = V(:, 1:minColumns);

% Concatenate the matrices along the second dimension
combinedMatrix = [timestamps; N; R; V;]';

% Write the combined matrix to a CSV file
writematrix(combinedMatrix', '8x8.csv');

% Display message
disp('Window Closed and arduino object has been deleted');

% Close the serial port
clear arduinoObj