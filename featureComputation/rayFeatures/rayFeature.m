function rayFeat = rayFeature(I)
% Ray Like Features
if( nargin < 1 )
    clc;clear; close all;
    I = imread('cameraman.tif');
end
numOri = 12;
rotSteps = linspace(0,360,numOri+1);
rotSteps = rotSteps(1:end-1);
Ie = double(edge(I, 'sobel'));
Ie( Ie > 0 ) = 255;
Ie( Ie ==0 ) = 1;
[Ix Iy] = gradient(double(I));
gradMag = sqrt( Ix.^2 + Iy.^2 );
rayFeat = zeros(numOri,6);

for rotIter = 1:numOri
    temp1 = imrotate(Ie, rotSteps(rotIter));    [numRows numCols] = size(temp1);
    temp2 = imrotate(gradMag, rotSteps(rotIter));
    temp3 = imrotate(Ix, rotSteps(rotIter));
    temp4 = imrotate(Iy, rotSteps(rotIter));
    f1 = zeros(numRows, numCols); f2 = f1; f3 = f1;
    for colIter = 1:size(temp1,2)
        rowIter = 1;
        while( temp1(rowIter, colIter) == 0 && rowIter < numRows )
            rowIter = rowIter + 1;
        end
        d = 0;
        o = 1;
        n = 0;
        while( temp1(rowIter, colIter)~=0 && rowIter < numRows )
            f1(rowIter, colIter) = d;
            f2(rowIter, colIter) = n;
            f3(rowIter, colIter) = o;
            if( temp1(rowIter, colIter) >100 )
                d = 0;
                n = temp2( rowIter, colIter );
                o = (1/n) * ( temp3(rowIter, colIter)*cos(rotSteps(rotIter)) + temp4(rowIter, colIter)*sin(rotSteps(rotIter)) );
            else
                d = d+1;
            end
            rowIter = rowIter+1;
        end
        
    end
    
    temp1 = imrotate(temp1, -rotSteps(rotIter)); temp1 = cutImg(temp1, I);
    f1 = imrotate(f1, -rotSteps(rotIter)); 
    temp = cutImg(f1, I);
    rayFeat(rotIter,1:2) = [mean(temp(:)) std(temp(:))];
%     f1r(:,:,rotIter) = cutImg(f1, I);
    f2 = imrotate(f2, -rotSteps(rotIter)); 
    temp = cutImg(f2, I);
    rayFeat(rotIter,3:4) = [mean(temp(:)) std(temp(:))];
%     f2r(:,:,rotIter) = cutImg(f2, I);
    f3 = imrotate(f3, -rotSteps(rotIter)); 
    temp = cutImg(f3, I);
    rayFeat(rotIter,5:6) = [mean(temp(:)) std(temp(:))];
%     f3r(:,:,rotIter) = cutImg(f3, I);
    
    if( nargin < 1 )
        display(['scanning ori: ' num2str(rotSteps(rotIter))])
%         figure(1); imshow( uint8(f1) ); pause;
    end
end

rayFeat = rayFeat(:);