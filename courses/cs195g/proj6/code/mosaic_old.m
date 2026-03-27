function [ panorama ] = mosaic( filenames )

  % read images
  imgA = im2double(imread( filenames{1} ));
  imgB = im2double(imread( filenames{2} ));
  [Ma,Na,D] = size( imgA );
  [Mb,Nb,D] = size( imgB );
    
  % get correspondence points
  [p1_x,p1_y,V1] = harris( imgA );
  [p2_x,p2_y,V2] = harris( imgB );
  
  % compute descriptors
  D1 = zeros(numel(p1_x),3*8*8);
  D2 = zeros(numel(p2_x),3*8*8);
  for i=1:numel(p1_x)
    D1(i,:) =  [ ...
      reshape( imgA( p1_y(i)-3:p1_y(i)+4, p1_x(i)-3:p1_x(i)+4, 1 ), 1, 8*8 ), ...
      reshape( imgA( p1_y(i)-3:p1_y(i)+4, p1_x(i)-3:p1_x(i)+4, 2 ), 1, 8*8 ), ...
      reshape( imgA( p1_y(i)-3:p1_y(i)+4, p1_x(i)-3:p1_x(i)+4, 3 ), 1, 8*8 ) ];
    mu = mean( D1(i,:) );
    sig = std( D1(i,:) );
    D1(i,:) = ( D1(i,:) - mu ) ./ sig;
  end
  for i=1:numel(p2_x)
    D2(i,:) =  [ ...
      reshape( imgB( p2_y(i)-3:p2_y(i)+4, p2_x(i)-3:p2_x(i)+4, 1 ), 1, 8*8 ), ...
      reshape( imgB( p2_y(i)-3:p2_y(i)+4, p2_x(i)-3:p2_x(i)+4, 2 ), 1, 8*8 ), ...
      reshape( imgB( p2_y(i)-3:p2_y(i)+4, p2_x(i)-3:p2_x(i)+4, 3 ), 1, 8*8 ) ];
    mu = mean( D2(i,:) );
    sig = std( D2(i,:) );
    D2(i,:) = ( D2(i,:) - mu ) ./ sig;
  end  
  
  % compute candidate matches
  sqdist = dist2(D1,D2);
  matches = get_candidates( sqdist );
  
  %
  % RANSAC Iterations
  %
  n_iters = 100000;  best_score = 0; H_best = [];
%   for iter = 1:n_iters
  while best_score < 10
    
    % randomly choose 4 points
    p = randperm( size(matches,1) );
    I_rand = p(1:4)';
    I1_match = matches(I_rand,1);
    I2_match = matches(I_rand,2);
    X1 = p1_x(I1_match); Y1 = p1_y(I1_match);
    X2 = p2_x(I2_match); Y2 = p2_y(I2_match);
    
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
    score = compute_consensus( H, p1_x, p1_y, p2_x, p2_y, matches );
    if score > best_score
      best_score = score;
      H_best = H;
    end
    
  end
  
  %
  % APPLY HOMOGRAPHY
  %
  H = H_best;
  
  % compute reverse transform
  K = H * [ 1 Ma 1 Ma ; 1 1 Na Na ; 1 1 1 1 ];
  K = K ./ repmat( K(3,:), 3, 1 );
  Xs = min( [ K(1,:) 0 ] ) : max( [ K(1,:) Nb ] ) ;
  Ys = min( [ K(2,:) 0 ] ) : max( [ K(2,:) Mb ] ) ;
  [Xgrid,Ygrid] = ndgrid(Xs,Ys);
  [Mgrid, Ngrid] = size(Xgrid);
  X = H \ [ Xgrid(:) Ygrid(:) ones(Mgrid*Ngrid,1) ]';
  X = X ./ repmat( X(3,:), 3, 1 );

  % reverse transform
  x_vec = reshape( X(1,:), Mgrid, Ngrid )';
  y_vec = reshape( X(2,:), Mgrid, Ngrid )';
  for i=1:D
    panorama(:,:,i) = interp2( imgA(:,:,i), x_vec, y_vec, '*bilinear' );
  end

  % create panorama
  offset = -round( [ min( [ K(1,:) 0 ] ) min( [ K(2,:) 0] ) ] );
  panorama( 1+offset(2):Mb+offset(2), 1+offset(1):Nb+offset(1), : ) = ...
    double( imgB );
  imshow( panorama );
  keyboard;
  
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


