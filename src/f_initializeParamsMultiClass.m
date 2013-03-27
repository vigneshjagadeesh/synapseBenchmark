function bmark = initializeParamsMultiClass()
if( ispc )
    bmark.parDir = 'C:/Users/vignesh/Dropbox/synapseProject/';
    bmark.dataDir = 'C:/researchCode/dataBase/connectomeMultiClassLocations/';
else
    bmark.parDir = '/cluster/home/vignesh/synapseProject/';
    bmark.dataDir = '/media/OS/researchCode/dataBase/connectomeMultiClassLocations/';
end
addpath( genpath( [bmark.parDir 'interfaces'] ) );
bmark.NUM_CLASSES = 10;
bmark.types = {'bc', ... %1
               'yac', ... %2
               'gac', ... %3
               'gc', ... %4
               'gj', ... %5
               'hc', ... %6
               'mc', ... %7
               'mg', ... %8
               'ribb', ... %9
               'yac'}; 
for classIter = 1:bmark.NUM_CLASSES
bmark.dirs{classIter}          = [bmark.dataDir  bmark.types{classIter} '/001/'];    
end
for iter = 1:bmark.NUM_CLASSES
    currFiles = dir( [bmark.dirs{iter} '0*'] );
    currFiles = currFiles(1:100);
    bmark.trainDir{iter} = bmark.dirs{iter};
    bmark.testDir{iter}  = bmark.dirs{iter};
    numFiles  = numel( currFiles );
    shuffler  = randperm( numFiles );
    trainIndex = shuffler( 1:ceil(.25*numel(shuffler)) );
    testIndex  = shuffler( ceil(.25*numel(shuffler))+1:end );
    bmark.trainFiles{iter} = currFiles(trainIndex);
    bmark.testFiles{iter}  = currFiles(testIndex);
end

FILTERINFO.N         = 256;
FILTERINFO.FGabor         = cbi_gabordictionary(4, 6, FILTERINFO.N, [0.05 0.4], 0); %
[FILTERINFO.F FILTERINFO.FFreq] = makeRFSfilters(FILTERINFO.N);
FILTERINFO.gistFilt  = createGabor([8 8 4], FILTERINFO.N);

%% Create Texton Dictionary
if( 0 )
    FALL = [];    
    FResp = convTexture(I, FILTERINFO.F);
    FALL = [FALL; FResp];    
    FALL = FALL(1:16:end, :); 
    textonDict = ( vgg_kmeans(FALL', 100 ) )';  save('preTextonsMosaic', 'textonDict');
    %textonDict = kmeans(FALL, 10 );  save('preTextonsMosaic', 'textonDict');
else
    load('preTextons'); 
end
FILTERINFO.textonDict = textonDict;
FILTERINFO.equalizeImg = false;
FILTERINFO.patchType = 'nonoverlap';
% FILTERINFO.mapping   = getmapping(8,'u2');
FILTERINFO.numberGistBlocks = 4;

FILTERINFO.ID           = 1;
bmark.learn             = 2;
bmark.normalizeFeatures = 1;
bmark.validate          = 1;
bmark.FILTERINFO        = FILTERINFO;
bmark.featLib           = 1;
bmark.learnLib          = 1;
% Set benchmark parameters
bmark.tasks      = {'synapsedetection'};
bmark.features   = { 'gaborwavelets' , ... %1
                     'texton' , ...
                     'textonEnergy', ...
                     'morph1' , ... 
                     'morph2', ...
                     'gist', ... 
                     'lbp', ...
                     'lbpr', ...
                     'ray', ...
                     'radon', ...
                     'zernike', ...
                     'cfmt' };%12
bmark.learners   = { 'svmrbf', 'gboost' , 'mkl'  };
bmark.validate   = { 'fm'    , 'roc'    , 'rand' };
bmark.resizeImg = true;
