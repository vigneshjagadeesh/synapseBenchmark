%% Synaptic Vesicle Feature
function feat = cbi_fsv(I)
% Given an image compute feature for
ctr = 1;
for thVal = .2:.2:.7
    bw = 1 - im2bw( uint8(I), thVal );
    bw1 = bw;
    CC = bwconncomp(bw);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    idx1 = find(numPixels < 100 | numPixels > 600);
    %for iterCC = 1:numel(idx1)
    %    bw1( CC.PixelIdxList{idx(iterCC)} ) = 0;
    %end
    CC1 = bwconncomp(bw1);
    if( CC1.NumObjects > 0 )
        for iter = 1:CC1.NumObjects
            bwTemp = zeros( size(I) );
            bwTemp( CC1.PixelIdxList{iter} ) = 1;
            svRat(iter) = computeMoments( bwTemp );
        end
    else
        svRat = 0;
    end
    feat(ctr) = CC1.NumObjects ; %max(svRat);
    ctr = ctr + 1;
    %  figure(1); subplot(121); imshow(I, []); subplot(122); imshow(I, []); hold on; contour( bw1 - .5, [0 0], 'g' ); hold off;
end


function svRat = computeMoments(im1)

[y x] = find(im1);

yM = mean(y);
xM = mean(x);

Cxx = sum( ( x - xM ).^2 );
Cyy = sum( ( y - yM ).^2 );
Cxy = sum( (x-xM) .* (y-yM) );

C = [Cxx Cxy; Cxy Cyy];
[u s v] = svd(C);
svRat = s(1)/s(4);