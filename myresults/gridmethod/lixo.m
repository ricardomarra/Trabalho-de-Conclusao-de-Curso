load('chosed_images.mat');
load('final_score.mat');
load('number_of_images.mat');


csvwrite('chosed_images.csv', chosed_images);
csvwrite('final_score.csv', final_score);
csvwrite('number_of_images.csv', number_of_images);