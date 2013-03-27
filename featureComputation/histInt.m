function histI = histInt(a, B)

% Normalize histograms to sum to one
a = a./sum(a);
A = repmat( a, size(B, 1), 1 );
B = B ./ repmat( sum( B, 2), 1, size(B,2) );

histI = sum( min(A,B), 2);