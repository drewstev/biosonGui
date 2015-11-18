function filt_local(hfig,evnt) %#ok

gd=guidata(hfig);

hf = figure('units','normalized','position',[0.253 0.521 0.145 0.104],...
    'menubar','none','name','Local Filter Options',...
    'numbertitle','off','color',[0.925 0.914 0.847]);
uicontrol(hf,'style','text','units',...
    'normalized','position',[0.0707 0.233 0.374 0.18],...
    'string','Window Length','backgroundcolor',[0.925 0.914 0.847]);
uicontrol(hf,'style','text','units','normalized',...
    'position',[0.037 0.639 0.407 0.158],'string','Filter Type',...
    'backgroundcolor',[0.925 0.914 0.847]);

lfd.edit1 = uicontrol(hf,'style','edit','units','normalized',...
    'position',[0.502 0.233 0.418 0.211],'string',...
    sprintf('%0.0f',gd.lfd.lflen),...
    'backgroundcolor',[1 1 1]);

lfd.popupmenu1 = uicontrol(hf,'style','popupmenu',...
    'units','normalized','position',[0.508 0.617 0.407 0.203],...
    'string',{'Min';'Max';'Mean';'Median'},'backgroundcolor',[1 1 1],...
    'value',gd.lfd.lftype);

uicontrol(hf,'style','pushbutton',...
    'units','normalized',...
    'position',[0.4 0.01 0.2 0.15],...
    'string','Done','callback',@lfclose)

guidata(hf,lfd);

uiwait
lfd=guidata(hf);
gd.lfd=lfd;
guidata(hfig,gd);
close(hf)
end
%%%%%---------------------------------------------------------------------
function lfclose(hf,evnt) %#ok

lfd=guidata(hf);

lfd.lftype=get(lfd.popupmenu1,'value');
lfd.lflen=str2double(get(lfd.edit1,'string'));

if rem(lfd.lflen,1)~=0
    set(lfd.edit1,'string','Enter Integer Value',...
        'backgroundcolor','r');
    return
else
    set(lfd.edit1,'backgroundcolor','w')
end

guidata(hf,lfd);
uiresume
end