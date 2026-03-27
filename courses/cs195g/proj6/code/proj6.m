

close all;
clear variables;
rand( 'state', sum(100*clock) );

% imgdir = '/course/cs195g/asgn/proj6/data/';
imgdir = '../data/';
outdir = './images';
N = 13;

h = figure;
for i = 11 %1:N
    prefix = sprintf('source%03d',i);
    files = dir(sprintf('%s/%s/*.jpg',imgdir,prefix));
    
    T = length(files);
    filenames = cell(T,1);
    for j = 1:T
        filenames{j} = sprintf('%s/%s/%s',imgdir,prefix,files(j).name);
    end
    
    img = mosaic(filenames);
   figure(h);
   imshow(img);
    imwrite(img,sprintf('%s/panorama%03d.jpg',outdir,i));
end