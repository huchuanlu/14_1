%%
% script: trackparam.m
%     loads data and initializes variables
%
% We would like to thank Jongwoo Lim and David Ross for sharing their codes
% and descriptions. 

% DESCRIPTION OF OPTIONS:
%
% Following is a description of the options you can adjust for
% tracking, each proceeded by its default value.

%*************************************************************
% For a new sequence , you will certainly have to change p.
%       对于一个新的视频序列，需要改变的是p的值
%*************************************************************
%
% To set the other options,
% first try using the values given for one of the demonstration
% sequences, and change parameters as necessary.
%
%*************************************************************
% p = [px, py, sx, sy, theta]; 
% The location of the target in the first frame.
%       目标在第一帧的位置
% px and py are th coordinates of the centre of the box
%   px，py       ：   目标框的中心位置；
%
% sx and sy are the size of the box in the x (width) and y (height)
%   dimensions, before rotation
%   sx，sy       ：   目标框的宽，高
%
% theta is the rotation angle of the box
%   theta        ：   目标框的旋转角度
%
% 'numsample',400,   The number of samples used in the condensation
% algorithm/particle filter.  Increasing this will likely improve the
% results, but make the tracker slower.
%   'numsample'  :    采样次数，采样次数增加会提高效果，但跟踪速度会很慢
%
% 'condenssig',0.01,  The standard deviation of the observation likelihood.
%   'condenssig  ：   观测对象似然标准偏差
%
% 'ff',1, The forgetting factor, as described in the paper.  When
% doing the incremental update, 1 means remember all past data, and 0
% means remeber none of it.
%   'ff'         ：   遗忘因子
%
% 'batchsize',5, How often to update the eigenbasis.  We've used this
% value (update every 5th frame) fairly consistently, so it most
% likely won't need to be changed.  A smaller batchsize means more
% frequent updates, making it quicker to model changes in appearance,
% but also a little more prone to drift, and require more computation.
%   'batchsize'  ：   更新间隔
%
% 'affsig',[4,4,.02,.02,.005,.001]  These are the standard deviations of
% the dynamics distribution, that is how much we expect the target
% object might move from one frame to the next.  The meaning of each
% number is as follows:
%   'affsig'    ：   动态模型，affine变换参数分布"均值","方差"
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = rotation angle (radians, mean is 0)
%    affsig(4) = x scaling (pixels, mean is 1)
%    affsig(5) = y scaling (pixels, mean is 1)
%    affsig(6) = scaling angle (radians, mean is 0)
%
% OTHER OPTIONS THAT COULD BE SET HERE:
%
% 'tmplsize', [32,32] The resolution at which the tracking window is
% sampled, in this case 32 pixels by 32 pixels.  If your initial
% window (given by p) is very large you may need to increase this.
%   'tmplsize'  ：   跟踪窗大小
%
% 'maxbasis', 16 The number of basis vectors to keep in the learned
% apperance model.
%   'maxbasis'  :   最大基向量个数
%

%%******Change 'title' to choose the sequence you wish to run******%%
switch (title) 
%%-------------------------------------------------------------------------
    %
    case 'Caviar1'; 
        p = [145,112,30,79,0];
        opt = struct('affsig',[4,4,.015,.00,.00,.00]);
    %  
    case 'Caviar2';   
        p = [ 152, 68, 18, 61, 0.00 ];
        opt = struct('affsig',[4,4,.005,.00,.00,.00]); 
    %
    case 'Occlusion1'; 
        p = [177,147,115,145,0];
        opt = struct( 'affsig',[4, 4,.005,.00,.00,.00]);  
    %             
    case 'Occlusion2';    
        p = [156,107,74,100,0.00];
        opt = struct('affsig',[4, 4,.006,.015,.00,.00]);               
    %
    case 'Jumping';         
        p = [163,126,33,32,0];
        opt = struct('affsig',[12,12,.005,.00,.00,.00]);                      
    %
    case 'DavidIndoorNew'; 
        p = [194,108,46,60,0.00];
        opt = struct('affsig',[4, 4,.002,.01,.00,.00]);
    %
    case 'Car11';  
        p = [89 140 30 25 0];
        opt = struct('affsig',[4, 4,.005,.00,.00,.00]);  
    %
    case 'Face';  
        p = [293 283 94 114 0];
        opt = struct('affsig',[24,24,.005,.00,.00,.00]);  
    %
    case 'Car4'; 
        p = [245 180 200 150 0];
        opt = struct('affsig',[4,4,.015,.00,.00,.00]); 
    %
    case 'Deer';  
        p = [350, 40, 100, 70, 0];
        opt = struct('affsig',[12,12,.005,.000,.000,.000]); 
    case 'Leno';
        p = [271+56,48+73,112,146,0];
        opt = struct('affsig',[6,6,.005,.005,.00,.00]);
    case 'Walking';
        p = [692+12, 439+40, 24, 80,0];
        opt = struct('affsig',[4,4,.005,.00,.00,.00]);    %
    case 'Singer1';  
        p = [100, 200, 100, 300, 0];
        opt = struct('affsig',[4,4,.015,.00,.00,.00]); 
    otherwise;  error(['unknown title ' title]);
end
%%******Change 'title' to choose the sequence you wish to run******%%

%%***************************Data Path*****************************%%
dataPath = [ 'Data\' title '\'];
%%***************************Data Path*****************************%%