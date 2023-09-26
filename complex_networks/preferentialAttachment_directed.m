function A = preferentialAttachment_directed(N, m)
%preferentialAttachemtn_directed: creates a network of N agents generated 
% with the directed preferential attachment mechanism, i.e., starting from
% a diad of nodes, at each time step a new node is introduced in the
% network. The newborn receives m incoming connections (selected at random
% with the preferential attachment mechanism on the outdegree), then
% creates m outgoing edges (selected at random with the preferential
% attachment mechanism on the indegree).


% Initial network
vertices = 2;
if not(vertices<=N); fprintf('Specify more than 2 nodes.\n');  return; end
el = [];
el = [2 1 1];
el = [el; 1 2 1];
A = zeros(vertices,vertices);
for ii=1:size(el,1)
   A(el(ii,1), el(ii,2)) = el(ii,3);
end

% Growing process
while vertices < N
    [vertices, A] = add_pref_node(A, m);
end
