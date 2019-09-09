function [decision_pyramid] = pixelDecision(action_pyramid, base_value)

%pixelDecision 
%Creates a pyramid that indicates which pixel should be taken to the final
%image
%Each pixel may come from any of the f initial images
%
%
%
%Input:
%   -action_pyramid: pyramid composed of f other pyramids with its focus characteristic in
%   salience
%   -base_value: pixel value that will be designated to the lowest level of
%   the decision map
%Output:
%   -pyramid containing a map that indicates where does each of final image
%   pixel comes from

k = length(action_pyramid{1})
f = length(action_pyramid);

aux_pyr = action_pyramid{1};

decision_pyramid = action_pyramid{1};
for (d=1 : 1 : k)
    [g, h] = size(decision_pyramid{d});
    for (i=1 : 1 : g)
        for (j=1 : 1 : h)
            decision_pyramid{d}(i,j) = base_value;
        end
    end
end

for (t=2 : 1 : f)
    for (r=1 : 1 : k-1)
        [v, b] = size(action_pyramid{t}{r});
        for (i=1 : 1 : v)
            for(j=1 : 1 : b)
                if (aux_pyr{r}(i,j) < action_pyramid{t}{r}(i,j))
                    aux_pyr{r}(i,j) = action_pyramid{t}{r}(i,j);
                    decision_pyramid{r}(i,j) = t;
                end
            end
        end
    end
end


end

