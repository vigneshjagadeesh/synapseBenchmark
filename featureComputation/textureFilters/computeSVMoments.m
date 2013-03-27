function svRat = computeSVMoments(im1, varargin)

if( nargin == 1 )
    [y x] = find(im1);
else
    y = im1(:); x = varargin{1}(:);
end

yM = mean(y);
xM = mean(x);

Cxx = sum( ( x - xM ).^2 );
Cyy = sum( ( y - yM ).^2 );
Cxy = sum( (x-xM) .* (y-yM) );

C = [Cxx Cxy; Cxy Cyy];
[u s v] = svd(C);
svRat = s(1)/s(4);