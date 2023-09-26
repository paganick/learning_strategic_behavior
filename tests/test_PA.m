clear all;
close all;
clc;
set(0,'defaulttextInterpreter','latex');
warning('on');

testcase = setup_PA_testcase();

output_matrix = compute_output_matrix(testcase);
 
plot_PA(output_matrix);

%plot_PA_histogram(testcase);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function testcase = setup_PA_testcase()
% setup_PA_testcase: creates the testcase for the directed
% Preferential-Attachment model.

% Setup parameters for the PA networks
testcase.N     = 2;
testcase.m     = 2;
testcase.A = preferentialAttachment_directed(testcase.N, testcase.m);

testcase.n_agents = testcase.N;
testcase.listOfAgents = 1:testcase.N;
testcase.h = 1;

for i=1:testcase.n_agents
    testcase.legendInfo{i} = num2str(i);
end

testcase.theta{1} = linspace(0,  2, 51);
testcase.theta{2} = 0;
testcase.theta{3} = linspace(-2, 2, 51);

testcase.n_columns    = 50;
testcase.listOfAgents = [3, 4, 5, 10, 20, 50, 100, 200];
testcase.n_rows       = size(testcase.listOfAgents,2);
end


function output_matrix = compute_output_matrix(testcase)
% output_matrix: fills up the matrix of results containing the
% \theta_1-\theta_3 estimates (among the minimizers of the RSS, the one 
% with maximum norm) for each agent in the list, and for each test.

output_matrix = NaN(testcase.n_rows, testcase.n_columns,2);

for col=1:testcase.n_columns
    A = testcase.A;
    n = size(A,2);
    while (n<testcase.listOfAgents(end))
        [n, A] = add_pref_node(A, testcase.m);
        row = find(testcase.listOfAgents == n);
        if (row > 0)
            output_matrix(row, col, :) = minimumNEdistancePoint(A, testcase.listOfAgents(row), testcase);
        end
    end
end

end

function theta_min = minimumNEdistancePoint(A, agent_i, testcase)
% getMaxLikelihoodPoint: for a given network state A, and for the last
% inserted node agent_i, it computes the estimates which minimizes the
% distance to the Nash equilibrium conditions, through grid search.

    n_agents = size(A,2);
    initial_action = zeros(1,n_agents-1);
    samples = setup_reduced_discrete_action_space(n_agents, testcase.h, initial_action, testcase.m);
    n_samples = size(samples,1);
    test_samples = [samples(1:n_samples,1:agent_i-1), ...
                    zeros(n_samples,1), ...
                    samples(1:n_samples,agent_i:end)];

    theta_1 = testcase.theta{1};
    theta_2 = testcase.theta{2};
    theta_3 = testcase.theta{3};


    RSS = zeros(size(theta_1,2), size(theta_3,2));
    % Construct X and Y matrices from samples and add constraints
    [X, Y] = compute_XY(A, agent_i, test_samples);
    for ii=1:size(theta_1,2)
        for jj=1:size(theta_3,2)
            theta = [theta_1(ii); theta_2; theta_3(jj)];
            RSS(ii,jj) = compute_RSS(X, Y, theta);
        end
    end
    theta_min = getMin(RSS, theta_1, theta_3);
end

function theta = getMin(RSS, theta_1, theta_3)
% getMin: returns the minimum-norm estimate among those that 
% minimize the distance from the Nash Equilibrium.
   minimum = min(min(RSS(:)));
   [x,y] = find(RSS==minimum);
   max_norm = 0;
   for i=1:size(x,1)
      if (norm([theta_1(1,x(i)), theta_3(1,y(i))]) > max_norm)
          theta = [theta_1(1,x(i)), theta_3(1,y(i))]; % update
          max_norm = norm(theta);
      end
   end
end

function plot_PA_histogram(testcase)
% This function can be used to plot the histograms of the indegree and the
% outdegree.
A = preferentialAttachment_directed(testcase.listOfAgents(end), testcase.m, ...
                                             testcase.alpha, testcase.sym);
                                         
indegree = sum(A,1);
[a,b]=hist(indegree,unique(indegree));
figure();
scatter(b, a/sum(a), 'filled');
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
title('Indegree');
matlab2tikz('PA_squared_Indegree.tikz'),

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outdegree = sum(A,2);
[a,b]=hist(outdegree,unique(outdegree));
figure();
scatter(b, a/sum(a), 'filled');
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
title('Outdegree');
matlab2tikz('PA_squared_Outdegree.tikz'),

end