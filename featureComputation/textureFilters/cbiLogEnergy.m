function feat = cbiLogEnergy(I)
I = double(I);
filt1 = fspecial('log', [49 49], 3) ;
filt2 = fspecial('log', [49 49], 5) ;
filt3 = fspecial('log', [49 49], 7) ;

op1 = imfilter(I, filt1, 'conv', 'same');
op2 = imfilter(I, filt2, 'conv', 'same');
op3 = imfilter(I, filt3, 'conv', 'same');

feat = [ sqrt( sum(op1(:).^2) )  sqrt( sum(op2(:).^2) ) sqrt( sum(op3(:).^2) ) ];