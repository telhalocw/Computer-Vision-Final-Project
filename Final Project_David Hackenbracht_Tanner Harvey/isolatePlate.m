function maskedImage = isolatePlate(image, radiusSize)
% Pass function an image that has been read by imread and a radiusSize in
% pixels [i.e. img = imread('plate3.png')], call isolatePlate(img,270)
% Many thanks to ImageAnalyst and his code "circle_masking_demo.m" for the inspiration for this code.
% Requires the Image Processing Toolbox.

%from experimentation, plate radius is 300, take 30 away to isolate food away from plate
%Also: plates have an average diameter of 10inches (diameter of 5 inches)
%so 300pixels = 5 inches
%plate1: 300 - problem child
%plate2: 270 - interesting problem
%plate3: radius = 270 - best!!!
%plate4: radius = 300
%plate5: 340 - problem child
%plate6: 270 - minus salad
%plateHome: 270 - orange a problem, others good

originalImage = image;

% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(originalImage);
circleCenterX = columns/2;
circleCenterY = rows/2;
circleRadius = radiusSize;

% Initialize an image to a logical image of the circle. 
circleImage = false(rows, columns); 
[x, y] = meshgrid(1:columns, 1:rows); 
circleImage((x - circleCenterX).^2 + (y - circleCenterY).^2 <= circleRadius.^2) = true; 

% Mask the image with the circle.
if numberOfColorBands == 1
	maskedImage = originalImage; % Initialize with the entire image.
	maskedImage(~circleImage) = 0; % Zero image outside the circle mask.
else
	% Mask the image.
	maskedImage = bsxfun(@times, originalImage, cast(circleImage,class(originalImage)));
end

end