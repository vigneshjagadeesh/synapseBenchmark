% This file tries to compute all features of each sample image, and then 
% store the features in a mat file for each sample image.
% FILTERINFO.ID= 1. GABORWAVELET
%                2. TEXTONS
%                3. TEXTON HISTOGRAM
%                4. CC features
%                5. LOG and CC features
%                6. GIST features
%                7. LBP wihtout compression
%                8. LBP with rotation invariance

function FeaturesCompute(imgFileName)

if( nargin < 1 )
    imgFileName = '/cluster/home/retinamap/synapseProject/source/synapseDetector/benchmark/testImages.txt';
end
fprintf(1,'Loading FILTERINFO: ');
tic
load('/cluster/home/retinamap/synapseProject/source/synapseDetector/benchmark/data/FILTERINFO.mat');
toc
bmark.features      = { 'gaborwavelets','textonEnergy','texton','morph1','morph2','gist','lbp','lbpr','ray','radon','zernike','cfmt' };
bmark.N = 512;
imgNames = importdata( imgFileName );
for imgIter = 1:numel(imgNames)
    imgname = imgNames{imgIter};
    fprintf(1,[imgname '\n']);
    [fullPath rawFName c]=fileparts( imgname );
    destDir = [fullPath '/features/'];
    if( ~isdir( destDir ) );    mkdir(destDir);    end
    storename = [destDir rawFName '.mat'];
    if exist(storename,'file')==0
        tic
        Bags = Features(imgname, bmark, FILTERINFO);
        toc
        if isempty(Bags)
            display('File skipped because image size is too small!')
        end
        save([destDir rawFName '.mat'],'Bags');
    else
        display('file exists!')
    end
end
display('job completed!')


%% Create feature files for positive image samples
function Bags = Features(imagename, bmark, FILTERINFO)
N_HALF = round(bmark.N/2);

try,    I = imread(imagename);
        if any(size(I)<bmark.N)
            Bags =  [];
            return
        end
        [H W C] = size(I); H_HALF = round(H/2); W_HALF = round(W/2);
        if( C > 1 ), I = rgb2gray(I); end
        I = I(H_HALF-N_HALF:H_HALF+N_HALF-1,W_HALF-N_HALF:W_HALF+N_HALF-1);
%         if( bmark.resizeImg), I = imresize(I,[1024 1024]); end
catch me,   display('PNG ERROR!');  end

for featIter = 1:4
%     tic
%     fprintf(1, [num2str(featIter) ' ' bmark.features{featIter} ':']);
    FILTERINFO.ID = featIter;
    [~,Bags{featIter}.Features] = cbi_bagimg(I, FILTERINFO);
    Bags{featIter}.Featname = bmark.features{featIter};
%     toc
end
