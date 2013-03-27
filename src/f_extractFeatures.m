function [trainInfo testInfo] = f_extractFeatures(bmark)

numFeat = numel(bmark.featLib);
trainInfo = cell(1,numFeat);
testInfo  = cell(1,numFeat);

for metIter = 1 : numFeat
    trainInfo{metIter}.numClasses    = numel( bmark.trainFiles );
    trainInfo{metIter}.types         = bmark.types;
    trainInfo{metIter}.learn         = bmark.learnLib(1);
    trainInfo{metIter}.instLab       = 2;
    trainInfo{metIter}.feat          = bmark.features{bmark.featLib(metIter)};
end
fid = fopen('unstableImage.txt','w');
if bmark.RECOMPUTE_FEATURE
    N_HALF = round(bmark.FILTERINFO.N/2);
    %% Compute Training Features
    trainCtr = 1;
    for classIter = 1:numel( bmark.trainFiles )
        fprintf(1, ['training class ' num2str(classIter) ': totally ' num2str(numel(bmark.trainFiles{classIter})) ' samples!\n']);
        for fileIter = 1:numel(bmark.trainFiles{classIter})
            for featIter = 1:numel( bmark.featLib )
                %trainInfo{featIter}.trainFileName{trainCtr} = [ bmark.dataDir bmark.trainFiles{classIter}( fileIter ).name ];
                trainInfo{featIter}.trainFileName{trainCtr} = [bmark.trainFiles{classIter}( fileIter ).name ];
            end
            try,        
                        I = imread( trainInfo{1}.trainFileName{trainCtr} );
                        [H W C] = size(I); H_HALF = round(H/2); W_HALF = round(W/2);
                        I = I(H_HALF-N_HALF:H_HALF+N_HALF-1,W_HALF-N_HALF:W_HALF+N_HALF-1);
                        if( C > 1 ), I = rgb2gray(I); end
                        if( bmark.resizeImg), I = imresize(I,[1024 1024]); end
                        fprintf(1, [num2str(fileIter) ',']);
                        if mod(fileIter,10) == 0 ;    fprintf(1,'\n');        end
            catch me,   display('PNG ERROR!');  end
            for featIter = 1:numel( bmark.featLib )
                bmark.FILTERINFO.ID = bmark.featLib(featIter);
                [imgbagTest trainInfo{featIter}.trainBags{trainCtr, 1}.currFeat] = cbi_bagimg(I, bmark.FILTERINFO);
                trainInfo{featIter}.trainBagLabels( trainCtr,1 ) = classIter;
            end
            trainCtr = trainCtr + 1;
        end
        fprintf(1,[ '\nFinished Class ' num2str(classIter) ' in training features\n']);
    end

    %% Compute Testing Features
    testCtr = 1;
    for classIter = 1:numel( bmark.trainFiles )
        fprintf(1, ['testing class ' num2str(classIter) ': totally ' num2str(numel(bmark.testFiles{classIter})) ' samples!\n']);
        for fileIter = 1:numel(bmark.testFiles{classIter})
            for featIter = 1:numel( bmark.featLib )
                testInfo{featIter}.testFileName{testCtr} = [bmark.dataDir bmark.testFiles{classIter}(fileIter).name];
            end
            try,        I = imread( testInfo{1}.testFileName{testCtr} );
                        [H W C] = size(I); H_HALF = round(H/2); W_HALF = round(W/2);
                        I = I(H_HALF-N_HALF:H_HALF+N_HALF-1,W_HALF-N_HALF:W_HALF+N_HALF-1);
                        if( size(I,3) > 1 ),  I = rgb2gray(I);           end
                        if( bmark.resizeImg), I = imresize(I,[1024 1024]); end
                        fprintf(1, [num2str(fileIter) ',']);
                        if mod(fileIter,10) == 0 ;    fprintf(1,'\n');        end
            catch me,   display('PNG ERROR!'); end
            for featIter = 1:numel( bmark.featLib )
                bmark.FILTERINFO.ID = bmark.featLib(featIter);
                [imgbagTest testInfo{featIter}.testBags{testCtr, 1}.currFeat] = cbi_bagimg(I, bmark.FILTERINFO);
                testInfo{featIter}.testBagLabels( testCtr,1 ) = classIter;
            end
            testCtr = testCtr + 1;
        end
        fprintf(1,[ '\nFinished Class ' num2str(classIter) ' in testing features\n']);
    end
else
    %% Compute Training Features
    trainCtr = 1;
    for classIter = 1:numel( bmark.trainFiles )
        tic
        fprintf(1, ['training class ' num2str(classIter) ': totally ' num2str(numel(bmark.trainFiles{classIter})) ' samples...']);
        for fileIter = 1:numel(bmark.trainFiles{classIter})
            for featIter = 1:numel( bmark.featLib )
                trainInfo{featIter}.trainFileName{trainCtr} = bmark.trainFiles{classIter}( fileIter ).name ;
            end
            [a b c] = fileparts(trainInfo{1}.trainFileName{trainCtr});
            try, 
                load([a '/features/' b '.mat']);
%                 load([a '/features/' b '_unstable.mat']);
                for featIter = 1:numel( bmark.featLib )
                    bmark.FILTERINFO.ID = bmark.featLib(featIter);
                    trainInfo{featIter}.trainBags{trainCtr, 1}.currFeat = Bags{bmark.FILTERINFO.ID}.Features(:)';
                    trainInfo{featIter}.trainBagLabels( trainCtr,1 ) = classIter;
                end
                trainCtr = trainCtr + 1;
            catch me, 
                fprintf(fid,[trainInfo{featIter}.trainFileName{trainCtr} '\n']);
                display('LOADING ERROR!'); 
                continue;
            end
        end
        fprintf(1,[ 'Finished loading!\n']);
        toc
    end
    %% Compute Testing Features
    testCtr = 1;
    for classIter = 1:numel( bmark.trainFiles )
        tic
        fprintf(1, ['testing class ' num2str(classIter) ': totally ' num2str(numel(bmark.testFiles{classIter})) ' samples...']);
        for fileIter = 1:numel(bmark.testFiles{classIter})
            for featIter = 1:numel( bmark.featLib )
                testInfo{featIter}.testFileName{testCtr} = bmark.testFiles{classIter}(fileIter).name;
            end
            [a b c] = fileparts(testInfo{1}.testFileName{testCtr});
            try,        
                load([a '/features/' b '.mat']);
%                 load([a '/features/' b '_unstable.mat']);
                for featIter = 1:numel( bmark.featLib )
                    bmark.FILTERINFO.ID = bmark.featLib(featIter);
                    testInfo{featIter}.testBags{testCtr, 1}.currFeat = Bags{bmark.FILTERINFO.ID}.Features(:)';
                    testInfo{featIter}.testBagLabels( testCtr,1 ) = classIter;
                end
                testCtr = testCtr + 1;
            catch me,   
                fprintf(fid,[testInfo{featIter}.testFileName{testCtr} '\n']);
                display('LOADING ERROR!'); 
                continue
            end
        end
        fprintf(1,[ 'Finished loading!\n']);
        toc
    end
end
fclose(fid);
% Normalize Data if Necessary
display('Normalizing features!')
tic
if( bmark.normalizeFeatures )
    for featIter = 1:numel( bmark.featLib )
        [trainInfo{featIter}.trainBags ,trainMean ,trainStd] = normalizeFeatures(trainInfo{featIter}.trainBags, 1, []);
        [testInfo{featIter}.testBags   ,~         , ~      ] = normalizeFeatures(testInfo{featIter}.testBags , 0, trainMean, trainStd);
    end
end
toc



trainInfo = repmat(trainInfo,[1 numel(bmark.learnLib)]);
testInfo  = repmat(testInfo,[1 numel(bmark.learnLib)]);
for learnIter = 2 : numel(bmark.learnLib)
    trainInfo{learnIter}.learn         = bmark.learnLib(learnIter);
end
% instLab = [];
%if(classIter == 1)
%    try,           labImg = imread([ bmark.trainDir{classIter} bmark.labFiles{classIter}( fileIter ).name ]);
%    catch me,      labImg = zeros(size(I));
%    end
%    if( bmark.resizeImg),  labImg = imresize(labImg,[256 256]); end
%    for iterX = 1:bmark.FILTERINFO.N:size(I,2)
%        for iterY = 1:bmark.FILTERINFO.N:size(I,1)
%            instLab = [instLab; 2 - ( sum(sum( labImg(iterY:iterY+bmark.FILTERINFO.N-1, iterX:iterX+bmark.FILTERINFO.N-1) )) > 0 )];
%        end
%    end
%end