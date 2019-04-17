function bopt = bathy_opts(bopt)

hf = figure('units','normalized',...
    'position',[0.253 0.334 0.201 0.291],...
    'menubar','none','name','bathy_opts',...
    'numbertitle','off','color',[0.941 0.941 0.941]);

tabgp = uitabgroup(hf,'Position',[.05 .15 0.9 0.8]);
tab1= uitab(tabgp,'Title','GPS');
tab2 = uitab(tabgp,'Title','Geoid');

gd.use_gps_tide = uicontrol(tab1,'style','checkbox',...
    'units','normalized','position',[0.0949 0.822 0.448 0.0617],...
    'string','Use RTK Tide','backgroundcolor',[0.941 0.941 0.941],...
    'value',bopt.use_tide,...
    'callback',@use_tide);

gd.astr=uicontrol(tab1,'style','text','units','normalized',...
    'position',[0.0949 0.7 0.321 0.0724],...
    'string','Antenna Height (m)',...
    'backgroundcolor',[0.941 0.941 0.941],...
    'horizontalalign','left');
gd.height = uicontrol(tab1,'style','edit','units','normalized',...
    'position',[0.406 0.715 0.2 0.075],...
    'string',sprintf('%0.3f',bopt.antenna_height),...
    'backgroundcolor',[1 1 1]);

gd.gstr=uicontrol(tab1,'style','text','units','normalized',...
    'position',[0.0949 0.6 0.321 0.0724],...
    'string','RTK Mode',...
    'backgroundcolor',[0.941 0.941 0.941],...
    'horizontalalign','left');
gd.rtkmode = uicontrol(tab1,'style','edit','units','normalized',...
    'position',[0.406 0.615 0.2 0.075],...
    'string',sprintf('%0.3f',bopt.rtkmode),...
    'backgroundcolor',[1 1 1]);

gd.use_ppk_tide = uicontrol(tab1,'style','checkbox',...
    'units','normalized','position',[0.0949 0.515 0.448 0.0617],...
    'string','Use PPK Tide','backgroundcolor',[0.941 0.941 0.941],...
    'value',bopt.use_ppk_tide,...
    'callback',@use_ppk_tide);


uipanel2 = uipanel('parent',tab1,...
    'units','normalized',...
    'position',[0.09 0.05 0.822 0.405],...
    'title','PPK Options');

gd.select_ppk = uicontrol(uipanel2,'style','pushbutton',...
    'units','normalized',...
    'position',[0.0329 0.689 0.302 0.254],...
    'string','Select PPK File',...
    'backgroundcolor',[0.941 0.941 0.941],...
    'enable','off','callback',@getppkfile);
gd.ppkfilestr = uicontrol(uipanel2,'style','text',...
    'units','normalized','position',[0.365 0.746 0.207 0.164],...
    'string',bopt.ppkfilename,'backgroundcolor',[0.941 0.941 0.941],...
    'enable','off');
gd.ppk_use_ellipsoid = uicontrol(uipanel2,'style','checkbox',...
    'units','normalized','position',[0.0299 0.436 0.602 0.194],...
    'string','Use Ellipsoid Height','backgroundcolor',[0.941 0.941 0.941],...
    'enable','off','value',bopt.ppk_use_ellipsoid);
gd.ppk_astr=uicontrol(tab1,'style','text','units','normalized',...
    'position',[0.1249 0.1 0.321 0.0724],...
    'string','Antenna Height (m)',...
    'backgroundcolor',[0.941 0.941 0.941],...
    'horizontalalign','left','enable','off');
gd.ppk_height = uicontrol(tab1,'style','edit','units','normalized',...
    'position',[0.476 0.115 0.2 0.075],...
    'string',sprintf('%0.3f',bopt.ppk_antenna_height),...
    'backgroundcolor',[1 1 1],'enable','off');




gd.use_geoid = uicontrol(tab2,'style','checkbox',...
    'units','normalized','position',[0.0949 0.822 0.448 0.0617],...
    'string','Use Geoid Model','backgroundcolor',[0.941 0.941 0.941],...
    'value',bopt.use_geoid,...
    'callback',@use_geoid);

uipanel1 = uipanel('parent',tab2,...
    'units','normalized',...
    'position',[0.09 0.19 0.822 0.605],...
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
        set(gd.use_geoid,'enable','on')
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
    set(gd.gstr,'enable','off');
    set(gd.rtkmode,'enable','off')
end

if bopt.use_ppk_tide
    set(gd.select_ppk,'enable','on')
    set(gd.ppkfilestr,'enable','on')
    set(gd.ppk_use_ellipsoid,'enable','on')
    set(gd.ppk_astr,'enable','on')
    set(gd.ppk_height,'enable','on')
    set(gd.use_gps_tide,'enable','off')
    set(gd.astr,'enable','off')
    set(gd.height,'enable','off','string','0.000')
    set(gd.use_geoid,'enable','off','value',0)
    set(gd.use_ngs,'value',0,'enable','off')
    set(gd.use_static,'enable','off','value',0)
    set(gd.geoid_static,'enable','off','string','0.000')
    set(gd.use_dt4,'enable','off','value',0);
    set(gd.gstr,'enable','off');
    set(gd.rtkmode,'enable','off')
else
    set(gd.select_ppk,'enable','off')
    set(gd.ppkfilestr,'enable','off')
    set(gd.ppk_use_ellipsoid,'enable','off')
    set(gd.ppk_astr,'enable','off')
    set(gd.ppk_height,'enable','off')
end

gd.bopt=bopt;
guidata(hf,gd);




uiwait
gd=guidata(hf);

bopt.use_tide=get(gd.use_gps_tide,'value');
bopt.use_ppk_tide=get(gd.use_ppk_tide,'value');
if bopt.use_tide
    
    bopt.antenna_height=str2double(get(gd.height,'string'));
    bopt.rtkmode=str2double(get(gd.rtkmode,'string'));
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
    bopt.use_geoid=0;
    bopt.gtype='none';
    bopt.ngs_geoid_file=[];
    bopt.static_offset=0;
end

if bopt.use_ppk_tide
    bopt.ppkfilename=gd.bopt.ppkfilename;
    bopt.ppkfilepath=gd.bopt.ppkfilepath;
    bopt.ppk_use_ellipsoid=get(gd.ppk_use_ellipsoid,'value');
    bopt.ppk_antenna_height=str2double(get(gd.ppk_height,'string'));
else
    bopt.ppk_antenna_height=0;
    bopt.ppk_use_ellipsoid=0;
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
        set(gd.rtkmode,'enable','off')
        set(gd.gstr,'enable','off')
        set(gd.use_ppk_tide,'enable','on')
    case 1
        set(gd.astr,'enable','on')
        set(gd.height,'enable','on')
        set(gd.use_geoid,'enable','on')
        set(gd.rtkmode,'enable','on')
        set(gd.gstr,'enable','on')
        set(gd.use_ppk_tide,'enable','off','value',0)
        set(gd.select_ppk,'enable','off')
        set(gd.ppkfilestr,'enable','off','string','')
        set(gd.ppk_use_ellipsoid,'enable','off','value',0)
        set(gd.ppk_astr,'enable','off')
        set(gd.ppk_height,'enable','off')
        
end
%%%%----------------------------------------------------------------------
function use_ppk_tide(hf,evnt) %#ok
gd=guidata(hf);

val=get(gd.use_ppk_tide,'value');
switch val
    case 0
        
%         set(gd.use_geoid,'enable','off','value',0)
%         set(gd.use_ngs,'value',0,'enable','off')
%         set(gd.ngs_fname,'string','','visible','off')
%         set(gd.use_static,'enable','off','value',0)
%         set(gd.geoid_static,'enable','off','string','0.000')
%         set(gd.use_dt4,'enable','off','value',0);
        set(gd.use_gps_tide,'enable','on')
        set(gd.select_ppk,'enable','off')
        set(gd.ppkfilestr,'enable','off')
        set(gd.ppk_use_ellipsoid,'enable','off')
        set(gd.ppk_astr,'enable','off')
        set(gd.ppk_height,'enable','off')
    case 1
        set(gd.use_gps_tide,'enable','off','value',0)
        set(gd.select_ppk,'enable','on')
        set(gd.ppkfilestr,'enable','on')
        set(gd.ppk_use_ellipsoid,'enable','on')
        set(gd.ppk_astr,'enable','on')
        set(gd.ppk_height,'enable','on')
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
function getppkfile(hf,evnt) %#ok

gd=guidata(hf);

if isempty(gd.bopt.ppkfilepath)
    [filename, pathname,fmt] = uigetfile( ...
        '*.txt', 'Select a PPK file (*.txt)');
else
    [filename, pathname,fmt] = uigetfile( ...
        '*.txt', 'Select a PPK file (*.txt)',...
        gd.bopt.ppkfilepath);
end
if filename==0
    return
end

set(gd.ppkfilestr,'string',filename)
gd.bopt.ppkfilepath=pathname;
gd.bopt.ppkfilename=filename;

guidata(hf,gd)

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

gd.bopt.use_ppk_tide=get(gd.use_ppk_tide,'value');
if gd.bopt.use_ppk_tide
    if isempty(gd.bopt.ppkfilename)
        errordlg('Please select a PPK file')
        return

    end
end
guidata(hf,gd)
uiresume


