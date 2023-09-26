
function [theta_i_hat, ci] = compute_conf_interval(X_i, Y_i, lambda, theta_i_tilde, alpha)
% Computes the confindence intervals for the estimate points. The underline
% assumption is that the errors are i.i.d. with exponential distribution of
% unknown parameter lambda. 
% Confidence intervals are constructed following the procedure 
% explained in the SI, i.e. simulating the distribution of the parameters
% through the function randBeta, than computing the quantiles.
% 
    NSIM = 1000;
 
    C_i = pinv(X_i);
    check_C_i(C_i, X_i, Y_i, theta_i_tilde);
    bias = (C_i*(1/lambda*ones(size(X_i,1),1)));
    theta_i_hat = theta_i_tilde + bias;
    thetaRand = randBeta( NSIM, theta_i_hat, lambda, C_i, bias);
    ci = prctile( thetaRand, [alpha/2, 1-alpha/2]*100, 2 );
    
end

function check_C_i(C_i, X_i, Y_i, theta)
% check_C_i gives a warning in case C_i*Y_i -theta_i_tilde is not in the
% null space of X_i. That means there is a mismatch between the
% pseudoinverse C_i and the solution theta.
    TOL = 1.0e-4;
    diff        = C_i*Y_i - theta;
    null_space  = null(X_i);
    error       = norm(null_space*pinv(null_space)* diff -  diff);
    if (error > TOL)
        warning('C_i does not match with theta_i_tilde');
    end
end

function [ betaRand ] = randBeta( nSim, beta, lambda, C, bias)
% Simulates nSim realization of a random variable beta which is the sum of 
% an initial value beta + bias and a linear combination (given by the 
% matrix C) of exponential random variables of parameter lambda.
    [ ~, n ] = size( C );
    eps      = exprnd( 1/lambda, n, nSim );
    betaRand = beta + bias - C*eps;
end