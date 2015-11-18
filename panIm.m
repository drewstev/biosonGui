function panIm(hfig,eventdata,handles)%#ok

gd=guidata(hfig);

gd.pan=get(gd.toggle1,'value');

if gd.pan==1;
    set(gd.toggle1,'backgroundcolor','g')
    pan on
else
    set(gd.toggle1,'backgroundcolor',...
        [ 0.9255    0.9137    0.8471])
    gd.xlims=get(gca,'xlim');
    gd.ylims=get(gca,'ylim');
    pan off
end


guidata(hfig,gd);
setFocus(hfig)
end