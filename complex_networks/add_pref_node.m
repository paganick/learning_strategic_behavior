function [vertices, A] = add_pref_node(A, m)
% add_pref_node: the function performs one time step of the directed
% preferential attachment process of growing random network. It takes as
% input the adjacency matrix A at the current time step, as well as 
% m = m_in = m_out, number of incoming and outgoing ties of the new node,
% as described in the SI. It also returns the new number of nodes.

    el = adj2edge(A);
    vertices = size(A,2);
    indeg =[];       
    outdeg=[];
    for v=1:vertices
        indeg  = [indeg;  numel(find(el(:,2)==v))]; 
        outdeg = [outdeg; numel(find(el(:,1)==v))]; 
    end
    %% take sink-vertex-step
    vertices = vertices + 1;
    t = vertices*ones(1, min(m, vertices-1));
    s = weightedRandomSample(min(m, vertices-1),[1:vertices-1],outdeg/sum(outdeg));
    while not(length(unique(s))==length(s))
        s = weightedRandomSample(min(m, vertices-1),[1:vertices-1],outdeg/sum(outdeg));
    end
    for node=1:size(s,2)
        el = [el; s(node) t(node) 1];
    end
    el = unique(el, 'rows');
    %% take source-vertex-step
    s = vertices*ones(1, min(m, vertices-1));
    t = weightedRandomSample(min(m, vertices-1),[1:vertices-1],indeg/sum(indeg));
    while not(length(unique(t))==length(t))
        t = weightedRandomSample(min(m, vertices-1),[1:vertices-1],indeg/sum(indeg));
    end
    for node=1:size(s,2)
       el = [el; s(node) t(node) 1];
    end
    %% Updating the adjacency matrix
    el = unique(el, 'rows');
    A = zeros(vertices,vertices);
    for ii=1:size(el,1)
       A(el(ii,1), el(ii,2)) = el(ii,3);
    end
end

function el=adj2edge(adj)
% adj2edge: creates a list of edges el from the adjacency matrix adj.
    n=length(adj); % number of nodes
    edges=find(adj>0); % indices of all edges
    el=[];
    for e=1:length(edges)
        [i,j]=ind2sub([n,n],edges(e)); % node indices of edge e  
        el=[el; i j adj(i,j)];
    end
end

function s = weightedRandomSample(n,P,W)
%WEIGHTEDRANDOMSAMPLE Weighted random sampling.
% 
% INPUTs: number of draws from a discrete distribution (n)
%         possible values to pick from, (P)
%         set of normalized weights/probabilities, (W)
% OUTPUTs: s - set of n numbers drawn from P
%              according to the weights in W


    s = [];

    if abs(sum(W)-1)>10^(-8); fprintf('The probabilities do not sum up to 1.\n'); return; end

    % divide the unit interval into |P| segments each with length W_i
    unit = [0,W(1)];
    for w=2:length(W)
      unit = [unit W(w)+unit(length(unit))]; %#ok<AGROW>
    end

    % draw a random number in the unit interval uniformly - where does it fall?
    while length(s)<n

      lb = find(unit<rand, 1, 'last' );    % rand is in [unit(lb), unit(lb+1)]
      s = [s P(lb)];             %#ok<AGROW> % pick P(lb)

    end
end

