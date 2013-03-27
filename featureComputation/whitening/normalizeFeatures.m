function [trainBagger currMean currStd] = normalizeFeatures(trainBagger, TRN, varargin)

featMatU = zeros(numel(trainBagger),numel(trainBagger{1}.currFeat));
for bagIter = 1:numel(trainBagger)
    featMatU(bagIter,:)  = trainBagger{bagIter}.currFeat;
end

if( TRN )
    try,currMean = mean(featMatU);
    catch me, 
        dd = 1;
    end
    currStd = std(featMatU);
    currStd( currStd ~= 0 ) = 1;
else
    currMean = varargin{1}(:)';
    currStd = varargin{2}(:)';
end
for bagIter = 1 : numel(trainBagger)
    featMatU(bagIter,:) = featMatU(bagIter,:) -  currMean ;
    featMatU(bagIter,:) = featMatU(bagIter,:) ./ currStd ;
end
ctr = 1;
for bagIter = 1:numel(trainBagger)
    % For each Image Iterate over all sites
    for instIter = 1:size( trainBagger{bagIter}, 1 )
        try,
        trainBagger{bagIter}.currFeat(instIter, :) = featMatU(ctr, :) ;
        catch me,
            dd = 1;
        end
        ctr = ctr + 1;
    end
end
