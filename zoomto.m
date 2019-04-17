function zoomto(hfig,evnt) %#ok

gd=guidata(hfig);

pan off
set(gd.toggle1,'backgroundcolor',...
    [0.9255    0.9137    0.8471],...
    'value',0)
set(gd.push2,'backgroundcolor','g');



k=waitforbuttonpress; %#ok
point1 = get(gca,'CurrentPoint');
finalRect = rbbox; %#ok
pause(0.05)
point2 = get(gca,'CurrentPoint');
point1 = point1(1,1:2);

point2 = point2(1,1:2);

xlims=sort([point1(1),point2(1)]);
ylims=sort([point1(2),point2(2)]);
set(gd.ax1,'xlim',xlims,'ylim',ylims);


set(gd.push2,'backgroundcolor',...
    [0.9255    0.9137    0.8471]);

gd.xlims=xlims;
gd.ylims=ylims;

guidata(hfig,gd);
setFocus(hfig)


