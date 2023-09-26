function save_estimate(estimates, filename)
% save the estimates into a .mat file.
    save([filename, '.mat'], 'estimates');
end

