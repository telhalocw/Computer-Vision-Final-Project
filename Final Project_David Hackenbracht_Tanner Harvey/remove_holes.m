function holesGone = remove_holes(binImg)

C = ~binImg;
[labels, number] = bwlabel(C, 4);
C = C & (labels(:,:) == labels(1, 1));    
holesGone = ~C;

end