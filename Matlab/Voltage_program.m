% Clear the workspace and command window
clear
clc

% Read specs file
specs = read_specs("specs.txt");

% Create a serial port object
arduinoObj = serialport(specs.com_port,specs.baud_rate);
configureTerminator(arduinoObj,"CR/LF");

% Clear the input and output buffers of the serial port
flush(arduinoObj);

% Read data from the Arduino
dataFromArduino = readline(arduinoObj);
disp(dataFromArduino);

% Write data to the Arduino
my = specs.modules_y;
mx = specs.modules_x;
mx_str = int2str(mx);
my_str = int2str(my);
data_str = [mx_str, ',', my_str];

writeline(arduinoObj, data_str);

pause(2);

% Set up number of modules, matrix size and space between readings
ns = mx * my;
pm = specs.matrix_size;
sp = floor(pm/7) - 1;

% Set up the parameters for the plot
if my > 1 || mx > 1
    if my > mx
        ymin = 0; ymax = pm * mx + sp * (mx - 1);
        xmin = 0; xmax = pm * my + sp * (my - 1);
    else
        ymin = 0; ymax = pm * my + sp * (my - 1);
        xmin = 0; xmax = pm * mx + sp * (mx - 1);
    end
else
    ymin = 0; ymax = pm * mx;
    xmin = 0; xmax = pm * my;
end
zmin = 0; zmax = 5;

% Create a grid of x and y coordinates
[Y, X] = meshgrid(ymin:ymax, xmin:xmax);

% Initialize the data array Z to zero
Z = zeros(size(Y, 1), size(X, 2));

% Get the screen size
screenSize = get(0, 'ScreenSize');

% Define the amount to subtract from the width and height
delta = 200;

% Create a figure window
figure1 = figure('Position', screenSize);
axes1 = axes('Parent',figure1);

% Set up the plot
plotTitle = 'Voltage output';
plotGraph = surf(X, Y, Z);
colormap(parula); % Colorblind friendly colormap
colorbar
clim([zmin zmax])
title(plotTitle,'FontSize',15);
% Desired starting view
view(axes1,[-22.6905213270142 45.9084662576687]);

% If the plot is not square make sure the axes are equal
if my ~= mx
axis equal
end

% If there are more modules in y then in x, switch x and y
if specs.modules_y > specs.modules_x
    xlabel('Y','FontSize',20);
    ylabel('X','FontSize',20);
else
    xlabel('X','FontSize',20);
    ylabel('Y','FontSize',20);
end

zlabel('Voltage [V]','FontSize',20);
axis([xmin xmax ymin ymax zmin zmax]);

% Increase the font size of the axis tick labels
axes1.XAxis.FontSize = 20;
axes1.YAxis.FontSize = 20;
axes1.ZAxis.FontSize = 20;

% Initialize a 8x8 array F to zero
if ns >= 1
    F1 = zeros(8, 8);
end
if ns >= 2
    F2 = zeros(8, 8);
end
if ns >= 3
    F3 = zeros(8, 8);
end
if ns == 4
    F4 = zeros(8, 8);
end

% Set up the parameters for a Gaussian kernel
kernelSize = specs.kernel;
sigma = specs.sigma;
kernel = fspecial('gaussian', kernelSize, sigma);

% Initalize time registration
last_time = 0;
tic;

% Initialize a counter for the number of iterations
iteration = 0;

% Loop while the plot is open
while ishandle(plotGraph)
    % Read a line of data from the serial port
    data = readline(arduinoObj);
    str = char(data);

    %Index
    F1_index = strfind(str, 'A');
    F2_index = strfind(str, 'B');
    F3_index = strfind(str, 'C');
    F4_index = strfind(str, 'D');

    % Location for module 1 depending on modules active
    if ns >= 1
        x1 = str2double(str(2));
        y1 = str2double(str(3));
        if ns == 1
            F1(x1, y1) = str2double(str(4:end));
        else
            F1(x1, y1) = str2double(str(4:F2_index-1));
        end
        Z(x1 + sp*x1 - sp, y1 + sp*y1 - sp) = F1(x1, y1);
    end

    % Location for module 2 depending on modules active
    if ns >= 2
        x2 = str2double(str(F2_index+1));
        y2 = str2double(str(F2_index+2));
        if ns == 2
            F2(x2, y2) = str2double(str(F2_index+3:end));
            Z((x2 + sp*x2 - sp) + pm + sp, y2 + sp*y2 - sp) = F2(x2, y2);
        else
            F2(x2, y2) = str2double(str(F2_index+3:F3_index-1));
            Z((x2 + sp*x2 - sp) + pm + sp, y2 + sp*y2 - sp) = F2(y2, 9 - x2);
        end
    end

    % Location for module 3 depending on modules active
    if ns >= 3
        x3 = str2double(str(F3_index+1));
        y3 = str2double(str(F3_index+2));

        % Location for module 3 if there are 3 modules in a line
        if ns == 3
            F3(x3, y3) = str2double(str(F3_index+3:end));
            Z((x3 + sp*x3 - sp) + 2 * pm + 2 * sp, (y3 + sp*y3 - sp)) = F3(x3, y3);
        elseif ns == 4 && my ~= mx
            % Location for module 3 if there are 4 modules in a line
            F3(x3, y3) = str2double(str(F3_index+3:F4_index-1));
            Z((x3 + sp*x3 - sp) + 2 * pm + 2 * sp, (y3 + sp*y3 - sp)) = F3(x3, y3);
        else
            % Location for module 3 for 4 modules in a square
            F3(x3, y3) = str2double(str(F3_index+3:F4_index-1));
            Z(x3 + sp*x3 - sp, (y3 + sp*y3 - sp) + pm + sp) = F3(9 - y3, x3);
        end
    end

    % Location for module 4 
    if ns == 4
        x4 = str2double(str(F4_index+1));
        y4 = str2double(str(F4_index+2));
        F4(x4,y4) = str2double(str(F4_index+3:end));
        
        if my ~= mx
            Z((x4 + sp*x4 - sp) + 3 * pm + 3 * sp, (y4 + sp*y4 - sp)) = F4(x4, y4);
        else
            Z((x4 + sp*x4 - sp) + pm + sp, (y4 + sp*y4 - sp) + pm + sp) = F4(9 - x4,9 - y4);
        end
    end

    % Update the plot with the smoothed data every 10 iterations
    ZK1 = conv2(Z(:,:), kernel, 'same');
    ZK = Z;
    ZK(:,:) = ZK1;
    ZK = (ZK - min(ZK(:))) / (max(ZK(:)) - min(ZK(:))); % Normalize ZK to [0, 1]
    ZK = ZK * (max(Z(:)) - min(Z(:))) + min(Z(:)); % Scale ZK to have the same range as Z

    if mod(iteration, 10) == 0
        % Apply the Gaussian smoothing filter to the Z array
        if ishandle(plotGraph)
            set(plotGraph, 'ZData', Z, 'CData', Z);
            drawnow;
        else
            break;
        end
    end

    % Increment the iteration counter
    iteration = iteration + 1;

    % Print the response time
    if x1 == 1 && y1 == 1
        current_time = toc;
        % Update the plot title with the new Response time
        title(sprintf('%s\nResponse time: %.3f seconds', plotTitle, current_time - last_time),'FontSize',15);
        % fprintf('Response time: %.3f seconds\r', current_time - last_time);
        last_time = toc;
    end
end

disp('Plot Closed and arduino object has been deleted');

% Send reset command to Arduino
writeline(arduinoObj, "RESET");

% Close the serial port
clear arduinoObj
