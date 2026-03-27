function funny_faces( imgA, ptsA )
% FUNNY_FACES This function produces goofy faces from the input image
%   'imgA' and the corresponding reference points ptsA.
%
% Jason L. Pacheco
% 9/5/10
%

  [H,W,D] = size( imgA );
  
  % pin-head big-chin
  indx_squeeze = [15,16,10,1,2,18];
  pts_squeeze = ptsA( indx_squeeze, : );
  vec_diff_squeeze = ...
    repmat( mean( pts_squeeze ), [ size(pts_squeeze,1), 1] ) - pts_squeeze;
  pts_squeeze_new = round( pts_squeeze + 0.7*vec_diff_squeeze );  
  indx_extrude = [5,6,8,14,13,7,17];
  pts_extrude = ptsA( indx_extrude, : );
  vec_diff_extrude = ...
    repmat( mean( pts_extrude ), [ size(pts_extrude,1), 1] ) - pts_extrude;
  pts_extrude_new = round( pts_extrude - 0.7*vec_diff_extrude );
  pts_new = ptsA;
  pts_new( indx_squeeze, : ) = pts_squeeze_new;
  pts_new( indx_extrude, : ) = pts_extrude_new;
  pts_new( pts_new < 1 ) = 1;
  I = find( pts_new(:,1) > W );
  J = find( pts_new(:,2) > H );
  pts_new(I,1) = W;
  pts_new(J,2) = H;
  img = facemorph( imgA, ptsA, zeros( size( imgA ) ), pts_new, 1, 0 );
  figure;
  imshow( img );  

  % pin-cushion face
  vec_diff = repmat( mean( ptsA ), [size(ptsA,1), 1] ) - ptsA;
  pts_new = round( ptsA + 0.7 * vec_diff );
  img = facemorph( imgA, ptsA, zeros( size( imgA ) ), pts_new, 1, 0 );
  figure;
  imshow( img );
  
  % barrel distortion face  
  pts_new = round( ptsA -  vec_diff );
  pts_new( pts_new < 1 ) = 1;
  I = find( pts_new(:,1) > W );
  J = find( pts_new(:,2) > H );
  pts_new(I,1) = W;
  pts_new(J,2) = H;
  img = facemorph( imgA, ptsA, zeros( size( imgA ) ), pts_new, 1, 0 );
  figure;
  imshow( img );
    
  % cross-eyes
  pts_new = ptsA;
  pts_new(1,:) = ptsA(2,:);
  pts_new(2,:) = ptsA(1,:);
  img = facemorph( imgA, ptsA, zeros( size( imgA ) ), pts_new, 1, 0 );
  figure;
  imshow( img );
  
  % swap eyes and nose
  pts_new = ptsA;
  pts_new([1,2,18],:) = ptsA([3,4,9],:);
  pts_new([3,4,9],:) = ptsA([1,2,18],:);
  img = facemorph( imgA, ptsA, zeros( size( imgA ) ), pts_new, 1, 0 );
  figure;
  imshow( img );
  
  % swap L/R
  pts_new = ptsA;
  pts_new( [16,2,4,12,6,13], : ) = ptsA( [15,1,3,11,5,14], : );
  pts_new( [15,1,3,11,5,14], : ) = ptsA( [16,2,4,12,6,13], : );
  img = facemorph( imgA, ptsA, zeros( size( imgA ) ), pts_new, 1, 0 );
  figure;
  imshow( img );
  

return;

