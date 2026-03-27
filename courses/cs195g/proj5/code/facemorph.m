function img = facemorph(imgA, ptsA, imgB, ptsB, crossdissolve, warpratio)
% FACEMORPH Computes a face morph between two images and their
%   corresponding reference points. 
%

  [H,W,D] = size(imgA);

  offsetA = zeros(H,W,2);
  offsetB = zeros(H,W,2);
  maskA = ones(H,W);
  maskB = ones(H,W);

  % calculate offsets for marked points
  N = size(ptsA,1);
  pts_avg = ptsA .* warpratio + (1-warpratio) .* ptsB;
  offsetA( sub2ind( size(offsetA),  ptsA(:,2), ptsA(:,1), 1*ones(N,1) ) ) ...
    = pts_avg(:,1) - ptsA(:,1);
  offsetA( sub2ind( size(offsetA), ptsA(:,2), ptsA(:,1), 2*ones(N,1) ) ) ...
    = pts_avg(:,2) - ptsA(:,2);  
  offsetB( sub2ind( size(offsetB), ptsB(:,2), ptsB(:,1), 1*ones(N,1) ) ) ...
    = pts_avg(:,1) - ptsB(:,1);
  offsetB( sub2ind( size(offsetB), ptsB(:,2), ptsB(:,1), 2*ones(N,1) ) ) ...
    = pts_avg(:,2) - ptsB(:,2);  
  
  % define masks
  maskA( sub2ind( size(maskA), ptsA(:,2), ptsA(:,1) ) ) = zeros( N, 1 );
  maskB( sub2ind( size(maskB), ptsB(:,2), ptsB(:,1) ) ) = zeros( N, 1 );
  
  % calculate offsets for non-marked points
  offsetA = poisson( offsetA, maskA );
  offsetB = poisson( offsetB, maskB );

  % precompute offset indicies
  J = round( repmat( [ 1:W ], H, 1 ) - offsetA(:,:,1) );
  I = round( repmat( [ 1:H ]', 1, W ) - offsetA(:,:,2) );  
  J( J<1 ) = 1;  I( I<1 ) = 1;
  J( J > W ) = W; I( I>H ) = H;
  indxA = sub2ind( [H,W], reshape(I,H*W,1), reshape(J,H*W,1) );
  J = round( repmat( [ 1:W ], H, 1 ) - offsetB(:,:,1) );
  I = round( repmat( [ 1:H ]', 1, W ) - offsetB(:,:,2) );    
  J( J<1 ) = 1;  I( I<1 ) = 1;  
  J( J > W ) = W; I( I>H ) = H;  
  indxB = sub2ind( [H,W], reshape(I,H*W,1), reshape(J,H*W,1) );

  % compute intermediate images
  imgA_inter = zeros(H,W,D);
  imgB_inter = zeros(H,W,D);
  for d=1:D
    
    % Image A
    A_chan = imgA(:,:,d);
    imgA_inter(:,:,d) = reshape( A_chan(indxA), H, W, 1 );
    
    % Image B
    B_chan = imgB(:,:,d);
    indx = sub2ind( size(B_chan), reshape(I,H*W,1), reshape(J,H*W,1) );
    imgB_inter(:,:,d) = reshape( B_chan(indxB), H, W, 1 );
    
  end
  
  % blend intermediate images
  img = crossdissolve .* imgA_inter + (1-crossdissolve) .* imgB_inter;

end