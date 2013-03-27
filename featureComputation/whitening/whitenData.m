function [Xwhite varargout] = whitenData(X, varargin)

if( nargin == 1 )
    meanVal = mean(X,1);
    stdVal = std(X,1);
    X = X - repmat( meanVal, [size(X,1) 1] );
    stdVal( stdVal == 0 ) = 1;
    X = X ./ repmat( stdVal, [size(X,1) 1] );
    varargout{1} = meanVal;
    varargout{2} = stdVal;
else
    X = X - repmat( varargin{1}, [size(X,1) 1] );
    X = X ./ repmat( varargin{2}, [size(X,1) 1] );
    varargout{1} = [];
end
Xwhite = X;