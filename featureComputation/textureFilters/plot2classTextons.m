function plot2classTextons( featureClass, algParam)
NUM_PLOTS = 16;
figure(100);
numTrain = size( featureClass.trainSet{1}, 1 );
for iter = 1:NUM_PLOTS%numTrain
    subplot( ceil(NUM_PLOTS/5), 5, iter);
    bar( 1:sum(algParam.numTextons), featureClass.trainSet{1} (iter, :) );
    title(['Syn Mass' num2str(sum( featureClass.trainSet{1} (iter, 1:algParam.numTextons(1)) )) 'Non Mass' num2str(sum( featureClass.trainSet{1} (iter, 1+algParam.numTextons(1):end)) )]);
    axis([0 sum(algParam.numTextons) 0 0.1]);
end

figure(101);
numTrain = size( featureClass.trainSet{2}, 1 );
for iter = 1:NUM_PLOTS%numTrain
    subplot( ceil(NUM_PLOTS/5), 5, iter);
    bar( 1:sum(algParam.numTextons), featureClass.trainSet{2} (iter, :) );
    title(['Syn Mass' num2str(sum( featureClass.trainSet{2} (iter, 1:algParam.numTextons(1)) )) 'Non Mass' num2str(sum( featureClass.trainSet{2} (iter, 1+algParam.numTextons(1):end)) )]);
    axis([0 sum(algParam.numTextons) 0 0.1]);
end

NUM_PLOTS = 8;
figure(102);
numTest = size( featureClass.testSet{1}, 1 );
for iter = 1:NUM_PLOTS%numTest
    subplot( ceil(NUM_PLOTS/5), 5, iter);
    bar( 1:sum(algParam.numTextons), featureClass.testSet{1} (iter, :) );
    title(['Syn Mass' num2str(sum( featureClass.testSet{1} (iter, 1:algParam.numTextons(1)) )) 'Non Mass' num2str(sum( featureClass.testSet{1} (iter, 1+algParam.numTextons(1):end)) )]);
    axis([0 sum(algParam.numTextons) 0 0.1]);
end

figure(103);
numTest = size( featureClass.testSet{2}, 1 );
for iter = 1:NUM_PLOTS%numTest
    subplot( ceil(NUM_PLOTS/5), 5, iter);
    bar( 1:sum(algParam.numTextons), featureClass.testSet{2} (iter, :) );
    title(['Syn Mass' num2str(sum( featureClass.testSet{2} (iter, 1:algParam.numTextons(1)) )) 'Non Mass' num2str(sum( featureClass.testSet{2} (iter, 1+algParam.numTextons(1):end)) )]);
    axis([0 sum(algParam.numTextons) 0 0.1]);
end