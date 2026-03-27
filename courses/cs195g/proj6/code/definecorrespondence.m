function [ X1 Y1 X2 Y2 ] = definecorrespondence( imgA, imgB )
    h = figure; subplot(1,2,1); image(imgA); axis image; hold on;
    title('first input image');
    [X1 Y1] = getpts(4);
    subplot(1,2,2); image(imgB); axis image; hold on;
    title('second input image');
    [X2 Y2] = getpts(4);
    close(h);
end