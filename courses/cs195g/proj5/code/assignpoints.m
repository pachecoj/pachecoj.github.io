close all
clear variables

% datadir = '/course/cs195g/asgn/proj5/data/cropped';
datadir = '../data/cars';
ptsdir = './points/cars';

NUM_IMGS = 6;
N = 1:NUM_IMGS;


% Assign points
for i= N
    j = i+1;
    imgname = sprintf('%s/img%01d.jpg',datadir,i);
    ptsname = sprintf('%s/pts%03d.txt',ptsdir,i);
    
    img = im2double(imread(imgname));
    [ pts h ] = getpoints(img); close(h)
    save('-ascii',ptsname,'pts');
end
