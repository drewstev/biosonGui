function applypcai(hfig,evnt) %#ok

gd=guidata(hfig);

prompt={'Percent Cover output interval (pings):'};
name='Enter output ping interval';
numlines=1;
defaultanswer={num2str(gd.opt.avgint)};

answer=inputdlg(prompt,name,numlines,defaultanswer);
gd.opt.avgint=str2double(answer{:});

if gd.opt.avgint>length(gd.raw.pingnum)
    errordlg(['Length of output interval is greater than ',...
        'length of data record. Enter a number between',...
        ' 1 and ' num2str(length(gd.raw.pingnum))])
elseif gd.opt.avgint<0
    errordlg('Output interval should be an integer greater than 0');
elseif rem(gd.opt.avgint,1)~=0
    errordlg('Output interval should be an integer greater than 0')
else

    guidata(hfig,gd);
end