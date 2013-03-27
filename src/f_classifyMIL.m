function [predInfo trainInfo testInfo] = f_classifyMIL(trainInfo, testInfo )
    param.c = 100; param.gamma = .05; param.thresh = 40;
    trainKernelMat = constructKernel(trainInfo.trainBags, trainInfo.trainBags, param);
    testKernelMat = constructKernel(testInfo.testBags, trainInfo.trainBags, param);
    opt = ['-c ',num2str(param.c),' -t 4 -s 0'];
    trainKernel = [(1:size(trainKernelMat, 1))' trainKernelMat];
    testKernel = [(1:size(testKernelMat, 1))' testKernelMat];
    model = svmtrain(trainInfo.trainBagLabels, trainKernel, opt);
    predLabels = svmpredict(testInfo.testBagLabels, testKernel, model );
    figure(1);
    ctr = 1;
    try,
    for iter = 1:numel(testInfo.testFileName), 
        if( mod(iter,25)== 0 )
            %imshow(imread([testInfo.testFileName{iter}])); title( ['Pred Label: ' num2str(predLabels(iter) ) ' Gt: ' num2str(testInfo.testBagLabels(iter) )]  ); pause(1);
        end
    end
    CM = confMatrix( testInfo.testBagLabels(:)', predLabels(:)', trainInfo.numClasses ); confMatrixShow( CM, trainInfo.types, {'FontSize',20}, [], 0 ); title('confusion matrix','FontSize',24);
    pause(5);
    catch me,
    end
    pollerAcc = sum( predLabels(:) ~= testInfo.testBagLabels(:) ) ./ numel(testInfo.testBagLabels);
    predInfo.predBagLabels = predLabels;
    predInfo.predBagVariations = predLabels;