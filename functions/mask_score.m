function top_images = mask_score(mask_stack, stack, number_images)

%mask_score 
% Apply the boolean masks to the images and picks the ones with the highest
% score.
%    
% [top_images] = mask_score(mask_stack, stack, number_images)
%
%Input:
%   mask_stack: the stack containing the boolean masks
%   stack: the focal stack containing the images of the dataset
%   number_images: the number of images chosen per mask
%Output:
%   top_images: the index of the images with the highest scores

l = 1;
masked_figure = zeros(size(mask_stack,1), size(mask_stack,2), size(stack,3));
score_vector = zeros(1,size(stack,3));
top_images = zeros(1, size(mask_stack, 3)*number_images);

for m = 1:size(mask_stack,3)
    for k = 1:size(stack,3)
        masked_figure(:,:,k) = stack(:,:,k).*mask_stack(:,:,m);
        score_vector(k) = fmeasure(masked_figure(:,:,k), 'LAPD');
    end
    [~, index] = sort(score_vector, 'descend');
    indexes = index(1:number_images);
    for x = 1:number_images
        top_images(l) = indexes(1,x);
        l = l + 1;
    end
end

top_images = unique(top_images);