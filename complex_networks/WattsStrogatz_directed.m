function A = WattsStrogatz_directed(N,k,p)
% H = WattsStrogatz(N,K,p) returns a Watts-Strogatz model graph with N
% nodes, N*K edges, mean node degree 2*k, and rewiring probability p.
% p = 0 is a ring lattice.


% Connect each node to its K next and previous neighbors. This constructs
% indices for a ring lattice.
s = repelem((1:N)',1,2*k);
temp = [-k:-1,1:k];
t = s + repmat(temp,N,1);
t = mod(t-1,N)+1;

% Rewire the target node of each edge with probability beta
for source=1:N    
    switchEdge = rand(2*k, 1) < p;
    
    newTargets = rand(N, 1);
    newTargets(source) = -1;
    newTargets(t(source, ~switchEdge)) = 0;
    
    [~, ind] = sort(newTargets, 'descend');
    t(source, switchEdge) = ind(1:nnz(switchEdge));
end

G = digraph(s,t);

A = full(adjacency(G));
end