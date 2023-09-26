clear all;
close all;
clc;
set(0,'defaulttextInterpreter','latex');
warning('on');

%% Test case definition
testcase = set_Medici_testcase();
% Load testcase
testcase = load_testcase(testcase);
% Plot Graph
plot_graph(testcase.A, testcase.legendInfo);

% Numerical Discretization parameters
theta_0 = [0,     0,   0; 
           1,     1, 0.1;
           1,   0.1, 0.1;
           0.1,   1, 0.1;
           0.1, 0.1,   1;
           0.1, 0.1,  -1;
           2,     2,   2;
           2,     2,  -2]'; % Initial values


% Discretize the action space into samples
[samples] = setup_discrete_action_space(testcase.n_agents, testcase.h);

% Define convergence criteria and Confidence Intervals parameters
MAX_NITER = 10000;
TOL = 1.0e-5;
ALPHA = 0.05;    % confidence interval parameter

% Initialize result structure
estimates=struct('Agent', {}, 'Name', {}, 'Theta_hat', {}, 'Vertices', {}, 'Rays', {}, 'RSS', {});

% Compute estimates
for i=1:size(testcase.listOfAgents,2)
    agent_i = testcase.listOfAgents(i);
    [Ptheta, theta_hat, RSS] = computePtheta(testcase.A, agent_i, samples, theta_0, MAX_NITER, TOL, ALPHA);
    estimates(i).Agent      = agent_i;
    estimates(i).Name       = testcase.legendInfo(agent_i);
    estimates(i).Rays       = Ptheta.R;
    estimates(i).Vertices   = [];
    for j=1:size(Ptheta,2)
        estimates(i).Vertices   = [estimates(i).Vertices; Ptheta(j).V];
    end
    estimates(i).Theta_hat  = theta_hat;
    estimates(i).RSS        = RSS;
end

% Plot and save results
plot_estimate(estimates);
%save_estimate(estimates, testcase.name);

agent    = [];
theta    = [];
ci       = [];
error    = [];
RSS      = [];
agent2   = [];
vertices = [];
agent3   = [];
rays     = [];
for i=1:size(estimates,2)
    if(estimates(i).RSS > 0)
        agent{end+1} = estimates(i).Name;
        theta(end+1,:) = estimates(i).Theta_hat;
        ci(end+1,:)    = [min(estimates(i).Vertices(:,1)), min(estimates(i).Vertices(:,2)), min(estimates(i).Vertices(:,3)), ...
                          max(estimates(i).Vertices(:,1)), max(estimates(i).Vertices(:,2)), max(estimates(i).Vertices(:,3))];
        error(end+1,:) = [theta(end,:) - ci(end,1:3), ci(end,4:6) - theta(end,:)];
        RSS(end+1, :)  = estimates(i).RSS;
    else
        for j =1:size(estimates(i).Vertices,1)
            agent2{end+1}      = estimates(i).Name;
            vertices(end+1, :) = estimates(i).Vertices(j,:);
        end
        for j =1:size(estimates(i).Rays,1)
            agent3{end+1}      = estimates(i).Name;
            rays(end+1, :) = estimates(i).Rays(j,:);
        end
    end
end
% Round results:
theta = ceil(theta*10^4)/10^4;
error = ceil(error*10^4)/10^4;
RSS   = ceil(RSS*10^4)/10^4;
result_table = [cell2table(agent'), array2table(theta), array2table(error), array2table(RSS)];
result_table.Properties.VariableNames = {'Agent' 'theta_1' 'theta_2' 'theta_3', ...
                                   'theta_1min' 'theta_2min' 'theta_3min' 'theta_1max' 'theta_2max' 'theta_3max', 'RSS'};

% Save results in a table                                 
writetable(result_table, testcase.result_table_filename, 'delimiter', '\t');

