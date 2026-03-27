function matches = get_candidates( sqdist )
% GET_CANDIDATES Returns a set of candidate feature matches
%   based on thresholding e1_nn / e2_nn
%

  % compute candidate matches
  [ M, N ] = size( sqdist );
  [ Y, I ] = min( sqdist, [], 2 );
  med = median( sqdist, 2 );
  matches = [ [1:M]' , I ];
  err = Y ./ med ;
  
  % threshold matches
  n_keep = round( 0.5 * M );
  [ err_sorted, I ] = sort( err, 'ascend' );
  matches = matches( I(1:n_keep), : );
  
  % only unique matchings
  [B,I,J] = unique( matches(:,2), 'first' );
  matches = matches(I,:);

end