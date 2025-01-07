function plotRFSgnl(Sgnl,tshow)
figure('Position',[200 200 400 250]);
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter', 'latex');
set(groot,'defaultAxesFontSize',14);
plot(tshow,Sgnl(:,1:length(tshow))');
title("a) \textbf{Recorded Simulated Signal}");
ylim([min(min(Sgnl(:,1:length(tshow))))
    max(max(Sgnl(:,1:length(tshow))))
    ]);
xlim([0.01 0.035]);
xlabel("Time [$s$]");
ylabel("Intensity");
grid on;
box on;
set(gca,'LineWidth',1.5);

myFilename{1}   = 'Figures/RecordedSimulatedSgnl.png';
print(gcf,'-r200','-dpng',myFilename{1});  % saves bitmap
zread           = im2double(imread(myFilename{1}));[I,J]=find(mean(zread,3)<1);
zread           = zread(min(I):max(I),min(J):max(J),:);
imwrite(zread,myFilename{1});
end
