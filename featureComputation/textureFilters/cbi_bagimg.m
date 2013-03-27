function [imgbag, featbag] = cbi_bagimg(img, FILTERINFO)
%%%%%%%%%%%% EQUALIZING INSIDEE
%% Function takes in an image, breaks it into patches and applies the
%  filter bank specified in FILTERINFO ...
%  Specify the type, size and number of patches
% SPLITINFO.TYPE = 'nonoverlap', 'random', 'overlapby2'
% SPLITINFO.N    = patchsize
% SPLITINFO.NUM  = number of patches for random specification
% SPLITINFO.img  = Enitre image, can also be a patch
% Specify type of filter for function call and the filter bank itself
% FILTERINFO.F - 1. The filter bank - is in the form of cells for GW
%                2. The filter bank - is in the form of 3darrays for TONS
% FILTERINFO.ID= 1. GABORWAVELET
%                2. TEXTONS
%                3. TEXTON HISTOGRAM
%                4. CC features
%                5. LOG and CC features
%                6. GIST features
%                7. LBP wihtout compression
%                8. LBP with rotation invariance
%                9. Ray ...
%               10. Radon ...
%               11. Zernike ...
%               12. CFMT ...
N = FILTERINFO.N;
imgbag = [];
img = uint8(img);
[no_rows no_cols no_slices] = size(img);
    if( no_slices == 3 )
        imgGray = rgb2gray(img);
        imgColor = img;
    else
        imgColor = [];
        imgGray = img;
    end
    
    if(FILTERINFO.equalizeImg)
        imgGray = double(adapthisteq( imgGray ) );
    else
        imgGray = double(imgGray);
    end
    imgColor = double(imgColor);
    
    if(strcmp(FILTERINFO.patchType,'nonoverlap'))
        count = 1;
        for iter_x = 1:N:no_cols-N+1
            for iter_y = 1:N:no_rows-N+1
                bbox{count,1} = [iter_x iter_y N N];
                count = count + 1;
            end
        end
    elseif(strcmp(FILTERINFO.patchType,'random'))
        Xbegin = randperm(no_cols - N); Ybegin = randperm(no_rows - N);
        FILTERINFO.NUMRAND = min( min(numel(Xbegin), numel(Ybegin)), FILTERINFO.NUMRAND);
        Xbegin = Xbegin(1:FILTERINFO.NUMRAND );
        Ybegin = Ybegin(1:FILTERINFO.NUMRAND );
        count = 1;
        for iter = 1:FILTERINFO.NUMRAND
            bbox{count,1} = [Xbegin(iter) Ybegin(iter) N N];
            count = count + 1;
        end
    elseif(strcmp(FILTERINFO.patchType,'overlapby2'))
        count = 1;
        for iter_x = 1:N/2:no_cols-N+1
            for iter_y = 1:N/2:no_rows-N+1
                bbox{count,1} = [iter_x iter_y N N];
                count = count + 1;
            end
        end
    else
        error('No Patches Created');
    end
    featbag = cellfun(@(x) featureExtract(x, imgGray, imgColor, FILTERINFO), bbox, 'UniformOutput',false);
    featbag = cell2mat(featbag)';



function featbag = featureExtract(X, img, imgColor, FILTERINFO)

iter_x = X(1); iter_y = X(2); N = X(3);
curr_patch = img(iter_y:iter_y+N-1, iter_x:iter_x+N-1,:);

%imgbag(:, count) =  reshape( curr_patch, [], 1);
if( FILTERINFO.ID == 1)
    featbag = cbi_texturefeat(curr_patch, FILTERINFO.FGabor);
elseif( FILTERINFO.ID == 2 )
    featbag = cbi_textonfeat(curr_patch, FILTERINFO.FFreq);
elseif( FILTERINFO.ID == 3)
    featbag = cbi_textonhist(curr_patch, FILTERINFO.FFreq, FILTERINFO.textonDict);
elseif( FILTERINFO.ID == 4)
    featbag = cbi_thresh(curr_patch);
elseif( FILTERINFO.ID == 5)
    featbag = [cbi_log(curr_patch) cbi_fsv(curr_patch) ];
elseif( FILTERINFO.ID == 6 )
    featbag = gistGabor( prefilt( double(curr_patch), 4), FILTERINFO.numberGistBlocks, FILTERINFO.gistFilt);
elseif( FILTERINFO.ID == 7 )
    featbag = lbp(curr_patch);
    featbag = featbag(:) ./ sum(featbag(:));
elseif( FILTERINFO.ID == 8 )
    featbag = lbp(curr_patch,1,8,FILTERINFO.mapping,'h');
    featbag = featbag(:) ./ sum(featbag(:));
elseif( FILTERINFO.ID == 9)
    featbag = rayFeature(curr_patch);
elseif( FILTERINFO.ID == 10)
    featbag = computeRadon(curr_patch);
elseif( FILTERINFO.ID == 11)
    featbag = zernikeFeatures(curr_patch, FILTERINFO.zernQ, FILTERINFO.zernSelInd);
elseif( FILTERINFO.ID == 12)
    featbag = fourierMellin(curr_patch);
elseif( FILTERINFO.ID == 13 )
    featbag = extractCooccur(curr_patch, FILTERINFO.F(:,:,31:36), fspecial('log', 49, 7) );
elseif( FILTERINFO.ID == 14 )
    if( isempty(imgColor) )
        display('Empty Color Image Sent ... replicating first channel of img thrice');
        imgColor = repmat( img(:,:,1), [1 1 3]);
    end
        currColor = imgColor(iter_y:iter_y+N-1, iter_x:iter_x+N-1,:);
        Rh = histc(currColor(:,:,1), linspace(0,255,8) ); Rh = Rh/sum(Rh);
        Gh = histc(currColor(:,:,2), linspace(0,255,8) ); Gh = Gh/sum(Gh);
        Bh = histc(currColor(:,:,3), linspace(0,255,8) ); Bh = Bh/sum(Bh);
        currColor = [Rh(:); Gh(:); Bh(:)];
        featbag = currColor(:);            
elseif( FILTERINFO.ID == 15 )
    if( isfield(FILTERINFO, 'siftModel') )
        currBOW = getImageDescriptor(FILTERINFO.siftModel, curr_patch);
        featbag = currBOW(:);
    else
        featbag = zeros(3,1);
    end
end

%% Convolves the Input Patch with the MM dictionary and returns
function feat = cbi_texturefeat(img_patch, FILTER_BANK)
img_patch = im2double(img_patch);
A = fft2(img_patch);
NUM_FILTERS = size(FILTER_BANK, 3);
feat1 = zeros(NUM_FILTERS, 2);
for filt_iter = 1:NUM_FILTERS
    D =  real( fftshift( ifft2( A.* FILTER_BANK(:,:,filt_iter)  ) ) ); D = D(11:end-10, 11:end-10);% Obtaining mean and variance in time domain
    feat1(filt_iter, :) = [mean(D(:)) std(D(:), 1)];
end;
%feat1 = [mean(feat1(1:6,1)) mean(feat1(7:12,1)) mean(feat1(13:18,1)) mean(feat1(19:24,1)) ...
%   mean(feat1(1:6,2)) mean(feat1(7:12,2)) mean(feat1(13:18,2)) mean(feat1(19:24,2)) ...
%   mean(img_patch(:)) std(img_patch(:))       ];
%feat1 = [feat1(:)];
feat = feat1(:);


%% Convolves with the Leung Malik filter bank and returns energy
function feat = cbi_textonfeat(I, F)
I = im2double(I);
A = fft2( double(I) );
NUM_FILTERS = size(F,3);
gaborFeat = zeros(NUM_FILTERS, 2);
for filt_iter = 1:NUM_FILTERS
    D =  real( fftshift( ifft2( A.* F(:,:,filt_iter)  ) ) ); %D = D(11:end-10, 11:end-10);% Obtaining mean and variance in time domain 
    D(1:10,:) = 0; D(:,1:10) = 0; D(end-9:end,:)=0; D(:,end-9:end) = 0;
    gaborFeat(filt_iter, :) = [mean(abs(D(:))) std(D(:), 1)];
end
feat = gaborFeat(:);

%% Evaluates histogram given a texton dictionary
function feat = cbi_textonhist(img_patch, F, textonDict)

I = im2double(img_patch);
A = fft2( double(I) );
NUM_FILTERS = size(F,3);
D = zeros( size(F,1), size(F,2), size(F,3) );
for filt_iter = 1:NUM_FILTERS
    temp =  real( fftshift( ifft2( A.* F(:,:,filt_iter)  ) ) ); %D = D(11:end-10, 11:end-10);% Obtaining mean and variance in time domain 
    temp(1:10,:) = 0; temp(:,1:10) = 0; temp(end-11:end,:)=0; temp(:,end-11:end) = 0;
    D(:,:,filt_iter) = temp;
end
D = reshape(D, [size(D,1)*size(D,2) size(D,3)]);
sampler = rand(size(D,1),1)>.9;
D = D(sampler,:);

[IDX, ~] = knnsearch(textonDict, D);
feat = histc(IDX, 1:1:size(textonDict,1) );
feat = feat ./ sum(feat(:));

%% Evaluates Zernike Features
function zernFeat = zernikeFeatures(I, Q, selInd)
ISel = I(selInd);
zernRes = Q' * double(ISel(:));
zernFeat = [mean(zernRes(:)) std(zernRes(:))];