% D. Kaputa
% rotateCube.m
% Ravvenlabs

clc;
clear all;
close all;

genImage = 0;

if genImage == 1

%Initialization Parameters
server_ip   = '127.0.0.1';     %IP address of the Unity Server
server_port = 55001;           %Server Port of the Unity Sever

client = tcpclient(server_ip,server_port,"Timeout",20);
fprintf(1,"Connected to server\n");

width = 1920;
height = 1080;

%width = 752;
%height = 480;

serve = readmatrix("../datFiles/serve1.dat");

dataSize = size(serve);
numFrames = dataSize(1);

sampledServeCounter = 1;
framesTimeMs = 50;

%for counter = 1:framesTimeMs:numFrames
    x = serve(250,1);
    y = serve(250,3);
    z = serve(250,2);
    %z = z + 0.1625 + 0.37;

    image = blenderLink(client,width,height,x,y,z,0,0,0,"tennisBall");
    imagesc(image)
    set(gcf, 'Position', get(0, 'Screensize'));
    axis off

%end

    subplot(1,2,1)
    imageLeft = blenderLink(client, width, height, 0, -0.3, 11, 0, 0, 90, "Camera");
    imagesc(imageLeft, [0, 255]) % Apply fixed intensity range
    colormap('gray')
    set(gcf, 'Position', get(0, 'Screensize'));
    axis off
    axis tight
    
    subplot(1,2,2)
    imageRight = blenderLink(client, width, height, 0, 0.3, 11, 0, 0, 90, "Camera");
    imagesc(imageRight, [0, 255]) % Apply fixed intensity range
    colormap('gray')
    set(gcf, 'Position', get(0, 'Screensize'));
    axis off
    axis tight
    save images imageLeft imageRight

else

 load images.mat

 % Convert to Grayscale
 grayImage_L = rgb2gray(imageLeft);
 grayImage_R = rgb2gray(imageRight);
        
 % Edge Detection
 edgeImage_L = edge(grayImage_L, 'sobel');
 edgeImage_R = edge(grayImage_R, 'sobel');
        
 % Circle Detection
 [centers_L, radii_L] = imfindcircles(edgeImage_L, [15 30], 'ObjectPolarity', 'bright', 'Sensitivity', 0.88);
 [centers_R, radii_R] = imfindcircles(edgeImage_R, [15 30], 'ObjectPolarity', 'bright', 'Sensitivity', 0.92);


            

    %% 7. Extract Centroids
    if ~isempty(centers_L)
        xLeft = centers_L(1,1);
        yLeft = centers_L(1,2);
    else
        xLeft = NaN;
        yLeft = NaN;
    end

    if ~isempty(centers_R)
        xRight = centers_R(1,1);
        yRight = centers_R(1,2);
    else
        xRight = NaN;
        yRight = NaN;
    end

    %% 8. Display Results
    figure;
    subplot(1,2,1);
    imagesc(grayImage_L, [0, 255]); 
    colormap('gray');
    hold on;
    if ~isempty(centers_L)
        viscircles(centers_L, radii_L, 'EdgeColor', 'r');
        plot(xLeft, yLeft, 'rx', 'MarkerSize', 15, 'LineWidth', 2);
    end
    hold off;
    
    subplot(1,2,2);
    imagesc(grayImage_R, [0, 255]); 
    colormap('gray');
    hold on;
    if ~isempty(centers_R)
        viscircles(centers_R, radii_R, 'EdgeColor', 'r');
        plot(xRight, yRight, 'rx', 'MarkerSize', 15, 'LineWidth', 2);
    end
    hold off;

    %% 9. Compute Depth (Z), Disparity (d), and Position (X, Y)
    if ~isnan(xLeft) && ~isnan(xRight)
        % Baseline, focal length, and pixel size
        b = 600;      % baseline [mm]
        f = 6;       % focal length [mm]
        ps = 0.006;  % pixel size [mm]

        % Camera sensor details
        cxLeft = 1920 / 2;  
        cyLeft = 1080 / 2;  
        cxRight = 1920 / 2;  
        cyRight = 1080 / 2;  

        % Compute disparity
        d = abs((xLeft - cxLeft) - (xRight - cxRight)) * ps;  % Disparity in mm

        % Compute depth (Z) in meters
        Z = ((b * f) / d) / 1000; % Depth in meters
        Z = Z + 0.0;
        % Compute X and Y positions in meters
        X = Z * ((xLeft - cxLeft) * ps) / f; % Left-right position
        Y = (1*(Z * ((yLeft - cyLeft) * ps) / f)); % Up-down position
        Z1 = 11 - Z + 0.5325;
        % Display computed values
        %disp(['Disparity (d): ', num2str(d), ' mm']);
        disp(['X Position: ', num2str(Y), ' m']);
        disp(['Y Position: ', num2str(X), ' m']);
        disp(['Depth (Z): ', num2str(Z1), ' m']);

    else
        disp('Ball not detected in both images.');
    end




end