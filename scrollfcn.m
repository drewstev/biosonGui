function scrollfcn(hfig,evnt)

gd=guidata(hfig);



mousenew = get(gd.ax1,'CurrentPoint');
xy=mousenew(1,1:2);
xl=get(gd.ax1,'xlim');
yl=get(gd.ax1,'ylim');

xrange=diff(xl);
yrange=diff(yl);
gd.xlims=[xy(1)-(xrange/2) xy(1)+(xrange/2)];
gd.ylims=[xy(2)-(yrange/2) xy(2)+(yrange/2)];

set(gd.ax1,'xlim',gd.xlims,...
    'ylim',gd.ylims)

guidata(hfig,gd);
setFocus(hfig)