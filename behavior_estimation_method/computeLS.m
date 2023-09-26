function  [theta_tilde, RSS_tilde, isConverged] = computeLS(X, Y, theta_0, max_niter, tol)
% Compute the solution of the minimum distance problem, with constraints.
% The solution is returned in theta_tilde, the sum of squared errors in
% RSS_tilde, and isConverged is true iff the convergence (up to tolerance "tol") 
%is reached within max_niter iterations.

    % Initialize variable
    theta      = NaN(3, max_niter);
    RSS        = Inf(max_niter, 1);
    phi        = Inf(size(X,2), 1);
    gradient   = NaN(3, max_niter);

    k = 1;
    theta(:,k)              = theta_0;
    [RSS(k), phi]           = compute_RSS(X, Y, theta(:,k));        
    gradient(:, k)          = gradient_f(phi,X);
    isConverged             = test_convergence(gradient(:,k), theta(:,k), tol);

    % Loop with gradient method until convergence is reached, or max_niter
    % is reached.
    while (k < max_niter && isConverged == false)
        k = k+1;
        [theta]                 = gradient_descent(theta, gradient, k-1);
        theta(:,k)              = project(theta(:,k));
        [RSS(k), phi]           = compute_RSS(X, Y, theta(:,k));        
        gradient(:, k)          = gradient_f(phi,X);
        isConverged             = test_convergence(gradient(:,k), theta(:,k), tol);
    end
    if (~isConverged)
        theta_tilde = NaN(3,1);
        RSS_tilde   = Inf; 
    else
        theta_tilde = theta(:,k);
        RSS_tilde   = RSS(k);
    end
end


function [theta] = gradient_descent(theta, grad, k)
% gradient_descent: Updates theta with the new data, determined via a
% gradient descent algorithm. 
initial_step_size = 0.001;
if (k == 1)
    step_size = initial_step_size;
else
    H_norm = ((grad(:,k)-grad(:,k-1))'*(grad(:,k)-grad(:,k-1)));
    step_size = abs((theta(:,k) - theta(:,k-1))'*(grad(:,k)-grad(:,k-1)))/H_norm;
end
if (isnan(step_size))
    warning('Small step_size');
    step_size = 0;
end
theta(:,k+1) = theta(:,k) - grad(:,k)*step_size;
end


function project = project(theta)
% project: Projects theta into the constraint set (\theta_1 >=0 , \theta_2 >=0)
    project = theta; 
    project(1) = max(0, theta(1));
    project(2) = max(0, theta(2));
end


function isConverged = test_convergence(gradient, x, tol)
% test_convergence: Checks the convergence of the solution of the gradient
% descent algorithm. Since it is a constrained optimization problem, the
% solution "\theta" must satisfy: (\grad(F)|_\theta)^T(y-\theta) >=0 , for
% all feasible directions y.

    if (norm(gradient)<tol)
        isConverged = true;
    elseif (norm(gradient(3)) < tol)
        if ( (norm(gradient(2)) < tol) ||  (gradient(2) >= 0 && norm(x(2)) < tol) )
            if ( (norm(gradient(1)) < tol) ||  (gradient(1) >= 0 && norm(x(1)) < tol) )
                isConverged = true;
            else
                isConverged = false;
            end
        else
            isConverged = false;
        end
    else
        isConverged = false;
    end
end
