clear; 
close all; 
clc;
T=tic;

%% Perform Generic Addpaths
addpath('src'); 
addpath('data');
addpath( genpath( ['../../../interfaces'] ) );

%% Synapse Benchmark for benckmarking performance against different types
%  of feature descriptors with a standard gentle boost and libsvm based
%  classifier. The interface is pretty simple ... it comprises a feature
%  extraction stage, classification stage and a validation stage
SAVE_LEARNER = false;
RECOMPUTE_INIT_PARAM = true;
RECOMPUTE_TEXTON = true;
RECOMPUTE_FEATURE = true;
fprintf(1,'Setting initial prarmeters!\n');
tic
if RECOMPUTE_INIT_PARAM
    bmark = f_initializeParams();
else
%     load('data/bmark_half_each.mat');
    load('data/bmark_half_each_NEW.mat');
    bmark.featLib = 1 : 12 ;
    bmark.learnLib = 1 : 2 ;
end

toc

%% Create Texton Dictionary
if RECOMPUTE_TEXTON
    bmark.FILTERINFO = TextonCreator(bmark, 512);
else
    load('/cluster/home/retinamap/synapseProject/source/synapseDetector/benchmark/data/FILTERINFO.mat');
    bmark.FILTERINFO = FILTERINFO;
    clear FILTERINFO;
end

%% Feature Extraction
%  1.   Assume that images are stored as folders with names beginning with
%  class01, class02 and so on ... Further read any image with a .png or
%  .jpg extension from them and collect all images into a cell array, with
%  labels being stored in a very similar type cell array  ... subsequently
%  the data is split in some order to training and testing phases ...
%  2.   Since feature dimensionality is bound to change it is good to store
%  computed features in a cell array corresponding to each image or
%  training input ... Further
%  Task   = synapsedetection
%  SFldr  = train and test for respective images
%  SSFldr = class01, class02 and so on till number of classes

%% Extract Features
bmark.RECOMPUTE_FEATURE = true;
fprintf(1,'\nStarting Extracting Features!\n');
tic
if RECOMPUTE_FEATURE
    [trainInfo testInfo] = f_extractFeatures(bmark);
else
    load('trainInfo.mat');
%     numLimit = 100;
%     for iter = 1 : 2
%         bmark.trainFiles{iter} = bmark.trainFiles{iter}(1:numLimit);
%         bmark.testFiles{iter} = bmark.testFiles{iter}(1:numLimit);
%     end
%     for iter = 1 : 4
%         testInfo{iter}.testFileName     = testInfo{iter}.testFileName(1:numLimit);
%         testInfo{iter}.testBagLabels    = testInfo{iter}.testBagLabels(1:numLimit);
%         testInfo{iter}.testBags         = testInfo{iter}.testBags(1:numLimit);
%         trainInfo{iter}.trainFileName   = trainInfo{iter}.trainFileName(1:numLimit);
%         trainInfo{iter}.trainBagLabels  = trainInfo{iter}.trainBagLabels(1:numLimit);
%         trainInfo{iter}.trainBags       = trainInfo{iter}.trainBags(1:numLimit);
%     end
end
toc



%% Classification
metIter = 1;
for learnIter = 1:numel( bmark.learnLib )
    for featIter = 1:numel( bmark.featLib )
        tic
        display(['Learning using ' bmark.learners{learnIter} ', with feature ' bmark.features{bmark.featLib(featIter)}]);
        trainInfo{metIter}.learn = bmark.learnLib(learnIter);
        % 1.   Gentle Boost where the rule is always that the input data points are
        % stored as rows in a matrix
        % 2.   Support Vector Machine with an RBF kernel
        % 3.   Multi Kernel Learning, where the kernel matrices are computed from
        % the multiple features computed from the data
        
        [predInfo{metIter} trainInfo{metIter} testInfo{metIter}] = f_classifyFeatures(trainInfo{metIter}, testInfo{metIter}, SAVE_LEARNER);
        predInfo{metIter}.bmarkSetting = [bmark.features( bmark.featLib( featIter ) )  bmark.learners( bmark.learnLib(learnIter) )];
        predictions{featIter, learnIter} = predInfo{metIter};
        metIter = metIter+1;
        toc
    end
end
%% Validation
% 1.   F-Measure and Precision Recall Curves .. variations are with respect
% to the detector thresholds ...
% 2.   ROC Curves
% 3.   Rand Index
% PLOT Information are all stored in .mat files named after the feature
% extraction, classification and validation procedures in a results folder
% which is the same as the one where data is housed
%%%%%%%%%%% cvErr = dataQuality( testInfo.testMatLabels, predInfo.predMatLabels);
auxInfo.INSTEVAL = true; auxInfo.taskName='binClass'; SAVE_FIG = false;
validateInfo = f_validateResults(testInfo, predInfo, auxInfo, SAVE_FIG);
toc(T)
return


metIter = 1;
for featIter = 1:numel( bmark.featLib )
    %bmark.FILTERINFO.ID = bmark.featLib( featIter );
    %[trainInfo{metIter} testInfo{metIter}] = extractFeatures(bmark);
%     [predInfoMIL{metIter} trainInfoMIL{metIter} testInfoMIL{metIter}] = f_classifyMIL(trainInfo{metIter}, testInfo{metIter});
%     metIter = metIter+1;
end
auxInfo.INSTEVAL = false; auxInfo.taskName='milClass';
validateResults(testInfoMIL, predInfoMIL, auxInfo);