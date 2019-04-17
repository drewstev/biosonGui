function tomatfile(hfig,evnt) %#ok

gd=guidata(hfig);

dtx=gd.raw; %#ok
opt=gd.opt;
if isfield(gd,'out');
    class=1;
    classifyBioson(hfig);
    gd=guidata(hfig); %make sure latest settings are applied
    dtc=gd.out; %#ok
    if isfield(gd,'edits2')
        edits=gd.edits; %#ok
        edits2=gd.edits2; %#ok
    end
else
    class=0;
end

namer=strtok(opt.filename,'.');
[filename, pathname] = uiputfile( ...
    {'*.mat', 'MAT Files'}, ...
    'Save as',[opt.outpath,namer,'.mat']);

gd.opt.outpath=pathname;

if class
    if isfield(gd,'edits2')
        save([pathname,filename],'dtx','opt','dtc',...
            'edits','edits2');
    else
        save([pathname,filename],'dtx','opt','dtc');
    end
else
    save([pathname,filename],'dtx','opt');
end

guidata(hfig,gd);

 
