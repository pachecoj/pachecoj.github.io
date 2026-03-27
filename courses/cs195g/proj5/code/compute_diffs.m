function diffs = compute_diffs( source, mask )
% COMPUTE_DIFFS Computes the difference between each vertex in the mask
%   and its neighbors (up,down,left,right) also in the mask.
%

  diffs = zeros( size( source ) );
  [M,N] = size(mask(:,:,1));

  for i=1:3
  
    % bottom neighbor
    diffs(:,:,i) = ( source(:,:,i) - ...
      [ source(2:end,:,i); zeros(1,N) ] );
    
    % top neighbor
    diffs(:,:,i) = diffs(:,:,i) + ...
      (source(:,:,i) - [ zeros(1,N); source(1:(end-1),:,i) ] );
    
    % left neighbor
    diffs(:,:,i) = diffs(:,:,i) + ...
      (source(:,:,i) - [ zeros(M,1), source(:,1:(end-1),i) ] );
    
    % right neighbor
    diffs(:,:,i) = diffs(:,:,i) + ...
      (source(:,:,i) - [ source(:,2:end,i), zeros(M,1) ] );
    
  end
  

return;