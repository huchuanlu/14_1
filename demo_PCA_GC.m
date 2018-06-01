%%
clear all;
clc;

%%******Change 'title' to choose the sequence you wish to run******%%
title = 'Occlusion1'; 
% title = 'Occlusion2';
% title = 'Caviar1';
% title = 'Caviar2';
% title = 'Leno';
% title = 'Walking';
% title = 'DavidIndoorNew';
% title = 'Car4';
% title = 'Car11';
% title = 'Deer';
% title = 'Jumping';
% title = 'Face';

%%******Change 'title' to choose the sequence you wish to run******%%


%%***********************1.Initialization****************************%%
addpath(genpath('./Trackers')); 
addpath(genpath('./Evaluation'));
trackparam;
%%1.1 Initialize variables:
rand('state',0);    randn('state',0);
if ~exist('opt','var')        opt = [];  end
if ~isfield(opt,'tmplsize')   opt.tmplsize = [32,32];  end                  
if ~isfield(opt,'numsample')  opt.numsample = 600;  end                     
if ~isfield(opt,'affsig')     opt.affsig = [4,4,.01,.00,.00,.00];  end    
if ~isfield(opt,'condenssig') opt.condenssig = 0.1;  end                   
if ~isfield(opt,'maxbasis')   opt.maxbasis = 16;  end                       
if ~isfield(opt,'batchsize')  opt.batchsize = 5;  end                      
if ~isfield(opt,'ff')         opt.ff = 1.0;  end   
if ~isfield(opt,'param') 
    opt.param = [];
    opt.param.lambda = 0.5*0.08^2; 
    opt.param.lambda_i_j = 0.02; 
    opt.param.maxLoopNum = 5; 
    opt.param.imHei = 32;
    opt.param.imWid = 32;
end

%1.2 Load functions and parameters:
param0 = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];      
param0 = affparam2mat(param0);                  %%The affine parameter of 
                                                %%the tracked object in the first frame    
temp = importdata([dataPath 'datainfo.txt']);   %%DataInfo: Width, Height, Frame Number
TotalFrameNum = temp(3);                        %%Total frame number
frame = imread([dataPath '1.jpg']);             %%Load the first frame
if  size(frame,3) == 3
    framegray = double(rgb2gray(frame))/256;    %%For color images
else
    framegray = double(frame)/256;              %%For Gray images
end
%1.3 Load functions and parameters:
tmpl.mean = warpimg(framegray, param0, opt.tmplsize);    
tmpl.basis = [];                                        
tmpl.eigval = [];                                       
tmpl.numsample = 0;                                    
%
param = [];
param.est = param0;                                     
param.wimg = tmpl.mean; 
param.errRatio = [];
param.weights  = ones(opt.param.imHei*opt.param.imWid, 1);
% draw initial track window
drawopt = drawtrackresult([], 0, frame, tmpl, param);
% disp('resize the window as necessary, then press any key..'); pause;
%%***********************1.Initialization****************************%%

%%***********************2.Object Tracking***************************%%
wimgs = [];     %%Data buffer
result = [];    %%Tracking results
duration = 0; 
for num = 1:TotalFrameNum
    %%2.1 Load the (num)-th frame
    frame = imread([dataPath int2str(num) '.jpg']);
    if  size(frame,3) == 3
        framegray = double(rgb2gray(frame))/256;
    else
        framegray = double(frame)/256;
        frame = cat(3, [], frame, frame, frame);
    end
    tic;
    %%2.2 Do tracking
    param = estwarp_condens_PCA_GC(framegray, tmpl, param, opt);
    result = [ result; param.est' ];
    imwrite(param.weights, [ './OccMap/' title '/' num2str(num) '.jpg']);
    %%2.3 Update model
    wimgs = [wimgs, param.wimg(:)]; 
    if  (size(wimgs,2) >= opt.batchsize && ~isempty(wimgs))   
        %%(1)Incremental PCA
        [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
        sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);   
        %%(2)Clear data buffer
        wimgs = [];     
        %%(3)Keep (opt.maxbasis) basis vectors
        if  (size(tmpl.basis,2) > opt.maxbasis)          
            tmpl.basis  = tmpl.basis(:,1:opt.maxbasis);   
            tmpl.eigval = tmpl.eigval(1:opt.maxbasis);
        end
    end
    duration = duration + toc; 
    %%2.4 Draw tracking results
    drawopt = drawtrackresult(drawopt, num, frame, tmpl, param);   
end     
fprintf('%d frames took %.3f seconds : %.3fps\n',num, duration, num/duration);
fps = num/duration;
%%***********************2.Object Tracking***************************%%

%%*************************3.STD Results*****************************%%
PCAGCCenterAll  = cell(1,TotalFrameNum);      
PCAGCCornersAll = cell(1,TotalFrameNum);
for num = 1:TotalFrameNum
    if  num <= size(result,1)
        est = result(num,:);
        [ center corners ] = p_to_box([32 32], est);
    end
    PCAGCCenterAll{num}  = center;      
    PCAGCCornersAll{num} = corners;
end
save([ title '_PCAGC_rs.mat'], 'PCAGCCenterAll', 'PCAGCCornersAll', 'fps');
%%*************************3.STD Results*****************************%%
load([ dataPath title '_gt.mat']);
%
[ overlapRate ] = overlapEvaluationQuad(PCAGCCornersAll, gtCornersAll, frameIndex);
mOverlapRate = mean_no_nan(overlapRate)
%
mSuccessRate = sum(overlapRate>0.5)/length(overlapRate);
%
[ centerError ] = centerErrorEvaluation(PCAGCCenterAll,  gtCenterAll, frameIndex);
mCenterError = mean_no_nan(centerError)
