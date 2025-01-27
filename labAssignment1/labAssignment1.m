%hardcoded parameters
b = 60;
f = 6;
ps = 0.006;
xNumPix = 752;
cxLeft = xNumPix/2;
cxRight = xNumPix/2;

P = [0,0,10]';

camLeft = CentralCamera('focal', 0.006, 'pixel', 0.000006, 'resolution', [752, 480], 'centre', [752/2, 480/2]);
Tcam = SE3(-0.03,0,0);
camLeft.T = Tcam;
left = camLeft.project(P);
camLeft.plot(P);

camRight = CentralCamera('focal', 0.006, 'pixel', 0.000006, 'resolution', [752, 480], 'centre', [752/2, 480/2]);
Tcam = SE3(0.03,0,0);
camRight.T = Tcam;
right = camRight.project(P);
camRight.plot(P);

xLeft = left(1);
xRight = right(1);

d = (abs((xLeft - cxLeft)-(xRight-cxRight))*ps); %disparity [mm]
Z = (b *f)/d; %depth [mm]


