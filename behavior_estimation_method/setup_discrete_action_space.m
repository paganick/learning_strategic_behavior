function [samples] = setup_discrete_action_space(n_agents, h)
% Initializing the discretized action space
n_actions = n_agents-1;
grid_points = 1+(ceil(1/h));
alternatives_size = grid_points.^(n_actions);

samples = zeros(alternatives_size,n_agents-1);

a_disc = linspace(0, 1, grid_points);

for ii=1:alternatives_size
    temp = dec2base(ii-1, grid_points, n_agents-1);
    for jj=1:n_agents-1
        samples(ii,jj) = a_disc(str2double(temp(jj))+1);
    end
end


