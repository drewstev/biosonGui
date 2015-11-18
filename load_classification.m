function load_classification(hfig,evnt) %#ok


gd=guidata(hfig);

[filename, pathname] = uigetfile( ...
    {'*.mat', 'MAT Files (*.mat)'},...
    'Select a  file',gd.opt.outpath);

if filename==0
    return
else
    cldata=load([pathname,filename]);
    if ~all([isfield(cldata,'dtc');isfield(cldata,'opt')])
        warndlg('File does not contain classification data')
        return
    else
        
        gd.opt=cldata.opt;
        set(gd.edit1,'string',num2str(gd.opt.blanking))
        set(gd.edit2,'string',num2str(gd.opt.vblanking))
        set(gd.edit11,'string',num2str(gd.opt.minflen));
        set(gd.edit3,'string',num2str(gd.opt.smoothing));
        set(gd.edit5,'string',num2str(gd.opt.threshold));
        set(gd.edit10,'string',num2str(gd.opt.mindepth));
        set(gd.edit6,'string',num2str(gd.opt.maxdepth));
        set(gd.edit7,'string',num2str(gd.opt.vegheight));

        
        if isfield(cldata,'edits')
            
            gd.numedits=length(cldata.edits2);
            gd.edits=cldata.edits;
            gd.edits2=cldata.edits2;
            set(gd.menu6,'enable','on')
        end
    end
    guidata(hfig,gd);
    classifyBioson(hfig)
end

    