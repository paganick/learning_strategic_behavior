function f = f(X, theta, Y)
% f: Computes the linear function f, which represents the square of the sum of the
% differences between the values at the samples and the one at the Nash Equilibrium.
    f = X*theta - Y;
end
