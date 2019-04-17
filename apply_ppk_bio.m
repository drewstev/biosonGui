function apply_ppk_bio(hf,evnt) %#ok

gd=guidata(hf);
if ~isfield(gd.raw.gps,'mtime')
    errordlg('No valid time information in raw data file.')
    return
end


%interpolate onto rdata.ptime
%first check to make sure ppk covers the time frame
if (gd.raw.gps.mtime(1)<gd.ppk_data.mtime(1) || ...
        gd.raw.gps.mtime(end)>gd.ppk_data.mtime(end))
    idx=(gd.ppk_data.mtime>=gd.raw.gps.mtime(1) & ...
        gd.ppk_data.mtime<=gd.raw.gps.mtime(end));
    if numel(find(idx))==0
        gd.bopt.use_ppk_tide=0;
        guidata(hf,gd);
        warning('No overlap in time between PPK file and Biosonics data.')
        return
    else
        warning(['Post-process GPS does not cover entire ',...
            'data record. Tide strings will be truncated.'])
    end
end


fields={'latitude','lat';...
    'longitude','lon';...
    'quality','mode';...
    'nsats','nsats';...
    'dilution','hdop';...
    'altitude','elev';...
    'separation','geoid';...
    'elevation','ellipsoid_ht'};


idx=(gd.ppk_data.mtime>=gd.raw.gps.mtime(1) & ...
    gd.ppk_data.mtime<=gd.raw.gps.mtime(end));
[gpstime_u,ib]=unique(gd.ppk_data.mtime(idx));


for i=1:size(fields,1)
    if isfield(gd.ppk_data,fields{i,2})
        fdata=gd.ppk_data.(fields{i,2})(idx);
        gd.raw.gps.(fields{i,1})=interp1(gpstime_u,...
            fdata(ib),gd.raw.gps.mtime,...
            'linear','extrap');
    end
end
guidata(hf,gd)