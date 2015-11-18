function dispHelp(hfig,evnt) %#ok
gd=guidata(hfig);

str0=strjust(char(['Version',sprintf(' %0.2f',gd.version)],...
    ' written by Andrew Stevens',...
    ['Last Modified ',gd.modified],' '),'left');
str1=strjust(char('If you have questions',...
    'or want to report a bug, contact me:',' '),'left');
str2=strjust(char('Andrew Stevens',...
    'astevens@usgs.gov', 'tel: 650 329 5243 (USA)'),'left');

str={str0;str1;str2};
h=helpdlg(str,'About Biosonics Vegetation Module');
g=get(h,'children');
set(g(1:2),'fontsize',18)

end