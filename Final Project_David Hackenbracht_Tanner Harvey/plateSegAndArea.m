function [colorSegs, bwSegs, areas] = plateSegAndArea(I, numItems, inchesToPixels)
%flow: color segmentation (kmeans), texture segmentation (of grayscale
%image)
close all;
%image converted so background is black (masked)
%I is usually a maskedImage returned by isolatePlate 
%numItems is usally 5: 3 foods, 1 plate, 1 background

%5 is a good number for kmeans: 3 foods, 1 plate, 1 background (table)
seg6 = imsegkmeans(I,numItems);
colorSeg = labeloverlay(I,seg6);
figure();
imshow(colorSeg);

%begin Gabor filtering for texture
%Create a set of 24 Gabor filters, covering 6 wavelengths and 4
%orientations. (from MATLAB website)
wavelength = 2.^(0:5) * 3;
orientation = 0:45:135;
g = gabor(wavelength,orientation);

%convert original image to grayscale
Igray = im2gray(im2single(I));
figure();
imshow(Igray);

%gabor filter
gabormag = imgaborfilt(Igray,g);
montage(gabormag,'Size',[4 6])

%smooth filtered image to remove local variations
for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),3*sigma); 
end
% montage(gabormag,'Size',[4 6]) %uncomment to see textured images

%Get the x and y coordinates of all pixels in the input image.
nrows = size(I,1);
ncols = size(I,2);
[X,Y] = meshgrid(1:ncols,1:nrows);

%Concatenate the intensity information, neighborhood texture information, and spatial information about each pixel.
featureSet = cat(3,Igray,gabormag,X,Y);

%Segment the image into five regions using k-means clustering with the supplemented feature set.
L2 = imsegkmeans(featureSet,numItems,'NormalizeInput',true);
% L2 = imsegkmeans(featureSet,5);
C = labeloverlay(I,L2);
imshow(C)
title('Image with Additional Texture Information')

%isolate particular regions
%NEED: find only clusters within circle
%idea: cluster1 will be all black if region is not in circle, so can do
%sum(sum(cluster1(:,:,1)) and if that sum = 0, ignore that picture
segVect = zeros(1,numItems);
cellArray = cell(numItems,1);
%
for i = 1:numItems
    mask = L2==i;
    cluster = I.*uint8(mask);
    tempSum = sum(sum(cluster(:,:,1)));
    if tempSum > 0 %images that aren't just black
        segVect(1,i) = i;
        cellArray{i} = cluster;
    end
end
segVect = segVect(segVect~=0); %only interested in nonzero values
cellArray = cellArray(~cellfun('isempty',cellArray)); %delete empty parts

%need connected compontents analysis on images in cellArray

cellArrayBW = cell(numItems-2,1); %to hold black and white images for pixel counting (for area)
for i = 1:(numItems-2)
    temp = imbinarize(rgb2gray(cellArray{i}));
    temp2 = imdilate(temp,ones(9,9));
    temp3 = remove_holes(temp2);
    biggest = bwareafilt(temp3,1); % connected component analysis
    final = imerode(biggest,ones(9,9)); %erode to compensate for earlier dilation
    cellArrayBW{i} = final;
end

for i = 1:numItems-2 %subtract plate and background
    figure();
    imshow(cellArray{i});
    figure();
    imshow(cellArrayBW{i});
end

tempSize = size(segVect); %number of distinct images
pixelAreas = zeros(tempSize);
inchAreas = zeros(tempSize); %converted from pixel Areas; ex. ratio: 300pixels = 5 inches
%300^2 pixels^2 = 5^2 inches^2; 1 square pixel = 25/90000 square inches
%calculate areas of white regions in cellArrayBW (black and white images;
%holes filled)
for i = 1:numItems-2
    pixelAreas(1,i) = sum(sum(cellArrayBW{i}));
    inchAreas(1,i) = pixelAreas(1,i)*(inchesToPixels)^2;
end %areas of the 1st through last region (estimates for food area in inches)

%For saving the images after they've been segmented
% 
% imwrite(cellArray{1}, 'plate6_1.png');
% imwrite(cellArray{2}, 'plate6_2.png');
% imwrite(cellArray{3}, 'plate6_3.png');
% imwrite(cellArrayBW{1}, 'plate6_1BW.png');
% imwrite(cellArrayBW{2}, 'plate6_2BW.png');
% imwrite(cellArrayBW{3}, 'plate6_3BW.png');

colorSegs = cellArray;
bwSegs = cellArrayBW;
areas = inchAreas;
end