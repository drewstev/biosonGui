function run_bathy_opts(hf,evnt) %#ok
gd=guidata(hf);

if ~isfield(gd,'bopt')
    bopt.use_tide=0;
    bopt.use_ppk_tide=0;
    bopt.ppkfilename='';
    bopt.ppkfilepath='';
    bopt.ppk_use_ellipsoid=0;
    bopt.ppk_antenna_height=0;
    bopt.antenna_height=0;
    bopt.rtkmode=3;
    bopt.use_geoid=0;
    bopt.gtype='geoid_file';
    bopt.ngs_geoid_file=[];
    bopt.static_offset=0;
    
else
    bopt=gd.bopt;
end

gd.bopt=bathy_opts(bopt);


%if selected read the ngs binary geoid file
if strcmpi(gd.bopt.gtype,'geoid_file')
    if ~isfield(gd,'geoid_model')
        
        str=get(gd.text8,'string');
        [~,file,ext]=fileparts(gd.bopt.ngs_geoid_file);
        set(gd.text8,'string',['Reading geoid model file: ',...
            file,ext],'foregroundcolor','r')
        pause(0.1)
        drawnow
        gd.geoid_model=read_geoid(gd.bopt.ngs_geoid_file);
        
        set(gd.text8,'string','Triangulating geoid model file')
        drawnow
        [gx,gy]=meshgrid(gd.geoid_model.lon,gd.geoid_model.lat');
        gd.geoid_t=scatteredInterpolant(gx(:),gy(:),gd.geoid_model.data(:));
        
        set(gd.text8,'string',str,'foregroundcolor','k')
        gd.geoid_interp=0;
    end
    
end


%apply bathy options
if gd.bopt.use_tide
    tide=gd.raw.gps.elevation-...
        gd.bopt.antenna_height;
    if gd.bopt.use_geoid
        switch gd.bopt.gtype
            case 'geoid_file'
               
                undulation=...
                    gd.geoid_t(gd.raw.gps.longitude,...
                    gd.raw.gps.latitude);
                gd.geoid_interp=1;
                gd.raw.gps.separation=undulation;
                
                tide=(gd.raw.gps.elevation-...
                    gd.bopt.antenna_height)-...
                    undulation;
                
            case 'static'
                tide=(gd.raw.gps.elevation-...
                    gd.bopt.antenna_height)-...
                    gd.bopt.static_offset;
                
            case 'dt4'
                tide=(gd.raw.gps.elevation-...
                    gd.bopt.antenna_height)-...
                    gd.raw.gps.separation;
                
        end
    end
    tide(gd.raw.gps.quality~=gd.bopt.rtkmode)=NaN; %should only use RTK for tides
    gd.raw.gps.tide=tide;
    guidata(hf,gd)
end

if gd.bopt.use_ppk_tide
    
    h = waitbar(0,'Reading PPK GPS file, Please wait...');
    set(h,'name','Import PPK GPS data');
    gd.ppk_data=readgnav([gd.bopt.ppkfilepath,gd.bopt.ppkfilename]);
    waitbar(1,h,'Done!');
    close(h)
    
    guidata(hf,gd)
    apply_ppk_bio(hf);
    
    gd=guidata(hf);
    if gd.bopt.ppk_use_ellipsoid
        gd.raw.gps.tide=(gd.raw.gps.elevation-...
                    gd.bopt.ppk_antenna_height);
    else
        gd.raw.gps.tide=(gd.raw.gps.altitude-...
                    gd.bopt.ppk_antenna_height);
    end
    guidata(hf,gd)
end



if isfield(gd,'out')
    guidata(hf,gd);
    if gd.bopt.use_tide
    classifyBioson(hf)
    end
    if gd.bopt.use_ppk_tide
    classifyBioson(hf)
    end    
end

