function param = estwarp_condens_PCA_GC(frm, tmpl, param, opt)
%% function param = estwarp_condens_PCA_GC(frm, tmpl, param, opt)
%%      frm:                 Frame image;
%%      tmpl:                PCA model;
%%        -tmpl.mean:           PCA mean vector
%%        -tmpl.basis:          PCA basis vectors
%%        -tmpl.eigval:         The eigenvalues corresponding to basis vectors
%%        -tmpl.numsample:      The number of samples
%%      param:
%%        -param.est:           The estimation of the affine state of the tracked target 
%%        -param.wimg:          The collected sample for update
%%      opt:                 
%%        -opt.numsample:       The number of sampled candidates
%%        -opt.condenssig:      The variance of the Guassian likelihood function
%%        -opt.ff:              Forgotten factor;
%%        -opt.bacthsize:       The number of collected samples for update
%%        -opt.affsig:          The variance of affine parameters
%%        -opt.tmplsize:        The size of warpped image patch
%%        -opt.maxbasis:        The maximum number of basis vectors
%%        -opt.lssParam:        Parameters for sloving soft-thresold squares regression
%%DUT-IIAU-DongWang-2013-03-27
%%Dong Wang, Huchuan Lu, Minghsuan Yang, Least Soft-thresold Squares
%%Tracking. CVPR 2013.
%%http://ice.dlut.edu.cn/lu/index.html
%%wangdong.ice@gmail.com
%%
%%************************1.Candidate Sampling************************%%
%%Sampling Number
n = opt.numsample;
%%Data Dimension
sz = size(tmpl.mean);
N = sz(1)*sz(2);
%%Particle Filteri
if ~isfield(param,'param')
  param.param = repmat(affparam2geom(param.est(:)), [1,n]);
else
  cumconf = cumsum(param.conf);
  idx = floor(sum(repmat(rand(1,n),[n,1]) > repmat(cumconf,[1,n])))+1;
  param.param = param.param(:,idx);
end

%%Affine Parameter Sampling
randMatrix = randn(6,n);
param.param = param.param + randMatrix.*repmat(opt.affsig(:),[1,n]);
%%Extract or Warp Samples which are related to above affine parameters
wimgs = warpimg(frm, affparam2mat(param.param), sz);
%%************************1.Candidate Sampling************************%%

%%*******************2.Calucate Likelihood Probablity*******************%%
%%Remove the average vector or Centralizing
diff = repmat(tmpl.mean(:),[1,n]) - reshape(wimgs,[N,n]);
%
if  (size(tmpl.basis,2) == 16)
    weights = param.weights;
    basisT  = tmpl.basis((weights==1),:);
    diffT   = diff((weights==1),:);
    basisTT = basisT'*basisT;
    coeffT  = inv(basisTT+eps*eye(size(basisTT)))*basisT'*diffT;
    diffT   = diffT - basisT*coeffT;
    param.conf = exp(-(0.5*sum(diffT.^2))./opt.condenssig)';
else
    param.conf = exp(-(0.5*sum(diff.^2))./opt.condenssig)';
end
%%*******************2.Calucate Likelihood Probablity*******************%%

%%*****3.Obtain the optimal candidate by MAP (maximum a posteriori)*****%%
param.conf = param.conf ./ sum(param.conf);
[~,maxidx] = max(param.conf);
param.est = affparam2mat(param.param(:,maxidx));
%%*****3.Obtain the optimal candidate by MAP (maximum a posteriori)*****%%

%%************4.Collect samples for model update(Section III.C)***********%%
wimg = wimgs(:,:,maxidx);
if  (size(tmpl.basis,2) == 16)
    [~, ~, weights] = pca_gc(tmpl.mean(:)-wimg(:), tmpl.basis, opt.param);
%     param.weights = weights;
    param.wimg = (weights==1).*wimg(:) + (weights~=1).*tmpl.mean(:);
    param.wimg = reshape(param.wimg, size(wimg));
    param.weights = 1 - (reshape((weights~=1), size(wimg)));
else
    param.wimg = wimg;
    param.weights = (ones(size(wimg)));
end
%%************4.Collect samples for model update(Section III.C)***********%%