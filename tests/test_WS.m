clear all;
close all;
clc;
set(0,'defaulttextInterpreter','latex');
warning('on');

testcase = setup_WS_testcase();
d = compute_WS_heat_map(testcase);
plot_WS_heat_map(testcase, d);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function testcase = setup_WS_testcase()
% setup_WS_testcase: creates the testcase for the directed Watts-Strogatz
% model.

% Setup parameters for the WS networks
testcase.N = 11;
testcase.k = 2;
testcase.p = 0;

testcase.n_agents = testcase.N;
testcase.listOfAgents = 1:testcase.N;
testcase.h = 1;

for i=1:testcase.n_agents
    testcase.legendInfo{i} = num2str(i);
end

testcase.theta{1} = linspace(0,  2, 51);
testcase.theta{2} = 0;
testcase.theta{3} = linspace(-2, 2, 51);

testcase.n_tests  = 10;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function d = compute_WS_heat_map(testcase)
%compute_WS_heat_map: computes the heat map of the logarithm of the average
%distance function.
theta_1 = testcase.theta{1};
theta_2 = testcase.theta{2};
theta_3 = testcase.theta{3};


RSS = zeros(size(theta_3,2), size(theta_1,2));
d   = zeros(size(theta_3,2), size(theta_1,2));

samples = setup_discrete_action_space(testcase.n_agents, testcase.h);

for i_test = 1:testcase.n_tests
    testcase.A = WattsStrogatz_directed(testcase.N, testcase.k, testcase.p);
    for agent_i=1:testcase.n_agents
        % Construct samples
        n_samples = size(samples,1);
        test_samples = [samples(1:n_samples,1:agent_i-1), ...
            zeros(n_samples,1), ...
            samples(1:n_samples,agent_i:end)];
        
        % Construct X and Y matrices from samples and add constraints
        [X, Y] = compute_XY(testcase.A, agent_i, test_samples);
        for ii=1:size(theta_1,2)
            for jj=1:size(theta_3,2)
                theta = [theta_1(ii); theta_2; theta_3(jj)];
                RSS(jj,ii) = compute_RSS(X, Y, theta);
            end
        end
        d = d + RSS.^(1/2);
    end
    d = d/testcase.n_agents;
end
d = d/testcase.n_tests;
d = log(d+1);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function plot_WS_heat_map(testcase, d)
%plot_WS_heat_map: plots the heat map of the logarithm of the average
%distance function.
[X, Y] = meshgrid(testcase.theta{1}, testcase.theta{3});
surf(X, Y, d);
shading interp;
xlabel('$\theta_1$');
ylabel('$\theta_3$');
xlim([min(testcase.theta{1}), max(testcase.theta{1})]);
ylim([min(testcase.theta{3}), max(testcase.theta{3})]);
view(2);
c = colorbar('southoutside');
c.Label.Interpreter = 'latex';
c.Label.String = '$\frac{\sum_{i=1}^N d_i(\theta)}{N}$';
c.Label.Interpreter = 'latex';
colormap(flip(jet));

filename = ['WS_K_', num2str(testcase.k), '_p_', num2str(testcase.p), '.tikz'];
matlab2tikz(filename);

end



