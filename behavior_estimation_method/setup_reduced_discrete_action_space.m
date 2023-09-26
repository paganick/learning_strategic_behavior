function [samples] = setup_reduced_discrete_action_space(n_agents, h, initial_action, change_elements)
% Initializing the discretized action space
grid_points = 1+(ceil(1/h));
alternatives_size = grid_points.^(change_elements);
combinations = combnk(1:n_agents-1, change_elements);
number_combinations = size(combinations,1);

samples = repmat(initial_action, alternatives_size*number_combinations,1);

a_disc = linspace(0, 1, grid_points);

for ii = 1:alternatives_size
    temp = dec2base(ii-1, grid_points, change_elements);
    for jj=1:number_combinations
        for kk=1:change_elements
            samples((ii-1)*number_combinations+jj,combinations(jj,kk)) = a_disc(str2double(temp(kk))+1);
        end
    end
end
samples = unique(samples, 'rows');