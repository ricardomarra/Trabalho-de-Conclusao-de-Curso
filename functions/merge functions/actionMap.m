function [act_map1] = actionMap(pyramid1)

%actionMap 
%Creates a map that salientates the a specific characteristic in the images
%This characteristic must indicates "where" is the image focused
%In order to build this action map, the code considers the pixel value.
%
%    [action_map] = actionMap(pyramid1)
%
%Input:
%   pyramid1: image pyramid; 1xt cell containing the layers of a Laplacian pyramid image;
%
%Output:
%   act_map1: 1xt cell with the salience of pyramid1

for (t=1 : 1 : length(pyramid1))
    act_map1{t} = pyramid1{t}.^2;
end


end

