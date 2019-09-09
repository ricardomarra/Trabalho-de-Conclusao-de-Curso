function mask_stack = depthtomask(depth_image, number_masks)

%depthtomask
% Creates boolean masks based on the histogram of the depthmap
% Each mask corresponds with a depth level of the image
%
% [mask_stack] = depthtomask(depth_image, number_masks)
%
%Input:
%   depth_image: the depthmap of the image; 
%   number_masks: the number of masks to be created;
%
%Output:
%   mask_stack: the stack of the boolean masks

depth_image = double(depth_image);
fmin = depth_image - min(min(depth_image));
fs = 255*(fmin./(max(max(depth_image))));
fs = imresize(fs, [434 625]);
fs = round(fs);

hist = zeros(1,max(max(fs)));
for i = 1:1:max(max(fs))
    hist(i) = sum(fs(:) == i);
end

bar(hist);
n = 2;
total_sum = sum(hist);
ranges = [0, zeros(1, number_masks)];
init_threshold = 1/number_masks;
next_threshold = init_threshold;

for k = 1:1:length(hist)
    partial_sum = sum(hist(1:k));
    threshold = partial_sum/total_sum;
    if (threshold >= next_threshold)
        ranges(n) = k;
        n = n + 1;
        next_threshold = init_threshold + next_threshold;
    end
end

mask_stack = zeros(size(fs,1), size(fs,2), length(ranges)-1);

for k = 1:1:length(ranges)-1
    mini = ranges(k);
    maxi = ranges(k+1);
    mask_stack(:,:,k) = ((fs(:,:) > mini) & (fs(:,:) <= maxi));
end