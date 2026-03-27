%% INITIALIZE

close all
clear variables

mean_guy_flag = true;

datadir = '../data/cropped';
% datadir = '../data/cars';
ptsdir = './points';
imgdir = './images';

NUM_IMGS = 6;
% N = 1:NUM_IMGS-1;

%% COMPUTE MEAN GUY
if mean_guy_flag
  
  % compute mean shape
  pts_avg = [];
  for i=1:NUM_IMGS
    pts = load(sprintf('%s/pts%03d.txt',ptsdir,i));
    if isempty(pts_avg)
      pts_avg = (1/NUM_IMGS).*pts;
    else
      pts_avg = pts_avg + (1/NUM_IMGS).*pts;
    end
  end
  pts_avg = round( pts_avg );
  
  % compute mean morphs
  im_mean = [];
  im_medianR = []; im_medianG = []; im_medianB = [];
  for i=1:NUM_IMGS
    imgA = im2double(imread(sprintf('%s/face%03d.jpg',datadir,i)));
    ptsA = load(sprintf('%s/pts%03d.txt',ptsdir,i));
    imgB = zeros(size(imgA));
    im_morph = facemorph(imgA,ptsA,imgB,pts_avg,1,0);
    if isempty(im_mean)
      im_mean = (1/NUM_IMGS).*im_morph;
    else
      im_mean = im_mean + (1/NUM_IMGS).*im_morph;
    end
    im_medianR = cat(3, im_medianR, im_morph(:,:,1));
    im_medianG = cat(3, im_medianG, im_morph(:,:,2));
    im_medianB = cat(3, im_medianB, im_morph(:,:,3));    
  end
  im_medianR = median(im_medianR,3);
  im_medianG = median(im_medianG,3);
  im_medianB = median(im_medianB,3);  
  
  % display mean guy
  figure;
  imshow(im_mean);
  
  % display median guy
  figure;
  imshow(cat(3,im_medianR,im_medianG,im_medianB));
  
  return;  
end

%% FUNNY FACES
im_median = cat(3, im_medianR, im_medianG, im_medianB );
funny_faces( im_median, pts_avg );

%% COMPUTE MORPHS
h = figure;
ctr = 0;
for i=1:NUM_IMGS-1
    j = i+1;
    ctr = ctr+1;
    
    imgnameA = sprintf('%s/img%01d.jpg',datadir,i);
    imgnameB = sprintf('%s/img%01d.jpg',datadir,j);
    ptsnameA = sprintf('%s/pts%03d.txt',ptsdir,i);
    ptsnameB = sprintf('%s/pts%03d.txt',ptsdir,j);

    imgA = im2double(imread(imgnameA));
    imgB = im2double(imread(imgnameB));
    ptsA = load(ptsnameA);
    ptsB = load(ptsnameB);
    
    assert(sum(size(ptsA) ~= size(ptsB)) == 0);
    
%     crossdissolve = 0.5;
%     warpratio = 0.5;
    for a = 1:-0.05:0
      img = facemorph(imgA,ptsA, imgB, ptsB, a, a);
    
      figure(h)
      imshow(img);      
      imwrite(img,sprintf('%s/frame%03d.jpg',imgdir,ctr),'jpg','Quality',95);
    end
    
end



