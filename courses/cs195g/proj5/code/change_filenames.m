clear all;
close all;

imgdir = './images';
NUM_IMGS = 19;

k=1;
for i=1:(NUM_IMGS-1)
  for f=1:21
    img = imread(sprintf('%s/img%03d_frame%03d.jpg',imgdir,i,f));
    imwrite(img,sprintf('%s/frame%03d.jpg',imgdir,k),'jpg','Quality',95);
    k = k+1;
  end
end

