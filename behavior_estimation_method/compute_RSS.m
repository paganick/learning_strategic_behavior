function [RSS, phi] = compute_RSS(X, Y, theta)
% Computes the sum of residuals function
    phi      = max(0, f(X, theta, Y));
    RSS      = phi'*phi;
end