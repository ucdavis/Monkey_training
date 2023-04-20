outputDir = 'D:\Wenqing\Foraging\Natural\Image';
load D:\Wenqing\stl10_matlab\train.mat
X_bird=X(y==2|y==3|y==4|y==5|y==6|y==8,:,:,:);
 XBatch=reshape(X_bird,[6*500,96,96,3]);
 XBatch_test=ones(size(XBatch));

%  for i=1:50
%          filename = strcat( outputDir, num2str(i),'.bmp');
% 
%      rgbpict = imread(filename);
% rgbpict1 = imresize(rgbpict,1); % don't need giant images for an example
% rgbpict = im2double(rgbpict); % need to cast & scale for this to work
%      factors = permute([0.299 0.587 0.114],[1 3 2]);
% Y601 = sum(bsxfun(@times,rgbpict,factors),3);
% 
% imwrite(Y601,filename,'bmp');
%  end
% Loop over the images in the X array
for i = 1:size(XBatch,1)
    % Define the output filename
    filename = strcat( outputDir, num2str(i),'.bmp');
    
    % Write the image to disk in JPG format
    imwrite(squeeze(XBatch(i,:,:,:)), filename, 'bmp');
end

%%

