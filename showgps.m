function showgps(hfig,evnt) %#ok

gd=guidata(hfig);

figure
subplot(1,2,1)
plot(gd.raw.gps.longitude,gd.raw.gps.latitude,'k.')
xlabel('Longitude (\circE)')
ylabel('Latitude (\circN)')

subplot(3,2,2)
plot(gd.raw.pingnum,gd.raw.gps.elevation,'k-')
set(gca,'xticklabel',[],...
    'yaxislocation','r',...
    'xlim',[0 max(gd.raw.pingnum)])
ylabel('Altitude (m)')

subplot(3,2,4)
plot(gd.raw.pingnum,gd.raw.gps.nsats,'k-')
set(gca,'xticklabel',[],...
    'yaxislocation','r',...
    'xlim',[0 max(gd.raw.pingnum)])
ylabel('Num. Satellites')

subplot(3,2,6)
plot(gd.raw.pingnum,gd.raw.gps.quality,'k-')
set(gca,'yaxislocation','r',...
    'ylim',[0 5],...
    'ytick',(1:4),...
    'xlim',[0 max(gd.raw.pingnum)])
ind=find(gd.raw.gps.quality==3);
hold on 
plot(gd.raw.pingnum(ind),gd.raw.gps.quality(ind),'gs')

xlabel('Ping Number')
ylabel('GPS Status')