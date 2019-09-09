function [imageY,imageCb,imageCr] = decomposeYCbCr(imageYCbCr)

%decomposeYCbCr  
%Decomposition of a YCbCr image into each one of its levels (Y, Cb, Cr)
%
%   [ imageY, imageCb, imageCr ] = decomposeYCbCr (imageYCbCr)
%
%Input:
%   imageYCbCr: uint8 3-levels-image in the YCbCr form
%
%Output:
%   imageY: Y level of a YCbCr uint8 image
%   imageCb: Cb level of a YCbCr uint8 image
%   imageCr: Cr level of a YCbCr uint8 image

imageY = imageYCbCr(:,:,1);
imageCb = imageYCbCr(:,:,2);
imageCr = imageYCbCr(:,:,3);

end

