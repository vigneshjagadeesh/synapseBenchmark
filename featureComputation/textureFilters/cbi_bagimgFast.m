function [imgbag featbag X] = cbi_bagimg(img, FILTERINFO)

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
X_begin = [];
Y_begin = [];
imgbag = [];
[no_rows no_cols no_slices] = size(img);
% % % imgFilt = convTexture(img, FILTERINFO.F);
if(strcmp(FILTERINFO.patchType,'nonoverlap'))
    count = 1;
    for iter_x = 1:N:no_cols-N+1
        for iter_y = 1:N:no_rows-N+1
            display(['Processing patch ' num2str(count) ]);
            curr_patch{count} = img(iter_y:iter_y+N-1, iter_x:iter_x+N-1);
            % % % curr_patch = imgFilt(iter_y:iter_y+N-1, iter_x:iter_x+N-1);
            imgbag(:, count) =  reshape( curr_patch{count}, [], 1);
            X_begin = [X_begin iter_x];
            Y_begin = [Y_begin iter_y];
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
        curr_patch{count} = img(Ybegin(iter):Ybegin(iter)+N-1, Xbegin(iter):Xbegin(iter)+N-1);
        imgbag(:, iter) = reshape( curr_patch{count}, [], 1);

        count = count + 1;
    end
elseif(strcmp(FILTERINFO.patchType,'overlapby2'))
    count = 1;
    for iter_x = 1:N/2:no_cols-N+1
        for iter_y = 1:N/2:no_rows-N+1
            display(['Processing patch ' num2str(count) ]);
            curr_patch{count} = img(iter_y:iter_y+N-1, iter_x:iter_x+N-1);
            imgbag(:, count) =  reshape( curr_patch{count}, [], 1);
            
            X_begin = [X_begin iter_x];
            Y_begin = [Y_begin iter_y];
            count = count + 1;
        end
    end
else
    error('No Patches Created');
end

X = [X_begin(:) Y_begin(:)];
firstFeat(1,:) = cbi_texturefeat(curr_patch{1}, FILTERINFO.F);
featbag = zeros( numel(curr_patch), size(firstFeat,2) );
featbag(1,:)  = firstFeat;
filId = FILTERINFO.ID;
parfor patchIter = 2:numel(curr_patch)
            if( filId  == 1)
                featbag(patchIter,:) = cbi_texturefeat(curr_patch{patchIter}, FILTERINFO.F);
            elseif( filId == 2 )
                featbag(patchIter,:) = cbi_textonfeat(curr_patch{patchIter}, FILTERINFO.F);
            elseif( filId == 3)
                featbag(patchIter, :) = cbi_textonhist(curr_patch{patchIter}, FILTERINFO);
            elseif( filId == 4)
                featbag(patchIter, :) = cbi_fsv(curr_patch{patchIter});
            elseif( filId == 5)
                featbag(patchIter, :) = [cbi_log(curr_patch{patchIter}) cbi_fsv(curr_patch{patchIter})];
            elseif( filId == 6 )
                featbag(patchIter, :) = gistGabor( prefilt( double(curr_patch{patchIter}), 4), FILTERINFO.numberGistBlocks, FILTERINFO.gistFilt);
            elseif( filId == 7 )
                featbag(patchIter, :) = lbp(curr_patch{patchIter});
                featbag(patchIter, :) = featbag(patchIter, :) ./ sum(featbag(patchIter, :));
            elseif( filId == 8 )
                featbag(patchIter, :) = lbp(curr_patch{patchIter},1,8,FILTERINFO.mapping,'h');
                featbag(patchIter, :) = featbag(patchIter, :) ./ sum(featbag(patchIter, :));
            elseif( filId == 9)
                featbag(patchIter,:) = rayFeature(curr_patch{patchIter});
            elseif( filId == 10)
                featbag(patchIter,:) = computeRadon(curr_patch{patchIter});
            elseif( filId == 11)
                featbag(patchIter,:) = computeZernike(curr_patch{patchIter});
            elseif( filId == 12)
                featbag(patchIter,:) = fourierMellin(curr_patch{patchIter});
            end
end

%% Convolves the Input Patch with the MM dictionary and returns
function feat = cbi_texturefeat(img_patch, FILTER_BANK)
A = fft2(img_patch);
% close all; figure(1); imshow(img_patch);
if(size(img_patch,1)  ~= size(img_patch,2) )
    error('Patches must be square');
end
NUM_FILTERS = size(FILTER_BANK, 3);
feat1 = zeros(NUM_FILTERS, 2);
for filt_iter = 1:NUM_FILTERS
    D =  abs(ifft2( A.* FILTER_BANK(:,:,filt_iter) ) ); % Obtaining mean and variance in time domain
    % figure(2); imagesc(D); pause;
    feat1(filt_iter, :) = [mean(mean(D)) std(D(:), 1)];
end;
feat = feat1(:);

%% Convolves with the Leung Malik filter bank and returns energy
function feat = cbi_textonfeat(img_patch, F)
img_patch = double( img_patch );
if( ( size(img_patch,1) ~= size(img_patch,2) ) || size(img_patch,3)>1 )
    error('Please Input GRAYSCALE SQUARE Patches');
end
[~, ~, no_filters] = size(F);
feat1 = zeros(no_filters, 2);
% close all; figure(1); imshow( img_patch );
for filter_iter = 1:no_filters
    %D = imfilter( double(img_patch), F(:,:,filter_iter), 'replicate', 'conv');
    D =  real( fftshift( ifft2( fft2(img_patch) .* F(:,:,filter_iter) ) ) ); D = D(11:end-10, 11:end-10);
    % figure(2); imagesc(D); pause; 
    
    feat1(filter_iter, :) = [mean(abs(D(:))) std(D(:), 1)];
end
% feat = [mean(feat1(7:12,1)) mean(feat1(7:12,2)); feat1(13:14,:)];
feat = [mean(feat1(1:6,1)) mean(feat1(1:6,2)); mean(feat1(7:12,1)) mean(feat1(7:12,2)); feat1(13:14,:)];
feat = [feat(:); mean(img_patch(:)); std(img_patch(:),1); cbi_log(img_patch) ];

%% Evaluates histogram given a texton dictionary
function feat = cbi_textonhist(img_patch, FILTER_INFO)
if( ( size(img_patch,1) ~= size(img_patch,2) ) || size(img_patch,3)>1 )
    error('Please Input GRAYSCALE SQUARE Patches');
end
D = convTexture(img_patch, FILTER_INFO.F);
% D = img_patch;
[IDX, D] = knnsearch(FILTER_INFO.textonDict, D);
feat = histc(IDX, 1:1:size(FILTER_INFO.textonDict,1) );
feat = feat ./ sum(feat(:));
