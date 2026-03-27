function [ out ] = poisson( source, mask )
% POISSON Solve poisson blending equation as a linear system of
%   constraints Ax=b.
%
  [M,N] = size(mask(:,:,1));
  
  %
  % BUILD CONSTRAINT MATRIX A
  %
  E = edges4connected(M,N);
  K = find( ~mask );
  for i=1:numel(K)
    K_i = find( E(:,1) == K(i) );
    E(K_i,:) = [];
  end
  I = [ E(:,1); find(mask); K ];
  J = [ E(:,2); find(mask); K ];
  S = [ -ones(length(E(:,1)),1); 4*ones(numel(find(mask)),1); ones(numel(K), 1) ];
  A = sparse(I,J,S,M*N,M*N);
  
  % solve each channel independently
  for d=1:size(source,3)
        
    % constraints for elements on boundary
    b = zeros(M*N,1); % reshape( V(:,:,d), numel(V(:,:,d)), 1 );   
    K = find( ~mask );
    source_chan = source(:,:,d);
    b(K) = source_chan(K);
        
    % solve system
    x = A\b;
%     out(:,:,d) = reshape(x,M,N) .* mask(:,:,d) + target(:,:,d) .*
%     ~mask(:,:,d);
    out(:,:,d) = reshape(x,M,N);
    
  end  
  
end