function bopt = bathy_opts(bopt)

hf = figure('units','normalized',...
    'position',[0.253 0.334 0.201 0.291],...
    'menubar','none','name','bathy_opts',...
    'numbertitle','off','color',[0.941 0.941 0.941]);


gd.use_gps_tide = uicontrol(hf,'style','checkbox',...
    'units','normalized','position',[0.0949 0.822 0.448 0.0617],...
    'string','Use GPS Tide','backgroundcolor',[0.941 0.941 0.941],...
    'value',bopt.use_tide,...
    'callback',@use_tide);

gd.astr=uicontrol(hf,'style','text','units','normalized',...
    'position',[0.0949 0.7 0.321 0.0724],...
    'string','Antenna Height (m)',...
    'backgroundcolor',[0.941 0.941 0.941],...
    'horizontalalign','left');
gd.height = uicontrol(hf,'style','edit','units','normalized',...
    'position',[0.406 0.715 0.2 0.075],...
    'string',sprintf('%0.3f',bopt.antenna_height),...
    'backgroundcolor',[1 1 1]);



gd.use_geoid = uicontrol(hf,'style','checkbox',...
    'units','normalized','position',[0.0949 0.622 0.448 0.0617],...
    'string','Use Geoid Model','backgroundcolor',[0.941 0.941 0.941],...
    'value',bopt.use_geoid,...
    'callback',@use_geoid);

uipanel1 = uipanel('parent',hf,...
    'units','normalized',...
    'position',[0.09 0.19 0.822 0.405],...
    'title','Geoid Options');

gd.use_ngs = uicontrol(uipanel1,'style','checkbox',...
    'units','normalized',...
    'position',[0.0329 0.739 0.302 0.194],...
    'string','NGS Geoid File',...
    'backgroundcolor',[0.941 0.941 0.941],...
    'enable','off','callback',@use_ngs);
gd.select_ngs = uicontrol(uipanel1,'style','pushbutton',...
    'units','normalized','position',[0.365 0.746 0.207 0.164],...
    'string','Select File','backgroundcolor',[0.941 0.941 0.941],...
    'enable','off','callback',@select_ngs);
gd.ngs_fname = uicontrol(uipanel1,'style','text',...
    'units','normalized','position',[0.575 0.75 0.307 0.15],...
    'backgroundcolor',[0.941 0.941 0.941],...
    'visible','off');


gd.use_static = uicontrol(uipanel1,'style','checkbox',...
    'units','normalized','position',[0.0299 0.396 0.302 0.194],...
    'string','Static Offset','backgroundcolor',[0.941 0.941 0.941],...
    'enable','off','callback',@use_static);
gd.geoid_static = uicontrol(uipanel1,'style','edit','units',...
    'normalized','position',[0.368 0.373 0.198 0.209],...
    'string','0.00','backgroundcolor',[1 1 1],...
    'enable','off');

gd.use_dt4 = uicontrol(uipanel1,'style','checkbox',...
    'units','normalized','position',[0.0299 0.097 0.502 0.194],...
    'string','From DT4 (not recommended)',...
    'backgroundcolor',[0.941 0.941 0.941],...
    'enable','off','callback',@use_dt4);

gd.done = uicontrol(hf,'style','pushbutton',...
    'units','normalized','position',[0.728 0.059 0.2 0.0777],...
    'string','OK','backgroundcolor',[0.941 0.941 0.941],...
    'callback',@close_bathy_opts);


%need to initialize the parameters
if bopt.use_tide
    if bopt.use_geoid
        gtype=find(strcmpi(bopt.gtype,{'geoid_file';...
            'static';'dt4'}));
        switch gtype
            case 1
                set(gd.select_ngs,'enable','on')
                set(gd.use_ngs,'value',1,...
                    'enable','on')
                set(gd.ngs_fname,'visible','on',...
                    'string',bopt.ngs_geoid_file);
                gd.ngs_filename=bopt.ngs_geoid_file;
            case 2
                set(gd.use_static,'enable','on',...
                    'value',1)
                set(gd.geoid_static,'enable','on',...
                    'string',sprintf('%0.3f',bopt.static_offset));
            case 3
                set(gd.use_dt4,'enable','on','value',1)
        end
    end
else
    set(gd.astr,'enable','off')
    set(gd.height,'enable','off','string','0.000')
    set(gd.use_geoid,'enable','off','value',0)
    set(gd.use_ngs,'value',0,'enable','off')
    set(gd.use_static,'enable','off','value',0)
    set(gd.geoid_static,'enable','off','string','0.000')
    set(gd.use_dt4,'enable','off','value',0);
end

guidata(hf,gd);




uiwait
gd=guidata(hf);

bopt.use_tide=get(gd.use_gps_tide,'value');
if bopt.use_tide
    
    bopt.antenna_height=str2double(get(gd.height,'string'));
    bopt.use_geoid=get(gd.use_geoid,'val');
    if bopt.use_geoid
        switch gd.gtype
            case 1
                bopt.gtype='geoid_file';
                bopt.ngs_geoid_file=gd.ngs_filename;
            case 2
                bopt.gtype='static';
                bopt.ngs_geoid_file=[];
                
            case 3
                bopt.gtype='dt4';
                bopt.ngs_geoid_file=[];
        end
    else
        bopt.gtype='none';
        bopt.ngs_geoid_file=[];
    end
    
    bopt.static_offset=str2double(get(gd.geoid_static,'string'));
else
    bopt.antenna_height=0;
    bopt.use_geoid=0;
    bopt.gtype='none';
    bopt.ngs_geoid_file=[];
    bopt.static_offset=0;
end


close(hf)
%%%%----------------------------------------------------------------------
function use_tide(hf,evnt) %#ok
gd=guidata(hf);

val=get(gd.use_gps_tide,'value');
switch val
    case 0
        set(gd.astr,'enable','off')
        set(gd.height,'enable','off','string','0.000')
        set(gd.use_geoid,'enable','off','value',0)
        set(gd.use_ngs,'value',0,'enable','off')
        set(gd.ngs_fname,'string','','visible','off')
        set(gd.use_static,'enable','off','value',0)
        set(gd.geoid_static,'enable','off','string','0.000')
        set(gd.use_dt4,'enable','off','value',0);
    case 1
        set(gd.astr,'enable','on')
        set(gd.height,'enable','on')
        set(gd.use_geoid,'enable','on')
end



%%%%----------------------------------------------------------------------
function use_geoid(hf,evnt) %#ok

gd=guidata(hf);
val=get(gd.use_geoid,'value');

switch val
    case 0
        set(gd.use_ngs,'enable','off')
        set(gd.use_static,'enable','off');
        set(gd.use_dt4,'enable','off');
        set(gd.geoid_static,'enable','off')
        set(gd.geoid_static,'string','0.000')
        set(gd.select_ngs,'enable','off')
        set(gd.use_dt4,'value',0)
        set(gd.use_ngs,'value',0)
        set(gd.use_static,'value',0)
        set(gd.ngs_fname,'visible','off')
    case 1
        set(gd.use_ngs,'enable','on')
        set(gd.use_static,'enable','on');
        set(gd.use_dt4,'enable','on');
end

%%%%----------------------------------------------------------------------
function use_ngs(hf,evnt) %#ok
gd=guidata(hf);

val=get(gd.use_ngs,'value');
switch val
    case 0
        set(gd.select_ngs,'enable','off')
        set(gd.use_static,'enable','on');
        set(gd.use_dt4,'enable','on');
        set(gd.ngs_fname,'visible','off')
    case 1
        set(gd.select_ngs,'enable','on');
        set(gd.use_static,'enable','off');
        set(gd.geoid_static,'string','0.000')
        set(gd.use_dt4,'enable','off');
        set(gd.ngs_fname,'visible','on')
        
end

%%%%----------------------------------------------------------------------
function use_static(hf,evnt) %#ok
gd=guidata(hf);

val=get(gd.use_static,'value');
switch val
    case 0
        set(gd.use_ngs,'enable','on')
        set(gd.use_dt4,'enable','on')
        set(gd.geoid_static,'enable','off')
    case 1
        set(gd.geoid_static,'enable','on')
        set(gd.use_ngs,'enable','off')
        set(gd.select_ngs,'enable','off');
        set(gd.use_dt4,'enable','off');
        set(gd.ngs_fname,'visible','off')
end

%%%%----------------------------------------------------------------------

function use_dt4(hf,evnt) %#ok
gd=guidata(hf);

val=get(gd.use_dt4,'value');
switch val
    case 0
        set(gd.use_ngs,'enable','on')
        set(gd.use_static,'enable','on')
        
    case 1
        set(gd.geoid_static,'enable','off')
        set(gd.use_ngs,'enable','off')
        set(gd.use_static,'enable','off')
        set(gd.select_ngs,'enable','off');
        set(gd.ngs_fname,'visible','off')
        set(gd.geoid_static,'string','0.000')
        
end

%%%%----------------------------------------------------------------------
function select_ngs(hf,evnt) %#ok
gd=guidata(hf);

[filename, pathname] = uigetfile( ...
    {'*.bin';'*.*'}, ...
    'Pick a NGS Geiod file (*.BIN)');

if filename==0
    return
end

gd.ngs_filename=[pathname,filename];
set(gd.ngs_fname,'string',filename,...
    'visible','on')

guidata(hf,gd)


%%%%----------------------------------------------------------------------
function close_bathy_opts(hf,evnt) %#ok
gd=guidata(hf);

val=get(gd.use_geoid,'val');
switch val
    case 1
        %first make sure at least one correction type is selected
        v(1)=get(gd.use_ngs,'val');
        v(2)=get(gd.use_static,'val');
        v(3)=get(gd.use_dt4,'val');
        if all(v==0)
            errordlg('Please select a geoid model correction type')
            return
        end
        
        %now make sure a ngs file is selected
        if v(1)==1
            if ~isfield(gd,'ngs_filename')
                errordlg('Please select a NGS geoid file')
            end
        end
        
        gd.gtype=find(v==1);
end

guidata(hf,gd)
uiresume


