
leftImds = imageDatastore({'labAssignment3\left5.jpg'});

[leftImgMod, info] = readimage(leftImds,1)

%imagesc(leftImgMod);
 
[leftC, leftR] = imfindcircles(leftImgMod,[10,500],ObjectPolarity="bright",Sensitivity=0.9)

imshow(leftImgMod);
viscircles(leftC, leftR);
