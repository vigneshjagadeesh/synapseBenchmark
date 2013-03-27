function [Q minInd] = computeZernike(PATCH_SIZE)

if( nargin < 1 )
    close all; clear; clc;
    PATCH_SIZE = 256;
end

% Build a grid
%x = -1:0.01:1;
x = linspace(-1, 1, PATCH_SIZE);
[X,Y] = meshgrid(x,x);
[theta,r] = cart2pol(X,Y);

is_in_circle = r<=1;
r = r(is_in_circle);
theta = theta(is_in_circle);

% Compute and display the first 25 pseudo-Zernike functions
n_max = 10;
totalNums = ( (n_max+2) * (n_max+1) )/2;

% Generate random samples
samp = [rand rand];
rthe = [sqrt( samp(1,1)^2 + samp(1,2)^2 ) atan2( samp(1,2), samp(1,1) )];
for iter = 2:totalNums
    flag = 0;
    while( flag == 0 )
        samp(iter,:) = [randn randn];
        rad = sqrt( samp(iter,1)^2 + samp(iter,2)^2 );
        ang = atan2( samp(iter,2), samp(iter,1) );
        if( (rad < .95) && (min( pdist( samp ) ) > .05) )
            flag = 1;
            rthe = [rthe; rad ang];
        end
    end
end

distMats = pdist2([r theta], rthe);
[minVal minInd] = min(distMats);
minInd = sort( minInd );
N = 2*n_max+1;
h = figure('Position',[0 0 800 600],'Visible','off');
P = nan(size(X));
P(is_in_circle) = pzernfun(0,0,r,theta);
if( nargin < 1)
    figure; pcolor(x,x,P), shading interp
    hold on; plot( samp(:,1), samp(:,2), 'r*' ); hold off;
end
ZVal = [];
for n = 0:n_max
    for m = -n:n
        P = nan(size(X));
        P(is_in_circle) = pzernfun(n,m,r,theta);
        ZVal = [ZVal pzernfun(n,m,r,theta)];
        if( nargin < 1 )
            subplot(n_max+1,N,n*N + n_max + m + 1)
            pcolor(x,x,P), shading interp
            axis square
            set(gca,'XTick',[],'YTick',[])
            title(['P_' num2str(n) '^{' num2str(m) '}(r,\theta)'])
        end
    end
end
ZVal = ZVal( minInd, :);
[Q R] = qr(ZVal);
% movegui(h,'center')
% set(h,'Visible','on')