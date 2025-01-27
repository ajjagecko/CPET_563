%hardcoded parameters
b = 60;
f = 6;
ps = 0.006;
xNumPix = 752;
yNumPix = 480;
cxLeft = xNumPix/2;
cxRight = xNumPix/2;

camLeft = CentralCamera('focal', f/1000, 'pixel', ps/1000, 'resolution', [xNumPix, yNumPix], 'centre', [xNumPix/2, yNumPix/2], 'name', 'Left');
Tcam = SE3(-0.03,0,0);
camLeft.T = Tcam;

camRight = CentralCamera('focal', f/1000, 'pixel', ps/1000, 'resolution', [xNumPix, yNumPix], 'centre', [xNumPix/2, yNumPix/2], 'name', 'Right');
Tcam = SE3(0.03,0,0);
camRight.T = Tcam;

depth = 1:0.1:10;
numPoints = length(depth);
xLeft = zeros(1,numPoints);
xRight = zeros(1,numPoints);
calcDepth = zeros(1,numPoints);

for counter = 1:numPoints
    P = [0,0,depth(counter)]';
    leftPixel = camLeft.project(P);
    rightPixel = camRight.project(P);
    xLeft(counter) = leftPixel(1);
    xRight(counter) = rightPixel(1);
    d = (abs((xLeft(counter) - cxLeft)-(xRight(counter)-cxRight))*ps); %disparity [mm]
    Z = (b*f)/d; %depth [mm]
    calcDepth(counter) = Z/1000;
end

error = depth - calcDepth;
plot(depth,error)