function FILTERINFO = TextonCreator(bmark,N)

%% Create Texton Dictionary
FILTERINFO.N                = N;
FILTERINFO.freshTextons     = false;

[FILTERINFO.zernQ FILTERINFO.zernSelInd] = computeZernike(FILTERINFO.N);
display('Finished Computing Zernike Polynomial');

if( FILTERINFO.freshTextons )
    FALL = [];
    for iter = 1:numel(bmark.trainFiles)
        numFiles = numel( bmark.trainFiles{iter} ); sel = randperm(numFiles); sel = min(10, numel(sel) );
        for selIter = 1:numel(sel)
            Icurr = imread( [ bmark.trainDir{iter} bmark.trainFiles{iter}( sel(selIter) ).name] ); if( size(Icurr,3) > 1 ), Icurr = rgb2gray(Icurr); end
            FResp = convTexture(Icurr, FILTERINFO.F);
            FALL = [FALL; reshape( FResp, [size(FResp,1)*size(FResp,2), size(FResp,3) ] )];
        end
    end
    FALL = FALL(1:16:end, :);
    try, textonDict = ( vgg_kmeans(FALL', 100 ) )'; catch me, textonDict = kmeans(FALL, 100 ); end
    save('preTextons', 'textonDict');
else,load('preTextons'); end

if ismember(1, bmark.featLib)
    FILTERINFO.FGabor          = cbi_gabordictionary(4, 6, FILTERINFO.N, [0.05 0.4], 0); %
end
if ismember(3, bmark.featLib)
    FILTERINFO.textonDict = textonDict;
end
if any(ismember([2 3 13], bmark.featLib))
    [FILTERINFO.F FILTERINFO.FFreq] = makeRFSfilters(FILTERINFO.N);
end
if ismember(6, bmark.featLib)
    FILTERINFO.gistFilt  = createGabor([8 8 4], FILTERINFO.N);
    FILTERINFO.numberGistBlocks = 4;
end
if ismember(8, bmark.featLib)
    FILTERINFO.mapping   = getmapping(8,'u2');
end
if ismember(11, bmark.featLib)
    [FILTERINFO.zernQ, FILTERINFO.zernSelInd] = computeZernike(FILTERINFO.N);
end
FILTERINFO.patchType = 'nonoverlap';
FILTERINFO.NUMRAND = 10;
FILTERINFO.equalizeImg = false;
