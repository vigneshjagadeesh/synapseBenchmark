% This function takes an image as input, and computes the chosen feature.
% Then, it uses the chosen method to classify the input image. 
% Candidate classifiers are : 'svm', 'boost'
% Candidate features are: 'gaborwavelets', 'textonEnergy'
% Example of usage: out = ImageClassifier(img, 'svm', 'textonEnergy')


function probEst = synDetect(img, ClassifierName, FeatureName)

if nargin< 3
    FeatureName = 'gaborwavelets';
end
if nargin < 2
    ClassifierName = 'svm';
end

[H,W] = size(img);
H_half = round(H/2);
W_half = round(W/2);

if strcmp(FeatureName,'gaborwavelets')
    tic
    load('FILTERINFO.FGabor.mat')
    toc
    tic
    tempImg = img(H_half-255:H_half+256,W_half-255:W_half+256);
    featbag = texturefeat(tempImg, FILTERINFO.FGabor);
%     tempImg = img(H_half-511:H_half+512,W_half-511:W_half+512);
%     tempImg = imresize(tempImg,[512 512]);
%     featbag = [featbag texturefeat(tempImg, FILTERINFO.FGabor)];
%     tempImg = imresize(img,[512 512]);
%     featbag = [featbag texturefeat(tempImg, FILTERINFO.FGabor)];
    toc
elseif strcmp(FeatureName,'textonEnergy')
    tic
    load('FILTERINFO.FFreq.mat')
%     [FILTERINFO.F FILTERINFO.FFreq] = makeRFSfilters(512);
    toc
    tic
    tempImg = img(H_half-255:H_half+256,W_half-255:W_half+256);
    featbag = texturefeat(tempImg, FILTERINFO.FFreq);
%     tempImg = img(H_half-511:H_half+512,W_half-511:W_half+512);
%     tempImg = imresize(tempImg,[512 512]);
%     featbag = [featbag texturefeat(tempImg, FILTERINFO.FFreq)];
%     tempImg = imresize(img,[512 512]);
%     featbag = [featbag texturefeat(tempImg, FILTERINFO.FFreq)];
    toc
else
    error('No such feature found!')
end




if strcmp(ClassifierName,'svm')
    tic
    load(['/cluster/home/retinamap/synapseProject/source/synapseDetector/benchmark/ComputedClassifier/svm_' FeatureName '.mat' ]);
    [~, ~, probEst] = svmpredict( 0, featbag(:)', svmModel, '-b 1' );
    probEst = probEst(1);
    toc
elseif strcmp(ClassifierName,'boost')
    load(['/cluster/home/retinamap/synapseProject/source/synapseDetector/benchmark/ComputedClassifier/boost_' FeatureName '.mat' ]);
    [~, probEst] = strongGentleClassifier( featbag(:)', boostModel );
else
    error('No such classifier found!')
end
return

%% Convolves the Input Patch with the MM dictionary and returns
function feat = texturefeat(img_patch, FILTER_BANK)
img_patch = im2double(img_patch);
A = fft2(img_patch);
NUM_FILTERS = size(FILTER_BANK, 3);
feat1 = zeros(NUM_FILTERS, 2);
for filt_iter = 1:NUM_FILTERS
    D =  real( fftshift( ifft2( A.* FILTER_BANK(:,:,filt_iter)  ) ) ); D = D(11:end-10, 11:end-10);% Obtaining mean and variance in time domain
    feat1(filt_iter, :) = [mean(D(:)) std(D(:), 1)];
end;
feat = feat1(:);
return
