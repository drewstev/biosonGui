function localopen2(hfig,evnt) %#ok

gd=guidata(hfig);

[gd.opt.filename, gd.opt.pathname,fidx] = uigetfile( ...
    gd.local_spec,...
    'Select a  file',gd.opt.pathname);

if gd.opt.filename==0
    return
else
    pathname=gd.opt.pathname;
end

ftype=gd.local_spec{fidx};
if fidx==2
    gd.local_spec=flipud(gd.local_spec);
end


gd.geoid_interp=0;
set(gd.check3,'enable','off')
set(gd.check2,'enable','off')

set(gd.text8,'string',...
    ['Reading file: ',gd.opt.filename,...
    ', Please Wait...'],'foregroundcolor','r')
drawnow


switch ftype
    case '*.dt4'
        %reset gui edit controls
        set(gd.push4,'enable','off');
        set(gd.push5,'enable','off');
        set(gd.push6,'enable','off');
        set(gd.pop1,'enable','off');
        set(gd.menu13,'enable','off');
        set(gd.menu15,'enable','off');
        set(gd.menu18,'enable','off');
        set(gd.menu19,'enable','off');
        set(gd.menu21,'enable','off');
        set(gd.menu22,'enable','off');
        
        %read the specified file
        dtx=rd_dtx([gd.opt.pathname,gd.opt.filename]);
        
        %what channel to process
        dtx=dtx(gd.opt.channel);
        
        
        %user specifed temp and salinity
        env_inp=isempty([gd.opt.sal gd.opt.temp]);
        if ~env_inp
            if ~isempty(gd.opt.sal)
                dtx.env.salinity=gd.opt.sal;
            end
            if ~isempty(gd.opt.temp)
                dtx.env.temperature=gd.opt.temp;
            end
            
            %recalculate speed of sound and range vector
            dtx.env.sv=sw_svel(dtx.env.salinity,...
                dtx.env.temperature,0);
            dtx.range=((1:dtx.snd.sampperping)'+dtx.snd.blank)...
                *(dtx.snd.sampperiod*dtx.env.sv/2e6);
            
        end
        
        %calculate the desired quantity (sv,ts,log10)
        % set up default values for different quantities
        % (if unspecified in input)
        if any(strcmpi(gd.opt.quantity,{'sv';'ts'}))
            [ts,sv]=calcTsSv(dtx);
        end
        
        switch gd.opt.quantity
            case 'sv'
                dtx.vals=sv;
                
            case 'ts'
                dtx.vals=ts;
        end
        
        
        %plot data for original view
        cla
        gd.im=imagesc(dtx.pingnum,-dtx.range,dtx.vals);
        hold on
        set(gca,'ydir','norm')
        
        ylabel('Range (m)','fontsize',14)
        xlabel('Ping Number','fontsize',14)
        
        gd.c1=colorbar;
        set(get(gd.c1,'ylabel'),'string',gd.opt.clabel,...
            'fontsize',14)
        
        gd.raw=dtx;
        gd.xlims=[min(gd.raw.pingnum) max(gd.raw.pingnum)];
        gd.ylims=-[max(gd.raw.range) min(gd.raw.range)];
        gd.xlimo=[min(gd.raw.pingnum) max(gd.raw.pingnum)];
        gd.ylimo=-[max(gd.raw.range) min(gd.raw.range)];
        set(gca,'clim',gd.cmap.clims);
        
        set(gca,'xlim',gd.xlims,...
            'ylim',gd.ylims);
        
        
        %clean data for new file
        gd.numedits=0;
        fields={'edits';'edits2';'out';'p1';'p2';'og'};
        for i=1:length(fields)
            if isfield(gd,fields{i})
                gd=rmfield(gd,fields{i});
            end
        end
        
        guidata(hfig,gd)
        %apply bathy options
        if isfield(gd,'bopt')
            if gd.bopt.use_tide
                tide=gd.raw.gps.elevation-...
                    gd.bopt.antenna_height;
                if gd.bopt.use_geoid
                    switch gd.bopt.gtype
                        case 'geoid_file'
                            
                            if ~isfield(gd,'geoid_t') %this is if you opened a mat file first
                                warndlg(['Geoid Data not found. Use Edit-> ',...
                                    'Bathymetry Options to re-load'])
                            else
                                
                                undulation=...
                                    gd.geoid_t(gd.raw.gps.longitude,...
                                    gd.raw.gps.latitude);
                                gd.raw.gps.separation=undulation;
                                gd.geoid_interp=1;
                                
                                tide=(gd.raw.gps.elevation-...
                                    gd.bopt.antenna_height)-...
                                    undulation;
                            end
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
            if gd.bopt.use_ppk_tide
            
                apply_ppk_bio(hfig);
                
                gd=guidata(hfig);
                if gd.bopt.ppk_use_ellipsoid
                    gd.raw.gps.tide=(gd.raw.gps.elevation-...
                        gd.bopt.ppk_antenna_height);
                else
                    gd.raw.gps.tide=(gd.raw.gps.altitude-...
                        gd.bopt.ppk_antenna_height);
                end
            end
            
        end
        
        
    case '*.mat'
        
        
        matfilename=gd.opt.filename;
        
        %clean data for new file
        gd.numedits=0;
        fields={'edits';'edits2';'out';'p1';'p2';'og'};
        for i=1:length(fields)
            if isfield(gd,fields{i})
                gd=rmfield(gd,fields{i});
            end
        end
        
        cldata=load([gd.opt.pathname,gd.opt.filename]);
        if ~all([isfield(cldata,'dtx');...
                isfield(cldata,'opt')])
            warndlg('File does not contain classification data')
            return
        else
            
            gd.opt=cldata.opt;
            
            set(gd.edit1,'string',num2str(gd.opt.blanking))
            set(gd.edit11,'string',num2str(gd.opt.minflen));
            set(gd.edit3,'string',num2str(gd.opt.smoothing));
            set(gd.edit5,'string',num2str(gd.opt.threshold));
            set(gd.edit10,'string',num2str(gd.opt.mindepth));
            set(gd.edit6,'string',num2str(gd.opt.maxdepth));
            set(gd.edit7,'string',num2str(gd.opt.vegheight));
            gd.opt.pathname=pathname;
            
            
            
            cla
            gd.raw=cldata.dtx;
            gd.im=imagesc(gd.raw.pingnum,-gd.raw.range,...
                gd.raw.vals);
            hold on
            set(gca,'ydir','norm')
            
            ylabel('Range (m)','fontsize',14)
            xlabel('Ping Number','fontsize',14)
            
            gd.c1=colorbar;
            set(get(gd.c1,'ylabel'),'string',gd.opt.clabel,...
                'fontsize',14)
            
            
            gd.xlims=[min(gd.raw.pingnum) max(gd.raw.pingnum)];
            gd.ylims=-[max(gd.raw.range) min(gd.raw.range)];
            gd.xlimo=[min(gd.raw.pingnum) max(gd.raw.pingnum)];
            gd.ylimo=-[max(gd.raw.range) min(gd.raw.range)];
            set(gca,'clim',gd.cmap.clims);
            
            set(gca,'xlim',gd.xlims,...
                'ylim',gd.ylims);
            
            
            %clean data for new file
            gd.numedits=0;
            fields={'edits';'edits2';'out';'p1';'p2';'og'};
            for i=1:length(fields)
                if isfield(gd,fields{i})
                    gd=rmfield(gd,fields{i});
                end
            end
            
            
            if isfield(cldata,'dtc')
                if isfield(cldata.dtc,'bathy_opts')
                    %don't want to update bathy opts if present in the
                    %mat file
                    gd.bopt=cldata.dtc.bathy_opts;
                else
                    
                    %apply bathy options if you open a mat file with no
                    %bathy opts but they are in gui
                    if isfield(gd,'bopt')
                        if gd.bopt.use_tide
                            tide=gd.raw.gps.elevation-...
                                gd.bopt.antenna_height;
                            if gd.bopt.use_geoid
                                switch gd.bopt.gtype
                                    case 'geoid_file'
                                        
                                        if ~isfield(gd,'geoid_t') %this is if you opened a mat file first
                                            warndlg(['Geoid Data not found. Use Edit-> ',...
                                                'Bathymetry Options to re-load'])
                                        else
                                            
                                            undulation=...
                                                gd.geoid_t(gd.raw.gps.longitude,...
                                                gd.raw.gps.latitude);
                                            gd.raw.gps.separation=undulation;
                                            gd.geoid_interp=1;
                                            
                                            tide=(gd.raw.gps.elevation-...
                                                gd.bopt.antenna_height)-...
                                                undulation;
                                        end
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
                        
                        if gd.bopt.use_ppk_tide
                            
                            apply_ppk_bio(hf);
                            
                            gd=guidata(hf);
                            if gd.bopt.ppk_use_ellipsoid
                                gd.raw.gps.tide=(gd.raw.gps.elevation-...
                                    gd.bopt.ppk_antenna_height);
                            else
                                gd.raw.gps.tide=(gd.raw.gps.altitude-...
                                    gd.bopt.ppk_antenna_height);
                            end
                        end
                    end
                    
                end
                
                if isfield(cldata,'edits')
                    
                    gd.numedits=length(cldata.edits2);
                    gd.edits=cldata.edits;
                    gd.edits2=cldata.edits2;
                    set(gd.menu6,'enable','on')
                    
                end
                guidata(hfig,gd);
                classifyBioson(hfig)
                gd=guidata(hfig);
            else
                set(gd.push4,'enable','off');
                set(gd.push5,'enable','off');
                set(gd.push6,'enable','off');
                set(gd.pop1,'enable','off');
                set(gd.menu13,'enable','off');
                set(gd.menu15,'enable','off');
                set(gd.menu18,'enable','off')
                set(gd.menu6,'enable','off');
                set(gd.menu19,'enable','off');
                set(gd.menu21,'enable','off');
                set(gd.menu22,'enable','off');
                
            end
        end
end

if isfield(gd,'wmh')
    if isvalid(gd.wmh)
        wmline(gd.wmh,gd.raw.gps.latitude,gd.raw.gps.longitude,...
    'featurename',gd.opt.filename);
    end
end

if exist('matfilename','var')
    set(gd.text8,'string',...
    ['Displaying file: ',matfilename,...
    ',  Channel: ',sprintf('%d,',gd.opt.channel),...
    sprintf(' %d',gd.raw.snd.rxee.frequency/1000), 'kHz'],...
    'foregroundcolor','k')
else
set(gd.text8,'string',...
    ['Displaying file: ',gd.opt.filename,...
    ',  Channel: ',sprintf('%d,',gd.opt.channel),...
    sprintf(' %d',gd.raw.snd.rxee.frequency/1000), 'kHz'],...
    'foregroundcolor','k')
end

guidata(hfig,gd);
setFocus(hfig);