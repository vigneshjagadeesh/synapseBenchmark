function [trainBagger currMean currStd] = normalizeFeatures(trainBagger, TRN, varargin)

featMatU = [];
for bagIter = 1:numel(trainBagger)
    featMatU  = [featMatU; trainBagger{bagIter}];
end

if( TRN )
    currMean = mean(featMatU);
    currStd = std(featMatU);
else
    currMean = varargin{1}(:)';
    currStd = varargin{2}(:)';
end
featMatU = featMatU - repmat( currMean, [size(featMatU,1) 1] );
featMatU = featMatU ./ repmat( currStd, [size(featMatU,1) 1] );

ctr = 1;
for bagIter = 1:numel(trainBagger)
    % For each Image Iterate over all sites
    for instIter = 1:size( trainBagger{bagIter}, 1 )
        trainBagger{bagIter}(instIter, :) = featMatU(ctr, :) ;
        ctr = ctr + 1;
    end
end
