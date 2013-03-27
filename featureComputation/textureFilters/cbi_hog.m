function feat = cbi_hog(img, noBins)

if(nargin < 1)
    img = imread('cameraman.tif');
    noBins = 16;
elseif( nargin < 2)
    noBins = 32;
end

[Ix Iy] = gradient( double( img ) );
gradMag = sqrt(Ix.^2 + Iy.^2);
ang = atan2( Iy, Ix ) * 180 /pi;
ang( ang < 0 ) = ang( ang < 0 )  + 360;

binSpace = linspace(0, 360, noBins+1);

for iter = 1:numel(binSpace)-1
    tempInd = ang > binSpace(iter) & ang < binSpace(iter+1);
    feat(iter) = sum( gradMag( tempInd(:) ) );
end

%feat = median(feat);
%feat = entropy(feat./sum(feat));
    