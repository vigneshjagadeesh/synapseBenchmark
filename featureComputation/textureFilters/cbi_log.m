%% Synaptic Vesicle Feature
function [feat] = cbi_log(I1)
I = double(I1);
% This code performs an adaptive histogram equalization
featVal1 = doFilt( I,  normalise( fspecial('log', [49 49], 7) ) );



feat = [featVal1(:)]';

function f=normalise(f),
f=f-mean(f(:)); f=f/sum(abs(f(:)));
return

function featVal = doFilt(I4, f)
numRetain = 25;
I3 = uint8(I4);
I2 = adapthisteq( I3 );
%I1 = medfilt2(I3);
I1 = double(I2);
F1 = imfilter(I1 , f, 'conv', 'same');
lmax1 = F1 > imdilate(F1, [1 1 1; 1 0 1; 1 1 1]);
lval1 = F1(lmax1); 
[lval1Sort lval1SortIndex] = sort(lval1, 'descend');
[lmax1Y lmax1X] = find(lmax1);
lmax1 = lmax1(lval1SortIndex);
numRetain = min( numel(lmax1Y), numRetain );
lmax1Y = lmax1Y(lval1SortIndex); lmax1Y = lmax1Y(1:numRetain);
lmax1X = lmax1X(lval1SortIndex); lmax1X = lmax1X(1:numRetain);

% figure(10);  imshow(uint8(I1)); hold on; plot(lmax1X, lmax1Y, 'r*');  hold off; title( [num2str(median(lval1Sort(1:numRetain)) ) ]);
%             pause;
featVal = [median(lval1Sort(1:numRetain))];
