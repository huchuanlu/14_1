function toy_demo_pca_GC

%% Load Basis Vectors and Mean from PCADATA
load PCADATA.mat;       
imSize  = [32 32];

%% Parameter Setting
param = [];
param.lambda = 0.5*0.08^2; 
param.lambda_i_j = 0.02; 
param.maxLoopNum = 10; 
param.imHei = 32;
param.imWid = 32;

%% Load Test Images
inPath    = ['./Test/']; 
dirPath = dir([inPath,'*','bmp']);
imNum   = length(dirPath);
data    = zeros(imSize(1)*imSize(2),imNum);
imTemp  = [];
for num = 1:imNum
    im = imread([inPath dirPath(num).name]);
    im = im2double(im);
    imTemp = [ imTemp im ];
    im = reshape(im,[imSize(1)*imSize(2),1]);
    data(:,num) = im;
end
imwrite(uint8(255*imTemp),'Ori.bmp');

%% Centralizing
for num = 1:imNum
    data(:,num) = data(:,num) - Mu;
end              
    
%% L1 Minimization
alpha = [];
for num = 1:imNum
    tic;
    alpha = [alpha pca_GC(data(:,num), W, param)];
    toc;
end

%% Occlusion
imTemp  = [];
for num = 1:imNum
    alphaOcc = abs(alpha(size(W,2)+1:end,num));
    alphaOcc = reshape(alphaOcc, [imSize(1), imSize(2)]);
    imTemp = [ imTemp alphaOcc ];
end
imwrite(uint8(255*imTemp),'Occ.bmp');

%% Reconstrution
imTemp  = [];
for num = 1:imNum
    alphaRec = alpha(1:size(W,2),num);
    imRec = W*double(alphaRec)+Mu;
    imRec = reshape(imRec, [imSize(1) imSize(2)]);
    imTemp = [ imTemp imRec ];
end
imwrite(uint8(255*imTemp),'Rec.bmp');

%%  Final Results
imOri = imread('Ori.bmp');
imOcc = imread('Occ.bmp');
imRS(:,:,1) = imOri + 0.2*imOcc;
imRS(:,:,2) = imOri;
imRS(:,:,3) = imOri + 0.2*(255-imOcc);
imwrite(uint8(imRS),'RS.bmp');
