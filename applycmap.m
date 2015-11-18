function applycmap(hfig,evnt) %#ok

cmap_opt(hfig)
gd=guidata(hfig);

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

set(gca,'clim',gd.cmap.clims);
gd.clims=gd.cmap.clims;
guidata(hfig,gd);