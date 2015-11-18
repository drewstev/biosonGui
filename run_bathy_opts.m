function run_bathy_opts(hf,evnt) %#ok
gd=guidata(hf);

if ~isfield(gd,'bopt');
    bopt.use_tide=0;
    bopt.antenna_height=0;
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
    gd.raw.gps.tide=tide;
end





guidata(hf,gd)

if isfield(gd,'out')
    if gd.bopt.use_tide
    classifyBioson(hf)
    end
end

