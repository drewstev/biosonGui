function geclose(hf,evnt) %#ok

ge=guidata(hf);

ge.thin=str2double(get(ge.edit4,'string'));
ge.cmin=str2double(get(ge.edit3,'string'));
ge.cmax=str2double(get(ge.edit2,'string'));
ge.scale=str2double(get(ge.edit1,'string'));

ge.type=get(ge.popupmenu2,'value');
ge.cmap=get(ge.popupmenu1,'value');

guidata(hf,ge);
uiresume