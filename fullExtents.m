function fullExtents(hfig,eventdata,handles)%#ok

gd=guidata(hfig);
gd.pan=get(gd.toggle1,'value');

if gd.pan==1;
    set(gd.toggle1,'value',0,...
        'backgroundcolor',[0.9255    0.9137    0.8471])
    pan off
end

set(gca,'xlim',gd.xlimo)
set(gca,'ylim',gd.ylimo)

gd.xlims=gd.xlimo;
gd.ylims=gd.ylimo;


guidata(hfig,gd);
setFocus(hfig);