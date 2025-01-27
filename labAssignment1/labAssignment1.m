function [d, calcDepth] = calculateDepth(b,f,ps,xNumPix,yNumPix,depth)
    cxLeft = xNumPix/2;
    cxRight = xNumPix/2;

    %Left Camera Creation
    camLeft = CentralCamera('focal', f/1000, 'pixel', ps/1000, 'resolution', [xNumPix, yNumPix], 'centre', [xNumPix/2, yNumPix/2], 'name', 'Left');
    Tcam = SE3(-0.03,0,0);
    camLeft.T = Tcam;

    %Right Camera Creation
    camRight = CentralCamera('focal', f/1000, 'pixel', ps/1000, 'resolution', [xNumPix, yNumPix], 'centre', [xNumPix/2, yNumPix/2], 'name', 'Right');
    Tcam = SE3(0.03,0,0);
    camRight.T = Tcam;


    numPoints = length(depth);
    x = zeros(1,numPoints);
    y = zeros(1,numPoints);
    P = [x;y;depth];
    leftPixel = camLeft.project(P);
    rightPixel = camRight.project(P);
    xLeft = leftPixel(1,:);
    xRight = rightPixel(1,:);
    d = (abs((xLeft - cxLeft)-(xRight-cxRight))*ps); %disparity [mm]
    Z = (b*f)./d; %depth [mm]
    calcDepth = Z/1000;
end

%hardcoded parameters
b = 60;             %baseline [mm]
f = 6;              %focal length [mm]
ps = 0.006;         %pixel size [mm]
xNumPix = 752;      %total number of pixels in x direction
yNumPix = 480;      %total number of pixels in y direction
depth = 0.1:0.1:10; %depth

[d, calcDepth] = calculateDepth(b,f,ps,xNumPix,yNumPix,depth);

subplot(2,1,1)
plot(depth, d)
subplot(2,1,2)
plot(depth, calcDepth - depth)

%hardcoded parameters
b = 60;             %baseline [mm]
f = 10;              %focal length [mm]
ps = 0.006;         %pixel size [mm]
xNumPix = 752;      %total number of pixels in x direction
yNumPix = 480;      %total number of pixels in y direction
depth = 0.1:0.1:10; %depth

[d, calcDepth] = calculateDepth(b,f,ps,xNumPix,yNumPix,depth);

subplot(2,1,1)
hold on
plot(depth, d)
title("Disparity over Depth")
xlabel("depth [m]")
ylabel("disparity [m]")
legend("f = 6mm","f = 10mm")

subplot(2,1,2)
hold on
plot(depth, calcDepth - depth)
title("Depth Error over Depth")
xlabel("depth [m]")
ylabel("depth error [m]")
legend("f = 6mm","f = 10mm")