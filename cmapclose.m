function cmapclose(hf,evnt) %#ok

cmap=guidata(hf);

cmap.type=get(cmap.popupmenu1,'value');
cmap.clims=[str2double(get(cmap.edit1,'string')),...
    str2double(get(cmap.edit2,'string'))];

guidata(hf,cmap);
uiresume
