function [disTextonDict textonProj] = learnDiscriminTextonDict(trainImg, algParam)
PREQUANT = false; % Means clustering takes place in low dimensional space
F = algParam.F;
numTextons = algParam.numTextons;
    textonDict = []; textonLab = []; trainLab = [];
    trainRes = cell(2,1);
    for dirIter = 1:size(trainImg, 4)
        tic,
% % %         for trainIter = 1:size(trainImg, 3)
% % %             currImg = double(trainImg(:,:,trainIter,dirIter));
% % %             trainRes = [trainRes; convTexture(currImg, F)];
% % %         end

% % % % % % UNCOMMENT IF YOU WANT TO USE PATCH FILTERING IN TEXTON LEARNING        
        for trainIter = 1:size(trainImg, 3)
            for iter_x = 1:algParam.N:size(trainImg,2)-algParam.N+1
                for iter_y = 1:algParam.N:size(trainImg,1)-algParam.N+1
                    currImg = double(trainImg(iter_y:iter_y+algParam.N-1, iter_x:iter_x+algParam.N-1,trainIter,dirIter));
                    trainRes{dirIter} = [trainRes{dirIter}; convTexture(currImg, F)];
                    trainLab = [trainLab; dirIter .* ones(size(currImg,1)*size(currImg,2),1)];
                end
            end
        end

        if(PREQUANT)
            [IDX, textons{dirIter}] = kmeans(trainRes{dirIter}, numTextons(dirIter));
            textonDict = [textonDict; textons{dirIter}];    
            textonLab = [textonLab; dirIter .* ones(size(textons{dirIter},1),1)];
        end
    end
    if(PREQUANT)
    [disTextonDict textonProj] = lda( textonDict, textonLab, 4);
    else
    [trainProj textonProj] = lda( [trainRes{1};trainRes{2}] , trainLab, 10);
    projRes{1} = trainProj(1:size(trainRes{1},1), :);
    projRes{2} = trainProj(1+size(trainRes{1},1):end, :);
        for dirIter = 1:2
            tic,
            [IDX, textons{dirIter}] = kmeans(projRes{dirIter}, numTextons(dirIter));
            toc
            textonDict = [textonDict; textons{dirIter}];  
        end
        disTextonDict = textonDict;
    end