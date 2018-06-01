function [alpha coeff weights] = pca_gc(data, W, param)
%%
%%  function alpha = pca_gc(data, W, param)
%%  ���룺
%%      data:       ���Ļ������������-������
%%      W:          PCA�Ļ�����
%%      param:
%%          param.lambda            һԪ�������             
%%          param.lambda_i_j        ��Ԫ�������
%%          param.maxLoopNum        ���ѭ������
%%          param.imHei             ��
%%          param.imWid             ��
%%  �����
%%      coeff:      ϵ��
%%      weights��   Ȩ��

edges   = edges4connected(param.imHei,param.imWid);
dim     = size(W,2);
len     = size(W,1);
coeff   = zeros(dim,1);
weights = ones(len,1);

for num = 1:param.maxLoopNum
%% (1)Weighted Least Square Regression 
    WT    = W(weights~=0,:);
    WTT   = WT'*WT; 
    coeff = inv(WTT+eps*eye(size(WTT)))*WT'*data(weights~=0);
    err   = data-W*coeff;
%% (2)Max Flow <=> Min Cut
    A = sparse(edges(:,1), edges(:,2), param.lambda_i_j, len, len, 4*len);
    T = sparse([  0.5*err.^2, param.lambda*ones(len,1) ]);
    [~,labels] = maxflow(A,T);
    weights = labels;
%% (3)Avoid Overfitting:
    if  mean(weights) < 0.25
        param.lambda_i_j = param.lambda_i_j*0.75;
        weights = ones(len,1);
        num = 1;
    end
end

alpha = [coeff; weights];

