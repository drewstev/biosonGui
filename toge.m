function toge(hfig,evnt) %#ok

gd=guidata(hfig);

namer=strtok(gd.opt.filename,'.');
[filename, pathname] = uiputfile( ...
    {'*.kml', 'KML Files'}, ...
    'Save as',[gd.opt.outpath,namer,'.kml']);

if filename==0
    return
end

%data type
types={'depth';'vegcover';'vegheight'};
data=gd.out.(types{gd.ge.type});

%only finite vals
ind=find(all(isfinite([gd.out.longitude(:),...
    gd.out.latitude(:),...
    data]),2));
lon=gd.out.longitude(ind(1:gd.ge.thin:end));
lat=gd.out.latitude(ind(1:gd.ge.thin:end));
data2=data(ind(1:gd.ge.thin:end));
mtime=gd.out.mtime(ind(1:gd.ge.thin:end));

%colormap
switch gd.ge.cmap;
    case 1 
        load sgmap
        map=sgmap;
    case 2
        map=flipud(gray);
    case 3
        map=jet; 
    case 4
        map=flipud(hot);
    case 5
        map=cool;
    case 6
        map=spring;
    case 7
        map=summer;
    case 8
        map=autumn;
    case 9
        map=winter;
    case 10
        map=flipud(bone);
    case 11
        map=copper;
    case 12
        map=flipud(pink);
end


gescatter([pathname,filename],lon(:),lat(:),data2(:),'time',mtime(:),...
    'clims',[gd.ge.cmin gd.ge.cmax],'colormap',map,...
    'scale',gd.ge.scale);

gd.opt.outpath=pathname;
guidata(hfig,gd);