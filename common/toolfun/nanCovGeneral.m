function varCovMatrix = nanCovGeneral( matrixInput )
%
%NANCOVGENERAL calculates covariance matrix, ignoring NaNs, in a general
% way. The orinal matlab function removes all rows where NaNs are present,
% which leads to lost of information for multiple repetitons when only one 
% observation have a NaN value. 
% For this general function, each observation (column) will be compare with
% all the % other observations as pairs. It will allow the function to preserve
% information, because it will remove the row only for the individual comparisons.
%
% INPUT
%  
%   matrixInput:   matrix whose will be calculate the cov 
%  
% OUTPUT
%
%  varCovMatrix: covariance-variance matrix  
%
%   
% Luciana de Oliveira, October 2017.

%% Input

% reserve space for the covMatrix
sizeCov=size(matrixInput,2);

varCovMatrix=zeros(sizeCov);

%% calculate varCovMatrix and fill the values in the diagonal

% %first calculate the variance and fill it in the diagonal
% 
for indexDiag= 1:sizeCov
    
    varMatrix=nanvar(matrixInput(:,indexDiag));
    
    %fill the value in the diagonal of matrix 
    varCovMatrix(indexDiag,indexDiag)=varMatrix;
end

%% calculate the cov for all the combinations between the observations

if size(matrixInput,2)>1

indexCov= 1:sizeCov;
combIndexCov=nchoosek(indexCov,2); 
for indexCov=1:size(combIndexCov,1)
   covMatrixTemp=nancov(matrixInput(:,combIndexCov(indexCov,1)),matrixInput(:,combIndexCov(indexCov,2)));
   varCovMatrix(combIndexCov(indexCov,1),combIndexCov(indexCov,2))=covMatrixTemp(1,2);
   varCovMatrix(combIndexCov(indexCov,2),combIndexCov(indexCov,1))=covMatrixTemp(2,1);
end
end

end

