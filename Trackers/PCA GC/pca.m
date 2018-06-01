function [W mu] = pca(data, dim)
%%function [W mu] = pca(data, dim)
%%Calculate PCA to obtain basis functions
%%Input:
%%      data: data matrix [nDim*nSample]      
%%      dim:  Reserved Dimensions
%%Output:
%%      mu:   mean vector [nDim*1]
%%      W:    basis functions [nDim*dim]
%%Reference:
%%M.Turk, and A.Pentland. Eigenfaces for Recognition [J]. JOURNAL OF COGNITIVE NEUROSCIENCE, 3:71-86, 1991.
%%Dong Wang, IIAU LAB, DUT, China
%%Version 0.1 2010-09-05
	
[ nDim nSample ] = size(data);
%%Calculate the mean
mu = mean(data,2);  
%%Normalize the data
for num = 1:nSample
    data(:,num) = data(:,num) - mu;
%     data(:,num) = data(:,num)/norm(data(:,num));
end
%%pca
if nDim<nSample
   covM = data*data'/dataNum;
   [ pc , latent , explained ] = pcacov(covM);
   W = pc(:,1:dim);
end
%%fast pca (used in Eigenface)
if nDim>nSample
   covM = data'*data/nSample;
   [ pc , latent , explained ] = pcacov( covM );
   W = data*pc(:,1:dim);
   for num = 1:dim
       W(:,num) = W(:,num)/norm(W(:,num));
   end
end