function showclass(hfig,evnt) %#ok

gd=guidata(hfig);

if get(gd.check3,'value')
    set(gd.p1,'visible','on');
else
    set(gd.p1,'visible','off')
end

if get(gd.check2,'value')
    set(gd.p2,'visible','on');
else
    set(gd.p2,'visible','off')
end