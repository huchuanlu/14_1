function train_pca_basis
clear all;
clc;

path    = '.\Train\';                       %%The path of training images 
imSize  = [32 32];                          %%The size of training images
dirPath = dir([path,'*','bmp']);
imNum   = length(dirPath);                  %%The number of training images
data    = zeros(imSize(1)*imSize(2), imNum);%%Training data
%% Load training images
for num = 1:imNum
    im = imread([path dirPath(num).name]);
    im = im2double(im);
    im = reshape(im, [imSize(1)*imSize(2), 1]);
    data(:,num) = im;
end
% % %%  Normalize the data
% % for num = 1:imNum
% %     data(:,num) = data(:,num)/norm(data(:,num));
% % end
%% PCA
[W Mu] = pca(data, 16);

save PCADATA.mat W Mu