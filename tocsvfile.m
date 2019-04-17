function tocsvfile(hfig,evnt) %#ok

gd=guidata(hfig);

if ~isfield(gd,'out');
    errordlg('Please run classification algorithm first.')
    return
end

namer=strtok(gd.opt.filename,'.');
[filename, pathname] = uiputfile( ...
    {'*.csv', 'CSV Files'}, ...
    'Save as',[gd.opt.outpath,namer,'.csv']);

if filename==0
    return
end


classifyBioson(hfig);
gd=guidata(hfig);
dtc=gd.out;
    


allfields=fieldnames(dtc);
nfields=structfun(@(x)(isnumeric(x)),dtc);
dtc=rmfield(dtc,allfields(~nfields));
dtc=structfun(@(x)(x(isfinite(dtc.mtime))),dtc,'un',0);

%with or without gps tide
hdrs={'Date and Time (dd-mmm-yyyy HH:MM:SS.SSS)','%s','mtime';...
    'Longitude (deg)','%0.6f','longitude';...
    'Latitude (deg)','%0.6f','latitude';...
    'Depth (m)','%0.2f','depth';...
    'GPS Mode (-)','%0.0f','gpsmode';...
    'GPS Tide Correction (m)','%0.2f','tide';...
    'Elevation (m)','%0.2f','zc';...
    'Veg. Cover (-)','%0.2f','vegcover';...
    'Veg. Height (m)','%0.2f','vegheight'};






%determine which fields if GPS tide is used or not
if isfield(gd,'bopt') 
    if (gd.bopt.use_tide || gd.bopt.use_ppk_tide)
        hfields=hdrs(:,1);
        hdata=hdrs(:,3);
        fmts=hdrs(:,2);
    end
    
else
    hfields=hdrs([1:5,8:9],1);
    hdata=hdrs([1:5,8:9],3);
    fmts=hdrs([1:5,8:9],2);
    
end

fmt=cellfun(@(x,y)([x,y]),fmts',...
    [repmat({','},1,length(fmts)-1),{'\n'}],'un',0);


%file header
fid=fopen([pathname,filename],'wt');
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

gd.opt.outpath=pathname;
guidata(hfig,gd);
