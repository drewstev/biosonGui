function export_batch(hfig,evnt) %#ok

gd=guidata(hfig);
str=get(gd.text8,'string');

namer=strtok(gd.opt.filename,'.');
[filename, pathname] = uiputfile( ...
    {'*.*',  'All Files (*.*)'},...
    'Select File Name',[gd.opt.outpath,namer]);

if filename==0
    return
end
if isfield(gd,'out')
    classifyBioson(hfig)
end

%mat file
if gd.batch.out_mat
    
    set(gd.text8,'string',['Exporting MAT file: ',filename,'.mat'],...
        'foregroundcolor','r')
    pause(0.1)
    
    opt=gd.opt;
    dtx=gd.raw; %#ok
    if isfield(gd,'out');
        class=1;
        dtc=gd.out; %#ok
        if isfield(gd,'edits2')
            edits=gd.edits; %#ok
            edits2=gd.edits2; %#ok
        end
    else
        class=0;
    end
    
    
    if class
        if isfield(gd,'edits2')
            save([pathname,filename,'.mat'],'dtx','opt','dtc',...
                'edits','edits2');
        else
            save([pathname,filename,'.mat'],'dtx','opt','dtc');
        end
    else
        save([pathname,filename,'.mat'],'dtx','opt');
    end
end

%shape file

if gd.batch.out_shape
    
    set(gd.text8,'string',['Exporting SHP file: ',filename,'.shp'],...
        'foregroundcolor','r')
    pause(0.1)
    
    fields={'Geometry';...
        'Filename';...
        'Time';...
        'Lon';...
        'Lat';...
        'Depth';...
        'GPS_Tide';...
        'Elevation';...
        'VegFlag';...
        'VegCover';...
        'VegHeight'};
    if isfield(gd,'bopt')
        if gd.bopt.use_tide
            fidx=1:length(fields);
            dfields={'mtime','longitude','latitude',...
                'depth','tide','zc','vegflag',...
                'vegcover','vegheight'};
        else
            fidx=[1:6,9:11];
            dfields={'mtime','longitude','latitude',...
                'depth','vegflag',...
                'vegcover','vegheight'};
        end
        
    else
        fidx=[1:6,9:11];
        dfields={'mtime','longitude','latitude',...
            'depth','vegflag',...
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
    
    
    
    shapewrite(shp,[pathname,filename,'.shp']);
    
end

%csv file

if gd.batch.out_csv
    
    
    
    if isfield(gd,'out');
        dtc=gd.out;
        
    else
        errordlg('Please run classification algorithm first.')
        return
    end
    
    
    
    set(gd.text8,'string',['Exporting CSV file: ',filename,'.csv'],...
        'foregroundcolor','r')
    pause(0.1)
    
    
    allfields=fieldnames(dtc);
    nfields=structfun(@(x)(isnumeric(x)),dtc);
    dtc=rmfield(dtc,allfields(~nfields));
    dtc=structfun(@(x)(x(isfinite(dtc.mtime))),dtc,'un',0);
    
    %with or without gps tide
    hdrs={'Date and Time (dd-mmm-yyyy HH:MM:SS.SSS)','%s','mtime';...
        'Longitude (deg)','%0.6f','longitude';...
        'Latitude (deg)','%0.6f','latitude';...
        'Depth (m)','%0.2f','depth';...
        'GPS Tide Correction (m)','%0.2f','tide';...
        'Elevation (m)','%0.2f','zc';...
        'Veg. Cover (-)','%0.2f','vegcover';...
        'Veg. Height (m)','%0.2f','vegheight'};
    
    
    
    
    
    
    %determine which fields if GPS tide is used or not
    if isfield(gd,'bopt')
        if gd.bopt.use_tide
            hfields=hdrs(:,1);
            hdata=hdrs(:,3);
            fmts=hdrs(:,2);
        end
        
    else
        hfields=hdrs([1:4,7:8],1);
        hdata=hdrs([1:4,7:8],3);
        fmts=hdrs([1:4,7:8],2);
        
    end
    
    fmt=cellfun(@(x,y)([x,y]),fmts',...
        [repmat({','},1,length(fmts)-1),{'\n'}],'un',0);
    
    
    %file header
    fid=fopen([pathname,filename,'.csv'],'wt');
    for i=1:length(hfields)
        if i==length(hfields)
            fprintf(fid,'%s\n',hfields{i});
        else
            fprintf(fid,'%s,',hfields{i});
        end
    end
    
    
    for i = 1:length(dtc.pingnum)
        for j=1:length(hfields)
            if j==1
                fprintf(fid,fmt{j},...
                    datestr(dtc.(hdata{j})(i),'dd-mmm-yyyy HH:MM:SS.FFF'));
            else
                fprintf(fid,fmt{j},dtc.(hdata{j})(i));
            end
        end
    end
    fclose(fid);
    

    
    
    
    
end

%nav file
if gd.batch.out_facs
    set(gd.text8,'string',['Exporting FACS file: ',filename,'.txt'],...
        'foregroundcolor','r')
    pause(0.1)
    
    write_facs([pathname,filename,'.txt'],gd.out.longitude(:),...
        gd.out.latitude(:),gd.out.depth(:),gd.out.mtime(:))
end

%google earth
if gd.batch.out_ge
    set(gd.text8,'string',['Exporting KML file: ',filename,'.lml'],...
        'foregroundcolor','r')
    pause(0.1)
    
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
    
    
    gescatter([pathname,filename,'.kml'],lon(:),lat(:),data2(:),'time',mtime(:),...
        'clims',[gd.ge.cmin gd.ge.cmax],'colormap',map,...
        'scale',gd.ge.scale);
end

set(gd.text8,'string',str,'foregroundcolor','k')

gd.opt.outpath=pathname;
guidata(hfig,gd);



