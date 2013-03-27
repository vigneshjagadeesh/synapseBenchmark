function [cvSVM cvBoost cvKnn] = featureQuality(trainData, trainLabels )

% A stratified partition is preferred to evaluate classification
% algorithms.
cp = cvpartition(trainLabels,'k',10);
classK = @(xtrain, ytrain,xtest)(knnclassify(xtest,xtrain,ytrain));
cvKnn = crossval('mcr',trainData,trainLabels,'predfun', classK,'partition',cp);


if( numel(unique(trainLabels)) <= 2 )
classB = @(xtrain, ytrain,xtest)(boostClassifier(xtrain,ytrain,xtest));
cvBoost = crossval('mcr',trainData,trainLabels,'predfun', classB,'partition',cp);
else
    cvBoost = 0;
end

classS = @(xtrain, ytrain,xtest)(svmClassifier(xtrain,ytrain,xtest));
cvSVM = crossval('mcr',trainData,trainLabels,'predfun', classS,'partition',cp);


display(['SVM Error ' num2str(cvSVM) ' Boost Error ' num2str(cvBoost) ' Knn Error ' num2str(cvKnn)]);

trainLabels = nominal(trainLabels);
yorder = unique(trainLabels);
fK = @(xtr,ytr,xte,yte) confusionmat(yte,knnclassify(xte,xtr,ytr),'order',yorder);
cfMatK = crossval(fK,trainData,trainLabels,'partition',cp);
% cfMat is the summation of 10 confusion matrices from 10 test sets.
nclasses = sqrt( size(cfMatK, 2) );
cfMatK = reshape(sum(cfMatK),nclasses,nclasses)

if( numel(unique(trainLabels)) <= 2 )
fB = @(xtr,ytr,xte,yte) confusionmat(yte,boostClassifier(xtr,ytr,xte),'order',yorder);
cfMatB = crossval(fB,trainData,trainLabels,'partition',cp);
% cfMat is the summation of 10 confusion matrices from 10 test sets.
cfMatB = reshape(sum(cfMatB),nclasses,nclasses)
end
fS = @(xtr,ytr,xte,yte) confusionmat(yte,svmClassifier(xtr,ytr,xte),'order',yorder);
cfMatS = crossval(fS,trainData,trainLabels,'partition',cp);
% cfMat is the summation of 10 confusion matrices from 10 test sets.
cfMatS = reshape(sum(cfMatS),nclasses,nclasses)