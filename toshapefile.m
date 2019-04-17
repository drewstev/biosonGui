function toshapefile(hfig,evnt) %#ok

gd=guidata(hfig);
str=get(gd.text8,'string');

if ~isfield(gd,'out');
    errordlg('Please run classification algorithm first.')
    return
end

namer=strtok(gd.opt.filename,'.');
[filename, pathname] = uiputfile( ...
    {'*.shp', 'Shape Files'}, ...
    'Save as',[gd.opt.outpath,namer,'.shp']);

if filename==0
    return
else
    gd.opt.outpath=pathname;
end

classifyBioson(hfig)
gd=guidata(hfig);

set(gd.text8,'string',['Exporting SHP file: ',filename],...
    'foregroundcolor','r')
pause(0.1)

fields={'Geometry';...
    'Filename';...
    'Time';...
    'Lon';...
    'Lat';...
    'Depth';...
    'GPS_mode';...
    'GPS_Tide';...
    'Elevation';...
    'VegFlag';...
    'VegCover';...
    'VegHeight'};
if isfield(gd,'bopt')
    if gd.bopt.use_tide
        fidx=1:length(fields);
        dfields={'mtime','longitude','latitude',...
            'depth','gpsmode','tide','zc','vegflag',...
            'vegcover','vegheight'};
    else
        fidx=[1:7,10:12];
        dfields={'mtime','longitude','latitude',...
            'depth','gpsmode','vegflag',...
            'vegcover','vegheight'};
    end
    
else
    fidx=[1:7,10:12];
          dfields={'mtime','longitude','latitude',...
            'depth','gpsmode','vegflag',...
            'vegcover','vegheight'};
end



%shapefile format
ind= all(isfinite([gd.out.longitude(:) gd.out.depth(:)]),2);

shp=repmat(cell2struct(cell(length(fields(fidx)),1),fields(fidx)),...
    length(find(ind==1)),1);
[shp(:).Geometry]=deal('Point');
[shp(:).Filename]=deal(gd.out.filename);

fields2=fields(fidx);
fields2=fields2(3:end);


for i=1:length(dfields)
    if i==1
        shpdata=num2cell(datestr(gd.out.(dfields{i})(ind)),2);
    else
        shpdata=num2cell(gd.out.(dfields{i})(ind));
    end
    
    [shp(:).(fields2{i})]=deal(shpdata{:});
end



shapewrite(shp,[pathname,filename]);
set(gd.text8,'string',str,'foregroundcolor','k')
guidata(hfig,gd);
