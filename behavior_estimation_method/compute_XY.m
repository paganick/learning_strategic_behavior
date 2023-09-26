    function [X, Y] = compute_XY(A, agent_i, samples)
% Computes the X and Y matrices for agent i, accordingly to the scheme in
% the paper.
n_samples = size(samples,1);
X = zeros(n_samples, 3);
Y = zeros(n_samples, 1);
for jj=1:n_samples
    A_var = A;
    A_var(agent_i, :) = samples(jj, :);
    X(jj,1) = reciprocity(A_var, agent_i) - reciprocity(A, agent_i);
    X(jj,2) = three_step_centrality(A_var, agent_i) - three_step_centrality(A, agent_i);
    X(jj,3) = clust(A_var, agent_i) - clust(A, agent_i);
    Y(jj)   = cost(A_var, agent_i) - cost(A, agent_i);
end
end

function [reciprocity] = reciprocity(A, node_i)
% reciprocity:
% Computes the reciprocity factor of the cost function for node_i
    A_squared = A^2;
    reciprocity = A_squared(node_i, node_i);
end

function [three_step_centrality] = three_step_centrality(A, node_i)
% three_step_centrality:
% Computes the three_step_centrality factor of the cost function for node_i
    A_cube = A^3;
    cyclic_triads = A_cube(node_i, node_i);
    sum_A = sum(A);
    indegree = sum_A(node_i);
    three_step_centrality = cyclic_triads + indegree*reciprocity(A,node_i); 
end

function [clust] = clust(A,node_i)
%CLUSTERING This function computes the second term of the payoff function
%(the clustering coefficient) for a given node i and graph A
    A_squared = A^2;
    clust = 0;
    for jj=1:size(A,2) 
        if jj ~= node_i
            clust = clust + A(node_i,jj)*A_squared(node_i,jj);
        end  
    end
end

function [cost] = cost(A,node_i)
%COST This function computes the cost of maintaining the ties
    sum_A = sum(A,2);
    cost = (sum_A(node_i));
end
