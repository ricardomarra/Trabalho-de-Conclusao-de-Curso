%Proposed Algorithm Selection Code
%Sibgrapi 2018
%Natalia_Bruno_Eduardo


%{
Information about this version: the algorithm receives a focus stack as
input; then, it selects the N images that contribute the most to the final
output image; finally, an output image is generated with the N images as
input. Besides that, the action map construction considers the pixel value
and it neighbors' values.
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the code reads all images in format PNG that are in the same directory as
this code and places them in a cell called 'im_init'.
This should be the focus stack.
%} 

imagefiles = dir('*.png');      
nfiles = length(imagefiles);    % Number of files found
for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   im_init{ii} = currentimage;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, some parameters are defined for the code.
%}

% f = number of images in the focus stack
f = length(im_init);

% k = number of layers for the image Laplacian pyramids
% A recommended value for k is 6.
k = 6;

% n_final = number of images that will be used in the final fusion process
n_final = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, all input images are converted from RGB format to YCbCr format.
%}

YCbCr = cell(1,f);
for (count=1 : 1 : f)
    YCbCr{count} = rgb2ycbcr(im_init{count});
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
dec_map = pixelDecision(act, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, the first version of the output pyramid is elaborated accordingly to
the decision map.
This first version of the output pyramid is only used to determine the N
images that contribute the most to the output image.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, a score is defined for each one of the input images.
The N images with the N highest scores are selected and placed in a cell
called 'im_filtered'.
%}

score = defineScore(f,dec_map);

[a,b] = size(dec_map{k});
score(1) = score(1) - (a*b);

[score_sorted, score_order] = sort(score, 'descend');
im_order = im_init(score_order);
im_filtered = im_order(1:n_final);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
Now that the N images were already selected, the fusion algorithm is
applied to them.
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, some parameters are defined for the code.
%}

% f = number of images in the focus stack
f = length(im_filtered);

% k = number of layers for the image Laplacian pyramids
% A recommended value for k is 6.
k = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Here, all input images are converted from RGB format to YCbCr format.
%}

YCbCr = cell(1,f);
for (count=1 : 1 : f)
    YCbCr{count} = rgb2ycbcr(im_filtered{count});
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
The output image is called 'final_image_rgb' and is shown as a figure.
%}

[im_final_Y] = pyrReconstruct(p_out_Y);
[im_final_Cb] = pyrReconstruct(p_out_Cb);
[im_final_Cr] = pyrReconstruct(p_out_Cr);


final_image_ycbcr = cat(3, im_final_Y, im_final_Cb, im_final_Cr);

final_image_rgb = ycbcr2rgb(final_image_ycbcr);

figure(1); imshow(final_image_rgb)
