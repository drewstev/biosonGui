function open_webmap(hfig,evnt) %#ok

gd=guidata(hfig);
gd.wmh=webmap;

wmline(gd.raw.gps.latitude,gd.raw.gps.longitude,...
    'featurename',gd.opt.filename);

guidata(hfig,gd)

