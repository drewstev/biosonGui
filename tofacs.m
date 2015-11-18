function tofacs(hfig,evnt) %#ok

gd=guidata(hfig);

namer=strtok(gd.opt.filename,'.');
[filename, pathname] = uiputfile( ...
    {'*.txt', 'TEXT Files'}, ...
    'Save as',[gd.opt.outpath,namer,'.txt']);

write_facs([pathname,filename],gd.out.longitude(:),...
    gd.out.latitude(:),gd.out.depth(:),gd.out.mtime(:))

gd.opt.outpath=pathname;
guidata(hfig,gd);