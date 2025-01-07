function plotRoom(room_dims, source_coords_matrix, receiver_coords)
% plotRoom: Plots a 3D rectangular room with multiple sources and a receiver,
% with Y as the height and Z as the width, visually swapping Y and Z.
% The origin of the plot is centered at the receiver's position and
% an arrow is drawn only from the fourth source to the receiver.
%
% Inputs:
%   room_dims: 1x3 vector [length, height, width] of the room
%   source_coords_matrix: 3xN matrix, where each column is the [x; y; z] coordinates of a source
%   receiver_coords: 1x3 vector [x, y, z] coordinates of the receiver

% Extract room dimensions (keeping the original meaning)
L = room_dims(1);  % Room length (x-axis)
H = room_dims(2);  % Room height (y-axis, but swapped to Z)
W = room_dims(3);  % Room width (z-axis, but swapped to Y)

% Shift all source coordinates so that the receiver is at the origin (0,0,0)
source_coords_shifted_matrix = source_coords_matrix - receiver_coords';  % Transpose receiver_coords for matrix subtraction

% Define the vertices of the room for plotting, shifted so that the receiver is at the origin
vertices = [
    -receiver_coords(1)             -receiver_coords(3)             -receiver_coords(2);
    L - receiver_coords(1)          -receiver_coords(3)             -receiver_coords(2);
    L - receiver_coords(1)          W - receiver_coords(3)          -receiver_coords(2);
    -receiver_coords(1)             W - receiver_coords(3)          -receiver_coords(2);
    -receiver_coords(1)             -receiver_coords(3)             H - receiver_coords(2);
    L - receiver_coords(1)          -receiver_coords(3)             H - receiver_coords(2);
    L - receiver_coords(1)          W - receiver_coords(3)          H - receiver_coords(2);
    -receiver_coords(1)             W - receiver_coords(3)          H - receiver_coords(2)
    ];

% Define the faces of the room (using the vertices)
faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];

% Plot the room
figure('Position',[200 200 400 250]);
% Set default properties for LaTeX interpretation and font size
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesFontSize', 12);
patch('Vertices', vertices, 'Faces', faces, ...
    'FaceColor', 'cyan', 'FaceAlpha', 0.1, 'EdgeColor', 'black');
hold on;

% Get the number of sources
num_sources = size(source_coords_matrix, 2);

% Plot each source and only draw an arrow from the fourth source to the receiver
for i = 1:num_sources
    % Extract the shifted coordinates for the current source
    source_coords_shifted = source_coords_shifted_matrix(:, i);

    % Define color and marker based on whether it's the fourth source
    if i == 1
        color = 'r'; % Different color for the fourth source
        marker = 'o';      % Square marker for the fourth source
    else
        color = 'magenta';       % Default color for other sources
        marker = 'o';      % Circle marker for other sources
    end


    % Add text and draw an arrow only for the fourth source
    if i == 1
        % Plot the current source (with swapped Y and Z for visualization, and shifted)
        plot3(source_coords_shifted(1), source_coords_shifted(3), source_coords_shifted(2), ...
            marker, 'MarkerSize', 10, 'MarkerFaceColor', color, 'MarkerEdgeColor', color);

        %text(source_coords_shifted(1), source_coords_shifted(3), source_coords_shifted(2), ...
        %    ' Source', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', color);
        % Draw an arrow from the fourth source to the receiver
        quiver3(source_coords_shifted(1), source_coords_shifted(3), source_coords_shifted(2), ...
            -source_coords_shifted(1), -source_coords_shifted(3), -source_coords_shifted(2), ...
            0, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5);

    else
        % Plot the current source (with swapped Y and Z for visualization, and shifted)
        plot3(source_coords_shifted(1), source_coords_shifted(3), source_coords_shifted(2), ...
            marker, 'MarkerSize', 3, 'MarkerFaceColor', color, 'MarkerEdgeColor', color);

    end
end


% Plot the receiver (it is now at the origin)
plot3(0, 0, 0, 'bo', 'MarkerSize', 4, 'MarkerFaceColor', 'b');
text(0, 0, 0, 'Sensor', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');



% Labels and axes (swapping Y and Z in the labels)
xlabel('X (Length)');
ylabel('Z (Width)');   % Swapped: Y becomes Z
zlabel('Y (Height)');   % Swapped: Z becomes Y
title("b) \textbf{3D Room with $3^{rd}$ order reflections}");
%axis equal;
% Set axis limits
xlim([-34.5, 34.5]); % X-axis limits
ylim([-25.5, 25.5]); % Y-axis limits (actually Z swapped)
zlim([-12.9, 12.9]); % Z-axis limits (actually Y swapped)
grid on;
box on;
view(3);  % 3D view
set(gca,'LineWidth',1.5);

myFilename{1}   = 'Figures/SimulatedRoom.png';
print(gcf,'-r200','-dpng',myFilename{1});  % saves bitmap
zread           = im2double(imread(myFilename{1}));[I,J]=find(mean(zread,3)<1);
zread           = zread(min(I):max(I),min(J):max(J),:);
imwrite(zread,myFilename{1});
end