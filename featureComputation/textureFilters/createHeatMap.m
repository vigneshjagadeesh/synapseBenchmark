function createHeatMap(img, predImgLabels, FILTERINFO)

% inferChunk.featFile
% inferChunk.classLabels
% Will Recreate a Heat Map based on how the image was broken down ...
    for imgIter = 1:1 % Do it for one image
        [no_rows no_cols no_slices] = size(img);
        heatMap = zeros(no_rows, no_cols);
        heatMask = zeros(no_rows, no_cols);
        avgMask = zeros(no_rows, no_cols);
        if(strcmp(FILTERINFO.patchType,'nonoverlap'))
            count = 1;
            for iter_x = 1:FILTERINFO.N:no_cols-FILTERINFO.N+1
                for iter_y = 1:FILTERINFO.N:no_rows-FILTERINFO.N+1
                    heatMask(iter_y:iter_y+FILTERINFO.N-1, iter_x:iter_x+FILTERINFO.N-1) = predImgLabels(count);
                    
                    count = count + 1;
                end
            end
            heatMap = heatMask;
        elseif(strcmp(FILTERINFO.patchType,'overlapby2'))
            count = 1;
            for iter_x = 1:FILTERINFO.N/2:no_cols-FILTERINFO.N+1
                for iter_y = 1:FILTERINFO.N/2:no_rows-FILTERINFO.N+1
                    heatMask(iter_y:iter_y+FILTERINFO.N-1, iter_x:iter_x+FILTERINFO.N-1, count) = predImgLabels(count);
                    avgMask(:,:,count) = heatMask(:,:,count) > 0;
                    count = count + 1;
                end
            end
             heatMap = ( sum( heatMask, 3) ./ sum(avgMask, 3) )  / 2;
        else
            error('Heat Map not Created');
        end
       
        fh = figure(1); subplot(121); imshow( uint8( img ) ); subplot(122); imagesc(heatMap);
        % set(fh, 'AlphaMap', heatMap, 'Color', [1 1 0] );    
        % hold on; alpha(heatMap); hold off; 
        title(['Image Decision is' num2str(mode(predImgLabels)) ]);
    end
end