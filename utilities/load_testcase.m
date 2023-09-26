function testcase = load_testcase(testcase)    
% load_testcase:
% loads the adjaceny matrix A, the legend, and normalizes A.
    data                = importdata([testcase.filename, '.dat'], testcase.delimiter);
    testcase.n_agents   = size(data,2);
    testcase.A          = data((testcase.block-1)*testcase.n_agents+1 : ...
                               (testcase.block-1)*testcase.n_agents+testcase.n_agents, :);
    testcase.legendInfo = load_legend(testcase.legendFilename);
    testcase.A          = normalize_matrix(testcase.A, testcase.n_agents);
end

function legendInfo = load_legend(legendFilename)
% load_legend:   reads the legend from the legendFilename stored in
% testcase
    legendInfo = importdata([legendFilename, '.dat'], '\t');
end

    
function A = normalize_matrix(A, n_agents)
% normalize_matrix:
% returns the minimum between the A matrix and a matrix of all ones.
    A = min(A, ones(n_agents));
end
