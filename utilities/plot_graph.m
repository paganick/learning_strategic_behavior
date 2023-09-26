function plot_graph(A, legendInfo)
% plot_graph:
% plots the diagraph from the Adjacency matrix A, adding the nodes' label 
% from legendInfo
    figure();
    plot(digraph(A),'NodeLabel', legendInfo, 'Layout', 'Force');
end

