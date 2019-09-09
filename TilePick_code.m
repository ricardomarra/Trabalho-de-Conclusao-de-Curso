% Grid division based selection code

%{
Information about this version: the algorithm receives all images as
input; then, an output image is generated with the top input images based on 
a focus measure algorithm. The action map construction considers the pixel 
value and it neighbors' values.
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the code reads the folder containing the images. The code splits each
image in a NxN grid and calculates the focus score per tile of the grid.
The code then chooses the K images with highest score per tile.
%}

clear all;
close all;
clc;

filename = 'Bikes'; % Replace with the name of the folder of the images you want to merge
addpath(genpath('functions'));

listing = dir(strcat('dataset/', filename, '*/*.png'));
files = {listing.name};
stack_length = length(files);
example = imread(fullfile(strcat('dataset/', filename), files{1}));

stack = zeros(size(example,1), size(example,2), stack_length);
red_stack = zeros(size(example,1), size(example,2), stack_length);
green_stack = zeros(size(example,1), size(example,2), stack_length);
blue_stack = zeros(size(example,1), size(example,2), stack_length);

for k = 1:stack_length
    path = fullfile(strcat('dataset/', filename), files{k});
    image = imread(path);
    red_stack(:,:,k) = image(:,:,1);
    green_stack(:,:,k) = image(:,:,2);
    blue_stack(:,:,k) = image(:,:,3);
    image = rgb2gray(image);
    stack(:,:,k) = image(:,:);
end

number_of_images = zeros(4,4);
final_score = zeros(4,4);
folder = 'results/gridmethod';
iter = 1;

for grid = 2:5 % splits the image in 2x2 to 5x5 grids
    for imgs = 1:4 % picks 1 to 4 images per grid
        
        top_images = tile_score(stack, grid, imgs)
        
        number_of_images(grid - 1, imgs) = length(top_images);
        
        for m = 1:length(top_images)
            image(:,:,1) = red_stack(:,:,top_images(m));
            image(:,:,2) = green_stack(:,:,top_images(m));
            image(:,:,3) = blue_stack(:,:,top_images(m));
            chosed_images(iter, m) = top_images(m);
            im_init{m} = {image};
        end
        iter = iter + 1;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, some parameters are defined for the code.
        %}

        % f = number of input images
        f = length(im_init);

        % k = number of layers for the image Laplacian pyramids
        % A recommended value for k is 6.
        k = 6;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, all input images are converted from RGB format to YCbCr format.
        %}

        YCbCr = cell(1,f);
        for (count=1 : 1 : f)
            YCbCr{count} = rgb2ycbcr(im_init{count}{1});
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, the cell containing the YCbCr images are decomposed in 3 others cells,
        each of them representing the Y, the Cb and the Cr layers.
        %}

        Y = cell(1,f);
        Cb = cell(1,f);
        Cr = cell(1,f);
        for (count=1 : 1 : f)
            [Y{count}, Cb{count}, Cr{count}] = decomposeYCbCr(YCbCr{count});
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, all input images are converted from unit8 to double format.
        Also, pixel values are placed in an interval of 0 to 1.
        %}

        for (count=1 : 1 : f)
            Y{count} = double(Y{count})/255;
            Cb{count} = double(Cb{count})/255;
            Cr{count} = double(Cr{count})/255;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, the output pyramid cells (Y, Cb and Cr layers) are defined.
        %}

        p_out_Y = cell (1, k);
        p_out_Cb = cell (1, k);
        p_out_Cr = cell (1, k);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, all input images go through the process of Laplacian pyramid
        decomposition in k levels.
        %}

        Y_pyr = cell(1,f);
        Cb_pyr = cell(1,f);
        Cr_pyr = cell(1,f);

        for (count=1 : 1 : f)
            Y_pyr{count} = genPyr(Y{count}, 'laplace', k);
            Cb_pyr{count} = genPyr(Cb{count}, 'laplace', k);
            Cr_pyr{count} = genPyr(Cr{count}, 'laplace', k);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, the action map is created and defined.
        *Note that this process is done only for pyramid Y.
        %}

        act = cell(1,f);
        for (count=1 : 1 : f)
            act{count} = actionMap1(Y_pyr{count});
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, the decision map is created and defined.
        %}

        dec_map = cell(1,k);
        dec_map = pixelDecision(act,1);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, the final version of the output pyramids is elaborated accordingly to
        the decision map.
        %}

        for (c=1 : 1 : k)
            if (c == k)
                p_out_Y{c} = Y_pyr{1}{c};
                p_out_Cb{c} = Cb_pyr{1}{c};
                p_out_Cr{c} = Cr_pyr{1}{c};
            else
                [m, n] = size(dec_map{c});
                for (q=1 : 1 : f)
                    for (i=1 : 1 : m)
                        for (j=1 : 1 : n)
                            if (dec_map{c}(i,j) == q)
                                p_out_Y{c}(i,j) = Y_pyr{q}{c}(i,j);
                                p_out_Cb{c}(i,j) = Cb_pyr{q}{c}(i,j);
                                p_out_Cr{c}(i,j) = Cr_pyr{q}{c}(i,j);
                            end
                        end
                    end
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        Here, the output image is reconstructed based on the output pyramids.
        The output image is called 'Final Image [QxQ] grid (K images) per
        grid', where QxQ is the grid number and K the number of images
        per grid.
        
        The output images are saved in the results/gridmethod folder along
        with csv files that shows the chosed images, final score and the
        number of images utilized to make each image.
        %}

        [im_final_Y] = pyrReconstruct(p_out_Y);
        [im_final_Cb] = pyrReconstruct(p_out_Cb);
        [im_final_Cr] = pyrReconstruct(p_out_Cr);


        final_image_ycbcr = cat(3, im_final_Y, im_final_Cb, im_final_Cr);

        final_image_rgb = ycbcr2rgb(final_image_ycbcr);
        
        final_image_rgb = uint8(round(255*final_image_rgb));
        final_score(grid - 1, imgs) = fmeasure(rgb2gray(final_image_rgb), 'LAPD')
        
        baseFileName = sprintf(strcat(filename, ' - Final Image [%dx%d] grid (%d images) per grid.png', grid, grid, imgs));
        fullFileName = fullfile(folder, baseFileName);
        imwrite(final_image_rgb, fullFileName);
    end
end

csvwrite(fullfile(folder, strcat(filename, ' - chosed_images.csv'), chosed_images));
csvwrite(fullfile(folder, strcat(filename, ' - final_score.csv'), final_score));
csvwrite(fullfile(folder, strcat(filename, ' - number_of_images.csv'), number_of_images));
