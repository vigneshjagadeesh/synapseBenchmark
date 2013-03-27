function [imgbag featbag X] = cbi_discbagimg(img, FILTERINFO, textonProj)

%% Function takes in an image, breaks it into patches and applies the
%  filter bank specified in FILTERINFO ...
%  Specify the type, size and number of patches 
    % SPLITINFO.TYPE = 'nonoverlap', 'random', 'overlapby2'
    % SPLITINFO.N    = patchsize
    % SPLITINFO.NUM  = number of patches for random specification
    % SPLITINFO.img  = Enitre image, can also be a patch
% Specify type of filter for function call and the filter bank itself
    % FILTERINFO.ID = 1for GABORWAVELET, 2for TEXTONS
    % FILTERINFO.F - The filter bank - is in the form of cells for GW
    %                The filter bank - is in the form of 3darrays for TONS


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
            curr_patch = img(iter_y:iter_y+N-1, iter_x:iter_x+N-1);
            % % % curr_patch = imgFilt(iter_y:iter_y+N-1, iter_x:iter_x+N-1);
            imgbag(:, count) =  reshape( curr_patch, [], 1);            
            if( FILTERINFO.ID == 1)
                featbag(count,:) = cbi_texturefeat(curr_patch, FILTERINFO.F);
            elseif( FILTERINFO.ID == 2 )
                %featbag(count,:) = cbi_textonfeat(curr_patch, FILTERINFO.F);
                [~, featbag(count,:)] = vrl_imfilter(curr_patch, FILTERINFO.F);
            elseif( FILTERINFO.ID == 3)
                featbag(count, :) = cbi_textonhist(curr_patch, FILTERINFO, textonProj);
            end
            X_begin = [X_begin iter_x];
            Y_begin = [Y_begin iter_y];
            count = count + 1;
        end
    end    
elseif(strcmp(FILTERINFO.patchType,'random'))
    Xbegin = randperm(no_cols - N); Xbegin = Xbegin(1:SPLITINFO.NUM);
    Ybegin = randperm(no_rows - N); Ybegin = Ybegin(1:SPLITINFO.NUM);
    for iter = 1:SPLITINFO.NUM
            curr_patch = img(Ybegin(iter):Ybegin(iter)+N-1, Xbegin(iter):Xbegin(iter)+N-1);
            imgbag(:, iter) = reshape( curr_patch, [], 1);
            if( FILTERINFO.ID == 1)
                featbag(count,:) = cbi_texturefeat(curr_patch, FILTERINFO.F);
            elseif( FILTERINFO.ID == 2 )
                %featbag(count,:) = cbi_textonfeat(curr_patch, FILTERINFO.F);
                [~, featbag(count,:)] = vrl_imfilter(curr_patch, FILTERINFO.F);
            elseif( FILTERINFO.ID == 3)
                featbag(count, :) = cbi_textonhist(curr_patch, FILTERINFO, textonProj);                
            end            
    end    
elseif(strcmp(FILTERINFO.patchType,'overlapby2'))
    count = 1;
    for iter_x = 1:N/2:no_cols-N+1
        for iter_y = 1:N/2:no_rows-N+1
            curr_patch = img(iter_y:iter_y+N-1, iter_x:iter_x+N-1);
            imgbag(:, count) =  reshape( curr_patch, [], 1);
            if( FILTERINFO.ID == 1)
                featbag(count,:) = cbi_texturefeat(curr_patch, FILTERINFO.F);
            elseif( FILTERINFO.ID == 2 )
                featbag(count,:) = cbi_textonfeat(curr_patch, FILTERINFO.F);
            elseif( FILTERINFO.ID == 3)
                featbag(count, :) = cbi_textonhist(curr_patch, FILTERINFO, textonProj);            
            end
            X_begin = [X_begin iter_x]; 
            Y_begin = [Y_begin iter_y]; 
            count = count + 1;
        end
    end
else
    error('No Patches Created');
end

X = [X_begin(:) Y_begin(:)];


%% Convolves the Input Patch with the MM dictionary and returns
function feat = cbi_texturefeat(img_patch, FILTER_BANK)
A = fft2(img_patch);
if(size(img_patch,1)  ~= size(img_patch,2) )
    error('Patches must be square');
end
NUM_FILTERS = size(FILTER_BANK, 3);
feat1 = zeros(NUM_FILTERS, 2);
for filt_iter = 1:NUM_FILTERS    
        D = abs(ifft2(A.*FILTER_BANK(:,:,filt_iter))); % Obtaining mean and variance in time domain
%         figure(100+filt_iter);      imagesc(D);
        feat1(filt_iter, :) = [mean(mean(D)) std(D(:), 1)];
end;
feat = feat1(:);
feat(1:end/2) = feat(1:end/2) - mean(feat(1:end/2));  feat(1:end/2) = feat(1:end/2)./std(feat(1:end/2));
feat(end/2+1:end) = feat(end/2+1:end) - mean(feat(end/2+1:end));  feat(end/2+1:end) = feat(end/2+1:end)./std(feat(end/2+1:end));
% pause;
%% Convolves with the Leung Malik filter bank and returns energy
function feat = cbi_textonfeat(img_patch, F)
if( ( size(img_patch,1) ~= size(img_patch,2) ) || size(img_patch,3)>1 )
    error('Please Input GRAYSCALE SQUARE Patches');
end

[~, ~, no_filters] = size(F);
feat1 = zeros(no_filters, 2);
for filter_iter = 1:no_filters
    D = imfilter(img_patch, F(:,:,filter_iter), 'replicate', 'conv');
%     figure(100+filter_iter);  imagesc(D);
    feat1(filter_iter, :) = [mean(D(:)) std(D(:), 1)];
end
feat = feat1(:);
feat(1:end/2) = feat(1:end/2) - mean(feat(1:end/2));  feat(1:end/2) = feat(1:end/2)./std(feat(1:end/2));
feat(end/2+1:end) = feat(end/2+1:end) - mean(feat(end/2+1:end));  feat(end/2+1:end) = feat(end/2+1:end)./std(feat(end/2+1:end));
% pause;
%% Evaluates histogram given a texton dictionary 
function feat = cbi_textonhist(img_patch, FILTER_INFO, textonProj) 
if( ( size(img_patch,1) ~= size(img_patch,2) ) || size(img_patch,3)>1 )
    error('Please Input GRAYSCALE SQUARE Patches');
end
D = convTexture(img_patch, FILTER_INFO.F) * textonProj.M;
% D = img_patch;
[IDX, D] = knnsearch(FILTER_INFO.textonDict, D);
feat = histc(IDX, 1:1:size(FILTER_INFO.textonDict,1) );
feat = feat ./ sum(feat(:));
% feat = feat - mean(feat(:));
% feat = feat ./ var( feat(:) );