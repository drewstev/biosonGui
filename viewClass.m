function viewClass(hfig,evnt) %#ok

gd=guidata(hfig);

figure
ax(1)=subplot(4,1,1:2);
imagesc(gd.raw.pingnum,-gd.raw.range,gd.raw.vals)
set(gca,'ydir','n',...
    'nextplot','add',...
    'xticklabel',[],...
    'xlim',gd.xlims,...
    'ylim',gd.ylims)
plot(gd.out.pingnum,gd.out.vegtop,'g-');
plot(gd.out.pingnum,gd.out.depth,'r-');

switch gd.cmap.type;
    case 1 
        colormap(flipud(gray))
    case 2
        colormap(jet)   
    case 3
        colormap(flipud(hot))
    case 4
        colormap(cool)
    case 5
        colormap(spring)
    case 6
        colormap(summer)
    case 7
        colormap(autumn)
    case 8
        colormap(winter)
    case 9
        colormap(flipud(bone))
    case 10
        colormap(copper)
    case 11
        colormap(flipud(pink))
end

c1=colorbar;
set(get(c1,'ylabel'),'string',gd.opt.clabel,...
    'fontsize',10,'fontang','it','fontweight','b')
ylabel('\bf\it\fontsize{10}Range (m)')


yi=(0:10:100)';
[X,Y]=meshgrid(gd.out.pingnum,yi);
Z=repmat(gd.out.vegcover'.*100,numel(yi),1);
[~,bin]=histc(gd.out.vegcover.*100,yi);
bin(bin==0)=1;
for i=1:length(gd.out.pingnum)
        Z(bin(i):end,i)=NaN;
end

ax(2)=subplot(4,1,3);
pcolor(X,Y,Z)
shading flat
view(2)
hold on
colormap(ax(2),gd.sgmap)

plot(gd.out.pingnum,gd.out.vegcover.*100,'k')
set(gca,'xticklabel',[],...
    'xlim',gd.xlims)
ylabel('\bf\it\fontsize{10}Cover (%)')
c2=colorbar;
set(get(c2,'ylabel'),'string','\bf\itVeg. cover (%)')

set(gca,'ylim',[-5 105],...
    'ytick',(0:25:100),...
    'ydir','n',...
    'layer','top',...
    'box','on')

ax(3)=subplot(4,1,4);
plot(gd.out.pingnum,gd.out.vegheight,'k')
set(gca,'xlim',gd.xlims)
ylabel('\bf\it\fontsize{10}Height (m)')
xlabel('\bf\it\fontsize{10}Ping Number')

pos=get(ax,'position');
wid=pos{1}(3);
pos2=cellfun(@(x)([x(1) x(2) wid x(4)]),pos,'un',0);
set(ax,{'position'},pos2)

linkaxes(ax,'x')
set(gcf,'paperpositionmode','au')








