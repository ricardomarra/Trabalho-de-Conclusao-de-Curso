function [score] = defineScore(f, decision_map)

%defineScore
%Defines a score for each one of the entry images
%The socre corresponds to the number of times that each entry image
%contributed to the final output image
%
%      [score] = defineScore(f, decision_map)
%
%Input:
%   - decision_map: 1xk pyramid with the layers of the final output image;
%   - f: number of entry images in the main code;
%
%Output:
%   - score: array with f elements with the argument corresponding to the
%   image score;

score = zeros(1,f);

k = length(decision_map);

dec_map_temp = zeros(1,k);

for (c=1 : 1 : f)
    for (d=1 : 1 : k)
        dec_map_temp(d) = sum(sum(decision_map{d} == c));
    end
    score(c) = sum(dec_map_temp);
end
    
end

