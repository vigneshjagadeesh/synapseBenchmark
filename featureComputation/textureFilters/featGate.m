function featGate(imDir, featChoice)
if( nargin < 1 )
    imName = '/cluster/home/vignesh/synapseProject/514_ipl_01_126.tif';
    featChoice = 1;
else
    featChoice = str2num( featChoice );
end
FILTERINFO.N               = 1024;
FILTERINFO.FGabor          = cbi_gabordictionary(4, 6, FILTERINFO.N, [0.05 0.4], 0); %
[FILTERINFO.F FILTERINFO.FFreq] = makeRFSfilters(FILTERINFO.N);
FILTERINFO.gistFilt  = createGabor([8 8 4], FILTERINFO.N);
[FILTERINFO.zernQ, FILTERINFO.zernSelInd] = computeZernike(FILTERINFO.N);
FILTERINFO.freshTextons    = false;
%% Create Texton Dictionary

if( FILTERINFO.freshTextons )
    FALL = [];
    for iter = 1:numel(bmark.trainFiles)
        numFiles = numel( bmark.trainFiles{iter} ); sel = randperm(numFiles); sel = min(10, numel(sel) );
        for selIter = 1:numel(sel)
            Icurr = imread( [ bmark.trainDir{iter} bmark.trainFiles{iter}( sel(selIter) ).name] ); if( size(Icurr,3) > 1 ), Icurr = rgb2gray(Icurr); end
            for filtIter = 1:size(FILTERINFO.F, 3 )
                FResp(:,:,filtIter) = vrl_imfilter( Icurr, FILTERINFO.F(:,:,filtIter) );
            end
            FALL = [FALL; reshape( FResp, [size(FResp,1)*size(FResp,2), size(FResp,3) ] )];
        end
    end
    FALL = FALL(1:16:end, :); textonDict = ( vgg_kmeans(FALL', 100 ) )';  save('preTextons', 'textonDict');
else
    try,
        load('/cluster/home/synapseProject/source/synDetect/benchmark/preTextons.mat');
    catch me
        textonDict = [];
    end
end
FILTERINFO.textonDict = textonDict;
FILTERINFO.patchType = 'nonoverlap';
FILTERINFO.mapping   = getmapping(8,'u2');
FILTERINFO.numberGistBlocks = 4;

FILTERINFO.ID           = featChoice;
bmark.featLib           = featChoice;
FILTERINFO.equalizeImg  = false;
bmark.features   = { 'gaborwavelets' , ... %1
    'textonEnergy' , ...
    'texton', ...
    'morph1' , ...
    'morph2', ...
    'gist', ...
    'lbp', ...
    'lbpr', ...
    'ray', ...
    'radon', ...
    'zernike', ...
    'cfmt', ...
    'coOccur' };%13
allFiles = dir(imDir);
for fileIter = 3:numel(allFiles)
imName = [imDir allFiles(fileIter).name];
if(~isdir(imName))
imName
img = imread(imName);

[imgbag featbag X] = cbi_bagimg(img, FILTERINFO);
display('Features Computed')
pathName = [];
while( ~isempty( imName ) )
[temp2 imName] = strtok( imName, '/');
if( ~isempty(imName) )
pathName = [pathName '/' temp2];
end
end
imNameOnly = strtok(temp2, '.');
pathName = [pathName '/' bmark.features{featChoice} '/' imNameOnly];
save([pathName '.mat'], 'featbag');
display('Written to file')

end
end
exit;
