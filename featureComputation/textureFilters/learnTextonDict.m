function textonDict = learnTextonDict(trainImg, algParam)

F = algParam.F;
numTextons = algParam.numTextons;
    textonDict = [];
    for dirIter = 1:size(trainImg, 4)
        if(numTextons(dirIter) == 0 )
            continue;
        end
        trainRes = [];
        
% % %         for trainIter = 1:size(trainImg, 3)
% % %             currImg = double(trainImg(:,:,trainIter,dirIter));
% % %             trainRes = [trainRes; convTexture(currImg, F)];
% % %         end

% % % % % % UNCOMMENT IF YOU WANT TO USE PATCH FILTERING IN TEXTON LEARNING        
        for trainIter = 1:size(trainImg, 3)
            for iter_x = 1:algParam.N:size(trainImg,2)-algParam.N+1
                for iter_y = 1:algParam.N:size(trainImg,1)-algParam.N+1
                    currImg = double(trainImg(iter_y:iter_y+algParam.N-1, iter_x:iter_x+algParam.N-1,trainIter,dirIter));
                    trainRes = [trainRes; convTexture(currImg, F)];
                end
            end
        end

        
%         [IDX, textons{dirIter}] = kmeans1(trainRes, numTextons, 1);
        tic,
        [IDX, textons{dirIter}] = kmeans(trainRes, numTextons(dirIter));
        toc
        textonDict = [textonDict; textons{dirIter}];    
    end
 if(size(F,3) ==38)   
    Fmat = [];
    for iter = 3:6:36
        temp = F(:,:,iter);
        Fmat = [Fmat; temp(:)'];
    end
    temp = F(:,:,37); Fmat = [Fmat; temp(:)'];
    temp = F(:,:,38); Fmat = [Fmat; temp(:)'];
    for iter = 1:dirIter
        figure( 200 + iter );
        for subIter = 1:algParam.numTextons(iter)
            currResponse = pinv(Fmat) *  textons{iter}(subIter,:)';
            subplot(ceil(algParam.numTextons(iter)/3), 3, subIter)
            imagesc( reshape(currResponse, [size(F(:,:,1), 1) size(F(:,:,1), 2)] ) ) ;
        end
    end
 else
    Fmat = [];
    for iter = 1:size(F,3)
        temp = F(:,:,iter);
        Fmat = [Fmat; temp(:)'];
    end
    for iter = 1:dirIter
        figure( 200 + iter );
        for subIter = 1:algParam.numTextons(iter)
            currResponse = pinv(Fmat) *  textons{iter}(subIter,:)';
            subplot(ceil(algParam.numTextons(iter)/3), 3, subIter)
            imagesc( reshape(currResponse, [size(F(:,:,1), 1) size(F(:,:,1), 2)] ) ) ;
        end
    end
 end