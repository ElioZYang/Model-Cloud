function PLOTFLOW(INPUT)
GAS_PROPERTY=INPUT.GAS_PROPERTY;
F=INPUT.F;
name=INPUT.type;
[~,n]=size(GAS_PROPERTY);
ns=2;
xx=0:n-1;
figure;
% subplot(ns,1,1)
% plot(xx,GAS_PROPERTY(1,:).*(1+GAS_PROPERTY(2,:)),LineWidth=3,Marker="square",Color='black')
% xticks(linspace(0.5,n-1.5,n-1))
% xticklabels(F)
% % xlabel('flow')
% ylabel('Gas Flow(kg/s)')
% set(gca,'FontName','Times','FontSize',12);
% % 设置刻度和刻度标签
% set(gca, 'XTick', (1:length(F))-0.5, 'XTickLabels', F);
subplot(ns,1,1)
plot(xx,GAS_PROPERTY(3,:)/1000,LineWidth=3,Marker="square",Color='blue')
ylim([0,max(GAS_PROPERTY(3,:)/1000)])
xticks(linspace(0.5,n-1.5,n-1))
xticklabels(F)
% xlabel('flow')
ylabel('Pressure(kPa)')
set(gca,'FontName','Times','FontSize',12);
% 设置刻度和刻度标签
set(gca, 'XTick', (1:length(F))-0.5, 'XTickLabels', F);
subplot(ns,1,2)
plot(xx,GAS_PROPERTY(4,:),LineWidth=3,Marker="square",Color='red')
ylim([0,max(GAS_PROPERTY(4,:))])
xticks(linspace(0.5,n-1.5,n-1))
xticklabels(F)
% xlabel('flow')
ylabel('Temperature(K)')
set(gca,'FontName','Times','FontSize',12);
% 设置刻度和刻度标签
set(gca, 'XTick', (1:length(F))-0.5, 'XTickLabels', F);
saveas(gcf,strcat(name," flow"),'png')
% close all
end