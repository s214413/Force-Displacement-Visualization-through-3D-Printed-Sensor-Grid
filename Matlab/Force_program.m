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
zmin = 0; zmax = 80;

% Create a grid of x and y coordinates
[Y, X] = meshgrid(ymin:ymax, xmin:xmax);

% Initialize the data array Z to zero
Z = zeros(size(Y, 1), size(X, 2));

% Get the screen size
screenSize = get(0, 'ScreenSize');

% Define the amount to subtract from the width and height
delta = 200;

% Create a figure window
% figure1 = figure('Position', [delta/2 delta/2 screenSize(3)-delta screenSize(4)-delta]);
figure1 = figure('position', screenSize);
axes1 = axes('Parent',figure1);

% Set up the plot
plotTitle = 'Force destribution visualisation';
title(plotTitle,'FontSize',15);
plotGraph = surf(X, Y, Z);
colormap(parula); % Colorblind friendly colormap
colorbar 
clim([zmin zmax])

% Desired starting view
view(axes1,[-22.6905213270142 45.9084662576687]);

% If the plot is not square make sure the axes are equal
if my ~= mx
axis equal
end

% If there are more modules in y then in x, switch x and y
if specs.modules_y > specs.modules_x
    xlabel('Y','FontSize',15);
    ylabel('X','FontSize',15);
else
    xlabel('X','FontSize',15);
    ylabel('Y','FontSize',15);
end

zlabel('Force [N]','FontSize',15);
axis([xmin xmax ymin ymax zmin zmax]);

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

% Offsets to fit
V_offset = [
    0	    0.45	0.85	1.13	1.4	    1.6	    1.78	2.01;
    0.2	    0.64	1.01	1.35	1.62	1.81	1.98	2.17;
    0.49	0.88	1.19	1.5	    1.7	    1.88	2.09	2.32;
    0.8	    1.41	2.09	1.63	1.82	2.05	2.22	2.38;
    1.12	1.11	1.48	1.7	    1.87	2.06	2.3	    2.46;
    0.96	1.71	1.45	1.74	1.9	    2.04	2.21	2.4;
    1	    1.3	    1.55	1.85	2.05	2.12	2.26	2.46;
    1.19	1.41	1.65	1.97	2.16	2.22	2.35	2.54
    ];

% Fit coeffecients
a = 2.3;
b = 0.3606;
c = 1.992e-11;
d = 5.904;

% Set up the parameters for a Gaussian kernel
kernelSize = specs.kernel;
sigma = specs.sigma;
kernel = fspecial('gaussian', kernelSize, sigma);

% Time registration
last_time = 0;
tic;

% Initialize a counter for the number of iterations
iteration = 0;

% Loop while the plot is open
while ishandle(plotGraph)
    % Read a line of data from the serial port
    data = readline(arduinoObj);
    str = char(data);

    % Index defined
    V1_index = strfind(str, 'A');
    V2_index = strfind(str, 'B');
    V3_index = strfind(str, 'C');
    V4_index = strfind(str, 'D');

    % Location for module 1 depending on modules active
    if ns >= 1
        x1 = str2double(str(2));
        y1 = str2double(str(3));

        if ns == 1
            V1 = str2double(str(V1_index + 3:end));
        else
            V1 = str2double(str(V1_index + 3:V2_index - 1));
        end

        V1 = V1 + V_offset(x1,y1);
        F1(x1, y1) = a * exp(b * V1) + c * exp(d * V1);

        if V1 <= 2.7
            F1(x1, y1) = 0.0001;
        end
        Z(x1 + sp * x1 - sp, y1 + sp * y1 - sp) = F1(x1, y1);
    end

    % Location for module 2 depending on modules active
    if ns >= 2
        x2 = str2double(str(V2_index + 1));
        y2 = str2double(str(V2_index + 2));
        if ns == 2
            V2 = str2double(str(V2_index + 3:end));
            V2 = V2 + V_offset(x2,y2);
            F2(x2, y2) = a * exp(b * V2) + c * exp(d * V2);
            if V2 <= 2.7
                F2(x2, y2) = 0.0001;
            end
            Z((x2 + sp*x2 - sp) + pm + sp, y2 + sp*y2 - sp) = F2(x2, y2);
        else
            V2 = str2double(str(V2_index + 3:V3_index - 1));
            V2 = V2 + V_offset(x2, y2);
            F2(x2, y2) = a * exp(b * V2) + c * exp(d * V2);
            if V2 <= 2.7
                F2(x2, y2) = 0.0001;
            end
            Z((x2 + sp * x2 - sp) + pm + sp, y2 + sp * y2 - sp) = F2(y2, 9 - x2);
        end
    end

    % Location for module 3 depending on modules active
    if ns >= 3
        x3 = str2double(str(V3_index + 1));
        y3 = str2double(str(V3_index + 2));

        % Location for module 3 if there are 3 modules in a line
        if ns == 3
            V3 = str2double(str(V3_index + 3:end));
            V3 = V3 + V_offset(x3,y3);
            F3(x3, y3) = a * exp(b * V3) + c * exp(d * V3);
            if V3 <= 2.7
                F3(x3, y3) = 0.0001;
            end
            Z((x3 + sp*x3 - sp) + 2 * pm + 2 * sp, (y3 + sp*y3 - sp)) = F3(x3, y3);
        % Location for module 3 if there are 4 modules in a line
        elseif ns == 4 && my ~= mx
            V3 = str2double(str(V3_index + 3:V4_index - 1));
            V3 = V3 + V_offset(x3, y3);
            F3(x3, y3) = a * exp(b * V3) + c * exp(d * V3);
            if V3 <= 2.7
                F3(x3, y3) = 0.0001;
            end
            Z((x3 + sp * x3 - sp) + 2 * pm + 2 * sp, (y3 + sp * y3 - sp)) = F3(x3, y3);

        else
            % Location for module 3 for 4 modules in a square
            V3 = str2double(str(V3_index + 3:V4_index - 1));
            V3 = V3 + V_offset(x3, y3);
            F3(x3, y3) = a * exp(b * V3) + c * exp(d * V3);
            if V3 <= 2.7
                F3(x3, y3) = 0.0001;
            end
            Z(x3 + sp * x3 - sp, (y3 + sp * y3 - sp) + pm + sp) = F3(9 - y3, x3);
        end
    end

    % Location for module 4 
    if ns >= 4
        x4 = str2double(str(V4_index + 1));
        y4 = str2double(str(V4_index + 2));
        V4 = str2double(str(V4_index + 3:end));
        V4 = V4 + V_offset(x4, y4);
        F4(x4, y4) = a * exp(b * V4) + c * exp(d * V4);
        if V4 <= 3
            F4(x4, y4) = 0.0001;
        end

        if my ~= mx
            Z((x4 + sp * x4 - sp) + 3 * pm + 3 * sp, (y4 + sp * y4 - sp)) = F4(x4, y4);
        else
            Z((x4 + sp * x4 - sp) + pm + sp, (y4 + sp * y4 - sp) + pm + sp) = F4(9 - x4,9 - y4);
        end
    end

    % Update the plot with the smoothed data every 10 iterations
    ZK1 = conv2(Z(:,:), kernel, 'same');
    ZK = Z;
    ZK(:,:) = ZK1;
    ZK = (ZK - min(ZK(:))) / (max(ZK(:)) - min(ZK(:))); % Normalize ZK to [0, 1]
    ZK = ZK * (max(Z(:)) - min(Z(:))) + min(Z(:)); % Scale ZK to have the same range as Z

    if mod(iteration, 64) == 0
        % Apply the Gaussian smoothing filter to the Z array
        if ishandle(plotGraph)
            set(plotGraph, 'ZData', ZK, 'CData', ZK);
            drawnow;
        else
            break;
        end
    end

    % Increment the iteration counter
    iteration = iteration + 1;

    % Print the elapsed time
    if x1 == 1 && y1 == 1
        current_time = toc;
        % Update the plot title with the new elapsed time
        title(sprintf('%s\nElapsed time: %.3f seconds', plotTitle, current_time - last_time),'FontSize',15);
        % fprintf('Elapsed time: %.3f seconds\r', current_time - last_time);
        last_time = toc;
    end
end

disp('Plot Closed and arduino object has been deleted');

% Send reset command to Arduino
writeline(arduinoObj, "RESET");

% Close the serial port
clear arduinoObj