function plot_dataset(ds_info)
% PLOT_DATASET  Dataset visualizations.
    X=ds_info.features; Y=ds_info.labels;
    feat_names={'Mean Excess Delay [\mus]','Var Excess Delay [\mus^2]',...
                'Mean Doppler [Hz]','Var Doppler [Hz^2]',...
                'N_{eMBB}','N_{URLLC}','N_{mMTC}'};
    figure('Name','Class Distribution');
    bar(1:10,histcounts(Y,0.5:1:10.5),'FaceColor',[0.3,0.6,0.9]);
    xlabel('Class'); ylabel('Count'); title('Waveform Dataset — Class Distribution'); grid on;
    figure('Name','Feature Distributions','Position',[50,50,1200,500]);
    for f=1:7
        subplot(2,4,f);
        histogram(X(:,f),40,'FaceColor',[0.2,0.5,0.8],'EdgeAlpha',0.3);
        xlabel(feat_names{f}); ylabel('Count'); title(sprintf('F%d',f)); grid on;
    end
    subplot(2,4,8); axis off;
    text(0.5,0.5,sprintf('Total: %d samples\n10 classes',ds_info.n_samples),...
         'HorizontalAlignment','center','FontSize',12);
    figure('Name','Feature Correlations','Position',[50,50,1100,400]);
    subplot(1,3,1); scatter(X(:,3),X(:,1),8,Y,'filled','MarkerFaceAlpha',0.4);
    xlabel('Mean Doppler [Hz]'); ylabel('Mean Excess Delay [\mus]'); title('F3 vs F1'); colorbar; grid on;
    subplot(1,3,2); scatter(X(:,5),X(:,6),8,Y,'filled','MarkerFaceAlpha',0.4);
    xlabel('N_{eMBB}'); ylabel('N_{URLLC}'); title('F5 vs F6'); colorbar; grid on;
    subplot(1,3,3); scatter(X(:,2),X(:,3),8,Y,'filled','MarkerFaceAlpha',0.4);
    xlabel('Var Excess Delay [\mus^2]'); ylabel('Mean Doppler [Hz]'); title('F2 vs F3'); colorbar; grid on;
end
