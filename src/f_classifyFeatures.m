function [predInfo trainInfo testInfo] = f_classifyFeatures(trainInfo, testInfo, SAVE_LEARNER )

%% Data Collection
NUM_PATCHES = size(trainInfo.trainBags{1},1);
NUM_TEST_BAGS = numel(testInfo.testBags);

if( sum ( unique(trainInfo.instLab(:)) ) == 2 )
    trainMatLabel = repmat( trainInfo.trainBagLabels', NUM_PATCHES, 1);
else
    trainMatLabel = [trainInfo.instLab(:); 2*ones(sum(trainInfo.trainBagLabels==2)*NUM_PATCHES, 1)];
end
testMatLabel = repmat( testInfo.testBagLabels', NUM_PATCHES, 1);
% featQuality = featureQuality(trainMat, trainMatLabel(:));

trainMat = zeros(numel(trainInfo.trainBags),numel(trainInfo.trainBags{1}.currFeat));
for iter = 1 : numel(trainInfo.trainBags)
    trainMat(iter,:) = trainInfo.trainBags{iter}.currFeat;
end

testMat = zeros(numel(testInfo.testBags),numel(testInfo.testBags{1}.currFeat));
for iter = 1 : numel(testInfo.testBags)
    testMat(iter,:) = testInfo.testBags{iter}.currFeat;
end

%% LEARNER
if( trainInfo.learn == 1),
    svmModel = svmtrain( trainMatLabel(:), trainMat, '-b 1' );
    if SAVE_LEARNER
        save(['ComputedClassifier/svm_' trainInfo.feat '.mat'],'svmModel')
    end
    [predMatLabel accuracy probEst] = svmpredict( testMatLabel(:), testMat, svmModel, '-b 1' );
elseif( trainInfo.learn == 2),
    [predMatLabel probEst boostModel] = boostClassifier( trainMat, trainMatLabel(:), testMat  );
    if SAVE_LEARNER
        save(['ComputedClassifier/boost_' trainInfo.feat '.mat'],'boostModel')
    end
    predMatLabel = double( predMatLabel );
elseif( trainInfo.learn == 3 ),
    data.TRNfeatures = trainMat'; data.TRNlabels = trainMatLabel(:); data.TSTfeatures = testMat'; data.TSTlabels = testMatLabel(:); data.TYPEker = 1; data.TYPEreg = 0;
    predMatLabel = GMKLwrapper(data); probEst = predMatLabel;
else nbc = NaiveBayes.fit(trainMat,trainMatLabel(:)) ;
    predMatLabel = nbc.predict( testMat );
end
testInfo.testMatLabels = testMatLabel; predInfo.predMatLabels = predMatLabel;

%% Bag Level Predictions are made here
bagLabeler = reshape( predMatLabel, size(testInfo.testBags{1}, 1), NUM_TEST_BAGS );
predInfo.predBagLabels = ( max( bagLabeler, [], 1) )'; % Making it a column

%% Vary Thresholds for generating F-Measures
threshCtr = 1;
for thresh = .9:-.1:.3
    bagProb = 2 - reshape( probEst(:,1) > thresh, NUM_PATCHES, NUM_TEST_BAGS );
    labelVariations(:, threshCtr ) = bagProb(:);
    bagVariations = reshape( bagProb, size(testInfo.testBags{1}, 1), NUM_TEST_BAGS );
    predInfo.predBagVariations(:, threshCtr) = max( bagVariations, [], 1);
    threshCtr = threshCtr + 1;
end
predInfo.predMatVariations = labelVariations;

%% Visualize the data to see detections
colorsIndex = rand( trainInfo.numClasses, 3 );
patchDim = sqrt( size(bagLabeler, 1 ));
try,
    display( num2str(viggu) );
    for iter = 1:size(bagLabeler, 2)
        currLab = reshape( bagLabeler(:,iter), [patchDim patchDim] );
        currI = imread(testInfo.testFileName{iter});
        %if( FILTERINFO.resizeImg ), currI = imresize( currI, [256 256]); end
        if( size(currI,3) > 1 ),   currI =  rgb2gray( currI ); end
        simBox(currI, currLab, 256, colorsIndex);
        title(['Classified Image Label ' num2str(max(currLab(:))) 'GT: ' num2str(testInfo.testBagLabels(iter,1))]);
        pause(.5);
        
    end
catch me,  display('PNG Error'); end