function [P_theta, theta_hat, RSS] = computePtheta(A, agent_i, samples, theta_0, max_niter, tol, alpha)
% compute_theta_i_hat:
% Computes the estimate of the parameter for agent i. Firstly, it constructs
% matrices X_i and Y_i from a set of samples. Then, it checks
% whether there exists a region in the parameter space of non-violations.
% If that's the case, then it constructs the polyhedron from that. Note
% that, in this case, the polyhedron is the exact solution, even
% considering a full integral instead of samples.
% If such a region does not exist, then it computes theta_i_hat
% iteratively, then it computes the confidence intervals for it and
% construct the best estimate polytope around the best estimate point.
    
    % Construct samples
    n_samples = size(samples,1);   
    samples = [samples(1:n_samples,1:agent_i-1), ...
               zeros(n_samples,1), ...
               samples(1:n_samples,agent_i:end)];
    
    % Construct X and Y matrices from samples and add constraints
    [X, Y] = compute_XY(A, agent_i, samples);
    [X_constrained, Y_constrained] = addConstraints(X, Y);
    
    % Construct Polyhedron from constraints
    P_theta = Polyhedron(X_constrained, Y_constrained);
    P_theta = P_theta.minHRep();
    P_theta.computeVRep();
    
    % if Polyhedron is not empty, find a point that minimizes the minimum
    % distance problem.
    if(P_theta.isEmptySet())
        min_theta_i_tilde_norm = inf;
        nIter                  = size(theta_0,2);
        min_RSS                = inf;
        for ii=1:nIter      % Loop over different initial conditions (solution is not necessarily unique)
            [theta_i_tilde, RSS, isConverged] = computeLS(X, Y, theta_0(:,ii), max_niter, tol);
            if (~isConverged)
                   warning(['Agent ', num2str(agent_i), ' not converged within ', ...
                             num2str(max_niter), ' iterations, and initial condition: ', mat2str(theta_0(:,ii))]);
            elseif (norm(theta_i_tilde) < min_theta_i_tilde_norm)
                min_theta_i_tilde_norm = norm(theta_i_tilde);
                min_RSS = RSS;
                [P_theta, theta_hat] = computeP(X, Y, theta_i_tilde, alpha);
            end
        end
        RSS = min_RSS;
    else
        RSS = 0; % Polyhedron is not empty, thus the error is 0.
        theta_hat = NaN; % Estimate is a non-empty polyhedron
    end
end


function [X, Y] = addConstraints(X, Y)
% addConstraints is adding the constraints: \theta_1 >=0 and \theta_2 >=0
    X = [X; -1 0 0; 0 -1 0];
    Y = [Y; 0; 0];
end




function [polyhedron, theta_hat] = computeP(X, Y, theta, alpha)
% computeP: computes the polyhedron built with the \alpha and 1-\alpha 
%confidence intervals, around the best estimate theta.

    % Firstly, samples which do not violate the NE conditions are removed
    % from X and Y. Infact, they do not provide any information on the
    % parameters.
    n_samples = size(X, 1);
    remove = false(n_samples,1);
    for sample=1:n_samples
        if (f(X(sample,:), theta, Y(sample)) < 0) % no violations
            remove(sample) = true;
        end
    end
    X(remove,:) = [];
    Y(remove,:) = [];
    
    % Columns of X corresponding to a parameter which is constrained (to 0)
    % are removed. They cannot be used to estimate the CI of the
    % parameters.
    dof = [(theta(1:2) > 0)', 1];
    columns_dof = find(dof>0);
    X = X(:, columns_dof);
    
    % Lambda_hat, parameter of the exponential distribution of the errors,
    % is estimated from the mean of the error terms. 
    e = f(X, theta(columns_dof), Y);
    lambda_hat = 1/mean(e);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%    Uncomment this part to produce histogram of the errors
%     n_bins = 10;
%     figure();
%     hist(e, n_bins);
%     hold on;
%     bins = linspace(min(e), max(e), n_bins+1);
%     for i_bin=1:n_bins
%         x_p(i_bin) = (bins(i_bin) + bins(i_bin+1))/2;
%         y_p(i_bin) = size(e,1)*(-exp(-lambda_hat*(bins(i_bin+1))) + exp(-lambda_hat*(bins(i_bin))));
%     end
%     plot(x_p, y_p, 'r');
%     hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
     
    % Confidence intervals and the corrected theta_hat are computed
    [theta_hat(columns_dof,1), ci(columns_dof, :)] = ...
        compute_conf_interval(X, Y, lambda_hat, theta(columns_dof), alpha);

    % A polyhedron is constructed from the confidence intervals
    A_polyhedron  = [-eye(size(theta_hat,1)); eye(size(theta_hat,1))];
    b_polyhedron = [-ci(:,1); ci(:,2)];
    polyhedron = Polyhedron(A_polyhedron, b_polyhedron);
end


