function [ panorama ] = mosaic( filenames )

  N = numel( filenames );
  num_points = 100;  

  % get correspondence points
  img = cell( N, 1 );
  p_x = cell( N, 1 ); p_y = cell( N, 1 );
  for i=1:N
    img{i} = im2double(imread( filenames{i} ));
    [ p_x{i}, p_y{i}, tmp ] = harris( img{i} );    
  end
    
  % compute descriptors
  D = cell( N, 1 );
  for j=1:N
    D{j} = zeros( [ numel( p_x{j} ), 3*8*8 ] );
    for i=1:numel( p_x{j} )
      D{j}(i,:) =  [ ...
        reshape( img{j}( p_y{j}(i)-3:p_y{j}(i)+4, p_x{j}(i)-3:p_x{j}(i)+4, 1 ), 1, 8*8 ), ...
        reshape( img{j}( p_y{j}(i)-3:p_y{j}(i)+4, p_x{j}(i)-3:p_x{j}(i)+4, 2 ), 1, 8*8 ), ...
        reshape( img{j}( p_y{j}(i)-3:p_y{j}(i)+4, p_x{j}(i)-3:p_x{j}(i)+4, 3 ), 1, 8*8 ) ];
      mu = mean( D{j}(i,:) );
      sig = std( D{j}(i,:) );
      D{j}(i,:) = ( D{j}(i,:) - mu ) ./ sig;
    end
  end  
  
  % compute squared distance
  matches = cell( N, N );
  for i=1:N-1
    for j=i+1:N
      sqdist = dist2( D{i}, D{j} );
      matches{i,j} = get_candidates( sqdist );
    end
  end
  
  %
  % RANSAC Iterations
  %
  best_matches = cell( N, N );  best_score = zeros( N, N );  H_best = cell( N, N );
  for i=1:N-1
    for j=i+1:N
            
      best_score(i,j) = 0;
      max_iters = 100000;  iters = 0;
      while ( ( best_score(i,j) < 10 ) && (iters <= max_iters ) )
        
        iters = iters + 1;

        % randomly choose 4 points
        p = randperm( size(matches{i,j},1) );
        I_rand = p(1:4)';
        I1_match = matches{i,j}(I_rand,1);
        I2_match = matches{i,j}(I_rand,2);
        X1 = p_x{i}(I1_match); Y1 = p_y{i}(I1_match);
        X2 = p_x{j}(I2_match); Y2 = p_y{j}(I2_match);

        % solve homography
        A = [ ...
          [ X1; zeros(numel(X1),1) ], [ Y1; zeros(numel(Y1),1) ], ...
          [ ones(numel(X1),1); zeros(numel(X1),1) ], ....
          [ zeros(numel(X1),1); X1 ], [ zeros(numel(Y1),1); Y1 ], ...
          [ zeros(numel(X1),1); ones(numel(X1),1) ], ...
          ( -[ X1; X1 ] .* [X2; Y2] ), ( -[ Y1; Y1 ] .* [X2; Y2] ) ...
          ];
        if rcond(A) <= eps 
          continue;
        end
        b = [ X2; Y2 ];
        h = A\b;
        H = reshape([h;1],[3,3])';

        % compute score
        score = compute_consensus( H, p_x{i}(:), p_y{i}(:), p_x{j}(:), p_y{j}(:), matches{i,j} );
        if score > best_score(i,j)
          best_score(i,j) = score;
          best_score(j,i) = score;
          best_matches{i,j} = [ I1_match, I2_match ];
          H_best{i,j} = H;
          fprintf('New Best Score (%d,%d): %d\n', i,j,best_score(i,j));
        end

      end
    end
  end
  
  %
  % FIND GREEDY ORDERING
  %
  I = 1:N-1; J = [N];
  while ~isempty( I )
    [val, J_next] = max( best_score( I, J(1) ) );
    J = [ I(J_next), J ];
    I( J_next ) = [];
  end
  
  %
  % COMPUTE HISTOGRAM OF REFERENCE IMAGE
  %
%   ref_hist = zeros( size( img{J(end)} ) );
%   for d=1:3
% 
%   end
  
  %
  % TRANSFORM IMAGES
  %
  K = cell( 1, N );
  H = cell( 1, N );
  for this_i = 1:N-1
    
    % compute combined homography
    H{ J(this_i) } = eye(3,3);
    for i=this_i+1:N
      if J(i-1) < J(i)
        H{ J(this_i) } = H_best{ J(i-1), J(i) } * H{ J(this_i) };
      else
        H{ J(this_i) } = inv(H_best{ J(i), J(i-1) }) * H{ J(this_i) };
      end
    end
    
    % compute reverse transform
    [ Ma, Na, tmp ] = size( img{J(this_i)} );
    K{J(this_i)} = H{J(this_i)} * [ 1 Ma 1 Ma ; 1 1 Na Na ; 1 1 1 1 ];
    K{J(this_i)} = K{J(this_i)} ./ repmat( K{J(this_i)}(3,:), 3, 1 );    
  end
  
  % get coordinate vectors
  [Mb,Nb,tmp] = size( img{ J(end) } );
  K_all = [ K{:} ];
  Xs = min( [ K_all(1,:) 0 ] ) : max( [ K_all(1,:) Nb ] ) ;    
  Ys = min( [ K_all(2,:) 0 ] ) : max( [ K_all(2,:) Mb ] ) ;    
  [Xgrid,Ygrid] = ndgrid(Xs,Ys);
  [Mgrid, Ngrid] = size(Xgrid);
  
  % apply reverse transform
  panorama = zeros( Ngrid, Mgrid, 3 );
  for i=1:N-1
    X = H{ J(i) } \ [ Xgrid(:) Ygrid(:) ones(Mgrid*Ngrid,1) ]';
    X = X ./ repmat( X(3,:), 3, 1 );
    x_vec = reshape( X(1,:), Mgrid, Ngrid )';
    y_vec = reshape( X(2,:), Mgrid, Ngrid )';
    this_p = zeros( Ngrid, Mgrid, 3 );    
    for d=1:3
      this_p(:,:,d) = interp2( img{J(i)}(:,:,d), x_vec, y_vec, '*bilinear' );
    end  
    panorama( ~isnan( this_p ) ) = this_p( ~isnan( this_p ) );          
  end

  % create panorama
  offset = -round( [ min( [ K_all(1,:) 0 ] ) min( [ K_all(2,:) 0] ) ] );
  panorama( 1+offset(2):Mb+offset(2), 1+offset(1):Nb+offset(1), : ) = ...
    double( img{J(end)} );
%   imshow( panorama );
%   keyboard;
  
end


function score = compute_consensus( H, X1, Y1, X2, Y2, matches )
% COMPUTE_CONSENSUS Computes the consensus score for a homography
%   transform.
%

  % apply homography to points X1,Y1
  p1 = [ X1' ; Y1' ; ones( 1, numel(X1) ) ];
  p2 = [ X2' ; Y2' ; ones( 1, numel(X2) ) ];
  p1_trans = H * p1;
  p1_trans = p1_trans ./ repmat( p1_trans(3,:), 3, 1 );
    
  % calculate distances
  p1_matched = p1_trans( :, matches(:,1)' );
  p2_matched = p2( :, matches(:,2)' );
  err = sqrt( sum( ( p1_matched - p2_matched ).^2, 1 ) );
  
  score = numel( find( err <= 0.5 ) );

end


