function popmotion(hfig,evnt) %#ok

gd=guidata(hfig);
val=get(gd.pop1,'value');

switch val
    case 1
        set(gd.push5,'enable','on')
    case 2
end
