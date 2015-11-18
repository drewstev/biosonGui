function biosonGui(varargin)
%BIOSONGUI - graphically interpret Biosonics data
%
% BIOSONGUI is a tool for grapically finding the
% bottom and seagrass in biosonics data.


gd.version=2.06;
gd.modified='2015/6/9';


%process input
p=inputParser;
opts={'filename',   [],     {'char'},    {};...
    'pathname',     [],     {'char'},    {};...
    'quantity'      'sv',   {'char'},    {};...
    'blanking',     1,      {'numeric'}, {'nonnegative'};...
    'smoothing',    5,     {'numeric'}, {'scalar'; 'nonnegative'};...
    'minflen',      3,      {'numeric'}, {'nonnegative'};...
    'channel',      1,      {'numeric'}, {'scalar'};...
    'vegheight',    0.1,    {'numeric'}, {};...
    'maxdepth',     7,      {'numeric'}, {};...
    'mindepth',     1,      {'numeric'}, {};...
    'threshold',    [],     {'numeric'}, {};...
    'temp',         [],     {'numeric'}, {};...
    'sal',          [],     {'numeric'}, {};...
    'gpsOffset',    0,      {'numeric'}, {};...
    'avgint',       10,     {'numeric'}, {}};

cellfun(@(x)(p.addParamValue(x{1},x{2},...
    @(y)(validateattributes(y, x{3},x{4})))),num2cell(opts,2));

p.KeepUnmatched = true;
p.parse(varargin{:})
opt=p.Results;
validatestring(opt.quantity, {'sv';'ts';'log10'},'biosonGui','quantity');




%process file
if isempty(opt.filename)
    if isempty(opt.pathname)
    [filename, pathname, fidx] = uigetfile( ...
        {'*.dt4', 'DT4 Files (*.dt4)';...
        '*.ini', 'INI Files (*.ini)';...
        '*.mat', 'MAT Files (*.mat)'},...
        'Select a  file');
    else
            [filename, pathname, fidx] = uigetfile( ...
        {'*.dt4', 'DT4 Files (*.dt4)';...
        '*.ini', 'INI Files (*.ini)';...
        '*.mat', 'MAT Files (*.mat)'},...
        'Select a  file',opt.pathname);
    end
    
    if filename==0
        return        
    end
    
    %if input is ini file, then process 
    if fidx==2
        ini=read_ini([pathname,filename]);
        fields=fieldnames(ini);
        for i=1:length(fields);
            opt.(fields{i})=ini.(fields{i});
        end
        
        %if ini contains no filename
        if ~isfield(opt,'pathname')
            opt.pathname=[pwd,filesep];
        end
        if isempty(opt.filename)
            [opt.filename, opt.pathname] = uigetfile( ...
                {'*.dt4', 'DT4 Files (*.dt4)'},...
                'Select a  file',opt.pathname);
            if opt.filename==0
                return
            end
        end
    else
        opt.filename=filename;
        opt.pathname=pathname;
    end
    
else
    
    %set up working directory
    [path,name,ext]=fileparts(opt.filename);
    if isempty(path) && ~isfield(opt,'pathname')
        opt.pathname=[pwd,filesep];
    end
    if isempty(path) && isfield(opt,'pathname')
        if isempty(opt.pathname)
            opt.pathname=[pwd,filesep];
        
        end
    end

    opt.filename=[name,ext];
   
    
   
    %if specified check it can be found
    if ~exist([opt.pathname,opt.filename],'file')
        error('File not found.')
    end
end

 opt.outpath=opt.pathname;

s=SplashScreen('Biosonics Vegetation Module',...
    'splashscreen2.JPG');
s.addText(20, 50, 'Biosonics Vegetation GUI',...
    'FontSize', 30, 'Color', [0.6 0 0])
s.addText(20, 80,['version ',sprintf('%0.2f',gd.version)],...
    'FontSize', 20, 'Color', [0.6 0 0] )
s.addText(20,110,['Reading File: ',opt.filename],...
    'FontSize', 20, 'Color', [0.6 0 0] )


%read the specified file
switch fidx
    case 1
        dtx=rd_dtx([opt.pathname,opt.filename]);
    case 2
        dtx=rd_dtx([opt.outpath,opt.filename]);
    case 3
        cldata=load([opt.pathname,opt.filename]);
        dtx=cldata.dtx;
        
        ofields={'avgint';'blanking';'gpsOffset';...
            'maxdepth';'mindepth';'minflen';...
            'quantity';'smoothing';'threshold';...
            'vegheight'};
        for i=1:length(ofields)
            opt.(ofields{i})=cldata.opt.(ofields{i});
        end
end



%what channel to process
if opt.channel>length(dtx)
    wh=warndlg(sprintf('Channel %d not available. Using channel %d.',...
        opt.channel,length(dtx)),'modal');
    waitfor(wh)
    opt.channel=length(dtx);
end

dtx=dtx(opt.channel);


%user specifed temp and salinity
env_inp=isempty([opt.sal opt.temp]);
if ~env_inp
    if ~isempty(opt.sal)
        dtx.env.salinity=opt.sal;
    end
    if ~isempty(opt.temp)
        dtx.env.temperature=opt.temp;
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
if fidx~=3
    if any(strcmpi(opt.quantity,{'sv';'ts'}));
        [ts,sv]=calcTsSv(dtx);
    end
else
    ts=dtx.vals;
    sv=dtx.vals;
end


switch opt.quantity
    case 'sv'
        dtx.vals=sv;
        opt.clabel='Volume Scattering Strength (dB)';
        if isempty(opt.threshold)
            opt.threshold=10;
        end
    case 'ts'
        dtx.vals=ts;
        opt.clabel='Target Strength (dB)';
        
        if isempty(opt.threshold)
            opt.threshold=-65;
        end
    case 'log10'
        opt.clabel='log_{10} Pings';
        
        if isempty(opt.threshold)
            opt.threshold=4;
        end
end
        
delete(s)

%set up figure window
set(0,'units','pixels');
ssize=get(0,'screensize');
lp=round(ssize(3)*0.2);
bp=round(ssize(4)*0.1);
wp=round(ssize(3)*0.6);
hp=round(ssize(4)*0.8);

hfig=figure('position',[lp bp wp hp],...
    'KeyReleaseFcn',@cpfcn,...
    'WindowScrollWheelFcn',@scrollfcn);

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
fh = get(hfig,'JavaFrame');

fh.setFigureIcon(javax.swing.ImageIcon('icon.gif'))
set(gcf,'renderer','zbuffer')
set(hfig,'name','Biosonics Vegetation-Depth Gui','menubar','none',...
    'numbertitle','off')

%plot data for original view
gd.ax1=axes('position',[0.1 0.4 .8 0.5]);
gd.im=imagesc(dtx(1).pingnum,-dtx(1).range,dtx(1).vals);
hold on
set(gca,'ydir','normal')
ylabel('Range (m)','fontsize',14)
xlabel('Ping Number','fontsize',14)


colormap(flipud(gray));
gd.c1=colorbar;
set(get(gd.c1,'ylabel'),'string',opt.clabel,...
    'fontsize',14)

gd.xlims=get(gca,'xlim');
gd.ylims=get(gca,'ylim');
gd.xlimo=get(gca,'xlim');
gd.ylimo=get(gca,'ylim');




%Gui Elements
%Start with bottom controls
gd.hp = uipanel('Title','Filter Controls','FontSize',12,...
    'BackgroundColor','white',...
    'Position',[.05 .075 .55 .275]);

gd.hp2 = uipanel('Parent',gd.hp,'Title','Bottom','FontSize',12,...
    'Position',[0.05 0.05 .40 .9]);

gd.edit1=uicontrol('parent',gd.hp2,'Style','edit',...
    'units','normalized','position',[0.05 0.3 0.9 0.1],... %[0.05 0.05 0.9 0.1]
    'string',num2str(opt.blanking),...
    'callback',@classifyBioson);
gd.text1=uicontrol('parent',gd.hp2,'Style','text',...
    'units','normalized','position',[0.05 0.4 0.9 0.1],... %[0.05 0.15 0.9 0.1]
    'string','Bottom Blanking Distance (m)');
gd.edit5=uicontrol('parent',gd.hp2,'Style','edit',...
    'units','normalized','position',[0.05 0.05 0.9 0.1],...
    'string',num2str(opt.threshold),...
    'callback',@classifyBioson);
gd.text5=uicontrol('parent',gd.hp2,'Style','text',...
    'units','normalized','position',[0.05 0.15 0.9 0.1],...
    'string','Threshold');


% gd.edit2=uicontrol('parent',gd.hp2,'Style','edit',...
%     'units','normalized','position',[0.05 0.3 0.9 0.1],... 
%     'string',num2str(opt.mindepth),...
%     'callback',@classifyBioson);
% gd.text2=uicontrol('parent',gd.hp2,'Style','text',...
%     'units','normalized','position',[0.05 0.4 0.9 0.1],...
%     'string','Vegetation Blanking Distance (m)');
gd.edit11=uicontrol('parent',gd.hp2,'Style','edit',...
    'units','normalized','position',[0.05 0.55 0.9 0.1],...
    'string',num2str(opt.minflen),...
    'callback',@classifyBioson);
gd.text11=uicontrol('parent',gd.hp2,'Style','text',...
    'units','normalized','position',[0.05 0.65 0.9 0.1],...
    'string','Minimum Filter Width');

gd.edit3=uicontrol('parent',gd.hp2,'Style','edit',...
    'units','normalized','position',[0.05 0.8 0.9 0.1],...
    'string',num2str(opt.smoothing),...
    'callback',@classifyBioson);
gd.text3=uicontrol('parent',gd.hp2,'Style','text',...
    'units','normalized','position',[0.05 0.9 0.9 0.1],...
    'string','Bottom Smoothing Factor');


gd.text8=uicontrol('style','text','units','normalized',...
    'position',[0.01 0.01 0.35 0.015],...
    'string',['Displaying file: ',opt.filename,...
    ',  Channel: ',sprintf('%d,',opt.channel),...
    sprintf(' %d',dtx.snd.rxee.frequency/1000), 'kHz'],...
    'horizontalalign','left');

%Seagrass controls
gd.hp3 = uipanel('Parent',gd.hp,'Title','Vegetation','FontSize',12,...
    'Position',[0.525 0.05 .40 .9]);

gd.edit10=uicontrol('parent',gd.hp3,'Style','edit',...
    'units','normalized','position',[0.05 0.3 0.9 0.1],...
    'string',num2str(opt.mindepth),...
    'callback',@classifyBioson);
gd.text10=uicontrol('parent',gd.hp3,'Style','text',...
    'units','normalized','position',[0.05 0.4 0.9 0.1],...
    'string','Min. Depth (m)');

gd.edit6=uicontrol('parent',gd.hp3,'Style','edit',...
    'units','normalized','position',[0.05 0.55 0.9 0.1],...
    'string',num2str(opt.maxdepth),...
    'callback',@classifyBioson);
gd.text6=uicontrol('parent',gd.hp3,'Style','text',...
    'units','normalized','position',[0.05 0.65 0.9 0.1],...
    'string','Max. Depth (m)');
gd.edit7=uicontrol('parent',gd.hp3,'Style','edit',...
    'units','normalized','position',[0.05 0.8 0.9 0.1],...
    'string',num2str(opt.vegheight),...
    'callback',@classifyBioson);
gd.text7=uicontrol('parent',gd.hp3,'Style','text',...
    'units','normalized','position',[0.05 0.9 0.9 0.1],...
    'string','Minimum Height (m)');

%view controls
gd.hp4 = uipanel('Title','View','FontSize',12,...
    'BackgroundColor','white',...
    'Position',[.675 .2 .225 .15]);

gd.toggle1=uicontrol('parent',gd.hp4,'style','togglebutton',...
    'units','normalized','position',[0.05 0.65 0.4 0.25],...
    'string','Pan','callback',@panIm);

gd.push2=uicontrol('parent',gd.hp4,'style','pushbutton',...
    'units','normalized','position',[0.5 0.65 0.4 0.25],...
    'string','Zoom','callback',@zoomto);

gd.push3=uicontrol('parent',gd.hp4,'style','pushbutton',...
    'units','normalized','position',[0.05 0.35 0.85 0.2],...
    'string','Show Full Extents','callback',@fullExtents);

gd.check2=uicontrol('parent',gd.hp4,'style','checkbox',...
    'units','normalized','position',[0.05 0.05  0.4 0.2],...
    'string','Bottom','callback',@showclass,...
    'enable','off','value',1);

gd.check3=uicontrol('parent',gd.hp4,'style','checkbox',...
    'units','normalized','position',[0.5 0.05  0.4 0.2],...
    'string','Seagrass','callback',@showclass,...
    'enable','off','value',1);


%edit controls
gd.hp5 = uipanel('Title','Edit','FontSize',12,...
    'backgroundcolor','w','position',...
    [0.675 0.075 0.225 0.12]);

gd.push4=uicontrol('parent',gd.hp5,'style','pushbutton',...
    'units','normalized','position',[0.05 0.6 0.4 0.3],...
    'string','Lasso','callback',@lassoTool,...
    'enable','off');

gd.push5=uicontrol('parent',gd.hp5,'style','pushbutton',...
    'units','normalized','position',[0.5 0.6 0.4 0.3],...
    'string','Digitize','callback',@digitizeTool,...
    'enable','off');

gd.push6=uicontrol('parent',gd.hp5,'style','pushbutton',...
    'units','normalized','position',[0.05 0.1 0.4 0.3],...
    'string','Local Filter','callback',@apply_local_filt,...
    'enable','off');

gd.pop1=uicontrol('parent',gd.hp5,'style','popupmenu',...
    'units','normalized','position',[0.5 0.075 0.4 0.315],...
    'string',{'Bottom';'Vegetation'},'enable','off',...
    'callback',@popmotion);


%menu options
gd.menu1=uimenu('label','File');
gd.omenu=uimenu(gd.menu1,'Label','Open','callback',@localopen2);
% uimenu(gd.omenu,'label','New File','callback',@localopen);
% uimenu(gd.omenu,'label','Classification','callback',...
%     @load_classification)
gd.menu2=uimenu(gd.menu1,'Label','Export');
if ~isdeployed
    gd.menu3=uimenu(gd.menu2,'label','To Workspace',...
        'callback',@toworkspace);
end
gd.menu4=uimenu(gd.menu2,'label','MAT-File',...
    'callback',@tomatfile);
gd.menu13=uimenu(gd.menu2,'label','Shape-File',...
    'callback',@toshapefile,'enable','off');
gd.menu21=uimenu(gd.menu2,'label','CSV-File',...
    'callback',@tocsvfile,'enable','off');
gd.menu15=uimenu(gd.menu2,'label','TEXT-File (FACS)',...
    'callback',@tofacs,'enable','off');
gd.menu18=uimenu(gd.menu2,'label','Google Earth (.kml)',...
    'callback',@toge,'enable','off');
gd.menu22=uimenu(gd.menu2,'label','Export Batch',...
    'callback',@export_batch,'enable','off');

gd.menu16=uimenu(gd.menu1,'label','Configure');
gd.menu17=uimenu(gd.menu16,'label','Google Earth Export',...
    'callback',@geconfig);
uimenu(gd.menu16,'label','Batch Export Options',...
    'callback',@batch_gui);

gd.menu14=uimenu(gd.menu1,'label','Save .ini File',...
    'callback',@writeini);


gd.menu5=uimenu('label','Edit');
gd.menu6=uimenu(gd.menu5,'label','Undo','callback',@undo,...
    'enable','off');
gd.menu12=uimenu(gd.menu5,'label','Percent Cover Averaging Interval',...
    'callback',@applypcai);
gd.menu10=uimenu(gd.menu5,'label','Local Filter Options',...
    'callback',@filt_local);
gd.bathyopts=uimenu(gd.menu5,'label','Bathymetry Options',...
    'callback',@run_bathy_opts);
gd.menu11=uimenu(gd.menu5,'label','Color Options',...
    'callback',@applycmap);


gd.menu7=uimenu('label','Utilities');
gd.menu20=uimenu(gd.menu7,'label','File Info','callback',@fileInfo);
gd.menu8=uimenu(gd.menu7,'label','GPS Viewer','callback',@showgps);
gd.menu19=uimenu(gd.menu7,'label','Classification Viewer',...
    'callback',@viewClass,'enable','off');

gd.menu9=uimenu('label','Help');
uimenu(gd.menu9,'label','About','callback',@dispHelp);
uimenu(gd.menu9,'label','Hot Keys','callback',@showKeys);
uimenu(gd.menu9,'label','Reference','callback',@showRefs,...
    'visible','off');


gd.ja = java.awt.Robot;
gd.opt=opt;
gd.raw=dtx;


gd.fill_btm_gaps=1;
gd.fill_btm_maxgapsize=10;

gd.lfd.lftype=1;
gd.lfd.lflen=3;

gd.cmap.type=1;
gd.cmap.clims=get(gca,'clim');

gd.ge.thin=5;
gd.ge.cmin=-10;
gd.ge.cmax=0;
gd.ge.scale=0.3;
gd.ge.type=1;
gd.ge.cmap=3;

gd.batch.out_mat=1;
gd.batch.out_shape=1;
gd.batch.out_csv=1;
gd.batch.out_facs=1;
gd.batch.out_ge=1;


gd.local_spec= {'*.dt4', 'DT4 Files (*.dt4)';...
    '*.mat', 'MAT Files (*.mat)'};

switch fidx
    case {1 2}
        gd.numedits=0;
        guidata(hfig,gd);
    case 3
        %clean data for new file
        gd.numedits=0;
        fields={'edits';'edits2';'out';'p1';'p2';'og'};
        for i=1:length(fields);
            if isfield(gd,fields{i});
                gd=rmfield(gd,fields{i});
            end
        end
        
        gd.opt=cldata.opt;
        gd.raw=cldata.dtx;
        if isfield(cldata,'dtc')
             gd.opt=cldata.opt;
             set(gd.edit1,'string',num2str(gd.opt.blanking))
             set(gd.edit11,'string',num2str(gd.opt.minflen));
             set(gd.edit3,'string',num2str(gd.opt.smoothing));
             set(gd.edit5,'string',num2str(gd.opt.threshold));
             set(gd.edit10,'string',num2str(gd.opt.mindepth));
             set(gd.edit6,'string',num2str(gd.opt.maxdepth));
             set(gd.edit7,'string',num2str(gd.opt.vegheight));
            
             if isfield(cldata.dtc,'bathy_opts')
                 gd.bopt=cldata.dtc.bathy_opts;
             end
             
            if isfield(cldata,'edits')
                 gd.numedits=length(cldata.edits2);
                 gd.edits=cldata.edits;
                 gd.edits2=cldata.edits2;
                
                set(gd.menu6,'enable','on')
                set(gd.push4,'enable','on');
                set(gd.push5,'enable','on');
                set(gd.push6,'enable','on');
                set(gd.pop1,'enable','on');
                set(gd.menu13,'enable','on');
                set(gd.menu15,'enable','on');
                set(gd.menu18,'enable','on')
                set(gd.menu6,'enable','on');
                set(gd.menu19,'enable','on');
                set(gd.menu22,'enable','on')
            else
                gd.numedits=0;
            end
        end
        guidata(hfig,gd);
        classifyBioson(hfig)
end


