function validateInfo = f_validateResults(testInfo, predInfo, auxInfo, SAVE_FIG)
%%% Plots ROC, Precision/Recall and F1 Score for Binary Classification
if( nargin < 1 )
    I = imresize(imread('cameraman.tif'), [100 100] );
    Ig = roipoly(I);
    [Ix Iy] = gradient(double(Ig));
    Ig = sqrt(Ix.^2+Iy.^2) > 0;
    ctr = 1;
    gtLabels = Ig(:);
    for t = .1:.1:.9
        Iedge = edge(I, 'canny', t);
        predMatVariations(:, ctr) = Iedge(:);
        ctr = ctr + 1;
    end
    taskName = 'canny detection';
else
    if(auxInfo.INSTEVAL)
        for metIter = 1:numel(testInfo)
            prepLegend{metIter} = [predInfo{metIter}.bmarkSetting{1} '+' predInfo{metIter}.bmarkSetting{2}];
            colorPick(metIter,: ) = rand(1,3);
            gtLabels{metIter}   = testInfo{metIter}.testMatLabels;       gtLabels{metIter}( gtLabels{metIter} ~= 1 ) = 0;
            predMatVariations{metIter} = predInfo{metIter}.predMatVariations; predMatVariations{metIter}( predMatVariations{metIter} ~= 1 ) = 0;
            taskName = 'connectome detect';
        end
        validateInfo = [];
    elseif( numel( unique( predInfo{1}.predBagLabels ) ) <= 2 )
        currTask = auxInfo.taskName
        for metIter = 1:numel(testInfo)
            gtLabels{metIter}   = testInfo{metIter}.testBagLabels;     gtLabels{metIter}( gtLabels{metIter} ~= 1 ) = 0;
            predBagVariations{metIter} = predInfo{metIter}.predBagVariations; predBagVariations{metIter}( predBagVariations{metIter} ~= 1 ) = 0;
            for ctr = 1:size( predBagVariations{metIter},2 )
                if( strcmp(auxInfo.taskName,'binClass') || ctr<=1 )
                    TP{metIter}(ctr) = sum( predBagVariations{metIter}(:,ctr)     .* gtLabels{metIter}(:) );
                    FP{metIter}(ctr) = sum( predBagVariations{metIter}(:,ctr)     .* (1-gtLabels{metIter}(:)) );
                    FN{metIter}(ctr) = sum( (1-predBagVariations{metIter}(:,ctr)) .* gtLabels{metIter}(:) );
                    TN{metIter}(ctr) = sum( (1-predBagVariations{metIter}(:,ctr)) .* (1-gtLabels{metIter}(:)) );
                    TPR{metIter}(ctr) = TP{metIter}(ctr) / (TP{metIter}(ctr)+FN{metIter}(ctr)+0.001);
                    FPR{metIter}(ctr) = FP{metIter}(ctr) / (FP{metIter}(ctr)+TN{metIter}(ctr)+0.001);
                    Precision{metIter}(ctr) = TP{metIter}(ctr) / (TP{metIter}(ctr)+FP{metIter}(ctr)+0.001);
                    Recall{metIter}(ctr)    = TP{metIter}(ctr) / (TP{metIter}(ctr)+FN{metIter}(ctr)+0.001);
                    F1{metIter}(ctr)        = (2*Precision{metIter}(ctr)*Recall{metIter}(ctr))/(0.01+Precision{metIter}(ctr)+Recall{metIter}(ctr));
                end
            end
            F1{metIter}(:)
        end
        save([currTask '.mat', 'F1', 'Precision', 'Recall']); validateInfo.F1 = F1; validateInfo.Precision = Precision; validateInfo.Recall = Recall;
    end
end

if(auxInfo.INSTEVAL)
    
    for metIter = 1:numel(testInfo)
        for ctr = 1:size( predMatVariations{metIter},2)
            TP{metIter}(ctr) = sum( predMatVariations{metIter}(:,ctr)     .* gtLabels{metIter}(:) );
            FP{metIter}(ctr) = sum( predMatVariations{metIter}(:,ctr)     .* (1-gtLabels{metIter}(:)) );
            FN{metIter}(ctr) = sum( (1-predMatVariations{metIter}(:,ctr)) .* gtLabels{metIter}(:) );
            TN{metIter}(ctr) = sum( (1-predMatVariations{metIter}(:,ctr)) .* (1-gtLabels{metIter}(:)) );
            TPR{metIter}(ctr) = TP{metIter}(ctr) / (TP{metIter}(ctr)+FN{metIter}(ctr));
            FPR{metIter}(ctr) = FP{metIter}(ctr) / (FP{metIter}(ctr)+TN{metIter}(ctr));
            Precision{metIter}(ctr) = TP{metIter}(ctr) / (TP{metIter}(ctr)+FP{metIter}(ctr));
            Recall{metIter}(ctr)    = TP{metIter}(ctr) / (TP{metIter}(ctr)+FN{metIter}(ctr));
            F1{metIter}(ctr)        = (2*Precision{metIter}(ctr)*Recall{metIter}(ctr))/(Precision{metIter}(ctr)+Recall{metIter}(ctr));
        end
    end
    
    figure(1);
    for metIter = 1:numel(testInfo)
        hold on;
        plot(FPR{metIter}, TPR{metIter}, 'Color', colorPick(metIter,:), 'LineWidth', 3, ...
            'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', 'g', ...
            'MarkerSize', 10); grid on;
    end
    hold off; axis([0 1 0 1]);
    set(gca,'fontsize',14,'fontweight','bold','linewidth',4);
    title(['ROC for ' taskName]);
    xlabel('False Positive Rate','fontsize',16,'fontweight','bold');
    ylabel('True Positive Rate','fontsize',16,'fontweight','bold');
    legend(prepLegend);
    if SAVE_FIG
        saveas(gcf,['Fig/ROC_' num2str(numel(testInfo)) '.fig']);
    end
    figure(2);
    for metIter = 1:numel(testInfo)
        hold on;
        plot(Recall{metIter}, Precision{metIter}, 'Color', colorPick(metIter,:), 'LineWidth', 3, ...
            'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', 'g', ...
            'MarkerSize', 10); grid on;
    end
    hold off; axis([0 1 0 1]);
    set(gca,'fontsize',14,'fontweight','bold','linewidth',4);
    title(['Precision versus Recall  ' taskName]);
    xlabel('Recall','fontsize',16,'fontweight','bold');
    ylabel('Precision','fontsize',16,'fontweight','bold');
    legend(prepLegend);
    if SAVE_FIG
        saveas(gcf,['Fig/PrecisionRecall_' num2str(numel(testInfo)) '.fig']);
    end
    
    figure(3);
    for metIter = 1:numel(testInfo)
        hold on;
        plot(1:numel(F1{metIter}), F1{metIter}, 'Color', colorPick(metIter,:), 'LineWidth', 3, ...
            'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', 'g', ...
            'MarkerSize', 10); grid on;
    end
    hold off; axis([0 numel(F1) 0 1]);
    set(gca,'fontsize',14,'fontweight','bold','linewidth',4);
    title(['F Measure for  ' taskName]);
    xlabel('Parameter Variation','fontsize',16,'fontweight','bold');
    ylabel('F Measure','fontsize',16,'fontweight','bold');
    legend(prepLegend);
    if SAVE_FIG
        saveas(gcf,['Fig/Fmeasure_' num2str(numel(testInfo)) '.fig']);
    end
end
