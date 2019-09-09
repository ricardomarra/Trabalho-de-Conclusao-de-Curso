function [act_map1] = actionMap1(pyramid1)

%actionMap1 
%Creates a map that salientates a specific characteristic in the images
%This characteristic must indicates "where" is the image focused
%In order to build this action map, the code considers the pixel value and
%the pixel neighbors' values, that is, its neighborhood.
%
%    [action_map] = actionMap1(pyramid1)
%
%Input:
%   pyramid1: image pyramid; this is a 1xt cell containing the layers of a Laplacian pyramid image;
%
%
%Output:
%   act_map1: 1xt cell with the salience of pyramid1


for t=1 : 1 : length(pyramid1)
    [w, h] = size(pyramid1{t});
    for i=1 : 1 : w
        for j=1 : 1 : h
            if i==1 || i==w || j==1 || j==h || i==2 || i==w-1 || j==2 || j==h-1
                act_map1{t}(i,j) = pyramid1{t}(i,j).^2;
            else
                for i1=-2 : 1 : 2
                    for j1=-2 : 1 : 2
                        act_map1{t}(i,j) = act_map1{t}(i,j)+ pyramid1{t}(i+i1,j+j1).^2;
                    end
                end
            end
        end
    end
end


end



