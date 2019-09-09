function top_images = tile_score(stack, grid_size, number_images)

%tile_score 
% Splits the image in a grid and picks the best images with the highest
% scores in the grid.
%
% [top_images] = tile_score(stack, grid_size, number_images)
%
%Input:
%   stack: the focal stack containing the images of the dataset
%   grid_size: the size of the grid; if the input is 2, creates a 2x2 grid
%   number_images: the number of images chosen per tile in the grid
%Output:
%   top_images: the index of the images with the highest scores

%% Find dimensions

temp = mat2tiles(stack(:,:,1), grid_size, grid_size);
[A, B] = size(temp);
score_stack = zeros(grid_size, grid_size, size(stack, 3));
figure_score = zeros(1, size(stack, 3));

%% Find score per tile

for k = 1:size(stack, 3)
    grid_image = mat2tiles(stack(:,:,k), A, B);
    for i = 1:size(grid_image, 1)
        for j = 1:size(grid_image, 2)
            score_stack(i,j,k) = fmeasure(grid_image{i,j}, 'LAPD');
        end
    end
    figure_score(k) = fmeasure(stack(:,:,k), 'LAPD');
end

%% Plot score per image

plot_all = 0;
m = 0;
vector_plot = zeros(1, size(score_stack, 3));
k = [1:size(score_stack, 3)];

if plot_all == 1
    for i = 1:size(score_stack, 1)
        for j = 1:size(score_stack, 2)
            figure;
            m = m + 1;
            vector_plot(:) = score_stack(i,j,:);
            stem(k, vector_plot);
            title(['Score per tile. Tile number ' num2str(m)]);
            xlabel('Image number');
            ylabel('Score');
            xlim([0, size(score_stack, 3)]);
        end
    end
    figure;
    stem(k, figure_score);
    title(['Score per image.']);
    xlabel('Image number');
    ylabel('Score');
    xlim([0, size(score_stack, 3)]);
end
   
%% Find number_images max scores

top_images = zeros(1, number_images*grid_size^2);
l = 1;
for i = 1:size(score_stack, 1)
    for j = 1:size(score_stack, 2)
        [~, index] = sort(score_stack(i,j,:), 3, 'descend');
        indexes = index(1:number_images);
        for x = 1:number_images
            top_images(l) = indexes(:,:,x);
            l = l + 1;
        end
    end
end

top_images = unique(top_images);
[best_image, test] = max(figure_score)